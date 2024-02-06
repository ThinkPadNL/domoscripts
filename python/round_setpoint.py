# encoding: utf-8
'''
round_modus -- Honeywell Round Connected Modulation. This script can change the configured setpoint on the thermostat

@author:     Nicky Bulthuis - modified by ThinkPad

@copyright:  2015 Nicky Bulthuis. All rights reserved.

@license:    BSD

@deffield    updated: Updated
'''

import sys
from argparse import ArgumentParser
from evohomeclient2 import EvohomeClient

def main(argv=None):
    
    parser = ArgumentParser(description='Honeywell Round Connected Modulation')
    parser.add_argument("-u", "--username", dest="username", help="Username of your mytotalconnect.com account.", required=True)
    parser.add_argument("-p", "--password", dest="password", help="Password of your mytotalconnect.com account.", required=True)
    parser.add_argument("-s", "--setpoint", dest="setpoint", help="Desired setpoint temperature.", required=True)
    parser.add_argument("-m", "--mode", dest="setpointmode", help="Desired setpoint mode.", required=True)
    parser.add_argument("-t", "--until", dest="until", help="Until time.", required=False)
      
    args = parser.parse_args()
    
    client = EvohomeClient(args.username, args.password, debug=False)
    zone = '873144'

    data = {"HeatSetpointValue":args.setpoint,"SetpointMode":args.setpointmode,"TimeUntil":args.until}
    """
    Setpointmode can be chosen from
    0 = Auto
    1 = PermanentOverride
    2 = TemporaryOverride

    To set a permanent override use the six digit zone ID, set SetpointMode to 1 (PermanentOverride) and set the HeatSetpointValue to the temp you like, in this example 20.5 degrees C
    /opt/evohome-client/evo-settemp.sh XXXXXX 1 20.5

    To cancel the override set SetpointMode to 0 (Auto) and the HeatSetpointValue to 0.0. This makes the zone return to it's normal schedule.
    /opt/evohome-client/evo-settemp.sh XXXXXX 0 0.0

    To set a temporary override set SetpointMode to 2 (TemporaryOverride), set the HeatSetpointValue to the temp you like and set the ISO DateTime
    /opt/evohome-client/evo-settemp.sh XXXXXX 2 19.5 2015-04-27T23:30:00Z

    Source: https://www.domoticz.com/forum/viewtopic.php?f=5&t=4072&start=80#p40858
    """

    #print "%s" % client._get_single_heating_system().zones_by_id #Use this to determine the ID for the zone
    client._get_single_heating_system().zones_by_id[zone]._set_heat_setpoint(data) 
            
if __name__ == "__main__":
    sys.exit(main())

