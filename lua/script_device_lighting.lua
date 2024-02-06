-- script_time_lighting.lua
--This script will turn on some lights, when there is someone home, the lights aren't already on ('checklight' switch) and when the lux is below a certain value
--It will turn the lights off again, when there is nobody home anymore, or when the lux is above a certain value again

local presence_switch = 'IemandThuis'
local lux_sensor = 'Lichtintensiteit'
local checklight = 'Controlelamp verlichting'
local sleep_switch = 'Slapen'

commandArray = {}
sLUX = tonumber(otherdevices_svalues[lux_sensor])
if devicechanged[lux_sensor] or devicechanged[presence_switch] or devicechanged[sleep_switch] then
	if (otherdevices[checklight] == 'Off') and ((otherdevices[presence_switch] == 'On') and (otherdevices[sleep_switch] == 'Off') and ((sLUX < 143 and sLUX ~= 54612))) then
		commandArray[checklight]= 'On'
		commandArray['LED-strip TV en kast']= 'On'
		commandArray['Keuken']= 'On'
		commandArray['Lampje Expedit']= 'On'
		commandArray['Eettafel']= 'Set Level 7'

		elseif (otherdevices[checklight] == 'On' and (otherdevices[sleep_switch] == 'On' or (otherdevices[presence_switch] == 'Off'  or  (sLUX > 250  and  sLUX ~= 54612)))) then
			commandArray[checklight]= 'Off'
			commandArray['LED-strip TV en kast']= 'Off'
			commandArray['Keuken']= 'Off'
			commandArray['Lampje Expedit']= 'Off'
			commandArray['Booglamp']= 'Off'
			commandArray['Eettafel']= 'Off'
		end
end
return commandArray