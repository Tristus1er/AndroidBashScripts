#!/bin/bash

#* This script install frida on windows and an Android device.
# example : ./frida_install.sh

source ../_generic_methods.sh

# Frida without root
# https://fadeevab.com/frida-gadget-injection-on-android-no-root-2-methods/

# Defeat certificate pinning
# https://httptoolkit.tech/blog/frida-certificate-pinning/


# Display title
display_os_detected() {
	case $OS in
	  LINUX)
		echo -e "${CYAN}LINUX${NC} OS Detected"
		;;
	  WINDOWS)
		echo -e "${CYAN}WINDOWS${NC} OS Detected"
		;;
	  *)
		echo -e "${RED}OS type ($OS) not recognized or not supported (yet), check detect_os method to detect your OS.${NC}"
		exit
		;;
	esac
}

# Check Windows/Linux dependencies
check_dependencies() {

	local required=0

	####################################################
	# Install Frida client, and dependancies if needed #
	####################################################

	case $OS in
	  LINUX)
		# Check root available, or at least sudo
		display_separator "Check root perms"
		if [ "$EUID" -ne 0 ]
			then 
			echo -n -e "${RED}/!\ Please run as root (to install dependencies - not implemented yet !)"
			echo -e "${NC}"
		fi

		check_adb
		if [ "$?" -ne 0 ];then $required=1; fi

		check_emulator

		check_unxz
		if [ "$?" -ne 0 ];then $required=1; fi

		check_python
		if [ "$?" -ne 0 ];then $required=1; fi
	
		check_pip
		if [ "$?" -ne 0 ];then $required=1; fi

		check_pipx
		if [ "$?" -ne 0 ];then $required=1; fi
	
		check_frida
		if [ "$?" -ne 0 ];then $required=1; fi

		;;
	  WINDOWS)
		# Check admin mode is available
		display_separator "Check Admin mode"
		check_admin_windows

		check_adb
		if [ "$?" -ne 0 ];then $required=1; fi

		check_emulator

		check_7z
		if [ "$?" -ne 0 ];then $required=1; fi

		check_python
		if [ "$?" -ne 0 ];then $required=1; fi
	
		check_pip
		if [ "$?" -ne 0 ];then $required=1; fi
	
		check_pipx
		if [ "$?" -ne 0 ];then $required=1; fi

		check_frida
		if [ "$?" -ne 0 ];then $required=1; fi

		# if [ $? -ne 0 ]
		# then
		# 	echo -e "${CYAN}Install frida with pip.${NC}"
		# 	echo -e "${CYAN}NOTE : If it's stuck here ... setup the proxy parameters :${NC}"
		# 	echo -e "${CYAN}Ctrl + C to stop this process ... be patient, then :${NC}"
		# 	echo -e "${CYAN}example : export http_proxy='http://w3p2.atos-infogerance.fr:8080'${NC}"
		# 	echo -e "${CYAN}example : export https_proxy='http://w3p2.atos-infogerance.fr:8080'${NC}"
		# 	pip install frida-tools
			
		# 	# Check if frida has been successfully installed
		# 	check_frida
		# 	if [ $? -ne 0 ]
		# 	then
		# 		echo -e "${RED}Frida fail to be installed. Check the logs, and maybe add it manually to the PATH.${NC}"
		# 		exit 14
		# 	fi
		# fi
		;;
	  *)
		;;
	esac
	
	echo -e "${NC}"

	# Some dependencies missing, stop the script
	if [ $required -ne 0 ]
	then
	    echo -e "${RED}/!\ Some dependencies are required, please install them to continue.${NC}"
		echo -e "${NC}"
		exit 2
	fi


}

# Check admin mode is ok
check_admin_windows(){
	# Source: https://www.anycodings.com/1questions/3092404/is-there-a-command-to-check-if-git-bash-is-opened-in-administrator-mode
	if [[ $(sfc 2>&1 | tr -d '\0') =~ SCANNOW ]]; then
		echo -e "${GREEN}Shell is in Administrator mode : OK, continue.${NC}"
	else
		echo -e "Hello ${CYAN}$USERNAME${NC} can you please start this scrip in ${CYAN}Administrator mode${NC}."
		#https://answers.microsoft.com/en-us/windows/forum/all/sfc-is-not-recognized-as-an-internal-or-external/62308df2-47ae-4b6d-8256-4289d760c974
		echo -e "If you are sure that your shell is opened in Admin mode, then there is a problem with ${CYAN}sfc${NC}."
		echo -e "Please check that ${CYAN}C:/Windows/System32${NC} is listed in Path."
		exit
	fi
}


