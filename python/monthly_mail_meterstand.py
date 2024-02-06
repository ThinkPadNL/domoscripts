#monthly_mail_meterstand.py
#This script is meant to be run at the first day of the mont, at 0:01
#It will extract the meter reading of the smart meter connected to Domoticz
#The meter readings will be sent to you in a e-mail
import sys
import json
import urllib2
import re
import time
import datetime
import httplib, urllib

now = datetime.datetime.now()

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

def send_email(recipient, mailsubject, mailbody):
    import smtplib
    from email.MIMEMultipart import MIMEMultipart
    from email.MIMEText import MIMEText
 
    fromaddr = "YOUR_EMAIL_HERE"
    toaddr = recipient
    msg = MIMEMultipart()
    msg['From'] = fromaddr
    msg['To'] = toaddr
    msg['Subject'] = mailsubject
 
    body = mailbody
    msg.attach(MIMEText(body, 'plain'))
 
    server = smtplib.SMTP('smtp.gmail.com', 587)
    server.starttls()
    server.login(fromaddr, "PASSWORD")
    text = msg.as_string()
    server.sendmail(fromaddr, toaddr, text)
    server.quit()

domoticzurl = "http://127.0.0.1:80"
domoticzdeviceid_el = 6
domoticzdeviceid_gas = 7

ElectricityRateUsedOffPeak, ElectricityRateUsedPeak = get_el_values(domoticzurl, domoticzdeviceid_el)
GasMeterReading = get_gas_values(domoticzurl, domoticzdeviceid_gas)

subject = "Meterstanden op %s" % now.strftime("%Y-%m-%d %H:%M")
content = """ 
Meterstand elektra laag (T1): %s kWh
Meterstand elektra hoog (T2): %s kWh
Gasmeterstand:                     %s m3
""" % (ElectricityRateUsedOffPeak, ElectricityRateUsedPeak, GasMeterReading)
send_email("YOUR_EMAIL_HERE", subject, content)