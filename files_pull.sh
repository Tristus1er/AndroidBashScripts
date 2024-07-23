#!/bin/bash

#* This script pull files from de device.
#*
#*
#* Example : 
#* ```sh
#* ./files_pull.sh
#* ./files_pull.sh -s emulator-5556
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
OUTPUT_FOLDER=

# -------------------------------------------------------------------------------------------------
# Main
# -------------------------------------------------------------------------------------------------

while getopts "vhs:" arg; do
    case $arg in
         s) DEVICE_PARAMETER="-s $OPTARG"; SERIAL_NUMBER="$OPTARG";;
         h) usage; exit 1;;
         v) echo "version 1.0.0"; exit 1;;
		 *) usage; exit 1;;
    esac
done


echo -e "${PURPLE}**********************************${NC}"
echo -e "${PURPLE}*     PULL FILES FROM DEVICE     *${NC}"
echo -e "${PURPLE}**********************************${NC}"

# TODO : device parameter is mandatory

if [ -z "${DEVICE_PARAMETER}" ]; then
	wait_for_device
fi

MANUFACTURER=`adb $DEVICE_PARAMETER shell getprop ro.product.manufacturer`
MODEL=`adb $DEVICE_PARAMETER shell getprop ro.product.model`
ANDROID_NUMBER=`adb $DEVICE_PARAMETER shell getprop ro.build.version.release`
#SERIAL_NUMBER=`adb $DEVICE_PARAMETER shell getprop ro.serialno`
OUTPUT_FOLDER=${MANUFACTURER}_${MODEL}_${ANDROID_NUMBER}_${SERIAL_NUMBER}

mkdir $OUTPUT_FOLDER

echo -e "Pulling files to folder: ${CYAN}$OUTPUT_FOLDER${NC}"

filesList=`adb $DEVICE_PARAMETER shell ls sdcard/Download/*.png`
for filename in $filesList; do
	# Remove not needed empty characters
	currentFileName=`echo "$filename" | xargs`
	echo -e "Pull ${CYAN}$currentFileName${NC}"
	adb $DEVICE_PARAMETER pull $currentFileName ./$OUTPUT_FOLDER
done