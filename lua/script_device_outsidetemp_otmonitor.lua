--script_device_outsidetemp_otmonitor.lua
--This script grabs the outside temperature of a Weather Underground sensor in Domoticz and sends it to the 'otmonitor' application
--The otmonitor application will send it to your room thermostat over OpenTherm (OpenTherm gateway needed)
--This script assumes the output is like this 19.5;79;3;1019;3 (temp;humidity;null;pressure;null)
--more details at this wiki http://www.domoticz.com/wiki/Virtual_weather_devices

--otmonitor outside temperature information:
--Call the command like this: 'OT=temperature'
--Allowed values are between -40.0 and +64.0, although thermostats may not display the full range. 
--Specify a value above 64 (suggestion: 99) to clear a previously configured value.
--Examples: OT=-3.5, OT=99

local sensorwu = 'Buitentemperatuur' --name of the sensor that gets created when you add the WU device (and that contains multiple values like temperature, humidity, barometer etc)
local otmonitor_url = '192.168.4.31:8080' --ip and port of the otmonitor webinterface
local tendens_url = '192.168.4.72:8080' --ip and port of the tendens logging API

commandArray = {}
if devicechanged[sensorwu] then

        sWeatherTemp, sWeatherHumidity, sHumFeelsLike, sWeatherPressure = otherdevices_svalues[sensorwu]:match("([^;]+);([^;]+);([^;]+);([^;]+);([^;]+)")
        sWeatherTemp = tonumber(sWeatherTemp)
 
 		--os.execute('curl http://'.. otmonitor_url ..'command?OT=' .. sWeatherTemp)
        commandArray[1]={['OpenURL']='http://'.. otmonitor_url ..'/command?OT=' .. sWeatherTemp }
        commandArray[2]={['OpenURL']='http://'.. tendens_url ..'/api/metric?id=4&v=' .. sWeatherTemp }  
end
 
return commandArray
