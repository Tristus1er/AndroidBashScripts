#!/bin/bash

#* This script remove the appium applications.
#*
#*
#* Example : 
#* ```sh
#* ./reset_appium.sh
#* ./reset_appium.sh -s emulator-5556
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

while getopts "vhs:" arg; do
    case $arg in
         s) DEVICE_PARAMETER="-s $OPTARG";;
         h) usage; exit 1;;
         v) echo "version 1.0.0"; exit 1;;
		 *) usage; exit 1;;
    esac
done

echo -e "${PURPLE}*************************************${NC}"
echo -e "${PURPLE}*     CLEAR APPIUM APPLICATIONS     *${NC}"
echo -e "${PURPLE}*************************************${NC}"

if [ -z "${DEVICE_PARAMETER}" ]; then
	wait_for_device
fi


echo -e "Delete ${CYAN}io.appium.settings${NC}"
adb $DEVICE_PARAMETER uninstall io.appium.settings
echo -e "Delete ${CYAN}io.appium.uiautomator2.server${NC}"
adb $DEVICE_PARAMETER uninstall io.appium.uiautomator2.server
echo -e "Delete ${CYAN}io.appium.uiautomator2.server.test${NC}"
adb $DEVICE_PARAMETER uninstall io.appium.uiautomator2.server.test