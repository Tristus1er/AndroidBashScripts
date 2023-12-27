#!/bin/bash

#* This script put the device is DOZE MODE.
#*
#*
#* Example : 
#* ```sh
#* ./enter_doze_mode.sh
#* ./enter_doze_mode.sh -p com.android.vending
#* ./enter_doze_mode.sh -s emulator-5556
#* ./enter_doze_mode.sh -s emulator-5556 -p com.android.vending
#* ```

source _generic_methods.sh

# -------------------------------------------------------------------------------------------------
# Functions
# -------------------------------------------------------------------------------------------------
function usage() {
  echo "$0 [-s <deviceSerialNumber>] -p <applicationPackage>"
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

echo -e "${PURPLE}***********************************************${NC}"
echo -e "${PURPLE}*     FORCE THE DEVICE TO ENTER DOZE MODE     *${NC}"
echo -e "${PURPLE}***********************************************${NC}"

if [ -z "${DEVICE_PARAMETER}" ]; then
	wait_for_device
fi

#Source:
# https://gist.github.com/y-polek/febff143df8dd92f4ed2ce4035c99248
# More info
# https://developer.android.com/training/monitoring-device-state/doze-standby

# Battery powered state
adb $DEVICE_PARAMETER shell dumpsys battery | grep powered

# Unplug battery
adb $DEVICE_PARAMETER shell dumpsys battery unplug

# Battery powered state after "unplug"
adb $DEVICE_PARAMETER shell dumpsys battery | grep powered

# Reset battery
adb $DEVICE_PARAMETER shell dumpsys battery reset

# Dump Doze mode info
adb $DEVICE_PARAMETER shell dumpsys deviceidle

# Force activate Doze mode
adb $DEVICE_PARAMETER shell dumpsys deviceidle force-idle

# Enable Doze mode (may be required on Android Emulator)
adb $DEVICE_PARAMETER shell dumpsys deviceidle enable

# Get status of Light Doze mode
adb $DEVICE_PARAMETER shell dumpsys deviceidle get light

# Get status of Deep Doze mode
adb $DEVICE_PARAMETER shell dumpsys deviceidle get deep

# Enter Light Doze mode (should be called several times to pass all phases)
adb $DEVICE_PARAMETER shell dumpsys deviceidle step light

# Enter Deep Doze mode (should be called several times to pass all phases)
adb shell dumpsys deviceidle step deep


# If the PACKAGE_NAME is not empty or null
if ! [[ -z "${PACKAGE_NAME}" ]]; then
	echo -e "Set inactive package ${CYAN}$PACKAGE_NAME${NC}"
	# Set inactive application
	adb $DEVICE_PARAMETER shell am set-inactive $PACKAGE_NAME true
	adb $DEVICE_PARAMETER shell am get-inactive $PACKAGE_NAME
fi



# https://notifee.app/react-native/docs/android/background-restrictions
# Set low_power mode
adb $DEVICE_PARAMETER shell settings put global low_power 1


# REMOVE DOZE MODE
# Disable deviceidle
#adb $DEVICE_PARAMETER shell dumpsys deviceidle disable

# Reset battery
#adb $DEVICE_PARAMETER shell dumpsys battery reset