-- script_device_standbykiller.lua
--This script will turn on the power to a group of devices when there is someone home and we are not sleeping
--It will turn the group of devices off, when there is no one home, or when we go to bed
--The script needs a group called 'Standby-killer' (or change to own name below) and a virtual switch 'Groep - Standby-killer' (change below if needed). 
--IMPORTANT: The virtual switch needs to be placed INSIDE the Domoticz group, otherwise the script will not function 
--Reason for this: Lua cannot retrieve the status of a group, so that's why this virtual switch workaround is needed.

local presence_switch = 'IemandThuis'
local sleep_switch = 'Slapen'
local group_switch = 'Groep - Standby-killer'

commandArray = {}
if devicechanged[presence_switch] or devicechanged[sleep_switch] then

    if ((otherdevices[presence_switch] == 'On') and (otherdevices[group_switch] == 'Off')) then --someone home, not sleeping
        commandArray['Group:Standby-killer']='On'

        elseif ((otherdevices[presence_switch] == 'Off') and (otherdevices[group_switch] == 'On')) then --nobody home, or we are sleeping
        commandArray['Group:Standby-killer']='Off'
        end
end
return commandArray


