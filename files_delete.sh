#!/bin/bash

#* This script deletes files from de device.
#*
#*
#* Example : 
#* ```sh
#* ./files_delete.sh
#* ./files_delete.sh -s emulator-5556
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


echo -e "${PURPLE}************************************${NC}"
echo -e "${PURPLE}*     DELETE FILES FROM DEVICE     *${NC}"
echo -e "${PURPLE}************************************${NC}"

# TODO : device parameter is mandatory

if [ -z "${DEVICE_PARAMETER}" ]; then
	wait_for_device
fi

filesList=`adb $DEVICE_PARAMETER shell ls sdcard/Download/*.png`
for filename in $filesList; do
	# Remove not needed empty characters
	currentFileName=`echo "$filename" | xargs`
	echo -e "Delete ${CYAN}$currentFileName${NC}"
	adb $DEVICE_PARAMETER shell rm $currentFileName
done
