#!/bin/bash

#* This script allow to run other script on a chosen device or on all connected devices, and if on one device you can choose the package.
#*
#*
#* Example : 
#* ```sh
#* ./choose_device_and_package.sh
#* ```

source _generic_methods.sh

function choose_package() {
	PS3='Choose the package application to launch the script: '
	# 
	# List all the 3 rd party applications, and remove the "package:" prefix
	INSTALLED_APPS_LIST=( $(adb -s $1 shell "pm list packages -3" | sed -n 's/package:\(.*\)/\1/p') )

	IFS=$'\n' INSTALLED_APPS_LIST_SORTED=($(sort <<<"${INSTALLED_APPS_LIST[*]}")); unset IFS

	select application in "${INSTALLED_APPS_LIST_SORTED[@]}"; do
	  TARGET_APPLICATION=$application
	  break
	done
	
	echo $TARGET_APPLICATION
}

# Handle parameter (device name)
COMMAND_TO_LAUNCH="./reset_test.sh"
if [ -z "$1" ]
then
	echo "Using the default command $COMMAND_TO_LAUNCH"
else
	echo "Using the command : $1"
	COMMAND_TO_LAUNCH="$1 $2 $3 $4 $5 $6 $7 $8 $9"
fi


PS3='Choose the device to run the script: '

deviceList=`adb devices | tail -n +2 | cut -f1`

SAVEIFS=$IFS   # Save current IFS (Internal Field Separator)
IFS=$'\n'      # Change IFS to newline char
deviceList=($deviceList) # split the `deviceList` string into an array by the same name
IFS=$SAVEIFS   # Restore original IFS

b=("${a[@]}") 

deviceListChoice=("${deviceList[@]}") # Copy the array
# Add new element at the beginning of the array
deviceListChoice=('All of them' "${deviceListChoice[@]}")
# Add new element at the end of the array
deviceListChoice+=("Quit")

select deviceChoosen in "${deviceListChoice[@]}"; do
    case $deviceChoosen in
        "All of them")
            echo "Loop on all of them"
			for currentDevice in "${deviceList[@]}"
			do
			   echo -e "Running : ${CYAN}$currentDevice${NC}"
			   start ./$COMMAND_TO_LAUNCH -s $currentDevice
			done
			exit
            ;;
		"Quit")
            break
            ;;
        *)
			if [ -z "$deviceChoosen" ]
			then
				echo -e "${RED}Wrong choice${NC}"
			else
				echo -e "Use only ${CYAN}$deviceChoosen${NC}"
				./$COMMAND_TO_LAUNCH -s $deviceChoosen -p $(choose_package $deviceChoosen)
				exit
			fi
			;;
    esac
done