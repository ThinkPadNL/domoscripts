--script_device_deltaT.lua 
--This script subtracts two sensors (aanvoer_dv and retour_dv) from eachother and puts the calculated value in a new sensor (to be configured with 'deltat_idx')
local aanvoer_dv = 'OTGW_Aanvoer'
local retour_dv = 'OTGW_Retour'
local deltat_idx = 154

commandArray = {}

if devicechanged[aanvoer_dv] then

        aanvoer = otherdevices_svalues[aanvoer_dv]
        retour = otherdevices_svalues[retour_dv]
        aanvoer_temp = tonumber(aanvoer)
        retour_temp = tonumber(retour)
        commandArray['UpdateDevice'] = deltat_idx .. '|0|' .. string.format("%." .. 1 .. "f", aanvoer_temp - retour_temp)
end
return commandArray