--script_device_verlichting.lua

commandArray = {}


local light_intensity = 'Lichtintensiteit'
local motion_sensor = 'Motion'
local motion_enabled = 'Motion enabled'
local frontdoor_switch = 'Voordeur'
local killswitch = 'HE_Wandschakelaar'
local status_switch = 'Controlelamp verlichting'
local isdark_switch = 'IsDonker (virt)'

local scene_afwezig = 'Bewust afwezig'
local group_standby_devices = 'Standby-killer'
local verlichting_eetkamer = 'Groep - Verlichting - Eetkamer'

local light_group = 'Woonkamer'
local light_hallway = 'Licht gang'
local milight_all = 'AppLamp All'
local milight_tv = 'LED-strip TV'

local lux_lower = 143
local lux_upper = 250


if devicechanged[motion_sensor] or devicechanged[light_intensity] then
	lux = tonumber(otherdevices_svalues[light_intensity])

	--turn lights on when conditions are met
	if devicechanged[motion_sensor] == 'On' and otherdevices[motion_enabled] == 'On' and otherdevices[status_switch] == 'Off' and lux <= tonumber(lux_lower) and lux ~= 54612 then --lux != 54612 is to prevent bug in luxsensor (sometimes jumps to 54612)
		commandArray['Group:' .. light_group]='On'
	elseif lux >= tonumber(lux_upper) and lux ~= 54612 and otherdevices[status_switch] == 'On' then 
	commandArray['Group:' .. light_group]='Off'
	end

	--turn on stand-by devices when motion is detected
	if devicechanged[motion_sensor] == 'On' and otherdevices[motion_enabled] == 'On' then
		commandArray['Group:' .. group_standby_devices]='On'
		if otherdevices[milight_tv] == 'Off' then
		commandArray[milight_all]='Off' --fix to turn off Milight bulbs, because they turn on by default, when they receive power again (their power is turned off when leaving home)
		end
	end
			
end

--reset motion sensor, to allow it to trigger the lights if motion would be detected
if devicechanged[motion_sensor] == 'Off' and otherdevices[motion_enabled] == 'Off' then
	commandArray[motion_enabled]='On'
end

--killswitch is pressed
if devicechanged[killswitch] then
	if devicechanged[killswitch] == 'On' then
		commandArray['Scene:' .. scene_afwezig]='On'
		
		--turn light in hallway on when sun is down
		if otherdevices[isdark_switch] == 'On' and otherdevices[light_hallway] == 'Off' then
		commandArray[light_hallway]= 'On FOR 1'
		end
		
	end
end	

return commandArray