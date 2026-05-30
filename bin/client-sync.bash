#!/bin/bash


BIN=$(dirname "$(realpath ${0})")
source ${BIN}/config-source.bash

# ensure existence of Client's dirs
mkdir -p ${PASSWDS_CLIENT_NEW_DIR}
mkdir -p ${PASSWDS_CLIENT_DB_DIR}

# run `rsync`:
${PASSWDS_CLIENT_RSYNC}

# TODO: find the new or changed positions and update the passwords and database 

# find new or changed elements
 LANG=C diff -q  ${PASSWDS_CLIENT_NEW_DIR} ${PASSWDS_CLIENT_DB_DIR} | grep -o '[^[:space:]]*$'

