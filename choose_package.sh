#!/bin/bash

#* This script allow to run other script and select the package in installed applications on device.
#* Note: Works only if one device is connected. Use choose_device_and_package.sh script if more than one device is connected.
#*
#*
#* Example : 
#* ```sh
#* ./choose_package.sh
#* ```

source _generic_methods.sh

#* This script clear the application data.

source _generic_methods.sh


PS3='Choose the package application to launch the script: '
# 
# List all the 3 rd party applications, and remove the "package:" prefix
INSTALLED_APPS_LIST=( $(adb shell "pm list packages -3" | sed -n 's/package:\(.*\)/\1/p') )

IFS=$'\n' INSTALLED_APPS_LIST_SORTED=($(sort <<<"${INSTALLED_APPS_LIST[*]}")); unset IFS

select application in "${INSTALLED_APPS_LIST_SORTED[@]}"; do
  TARGET_APPLICATION=$application
  break
done

COMMAND_TO_LAUNCH="$1 $2 $3 $4 $5 $6 $7 $8 $9"

./$COMMAND_TO_LAUNCH -p $TARGET_APPLICATION