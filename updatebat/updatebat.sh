#!/bin/bash

BACKTITLE="Foclabroc Toolbox"
LANG_UI="${LANG_UI:-}"
LANG_FILE="/userdata/system/pro/lang_ui"

if [ -z "$LANG_UI" ] && [ -f "$LANG_FILE" ]; then
  LANG_UI=$(cat "$LANG_FILE")
fi

if [ "$LANG_UI" != "en" ] && [ "$LANG_UI" != "fr" ]; then
  LANG_UI=""
fi

select_language() {
  if [ -n "$LANG_UI" ]; then
    return
  fi

  CHOICE=$(dialog --clear --backtitle "$BACKTITLE" --title "Language / Langue" \
    --menu "\nChoose your language / Choisissez votre langue :\n " 12 60 2 \
    1 "English" \
    2 "Français" \
    2>&1 >/dev/tty)

  case $CHOICE in
    1) LANG_UI="en" ;;
    2|"") LANG_UI="fr" ;;
  esac

  echo "$LANG_UI" > "$LANG_FILE"
}

tr() {
  case "$LANG_UI:$1" in
    en:INIT_TITLE) echo "Batocera Update / Downgrade";;
    fr:INIT_TITLE) echo "Mise à jour / Downgrade Batocera";;
    en:INIT_MSG) echo "\nBatocera update or downgrade script.\n\nAllows you to upgrade or downgrade your Batocera version easily if the current version doesn't suit you.\n\n!!!WARNING!!! Do not downgrade by more than one version from your current version,\notherwise you may cause serious compatibility issues or even make booting impossible!!!\n\n\n\nAre you sure you want to continue ?";;
    fr:INIT_MSG) echo "\nScript de mise à jour ou Downgrade de Batocera.\n\nPermet de monter ou descendre la version de votre Batocera facilement si votre version actuelle ne vous convient pas.\n\n!!!ATTENTION!!! Ne pas descendre de plus d'une version par rapport à\nvotre version actuelle, au risque de causer de grave problèmes de compatibilité voir même rendre le boot impossible!!!\n\n\n\nÊtes-vous sûr de vouloir continuer ?";;
    en:ERR_TITLE) echo "Error";;
    fr:ERR_TITLE) echo "Erreur";;
    en:NO_INTERNET) echo "\nNo Internet connection.";;
    fr:NO_INTERNET) echo "\nPas de connexion Internet.";;
    en:SELECT_TITLE) echo "Choose a version";;
    fr:SELECT_TITLE) echo "Choisir une version";;
    en:SELECT_PROMPT) echo "\nCurrent version: $2\n\nSelect a version to download:\n ";;
    fr:SELECT_PROMPT) echo "\nVersion actuelle : $2\n\nSélectionnez une version à télécharger :\n ";;
    en:SPACE_TITLE) echo "Disk space error";;
    fr:SPACE_TITLE) echo "Erreur espace disque";;
    en:SPACE_MSG) echo "\nNot enough free space in /userdata.\nFree: ${2} MB\nRequired: ${3} MB";;
    fr:SPACE_MSG) echo "\nEspace libre insuffisant dans /userdata.\nLibre : ${2} Mo\nRequis : ${3} Mo";;
    en:BOOT_SPACE_TITLE) echo "Insufficient space in /boot";;
    fr:BOOT_SPACE_TITLE) echo "\nEspace insuffisant dans /boot";;
    en:BOOT_SPACE_MSG) echo "Free space on /boot: ${2} MB\nRequired: ${3} MB\n\nIncrease your boot partition size\nor update manually by following\nthe Batocera wiki.";;
    fr:BOOT_SPACE_MSG) echo "Espace libre sur /boot : ${2} Mo\nRequis : ${3} Mo\n\nAugmenter la taille de votre boot\nou mettez à jour manuelement en vous référant\nau wiki de batocera.";;
    en:DOWNLOAD_TITLE) echo "Download";;
    fr:DOWNLOAD_TITLE) echo "Téléchargement";;
    en:DOWNLOAD_GAUGE) echo "Downloading...";;
    fr:DOWNLOAD_GAUGE) echo "Téléchargement en cours...";;
    en:DOWNLOAD_STATUS) echo "\nDownloading version $2...";;
    fr:DOWNLOAD_STATUS) echo "\nTéléchargement de la version $2...";;
    en:SPEED) echo "Speed";;
    fr:SPEED) echo "Vitesse";;
    en:DOWNLOADED) echo "Downloaded";;
    fr:DOWNLOADED) echo "Téléchargé";;
    en:ETA) echo "Estimated time remaining";;
    fr:ETA) echo "Temps restant estimé";;
    en:DOWNLOAD_ERR) echo "Error during download.";;
    fr:DOWNLOAD_ERR) echo "Erreur pendant le téléchargement.";;
    en:DOWNLOAD_CANCEL) echo "\nDownload canceled or failed.";;
    fr:DOWNLOAD_CANCEL) echo "\nTéléchargement annulé ou échoué.";;
    en:MOUNT_RW) echo "\nRemounting /boot as read-write...";;
    fr:MOUNT_RW) echo "\nPassage en mode lecture-écriture de la partition Boot...";;
    en:MOUNT_RW_ERR) echo "\nUnable to remount /boot as read-write.";;
    fr:MOUNT_RW_ERR) echo "\nImpossible de remonter /boot en lecture-écriture.";;
    en:BACKUP_CFG) echo "\nBacking up configuration files...";;
    fr:BACKUP_CFG) echo "\nSauvegarde des fichiers de configuration...";;
    en:BACKUP_ERR) echo "\nError while backing up $2";;
    fr:BACKUP_ERR) echo "\nErreur lors de la sauvegarde de $2";;
    en:ANALYZE) echo "\nAnalyzing boot.tar.xz V$2 before extraction, please wait...";;
    fr:ANALYZE) echo "\nAnalyse du boot.tar.xz V$2 avant extraction patientez...";;
    en:EXTRACT_TITLE) echo "Extraction";;
    fr:EXTRACT_TITLE) echo "Extraction";;
    en:EXTRACT_GAUGE) echo "Extracting archive...";;
    fr:EXTRACT_GAUGE) echo "Extraction de l’archive en cours...";;
    en:EXTRACT_PROGRESS) echo "Extraction in progress... (Batocera.update file is large, please wait...)";;
    fr:EXTRACT_PROGRESS) echo "Extraction en cours... (Fichier Batocera.update lent car volumineux) patience...";;
    en:EXTRACT_FILE) echo "Extracted file: $2";;
    fr:EXTRACT_FILE) echo "Fichier extrait : $2";;
    en:RESTORE_CFG) echo "\nRestoring configuration files...";;
    fr:RESTORE_CFG) echo "\nRestauration des fichiers de configuration...";;
    en:RESTORE_ERR) echo "Error while restoring $2";;
    fr:RESTORE_ERR) echo "Erreur lors de la restauration de $2";;
    en:MOUNT_RO) echo "\nRemounting /boot as read-only...";;
    fr:MOUNT_RO) echo "\nRemontée de /boot en lecture seule...";;
    en:MOUNT_RO_ERR) echo "\nUnable to remount /boot as read-only.";;
    fr:MOUNT_RO_ERR) echo "\nImpossible de remonter /boot en lecture seule.";;
    en:CLEANUP) echo "\nCleaning up...";;
    fr:CLEANUP) echo "\nNettoyage...";;
    en:UPDATE_DONE_TITLE) echo "Update complete";;
    fr:UPDATE_DONE_TITLE) echo "Mise à jour terminée";;
    en:UPDATE_DONE_MSG) echo "\nThe update is complete. You are now on V${2}.\n\nAfter reboot:\n- Please update your BIOS to V${2}.\n- Update your MAME, FBNeo romsets accordingly.\n- Also update systems such as Switch, 3Dnes.\n";;
    fr:UPDATE_DONE_MSG) echo "\nLa mise à jour est terminée, vous êtes maintenant en V${2}.\n\nAprès redémarrage :\n- Veuillez bien mettre à jour vos BIOS en V${2}.\n- Mettez également à jour vos différents romsets MAME, FBNeo... en conséquence.\n- Et mettez à jour les systèmes tels que Switch, 3Dnes.\n";;
    en:REBOOT_TITLE) echo "Reboot required";;
    fr:REBOOT_TITLE) echo "Redémarrage nécessaire";;
    en:REBOOT_MSG) echo "\nA Batocera reboot is required.\n\nReboot now ?";;
    fr:REBOOT_MSG) echo "\nUn redémarrage de Batocera est nécessaire.\n\nVoulez-vous redémarrer maintenant ?";;
    en:CANCEL_TITLE) echo "Canceled";;
    fr:CANCEL_TITLE) echo "Annulé";;
    en:REBOOT_CANCEL) echo "\nReboot canceled by user.";;
    fr:REBOOT_CANCEL) echo "\nRedémarrage annulé par l'utilisateur.";;
    en:CONFIRM_TITLE) echo "Confirmation";;
    fr:CONFIRM_TITLE) echo "Confirmation";;
    en:CONFIRM_MSG) echo "\nCurrent Batocera version: $2\n\nDo you want to install version $3 ?";;
    fr:CONFIRM_MSG) echo "\nVersion de Batocera actuelle : $2\n\nVoulez-vous installer la version $3 ?";;
    en:DOWNGRADE_TITLE) echo "Downgrade not allowed";;
    fr:DOWNGRADE_TITLE) echo "Downgrade non autorisé";;
    en:DOWNGRADE_MSG) echo "\nYou selected version $2 while you are currently on version $3.\n\nDowngrading more than one version is not recommended to avoid compatibility or boot issues.\n\nPlease choose a more recent version (maximum one version below).";;
    fr:DOWNGRADE_MSG) echo "\nVous avez sélectionné la version $2 alors que vous êtes actuellement en version $3.\n\nIl est déconseiller de rétrograder de plus d’une version pour éviter des problèmes de compatibilité ou de démarrage.\n\nVeuillez choisir une version plus récente (maximum une version en dessous).";;
  esac
}

