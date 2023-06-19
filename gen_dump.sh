#! /bin/bash

ldap_dump() {
    ldapsearch -x uid | grep ^uid: | egrep -v "^uid: [0-9]*$" | awk '{print $2}'
}

krb_dump() {
    TMP_DUMP="temp.mit"
    kdb5_util dump -b7 $TMP_DUMP

    for user in $(ldap_dump)
    do
        grep $user@IME.USP.BR $TMP_DUMP
    done > dump.mit

    rm $TMP_DUMP
}

krb_dump
