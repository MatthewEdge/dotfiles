#!/bin/sh

MONITOR=$(pactl list short sinks | grep "hdmi-stereo" | cut -f1)
YETI_MIC=$(pactl list short sources | grep "input.usb-Blue_Mic" | cut -f1)

pactl set-default-sink ${MONITOR}
pactl set-default-source ${YETI_MIC}
