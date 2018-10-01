mcp23017 = require("mcp23017")

buttonStateDown = 0

aRelayStatus = {}
for i = 1, config.io.relays_amount do aRelayStatus[i] = 0 end

aButtonStatus = {}
for i = 1, config.io.buttons_amount do aButtonStatus[i] = 0 end

mcp23017.begin(0x0, config.i2c.pin_sda, config.i2c.pin_scl, i2c.SLOW)

-- relays

--Регистр IODIR определяет направление данных каждого разряда порта ввода\вывода.
--Когда любой разряд IO7 – IO0 этого регистра установлен в единичное состояние,
--соответствующий вывод порта становится входом;
--когда данный разряд сброшен, соответствующий вывод становится выходом.
mcp23017.writeIODIRA(0x00) -- make all GPIO pins as outputs

mcp23017.writeGPIOA(0x00)  -- make all GIPO pins off/low

--Регистр IPOL отвечает за инверсию полярности входов портов.
--Когда любой разряд IP7 – IP0 этого регистра установлен в единичное состояние, соответствующий вход порта инвертируется;
--когда данный разряд сброшен, соответствующий вход порта не инвертируется
mcp23017.writeIPOLA(0xFF)

-- buttons

--Регистр IODIR определяет направление данных каждого разряда порта ввода\вывода.
--Когда любой разряд IO7 – IO0 этого регистра установлен в единичное состояние,
--соответствующий вывод порта становится входом;
--когда данный разряд сброшен, соответствующий вывод становится выходом.
mcp23017.writeIODIRB(0xFF) -- make all GPIO pins as inputs

--Регистр GPPU служит для подключения к входам портов подтягивающих к источнику питания резисторов 100 кОм.
--Когда любой разряд из PU7 – PU0 этого регистра установлен в единичное состояние, 
--         соответствующий вывод порта подключается к подтягивающему резистору;
--когда данный разряд сброшен, соответствующий вывод порта отключается от резистора
mcp23017.writeGPPUB(0xFF)  -- pull up resistor

--Регистр GPINTEN управляет формированием прерывания для каждого вывода порта. 
--Если любой из его разрядов GPINT7 – GPINT0 установлен, 
--соответствующий вывод сформирует прерывание при изменении своего состояния. 
--Сброс этих разрядов регистра запрещает формирование прерывания при изменении состояния входов портов.
mcp23017.writeGPINTENB(0xFF) 

--Регистр DEFVAL представляет собой регистр сравнения с разрядами
--портов и позволяет формировать прерывания для каждого вывода порта
--при несовпадении соответствующего разряда порта и разряда DEF7 – DEF0 данного регистра
mcp23017.writeDEFVALB(0x00)

--Регистр INTCON управляет реакцией входов порта на регистр сравнения для формирования прерывания.
--Если разряд IOC7 – IOC0 установлен, соответствующий вход порта сравнивается с соответствующим разрядом в регистре DEFVAL.
--Если разряд IOC7 – IOC0 сброшен, соответствующий вход порта сравнивается с его предшествующей величиной
mcp23017.writeINTCONB(0x00)

--Регистр IPOL отвечает за инверсию полярности входов портов.
--Когда любой разряд IP7 – IP0 этого регистра установлен в единичное состояние, соответствующий вход порта инвертируется;
--когда данный разряд сброшен, соответствующий вход порта не инвертируется
mcp23017.writeIPOLB(0xFF)

mcp23017.readGPIOB()

function ioButtonsInterrupt()
    print("Interrupt")
--[[    local gpiobStatusInterrupt = mcp23017.readINTCAPB()
    print("gpiobStatusInterrupt:" .. gpiobStatusInterrupt)

    local gpiobStatusFirstRead = mcp23017.readGPIOB()
    print("gpiobStatusFirstRead:" .. gpiobStatusFirstRead)
]]    
--[[    if buttonStateDown == 0 and]] --[[gpiobStatusInterrupt > 0 1 == 1 then]]
        --[[buttonStateDown = 1]]
        tmr.delay(config.io.button_delay_short_click_us)
        readAndSend()
--[[
        print("Short delay complete")
]]
        
--[[
        print("gpiobStatusShort:" .. gpiobStatusShort)
]]
--[[        if gpiobStatusShort > 0 1==1 then]]
--[[
            local clickType = 1
]]
            --local gpioStatusFinish = gpiobStatusShort
            --print("gpioStatusFinish:" .. gpioStatusFinish)
--[[
            tmr.delay(config.io.button_delay_long_click_us)
            print("Long delay complete")
            local gpiobStatusLong = mcp23017.readGPIOB()
]]
            
--[[
            if gpiobStatusLong > 0 then
                gpioStatusFinish = gpiobStatusLong
                clickType = 2
            end
]]

