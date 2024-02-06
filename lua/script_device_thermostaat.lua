--script_device_thermostaat.lua
-- This script will change the heating mode on a Honeywell Round Connected Modulation by calling the round_modus.py script when a switch in Domoticz is actuated
commandArray = {}
ThermostaatSwitch = 'Verwarming eco/klokprogramma'

if (devicechanged[ThermostaatSwitch]=='On') then
   os.execute('/usr/bin/python /home/domoticz/domoticz/scripts/python/round_modus.py -u EMAILADDRESS -p PASSWORD --eco')
   print('<b style="color:Blue">Thermostaat op Eco-mode (3 graden lager dan klokprogramma)</b>')
end
if (devicechanged[ThermostaatSwitch]=='Off') then
   os.execute('/usr/bin/python /home/domoticz/domoticz/scripts/python/round_modus.py -u EMAILADDRESS -p PASSWORD --normal')
   print('<b style="color:Blue">Thermostaat van Eco-mode (3 graden lager dan klokprogramma) terug naar klokprogramma</b>')
end
return commandArray