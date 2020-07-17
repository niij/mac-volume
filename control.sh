#!/bin/sh

# Written by Brandon Annin github.com/niij
# MIT License

# This is a script to fix Apple's broken audio system when using external audio devices
#  that supposedly don't support controlling the volume, but in practice are able to.
# If you are able to control the volume of a device through System Preferences --> Sound,
#  but the volume keys don't work, then this is the fix.

# How to use:
#  call this script with one of these arguments: [up, down, toggle_mute]. You can override
#  your media keys to call the script with the appropriate argument using tools like Hammerspoon
#  or Karabiner Elements.

state_file_path=$(cd `dirname $0` && pwd)/mute_state.txt
error_message="error running script: pass a single argument from this list: [up, down, toggle_mute]"
current_volume=`osascript -e 'output volume of (get volume settings)'`
command=$1

if [ -z $command ]
then
  echo $error_message
  exit 1
fi

get_mute_state() {
  if mute_state=$(head -n 1 $state_file_path 2> /dev/null);
    then
      echo "mute state: ${mute_state}"
  else
      echo "-1" > $state_file_path
      mute_state=-1
  fi
}
get_mute_state

set_volume() {
  osascript -e "set volume output volume $1"
}

toggle_mute() {
  if [ $current_volume == "0" ]
    then
      set_volume $mute_state
      echo "-1" > $state_file_path
  else
      set_volume 0
      echo $current_volume > $state_file_path
  fi
}

if [ $command == 'up' ]
  then
    set_volume `expr $current_volume + 10`
elif [ $command = 'down' ]
  then
    set_volume `expr $current_volume - 10`
elif [ $command = 'toggle_mute' ]
  then
    toggle_mute
else
    echo $error_message
fi
