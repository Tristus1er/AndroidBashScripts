#!/bin/bash

#* This script calculate the hash of all the APKs located in the folder passed in parameter.
#* You can use it with the script calc_hash_device.sh that do the same, but with applications located and extracted from a device.
#*
#*
#* Example : 
#* ```sh
#* ./calc_hash_folder.sh /c/apk/
#* ```

source _generic_methods.sh
source _config_signatures.sh


# Check that the mandatory parameter (the path where the APKs are located) is there.
if [ $# -eq 0 ]
  then
    echo -e "${RED}No arguments supplied, please enter a path where your APKs are located.${NC}"
	script_name=`basename "$0"`
	echo -e "Example : ${GREEN}$script_name /c/apk/rc8${NC}"
	exit 50
fi

# Check that the mandatory parameter (the path where the APKs are located) is not empty.
if [ -z "$1" ]
  then
    echo -e "${RED}The argument supplied is empty ?!${NC}"
	echo -e "${CYAN}Please, enter a valid path.${NC}"
	exit 51
fi

# Check folder exist
if [ -d "$1" ]
then
	echo -e "${GREEN}Folder $1 found.${NC}"
else
	echo -e "${RED}Folder $1 NOT FOUND.${NC}"
	echo -e "\e[1mMaybe you can add \" before AND after your path ?${NC}."
	exit 52
fi

check_aapt
if [ $? -ne 0 ]
then
    echo -e "${RED}aapt is missing, please install it to continue.${NC}"
	exit 10
fi

check_certutil
if [ $? -ne 0 ]
then
    echo -e "${RED}certutil is missing, please install it to continue.${NC}"
	exit 11
fi

check_keytool
if [ $? -ne 0 ]
then
    echo -e "${RED}keytool is missing, please install it to continue.${NC}"
    exit 12
fi

check_jarsigner
if [ $? -ne 0 ]
then
    echo -e "${RED}jarsigner is missing, please install it to continue.${NC}"
    exit 13
fi


echo -e "${PURPLE}***********************************************${NC}"
echo -e "${PURPLE}*     CALCULATE THE HASH OF APK IN FOLDER     *${NC}"
echo -e "${PURPLE}***********************************************${NC}"


if test "$1"; then
    echo "Using $1 folder."
else
    echo "Folder $1 is missing/name is empty/...."
    exit
fi


for filename in $1/*.apk; do
    echo "----------------------------------------------------------------------------------------------------"
    echo -e "Filename : ${CYAN}$filename${NC}"
	
    PACKAGE_NAME=`aapt dump badging  $filename | grep package:\ name | sed -n 's/package: name=\x27\(.*\)\x27.*versionCode.*/\1/p'`
    echo -e "Package name : ${CYAN}$PACKAGE_NAME${NC}"
    
	# ----- HASH -----
	echo "Calculated hash :"
    echo -n -e "${CYAN}"
    certutil -hashfile $filename MD5 | sed -n '1!p' | head -n 1
    echo -n -e "${NC}"
	
	# ----- BUILD TYPE -----
    echo -n "Build type : "
    BUILD_TYPE=`aapt dump badging $filename | grep -c application-debuggable`
    if [ $BUILD_TYPE -eq 0 ]
    then
        echo -e "${GREEN}RELEASE${NC}"
    else
        echo -e "${YELLOW}DEBUG${NC}"
    fi
	
	# ----- VERSION -----
    echo -e "Version code/name :${CYAN}"
    aapt d badging $filename | grep -Po "(?<=\sversion(Code|Name)=')([0-9A-Za-z\-.]+)"
    echo -n -e "${NC}"

	# ----- SDK VERSION -----
    minSdkVersion=`eval "echo \"$(aapt list -a $filename | grep "android:minSdkVersion" | sed 's@.*=(type 0x10)0x\(.*\)$@$((16#\1))@g')\""`
    targetSdkVersion=`eval "echo \"$(aapt list -a $filename | grep "android:targetSdkVersion" | sed 's@.*=(type 0x10)0x\(.*\)$@$((16#\1))@g')\""`
	
	# Not applicable if it's a 3rd party application.
	if [ ${versionSDKExceptionArray[$PACKAGE_NAME]+_} ]; then
		minSdkVersionExpected=" NA"
	else
		minSdkVersionExpected=" ${GREEN}OK${NC}"
		if [[ "$minSdkVersion" != "26" ]]; then
			minSdkVersionExpected=" ${YELLOW}KO${NC}"	
		fi
	fi
	
	# Not applicable if it's a 3rd party application.
	if [ ${versionSDKExceptionArray[$PACKAGE_NAME]+_} ]; then
		targetSdkVersionExpected=" NA"
	else
		targetSdkVersionExpected=" ${GREEN}OK${NC}"
		if [[ "$targetSdkVersion" != "28" ]]; then
			targetSdkVersionExpected=" ${YELLOW}KO${NC}"
		fi
	fi

    echo -e "minSdkVersion    ${CYAN}$minSdkVersion${NC} $minSdkVersionExpected"
    echo -e "targetSdkVersion ${CYAN}$targetSdkVersion${NC} $targetSdkVersionExpected"

	# ----- SIGNATURE -----
	IS_AN_EXCEPTION=false
	file_to_check_name=`basename "$filename"`
	for key in "${!signatureAPKNameExceptionArray[@]}"; do
		#echo "Check $key over $file_to_check_name"
		if [[ $file_to_check_name = $key* ]]; then
			echo "Exception"
			IS_AN_EXCEPTION=true
		fi
	done

	if [[ $IS_AN_EXCEPTION = true ]]; then
		echo "Do not check signature : stub of real application."
	else
		SIGNED_BY=$(jarsigner -verify -verbose -certs $filename | grep "Signed by")
		echo -e "Signature: ${CYAN}$SIGNED_BY${NC}"
		echo -e "Expected:  ${CYAN}- Signed by \"${signatureListArray[$PACKAGE_NAME]}\"${NC}"

		if [[ "$SIGNED_BY" = "- Signed by \"${signatureListArray[$PACKAGE_NAME]}\"" ]]
			then
			echo -e "${GREEN}SIGNATURE OK${NC}"
		else
			echo -e "${RED}SIGNATURE KO${NC}"
		fi
	 
		echo -n -e "${CYAN}"
		jarsigner -verify -verbose -certs $filename | grep "The signer certificate will expire on"
		echo -n -e "${NC}"
		
		echo keytool -printcert -jarfile "$filename" | grep "SHA256 :" | sed 's/.*SHA256 : \(.*\)/\1/g'
		CERTIFICATE_HASH=$(keytool -printcert -jarfile "$filename" | grep "SHA *256 *:" | sed 's/.*SHA *256 *: \(.*\)/\1/g')
		
		echo -e "CERTIFICATE_HASH         : ${CYAN}$CERTIFICATE_HASH${NC}"	
		echo -e "CERTIFICATE_HASH Expected: ${CYAN}${certificateHashArray[$PACKAGE_NAME]}${NC}"

		if [[ "$CERTIFICATE_HASH" = "${certificateHashArray[$PACKAGE_NAME]}" ]]
			then
			echo -e "${GREEN}CERTIFICATE HASH OK${NC}"
		else
			echo -e "${RED}CERTIFICATE HASH KO${NC}"
		fi
	fi
done
