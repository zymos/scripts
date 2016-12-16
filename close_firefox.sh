#!/bin/bash

if [[ -n `pidof firefox` ]];then
	WID=`xdotool search "Mozilla Firefox" | head -1`
	xdotool windowactivate --sync $WID
	xdotool key --clearmodifiers ctrl+q
fi

