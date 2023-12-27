#!/bin/bash

#* This script display the next alarm set for an application.
#*
#*
#* Example : 
#* ```sh
#* ./alarm_test.sh
#* ./alarm_test.sh -s emulator-5556
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

if [ -z "${PACKAGE_NAME}" ]; then
	echo -e "${RED}Package name must not be empty.${NC}"
    usage
	exit 1
fi


echo -e "${PURPLE}*************************************************${NC}"
echo -e "${PURPLE}*     DISPLAY INFORMATION ABOUT ALART STATE     *${NC}"
echo -e "${PURPLE}*************************************************${NC}"

if [ -z "${DEVICE_PARAMETER}" ]; then
	wait_for_device
fi


echo -e "Alarm informations for package ${CYAN}$PACKAGE_NAME${NC}"
adb $DEVICE_PARAMETER shell dumpsys alarm |  sed -n '/Next wake from idle: Alarm.*$PACKAGE_NAME/,$p' | head -n 7

echo -e -n "Next alarm in: ${GREEN}"
adb $DEVICE_PARAMETER shell dumpsys alarm |  sed -n '/Next wake from idle: Alarm.*$PACKAGE_NAME/,$p' | head -n 7 | grep expectedWhenElapsed | sed 's/.*expectedWhenElapsed=\(.*\) expectedMaxWhenElapsed.*/\1/'
echo -e "${NC}"

echo "Current device date"
adb $DEVICE_PARAMETER shell date