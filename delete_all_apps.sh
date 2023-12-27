#!/bin/bash

#* This script delete all the applications of the list defined in _config_apps.sh script.
#*
#*
#* Example : 
#* ```sh
#* ./delete_all_apps.sh
#* ./delete_all_apps.sh -s emulator-5556
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


echo -e "${PURPLE}***************************${NC}"
echo -e "${PURPLE}*     DELETE ALL APPS     *${NC}"
echo -e "${PURPLE}***************************${NC}"

if [ -z "${DEVICE_PARAMETER}" ]; then
	wait_for_device
fi


echo Delete all applications
echo ""
for key in "${!applicationsPackagesArray[@]}"
do
  echo Delete $key
	adb $DEVICE_PARAMETER uninstall ${applicationsPackagesArray[$key]}
	echo ""
done