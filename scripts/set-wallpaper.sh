#!/usr/bin/env bash
pkill swaybg
swaybg -m fill -i "$1" &
disown
