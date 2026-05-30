#!/bin/bash

# Any script from this ${BIN} should start with the following two lines:
BIN=$(dirname "$(realpath ${0})")

echo $'\n'"TEST 1 - the first: source ${BIN}/config-source.bash"
source ${BIN}/config-source.bash
export | grep '\-x\ PASSWDS_'
echo "PATH=${PATH}"

echo $'\n'"TEST 2 - the second: source ${BIN}/config-source.bash"
source ${BIN}/config-source.bash
export | grep '\-x\ PASSWDS_'
echo "PATH=${PATH}"

echo $'\n''In both tests should be: `declare -x PASSWDS_CONFIGURED="1"`'
echo 'TEST 2 should not print: `./bin/test-config-source.bash: setting PASSWORDS_* ...`'