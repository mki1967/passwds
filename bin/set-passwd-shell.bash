#!/bin/bash

export BIN=$(dirname "$(realpath ${0})")
export BASE=$(realpath "${BIN}/..")
source ${BASE}/conf/conf.source


# TODO: przerobić z `r2-shell.bin`

if [[ -v SSH_ORIGINAL_COMMAND ]];
then
  echo "NIEDOZWOLONE: ${SSH_ORIGINAL_COMMAND}"
  exit ;
fi;

# to be run by the user 'auth' when a student logs in
# set paths in  variables
source /p210/bin/set-paths.source

echo
echo '*** Weryfikacja ***'
echo -n 'podaj swój numer indeksu (6 cyfr): '
read IDX;
if [[ ${IDX} != ${1} ]];
then
  echo 'To nie jest logowanie przez klucz przypisany do numeru indeksu '${IDX}' !!!';
  exit;
fi

mkdir -p ${AUTH};
echo
echo 'Wprowadź i powtórz nowe hasło:'
echo
stty -echo;
NEW='/home/auth/new'
mkdir -p ${NEW}
htpasswd -c ${NEW}'/'${1}'.auth' ${1};
if [[ $? != 0 ]];
then
 echo
 echo "*** Błąd przy wprowadzeniu i powtórzeniu hasła !!! ***"
 echo
 exit ;
fi
stty echo;

REPO_IP=10.252.16.1 # sprawdź na repo poleceniem: ip a
ssh auth@${REPO_IP} &> /dev/null  # transfer of '${NEW}/*' to 'repo:/p210/auth/'
echo
mv ${NEW}'/'${1}'.auth' ${AUTH}'/'${1}'.auth'  # clean ${NEW}: move ${1}'.auth' file to the archive ${AUTH}

echo "Nowe hasło zostało ustawione."
# cat ${AUTH}'/'${1}'.auth'
echo

REPO_URL="https://repo.cs.pwr.edu.pl/${1}"

# echo "Spróbuj otworzyć stronę: ${REPO_URL}"
echo "Dostęp przez plrzeglądarkę i klienta SVN"
echo "jako użytkownik: ${1}"
echo "podając hasło, które ustawiłeś."
echo

