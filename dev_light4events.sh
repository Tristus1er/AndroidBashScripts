#!/bin/bash

./choose_device.sh delete_app.sh -p fr.salaun.tristan.android.flyfire.debug
./choose_device.sh delete_app.sh -p fr.salaun.tristan.android.flyfire

echo "Press any key to continue"
while [ true ] ; do
read -t 10 -n 1
if [ $? = 0 ] ; then
exit ;
else
echo "waiting for the keypress to install APP"
fi
done

./choose_device.sh install_apk.sh -a /e/projects/AndroidStudioSVN/Light4EventsApp/app/build/outputs/apk/installed/debug/fr.salaun.tristan.android.flyfire-v47-1.47-installed-debug.apk

echo "Press any key to continue"
while [ true ] ; do
read -t 10 -n 1
if [ $? = 0 ] ; then
exit ;
else
echo "waiting for the keypress to START APP"
fi
done


./choose_device.sh start_app.sh -p fr.salaun.tristan.android.flyfire.debug