display_title "Check OS"
detect_os
display_os_detected

case $OS in
  LINUX)
	# Check root available, or at least sudo
	;;
  WINDOWS)
	# Check admin mode is available
	display_title "Check Admin mode"
	check_admin_windows
	;;
  *)
	;;
esac


display_title "Check dependencies"

check_dependencies

FRIDA_CLIENT_VERSION=`frida --version`


display_title "Check that root device is available"

# Get the devices list (another method used to see another way to do the same thing).
# Remove the item starting with List
# Remove empty item
DEVICES_LIST=$(adb devices | awk '{if ($1!="List" && $1!="") print $1}')

DEVICES_ARRAY=(${DEVICES_LIST// / })

DEVICES_NBR="${#DEVICES_ARRAY[*]}"

DEVICE_TO_USE=""

if [[ "$DEVICES_NBR" == "0" ]]; then
    echo -e "${YELLOW}No running devices found.${NC}"
	
	# Get the AVD name(s)
	EMULATOR_LIST=`emulator -list-avds`
	
	
	SAVEIFS=$IFS   # Save current IFS (Internal Field Separator)
	IFS=$'\n'      # Change IFS to newline char
	EMULATOR_ARRAY=($EMULATOR_LIST) # split the `names` string into an array by the same name
	IFS=$SAVEIFS   # Restore original IFS
	
	#EMULATOR_ARRAY=(${EMULATOR_LIST// / })
	
	
	
	EMULATOR_NBR="${#EMULATOR_ARRAY[*]}"

	echo -e "AVD nbre found ${GREEN}$EMULATOR_NBR${NC}."
	if [[ "$EMULATOR_NBR" == "1" ]]; then
		echo -e "${GREEN}Launching $avd_name${NC}."
		start emulator -avd $avd_name -writable-system -no-boot-anim
	else
		echo ""
		echo ""
		echo -e "There is more than 1 AVD, please choose one ${CYAN}without Google Play${NC} (to be able to have ${CYAN}ROOT${NC} access)."

# Fixme : There is a bug here : I have 4 AVD, the last 2 are displayed, but all numbers from 1-4 are working well :/		
#		echo "${EMULATOR_ARRAY[*]}"
#		echo "${EMULATOR_ARRAY[0]}"
#		echo "${EMULATOR_ARRAY[1]}"
#		echo "${EMULATOR_ARRAY[2]}"
#		echo "${EMULATOR_ARRAY[3]}"
		
		EMULATOR_ARRAY_NEW="" 
		PS3="Choose the AVD to start: "

		select avd in "${EMULATOR_ARRAY[@]}"; do
			echo ""
			echo -e "${GREEN} Launching $avd${NC}."
			emulator -avd $avd -writable-system -no-boot-anim > null 2>null &
			break
		done

		echo "Waiting for the AVD to launch ..."
		echo "If another screen has been open => just wait."
		echo "If nothing happend, there might be a problem opening the emulator using cmd => Please open it manually using AVD Tools, in Android Studio for example."
		adb wait-for-local-device
		#FIXME: wait for the device to really start
		sleep 30
		echo "OK"
		DEVICE_TO_USE=""
	fi
elif [[ "$DEVICES_NBR" == "1" ]]; then
	DEVICE_TO_USE=${DEVICES_ARRAY[0]}
else
	echo -e "${GREEN}There is $DEVICES_NBR devices connected. Please select the one (ROOTED/ROOTABLE) to use${NC}."
	select CURRENT_DEVICE in "${DEVICES_ARRAY[@]}"; do
		DEVICE_TO_USE=$CURRENT_DEVICE
		break
	done
fi

echo -e "Device to use : ${CYAN}$DEVICE_TO_USE${NC}."

echo "Check the root method we can use (adb root, or su command)."


CURRENT_USER=`adb -s $DEVICE_TO_USE shell whoami`
if [ $CURRENT_USER != "root" ]
then
	echo -e "Script need ROOT access."
	echo -e "Current user is: ${CYAN}$CURRENT_USER.${NC}"
	echo -e "Trying to restart ADB using root."

	ROOT_RESULT=`adb -s $DEVICE_TO_USE root`
	
	echo -e "Wait a bit."
	sleep 3
	
	if [ "$ROOT_RESULT" != "adbd cannot run as root in production builds" ]
	then
		CURRENT_USER=`adb -s $DEVICE_TO_USE shell whoami`
		echo -e "Current user is: ${CYAN}$CURRENT_USER.${NC}"
		if [ $CURRENT_USER == "root" ]
		then
			ADB_ROOT_METHOD=true
			echo -e "${GREEN}Root OK, continue.${NC}"
		else
			echo -e "${RED}Root fail.${NC}"
			echo -e "${RED}Current user is: $CURRENT_USER.${NC}"
			exit 20
		fi
	else
		CURRENT_USER=`adb -s $DEVICE_TO_USE shell su -c whoami`
		echo -e "Current user is: ${CYAN}$CURRENT_USER.${NC}"
		if [ $CURRENT_USER == "root" ]
		then
			# Use the sudo method
			ADB_ROOT_METHOD=false
			echo -e "${GREEN}Root device OK, continue.${NC}"
		else
			echo -e "${RED}ERROR launching root using adb. Please check :${NC}"
			echo -e "${RED} - If it's an AVD, then it must be an image WITHOUT google play services${NC}."
			echo -e "${RED} - If it's an real device, then it must be a rooted device${NC}."
			# Source : https://frida.re/docs/android/
			echo -e "${CYAN}You may try with prefix, for example :${NC}."
			echo -e "${PURPLE}adb shell \"su -c chmod 755 /data/local/tmp/frida-server\"${NC}."
			exit 21
		fi
	fi
else
	ADB_ROOT_METHOD=true
	echo -e "${GREEN}Current user is ROOT, lets continue.${NC}"
fi


echo -e "${PURPLE}#############################################${NC}"
echo -e "${PURPLE}# Install frida on Android Device if needed #${NC}"
echo -e "${PURPLE}#############################################${NC}"

echo "Check that frida is on the phone"

IS_FRIDA_INSTALLED=`adb -s $DEVICE_TO_USE shell "ls /data/local/tmp/frida-server 2>/dev/null" | wc -l`

if [[ "$IS_FRIDA_INSTALLED" == "1" ]]; then
	echo -e "${GREEN}frida-server is already installed.${NC}"
	
	FRIDA_SERVER_VERSION=`adb -s $DEVICE_TO_USE shell "data/local/tmp/frida-server --version"`
	
	echo -e "Frida client version : ${CYAN}$FRIDA_CLIENT_VERSION${NC}"
	echo -e "Frida server version : ${CYAN}$FRIDA_SERVER_VERSION${NC}"
	if [[ "$FRIDA_CLIENT_VERSION" != "$FRIDA_SERVER_VERSION" ]]; then
		echo -e "${YELLOW}!!! WARNING : versions of client and server mismatch !!!${NC}";
		echo -e "${YELLOW}!!! To upgrade the server version (on the phone), delete the file on the device an restart this script : adb shell rm data/local/tmp/frida-server ${NC}";
		echo -e "${YELLOW}!!! To upgrade the client version (on the computer), use : pip install --upgrade frida ${NC}";
	fi
	
	IS_FRIDA_RUNNING=`adb -s $DEVICE_TO_USE shell "ps" | grep "frida-server" | wc -l`
	if [[ "$IS_FRIDA_RUNNING" == "0" ]]; then
		# NEED ROOT, but already checked previously
		# adb root
		
		echo "Check that Frida has the correct rights to be launched"
		FRIDA_SERVER_RIGHTS=`adb -s $DEVICE_TO_USE shell "ls -lsa data/local/tmp/frida-server" | cut -d' ' -f2`
		if [[ "$FRIDA_SERVER_RIGHTS" != "-rwxr-xr-x" ]]; then
			echo "Starting frida ..."
			echo -e "${YELLOW}frida has not the good rights, lets fixit.${NC}"
			
			if [[ "$ADB_ROOT_METHOD" == true ]]; then
				adb -s $DEVICE_TO_USE shell "chmod 755 /data/local/tmp/frida-server"
			else
				adb -s $DEVICE_TO_USE shell "su -c chmod 755 /data/local/tmp/frida-server"
			fi
		fi
		
		# FIXME : this line is not returning
		echo "Starting frida ..."
		if [[ "$ADB_ROOT_METHOD" == true ]]; then
			adb -s $DEVICE_TO_USE shell "data/local/tmp/frida-server &" &
		else
			adb -s $DEVICE_TO_USE shell "su -c data/local/tmp/frida-server &" &
		fi
		
		#Check that frida-server has been started
		IS_FRIDA_STARTED=`adb -s $DEVICE_TO_USE shell "ps" | grep "frida-server" | wc -l`
		if [[ "$IS_FRIDA_STARTED" == "0" ]]; then
			echo -e "${RED}Frida-server fail to be started, check the errors.${NC}"
			exit 30
		fi
	else
		echo -e "${GREEN}Frida-server is already runnig.${NC}"
		
		#If frida has been started with shell user, then thefollowingerrorwill occurs:
		#frida error Failed to spawn: unable to find process with name 'system_server'
		# TODO : use command : adb shell "ps" | grep "frida-server"
		# Then check that the user running the server is root, else, kill frida server then restart it.
	fi
else 

	echo "Frida-server not found on the device => Install frida-server."
	
	echo -e "Get last Frida version name from ${CYAN}https://github.com/frida/frida/tags${NC}."
	curl -sS -o frida_tags.html https://github.com/frida/frida/tags
	RELEASE_VERSION=`cat frida_tags.html | grep "/frida/frida/releases/tag/" | head -1 | sed 's#.*primary Link\">\(.*\)</a></h2>.*#\1#g'`
	#       <h2 data-view-component="true" class="f4 d-inline"><a href="/frida/frida/releases/tag/16.0.2" data-view-component="true" class="Link--primary">16.0.2</a></h2>
	#Result or newer version of course
	#RELEASE_VERSION=16.0.2
	rm frida_tags.html


	echo -e "Look for the ${CYAN}$RELEASE_VERSION${NC} release (last one) of Frida server for Android emulator."	
	curl -sS -o frida_release.html https://github.com/frida/frida/releases/expanded_assets/$RELEASE_VERSION
	
	# Check which version to use.
	CURRENT_DEVICE_ARCHITECTURE=`adb -s $DEVICE_TO_USE shell "uname -m"`
	
	FRIDA_SERVER_VERSION=""
	if [[ "$CURRENT_DEVICE_ARCHITECTURE" == "armv7l" ]]; then
		echo -e "Device architecture is ${CYAN}ARM in 32 bits.${NC}"
		FRIDA_SERVER_VERSION="arm"
	elif [[ "$CURRENT_DEVICE_ARCHITECTURE" == "armv8l" ]]; then
		echo -e "Device architecture is ${CYAN}ARM in 64 bits.${NC}"
		FRIDA_SERVER_VERSION="arm64"
	elif [[ "$CURRENT_DEVICE_ARCHITECTURE" == "aarch64" ]]; then
		echo -e "Device architecture is ${CYAN}ARM in 64 bits.${NC}"
		FRIDA_SERVER_VERSION="arm64"
	elif [[ "$CURRENT_DEVICE_ARCHITECTURE" == "i686" ]]; then
		echo -e "Device architecture is ${CYAN}X86 in 32 bits.${NC}"
		FRIDA_SERVER_VERSION="x86"
	elif [[ "$CURRENT_DEVICE_ARCHITECTURE" == "x86_64" ]]; then
		echo -e "Device architecture is ${CYAN}X86 in 64 bits.${NC}"
		FRIDA_SERVER_VERSION="x86_64"
	else
		echo -e "${RED}Architecture not supported : $CURRENT_DEVICE_ARCHITECTURE.${NC}"
		exit 100
	fi
	

	# Look for something like /frida/releases/download/16.0.2/frida-server-16.0.2-android-x86_64.xz
	URL_TO_USE=$(cat frida_release.html | grep frida-server | grep android-${FRIDA_SERVER_VERSION}.xz | grep href | head -n 1 | sed -n 's/.*href="\(.*\)" rel.*/\1/p')
	rm frida_release.html

	echo "Get: ${CYAN}https://github.com$URL_TO_USE${NC}"
	curl -L -o frida-server.xz https://github.com$URL_TO_USE

	echo "Unzip the downloaded file."
	case $OS in
		LINUX)
			unxz 'frida-server.xz'
			;;
		WINDOWS)
			/c/Program\ Files/7-Zip/7z.exe x -y 'frida-server.xz'
			;;
		*)
			echo -e "${RED}Can't decompress frida file: OS type ($OS) not recognized or not supported (yet), check detect_os method to detect your OS.${NC}"
			exit
			;;
	esac

	
	echo "Clean the file."
	rm 'frida-server.xz'

	#TODO : check root
	#adb root
	echo "Push frida server to the device"
	adb -s $DEVICE_TO_USE push frida-server data/local/tmp/
	
	if [ $? -ne 0 ]
	then
		echo "Push frida server to the device (alternative way)."
		adb -s $DEVICE_TO_USE push frida-server sdcard/Download/
		adb shell mv sdcard/Download/frida-server data/local/tmp
	fi

	if [[ "$ADB_ROOT_METHOD" == true ]]; then
		echo "Change rights to be able to run it."
		adb -s $DEVICE_TO_USE shell "chmod 755 /data/local/tmp/frida-server"
		echo "Run the server."
		adb -s $DEVICE_TO_USE shell "data/local/tmp/frida-server &" &
	else
		echo "Change rights to be able to run it."
		adb -s $DEVICE_TO_USE shell "su -c chmod 755 /data/local/tmp/frida-server"
		echo "Run the server."
		adb -s $DEVICE_TO_USE shell "su -c data/local/tmp/frida-server &" &
	fi
	
	echo "Clean temp file."
	rm 'frida-server'
	
	#Check that frida-server has been started
	IS_FRIDA_STARTED=`adb -s $DEVICE_TO_USE shell "ps" | grep "frida-server" | wc -l`
	if [[ "$IS_FRIDA_STARTED" == "0" ]]; then
		echo -e "${RED}Frida-server fail to be started, check the errors.${NC}"
		exit 40
	fi
