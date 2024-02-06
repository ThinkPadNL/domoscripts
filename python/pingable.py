# encoding: utf-8
'''
pingable -- Pings a device on the local network and notifies Domoticz.
Call it like this from crontab:  python  /home/domoticz/domoticz/scripts/python/pingable.py --idx 30 --url http://127.0.0.1:80 192.168.4.9 -i 30 -c 210

@author:     Nicky Bulthuis

@copyright:  2015 Nicky Bulthuis. All rights reserved.

@license:    BSD

@deffield    updated: Updated
'''

import sys, json, urllib2, time
from datetime import datetime, timedelta
from argparse import ArgumentParser

#
# Originally from https://github.com/samuel/python-ping
# START PING
#
import os, socket, struct, select

if sys.platform == "win32":
    # On Windows, the best timer is time.clock()
    default_timer = time.clock
else:
    # On most other platforms the best timer is time.time()
    default_timer = time.time

# From /usr/include/linux/icmp.h; your milage may vary.
ICMP_ECHO_REQUEST = 8 # Seems to be the same on Solaris.


def checksum(source_string):
    """
    I'm not too confident that this is right but testing seems
    to suggest that it gives the same answers as in_cksum in ping.c
    """
    sum = 0
    countTo = (len(source_string)/2)*2
    count = 0
    while count<countTo:
        thisVal = ord(source_string[count + 1])*256 + ord(source_string[count])
        sum = sum + thisVal
        sum = sum & 0xffffffff # Necessary?
        count = count + 2

    if countTo<len(source_string):
        sum = sum + ord(source_string[len(source_string) - 1])
        sum = sum & 0xffffffff # Necessary?

    sum = (sum >> 16)  +  (sum & 0xffff)
    sum = sum + (sum >> 16)
    answer = ~sum
    answer = answer & 0xffff

    # Swap bytes. Bugger me if I know why.
    answer = answer >> 8 | (answer << 8 & 0xff00)

    return answer


def receive_one_ping(my_socket, ID, timeout):
    """
    receive the ping from the socket.
    """
    timeLeft = timeout
    while True:
        startedSelect = default_timer()
        whatReady = select.select([my_socket], [], [], timeLeft)
        howLongInSelect = (default_timer() - startedSelect)
        if whatReady[0] == []: # Timeout
            return

        timeReceived = default_timer()
        recPacket, addr = my_socket.recvfrom(1024)
        icmpHeader = recPacket[20:28]
        type, code, checksum, packetID, sequence = struct.unpack(
            "bbHHh", icmpHeader
        )
        # Filters out the echo request itself. 
        # This can be tested by pinging 127.0.0.1 
        # You'll see your own request
        if type != 8 and packetID == ID:
            bytesInDouble = struct.calcsize("d")
            timeSent = struct.unpack("d", recPacket[28:28 + bytesInDouble])[0]
            return timeReceived - timeSent

        timeLeft = timeLeft - howLongInSelect
        if timeLeft <= 0:
            return


def send_one_ping(my_socket, dest_addr, ID):
    """
    Send one ping to the given >dest_addr<.
    """
    dest_addr  =  socket.gethostbyname(dest_addr)

    # Header is type (8), code (8), checksum (16), id (16), sequence (16)
    my_checksum = 0

    # Make a dummy heder with a 0 checksum.
    header = struct.pack("bbHHh", ICMP_ECHO_REQUEST, 0, my_checksum, ID, 1)
    bytesInDouble = struct.calcsize("d")
    data = (192 - bytesInDouble) * "Q"
    data = struct.pack("d", default_timer()) + data

    # Calculate the checksum on the data and the dummy header.
    my_checksum = checksum(header + data)

    # Now that we have the right checksum, we put that in. It's just easier
    # to make up a new header than to stuff it into the dummy.
    header = struct.pack(
        "bbHHh", ICMP_ECHO_REQUEST, 0, socket.htons(my_checksum), ID, 1
    )
    packet = header + data
    my_socket.sendto(packet, (dest_addr, 1)) # Don't know about the 1


