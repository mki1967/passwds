#!/bin/bash

# check for argument:
USERNAME=${1? "Brak argumentu USERNAME"}

BIN=$(dirname "$(realpath ${0})")
source ${BIN}/config-source.bash


# TODO: przerobić z `r2-shell.bin`

if [[ -v SSH_ORIGINAL_COMMAND ]];
then
  echo "NIEDOZWOLONE: ${SSH_ORIGINAL_COMMAND}"
  exit ;
fi;

echo
echo '*** Weryfikacja ***'
echo -n 'podaj swój numer indeksu (6 cyfr): '
read IDX;
if [[ ${IDX} != ${1} ]];
then
  echo 'To nie jest logowanie przez klucz przypisany do numeru indeksu '${IDX}' !!!';
  exit;
fi

mkdir -p ${PASSWDS_SERVER_DB_DIR};
mkdir -p ${PASSWDS_SERVER_TMP_DIR};
echo
echo 'Wprowadź i powtórz nowe hasło:'
echo
stty -echo;
# openssl passwd -6 > "${PASSWDS_SERVER_DB_DIR}/${1}";
${PASSWDS_SERVER_PASSWD} > "${PASSWDS_SERVER_TMP_DIR}/${1}";
if [[ $? != 0 ]];
then
 stty echo; # important for local tests
 echo
 echo "*** Błąd przy wprowadzeniu i powtórzeniu hasła !!! ***"
 echo
 exit ;
fi
stty echo;
mv "${PASSWDS_SERVER_TMP_DIR}/${1}" "${PASSWDS_SERVER_DB_DIR}/${1}"
echo "Nowe hasło zostało wprowadzone do serwera."
echo "Na docelowych maszynach zostanie ustawione przy następnej synchronizacji."
