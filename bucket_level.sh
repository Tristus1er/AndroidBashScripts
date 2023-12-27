#!/bin/bash

#* This script display the bucket level of an application.
#* More information here : https://developer.android.com/topic/performance/appstandby
#*
#*
#* Example : 
#* ```sh
#* ./bucket_level.sh -p com.android.vending
#* ./bucket_level.sh -s emulator-5556 -p com.android.vending
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

echo -e "${PURPLE}**************************************************${NC}"
echo -e "${PURPLE}*     DISPLAY BUCKET LEVEL OF AN APPLICATION     *${NC}"
echo -e "${PURPLE}**************************************************${NC}"

if [ -z "${DEVICE_PARAMETER}" ]; then
	wait_for_device
fi


BUCKET_LEVEL=`adb $DEVICE_PARAMETER shell am get-standby-bucket $PACKAGE_NAME`

case $BUCKET_LEVEL in

  10)
    echo -n "STANDBY_BUCKET_ACTIVE"
    ;;

  30)
    echo -n "STANDBY_BUCKET_FREQUENT"
    ;;

  40)
    echo -n "STANDBY_BUCKET_RARE"
    ;;

  45)
    echo -n "STANDBY_BUCKET_RESTRICTED"
    ;;

  20)
    echo -n "STANDBY_BUCKET_WORKING_SET"
    ;;

  *)
    echo -n "unknown"
    ;;
esac