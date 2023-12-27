#!/bin/bash

#* This script display some information about the device.
#*
#*
#* Example : 
#* ```sh
#* ./device_info.sh
#* ./device_info.sh -s emulator-5556
#* ```

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
DEVICE_SERIAL=`adb shell getprop ro.serialno`
DEVICE_PARAMETER=

# -------------------------------------------------------------------------------------------------
# Main
# -------------------------------------------------------------------------------------------------

while getopts "vhs:" arg; do
    case $arg in
         s) DEVICE_PARAMETER="-s $OPTARG"; DEVICE_SERIAL="$OPTARG";;
         h) usage; exit 1;;
         v) echo "version 1.0.0"; exit 1;;
		 *) usage; exit 1;;
    esac
done


echo -e "${PURPLE}*******************************************${NC}"
echo -e "${PURPLE}*     GIVE INFORMATIONS ON THE DEVICE     *${NC}"
echo -e "${PURPLE}*******************************************${NC}"

if [ -z "${DEVICE_PARAMETER}" ]; then
	wait_for_device
fi

MODEL=`adb $DEVICE_PARAMETER shell getprop ro.product.model`
#adb $DEVICE_PARAMETER shell getprop ro.board.platform
MANUFACTURER=`adb $DEVICE_PARAMETER shell getprop ro.product.manufacturer`

ANDROID_NUMBER=`adb $DEVICE_PARAMETER shell getprop ro.build.version.release`

COMMERCIAL_NAME=`adb $DEVICE_PARAMETER shell getprop ro.vendor.oplus.market.name`

#ro.product.vendor.manufacturer
#ro.product.vendor.model

#ro.vendor.oplus.market.name
#[ro.build.version.realmeui]: [V3.0]
#[ro.build.version.release]: [12]
#[ro.product.brand]: [realme]
#[ro.product.model]: [RMX3472]

# Display default applications informations.
# Default dialer:
adb $DEVICE_PARAMETER shell cmd package resolve-activity tel://123456
#Default mail:
adb $DEVICE_PARAMETER shell cmd package resolve-activity mailto:john@example.com
#Default browser:
adb $DEVICE_PARAMETER shell cmd package resolve-activity http://www.example.com/
#Default messenging:
adb $DEVICE_PARAMETER shell cmd package resolve-activity sms://123456
#Default homescreen launcher:
adb $DEVICE_PARAMETER shell cmd package resolve-activity -c android.intent.category.HOME -a android.intent.action.MAIN

# Get various informations
adb shell getprop | grep "model\|version.sdk\|manufacturer\|ro.serialno\|product.name\|brand\|version.release\|build.id\|security_patch" | sed 's/ro\.//g'
# get the device imei
echo "[device.imei]: [$(adb shell service call iphonesubinfo 1 | awk -F "'" '{print $2}' | sed '1 d'| tr -d '\n' | tr -d '.' | tr -d ' ')]"
# get the device phone number
echo "[device.phonenumber]: [$(adb shell service call iphonesubinfo 19 | awk -F "'" '{print $2}' | sed '1 d'| tr -d '\n' | tr -d '.' | tr -d ' ')]"

echo -e "$DEVICE_SERIAL,$MANUFACTURER,$MODEL,$ANDROID_NUMBER,$COMMERCIAL_NAME"
#echo -e "$DEVICE_SERIAL,$MANUFACTURER,$MODEL,$ANDROID_NUMBER,$COMMERCIAL_NAME" >> devices.txt
#adb $DEVICE_PARAMETER shell getprop > "getprop_${MANUFACTURER}_${MODEL}_${ANDROID_NUMBER}_${DEVICE_SERIAL}.txt"