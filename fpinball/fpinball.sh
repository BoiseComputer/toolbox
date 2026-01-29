#!/bin/bash

URL_FP="https://github.com/foclabroc/toolbox/releases/download/Fichiers/fpinball.zip"

clear

LANG_UI="fr"
if [[ "$LANG" == en* ]]; then
    LANG_UI="en"
fi

tr() {
    case "$LANG_UI:$1" in
        en:VER_DETECTED) echo "\nDetected Batocera version: $2";;
        fr:VER_DETECTED) echo "\nVersion de Batocera détectée : $2";;
        en:UNSUPPORTED) echo "\nYour Batocera version ($2) is not supported.\n\nUpdate to version 42 or higher.";;
        fr:UNSUPPORTED) echo "\nVotre version de Batocera ($2) n'est pas prise en charge.\n\nMettez à jour vers la version 42 ou supérieure.";;
        en:CLEAN_OLD) echo "\nRemoving old files...";;
        fr:CLEAN_OLD) echo "\nSuppression des anciens fichiers...";;
        en:DL_ARCHIVE) echo "Downloading Future Pinball archive...";;
        fr:DL_ARCHIVE) echo "Téléchargement de l'archive Future Pinball en cours...";;
        en:DL_FAIL) echo "\nFailed to download the archive!";;
        fr:DL_FAIL) echo "\nÉchec du téléchargement de l'archive !";;
        en:EXTRACT_ARCHIVE) echo "Extracting Future Pinball archive...";;
        fr:EXTRACT_ARCHIVE) echo "Extraction de l'archive Future Pinball...";;
        en:CLEAN_TEMP) echo "\nCleaning temporary files...";;
        fr:CLEAN_TEMP) echo "\nNettoyage des fichiers temporaires...";;
        en:RUNNER_EXISTS) echo "\nWine GE-Custom is already installed.\nNo action needed.";;
        fr:RUNNER_EXISTS) echo "\nWine GE-Custom est déjà installé.\nAucune action nécessaire.";;
        en:FINAL_TITLE) echo "Future Pinball";;
        fr:FINAL_TITLE) echo "Future Pinball";;
        en:FINAL_MSG) echo "Installation of Future Pinball completed successfully.\n\nAdd your ROMs in /roms/fpinball and ensure the 'Future Pinball' system is enabled in Collections → Shown systems.\n\nAt first launch, wait 30 seconds to 1 minute for the automatic Winetricks installation.";;
        fr:FINAL_MSG) echo "Installation de Future Pinball terminée avec succès.\n\nAjoutez vos ROMs dans /roms/fpinball et vérifiez que le système 'Future Pinball' est bien coché dans les paramètres de Collections → Systèmes affichés.\n\nAu premier lancement, patientez 30 secondes à 1 minute pour l'installation automatique des Winetricks.";;
        en:RUNNER_INFO) echo "\nDownloading and installing the runner compatible with Future Pinball...";;
        fr:RUNNER_INFO) echo "\nTéléchargement et installation du runner compatible Future Pinball...";;
        en:RUNNER_DL) echo "Downloading Wine GE-Custom...";;
        fr:RUNNER_DL) echo "Téléchargement de Wine GE-Custom en cours...";;
        en:RUNNER_DL_FAIL) echo "\nError downloading Wine GE-Custom!";;
        fr:RUNNER_DL_FAIL) echo "\nErreur lors du téléchargement de Wine GE-Custom !";;
        en:RUNNER_ASSEMBLE) echo "\nAssembling files...";;
        fr:RUNNER_ASSEMBLE) echo "\nAssemblage des fichiers...";;
        en:RUNNER_ASSEMBLE_FAIL) echo "\nFailed to assemble files!";;
        fr:RUNNER_ASSEMBLE_FAIL) echo "\nÉchec de l'assemblage des fichiers !";;
        en:RUNNER_UNXZ) echo "\nDecompressing .xz archive...";;
        fr:RUNNER_UNXZ) echo "\nDécompression de l'archive .xz...";;
        en:RUNNER_UNXZ_FAIL) echo "\nError while decompressing .xz!";;
        fr:RUNNER_UNXZ_FAIL) echo "\nErreur lors de la décompression du .xz !";;
        en:RUNNER_EXTRACT) echo "Extracting Wine GE-Custom (~${2} MB)...";;
        fr:RUNNER_EXTRACT) echo "Extraction de Wine GE-Custom (~${2} Mo)...";;
        en:RUNNER_OK) echo "\nWine GE-Custom installation for Future Pinball completed successfully!";;
        fr:RUNNER_OK) echo "\nInstallation de Wine GE-Custom pour Future Pinball terminée avec succès !";;
        en:RUNNER_FAIL) echo "\nWine GE-Custom V40 installation failed!";;
        fr:RUNNER_FAIL) echo "\nÉchec de l'installation de Wine GE-Custom V40 !";;
    esac
}

