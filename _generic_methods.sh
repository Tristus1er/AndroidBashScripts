#!/bin/bash

#* This script contain generic functions used by other scripts.


#Reference for colors : https://misc.flogisoft.com/bash/tip_colors_and_formatting

# IHM

GREEN='\e[92m'
RED='\e[91m'
YELLOW='\e[93m'
PURPLE='\e[95m'
CYAN='\e[96m'
NC='\e[0m'

# Repeat given char n times
repeat(){
# TODO Check parameters
#Use for method with parameter : source : https://stackoverflow.com/questions/5691098/using-command-line-argument-range-in-bash-for-loop-prints-brackets-containing-th
	for i in $(eval echo {1..$2}); do echo -n "$1"; done
}

# Display title
display_title(){
	TITLE_LENGTH=`echo $1 | wc -c`

  echo -e "${NC}"
  
	# Header	
	echo -n -e "${PURPLE}"
	repeat '#' $TITLE_LENGTH
	repeat '#' 3 # The '# ' before the title, and the ' #' after it, minus 1.
	echo -e "${NC}"

	# Title
	echo -n -e "${PURPLE}# "
	echo -n "$1"
	echo -e " #${NC}"
	
	# Footer
	echo -n -e "${PURPLE}"
	repeat '#' $TITLE_LENGTH
	repeat '#' 3
	echo -e "${NC}${NC}"
}

# Display separator
display_separator(){
  TITLE_LENGTH=`echo $1 | wc -c`
  SEPARATOR_LENGTH=$(((60-$TITLE_LENGTH)/2))
	echo -e "${NC}"
	echo -n -e "${PURPLE}"
  repeat '=' $SEPARATOR_LENGTH
  echo -n -e " $1 "
	echo -n -e "${PURPLE}"
  repeat '=' $SEPARATOR_LENGTH
	echo -e "${NC}"
}

version() { 
  echo "$@" | awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }'; 
}

#* 
#* ### detect_os
#* Based on different methods, try to get the OS type we are running on.
detect_os () {
case "$OSTYPE" in
  solaris*) OS='SOLARIS' ;;
  darwin*)  OS='OSX' ;; 
  linux*)   OS='LINUX' ;;
  bsd*)     OS='BSD' ;;
  msys*)    OS='WINDOWS' ;;
  *)        detect_os_uname ;;
esac
}


#* 
#* ### detect_os_uname
#* Used by detect_os when the first method fail, to detect the OS.
detect_os_uname () {
unameOut="`uname`"
case $unameOut in
  'Linux')
    OS='LINUX'
    ;;
  'FreeBSD')
    OS='LINUX'
    ;;
  'WindowsNT')
    OS='WINDOWS'
    ;;
  'Darwin') 
    OS='OSX'
    ;;
  'SunOS')
    OS='SOLARIS'
    ;;
	'CYGWIN')
    OS='WINDOWS'
    ;;
	'MINGW')
    OS='WINDOWS'
    ;;
  'AIX')
	OS='AIX'
	;;
  *) OS='unknown: $OSTYPE';;
esac
}

#* 
#* ### wait_for_device
#* Wait for any Android device to be connected.
wait_for_device () {
	echo -e "${CYAN}Waiting for device online.${NC}"
	adb wait-for-device
	echo -e "${GREEN}Device found.${NC}"
}

#* 
#* ### pushd and popd
#* Avoid displaying stack when using popd and pushd
# https://stackoverflow.com/questions/25288194/dont-display-pushd-popd-stack-across-several-bash-scripts-quiet-pushd-popd
pushd () {
    command pushd "$@" > /dev/null
}

popd () {
    command popd "$@" > /dev/null
}

#* 
#* ### check_java
#* Check that Java is available.
# Origin : https://stackoverflow.com/questions/7334754/correct-way-to-check-java-version-from-bash-script
check_java () {
	display_separator "Check ${CYAN}java${NC}."
	if type -p java; then
		echo -e "${GREEN}Found java executable in PATH.${NC}"
		_java=java
	elif [[ -n "$JAVA_HOME" ]] && [[ -x "$JAVA_HOME/bin/java" ]];  then
		echo found java executable in JAVA_HOME     
		_java="$JAVA_HOME/bin/java"
	else
	  echo -e "${RED}/!\ No java.${NC}"
		return 1
	fi

	if [[ "$_java" ]]; then
		version=$("$_java" -version 2>&1 | awk -F '"' '/version/ {print $2}')
		echo -e "${CYAN}Using Java version $version.${NC}"
	fi
	return 0
}

