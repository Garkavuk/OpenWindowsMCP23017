mcp23017 = require("mcp23017")

PinStatusA = {}
PinStatusB = {}

--[[
function serialize(t)
  local serializedValues = {}
  local value, serializedValue
  for i=1,#t do
    value = t[i]
    if value == nil then
        table.insert(serializedValues, 'n')
    else
        serializedValue = type(value)=='table' and serialize(value) or value
        table.insert(serializedValues, serializedValue)
    end
  end
  return string.format("{ %s }", table.concat(serializedValues, ', ') )
end
]]

for i = 1, config.io.pins_amountA do PinStatusA[i] = 0 end
for i = 1, config.io.pins_amountB do PinStatusB[i] = 0 end

mcp23017.begin(0x0, config.i2c.pin_sda, config.i2c.pin_scl, i2c.SLOW)

--Регистр IODIR определяет направление данных каждого разряда порта ввода\вывода.
--Когда любой разряд IO7 – IO0 этого регистра установлен в единичное состояние,
--соответствующий вывод порта становится входом;
--когда данный разряд сброшен, соответствующий вывод становится выходом.
mcp23017.writeIODIRA(0xFF) -- make all GPIO pins as inputs
mcp23017.writeIODIRB(0xFF) -- make all GPIO pins as inputs

--Регистр GPPU служит для подключения к входам портов подтягивающих к источнику питания резисторов 100 кОм.
--Когда любой разряд из PU7 – PU0 этого регистра установлен в единичное состояние, 
--         соответствующий вывод порта подключается к подтягивающему резистору;
--когда данный разряд сброшен, соответствующий вывод порта отключается от резистора
mcp23017.writeGPPUA(0xFF)  -- pull up resistor
mcp23017.writeGPPUB(0xFF)  -- pull up resistor

--Регистр GPINTEN управляет формированием прерывания для каждого вывода порта. 
--Если любой из его разрядов GPINT7 – GPINT0 установлен, 
--соответствующий вывод сформирует прерывание при изменении своего состояния. 
--Сброс этих разрядов регистра запрещает формирование прерывания при изменении состояния входов портов.
mcp23017.writeGPINTENA(0xFF) 
mcp23017.writeGPINTENB(0xFF) 

--Регистр DEFVAL представляет собой регистр сравнения с разрядами
--портов и позволяет формировать прерывания для каждого вывода порта
--при несовпадении соответствующего разряда порта и разряда DEF7 – DEF0 данного регистра
mcp23017.writeDEFVALA(0x00)
mcp23017.writeDEFVALB(0x00)

--Регистр INTCON управляет реакцией входов порта на регистр сравнения для формирования прерывания.
--Если разряд IOC7 – IOC0 установлен, соответствующий вход порта сравнивается с соответствующим разрядом в регистре DEFVAL.
--Если разряд IOC7 – IOC0 сброшен, соответствующий вход порта сравнивается с его предшествующей величиной
mcp23017.writeINTCONA(0x00)
mcp23017.writeINTCONB(0x00)

--Регистр IPOL отвечает за инверсию полярности входов портов.
--Когда любой разряд IP7 – IP0 этого регистра установлен в единичное состояние, соответствующий вход порта инвертируется;
--когда данный разряд сброшен, соответствующий вход порта не инвертируется
mcp23017.writeIPOLA(0xFF)
mcp23017.writeIPOLB(0xFF)

mcp23017.readGPIOA()
mcp23017.readGPIOB()

function ioButtonsInterruptA()
--[[    print("Interrupt A")]]
    ioButtonsInterrupt()
end

function ioButtonsInterruptB()
--[[    print("Interrupt B")]]
    ioButtonsInterrupt()
end

function ioButtonsInterrupt()
--[[    print("Interrupt")]]
    tmr.delay(config.io.button_delay_short_click_us)
    ioSendState(false)
    ioButtonUp()
end

function ioSendState(forceSend)
    local needResendA = false
    local needResendB = false

    needResendA, pinStatusA = readPinStates("A", mcp23017.readGPIOA(), config.io.pins_amountA)
    needResendB, pinStatusB = readPinStates("B", mcp23017.readGPIOB(), config.io.pins_amountB)

    if needResendA == true or needResendB == true or forceSend == true  then
        sendPinStateMQTT("A", config.io.pins_amountA)
        sendPinStateMQTT("B", config.io.pins_amountB)
    end
end

function sendPinStateMQTT(pinType, pins_amount)
    local pinStatus
    local indexAdd
    if pinType == "A" then
        pinStatus = PinStatusA
        indexAdd = 0
    elseif pinType == "B" then
        pinStatus = PinStatusB
        indexAdd = 8
    end

    local i = 1
    for i = 1, pins_amount do
        mqttMessage(config.mqtt.topic_pin .. "/" .. i + indexAdd, pinStatus[i] == 1 and 'ON' or 'OFF')
    end
end

function readPinStates(pinType, gpioStatus, pins_amount)
    local needResend = false
    local pinBit = 0
    local pinStatus = {}
    
    local pinStatus
    if pinType == "A" then
        pinStatus = PinStatusA
    elseif pinType == "B" then
        pinStatus = PinStatusB
    end
    
    for pinBit = 0, pins_amount - 1 do
        
        local pinIndex = pinBit + 1;
        local currentPinValue
        
        if bit.isset(gpioStatus, pinBit) then
            currentPinValue = 1
        else
            currentPinValue = 0
        end

        if currentPinValue ~= pinStatus[pinIndex] then
            needResend = true
        end
        
        pinStatus[pinIndex] = currentPinValue
    end

    return needResend, pinStatus
end


function ioButtonUp(doContinue)
    if doContinue == nil then
        tmr.alarm(config.io.button_up_tmr_alarmd_id, config.io.button_up_check_ms, tmr.ALARM_AUTO, function()
            ioButtonUp(true)
        end)
    end
    if mcp23017.readGPIOB() == 0 then
        tmr.unregister(config.io.button_up_tmr_alarmd_id)
    end
end

gpio.mode(config.io.pin_interruptA, gpio.INT, gpio.PULLUP)
gpio.trig(config.io.pin_interruptA, "both", ioButtonsInterruptA)

gpio.mode(config.io.pin_interruptB, gpio.INT, gpio.PULLUP)
gpio.trig(config.io.pin_interruptB, "both", ioButtonsInterruptB)

