#!/bin/bash

#* This script allow to run other script on a chosen device or on all connected devices.
#*
#*
#* Example : 
#* ```sh
#* ./choose_device.sh
#* ```

source _generic_methods.sh

# Handle parameter (device name)
COMMAND_TO_LAUNCH="./reset_test.sh"
if [ -z "$1" ]
then
	echo "Using the default command $COMMAND_TO_LAUNCH"
else
	echo "Using the command : $1"
	COMMAND_TO_LAUNCH="$1 $2 $3 $4 $5 $6 $7 $8 $9"
fi

# Path to the Git Bash executable
GIT_BASH_PATH="/c/Program Files/Git/bin/bash.exe"

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
			   echo -e "Running : ${CYAN}$currentDevice${NC} $COMMAND_TO_LAUNCH -s $currentDevice"
			   start "" "$GIT_BASH_PATH" -c "$COMMAND_TO_LAUNCH -s $currentDevice"
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
				./$COMMAND_TO_LAUNCH -s $deviceChoosen
				exit
			fi
			;;
    esac
done