fi


#############
# Run frida #
#############

# List all the 3 rd party applications, and remove the "package:" prefix
INSTALLED_APPS_LIST=( $(adb -s $DEVICE_TO_USE shell "pm list packages -3" | sed -n 's/package:\(.*\)/\1/p') )

# Sort the list
# Source : https://stackoverflow.com/questions/7442417/how-to-sort-an-array-in-bash
IFS=$'\n' INSTALLED_APPS_LIST=($(sort <<<"${INSTALLED_APPS_LIST[*]}")); unset IFS

if [[ "${#INSTALLED_APPS_LIST[@]}" == "0" ]]; then
	echo -e "${RED}WARNING: no 3rd party applications installed, please install at least one and start again this script.${NC}"
	exit
elif [[ "${#INSTALLED_APPS_LIST[@]}" == "1" ]]; then
	TARGET_APPLICATION=${INSTALLED_APPS_LIST[0]}
	echo -e "There is only one third party application installed, so use it: ${CYAN}$TARGET_APPLICATION${NC}."
else
	INSTALLED_APPS_LIST+=("Enter the package manually")
	INSTALLED_APPS_LIST+=("Select all packages")
	echo ""
	echo ""
	PS3="Choose the application to instrument with frida: "

	select application in "${INSTALLED_APPS_LIST[@]}"; do
	  TARGET_APPLICATION=$application
	  break
	done