#* 
#* ### check_adb
#* Check that ADB is available.
check_adb () {
	display_separator "Check ${CYAN}ADB${NC}."
  if ! command -v adb &> /dev/null
    then
      echo -e "${YELLOW}ADB could not be found => Please, install it (Android SDK), and add it to PATH.${NC}"
      echo -e "${YELLOW}ADB is located in ANDROID_SDK/platform-tools.${NC}"
      echo -e "${RED}/!\ ADB is missing, please install it to continue.${NC}"
      return 1
  fi
  adb version
  return 0
}

#* 
#* ### 
#* Check that zipalign is available.
check_zipalign () {
	display_separator "Check ${CYAN}zipalign${NC}."
  if ! command -v zipalign &> /dev/null
    then
      echo -e "${YELLOW}zipalign could not be found => Please, install it (Android SDK), and add it to PATH.${NC}"
      echo -e "${YELLOW}zipalign is located in ANDROID_SDK/build-tools/28.0.3${NC}"
      echo -e "${YELLOW}PLEASE DEFINE : variable ANDROID_BUILD_TOOLS as %ANDROID_SDK%\build-tools\28.0.3${NC}"
      echo -e "${YELLOW}PLEASE DEFINE : variable ANDROID_SDK as (exemple) C:\Users\USER_NAME\AppData\Local\Android\Sdk${NC}"
      echo -e "${YELLOW}PLEASE ADD both to PATH${NC}"
      echo -e "${RED}/!\ zipalign is missing, please install it to continue.${NC}"
      return 1
  fi
  return 0
}

#* 
#* ### check_aapt
#* Check that aapt is available.
check_aapt () {
	display_separator "Check ${CYAN}aapt${NC}."
  if ! command -v aapt &> /dev/null
    then
      echo -e "${YELLOW}aapt could not be found => Please, install it (Android SDK), and add it to PATH.${NC}"
      echo -e "${YELLOW}aapt is located in ANDROID_SDK/build-tools/28.0.3${NC}"
      echo -e "${YELLOW}PLEASE DEFINE : variable ANDROID_BUILD_TOOLS as %ANDROID_SDK%\build-tools\28.0.3${NC}"
      echo -e "${YELLOW}PLEASE DEFINE : variable ANDROID_SDK as (exemple) C:\Users\USER_NAME\AppData\Local\Android\Sdk${NC}"
      echo -e "${YELLOW}PLEASE ADD both to PATH${NC}"
      echo -e "${RED}/!\ aapt is missing, please install it to continue.${NC}"
      echo -e "${YELLOW}${NC}"
      return 1
  fi
  aapt v
  return 0
}

#* 
#* ### check_certutil
#* Check that certutil is available.
check_certutil () {
	display_separator "Check ${CYAN}certutil${NC}."
  if ! command -v certutil &> /dev/null
    then
      echo -e "${RED}/!\ certutil could not be found, it should be available under windows.${NC}"
      return 1
  fi
  return 0
}

#* 
#* ### check_jarsigner
#* Check that jarsigner is available.
check_jarsigner () {
	display_separator "Check ${CYAN}jarsigner${NC}."
  if ! command -v jarsigner &> /dev/null
    then
      echo -e "${RED}/!\ jarsigner could not be found, it should be available under windows.${NC}"
      return 1
  fi
  return 0
}

#* 
#* ### check_emulator
#* Check that emulator is available.
check_emulator () {
	display_separator "Check ${CYAN}emulator${NC}."
  if ! command -v emulator &> /dev/null
    then
      echo -e "${YELLOW}emulator could not be found => Please, install it (Android SDK), and add it to PATH.${NC}"
      echo -e "${YELLOW}emulator is located in ANDROID_SDK/emulator${NC}"
      echo -e "${YELLOW}PLEASE DEFINE : variable ANDROID_EMULATOR as %ANDROID_SDK%\emulator${NC}"
      echo -e "${YELLOW}PLEASE DEFINE : variable ANDROID_SDK as (exemple) C:\Users\$USERNAME\AppData\Local\Android\Sdk${NC}"
      echo -e "${YELLOW}PLEASE ADD both to PATH${NC}"
      echo -e "${RED}/!\ emulator is missing (not mandatory), please install it to continue if you don't use a phone.${NC}"
      return 1
  fi
  return 0
}