# Détection de la version Batocera
VERSION=$(batocera-es-swissknife --version | awk '{print $1}' | sed -E 's/^([0-9]+).*/\1/')

dialog --backtitle "Foclabroc Toolbox" \
    --infobox "$(tr VER_DETECTED "$VERSION")" 6 50 2>&1 >/dev/tty
sleep 2

# Déterminer l'URL en fonction de la version
if [ "$VERSION" -ge 42 ]; then
    ARCHIVE_URL="$URL_FP"
else
        dialog --backtitle "Foclabroc Toolbox" \
            --msgbox "$(tr UNSUPPORTED "$VERSION")" 8 60 2>&1 >/dev/tty
    exit 1
fi

# Nom du fichier
ARCHIVE_NAME=$(basename "$ARCHIVE_URL")

# Chemin de destination
DESTINATION="/userdata/"

# Suppression des anciens dossiers
dialog --backtitle "Foclabroc Toolbox" \
    --infobox "$(tr CLEAN_OLD)" 5 50 2>&1 >/dev/tty
sleep 1
rm -rf /userdata/system/wine-bottles/fpinball
rm -rf /userdata/system/pro/fpinball

# Lancement du téléchargement
(
  curl -L --progress-bar -o "$DESTINATION$ARCHIVE_NAME" "$ARCHIVE_URL" 2>&1 | \
  stdbuf -oL tr '\r' '\n' | awk '/%/ {gsub(/%/,""); print $1}'
) | dialog --gauge "$(tr DL_ARCHIVE)" 7 60 0 2>&1 >/dev/tty
# Vérifier si le téléchargement a réussi
if [ $? -ne 0 ] || [ ! -f "$DESTINATION$ARCHIVE_NAME" ]; then
    dialog --backtitle "Foclabroc Toolbox" \
           --msgbox "$(tr DL_FAIL)" 6 50 2>&1 >/dev/tty
    exit 1
fi

# Décompression avec jauge de progression (toutes les 10 lignes)
TOTAL_FILES=$(unzip -l "$DESTINATION$ARCHIVE_NAME" | grep -E "^[ ]*[0-9]" | wc -l)
COUNT=0

(
  unzip -o "$DESTINATION$ARCHIVE_NAME" -d "$DESTINATION" | grep -E "inflating|extracting" | while read -r line; do
      COUNT=$((COUNT + 1))
      if (( COUNT % 10 == 0 )); then
          PERCENT=$((COUNT * 100 / TOTAL_FILES))
          echo "$PERCENT"
      fi
  done
) | dialog --gauge "$(tr EXTRACT_ARCHIVE)" 7 60 0 2>&1 >/dev/tty

# Nettoyage du fichier ZIP
dialog --backtitle "Foclabroc Toolbox" \
    --infobox "$(tr CLEAN_TEMP)" 5 50 2>&1 >/dev/tty
sleep 1
rm -f "$DESTINATION$ARCHIVE_NAME"

sleep 1


##############################################################
#  Installation automatique de Wine GE-Custom V40
##############################################################

# === Définir les URLs pour les fichiers split ===
URL_PART1="https://github.com/foclabroc/toolbox/raw/refs/heads/main/wine-tools/ge-customv40.tar.xz.001"
URL_PART2="https://github.com/foclabroc/toolbox/raw/refs/heads/main/wine-tools/ge-customv40.tar.xz.002"

# === Définir les répertoires ===
DOWNLOAD_DIR="/tmp/ge-custom-download"
EXTRACT_DIR="/userdata/system/wine/custom"
FINAL_DIR="$EXTRACT_DIR/ge-custom"

# === Vérifier si Wine GE-Custom est déjà installé ===
if [[ -d "$FINAL_DIR" ]]; then
    dialog --backtitle "Foclabroc Toolbox" \
    --infobox "$(tr RUNNER_EXISTS)" 6 60 2>&1 >/dev/tty
    sleep 2

	# === Message final ===
    dialog --backtitle "Foclabroc Toolbox" --title "$(tr FINAL_TITLE)" \
    --msgbox "$(tr FINAL_MSG)" 13 70 2>&1 >/dev/tty

    # === Rafraîchissement des jeux ===
    curl -s http://127.0.0.1:1234/reloadgames > /dev/null
    exit 0