fi

echo "DEBUG: $TARGET_APPLICATION"

if [[ "$TARGET_APPLICATION" == "Enter the package manually" ]]; then
	echo "${CYAN}Enter the package name to work on: >${NC}"
	read TARGET_APPLICATION
fi
if [[ "$TARGET_APPLICATION" == "Select all packages" ]]; then
	INSTALLED_APPS_LIST=( $(adb -s $DEVICE_TO_USE shell "pm list packages" | sed -n 's/package:\(.*\)/\1/p') )
	# Sort the list
	IFS=$'\n' INSTALLED_APPS_LIST=($(sort <<<"${INSTALLED_APPS_LIST[*]}")); unset IFS
	
	echo ""
	echo ""
	PS3="Choose the application to instrument with frida: "

	select application in "${INSTALLED_APPS_LIST[@]}"; do
	  TARGET_APPLICATION=$application
	  break
	done
fi


#https://codeshare.frida.re/browse
declare -A FRIDA_ACTION_LIST=(
	["Local script"]=""
	["SSL_frida-multiple-unpinning"]="akabe1/frida-multiple-unpinning"
	["SSL_Universal_Android_SSL_Pinning_Bypass_with_Frida"]="pcipolloni/universal-android-ssl-pinning-bypass-with-frida"
	["SharedPreferences"]="ninjadiary/frinja---sharedpreferences"
	["Android_Location_Spoofing"]="dzervas/android-location-spoofing"
	["SQLite_Database"]="ninjadiary/sqlite-database"
	["Bypass_Wi-Fi_check"]="zionspike/bypass-wi-fi-check-on-android"
	["Sockets"]="ninjadiary/frinja---sockets"
	["Android_Broadcast_Receiver"]="leolashkevych/android-broadcast-receiver"
	["EncryptedSharedPreferences"]="Alkeraithe/encryptedsharedpreferences"
	["Crypto_Intercept_Android_APK_Crypto_Operations"]="fadeevab/intercept-android-apk-crypto-operations"
	["AntiROOT_Multiple-root-detection-bypass"]="KishorBal/multiple-root-detection-bypass"
	["AntiROOT_Fridaantiroot"]="khoomelvin/fridaantiroot"
	["AntiROOT_anti-root"]="Surendrajat/anti-root"
	["AntiROOT_HideRoot"]="apkunpacker/hideroot"
	["AntiROOT_fridantiroot"]="dzonerzy/fridantiroot"
	["anti-frida-bypass"]="enovella/anti-frida-bypass"
	["DynamicHooks"]="realgam3/dynamichooks"
)