select_language
UPGRADE_DIR="/userdata/system/upgrade"
DEST_FILE="$UPGRADE_DIR/boot.tar.xz"

declare -A poids_versions=(
    [38]=3020
    [39]=3160
    [40]=3340
    [41]=3400
    [42]=3900
)

# Message initial
dialog --backtitle "$BACKTITLE" \
  --title "$(tr INIT_TITLE)" \
  --yesno "$(tr INIT_MSG)" 18 75 2>&1 >/dev/tty
if [ $? -ne 0 ]; then clear; exit 0; fi

# Fonction: vérifier connexion Internet
verifier_connexion() {
  if ! ping -c 1 -W 2 1.1.1.1 >/dev/null 2>&1; then
    dialog --backtitle "$BACKTITLE" --title "$(tr ERR_TITLE)" --msgbox "$(tr NO_INTERNET)" 7 40 2>&1 >/dev/tty
    clear; exit 1
  fi
}

# Fonction: sélectionner version
selectionner_version() {
  choix=$(dialog --backtitle "$BACKTITLE" --title "$(tr SELECT_TITLE)" --menu "$(tr SELECT_PROMPT "$VERSION")" 20 55 8 \
    38 "->Version 38 (3.02 Go)" \
    39 "->Version 39 (3.16 Go)" \
    40 "->Version 40 (3.34 Go)" \
    41 "->Version 41 (3.40 Go)" \
    42 "->Version 42 (3.90 Go)" \
    2>&1 >/dev/tty)

  if [ $? -ne 0 ] || [ -z "$choix" ]; then
    clear
    exit 0
  fi

  numero_version="$choix"
}

