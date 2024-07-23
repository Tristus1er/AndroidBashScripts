#!/bin/bash

#* This script reset the application turn off the Bluetooth and turn off the GPS.
#*
#*
#* Example : 
#* ```sh
#* ./reset_test.sh
#* ./reset_test.sh -s emulator-5556
#* ./reset_test.sh -s emulator-5556 -l 3
#* ```

source _generic_methods.sh

# -------------------------------------------------------------------------------------------------
# Functions
# -------------------------------------------------------------------------------------------------
function usage() {
  echo "$0 [-s <deviceSerialNumber>] [-p <applicationPackage>]"
  echo " -s deviceSerialNumber: The serial number of the device to use to run the command."
  echo " -p applicationPackage : The package name of the application to handle."
  echo ""
  echo "Example :"
  echo "$0"
  echo "$0 -p com.android.vending"
  echo "$0 -s emulator-5556 -p com.android.vending"
  echo
}

# -------------------------------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------------------------------
DEVICE_PARAMETER=
PACKAGE_NAME=

# -------------------------------------------------------------------------------------------------
# Main
# -------------------------------------------------------------------------------------------------

while getopts "vhs:p:" arg; do
    case $arg in
         s) DEVICE_PARAMETER="-s $OPTARG";;
         p) PACKAGE_NAME="$OPTARG";;
         h) usage; exit 1;;
         v) echo "version 1.0.0"; exit 1;;
		 *) usage; exit 1;;
    esac
done


echo -e "${PURPLE}************************************${NC}"
echo -e "${PURPLE}*     RESET DEVICE FOR TESTING     *${NC}"
echo -e "${PURPLE}************************************${NC}"

echo "DEVICE_PARAMETER = $DEVICE_PARAMETER"
echo "PACKAGE_NAME = $PACKAGE_NAME"


if [ -z "${DEVICE_PARAMETER}" ]; then
	wait_for_device
fi


echo "Go to home screen."
adb $DEVICE_PARAMETER shell input keyevent KEYCODE_HOME

# *************
# * Bluetooth *
# *************
echo "Disable Bluetooth."
# disable
adb $DEVICE_PARAMETER shell am start -a android.bluetooth.adapter.action.REQUEST_DISABLE
adb $DEVICE_PARAMETER shell input keyevent 22 # (right)
adb $DEVICE_PARAMETER shell input keyevent 22 # (right)
adb $DEVICE_PARAMETER shell input keyevent 66 # (enter)

# enable
#adb shell am start -a android.bluetooth.adapter.action.REQUEST_ENABLE
#adb shell input keyevent 22 (right)
#adb shell input keyevent 22 (right)
#adb shell input keyevent 66 (enter)

echo "Go to home screen."
adb $DEVICE_PARAMETER shell input keyevent KEYCODE_HOME

# *******
# * GPS *
# *******
echo "Disable Location."
# Source: https://android.stackexchange.com/questions/40147/enable-location-services-via-adb-or-shell
# disable
adb $DEVICE_PARAMETER shell settings put secure location_providers_allowed -gps
adb $DEVICE_PARAMETER shell settings put secure location_providers_allowed -network
adb $DEVICE_PARAMETER shell settings put secure location_mode 0

# enable
#adb $DEVICE_PARAMETER shell settings put secure location_providers_allowed +gps
#adb $DEVICE_PARAMETER shell settings put secure location_providers_allowed +network
#adb $DEVICE_PARAMETER shell settings put secure location_mode 3


# ***************
# * Flight mode *
# ***************
echo "Disable Fligh Mode."
# Source: https://stackoverflow.com/questions/10506591/turning-airplane-mode-on-via-adb
adb $DEVICE_PARAMETER shell settings put global airplane_mode_on 1
adb $DEVICE_PARAMETER shell am broadcast -a android.intent.action.AIRPLANE_MODE

# disable
#adb shell settings put global airplane_mode_on 0
#adb shell am broadcast -a android.intent.action.AIRPLANE_MODE

# TODO: check UPDATE October 2022 If you got error about security settings, best solution now is: For mobile data: adb shell svc data disable For wifi: adb shell svc wifi disable

# ******************
# * Clear app data *
# ******************
#echo -e "Clear ${CYAN}$PACKAGE_NAME${NC}."
#adb $DEVICE_PARAMETER shell pm clear $PACKAGE_NAME


# ********************************
# * Clear permissions of the app *
# ********************************
if [ -z "${PACKAGE_NAME}" ]; then
	echo "Do not handle permissions"
else
	echo -e "Clear permissions."
	./grant_all_permissions.sh -r $DEVICE_PARAMETER -p $PACKAGE_NAME
fi


# *******************
# * Delete app data *
# *******************
echo -e "delete ${CYAN}$PACKAGE_NAME${NC}."
adb $DEVICE_PARAMETER uninstall $PACKAGE_NAME

# ******************************
# * Clear battery optimisation *
# ******************************
if [ -z "${PACKAGE_NAME}" ]; then
	echo "Do not handle battery optimisation"
else
	echo -e "Clear battery optimization."
	./battery_optimization.sh -r $DEVICE_PARAMETER -p $PACKAGE_NAME
fi

# ***************
# * Disable NFC *
# ***************
echo -e "Disable NFC."
adb $DEVICE_PARAMETER shell svc nfc disable

# Enable
#adb $DEVICE_PARAMETER shell svc nfc enable

# ******************
# * Quicktail menu *
# ******************
#echo "Display the quicktail menu to check Bluetooth and location are well disabled."
# Expand status bar to check visually that Bluetooth AND location are disabled.
#adb $DEVICE_PARAMETER shell service call statusbar 1

# Collapse status bar
#adb shell service call statusbar 2

#sleep 10

# return home menu
#echo "Go to home screen."
#adb $DEVICE_PARAMETER shell input keyevent KEYCODE_HOME

# *******************
# * Turn screen off *
# *******************
# Press power button
#echo "Turn off screen."
#adb $DEVICE_PARAMETER shell input keyevent 26