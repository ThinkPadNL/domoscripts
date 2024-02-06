-- script_time_motion.lua
-- This script activates a presence switch ('status_switch') when there is motion detected. This presence switch is used in other scripts to turn on various items.
local motion_switch = 'Motion'
local status_switch = 'IemandThuis'
local hallway_switch = 'Licht gang'

commandArray = {}

if (devicechanged[motion_switch] == 'On' and otherdevices[status_switch]) == 'Off' then --motion detected, so there is someone home
 	commandArray[status_switch]='On'

 	if (otherdevices[hallway_switch] == 'On') then --turn off the light in the hallway, when we enter the livingroom
 	commandArray[hallway_switch]='Off'
	end

end
return commandArray



