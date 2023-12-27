#!/bin/bash

#* This script give a status of the applications listed in the _config_apps.sh script:
#* - Installed or NOT.
#* - DEBUG/RELEASE mode.
#* - Backupable or NOT.  
#*
#*
#* Example : 
#* ```sh
#* ./check_apps_state.sh
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

echo -e "${PURPLE}****************************${NC}"
echo -e "${PURPLE}*     CHECK APPS STATE     *${NC}"
echo -e "${PURPLE}****************************${NC}"

if [ -z "${DEVICE_PARAMETER}" ]; then
	wait_for_device
fi

check_app_mode () {
	# Check is application is installed (Unable to find package:)
	adb $DEVICE_PARAMETER shell dumpsys package $1 | findstr "Unable" > /dev/null
	if [ $? -eq 0 ]
	then
		echo -e "${RED}Application $1 NOT FOUND.${NC}"
		return 2
	else
		echo -e "${GREEN}Application found.${NC}"
	fi

	# Check if the application is debuggable
	adb $DEVICE_PARAMETER shell dumpsys package $1 | findstr flags | findstr DEBUGGABLE > /dev/null
	if [ $? -eq 0 ]
	then
		echo -e "${YELLOW}Application $1 DEBUGGABLE.${NC}"
	else
		echo -e "${CYAN}Application $1 (in RELEASE MODE).${NC}"
	fi

	# Check if the application is backupable
	adb $DEVICE_PARAMETER shell dumpsys package $1 | findstr flags | findstr ALLOW_BACKUP  > /dev/null
	if [ $? -eq 0 ]
	then
		echo -e "${GREEN}Application $1 backup allowed.${NC}"
	else
		echo -e "${RED}Application $1 BACKUP NOT ALLOWED.${NC}"
	fi
}

echo ---------- Check apps states ----------
for key in "${!applicationsPackagesArray[@]}"
do
    echo Check $key
	check_app_mode ${applicationsPackagesArray[$key]}
	echo ""
done
