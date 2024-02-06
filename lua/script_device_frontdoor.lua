-- script_device_frontdoor.lua
--This script will turn on the presence switch when the frontdoor is openend, and the motion hasn't yet been activated
--This is done to let the lights go on immediately when arriving home in the evening

local door_switch = 'Voordeur'
local presence_switch = 'IemandThuis'
local motion_switch = 'Motion'
local isdark_switch = 'IsDonker (virt)'
local nomotion_uservar = 'nomotionCounter'

commandArray = {}

no_motion_minutes = tonumber(uservariables[nomotion_uservar])
time = os.date("*t")  --Get current time
minutes = time.min + time.hour * 60  --Convert time to minutes

if devicechanged[door_switch] == 'On' then
	if (otherdevices[motion_switch] == 'Off' and otherdevices[presence_switch] == 'Off') then

	no_motion_minutes = 0
	commandArray['Variable:' .. nomotion_uservar] = tostring(no_motion_minutes)

	commandArray[presence_switch]='On'
	print('<font color="blue">Deur is open gegaan terwijl bewegingssensor uit stond, er is nu iemand thuis</font>')
	end

	if (otherdevices[isdark_switch] == 'On' and otherdevices['Licht gang'] == 'Off') and (minutes > (timeofday['SunsetInMinutes']) and minutes < (timeofday['SunriseInMinutes'])) then
		commandArray['Licht gang'] = 'On'
	end

end
return commandArray