-- script_device_pclight.lua
--This script will turn on the desklight of my PC, when the PC is on (virtual switch) and there is someone home (virtual switch) and when it is dark enough
--When the PC is turned off OR nobody is home anymore, the desklight will be turned off

local presence_switch = 'IemandThuis'
local light_switch = 'Bureaulamp werkkamer'
local pc_switch = 'PC Werkkamer'
local lux_sensor = 'Lichtintensiteit'

commandArray = {}
sLUX = tonumber(otherdevices_svalues[lux_sensor])
if (devicechanged[pc_switch] == 'On' and otherdevices[light_switch] == 'Off' and otherdevices[presence_switch] == 'On' and sLUX < 300) then
		print('<font color="blue">At least one phone is home, turn the presence switch to ON</font>')
		commandArray[light_switch]= 'On'

if (devicechanged[pc_switch] == 'Off' and (otherdevices[light_switch] == 'On' or otherdevices[presence_switch] == 'Off' or sLUX > 300)) then
		print('<font color="blue">At least one phone is home, turn the presence switch to ON</font>')
		commandArray[light_switch]= 'Off'
	end
end
return commandArray