#!/bin/bash

BIN=$(dirname "$(realpath ${0})")
source ${BIN}/config-source.bash

# 1. Tworzymy unikalny katalog dla bufora sieciowego za pomocą PID ($$)
export PASSWDS_CLIENT_INC_DIR="${PASSWDS_CLIENT_DIR}/incoming_$$"

# Upewniamy się, że podstawowe katalogi oraz nasz bufor istnieją
mkdir -p "${PASSWDS_CLIENT_NEW_DIR}"
mkdir -p "${PASSWDS_CLIENT_DB_DIR}"
mkdir -p "${PASSWDS_CLIENT_INC_DIR}"

# 2. BEZPIECZEŃSTWO: Automatyczne sprzątanie bufora niezależnie od wyniku (trap)
cleanup() {
    passwds_log "Czyszczenie unikalnego bufora sieciowego: ${PASSWDS_CLIENT_INC_DIR}"
    rm -rf "${PASSWDS_CLIENT_INC_DIR}"
}
trap cleanup EXIT INT TERM

# 3. Dynamiczne przepisanie rsync, aby celował w nasz bezpieczny bufor
RSYNC_SECURE=$(echo "${PASSWDS_CLIENT_RSYNC}" | sed "s|${PASSWDS_CLIENT_NEW_DIR}/|${PASSWDS_CLIENT_INC_DIR}/|g")

passwds_log "Uruchamianie rsync z flagą --link-dest (ochrona łącza i procesów)..."

# 4. Wywołanie rsync z optymalizacją pod twarde dowiązania (hardlinks)
${RSYNC_SECURE} --link-dest="${PASSWDS_CLIENT_NEW_DIR}"

# 5. Lokalne, błyskawiczne i atomowe przerzucenie danych do katalogu czystopisu
passwds_log "Atomowe przerzucenie danych z bufora do czystopisu: ${PASSWDS_CLIENT_NEW_DIR}"
rsync -a --delete "${PASSWDS_CLIENT_INC_DIR}/" "${PASSWDS_CLIENT_NEW_DIR}/"

# 6. Analiza różnic i aktualizacja bazy/systemu haseł (Twój oryginalny silnik)
for IDX in $(LANG=C diff -q "${PASSWDS_CLIENT_NEW_DIR}" "${PASSWDS_CLIENT_DB_DIR}" | grep -o '\([[:alnum:]_]*\ differ$\)\|\([[:alnum:]_]*$\)' | grep -o '^[[:alnum:]_]*');
do
  USERNAME=$(username "${IDX}")
  PASSWORD=$(cat "${PASSWDS_CLIENT_NEW_DIR}/${IDX}")
  
  # Walidacja hasha przy użyciu bezpiecznej funkcji z config-source.bash
  if is_valid_sha512 "${PASSWORD}"; then
    
    # Sprawdzamy czy użytkownik istnieje w systemie operacyjnym
    if ! getent passwd "${USERNAME}" > /dev/null 2>&1; then
      passwds_log "Użytkownik ${USERNAME} nie istnieje. Tworzenie konta bez katalogu domowego."
      sudo useradd -p '!' "${USERNAME}"
    fi
    
    if [[ ! -v IGNORE_NEW_USER ]]; then
      passwds_log "Aktualizacja hasła w /etc/shadow dla: ${USERNAME}"
      echo "${USERNAME}:${PASSWORD}" | sudo chpasswd -e
      
      # PO UDANEJ AKTUALIZACJI: Kopiujemy plik do bazy lokalnej (DB), 
      # dzięki czemu przy kolejnym obrocie pętli demona diff go pominie!
      cp "${PASSWDS_CLIENT_NEW_DIR}/${IDX}" "${PASSWDS_CLIENT_DB_DIR}/${IDX}"
    else
      unset IGNORE_NEW_USER
    fi
    
  else
    passwds_log "BŁĄD: Wykryto nieprawidłowy lub uszkodzony hash dla indeksu: ${IDX}. Pomijam!"
  fi
done