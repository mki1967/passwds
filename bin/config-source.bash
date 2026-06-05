#!/bin/bash
if [[ ! -v PASSWDS_CONFIGURED ]];
then  
  # echo "${0}: setting PASSWORDS_* ..."  # for tests only
  export PASSWDS_BIN=$(dirname "$(realpath ${0})")
  export PASSWDS_BASE=$(realpath "${PASSWDS_BIN}/..")
  export PATH="${PASSWDS_BIN}:${PATH}"
  export PASSWDS_CONFIG_DIR="${PASSWDS_BASE}/conf"
  source "${PASSWDS_CONFIG_DIR}/conf.source"



  # Common scripts

  # `username` outputs user name for password file name in parameter ${1}
  function username() {
      local USERNAME="u_${1}" # DEFINE YOUR OWN TEMPLATE HERE !
      echo ${USERNAME}
  }
  export -f username;

  # Store log message
  function passwds_log() {
      mkdir -p $(dirname ${PASSWDS_LOG}); # ensure existence ...
      # ALL ARGUMENTS IN LOG MESSAGE !
      local LOG="$(date --rfc-3339=seconds) $(realpath ${0}): ${*}"
      echo ${LOG}  >> ${PASSWDS_LOG}
  }
  export -f passwds_log;

  # Validation scripts
  # Valiate password (script from Gemini):
  is_valid_sha512() {
      local regex='^\$6\$[a-zA-Z0-9./]{1,16}\$[a-zA-Z0-9./]{86}$'
      [[ -n "$1" && "$1" =~ ${regex} ]]
  }
  export -f is_valid_sha512;

  # Vaidate ssh key (script from Gemini):
  is_valid_ssh_pubkey() {
    local key_file="$1"

    # 1. Sprawdź, czy plik istnieje i nie jest pusty
    if [[ ! -s "${key_file}" ]]; then
        return 1
    fi

    # 2. Sprawdź, czy plik zaczyna się od znanych prefiksów klucza publicznego
    #    (Wyklucza to pliki prywatne, tekstowe itp.)
    if ! grep -qE '^(ssh-(rsa|ed25519|dss)|ecdsa-sha2-)' "${key_file}"; then
        return 1
    fi

    # 3. Jeśli przeszedł test tekstowy, sprawdź go narzędziem OpenSSH
    if ssh-keygen -l -f "${key_file}" > /dev/null 2>&1; then
        return 0  # To jest poprawny klucz PUBLICZNY
    else
        return 1  # Klucz jest uszkodzony
    fi
  }
  export -f is_valid_sha512;

  # Prevent child process from exporting the same:
  export PASSWDS_CONFIGURED="1${PASSWDS_CONFIGURED}" 
fi;
