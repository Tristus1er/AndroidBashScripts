#!/bin/bash

#* This script close the applications that are in the list of _config_apps.sh script.
#*
#*
#* Example : 
#* ```sh
#* ./close_apps.sh
#* ./close_apps.sh -s emulator-5556
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


echo -e "${PURPLE}**************************${NC}"
echo -e "${PURPLE}*     CLOSE ALL APPS     *${NC}"
echo -e "${PURPLE}**************************${NC}"

if [ -z "${DEVICE_PARAMETER}" ]; then
	wait_for_device
fi


echo ""
for key in "${!applicationsPackagesArray[@]}"
do
  echo Close $key
	adb $DEVICE_PARAMETER shell am force-stop ${applicationsPackagesArray[$key]}
	echo ""
done

for key in "${!testApplicationsPackagesArray[@]}"
do
  echo Close $key
	adb $DEVICE_PARAMETER shell am force-stop ${testApplicationsPackagesArray[$key]}
	echo ""
done
