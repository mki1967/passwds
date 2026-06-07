#!/bin/bash

# Run on server

# check for argument:
KEYS_DIR=${1? "Brak argumentu KEYS_DIR"}

BIN=$(dirname "$(realpath ${0})")
source ${BIN}/config-source.bash

# TODO: dokończ przerabianie

for KEY_PATH in $(find ${KEYS_DIR} | sort) ;
do
  if is_valid_ssh_pubkey ${KEY_PATH};
  then
    NAME=$(basename $KEY_PATH);
    NAME=${NAME%.pub};
    echo -n "command=\"${PASSWDS_BIN}/set-passwd-shell.bash ${NAME},no-port-forwarding,no-X11-forwarding,no-agent-forwarding \""
    cat ${KEY_PATH};
  fi;
done