# Fonction: vérifier espace libre dans /userdata (pour téléchargement)
verifier_espace_userdata() {
  poids=${poids_versions[$numero_version]}
  espace_libre=$(df -Pm /userdata | awk 'NR==2 {print $4}')
  if (( espace_libre < poids + 10 )); then
    dialog --backtitle "$BACKTITLE" --title "$(tr SPACE_TITLE)" --msgbox "$(tr SPACE_MSG "$espace_libre" "$poids")" 9 60 2>&1 >/dev/tty
    clear; exit 1
  fi
}

# Fonction: vérifier espace libre dans /boot (pour extraction)
verifier_espace_boot() {
  taille_archive=${poids_versions[$numero_version]}
  taille_min_requise_boot=$((taille_archive + 200))
  espace_libre_boot=$(df -Pm /boot | awk 'NR==2 {print $4}')
  if (( espace_libre_boot < taille_min_requise_boot )); then
    dialog --backtitle "$BACKTITLE" --title "$(tr BOOT_SPACE_TITLE)" --msgbox \
      "$(tr BOOT_SPACE_MSG "$espace_libre_boot" "$taille_min_requise_boot")" 15 60 2>&1 >/dev/tty
    clear; exit 1
  fi
}

# Fonction: télécharger fichier avec barre de progression dialog (infos vitesse, taille, temps restant)
telecharger_fichier() {
  url="https://foclabroc.freeboxos.fr:55973/share/wz8r37M_mq6Y5inK/boot-${numero_version}.tar.xz"
  poids=${poids_versions[$numero_version]} # en Mo
  poids_bytes=$((poids * 1024 * 1024))

  mkdir -p "$UPGRADE_DIR"
  rm -f "$DEST_FILE"

  (
    curl -sL "$url" -o "$DEST_FILE" &
    PID_CURL=$!
    START_TIME=$(date +%s)

    while kill -0 $PID_CURL 2>/dev/null; do
      if [ -f "$DEST_FILE" ]; then
        CURRENT_SIZE=$(stat -c%s "$DEST_FILE" 2>/dev/null)
        NOW=$(date +%s)
        ELAPSED=$((NOW - START_TIME))
        [ "$ELAPSED" -eq 0 ] && ELAPSED=1

        SPEED_BPS=$((CURRENT_SIZE / ELAPSED))
        SPEED_MO=$(echo "scale=2; $CURRENT_SIZE / $ELAPSED / 1048576" | bc)
        CURRENT_MB=$((CURRENT_SIZE / 1024 / 1024))
        TOTAL_MB=$poids
        REMAINING_BYTES=$((poids_bytes - CURRENT_SIZE))
        [ "$SPEED_BPS" -eq 0 ] && SPEED_BPS=1

        ETA_SEC=$((REMAINING_BYTES / SPEED_BPS))
        ETA_MIN=$((ETA_SEC / 60))
        ETA_REST_SEC=$((ETA_SEC % 60))
        ETA_FORMAT=$(printf "%02d:%02d" "$ETA_MIN" "$ETA_REST_SEC")

        PROGRESS=$((CURRENT_SIZE * 100 / poids_bytes))
        [ "$PROGRESS" -gt 100 ] && PROGRESS=100

        echo "XXX"
        echo -e "$(tr DOWNLOAD_STATUS "$numero_version")"
        echo ""
        echo -e "$(tr SPEED) : ${SPEED_MO} Mo/s | $(tr DOWNLOADED) : ${CURRENT_MB} / ${TOTAL_MB} Mo"
        echo ""
        echo -e "$(tr ETA) : ${ETA_FORMAT}"
        echo "XXX"
        echo "$PROGRESS"
      fi
      sleep 0.5
    done

    wait $PID_CURL
    RET=$?
    if [ $RET -ne 0 ]; then
      rm -f "$DEST_FILE"
      echo "XXX"
      echo "$(tr DOWNLOAD_ERR)"
      echo "XXX"
      sleep 2
      exit 1
    fi
  ) | dialog --backtitle "$BACKTITLE" --title "$(tr DOWNLOAD_TITLE)" --gauge "$(tr DOWNLOAD_GAUGE)" 13 70 0 2>&1 >/dev/tty

  if [ ! -f "$DEST_FILE" ]; then
    dialog --backtitle "$BACKTITLE" --title "$(tr CANCEL_TITLE)" --msgbox "$(tr DOWNLOAD_CANCEL)" 7 40 2>&1 >/dev/tty
    clear
    exit 1
  fi
}

