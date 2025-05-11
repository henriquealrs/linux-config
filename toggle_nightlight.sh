#!/bin/bash

if pgrep -x "wlsunset" > /dev/null
then
    killall wlsunset
else
    wlsunset -T 4500 # >> $HOME/wlsunset-result &
fi

echo "Toggled\n" >> $HOME/night
