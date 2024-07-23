#!/bin/bash

#* This script clean the applications that are in the _config_apps.sh script.
#*
#*
#* Example : 
#* ```sh
#* ./clear_data_apps.sh
#* ./clear_data_apps.sh -s emulator-5556
#* ```

source _config_apps.sh
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


echo -e "${PURPLE}*******************************${NC}"
echo -e "${PURPLE}*     CLEAR ALL APPS DATA     *${NC}"
echo -e "${PURPLE}*******************************${NC}"

if [ -z "${DEVICE_PARAMETER}" ]; then
	wait_for_device
fi

echo ""
for key in "${!applicationsPackagesArray[@]}"
	do
	echo Clear $key
	adb $DEVICE_PARAMETER shell pm clear ${applicationsPackagesArray[$key]}
	echo ""
done

for key in "${!testApplicationsPackagesArray[@]}"
	do
	echo Clear $key
	adb $DEVICE_PARAMETER shell pm clear ${testApplicationsPackagesArray[$key]}
	echo ""
done