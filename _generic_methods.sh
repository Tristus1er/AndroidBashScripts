#!/bin/bash

#* Ce script contient des fonctions utilisées dans d'autres scripts, pour factoriser le code.


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
	echo -e "${NC}"
}


#* 
#* ### detect_os
#* Based ondifferent methods, try to get the OS type we are running on.
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
	echo -e "Check ${CYAN}java${NC}."
	if type -p java; then
		echo -e "${GREEN}Found java executable in PATH.${NC}"
		_java=java
	elif [[ -n "$JAVA_HOME" ]] && [[ -x "$JAVA_HOME/bin/java" ]];  then
		echo found java executable in JAVA_HOME     
		_java="$JAVA_HOME/bin/java"
	else
	  echo -e "${RED}No java.${NC}"
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
	echo -e "Check ${CYAN}ADB${NC}."
  if ! command -v adb &> /dev/null
    then
      echo -e "${YELLOW}ADB could not be found => Please, install it (Android SDK), and add it to PATH.${NC}"
      echo -e "${YELLOW}ADB is located in ANDROID_SDK/platform-tools.${NC}"
      return 1
  fi
  adb version
  return 0
}

#* 
#* ### 
#* Check that zipalign is available.
check_zipalign () {
	echo -e "Check ${CYAN}zipalign${NC}."
  if ! command -v zipalign &> /dev/null
    then
      echo -e "${YELLOW}zipalign could not be found => Please, install it (Android SDK), and add it to PATH.${NC}"
      echo -e "${YELLOW}zipalign is located in ANDROID_SDK/build-tools/28.0.3${NC}"
      echo -e "${YELLOW}PLEASE DEFINE : variable ANDROID_BUILD_TOOLS as %ANDROID_SDK%\build-tools\28.0.3${NC}"
      echo -e "${YELLOW}PLEASE DEFINE : variable ANDROID_SDK as (exemple) C:\Users\USER_NAME\AppData\Local\Android\Sdk${NC}"
      echo -e "${YELLOW}PLEASE ADD both to PATH${NC}"
      return 1
  fi
  return 0
}

#* 
#* ### check_aapt
#* Check that aapt is available.
check_aapt () {
	echo -e "Check ${CYAN}aapt${NC}."
  if ! command -v aapt &> /dev/null
    then
      echo -e "${YELLOW}aapt could not be found => Please, install it (Android SDK), and add it to PATH.${NC}"
      echo -e "${YELLOW}aapt is located in ANDROID_SDK/build-tools/28.0.3${NC}"
      echo -e "${YELLOW}PLEASE DEFINE : variable ANDROID_BUILD_TOOLS as %ANDROID_SDK%\build-tools\28.0.3${NC}"
      echo -e "${YELLOW}PLEASE DEFINE : variable ANDROID_SDK as (exemple) C:\Users\USER_NAME\AppData\Local\Android\Sdk${NC}"
      echo -e "${YELLOW}PLEASE ADD both to PATH${NC}"
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
	echo -e "Check ${CYAN}certutil${NC}."
  if ! command -v certutil &> /dev/null
    then
      echo -e "${RED}certutil could not be found, it should be available under windows.${NC}"
      return 1
  fi
  return 0
}

#* 
#* ### check_jarsigner
#* Check that jarsigner is available.
check_jarsigner () {
	echo -e "Check ${CYAN}jarsigner${NC}."
  if ! command -v jarsigner &> /dev/null
    then
      echo -e "${RED}jarsigner could not be found, it should be available under windows.${NC}"
      return 1
  fi
  return 0
}

#* 
#* ### check_emulator
#* Check that emulator is available.
check_emulator () {
	echo -e "Check ${CYAN}emulator${NC}."
  if ! command -v emulator &> /dev/null
    then
      echo -e "${YELLOW}emulator could not be found => Please, install it (Android SDK), and add it to PATH.${NC}"
      echo -e "${YELLOW}emulator is located in ANDROID_SDK/emulator${NC}"
      echo -e "${YELLOW}PLEASE DEFINE : variable ANDROID_EMULATOR as %ANDROID_SDK%\emulator${NC}"
      echo -e "${YELLOW}PLEASE DEFINE : variable ANDROID_SDK as (exemple) C:\Users\$USERNAME\AppData\Local\Android\Sdk${NC}"
      echo -e "${YELLOW}PLEASE ADD both to PATH${NC}"
      echo -e "${YELLOW}${NC}"
      return 1
  fi
  return 0
}

#* 
#* ### check_keytool
#* Check that keytool is available.
check_keytool () {
	echo -e "Check ${CYAN}keytool${NC}."
  if ! command -v keytool &> /dev/null
    then
      echo -e "${YELLOW}keytool could not be found => Please, check your JDK installation.${NC}"
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
      return 1
  fi
  return 0
}

