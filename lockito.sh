#!/bin/bash

#* This script launch lockito simulation.
#*
#*
#* Example : 
#* ```sh
#* ./lockito.sh
#* ./lockito.sh -s emulator-5556
#* ./lockito.sh -s emulator-5556 -l 3
#* ```


source _generic_methods.sh

# -------------------------------------------------------------------------------------------------
# Functions
# -------------------------------------------------------------------------------------------------
function usage() {
  echo "$0 [-s <deviceSerialNumber>] -l <lockitoSimulationId>"
  echo " -s deviceSerialNumber: The serial number of the device to use to run the command."
  echo " -l lockitoSimulationId: The lockito simulation ID to use (check in the application for the ID)."
  echo ""
  echo "Example :"
  echo "$0 -s emulator-5556"
  echo
}

# -------------------------------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------------------------------
DEVICE_PARAMETER=
LOCKITO_SIMULATION_ID=1

# -------------------------------------------------------------------------------------------------
# Main
# -------------------------------------------------------------------------------------------------

while getopts "vhs:l:" arg; do
    case $arg in
         s) DEVICE_PARAMETER="-s $OPTARG";;
         l) LOCKITO_SIMULATION_ID="$OPTARG";;
         h) usage; exit 1;;
         v) echo "version 1.0.0"; exit 1;;
		 *) usage; exit 1;;
    esac
done

echo -e "${PURPLE}***********************************${NC}"
echo -e "${PURPLE}*     LAUNCH LOCKITO SCENARIO     *${NC}"
echo -e "${PURPLE}***********************************${NC}"

if [ -z "${DEVICE_PARAMETER}" ]; then
	wait_for_device
fi

#https://lockito-app.com/changelog.html
#adb shell am broadcast -n fr.dvilleneuve.lockito/fr.dvilleneuve.lockito.core.service.SimulationActionReceiver <ACTION>
#
#Where<ACTION> can be:
#
#    -a load --el simulationId <simulationId> (to load and prepare simulation with id <simulationId>)
#    -a unload (to unload and clean simulation)
#    -a play (to start loaded simulation)
#    -a pause (to pause loaded simulation)
#    -a stop

# Open google Maps (to check the position)
adb $DEVICE_PARAMETER shell am start -a android.intent.action.MAIN -n com.google.android.apps.maps/com.google.android.maps.MapsActivity

# Clean, load and launch scenario
adb $DEVICE_PARAMETER shell am broadcast -n fr.dvilleneuve.lockito/fr.dvilleneuve.lockito.core.service.SimulationActionReceiver -a unload
sleep 3
adb $DEVICE_PARAMETER shell am broadcast -n fr.dvilleneuve.lockito/fr.dvilleneuve.lockito.core.service.SimulationActionReceiver -a load --el simulationId $LOCKITO_SIMULATION_ID
sleep 3
adb $DEVICE_PARAMETER shell am broadcast -n fr.dvilleneuve.lockito/fr.dvilleneuve.lockito.core.service.SimulationActionReceiver -a play
sleep 3
adb $DEVICE_PARAMETER shell input keyevent KEYCODE_POWER