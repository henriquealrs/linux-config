#!/bin/bash

if pgrep -x "wlsunset" > /dev/null
then
    killall wlsunset
else
    wlsunset -T 4500 2>&1 > /dev/null &
fi