echo ""
echo ""
echo "Other frida scripts can be found: https://codeshare.frida.re/browse"
PS3="Choose the frida script to use: "

select action in "${!FRIDA_ACTION_LIST[@]}"; do
  FRIDA_ACTION=$action
  break
done

echo -e "Selected action : ${CYAN}$FRIDA_ACTION${NC}"

FRIDA_ACTION_TO_USE=${FRIDA_ACTION_LIST[$FRIDA_ACTION]}

#echo -e "Selected action : ${CYAN}$FRIDA_ACTION_TO_USE${NC}"

FRIDA_PARAMETER=""

# If the action is empty, then choose a script
if [ "$FRIDA_ACTION" = "Local script" ] ; then
	echo "Select local file:"
	read -p 'Frida script full path> ' FRIDA_SCRIPT
	FRIDA_PARAMETER="-l $FRIDA_SCRIPT"
else
	FRIDA_PARAMETER="--codeshare $FRIDA_ACTION_TO_USE"
fi


ACTIVATE_PROXY=false
while true; do
  echo -e "${CYAN}Do you want to activate proxy (with ssl pinning scripts) (y/n) ?${NC}"
  read -p "> " -n 1 yn
  echo ""
  case $yn in
	  [Yy]* ) ACTIVATE_PROXY=true; break;;
	  [Nn]* ) break;;
	  * ) echo -e "${YELLOW}Please answer y for yes or n for no.${NC}";;
  esac