fi

# === Création des répertoires ===
mkdir -p "$DOWNLOAD_DIR"
mkdir -p "$EXTRACT_DIR"

# === Message d'information ===
dialog --backtitle "Foclabroc Toolbox" --infobox "$(tr RUNNER_INFO)" 6 60 2>&1 >/dev/tty
sleep 2

# === Téléchargement des 2 parties ===
(
  echo 10
  curl -Ls -o "$DOWNLOAD_DIR/ge-customv40.tar.xz.001" "$URL_PART1" --progress-bar && echo 50
  curl -Ls -o "$DOWNLOAD_DIR/ge-customv40.tar.xz.002" "$URL_PART2" --progress-bar && echo 100
) | dialog --gauge "$(tr RUNNER_DL)" 7 55 0 2>&1 >/dev/tty

# === Vérification des téléchargements ===
if [[ ! -f "$DOWNLOAD_DIR/ge-customv40.tar.xz.001" || ! -f "$DOWNLOAD_DIR/ge-customv40.tar.xz.002" ]]; then
    dialog --backtitle "Foclabroc Toolbox" --infobox "$(tr RUNNER_DL_FAIL)" 5 55 2>&1 >/dev/tty
    exit 1
fi

# === Assemblage des fichiers ===
cd "$DOWNLOAD_DIR" || exit 1
dialog --backtitle "Foclabroc Toolbox" --infobox "$(tr RUNNER_ASSEMBLE)" 5 55 2>&1 >/dev/tty
sleep 1
cat ge-customv40.tar.xz.001 ge-customv40.tar.xz.002 > ge-customv40.tar.xz

if [[ ! -f "ge-customv40.tar.xz" ]]; then
    dialog --backtitle "Foclabroc Toolbox" --infobox "$(tr RUNNER_ASSEMBLE_FAIL)" 5 55 2>&1 >/dev/tty
    exit 1
fi

# === Décompression du .xz ===
dialog --backtitle "Foclabroc Toolbox" --infobox "$(tr RUNNER_UNXZ)" 5 55 2>&1 >/dev/tty
xz -d ge-customv40.tar.xz

if [[ ! -f "ge-customv40.tar" ]]; then
    dialog --backtitle "Foclabroc Toolbox" --infobox "$(tr RUNNER_UNXZ_FAIL)" 5 55 2>&1 >/dev/tty
    exit 1
fi

# === Suppression ancien dossier ===
rm -rf "$FINAL_DIR"

# === Simulation + extraction réelle ===
ARCHIVE="$DOWNLOAD_DIR/ge-customv40.tar"
SIZE_MB=$(du -m "$ARCHIVE" | cut -f1)

(
  # Lance l'extraction réelle en tâche de fond
  tar -xf "$ARCHIVE" -C "$EXTRACT_DIR" &
  TAR_PID=$!

  # Simulation de la progression basée sur la taille
  TOTAL_TIME=$((SIZE_MB / 8))
  [ "$TOTAL_TIME" -lt 4 ] && TOTAL_TIME=8
  [ "$TOTAL_TIME" -gt 45 ] && TOTAL_TIME=90

  STEPS=100
  for i in $(seq 1 $STEPS); do
      echo "$i"
      sleep $(awk "BEGIN {print $TOTAL_TIME/$STEPS}")
  done

  # Attend la fin réelle de l’extraction
  wait $TAR_PID 2>/dev/null
) | dialog --gauge "$(tr RUNNER_EXTRACT "$SIZE_MB")" 7 60 0 2>&1 >/dev/tty

# === Vérification de l'installation ===
if [[ -d "$FINAL_DIR" ]]; then
    dialog --backtitle "Foclabroc Toolbox" \
    --infobox "$(tr RUNNER_OK)" 6 60 2>&1 >/dev/tty
    sleep 3
else
    dialog --backtitle "Foclabroc Toolbox" \
    --infobox "$(tr RUNNER_FAIL)" 4 55 2>&1 >/dev/tty
    exit 1
fi

# === Nettoyage ===
cd /tmp || exit 1
rm -rf "$DOWNLOAD_DIR"

# === Message final ===
dialog --backtitle "Foclabroc Toolbox" --title "$(tr FINAL_TITLE)" \
--msgbox "$(tr FINAL_MSG)" 13 70 2>&1 >/dev/tty
chmod a+x "/userdata/system/pro/fpinball/batocera-config-fpinball"
# === Rafraîchissement des jeux ===
curl -s http://127.0.0.1:1234/reloadgames > /dev/null

exit 0
