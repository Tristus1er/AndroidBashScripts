#!/bin/bash

#* This script install an application on a device using serial AND file name.
#* Force install in case of:
#* - Application already installed.
#* - Downgrade.
#* - Signature error.
#* - Test application.
#* If first attempt of install fail, then uninstall the application, and try to install again.
#*
#*
#* Example : 
#* ```sh
#* ./install_apk.sh -a /c/apk/Application.apk
#* ./install_apk.sh -s emulator-5556 -a /c/apk/Application.apk
#* ```


source _generic_methods.sh

# -------------------------------------------------------------------------------------------------
# Functions
# -------------------------------------------------------------------------------------------------
function usage() {
  echo "$0 [-s <deviceSerialNumber>] -a <apkPath>"
  echo " -s deviceSerialNumber: The serial number of the device to use to run the command."
  echo " -a applicationPackage : The path of APK to install."
  echo ""
  echo "Example :"
  echo "$0 -a /c/apk/Application.apk"
  echo "$0 -s emulator-5556 -a /c/apk/Application.apk"
  echo
}

# -------------------------------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------------------------------
DEVICE_PARAMETER=
APK_PATH=

# -------------------------------------------------------------------------------------------------
# Main
# -------------------------------------------------------------------------------------------------

while getopts "vhs:a:" arg; do
    case $arg in
         s) DEVICE_PARAMETER="-s $OPTARG";;
         a) APK_PATH="$OPTARG";;
         h) usage; exit 1;;
         v) echo "version 1.0.0"; exit 1;;
		 *) usage; exit 1;;
    esac
done

if [ -z "${APK_PATH}" ]; then
	echo -e "${RED}APK path must not be empty.${NC}"
  usage
  sleep 10
  exit 1
fi


check_adb
if [ $? -ne 0 ]
then
  echo -e "${RED}ADB is missing, please install it to continue.${NC}"
	sleep 10
	exit 10
fi

check_aapt
if [ $? -ne 0 ]
then
  echo -e "${RED}aapt is missing, please install it to continue.${NC}"
	sleep 10
	exit 11
fi


echo -e "${PURPLE}**************************${NC}"
echo -e "${PURPLE}*     INSTALL AN APK     *${NC}"
echo -e "${PURPLE}**************************${NC}"

if [ -f "$APK_PATH" ]; then
    echo "$APK_PATH exists."
else
	echo -e "${RED}File is missing: ${APK_PATH}${NC}"
	exit 12
fi



if [ -z "${DEVICE_PARAMETER}" ]; then
	wait_for_device
fi

echo -e "${CYAN}Installing $APK_PATH${NC}"
adb $DEVICE_PARAMETER install -r -d -g -t "$APK_PATH"
if [ $? -ne 0 ]
then
  echo -e "${YELLOW}ERROR Install.${NC}"
  echo -e "${CYAN}Delete old app${NC}${YELLOW} (All data apps are lost).${NC}"
  adb $DEVICE_PARAMETER uninstall `aapt dump badging  "$APK_PATH" | grep package:\ name | sed -n 's/package: name=\x27\(.*\)\x27.*versionCode.*/\1/p'`
  echo -e "${CYAN}Retrying install.${NC}"
  adb $DEVICE_PARAMETER install -r -d -g -t "$APK_PATH"
  if [ $? -ne 0 ]
  then
	#Source: https://stackoverflow.com/questions/15014519/apk-installation-failed-install-failed-verification-failure
	echo -e "${CYAN}Disable APK verifications.${NC}"
	adb shell settings put global verifier_verify_adb_installs 0
	adb shell settings put global package_verifier_enable 0
	adb $DEVICE_PARAMETER install -r -d -g -t "$APK_PATH"
	if [ $? -ne 0 ]
	then
		echo -e "${RED}ERROR Install.${NC}"
		sleep 10
		exit 13
	else
		echo -e "${GREEN}INSTALL OK.${NC}"
	  fi
  else
	echo -e "${GREEN}INSTALL OK.${NC}"
  fi
else
  echo -e "${GREEN}INSTALL OK.${NC}"
fi