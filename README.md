# Home IoT Open windows sensor on NodeMCU (ESP8266)
Устройство предназначено для получения состояния GPIO.

Управлять можно например через Openhab:
https://github.com/ssk181/home-switch-openhab

## Hardware
- NodeMCU
- MCP23017
- Pin's (A0-A7, B0-B7)

## MQTT-сообщения
Устройство шлет сообщения о каждом действии в MQTT очередь:

- /home/iot/{Device-IP}/out/online               *- ON - соединился с очередью MQTT, OFF - разъединился (LWT)*
- /home/iot/{Device-IP}/out/pin/{RelayIndex}     *- ON или OFF*
- /home/iot/{Device-IP}/out/state/uptime         *- Время работы устройства с момента последней загрузки в секундах*
- /home/iot/{Device-IP}/out/state/memory         *- Свободная память в байтах*
- /home/iot/{Device-IP}/out/state/pin/{RelayIndex} *- Статус реле ON или OFF*

И принимает сообщения:
- /home/iot/{Device-IP}/in/relay/{ButtonIndex}  *- ON | OFF | INVERT*
- /home/iot/{Device-IP}/in/state/uptime         *Без сообщения*
- /home/iot/{Device-IP}/in/state/memory         *Без сообщения*
- /home/iot/{Device-IP}/in/state/pin            *Без сообщения*

## Installation
1. Установить прошивку integer с модулями: *bit, dht, file, gpio, i2c, mqtt, net, node, tmr, uart, wifi* 
(собрать можно самому либо тут: http://nodemcu-build.com/)

1.a) Установить прошивку integer с модулями: *bit, file, gpio, i2c, mqtt, net, node, tmr, uart, wifi* 
