#!/bin/bash

#* This is a template for script using serial name.

source ../_generic_methods.sh
source _generic_methods_android.sh

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


# PUT YOUR COMMAND HERE
# Example: adb $DEVICE_PARAMETER shell ...