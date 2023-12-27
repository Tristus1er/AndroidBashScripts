#!/bin/bash

#* This script add or remove the application to the battery optimization list.
#*
#*
#* Example : 
#* ```sh
#* ./battery_optimization.sh -p com.android.vending
#* ./battery_optimization.sh -s emulator-5556 -p com.android.vending
#* ./battery_optimization.sh -s emulator-5556 -p com.android.vending -r
#* ./battery_optimization.sh -s emulator-5556 -p com.android.vending -r -d
#* ```

source _generic_methods.sh

# -------------------------------------------------------------------------------------------------
# Functions
# -------------------------------------------------------------------------------------------------
function usage() {
  echo "$0 [-s <deviceSerialNumber>] -p <applicationPackage> [-a] [-r] [-d]"
  echo " -s deviceSerialNumber: The serial number of the device to use to run the command."
  echo " -p applicationPackage : The package name of the application to handle."
  echo " -a : Add the package to battery optimization list (no optimization) : default value."
  echo " -r : Remove the package to battery optimization list (optimization : default behaviour of the OS)."
  echo " -d : Display the list before and after the action."
  echo ""
  echo "Example :"
  echo "$0 -p com.android.vending"
  echo "$0 -s emulator-5556 -p com.android.vending"
  echo "$0 -s emulator-5556 -p com.android.vending -r"
  echo "$0 -s emulator-5556 -p com.android.vending -r -d"
  echo
}

# -------------------------------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------------------------------
DEVICE_PARAMETER=
PACKAGE_NAME=
ADD_TO_LIST=true
DISPLAY_BEFORE_AND_AFTER_STATUS=false

# -------------------------------------------------------------------------------------------------
# Main
# -------------------------------------------------------------------------------------------------

while getopts "vhs:p:ard" arg; do
    case $arg in
         s) DEVICE_PARAMETER="-s $OPTARG";;
         p) PACKAGE_NAME="$OPTARG";;
         a) ADD_TO_LIST=true;;
         r) ADD_TO_LIST=false;;
         d) DISPLAY_BEFORE_AND_AFTER_STATUS=true;;
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

echo -e "${PURPLE}***************************************************************${NC}"
echo -e "${PURPLE}*     ADD/REMOVE APPLICATION OF BATTERY OPTIMIZATION LIST     *${NC}"
echo -e "${PURPLE}***************************************************************${NC}"

if [ -z "${DEVICE_PARAMETER}" ]; then
	wait_for_device
fi

if [ "$DISPLAY_BEFORE_AND_AFTER_STATUS" = true ] ; then
	echo "Packages in Battery Whitelist BEFORE"

	# Dump Doze mode info
	adb $DEVICE_PARAMETER shell dumpsys deviceidle | sed -n '/  Whitelist user apps:/, /  Whitelist (except idle) all app ids:/p' | head -n -1 | tail -n +2
	# sed -n '/ Whitelist user apps:/, /  Whitelist (except idle) all app ids:/p'
	# Keep all the lines between "  Whitelist user apps:" and "  Whitelist (except idle) all app ids:"
	# head -n -1
	# Remove the last line
	# tail -n +2
	# Remove the first line
fi

if [ "$ADD_TO_LIST" = true ] ; then
	# Add the package to the whitelist
	adb $DEVICE_PARAMETER shell dumpsys deviceidle whitelist +$PACKAGE_NAME
else
	# Remove the package of the whitelist
	adb $DEVICE_PARAMETER shell dumpsys deviceidle whitelist -$PACKAGE_NAME
fi

if [ "$DISPLAY_BEFORE_AND_AFTER_STATUS" = true ] ; then
	echo "Packages in Battery Whitelist AFTER action"
	# Dump Doze mode info
	adb $DEVICE_PARAMETER shell dumpsys deviceidle | sed -n '/  Whitelist user apps:/, /  Whitelist (except idle) all app ids:/p' | head -n -1 | tail -n +2
fi