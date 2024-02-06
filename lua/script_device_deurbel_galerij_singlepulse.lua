-- script_device_deurbel_singlepuls.lua
-- This script acts as a buffer for a switch, it only responds when there is atleast 'TimeBetweenPresses' (value that can be configured) seconds between the press of the buttonn
-- Script needs a Domoticz uservariable called 'DeurbelGalerijPreviousPress' of type 'String'
-- See http://domoticz.com/forum/viewtopic.php?f=23&t=7512 for more information

commandArray = {}

TimeBetweenPresses = 30 --time that needs to be between presses (in seconds), before os.execute line is ran again

function datetimedifferencenow(s)
   year = string.sub(s, 1, 4)
   month = string.sub(s, 6, 7)
   day = string.sub(s, 9, 10)
   hour = string.sub(s, 12, 13)
   minutes = string.sub(s, 15, 16)
   seconds = string.sub(s, 18, 19)
   t1 = os.time()
   t2 = os.time{year=year, month=month, day=day, hour=hour, min=minutes, sec=seconds}
   difference = os.difftime (t1, t2)
   return difference
end

if (devicechanged['Deurbel galerij'] == 'On') then
   if (datetimedifferencenow(uservariables_lastupdate['DeurbelGalerijPreviousPress']) > TimeBetweenPresses ) then
      print('<b style="color:Blue">Deurbel galerij: vorige keer was <b style="color:Green">MEER</b> dan '..TimeBetweenPresses..' sec geleden, pushbericht sturen</b>')
      os.execute('/home/domoticz/domoticz/scripts/bash/deurbel/snapshot.sh')
      commandArray['Variable:DeurbelGalerijPreviousPress']=tostring(os.time())
   else
      print('<b style="color:Blue">Deurbel galerij: vorige keer was <b style="color:Red">MINDER</b> dan '..TimeBetweenPresses..' sec geleden, negeer signaal</b>')
   end
end
return commandArray