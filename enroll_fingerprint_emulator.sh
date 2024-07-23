#!/bin/bash

#!/bin/bash

#* This script allow to enroll fingerprint to a clean emulator device.
#*
#*
#* Example : 
#* ```sh
#* ./enroll_fingerprint_emulator.sh -n 0000
#* ./enroll_fingerprint_emulator.sh -s emulator-5556 -n 0000
#* ```

source _generic_methods.sh

# -------------------------------------------------------------------------------------------------
# Functions
# -------------------------------------------------------------------------------------------------
function usage() {
  echo "$0 [-s <deviceSerialNumber>] [-n <pinCodeToUse>]"
  echo " -s deviceSerialNumber: The serial number of the device to use to run the command."
  echo " -n pinCodeToUse : Th pin code to use. By default it will use 0000."
  echo ""
  echo "Example :"
  echo "$0 -n 0000"
  echo "$0 -s emulator-5556 -n 0000"
  echo
}

# -------------------------------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------------------------------
DEVICE_PARAMETER=
PIN_CODE_TO_USE="0000"

# -------------------------------------------------------------------------------------------------
# Main
# -------------------------------------------------------------------------------------------------

while getopts "vhs:n:" arg; do
    case $arg in
         s) DEVICE_PARAMETER="-s $OPTARG";;
         n) PIN_CODE_TO_USE="$OPTARG";;
         h) usage; exit 1;;
         v) echo "version 1.0.0"; exit 1;;
		 *) usage; exit 1;;
    esac
done

echo -e "${PURPLE}******************************************${NC}"
echo -e "${PURPLE}*     ENROLL FINGERPRINT TO EMULATOR     *${NC}"
echo -e "${PURPLE}******************************************${NC}"

if [ -z "${DEVICE_PARAMETER}" ]; then
	wait_for_device
fi

# Enrolement process
# https://stackoverflow.com/questions/56133153/how-to-set-fingerprint-lock-screen-from-adb
# Keycode event
# https://stackoverflow.com/questions/7789826/adb-shell-input-event

# x, y clicks defined for emulator NEXUS S.


# Set pin code
adb $DEVICE_PARAMETER shell locksettings set-pin $PIN_CODE_TO_USE
# Should answer:
# Pin set to '0000'
# If answer is the following, then the PIN is already set:
# Error while executing command: set-pin
# java.lang.IllegalArgumentException: Credential can't be null or empty


# Open settings
adb $DEVICE_PARAMETER shell am start -a android.settings.SECURITY_SETTINGS
sleep 1
# scroll to bottom
adb $DEVICE_PARAMETER shell input swipe 200 650 200 100
sleep 1
# click on Pixel Imprint
adb $DEVICE_PARAMETER shell input tap 230 620
sleep 1
# Input PIN code
adb $DEVICE_PARAMETER shell input text $PIN_CODE_TO_USE && adb shell input keyevent 66
sleep 1
# Click on more button
adb $DEVICE_PARAMETER shell input tap 360 750
sleep 1
# Click on more button, then click on I Agree
adb $DEVICE_PARAMETER shell input tap 360 750
sleep 1
adb $DEVICE_PARAMETER shell input tap 360 750
sleep 1
adb $DEVICE_PARAMETER shell input tap 360 750
sleep 1
adb $DEVICE_PARAMETER shell input tap 360 750
sleep 1

# Simulate finger press
adb $DEVICE_PARAMETER -e emu finger touch 1
sleep 1
adb $DEVICE_PARAMETER -e emu finger touch 1
sleep 1
adb $DEVICE_PARAMETER -e emu finger touch 1
sleep 1
# click on done
adb $DEVICE_PARAMETER shell input tap 360 750
sleep 1
# click on home
adb shell input keyevent 3