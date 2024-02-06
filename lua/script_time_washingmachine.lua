--script_time_washingmachine.lua
--This script monitors the current consumption indicated by a Z-Wave plug, placed between the washingmachine and the mains outlet
--It will count the amount of time that the power usage is below the triggervalue to be configured below. This indicates us that the washer has finished.
--When the script thinks the washingmachine is done, it will send you a pushnotification (line #38)

--Change the values below to reflect to your own setup
local switch_washingmachine   = 'virt_wasmachine'         --Name of virtual switch that will show the state of the washingmachine (on/off)
local washer_status_uservar   = 'washingmachine_status'
local energy_consumption      = 'Wasmachine'         --Name of Z-Wave plug that contains actual consumption of washingmachine (in Watts)
local washer_counter_uservar  = 'washingmachine_counter'   --Name of the uservariable that will contain the counter that is needed
local idle_minutes            = 5                      --The amount of minutes the consumption has to stay below the 'consumption_lower' value
local consumption_upper       = 20                       --If usage is higher than this value (Watts), the washingmachine has started
local consumption_lower       = 3                       --If usage is lower than this value (Watts), the washingmachine is idle for a moment/done washing
sWatt, sTotalkWh              = otherdevices_svalues[energy_consumption]:match("([^;]+);([^;]+)")
washer_usage                  = tonumber(sWatt)

commandArray = {}

--Virtual switch is off, but consumption is higher than configured level, so washing has started
if (washer_usage > consumption_upper) and uservariables[washer_status_uservar] == 0 then
  --commandArray[switch_washingmachine]='On'
  commandArray['Variable:' .. washer_status_uservar]='1'
  print('Current power usage (' ..washer_usage.. 'W) is above upper boundary (' ..consumption_upper.. 'W), so washing has started!')
  commandArray['Variable:' .. washer_counter_uservar]=tostring(idle_minutes)
end      

if (washer_usage < consumption_lower) and uservariables[washer_status_uservar] == 1 then --Washing machine is not using a lot of energy, subtract the counter
  commandArray['Variable:' .. washer_counter_uservar]=tostring(math.max(tonumber(uservariables[washer_counter_uservar]) - 1, 0))
  print('Current power usage (' ..washer_usage.. 'W) is below lower boundary (' ..consumption_lower.. 'W), washer is idle or almost ready')
  print('Subtracting counter with 1, new value: ' ..uservariables[washer_counter_uservar].. ' minutes') 
end

--Washingmachine is done
if ((uservariables[washer_status_uservar] == 1) and uservariables[washer_counter_uservar] == 0) then
  print('Washingmachine is DONE')
  print('Current power usage washingmachine ' ..washer_usage.. 'W')
  print('Washingmachine is done, please go empty it!')
  commandArray['SendNotification']='Washingmachine#Washingmachine is done, please go empty it!#0' --Use Domoticz to send a notification, replace line for your own command if needed.
  --commandArray[switch_washingmachine]='Off'
  commandArray['Variable:' .. washer_status_uservar]='0'
end   

return commandArray