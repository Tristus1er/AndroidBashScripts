#!/bin/bash

#* This script add or remove the application to the battery optimization list.
#*
#*
#* Example : 
#* ```sh
#* ./take_screenshots.sh -f filename
#* ./take_screenshots.sh -s emulator-5556 -f filename
#* ```

source _generic_methods.sh

# -------------------------------------------------------------------------------------------------
# Functions
# -------------------------------------------------------------------------------------------------
function usage() {
  echo "$0 [-s <deviceSerialNumber>] -f <filename>"
  echo " -s deviceSerialNumber: The serial number of the device to use to run the command."
  echo " -f filename : The file name of the file where to store the screenshot."
  echo ""
  echo "Example :"
  echo "$0 -f main_screen"
  echo "$0 -s emulator-5556 -f main_screen"
  echo
}

# -------------------------------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------------------------------
DEVICE_PARAMETER=
FILE_NAME=

# -------------------------------------------------------------------------------------------------
# Main
# -------------------------------------------------------------------------------------------------

while getopts "vhs:f:" arg; do
    case $arg in
         s) DEVICE_PARAMETER="-s $OPTARG";;
         f) FILE_NAME="$OPTARG";;
         h) usage; exit 1;;
         v) echo "version 1.0.0"; exit 1;;
		 *) usage; exit 1;;
    esac
done

if [ -z "${FILE_NAME}" ]; then
	FILE_NAME="screenshot_$(date +"%Y_%m_%d_%I_%M_%p")"
fi

echo -e "${PURPLE}*****************************${NC}"
echo -e "${PURPLE}*     TAKING SCREENSHOT     *${NC}"
echo -e "${PURPLE}*****************************${NC}"


if [ -z "${DEVICE_PARAMETER}" ]; then
	wait_for_device
fi

adb $DEVICE_PARAMETER exec-out screencap -p > ${FILE_NAME}.png