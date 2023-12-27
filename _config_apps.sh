#!/bin/bash

#* This script set the list of the applications that must be used by other scrips (clear_data_app.sh, ...).

declare -A applicationsPackagesArray=(
	["UIAuto"]="fr.salaun.tristan.androiduiauto"
	["L4EDebug"]="fr.salaun.tristan.android.flyfire.debug"
	["L4E"]="fr.salaun.tristan.android.flyfire"
)