#* 
#* ### check_keytool
#* Check that keytool is available.
check_keytool () {
	display_separator "Check ${CYAN}keytool${NC}."
  if ! command -v keytool &> /dev/null
    then
      echo -e "${YELLOW}keytool could not be found => Please, check your JDK installation.${NC}"
      echo -e "${RED}/!\ keytool is missing, please install it to continue.${NC}"
      return 1
  fi
  return 0
}

#* 
#* ### check_telnet
#* Check that telnet is available (For Windows).
check_telnet () {
  if ! command -v telnet &> /dev/null
    then
      echo -e "${YELLOW}telnet could not be found.${NC}"
      echo -e "${YELLOW}Lancer : Panneau de configuration.${NC}"
      echo -e "${YELLOW}Activer ou désactiver des fonctionalités Windows.${NC}"
      echo -e "${YELLOW}TU AS OUBLIER DE PASSER ADMIN !!!.${NC}"
      echo -e "${YELLOW}Cocher : Client Telnet.${NC}"
      echo -e "${RED}/!\ telnet is missing, please install it to continue.${NC}"
      return 1
  fi
  return 0
}

#* 
#* ### check_unxz
#* Check that unxz is available (For Linux).
check_unxz () {
  if ! command -v unxz &> /dev/null
    then
      echo -e "${YELLOW}unxz could not be found.${NC}"
      echo -e "${YELLOW}Lancer : sudo apt-get install xz-utils.${NC}"
      echo -e "${RED}/!\ unxz is missing, please install it to continue.${NC}"
      return 1
  fi
  return 0
}

#* 
#* ### check_7z
#* Check that 7z is available (For Windows).
check_7z () {
  if ! command -v 7z &> /dev/null
    then
      echo -e "${YELLOW}7z could not be found.${NC}"
      echo -e "${YELLOW}Télécharger et installer 7z : https://www.7-zip.org/download.html ${NC}"
      echo -e "${RED}/!\ 7z is missing, please install it to continue.${NC}"
      return 1
  fi
  return 0
}

##########
# Python #
##########

#* 
#* ### check_python
#* Check that python is available (For Windows/Linux).
check_python () {
	display_separator "Check ${CYAN}python 3${NC}."
  if ! command -v python3 &> /dev/null
    then
      echo -e "${YELLOW}python could not be found => Please, install it, and add it to PATH.${NC}"
      echo -e "${YELLOW}You can found python at: https://www.python.org/downloads/windows/ .${NC}"
      echo -e "${RED}/!\ python is missing, please install it to continue.${NC}"
      return 1
  fi
  if ! python3 --version
  then
		echo ""
		echo -e "${RED}/!\ Python found, but not running${NC}"
		return 1
	fi
  return 0
}

#* 
#* ### check_pip
#* Check that pip is available (For Windows/Linux).
check_pip () {
	display_separator "Check ${CYAN}pip${NC}."
  if ! command -v pip &> /dev/null
    then
      echo -e "${YELLOW}pip could not be found => Please, install it, and add it to PATH.${NC}"
      echo -e "${YELLOW}curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py${NC}"
      echo -e "${YELLOW}python get-pip.py${NC}"
      echo -e "${RED}/!\ pip is missing, please install it to continue.${NC}"
      return 1
  fi
  echo "pip version"
  pip --version
  return 0
}

#* 
#* ### check_pipx
#* Check that pipx is available (For Windows/Linux).
check_pipx () {
	display_separator "Check ${CYAN}pipx${NC}."
  if ! command -v pipx &> /dev/null
    then
      check_pip
      echo -e "${YELLOW}pipx could not be found => Please, install it, and add it to PATH (with ensurepath command).${NC}"
      echo -e "${YELLOW}https://github.com/pypa/pipx${NC}"
      echo -e "${RED}/!\ pipx is missing, please install it to continue.${NC}"
      return 1
  fi
  echo "pipx version"
  pipx --version
  return 0
}

#* 
#* ### check_frida
#* Check that frida is available (For Windows/Linux).
check_frida () {
	display_separator "Check ${CYAN}frida${NC}."
  if ! command -v frida &> /dev/null
    then
      echo -e "${YELLOW}frida could not be found => Please, install it with pipx, and add it to PATH.${NC}"
      echo -e "${YELLOW}pipx install frida-tools${NC}"
      echo -e "${RED}/!\ frida is missing, please install it to continue.${NC}"
      return 1
  fi
  echo "Frida version"
  frida --version
  return 0
}