#* 
#* ### getScript
#* Download a file (in our case: a script).
#* @param The name of the file to store
#* @param The URL of the file to download
getScript() {
  echo -e "${CYAN}Get $1${NC}"
	  curl.exe -sS -o $1 $2
	  # Gitlabversion curl -sS -L -k --request GET --header "PRIVATE-TOKEN: $GITLAB_API_TOKEN" -o $1 $2

	  if test -f "./$1"; then
		echo -e "${GREEN}./$1 downloaded.${NC}"
	  else
	  	echo -e "${RED}./$1 script is missing, and is mandatory.${NC}"
		exit 1
  fi
}

#* 
#* ### getScriptIfNeeded
# Download a file (in our case: a script), only if it do not exist (avoid replacing the actual one).
# @param The name of the file to store
# @param The URL of the file to download
getScriptIfNeeded() {
  echo "Check that $1 script is available."
  if test -f "./$1"; then
	echo -e "${YELLOW}./$1 exists NO UPDATE DONE.${NC}"
  else
	echo -e "${CYAN}Get $1${NC}"
	  curl.exe -sS -o $1 $2
	#GitLabVersion curl -sS -L -k --request GET --header "PRIVATE-TOKEN: $GITLAB_API_TOKEN" -o $1 $2
	  if test -f "./$1"; then
		echo -e "${GREEN}./$1 downloaded.${NC}"
	  else
	  	echo -e "${RED}./$1 script is missing, and is mandatory.${NC}"
		exit 1
	  fi
  fi
}

#* 
#* ### Methods to parse XML.
#########################
# Parsing RSS, HTML, ...#
#########################

#* #### xmlgetnext
#* Allow to parse XML.
function xmlgetnext () {
   local IFS='>'
   read -d '<' TAG VALUE
}

#* 
#* #### get_branch_of_job
#* Get the branch name of a job.
function get_branch_of_job() {
	curl.exe -sS -o tmp_build_page.html $1
	grep BRANCH tmp_build_page.html | sed 's@.*BRANCH=\(.*\), MODULES_PROFILE.*@\1@g'
}

#* 
#* #### get_build_number
#* Get the build number from jenkins URL.
function get_build_number() {
	# http://jenkins.sics/job/build-sicsd/1375/
	echo $1 | sed 's@http://jenkins.sics/job/.*/\([0-9]*\)/@\1@g'
}

#* 
#* #### get_status_of_job
#* Get the status of the selected job.
function get_status_of_job() {
	curl.exe -sS -o tmp_build_page.html $1
	grep "/buildTimeTrend" tmp_build_page.html | sed 's@.* alt="\(.*\)" tooltip.*@\1@g'
}

#* 
#* #### get_date_of_job
#* Get the date of the job.
function get_date_of_job() {
	curl.exe -sS -o tmp_build_page.html $1
	awk '/Build #/{getline; print}' tmp_build_page.html | sed 's@.*(\(.*\)).*@\1@g'
}

#* 
#* #### get_sics_branch_of_job
#* Get the branch name for sics.
function get_sics_branch_of_job() {
	curl.exe -sS -o tmp_build_page.html $1
	grep BRANCH tmp_build_page.html | sed 's@.*Started by timer with parameters: {SICS_BRANCH=\(.*\)}<.*@\1@g'
}

#* 
#* #### get_pims_from_job
#* Get the pims path of job.
function get_pims_from_job() {
	curl.exe -sS -o tmp_build_page.html $1
	grep "artifact/assemblies/runtime/target/bull-pims" tmp_build_page.html | sed "s@.*target/\(.*\)';.*@\1@g"
}

##########
# Python #
##########

#* 
#* ### check_python
#* Check that python is available (For Windows).
check_python () {
	echo -e "Check ${CYAN}python${NC}."
  if ! command -v python &> /dev/null
    then
      echo -e "${YELLOW}python could not be found => Please, install it, and add it to PATH.${NC}"
      echo -e "${YELLOW}You can found python at: https://www.python.org/downloads/windows/ .${NC}"
      return 1
  fi
  if ! python --version
  then
		echo ""
		echo -e "${RED}Python found, but not running${NC}"
		return 1
	fi
  return 0
}

#* 
#* ### check_pip
#* Check that pip is available (For Windows).
check_pip () {
	echo -e "Check ${CYAN}pip${NC}."
  if ! command -v pip &> /dev/null
    then
      echo -e "${YELLOW}pip could not be found => Please, install it, and add it to PATH.${NC}"
      echo -e "${YELLOW}curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py${NC}"
      echo -e "${YELLOW}python get-pip.py${NC}"
      return 1
  fi
    echo "pip version"
  pip --version
  return 0
}

#* 
#* ### check_frida
#* Check that frida is available (For Windows).
check_frida () {
	echo -e "Check ${CYAN}frida${NC}."
  if ! command -v frida &> /dev/null
    then
      echo -e "${YELLOW}frida could not be found => Please, install it, and add it to PATH.${NC}"
      return 1
  fi
  echo "Frida version"
  frida --version
  return 0
}