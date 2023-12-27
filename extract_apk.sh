#!/bin/bash

#* This script allow to extract an APK from a non-root device.
#*
#*
#* Example : 
#* ```sh
#* ./extract_apk.sh
#* ./extract_apk.sh -3
#* ./extract_apk.sh -a
#* ./extract_apk.sh -3 -a
#* ```

source _generic_methods.sh

# -------------------------------------------------------------------------------------------------
# Functions
# -------------------------------------------------------------------------------------------------
function usage() {
  echo "$0 [-3] [-a] [-h] [-v]"
  echo " -3 : List only third party applications."
  echo " -a : Extract all applications."
  echo " -h : this help."
  echo " -v : version of the script."
  echo
}

# -------------------------------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------------------------------
third_party_applications=
extract_all_applications=false

# -------------------------------------------------------------------------------------------------
# Main
# -------------------------------------------------------------------------------------------------

while getopts "vha3" arg; do
    case $arg in
         3) third_party_applications="-3";;
         a) extract_all_applications=true;;
         h) usage; exit 1;;
         v) echo "version 1.0"; exit 1;;
    esac
done

echo -e "${PURPLE}***********************************${NC}"
echo -e "${PURPLE}*     EXTRACT APK FROM DEVICE     *${NC}"
echo -e "${PURPLE}***********************************${NC}"


mkdir -p extracted_apk

installed_apps_list=( $(adb shell "pm list packages $third_party_applications" | sed -n 's/package:\(.*\)/\1/p' | sort) )

if [[ "${#installed_apps_list[@]}" == "0" ]]; then
	echo -e "${YELLOW}WARNING: No applications found.${NC}"
else
	
	if [ "$extract_all_applications" = true ] ; then
		for PACKAGE in "${installed_apps_list[@]}"
		do
			echo "--------------------------------------------------"
			VERSION_NAME=`adb shell dumpsys package $PACKAGE | grep versionName | cut -d "=" -f 2`
			VERSION_CODE=`adb shell dumpsys package $PACKAGE | grep versionCode | cut -d " " -f 5 | cut -d "=" -f 2`
			APK_PATH=`adb shell pm path $PACKAGE | grep "base\.apk" | cut -d ":" -f 2`
			
			# Remove the first char (/) for Windows problem.
			APK_PATH="${APK_PATH:1}"
			
			APK_DEST_NAME="${PACKAGE}_${VERSION_NAME}_${VERSION_CODE}.apk"
			echo "Extract $APK_PATH"
			echo "To file $APK_DEST_NAME"
			adb pull /`adb shell pm path $PACKAGE | grep "base\.apk" | cut -d ":" -f 2` ./extracted_apk/$APK_DEST_NAME
		done

	else
		echo ""
		echo "List of all the available applications"
		PS3='Choose the application to extract: '

		select PACKAGE in "${installed_apps_list[@]}"; do
		  
			VERSION_NAME=`adb shell dumpsys package $PACKAGE | grep versionName | cut -d "=" -f 2`
			VERSION_CODE=`adb shell dumpsys package $PACKAGE | grep versionCode | cut -d " " -f 5 | cut -d "=" -f 2`
			APK_PATH=`adb shell pm path $PACKAGE | grep "base\.apk" | cut -d ":" -f 2`
			
			# Remove the first char (/) for Windows problem.
			APK_PATH="${APK_PATH:1}"
			
			APK_DEST_NAME="${PACKAGE}_${VERSION_NAME}_${VERSION_CODE}.apk"
			echo "Extract $APK_PATH"
			echo "To file $APK_DEST_NAME"
			adb pull /`adb shell pm path $PACKAGE | grep "base\.apk" | cut -d ":" -f 2` ./extracted_apk/$APK_DEST_NAME
		  break
		done
	fi
fi
