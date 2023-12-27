#!/bin/bash

#* This script start an application. If the Activity is not filled, then discover by itself.
#*
#*
#* Example : 
#* ```sh
#* ./start_app.sh -p fr.dvilleneuve.lockito
#* ./start_app.sh -s emulator-5556 -p fr.dvilleneuve.lockito
#* ./start_app.sh -p fr.dvilleneuve.lockito -a .ui.SplashscreenActivity
#* ./start_app.sh -s emulator-5556 -p fr.dvilleneuve.lockito -a .ui.SplashscreenActivity
#* ```

source _generic_methods.sh

# -------------------------------------------------------------------------------------------------
# Functions
# -------------------------------------------------------------------------------------------------
function usage() {
  echo "$0 [-s <deviceSerialNumber>] -p <applicationPackage> [-a <applicationActivity>]"
  echo " -s deviceSerialNumber: The serial number of the device to use to run the command."
  echo " -p applicationPackage : The package name of the application to handle."
  echo " -a applicationActivity : The activity name to launch, if empty, then try to find the good one."
  echo ""
  echo "Example :"
  echo "$0 -p fr.dvilleneuve.lockito"
  echo "$0 -p fr.dvilleneuve.lockito -a .ui.SplashscreenActivity"
  echo "$0 -s emulator-5556 -p fr.dvilleneuve.lockito -a .ui.SplashscreenActivity"
  echo
}

# -------------------------------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------------------------------
DEVICE_PARAMETER=
PACKAGE_NAME=
ACTIVITY_NAME=

# -------------------------------------------------------------------------------------------------
# Main
# -------------------------------------------------------------------------------------------------

while getopts "vhs:p:a:" arg; do
    case $arg in
         s) DEVICE_PARAMETER="-s $OPTARG";;
         p) PACKAGE_NAME="$OPTARG";;
         a) ACTIVITY_NAME="$OPTARG";;
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

echo -e "${PURPLE}*****************************${NC}"
echo -e "${PURPLE}*     START APPLICATION     *${NC}"
echo -e "${PURPLE}*****************************${NC}"

if [ -z "${DEVICE_PARAMETER}" ]; then
	wait_for_device
fi

if [ -z "${ACTIVITY_NAME}" ]; then
	echo -e "Find the activity to launch for package ${CYAN}$PACKAGE_NAME${NC}"
	APP_TO_LAUNCH=`adb $DEVICE_PARAMETER shell pm dump ${PACKAGE_NAME} | grep -A 1 android.intent.action.MAIN: | tail -n +2 | tr -s ' ' | cut -d ' ' -f 3`
	# Line explanation
	# adb shell pm dump ${PACKAGE_NAME}
	# Get all the informations about the application using it's package name.
	# grep -A 1 android.intent.action.MAIN:
	# Get only the line containing android.intent.action.MAIN: AND the next one.
	# tail -n +2
	# Keep only the second line (containing the interesting information).
	# tr -s ' '
	# convert multiple spaces to a single one.
	# cut -d ' ' -f 3
	# get the 3rd field: the one containing thevalue we are looking for.
	
	echo -e "Launching  ${CYAN}$APP_TO_LAUNCH${NC}"
	adb $DEVICE_PARAMETER shell am start -n $APP_TO_LAUNCH
else
	adb $DEVICE_PARAMETER shell am start -n ${PACKAGE_NAME}/${ACTIVITY_NAME}
fi