done

if [ "$ACTIVATE_PROXY" = true ] ; then
	echo "Activate proxy."

	case $OS in
		LINUX)
			#ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'
			LOCAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
			;;
		WINDOWS)
			LOCAL_IP=$(ipconfig | grep 'IPv4 Address' | grep -v "Autoconfiguration" | grep -Eo '([0-9]*\.){3}[0-9]*')
			;;
		*)
			echo -e "${RED}Can't find proxy IP: OS type ($OS) not recognized or not supported (yet), check detect_os method to detect your OS.${NC}"
			exit
			;;
	esac

	echo -e "Set proxy on android device to: ${CYAN}$LOCAL_IP:8080${NC} with the following command:"
	echo adb -s $DEVICE_TO_USE shell settings put global http_proxy $LOCAL_IP:8080
	adb -s $DEVICE_TO_USE shell settings put global http_proxy $LOCAL_IP:8080
	
	echo -e "Launch an HTTP proxy on your computer, for example ${CYAN}Burp Suite${NC}."
	echo -e "Menu Proxy, then Proxy settings"
	echo -e "Proxy listeners"
	echo -e "Remove the actual 127.0.0.1:8080 listener."
	echo -e "Add new one : Bind to port: 8080"
	echo -e "Bind to address: All interfaces"
	echo -e "Open the HTTP History tab"
fi

#echo "FRIDA_ACTION_TO_USE = $FRIDA_ACTION_TO_USE"
echo -e "Command launched: ${CYAN}frida -D $DEVICE_TO_USE $FRIDA_PARAMETER -f $TARGET_APPLICATION${NC}"

echo -e "${MAGENTA}To exit, enter command : q${NC}"
if [ $(version $FRIDA_CLIENT_VERSION) -ge $(version "15.2.0") ] ; then
	frida -D $DEVICE_TO_USE $FRIDA_PARAMETER -f $TARGET_APPLICATION
else
	frida --no-pause -D $DEVICE_TO_USE $FRIDA_PARAMETER -f $TARGET_APPLICATION
fi

if [ "$ACTIVATE_PROXY" = true ] ; then
	echo "Remove proxy."
	adb -s $DEVICE_TO_USE shell settings put global http_proxy :0	
fi
