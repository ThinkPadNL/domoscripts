-- script_time_nomotion.lua
-- This script flips a switch when no motion has been detected for more than 30 minutes 

--Change the values below to reflect to your own setup
local motion_switch 		= 'Motion'
local nomotion_uservar 		= 'nomotionCounter'
local status_switch 		= 'IemandThuis'
local energy_consumption    = 'TV-hoek - verbruik'  --Name of Z-Wave plug that contains actual consumption of washingmachine (in Watts)
local consumption_lower     = 60.0                 --If usage is higher than this value (Watts), the TV is playing/radio is on
local nomotion_timeout		= 30	--Amount of minutes that no motion should be detected to assume nobody is home anymore
sWatt, sTotalkWh 			= otherdevices_svalues[energy_consumption]:match("([^;]+);([^;]+)")

commandArray = {}

no_motion_minutes = tonumber(uservariables[nomotion_uservar])
remaining = nomotion_timeout - no_motion_minutes

if (otherdevices[motion_switch] == 'Off') then
	no_motion_minutes = no_motion_minutes + 1
	print('<font color="red">Al ' ..tonumber(no_motion_minutes).. ' minuten geen beweging gedetecteerd, over ' ..tonumber(remaining).. ' minuten gaat het licht uit!</font>')	
else 
	no_motion_minutes = 0
	--print('<font color="red">Beweging gedetecteerd, teller gereset naar ' ..tonumber(no_motion_minutes).. '</font>')
end 

commandArray['Variable:' .. nomotion_uservar] = tostring(no_motion_minutes)

--if otherdevices[status_switch] == 'On' and no_motion_minutes > 30 then
if otherdevices[status_switch] == 'On' and no_motion_minutes > tonumber(nomotion_timeout) and tonumber(sWatt) < consumption_lower then
 	commandArray[status_switch]='Off'
	print('<font color="red">Al ' ..tonumber(no_motion_minutes).. ' minuten geen beweging gedetecteerd, niemand meer thuis</font>')	
end

return commandArray