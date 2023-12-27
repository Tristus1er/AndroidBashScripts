#!/bin/bash

#* This script allow generating JACOCO report (the Jacoco Broadcast receiver MUST have been integrated in the application).
#*
#*
#* Example : 
#* ```sh
#* ./jacoco_extract_code_coverage.sh -p com.android.vending
#* ./jacoco_extract_code_coverage.sh -p com.android.vending -f temp_report.ec
#* ./jacoco_extract_code_coverage.sh -p com.android.vending -f temp_report.ec -d campaign1
#* ```

source _generic_methods.sh

# -------------------------------------------------------------------------------------------------
# Functions
# -------------------------------------------------------------------------------------------------
function usage() {
  echo "$0 [-s <deviceSerialNumber>] -p <applicationPackage> [-f <filename>] [-d <directory>]"
  echo " -s deviceSerialNumber: The serial number of the device to use to run the command."
  echo " -p applicationPackage : The package name of the application to handle."
  echo " -f filename : The filename of the report to generate."
  echo " -d directory : The folder/directory where to put the report."
  echo ""
  echo "Example :"
  echo "$0 -p com.android.vending"
  echo "$0 -s emulator-5556 -p com.android.vending"
  echo "$0 -s emulator-5556 -p com.android.vending -f temp_report.ec"
  echo "$0 -s emulator-5556 -p com.android.vending -f temp_report.ec -d campain1"
  echo
}

# -------------------------------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------------------------------
DEVICE_PARAMETER=
PACKAGE_NAME=
FILENAME="report.ec"
FOLDER="folder_name"

# -------------------------------------------------------------------------------------------------
# Main
# -------------------------------------------------------------------------------------------------

while getopts "vhs:p:f:d:" arg; do
    case $arg in
         s) DEVICE_PARAMETER="-s $OPTARG";;
         p) PACKAGE_NAME="$OPTARG";;
         f) FILENAME="$OPTARG";;
         d) FOLDER="$OPTARG";;
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

INTENT_ACTION_NAME="${PACKAGE_NAME}.GENERATE_CODE_COVERAGE_REPORT"


echo -e "${PURPLE}**********************************************${NC}"
echo -e "${PURPLE}*     GENERATE AND EXTRACT JACOCO REPORT     *${NC}"
echo -e "${PURPLE}**********************************************${NC}"

if [ -z "${DEVICE_PARAMETER}" ]; then
	wait_for_device
fi

echo "Generate the report on the device for package ${CYAN}$PACKAGE_NAME${NC}"
adb $DEVICE_PARAMETER shell am broadcast -p $PACKAGE_NAME -a $INTENT_ACTION_NAME --es filename "$FILENAME"

echo "Extract the report to the local file: $FOLDER/$FILENAME"
adb $DEVICE_PARAMETER shell "run-as $PACKAGE_NAME cat files/$FILENAME" > $FOLDER/$FILENAME