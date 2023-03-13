#!/bin/bash

# This script is required to insert a custom attribute into the "dictionary.freeradius.internal" dictionary.
# This attribute is required to allow the authentication of printers using the 'TLS-Client-Cert-Template-Name' attribute.
# Key things to note:
# - The attribute has been allocated the number 2000 from a free range within the file. It is possible that future upgrades to freeradius
# will allocate this value which will cause a duplicate. The 'check_if_attribute_number_exists' function is designed to test for the
# presence of 2000 within the dictionary file,  error and then exit prior to the custom attribute being added, so that developers can investigate as necessary.


set -euo pipefail
FILE="/usr/local/share/freeradius/dictionary.freeradius.internal"
ATTRIBUTE_NUMBER_TO_MATCH="2000"
CUSTOM_ATTRIBUTE_TO_INSERT="ATTRIBUTE	TLS-Client-Cert-Template-Information		2000	string"

check_if_attribute_number_exists() {
    echo "Checking if custom attribute number '$ATTRIBUTE_NUMBER_TO_MATCH' exists";
    if grep -q "$ATTRIBUTE_NUMBER_TO_MATCH" "$FILE" ; then
        echo "Attribute Number '$ATTRIBUTE_NUMBER_TO_MATCH' already exists in the dictionary." ;
        echo "We cannot assign a custom attribute with the same attribute number and must exit!";
        exit 1;
    else
        echo "Attribute Number '$ATTRIBUTE_NUMBER_TO_MATCH' does not exist in the dictionary." ;
        echo "Continue to insert custom attribute";
    fi
}

insert_custom_attribute() {
    echo "Inserting custom attribute '$CUSTOM_ATTRIBUTE_TO_INSERT' into '$FILE' dictionary";
    cat << EOF >>$FILE

# This is the entry point for the custom attribute 'ATTRIBUTE	TLS-Client-Template-Name'
# This attribute is required for identifying zerox printers on NACS
# This is the corresponding repo - https://github.com/ministryofjustice/network-access-control-server
$CUSTOM_ATTRIBUTE_TO_INSERT
EOF
}

main() {
    check_if_attribute_number_exists
    insert_custom_attribute
}

main
