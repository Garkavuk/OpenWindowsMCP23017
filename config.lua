config = {
    network = {
        ssid         = "Keenetic-2G",
        password     = "1234567890",
        tmr_alarm_id = 0,
        tmr_retry_ms = 20000
    },
    collectgarbage = {
        ticks = 10,
    },
    i2c = {
        pin_sda = 3,
        pin_scl = 4
    },
    io = {
        buttons_amount   = 8, -- 1 to 8
        relays_amount    = 8, -- 1 to 8
        pin_interrupt    = 6,
        button_delay_short_click_us = 20000,
        button_delay_long_click_us  = 500000,
        button_up_tmr_alarmd_id     = 3,
        button_up_check_ms          = 500,
        buttons_actions = { -- linked relays on short click and on long click
            {{1}, {0}},
            {{2}, {0}},
            {{3}, {0}},
            {{4}, {0}},
            {{5}, {0}},
            {{6}, {0}},
            {{7}, {0}},
            {{8}, {0}},
        }
    },
    dht = {
        pin = nil, -- GPIO pin index or nil if disabled
    },
    mqtt = {
        broker_ip      = "192.168.88.100",
        port           = 1883,
        user           = "",
        password       = ""
        keep_alive_sec = 60,
        tmr_alarm_id   = 2,
        tmr_retry_ms   = 3000,
        queue_ttl_sec  = 3600,
        queue_max_size = 50,
        topic          = "/home/iot",
        topic_online   = "online",
        topic_button   = "button",
        topic_relay    = "relay",
        topic_climate_temp     = "climate/temp",
        topic_climate_humidity = "climate/humidity",
        topic_state_uptime     = "state/uptime",
        topic_state_memory     = "state/memory",
        topic_state_relay      = "state/relay",
        dir_in         = "in",
        dir_out        = "out",
        msg_on         = "ON",
        msg_off        = "OFF",
        msg_invert     = "INVERT",
        climate_cache_sec = 15
    }
}