def do_one(dest_addr, timeout=2):
    """
    Returns either the delay (in seconds) or none on timeout.
    """
    icmp = socket.getprotobyname("icmp")
    try:
        my_socket = socket.socket(socket.AF_INET, socket.SOCK_RAW, icmp)
    except socket.error, (errno, msg):
        if errno == 1:
            # Operation not permitted
            msg = msg + (
                " - Note that ICMP messages can only be sent from processes"
                " running as root."
            )
            raise socket.error(msg)
        raise # raise the original error

    my_ID = os.getpid() & 0xFFFF

    send_one_ping(my_socket, dest_addr, my_ID)
    delay = receive_one_ping(my_socket, my_ID, timeout)

    my_socket.close()
    return delay

#
# END PING
#

# Datetime holding the last successful ping.
dt_last_pingable = None

# 
# Default connection timeout
#
DEFAULT_TIMEOUT = 5

class Domoticz():
    
    def __init__(self, url):
        self.baseurl = url
        
    def __execute__(self, url):
        
        req = urllib2.Request(url)
        return urllib2.urlopen(req, timeout=DEFAULT_TIMEOUT)
    
    def flip_switch(self, xid, wanted_status, verbose=False):
        """
        Turn a switch on or off
        """
        data = self.get_device(xid)
        
        current_status = data['result'][0]['Status']
        
        switchcmd = "Off"
        if wanted_status:
            switchcmd = "On"        
        
        result = True
        
        if current_status != switchcmd:
                        
            switch_url = "%s/json.htm?type=command&param=switchlight&idx=%s&switchcmd=%s&level=0" % (self.baseurl, xid, switchcmd)
            
            if verbose:
                print "Calling Domoticz: %s" % switch_url
              
            status = json.load(self.__execute__(switch_url))
            
            if verbose:
                print "Result Domoticz: %s" % status['status']            
            
            if status['status'] != 'OK':
                result = False
                
        return result
        
    def get_device(self, xid):
        """
        Get the device information.
        """
        #http://192.168.1.3:8080/json.htm?type=devices&rid=16
        url = "%s/json.htm?type=devices&rid=%s" % (self.baseurl, xid)
        data = json.load(self.__execute__(url))
        return data


def start_scheduler(url, interval, cooldown, xid, devices, verbose=False):
    import sched
    
    scheduler = sched.scheduler(time.time, time.sleep)
        
    def ping_devices(): 
        scheduler.enter(interval, 1, ping_devices, ())
        global dt_last_pingable
        
        for device in devices:
            
            delay = do_one(device)
            
            if delay:
                
                if verbose:
                    print "Device %s, got ping reply: %s" % (device, delay)
                dt_last_pingable = datetime.now()
                break

        wanted_status = dt_last_pingable > (datetime.now() - timedelta(seconds=cooldown))
        
        if verbose:
            print "Pingable or in cooldown: %s" % wanted_status
            
        Domoticz(url).flip_switch(xid, wanted_status, verbose)
        
    global dt_last_pingable    

    # reset the last successful ping to now - cooldown
    dt_last_pingable = datetime.now() - timedelta(seconds=cooldown)
    scheduler.enter(0, 1, ping_devices, ())
    scheduler.run()

def main(argv=None):
    
    from tendo import singleton
    
    parser = ArgumentParser(description='Pings a device on the local network and notifies Domoticz.')
    parser.add_argument("-u", "--url", dest="url", help="URL to Domoticz, eg: http://localhost:8080", default='http://localhost:8080')
    parser.add_argument("--idx", dest="idx", help="Domoticz idx for the switch that needs to be notified.", type=int, required=True)
    parser.add_argument("-i", "--interval", dest="interval", help="Ping interval in seconds, defaults to 10", type=int, default=10)
    parser.add_argument("-c", "--cooldown", dest="cooldown", help="Cooldown interval in seconds, defaults to 60", type=int, default=60)
    parser.add_argument("-v", "--verbose", dest="verbose", action="store_true", help="Be verbose", default=False)

    parser.add_argument('devices', metavar='HOST', nargs='+',
                   help='An IP or hostname to ping')

    args = parser.parse_args()
    
    # singleton this instance of the device idx
    me = singleton.SingleInstance(flavor_id=args.idx)
    
    start_scheduler(args.url, args.interval, args.cooldown, args.idx, args.devices, verbose=args.verbose)
        
if __name__ == "__main__":
    sys.exit(main())