# Fonction: extraction avec affichage fichiers extraits dans dialog gauge
extraire_et_mettre_a_jour() {
  verifier_espace_boot

  dialog --backtitle "$BACKTITLE" --infobox "$(tr MOUNT_RW)" 6 50 2>&1 >/dev/tty
  sleep 2
  if ! mount -o remount,rw /boot; then
    dialog --backtitle "$BACKTITLE" --title "$(tr ERR_TITLE)" --msgbox "$(tr MOUNT_RW_ERR)" 8 50 2>&1 >/dev/tty
    clear; exit 1
  fi

  dialog --backtitle "$BACKTITLE" --infobox "$(tr BACKUP_CFG)" 6 40 2>&1 >/dev/tty
  sleep 2

  BOOTFILES="config.txt batocera-boot.conf"
  for BOOTFILE in ${BOOTFILES}; do
    if [ -e "/boot/${BOOTFILE}" ]; then
      cp "/boot/${BOOTFILE}" "/boot/${BOOTFILE}.upgrade" || {
        dialog --backtitle "$BACKTITLE" --title "$(tr ERR_TITLE)" --msgbox "$(tr BACKUP_ERR "$BOOTFILE")" 7 50 2>&1 >/dev/tty
        clear; exit 1
      }
    fi
  done

  dialog --backtitle "$BACKTITLE" --infobox "$(tr ANALYZE "$numero_version")" 5 60 2>&1 >/dev/tty

  TOTAL_FILES=$(tar -tf "$DEST_FILE" | wc -l)
  [ "$TOTAL_FILES" -eq 0 ] && TOTAL_FILES=1
  COUNT=0

  (
    tar -xvf "$DEST_FILE" --no-same-owner -C /boot | while read -r file; do
      COUNT=$((COUNT + 1))
      PERCENT=$((COUNT * 100 / TOTAL_FILES))
      echo "XXX"
      echo "$PERCENT"
      echo ""
      echo "$(tr EXTRACT_PROGRESS)"
      echo ""
      echo "$(tr EXTRACT_FILE "$file")"
      echo "($COUNT / $TOTAL_FILES)"
      echo "XXX"
    done
  ) | dialog --backtitle "$BACKTITLE" --title "$(tr EXTRACT_TITLE)" --gauge "$(tr EXTRACT_GAUGE)" 12 90 0 2>&1 >/dev/tty

  dialog --backtitle "$BACKTITLE" --infobox "$(tr RESTORE_CFG)" 6 40 2>&1 >/dev/tty
  sleep 2
  for BOOTFILE in ${BOOTFILES}; do
    if [ -e "/boot/${BOOTFILE}.upgrade" ]; then
      if ! mv "/boot/${BOOTFILE}.upgrade" "/boot/${BOOTFILE}"; then
        dialog --backtitle "$BACKTITLE" --title "$(tr ERR_TITLE)" --msgbox "$(tr RESTORE_ERR "$BOOTFILE")" 7 50 2>&1 >/dev/tty
        clear
        exit 1
      fi
    fi
  done

  dialog --backtitle "$BACKTITLE" --infobox "$(tr MOUNT_RO)" 6 40 2>&1 >/dev/tty
  sleep 2
  mount -o remount,ro /boot || {
    dialog --backtitle "$BACKTITLE" --title "$(tr ERR_TITLE)" --msgbox "$(tr MOUNT_RO_ERR)" 7 50 2>&1 >/dev/tty
    clear; exit 1
  }

  # Supprimer l’archive téléchargée
  dialog --backtitle "$BACKTITLE" --infobox "$(tr CLEANUP)" 5 40 2>&1 >/dev/tty
  sleep 2
  rm -f "$DEST_FILE"

  dialog --backtitle "$BACKTITLE" --title "$(tr UPDATE_DONE_TITLE)" --msgbox "$(tr UPDATE_DONE_MSG "$numero_version")" 12 90 2>&1 >/dev/tty

  dialog --backtitle "$BACKTITLE" --title "$(tr REBOOT_TITLE)" --yesno "$(tr REBOOT_MSG)" 9 50 2>&1 >/dev/tty
  reponse=$?
  clear
  if [ "$reponse" -eq 0 ]; then
    reboot
  else
    dialog --backtitle "$BACKTITLE" --title "$(tr CANCEL_TITLE)" --infobox "$(tr REBOOT_CANCEL)" 7 40 2>&1 >/dev/tty
  fi
}

# Détecter la version actuelle de Batocera
VERSION=$(batocera-es-swissknife --version | awk '{print $1}' | sed -E 's/^([0-9]+).*/\1/')

# Confirmation après sélection de version
confirmer_version() {
  dialog --backtitle "$BACKTITLE" --title "$(tr CONFIRM_TITLE)" --yesno "$(tr CONFIRM_MSG "$VERSION" "$numero_version")" 9 60 2>&1 >/dev/tty

  if [ $? -ne 0 ]; then
    return 1
  fi

  return 0
}

# Main
verifier_connexion
while true; do
  selectionner_version
  if (( numero_version < VERSION - 1 )); then
    dialog --backtitle "$BACKTITLE" --title "$(tr DOWNGRADE_TITLE)" --msgbox "$(tr DOWNGRADE_MSG "$numero_version" "$VERSION")" 14 70 2>&1 >/dev/tty
    continue
  fi
  confirmer_version || continue
  break
done
verifier_espace_userdata
telecharger_fichier
extraire_et_mettre_a_jour
clear
exit 0
