# encoding: utf-8
'''
pvoutput -- Upload van Domoticz naar pvoutput.org

Instructies:

Status informatie voor pvoutput kan ingesteld worden op 5, 10 of 15 minuten, 
roep dit programma aan op dat interval voor een juiste upload.

@author:     Nicky Bulthuis

@copyright:  2014 Nicky Bulthuis. All rights reserved.

@license:    BSD

@deffield    updated: Updated
'''

import sys
import json
import urllib2
import re
from decimal import Decimal

from argparse import ArgumentParser


class Domoticz():
    
    def __init__(self, url):
        
        self.baseurl = url
        
    def __execute__(self, url):
        
        req = urllib2.Request(url)
        return urllib2.urlopen(req, timeout=5)
       
    def get_device(self, xid):
        """
        Get the device information.
        """
        url = "%s/json.htm?type=devices&rid=%s" % (self.baseurl, xid)
        data = json.load(self.__execute__(url))
        return data


def main(argv=None): # IGNORE:C0111
    '''Command line options.'''

    parser = ArgumentParser(description='Upload van Domoticz naar pvoutput.org')
    parser.add_argument("-a", "--apikey", dest="apikey", help="PVOutput API Key", required=True)
    parser.add_argument("-s", "--sid", dest="sid", help="PVOutput System Id", required=True)
    parser.add_argument("-u", "--url", dest="url", help="URL naar Domoticz, eg: http://localhost:8080", default='http://localhost:8080')
    parser.add_argument("-e", "--e-device-id", dest="e_device_id", help="Domoticz Device Id voor het Elektriciteits verbruik", type=int, required=True)
    parser.add_argument("-p", "--pv-device-id", dest="pv_device_id", help="Domoticz Device Id voor het PV", type=int)

    # Process arguments
    args = parser.parse_args()

    e_in, e_uit, e_in_pwr, e_uit_pwr = get_e(args.url, args.e_device_id)
    
    pv_in = 0
    pv_pwr = 0;
    
    if args.pv_device_id:
        pv_in, pv_pwr = get_pv(args.url, args.pv_device_id)

    v1 = pv_in
    v2 = pv_pwr
    v3 = e_in + pv_in - e_uit
    v4 = max(e_in_pwr + pv_pwr - abs(e_uit_pwr), 0)
    
    code = upload_to_pvoutput(args.apikey, args.sid, v1, v2, v3, v4)
    
    if code == 200:
        return 0
    else:
        return code

def floorTime(dt=None, roundTo=60):
    """
    Floor a datetime object to any time laps in seconds
    dt : datetime.datetime object, default now.
    """
    import datetime

    if dt is None:
        dt = datetime.datetime.now()

    dt_min = datetime.datetime(datetime.MINYEAR, 1, 1)
    dt_min = dt_min.replace(tzinfo=dt.tzinfo)

    seconds = (dt - dt_min).seconds
    rounding = seconds // roundTo * roundTo
    return dt + datetime.timedelta(0, rounding - seconds, -dt.microsecond)

def upload_to_pvoutput(apikey, sid, v1, v2, v3, v4):
    
    now = floorTime(roundTo=60*5)
    d = now.strftime('%Y%m%d')
    t = now.strftime('%H:%M')
    
    url = 'http://pvoutput.org/service/r2/addstatus.jsp?d=%s&t=%s&v1=%s&v2=%s&v3=%s&v4=%s' % (d, t, v1, v2, v3, v4)
    
    print url
    req = urllib2.Request(url)
    req.add_header('X-Pvoutput-Apikey', apikey)
    req.add_header('X-Pvoutput-SystemId', sid)
    
    return urllib2.urlopen(req).getcode()
    

def get_e(url, device_id):
    """
    Ophalen gegevens voor het elektriciteit.
    """
    
    device_data = Domoticz(url).get_device(device_id)
    data = device_data['result'][0]

    p = re.compile('^([0-9\.]+) .*$')

    e_in = int(Decimal(p.match(data['CounterToday']).group(1)) * 1000)
    e_uit = int(Decimal(p.match(data['CounterDelivToday']).group(1)) * 1000)
    
    e_in_pwr = int(p.match(data['Usage']).group(1))
    e_uit_pwr = int(p.match(data['UsageDeliv']).group(1))
    
    return e_in, e_uit, e_in_pwr, e_uit_pwr


def get_pv(url, device_id):
    """
    Ophalen gegevens voor PV.
    """
    device_data = Domoticz(url).get_device(device_id)
    data = device_data['result'][0]

    p = re.compile('^([0-9\.]+) .*$')

    pv = int(Decimal(p.match(data['CounterToday']).group(1)) * 1000)
    pv_pwr = int(p.match(data['Usage']).group(1))
    
    return pv, pv_pwr


if __name__ == "__main__":
    sys.exit(main())