#!/bin/bash

#* This script contain an example to update the password of the keystore and the KeyAlias.
#*
#*
#* Example : 
#* ```sh
#* ./keystore_password.sh
#* ```

source _generic_methods.sh

check_keytool
if [ $? -ne 0 ]
then
    echo -e "${RED}keytool is missing, please install it to continue.${NC}"
    exit 10
fi

#To change the password of your keystore file:
keytool -storepasswd -keystore keystore.jks -storepass OldKeyStorePassword -new NewKeyStorePassword

# To change the password of an alias inside a store:
keytool -keypasswd -keystore keystore.jks -alias appAlias -keypass OldAliasPassword -storepass NewKeyStorePassword -new NewAliasPassword