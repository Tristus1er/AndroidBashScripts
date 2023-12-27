#!/bin/bash

#* This script activate the UI Night mode.
#*
#* Example : 
#* ```sh
#* ./change_ui_mode_night.sh
#* ./change_ui_mode_night.sh -s emulator-5556
#* ```

source _generic_methods.sh

# -------------------------------------------------------------------------------------------------
# Functions
# -------------------------------------------------------------------------------------------------
function usage() {
  echo "$0 [-s <deviceSerialNumber>]"
  echo " -s deviceSerialNumber: The serial number of the device to use to run the command."
  echo ""
  echo "Example :"
  echo "$0"
  echo "$0 -s emulator-5556"
  echo
}

# -------------------------------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------------------------------
DEVICE_PARAMETER=

# -------------------------------------------------------------------------------------------------
# Main
# -------------------------------------------------------------------------------------------------

while getopts "vhs" arg; do
    case $arg in
         s) DEVICE_PARAMETER="-s $OPTARG";;
         h) usage; exit 1;;
         v) echo "version 1.0.0"; exit 1;;
		 *) usage; exit 1;;
    esac
done

echo -e "${PURPLE}*************************${NC}"
echo -e "${PURPLE}*     UI MODE NIGHT     *${NC}"
echo -e "${PURPLE}*************************${NC}"


if [ -z "${DEVICE_PARAMETER}" ]; then
	wait_for_device
fi

adb $DEVICE_PARAMETER shell "cmd uimode night yes"