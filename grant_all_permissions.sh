#!/bin/bash

#* This script grant all permission for a package.
#*
#*
#* Example : 
#* ```sh
#* ./grant_all_permissions.sh -p com.android.vending
#* ./grant_all_permissions.sh -s emulator-5556 -p com.android.vending
#* ./grant_all_permissions.sh -r -s emulator-5556 -p com.android.vending
#* ```

source _generic_methods.sh

# -------------------------------------------------------------------------------------------------
# Functions
# -------------------------------------------------------------------------------------------------
function usage() {
  echo "$0 [-s <deviceSerialNumber>] -p <applicationPackage>"
  echo " -s deviceSerialNumber: The serial number of the device to use to run the command."
  echo " -p applicationPackage : The package name of the application to handle."
  echo " -r : Revoke mode."
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
GRANTING_MODE='grant'

# -------------------------------------------------------------------------------------------------
# Main
# -------------------------------------------------------------------------------------------------

while getopts "vhrs:p:" arg; do
    case $arg in
         s) DEVICE_PARAMETER="-s $OPTARG";;
         p) PACKAGE_NAME="$OPTARG";;
         r) GRANTING_MODE='revoke';;
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


if [[ $GRANTING_MODE = "grant" ]]
then

    echo -e "${PURPLE}*****************************************************${NC}"
	echo -e "${PURPLE}*     GRANT ALL PERMISSIONS FOR THE APPLICATION     *${NC}"
	echo -e "${PURPLE}*****************************************************${NC}"

	if [ -z "${DEVICE_PARAMETER}" ]; then
		wait_for_device
	fi

	#Gell all non granted permissions
	PERMISSIONS_LIST=`adb $DEVICE_PARAMETER shell dumpsys package $PACKAGE_NAME | grep "granted=false" | sed "s/^[[:blank:]]*//;s/[[:blank:]]*$//" | sed "s/^\(.*\):.*/\1/"`
	echo "Permissions not granted, to be granted:"
	echo "$PERMISSIONS_LIST" # use the " to keep the carriage return in the variable

	echo "--------------------------------------------------------------------------------"
	for PERMISSION in $PERMISSIONS_LIST
	do
	  echo "Granting $PERMISSION"
	  adb $DEVICE_PARAMETER shell pm grant $PACKAGE_NAME $PERMISSION
	done

else

    echo -e "${PURPLE}*****************************************************${NC}"
	echo -e "${PURPLE}*     REVOKE ALL PERMISSIONS FOR THE APPLICATION     *${NC}"
	echo -e "${PURPLE}*****************************************************${NC}"

	if [ -z "${DEVICE_PARAMETER}" ]; then
		wait_for_device
	fi

	#Gell all non granted permissions
	PERMISSIONS_LIST=`adb $DEVICE_PARAMETER shell dumpsys package $PACKAGE_NAME | grep "granted=true" | sed "s/^[[:blank:]]*//;s/[[:blank:]]*$//" | sed "s/^\(.*\):.*/\1/"`
	echo "Permissions granted, to be revoked:"
	echo "$PERMISSIONS_LIST" # use the " to keep the carriage return in the variable

	echo "--------------------------------------------------------------------------------"
	for PERMISSION in $PERMISSIONS_LIST
	do
	  echo "Granting $PERMISSION"
	  adb $DEVICE_PARAMETER shell pm revoke $PACKAGE_NAME $PERMISSION
	done

fi





PERMISSIONS_LIST=`adb $DEVICE_PARAMETER shell dumpsys package $PACKAGE_NAME | grep "granted=false" | sed "s/^[[:blank:]]*//;s/[[:blank:]]*$//" | sed "s/^\(.*\):.*/\1/"`
echo ""
echo ""
echo "--------------------------------------------------------------------------------"
echo "Permissions not granted:"
PERMISSIONS_LIST=`adb $DEVICE_PARAMETER shell dumpsys package $PACKAGE_NAME | grep "granted=false" | sed "s/^[[:blank:]]*//;s/[[:blank:]]*$//" | sed "s/^\(.*\):.*/\1/"`
echo "$PERMISSIONS_LIST" # use the " to keep the carriage return in the variable

echo "--------------------------------------------------------------------------------"
echo "Permissions granted:"
PERMISSIONS_LIST=`adb $DEVICE_PARAMETER shell dumpsys package $PACKAGE_NAME | grep "granted=true" | sed "s/^[[:blank:]]*//;s/[[:blank:]]*$//" | sed "s/^\(.*\):.*/\1/"`
echo "$PERMISSIONS_LIST" # use the " to keep the carriage return in the variable


# Error:
# java.lang.SecurityException: grantRuntimePermission: Neither user 2000 nor current process has android.permission.GRANT_RUNTIME_PERMISSIONS.
# Solution:
# Go on the device, in Settings, Developer Options, scroll down until you find Disable Permission Monitoring and activate it


# Error:
# java.lang.SecurityException: Permission android.permission.SCHEDULE_EXACT_ALARM requested by <package_name> is not a changeable permission type
# Possible origin:
# When you clear the app data, you loose the permission granted during install process.
# Solution:
# Uninstall the application, then install it again.


# Example of manual grant
# adb $DEVICE_PARAMETER shell pm grant com.stid.blechallenge android.permission.POST_NOTIFICATIONS
# adb $DEVICE_PARAMETER shell pm grant com.stid.blechallenge android.permission.ACCESS_FINE_LOCATION
# adb $DEVICE_PARAMETER shell pm grant com.stid.blechallenge android.permission.ACCESS_COARSE_LOCATION
# adb $DEVICE_PARAMETER shell pm grant com.stid.blechallenge android.permission.ACCESS_BACKGROUND_LOCATION
# adb $DEVICE_PARAMETER shell pm grant com.stid.blechallenge android.permission.BLUETOOTH_SCAN

# Reset all permissions for all the application in the mobile
# adb shell pm reset-permissions