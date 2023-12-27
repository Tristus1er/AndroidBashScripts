#!/bin/bash

#* This script activate Wi-Fi, then activate ADB over Wi-Fi, extract IP address and connect to device.
#*
#*
#* Example : 
#* ```sh
#* ./activate_connect_tcp.sh
#* ./activate_connect_tcp.sh -s emulator-5556
#* ```

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


echo -e "${PURPLE}***********************************${NC}"
echo -e "${PURPLE}*     ACTIVATE TCP/WiFi DEBUG     *${NC}"
echo -e "${PURPLE}***********************************${NC}"

if [ -z "${DEVICE_PARAMETER}" ]; then
	wait_for_device
fi

# WORK IN PROGRESS

# echo "Get the WiFi status"
# adb $DEVICE_PARAMETER shell settings get global wifi_on
# => 0 WiFi off
# => 1 WiFi on

#echo "Activate WiFi"
# First method (might need root)
#adb $DEVICE_PARAMETER shell "svc wifi enable"
# With root
#adb shell su -c 'svc wifi enable'
#adb shell su -c 'svc wifi disable'

# Second method
#adb shell am start -a android.intent.action.MAIN -n com.android.settings/.wifi.WifiSettings
#adb shell input keyevent 20
#adb shell input keyevent 23

#adb shell cmd -w wifi set-wifi-enabled enabled 
# adb shell cmd -w wifi set-wifi-enabled disabled


# Work for OnePlus 10 Pro
#adb shell am start -a android.settings.WIRELESS_SETTINGS
#adb shell input keyevent 20
#sleep 1
#adb shell input keyevent 20
#sleep 1
#adb shell input keyevent 23
#sleep 1
#adb shell input keyevent 23
#sleep 1
#adb shell input keyevent KEYCODE_HOME


echo Activate tcp mode
adb $DEVICE_PARAMETER tcpip 5555

# Sleep for 1 seconds
echo Wait a bit
sleep 3

echo Find IP
#adb $DEVICE_PARAMETER shell ip -f inet addr show wlan0 | sed -n '1!p' | head -n 1 | cut -d' ' -f 6 | cut -d'/' -f 1
adb connect `adb $DEVICE_PARAMETER shell ip -f inet addr show wlan0 | sed -n '1!p' | head -n 1 | cut -d' ' -f 6 | cut -d'/' -f 1`

# Explanations :
# The command : adb -d shell ip -f inet addr show wlan0
# Return (for example) :
# 23: wlan0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 3000
#    inet 192.168.43.158/24 brd 192.168.43.255 scope global wlan0
#       valid_lft forever preferred_lft forever

# sed -n '1!p' => Remove the last line
# head -n 1 => Remove the first line
# cut -d' ' -f 6 => keep only 192.168.43.158/24
# cut -d'/' -f 1`=> Extract only 192.168.43.158

adb devices