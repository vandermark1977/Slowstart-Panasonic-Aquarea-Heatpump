--  Slowstart script with adjustment to have Direct control of the target water outlet temperature. 
--  Make a Temperature device (thermostat with a setpoint) and fill the IDX in line 33.
--  Use this device to make adjustments to the Target Water Outlet temperature.

return {
    on = {
        devices = { 
            49, --Pana [Compressor_Freq]
        }
    },
    data = {
--------------------------------------
-- compressor state
-- 1: compressor off
-- 2: compressor startup
-- 3: compressor relaxing
-- 4: compressor continuous operation
---------------------------------------
        state = { initial = 0 },
        treshold = {initial = 20}
    },
    logging = {
        level = domoticz.LOG_DEBUG, -- change to LOG_ERROR when OK - was LOG_DEBUG
        marker = scriptVar,
        },
    execute = function(domoticz, triggeredItem)
        local TaDirect = domoticz.devices(82)       -- IDX of the Pana [Z1_Heat_Request_Temp]
        local target_temp = domoticz.devices(66)    -- IDX of the Pana [Main_Target_Temp]
        local outlet_temp = domoticz.devices(65)    -- IDX of the Pana [Main_Outlet_Temp]
        local TempOutside = 41                      -- IDX of outside temp sensor
        local CompressorFreq = domoticz.devices(49) -- IDX of the Pana [Compressor_Freq]
        local Toggle = domoticz.devices(148)        -- IDX of On/Off switch you need to create from a dummy device. This on/of switch is only used for this script
        local TaManual = domoticz.devices(150)      -- IDX with which you set the target water temperature
        local outdoorTemp = tonumber(domoticz.devices(TempOutside).rawData[1])
-------------------------------------------------
-- Determine treshold for compressor frequency --
-- To set change from state 3 --> 4            --
-- Adjust these to your own situation!!        --
-------------------------------------------------
        if (outdoorTemp >= 3) then
            domoticz.data.treshold = 25 end
        if (outdoorTemp < 3 and outdoorTemp >= 1) then
            domoticz.data.treshold = 27 end
        if (outdoorTemp < 1 and outdoorTemp > -2) then
            domoticz.data.treshold = 37 end
        if (outdoorTemp <= -2 and outdoorTemp > -5) then
            domoticz.data.treshold = 40 end
        if (outdoorTemp <= -5 and outdoorTemp >-7) then
            domoticz.data.treshold = 44 end
        if (outdoorTemp <= -7 and outdoorTemp >-9) then
            domoticz.data.treshold = 46 end
        if (outdoorTemp <= -9 and outdoorTemp >-11) then
            domoticz.data.treshold = 47 end
        if (outdoorTemp <= -11) then
            domoticz.data.treshold = 48 end
---------------------------
-- Slowstart starts here --
---------------------------
        if(CompressorFreq.sValue == "0") then
            domoticz.log('State: compressor off', domoticz.LOG_INFO)
            domoticz.data.state = 1
            correction = 0
        elseif(domoticz.data.state == 1 or domoticz.data.state == 2) then
            domoticz.log('State: compressor startup', domoticz.LOG_INFO)
            domoticz.data.state = 2
            correction = outlet_temp.temperature - target_temp.temperature + TaDirect.setPoint -1
            if(tonumber(CompressorFreq.sValue) >= domoticz.data.treshold) then
                domoticz.data.state = 3
            end
        elseif(domoticz.data.state == 3) then
            domoticz.log('State: compressor relaxing', domoticz.LOG_INFO)
            correction = outlet_temp.temperature - target_temp.temperature + TaDirect.setPoint -1
            if((outlet_temp.temperature - target_temp.temperature) >= 1) and (tonumber(CompressorFreq.sValue) < domoticz.data.treshold) then
                domoticz.data.state = 4
            end
        elseif(domoticz.data.state == 4) then
            domoticz.log('State: continuous status', domoticz.LOG_INFO)
            if((outlet_temp.temperature - target_temp.temperature) >= 0) then
                correction = TaDirect.setPoint + 1
                domoticz.log('Target-Temp is: '.. target_temp.temperature .. ' & Water-Temp is: '.. outlet_temp.temperature.. ': Continuous with correction is Ta+1: (' .. tostring(correction)..')', domoticz.LOG_INFO)
            else
                correction = TaDirect.setPoint
                domoticz.log('Continuos without adjustment: Target-Temp is: '.. target_temp.temperature .. ' & Water-Temp is: '.. outlet_temp.temperature, domoticz.LOG_INFO)
            end
        else
            domoticz.log('State: undefined', domoticz.LOG_INFO)
            domoticz.data.state = 1
            correction = 0
        end
-----------------------------------------------------------------------
-- Correction is translated to Shift Target temperature water outlet --
-----------------------------------------------------------------------
        if correction < (TaManual.setPoint - 4) then
            correction = (TaManual.setPoint -4) end
        if correction > TaManual.setPoint then 
            domoticz.log('Correction ('.. tostring(correction)..') above current Ta target (' .. TaManual.setPoint..'): Ta set to: ' .. TaManual.setPoint, domoticz.LOG_INFO)
            correction = TaManual.setPoint end
        
        if TaDirect.setPoint == correction then
            domoticz.log('No correction: Current Ta equals correction ('.. tostring(correction).. ')', domoticz.LOG_INFO) end

        if (TaDirect.setPoint ~= correction) and (Toggle.lastUpdate.minutesAgo >= 1) then
            domoticz.log('Correction needed and Ta set to: ' .. tostring(correction), domoticz.LOG_INFO)
            TaDirect.updateSetPoint(correction)
            Toggle.toggleSwitch() end
        
        if (TaDirect.setPoint ~= correction) and (Toggle.lastUpdate.minutesAgo < 1) then
            domoticz.log('Correction needed but not executed, last correction < 1 minute ago', domoticz.LOG_INFO)
---------------------------------------
-- Final Log                         --
---------------------------------------
        else
            domoticz.log('End script. Toggle last triggered: ' .. Toggle.lastUpdate.minutesAgo..' minutes ago. Treshold is: '
            ..domoticz.data.treshold..' Buiten is het '..outdoorTemp..' oC', domoticz.LOG_INFO)
        end
    end
}
