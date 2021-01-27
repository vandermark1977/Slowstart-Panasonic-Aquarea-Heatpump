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
        local heatshift = domoticz.devices(82)  --Fill in IDX of the Z1_Heat_Request_Temp
        local target_temp = domoticz.devices(66) --Fill in IDX of Main_Target_Temp
        local outlet_temp = domoticz.devices(65) -- Fill in IDX of Main_Outlet_Temp
        local CompressorFreq = domoticz.devices(49) -- Fill in IDX of Compressor_Freq
        local Toggle = domoticz.devices(148) -- Fill in IDX of virtual On/Off switch you created from dummy sensor
        local Ta_target = domoticz.devices(66).temperature
        local Taanvoer = domoticz.devices(65).temperature

        if(CompressorFreq.sValue == "0") then
            domoticz.log('State: compressor off', domoticz.LOG_INFO)
            domoticz.data.state = 1
            correction = 0
        elseif(domoticz.data.state == 1 or domoticz.data.state == 2) then
            domoticz.log('State: compressor startup', domoticz.LOG_INFO)
            domoticz.data.state = 2
            correction = outlet_temp.temperature - target_temp.temperature + heatshift.setPoint -1
            if(tonumber(CompressorFreq.sValue) >24) then
                domoticz.data.state = 3
            end
        elseif(domoticz.data.state == 3) then
            domoticz.log('State: compressor relaxing', domoticz.LOG_INFO)
            correction = outlet_temp.temperature - target_temp.temperature + heatshift.setPoint -1
            if((outlet_temp.temperature - target_temp.temperature) >= 1) and (tonumber(CompressorFreq.sValue) < 25) then
                domoticz.data.state = 4
            end
        elseif(domoticz.data.state == 4) then
            domoticz.log('State: continu status', domoticz.LOG_INFO)
            if((outlet_temp.temperature - target_temp.temperature) >= 0) and (Toggle.lastUpdate.minutesAgo >= 1) then
                correction = heatshift.setPoint + 1
                domoticz.log('Continu met Correctie is Shift+1. TaDoel is: '.. Ta_target .. ' & Ta is: '.. Taanvoer.. '. Correctie is ' .. tostring(correction), domoticz.LOG_INFO)
            else
                correction = heatshift.setPoint
                domoticz.log('Continu zonder aanpassing: TaDoel is: '.. Ta_target .. ' & Ta is: '.. Taanvoer, domoticz.LOG_INFO)
            end
        else
            domoticz.log('State: undefined', domoticz.LOG_INFO)
            domoticz.data.state = 1
            correction = 0
        end
        
        if correction < -5 then correction = -5 end
        if correction > 0 then correction = 0 end
        
        if heatshift.setPoint == correction then
            domoticz.log('Geen correctie: Shift is al gelijk aan correctie ('.. tostring(correction).. ')', domoticz.LOG_INFO) end
        
        if (heatshift.setPoint ~= correction) and (Toggle.lastUpdate.minutesAgo >= 1) then
            domoticz.log('Correctie nodig en is gezet op: ' .. tostring(correction), domoticz.LOG_INFO)
            heatshift.updateSetPoint(correction)
            Toggle.toggleSwitch() end
        
        if (heatshift.setPoint ~= correction) and (Toggle.lastUpdate.minutesAgo < 1) then
            domoticz.log('Correctie nodig maar niet uitgevoerd, laatste correctie korter dan minuut geleden ', domoticz.LOG_INFO)
        
        else
            domoticz.log('Einde script. Toggle laatst getriggerd: ' .. Toggle.lastUpdate.minutesAgo..' minuten geleden', domoticz.LOG_INFO)
        end
    end
}
