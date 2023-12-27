#!/bin/bash

#* This script define the expected signature of the applications
#* - signatureListArray : the signatures.
#* - certificateHashArray : the certificates hashes.
#* - signatureAPKNameExceptionArray : the list of the APKs that the signature must be ignored.

declare -A signatureListArray=(
	["fr.salaun.tristan.androiduiauto"]="CN=SALAUN, OU=SALAUN, O=SALAUN, L=Marseille, C=FR"
)

declare -A certificateHashArray=(
	["fr.salaun.tristan.androiduiauto"]="XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX"
)

declare -A signatureAPKNameExceptionArray=(
		["apkname"]="Application Name"
)

declare -A versionSDKExceptionArray=(
		["package.name"]="App name"
)