#mindergas.py
#made by Nicky Bulthuis
#For more information: http://tweaken.blogspot.nl/2015/01/domoticz-uploaden-naar-mindergasnl.html
import sys, json, urllib2
from datetime import datetime, timedelta
from argparse import ArgumentParser

def main(argv=None):
    
    parser = ArgumentParser(description='Upload meterstand van Domoticz naar MinderGas.nl')
    parser.add_argument("-a", "--apikey", dest="apikey", help="MinderGas.nl API Key", required=True)
    parser.add_argument("-u", "--url", dest="url", help="URL naar Domoticz, eg: http://localhost:8080", default='http://localhost:8080')
    parser.add_argument("-d", "--device-id", dest="device", help="Device id voor de P1 Gas Smart Meter", type=int, required=True)

    args = parser.parse_args()
    
    device_data = json.load(urllib2.urlopen("%s/json.htm?type=devices&rid=%s" % (args.url, args.device), timeout=5))
    meterstand = device_data['result'][0]['Counter']

    code = upload_meterstand(meterstand, args.apikey)

    if code == 201:
        return 0
    else:
        return code


def upload_meterstand(meterstand, apikey):
    """
    Upload meterstand naar mindergas.nl
    """
    data = {
            'date': (datetime.now().date() - timedelta(days=1)).strftime("%Y-%m-%d"),
            'reading': meterstand
    }
    
    req = urllib2.Request('http://www.mindergas.nl/api/gas_meter_readings')
    req.add_header('Content-Type', 'application/json')
    req.add_header('AUTH-TOKEN', apikey)
    
    return urllib2.urlopen(req, json.dumps(data)).getcode()
    
if __name__ == "__main__":
    sys.exit(main())