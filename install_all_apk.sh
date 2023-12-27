#!/bin/bash

#* This script install all APK in a folder. Use install_apk.sh script.
#* 
#* Example : 
#* ```sh
#* ./install_all_apk.sh -f /c/apk/
#* ./install_all_apk.sh -s emulator-5556 -f /c/apk/
#* ```

source _generic_methods.sh

# -------------------------------------------------------------------------------------------------
# Functions
# -------------------------------------------------------------------------------------------------
function usage() {
  echo "$0 [-s <deviceSerialNumber>] -f <apkFolder>"
  echo " -s deviceSerialNumber: The serial number of the device to use to run the command."
  echo " -f apkFolder : The folder where all the APKs to install are located."
  echo ""
  echo "Example :"
  echo "$0 -f /c/apk/"
  echo "$0 -s emulator-5556 -f /c/apk/"
  echo
}

# -------------------------------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------------------------------
DEVICE_PARAMETER=
APK_FOLDER=

# -------------------------------------------------------------------------------------------------
# Main
# -------------------------------------------------------------------------------------------------

while getopts "vhs:f:" arg; do
    case $arg in
         s) DEVICE_PARAMETER="-s $OPTARG";;
         f) APK_FOLDER="$OPTARG";;
         h) usage; exit 1;;
         v) echo "version 1.0.0"; exit 1;;
		 *) usage; exit 1;;
    esac
done

if [ -z "${APK_FOLDER}" ]; then
	echo -e "${RED}APK folder must not be empty.${NC}"
    usage
	exit 50
fi


#Check folder format
FOLDER_TO_USE=$APK_FOLDER
echo "Path to use : $FOLDER_TO_USE"

re="[A-Za-z]:"
if [[ $APK_FOLDER =~ $re ]]
then
  echo -e "${CYAN}Windows folder format detected, converting to :${NC}"
  echo -e ""
  echo "/$APK_FOLDER" | sed -e 's/\\/\//g' -e 's/://'
  echo -e "${NC}"
  FOLDER_TO_USE=$(echo "/$APK_FOLDER" | sed -e 's/\\/\//g' -e 's/://')
fi

#check folder exist
if [ -d "$FOLDER_TO_USE" ]
then
  echo -e "${GREEN}Folder $FOLDER_TO_USE found.${NC}"
else
  echo -e "${RED}Folder $FOLDER_TO_USE NOT FOUND.${NC}"
  echo -e "\e[1mMaybe you can add \" before AND after your path ?${NC}."
  exit
fi


echo -e "${PURPLE}****************************${NC}"
echo -e "${PURPLE}*     INSTALL ALL APPS     *${NC}"
echo -e "${PURPLE}****************************${NC}"


for filename in $FOLDER_TO_USE/*.apk; do
	./install_apk.sh $DEVICE_PARAMETER -a "$filename"
done
