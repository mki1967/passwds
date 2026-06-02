#!/bin/bash


BIN=$(dirname "$(realpath ${0})")
source ${BIN}/config-source.bash

# ensure existence of Client's dirs
mkdir -p ${PASSWDS_CLIENT_NEW_DIR}
mkdir -p ${PASSWDS_CLIENT_DB_DIR}

# run `rsync`:
${PASSWDS_CLIENT_RSYNC}

# TODO: find the new or changed positions and update the passwords and database 

# Update users and passwords for new or changed elements:
for IDX in $(LANG=C diff -q  ${PASSWDS_CLIENT_NEW_DIR} ${PASSWDS_CLIENT_DB_DIR} | grep -o '\([[:alnum:]_]*\ differ$\)\|\([[:alnum:]_]*$\)' | grep -o '^[[:alnum:]_]*');
do
  USERNAME=$(username ${IDX});
  PASSWORD=$(cat "${PASSWDS_CLIENT_NEW_DIR}/${IDX}");
  TEST_PASSWORD=$(echo "${PASSWORD}" | grep -E '^\$6\$[a-zA-Z0-9./]{1,16}\$[a-zA-Z0-9./]{86}$' );
  #  passwds_log "TEST_PASSWORD = ${TEST_PASSWORD}";
  if [[ ( ! ( "${PASSWORD}" = "" ) ) && ( "${TEST_PASSWORD}" = "${PASSWORD}" ) ]]; # `[` nie obsługuje globbingu ale też buntuje się przy `!` i `(`
  then
    if ! getent passwd ${USERNAME} > /dev/null 2>&1;
    then
      # Użytkownik nie istnieje! Trzeba go najpierw stworzyć:"
      # passwds_log "sudo useradd -m -p '!' ${USERNAME}";   # TWORZYMY
      # albo (jeśli nie potrzebuje katalogu domowego):"
      passwds_log "sudo useradd -p '!' ${USERNAME}";      # TWORZYMY BEZ HOME
      # albo nie chcemy nowych:
      # IGNORE_NEW_USER=true;                        # INGNORUJEMY
    fi
    if [[ ! -v IGNORE_NEW_USER ]];
    then
      passwds_log "echo '${USERNAME}:${PASSWORD}' | sudo chpasswd -e";
    else
      unset  IGNORE_NEW_USER; # for next iteration
      passwds_log "# NO USER ${USERNAME}: ${PASSWDS_CLIENT_NEW_DIR}/${IDX}"
      rm ${PASSWDS_CLIENT_NEW_DIR}/${IDX}; # do not add to database
    fi;
  else
    passwds_log "# BAD: ${PASSWDS_CLIENT_NEW_DIR}/${IDX}"
    rm ${PASSWDS_CLIENT_NEW_DIR}/${IDX}; # do not add to database
  fi;
done;

# Update database with new files:
rsync -a  "${PASSWDS_CLIENT_NEW_DIR}/" "${PASSWDS_CLIENT_DB_DIR}/"
