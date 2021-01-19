-- Script to manage slow an efficient startup after (for example) defrost.
-- Script is based on Domoticz in combination with the Domoticz plugin (https://github.com/MarFanNL/HeishamonMQTT/tree/main)
-- Go to: <Settings> <More Options> <Events>
-- Click <+> and add new script >> DZVents >> All
-- "Select all / CTRL+A" and copy this script over the standard script
-- Give the script a clear name (next to ON/OFF toggle)
-- Hit "OFF" on the top left corner and "SAVE" top right corner
-- Line 18: CompressorFreq sensor IDX number to be filled in. (Standard: Compressor_Freq)
-- Line 32: heatshift sensor IDX number to be filled in. (standard: Z1_Heat_Request_Temp)
-- Line 33: target_temp sensor IDX number to be filled in. (Standard: Main_Target_Temp)
-- Line 34: outlet_temp sensor IDX number to be filled in.  (Standard: Main_Outlet_Temp)
-- Line 35: CompressorFreq sensor IDX number to be filled in. (Standard: Compressor_Freq)
-- IDX numbers can easilly be found by tapping the "hamburger menu button" next to the "tabs" of the scripts (top left corner) and searching (Ctrl + F) for the text behind "standard:" between the brackets.
-- HIT "ON" on the top left corner and hit "SAVE" on the top right corner and wait for a restart/defrost
return {
    on = {
        devices = { 
            49, --Pana Compressor_Freq
        }
    },
    data = {
        ---------------------------------------
        -- compressor state
        -- 1: compressor off
        -- 2: compressor startup
        -- 3: compressor relaxing
        -- 4: compressor continuous operation
        state = { initial = 1 }
    },
    logging = {
        level = domoticz.LOG_DEBUG, -- change to LOG_ERROR when OK - was LOG_DEBUG
        marker = scriptVar,
        },
    execute = function(domoticz, triggeredItem)
        local heatshift = domoticz.devices(82)
        local target_temp = domoticz.devices(66)
        local outlet_temp = domoticz.devices(65)
        local CompressorFreq = domoticz.devices(49)

        if(CompressorFreq.sValue == "0") then
            domoticz.log('State: compressor off', domoticz.LOG_INFO)
            domoticz.data.state = 1
            correction = 0
        elseif(domoticz.data.state == 1 or domoticz.data.state == 2) then
            domoticz.log('State: compressor startup', domoticz.LOG_INFO)
            domoticz.data.state = 2
            correction = outlet_temp.temperature - target_temp.temperature + heatshift.setPoint -1
            if(tonumber(CompressorFreq.sValue) > 20) then
                domoticz.data.state = 3
            end
        elseif(domoticz.data.state == 3) then
            domoticz.log('State: compressor relaxing', domoticz.LOG_INFO)
            correction = outlet_temp.temperature - target_temp.temperature + heatshift.setPoint -1
            if((outlet_temp.temperature - target_temp.temperature) >= 1) and (tonumber(CompressorFreq.sValue) < 21) then
                domoticz.data.state = 4
            end
        elseif(domoticz.data.state == 4) then
            domoticz.log('State: continuous operation', domoticz.LOG_INFO)
            if((outlet_temp.temperature - target_temp.temperature) >= 0) then
                correction = heatshift.setPoint + 1
            else
                correction = heatshift.setPoint
            end
        else
            domoticz.log('State: undefined', domoticz.LOG_INFO)
            domoticz.data.state = 1
            correction = 0
        end
        
        if correction < -5 then correction = -4 end
        if correction > 0 then correction = 0 end
        
        if heatshift.setPoint == correction then
            domoticz.log('No correction', domoticz.LOG_INFO)
        else
            domoticz.log('Correction set to ' .. tostring(correction), domoticz.LOG_INFO)
            heatshift.updateSetPoint(correction)
        end
    end
}
