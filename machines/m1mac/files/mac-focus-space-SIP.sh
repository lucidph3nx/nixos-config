#!/usr/bin/env bash

# so the shell can find jq etc
export PATH="/opt/homebrew/bin:$PATH"

# Switch to the workspace by passing in the space id (with SIP enabled)

tgt_space=$1

cur_display=$(yabai -m query --displays --display | jq '.index')
tgt_display=$(yabai -m query --displays --space ${tgt_space} | jq '.index')

# AppleScript key codes for the number keys
#           1  2  3  4  5  6  7  8  9  0
keycode=(0 18 19 20 21 23 22 26 28 25 29)

if [[ ${cur_display} == ${tgt_display} ]]; then
  osascript -e "tell application \"System Events\" to key code ${keycode[${tgt_space}]} using {option down}"
else
  yabai -m display --focus ${tgt_display} && \
  osascript -e "tell application \"System Events\" to key code ${keycode[${tgt_space}]} using {option down}"
fi

# if no window is focused, focus first window
echo $(yabai -m query --windows --window | jq '.title')
if [[ $(yabai -m query --windows --window | jq '.space') != ${tgt_space} ]]; then
  yabai -m window --focus first
fi
