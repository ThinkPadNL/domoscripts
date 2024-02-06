# encoding: utf-8
'''
round_temp -- Injects temperature information from a Honeywell Round Connected Modulation into a Domoticz instance.

@author:     Nicky Bulthuis

@copyright:  2015 Nicky Bulthuis. All rights reserved.

@license:    BSD

@deffield    updated: Updated
'''

import sys, json, urllib2
from argparse import ArgumentParser
from evohomeclient2 import EvohomeClient

def main(argv=None):
    
    parser = ArgumentParser(description='Injects temperature information from a Honeywell Round Connected Modulation into a Domoticz instance.')
    parser.add_argument("--url", dest="url", help="URL to Domoticz, eg: http://localhost:8080", default='http://localhost:8080')
    parser.add_argument("-t", "--device-id-temp", dest="device_temp", help="Device id for the temperature", type=int, required=True)
    parser.add_argument("-s", "--device-id-setpoint", dest="device_setpoint", help="Device id for setpoint", type=int, required=False)

    parser.add_argument("-u", "--username", dest="username", help="Username of your mytotalconnect.com account.", required=True)
    parser.add_argument("-p", "--password", dest="password", help="Password of your mytotalconnect.com account.", required=True)
    parser.add_argument("-z", "--zone", dest="zone", help="The name of the zone.", required=True)
    
    args = parser.parse_args()
    
    client = EvohomeClient(args.username, args.password, debug=False)
    
    for device in client.temperatures():
        
        if device['name'] == args.zone:
            
            temp = device['temp']
            setpoint = device['setpoint']
            
            #/json.htm?type=command&param=udevice&idx=IDX&nvalue=0&svalue=TEMP
            result_temp = json.load(urllib2.urlopen("%s/json.htm?type=command&param=udevice&idx=%s&nvalue=0&svalue=%s" % (args.url, args.device_temp, temp), timeout=5))
            result_setpoint = json.load(urllib2.urlopen("%s/json.htm?type=command&param=udevice&idx=%s&nvalue=0&svalue=%s" % (args.url, args.device_setpoint, setpoint), timeout=5))
            
            if result_temp['status'] == 'OK' and result_setpoint['status'] == 'OK':
                sys.exit(0)
            else:
                sys.exit(1)
            
            
if __name__ == "__main__":
    sys.exit(main())