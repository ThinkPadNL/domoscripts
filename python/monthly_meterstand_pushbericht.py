#monthly_pushbericht_meterstand.py
#This script is meant to be run at the first day of the mont, at 0:01
#It will extract the meter reading of the smart meter connected to Domoticz
#The meter readings will be sent to you in a pushnotification
#It will also save these readings in a file called 'verbruik.txt' in /home/domoticz/domoticz/scripts/python/
import sys
import json
import urllib2
import re
import time
import datetime
import httplib, urllib


def open_port():
    pass

def close_port():
    pass

class Domoticz():
    
    def __init__(self, url):
        
        self.baseurl = url
        
    def __execute__(self, url):

        req = urllib2.Request(url)
        return urllib2.urlopen(req, timeout=5)
       
    def get_device(self, xid):
        """
        Get the Domoticz device information.
        """
        url = "%s/json.htm?type=devices&rid=%s" % (self.baseurl, xid)
        data = json.load(self.__execute__(url))
        return data


def get_el_values(url, device_id):
    """
    Get electricity meter readings.
    """
    
    device_data = Domoticz(url).get_device(device_id)
    data = device_data['result'][0]['Data']

    ex = re.compile('^([0-9\.]+);([0-9\.]+);([0-9\.]+);([0-9\.]+);([0-9\.]+);([0-9\.]+)$')

    groups = ex.match(data).group
    meter_high = float(groups(1)) / 1000
    meter_low = float(groups(2)) / 1000
    #out_high = float(groups(3)) / 1000
    #out_low = float(groups(4)) / 1000
    #actual_in = float(groups(5)) / 1000
    #actual_out = float(groups(6)) / 1000

    return meter_high, meter_low#, out_high, out_low, actual_in, actual_out

def get_gas_values(url, device_id):
    """
    Get gasmeter reading.
    """
    
    device_data = Domoticz(url).get_device(device_id)
    data = device_data['result'][0]['Data']

    ex = re.compile('^([0-9\.]+)$')

    groups = ex.match(data).group
    gasstand = float(groups(1)) #/ 1000

    return gasstand
# example usage

domoticzurl = "http://127.0.0.1:80"
domoticzdeviceid_el = 6
domoticzdeviceid_gas = 7
#ElectricityRateUsedPeak, ElectricityRateUsedOffPeak, ElectricityRateGeneratedPeak, ElectricityRateGeneratedOffPeak, ElectricityTotalUsed, ElectricityCurrentRateOut = get_el_values(domoticzurl, domoticzdeviceid_el)
ElectricityRateUsedOffPeak, ElectricityRateUsedPeak = get_el_values(domoticzurl, domoticzdeviceid_el)
GasMeterReading = get_gas_values(domoticzurl, domoticzdeviceid_gas)

#print "-- DOMOTICZ ENERGIE--"
#print "Meterstand piektarief (hoog):\t\t"+str(ElectricityRateUsedPeak)+"kWh"
#print "Meterstand daltarief (laag):\t\t"+str(ElectricityRateUsedOffPeak)+"kWh"
#print "Gasmeterstand:\t\t\t\t"+str(GasMeterReading)+"m3"
#print "Totaal:\t\t\t"+str(ElectricityRateUsedPeak + ElectricityRateUsedOffPeak)+"kWh"
#print ""
#print "- Teruggeleverd"
#print "Daltarief:\t\t"+str(ElectricityRateGeneratedOffPeak)+"kWh"
#print "Piektarief:\t\t"+str(ElectricityRateGeneratedPeak)+"kWh"
#print "Huidig verbruik:\t"+str(ElectricityTotalUsed)

conn = httplib.HTTPSConnection("api.pushover.net:443")
conn.request("POST", "/1/messages.json",
urllib.urlencode({
    "token": "YOURTOKENHERE",
    "user": "YOURUSERKEYHERE",
    "message": "Meterstand elektra laag (T1): "+str(ElectricityRateUsedOffPeak)+"\n""Meterstand elektra hoog (T2): "+str(ElectricityRateUsedPeak)+"\n""Gasmeterstand: "+str(GasMeterReading)+"\n Zie ook /volume1/@appstore/domoticz/var/scripts/python/verbruik.txt",
    #"message": "Meterstand elektra hoog (T2): "+str(ElectricityRateUsedPeak)+"\n""Meterstand elektra laag (T1): "+str(ElectricityRateUsedOffPeak)+"\n""Gasmeterstand: "+str(GasMeterReading)+"\n Zie ook /volume1/@appstore/domoticz/var/scripts/python/verbruik.txt",
    "title": "Domoticz - meterstanden",
    "priority": "-1",
  }), { "Content-type": "application/x-www-form-urlencoded" })
conn.getresponse()

# creeer een bestand met de waarde / create a file with the readings
name = '/home/domoticz/domoticz/scripts/python/verbruik.txt'  # Naam tekstbestand / Name of text file 
now = datetime.datetime.now()
 
try: 
    file = open(name,'a')   # create file / creeer bestand
    # write the readings to the file / schrijf de waarde naar het bestand
    file.write('Meterstanden op ' + str(now.strftime("%Y-%m-%d %H:%M")) + ' waren als volgt: \n' 'Elektra laagtarief (T1): ' +str(ElectricityRateUsedOffPeak) + '\n' 'Elektra hoogtarief (T2): ' +str(ElectricityRateUsedPeak) + '\n' 'Gasmeter: ' +str(GasMeterReading) + '\n\n')
    # close the file / sluit het bestand (vergelijkbaar met het 'save' en daarna 'close' commando in word)
    #file.close()
except: # something went wrong / in het vorige blok is iets niet goed gegaan (error)
    print('Something went wrong!')
    sys.exit(0) # quit if something goes wrong Python / stop als er iets mis is gegaan