--[[
            local aRelayIndexSet = {}
            for buttonBit = 0, config.io.buttons_amount - 1 do
                if bit.isset(gpioStatusFinish, buttonBit) then
                    --print("buttonBit: " .. buttonBit)
                    local buttonIndex = buttonBit + 1;
                    --print("Button index: " .. buttonIndex .. " type: " .. "clickType")
                    --mqttMessage(config.mqtt.topic_button .. "/" .. buttonIndex, "0")

                    --print("aButtonStatus buttonIndex:" .. buttonIndex .. " value:" .. "1")
                    aButtonStatus[buttonIndex] = 1

        local i = 1
        for i = 1, config.io.buttons_amount do
            mqttMessage(config.mqtt.topic_button .. "/" .. i, aButtonStatus[i] == 1 and 'ON' or 'OFF')
        end
]]         
--[[
                    for key, relayIndex in pairs(config.io.buttons_actions[buttonIndex][clickType]) do
                        if not inTable(aRelayIndexSet, relayIndex) then
                            table.insert(aRelayIndexSet, relayIndex)
                        end
                    end
]]
--[[
                end
            end
]]
--[[
            for key, relayIndex in pairs(aRelayIndexSet) do
                ioRelaySet(relayIndex)
            end
]]
--[[
        end
    end
]]    
    ioButtonUp()
end

function readAndSend()
    local gpiobStatusShort = mcp23017.readGPIOB()
    local needResend = false
    local buttonBit = 0
    for buttonBit = 0, config.io.buttons_amount - 1 do
    
     local buttonIndex = buttonBit + 1;
     local currentButtonIndexValue
     if bit.isset(gpiobStatusShort, buttonBit) then
        currentButtonIndexValue = 1
     else
        currentButtonIndexValue = 0
     end
    
    
     if currentButtonIndexValue ~= aButtonStatus[buttonIndex] then
      needResend = true
     end
     
     aButtonStatus[buttonIndex] = currentButtonIndexValue
    end
    
    if needResend == true then
     local i = 1
     for i = 1, config.io.buttons_amount do
        mqttMessage(config.mqtt.topic_button .. "/" .. i, aButtonStatus[i] == 1 and 'ON' or 'OFF')
     end
    end
end


function ioButtonUp(doContinue)
--print("ioButtonUp:")

    if doContinue == nil then
        --print("ioButtonUp doContinue")
        tmr.alarm(config.io.button_up_tmr_alarmd_id, config.io.button_up_check_ms, tmr.ALARM_AUTO, function()
            ioButtonUp(true)
        end)
    end
    if mcp23017.readGPIOB() == 0 then
        --print("ioButtonUp mcp23017.readGPIOB() == 0")
        --[[buttonStateDown = 0]]
        tmr.unregister(config.io.button_up_tmr_alarmd_id)
    end
end

function ioRelaySet(relayIndex, state)
    local state = state or 2;
    assert(relayIndex >= 0 and relayIndex <= config.io.relays_amount, "relayIndex := 0.." .. config.io.relays_amount)
    assert(state >= 0 and state <= 2, "state := 0..2")

    local newState = 0
    if relayIndex == 0 then
        newState = state
        local i = 1
        for i = 1, config.io.relays_amount do
            if newState == 2 then
                aRelayStatus[i] = aRelayStatus[i] == 1 and 0 or 1
            else
                aRelayStatus[i] = newState
            end
            mqttMessage(config.mqtt.topic_relay .. "/" .. i, aRelayStatus[i] == 1 and 'ON' or 'OFF')
        end
    else
        if state == 2 then
            newState = aRelayStatus[relayIndex] == 1 and 0 or 1
        else
            newState = state
        end
        aRelayStatus[relayIndex] = newState
        mqttMessage(config.mqtt.topic_relay .. "/" .. relayIndex, newState == 1 and 'ON' or 'OFF')
    end

    local gpioaStatus = 0
    local i = 1
    for i = 1, config.io.relays_amount do
        if aRelayStatus[i] > 0 then
            gpioaStatus = bit.set(gpioaStatus, i - 1)
        else
            gpioaStatus = bit.clear(gpioaStatus, i - 1)
        end
    end
    mcp23017.writeGPIOA(gpioaStatus)
end

function ioSendState()
    local i = 1
    for i = 1, config.io.relays_amount do
        mqttMessage(config.mqtt.topic_state_relay .. "/" .. i, aRelayStatus[i] == 1 and 'ON' or 'OFF')
    end
end

function inTable(tbl, item)
    for key, value in pairs(tbl) do
        if value == item then return true end
    end
    return false
end

gpio.mode(config.io.pin_interrupt, gpio.INT, gpio.PULLUP)
gpio.trig(config.io.pin_interrupt, "both", ioButtonsInterrupt)