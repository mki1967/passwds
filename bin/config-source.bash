#!/bin/bash
if [[ ! -v PASSWDS_CONFIGURED ]];
then  
  echo "${0}: setting PASSWORDS_* ..."
  export PASSWDS_BIN=$(dirname "$(realpath ${0})")
  export PASSWDS_BASE=$(realpath "${PASSWDS_BIN}/..")
  export PATH="${PASSWDS_BIN}:${PATH}"
  export PASSWDS_CONFIG_DIR="${PASSWDS_BASE}/conf"
  source "${PASSWDS_CONFIG_DIR}/conf.source"
  export PASSWDS_CONFIGURED="1${PASSWDS_CONFIGURED}" 
fi;
