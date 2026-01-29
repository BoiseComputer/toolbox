#!/bin/bash

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

    CHOICE=$(dialog --clear --backtitle "Foclabroc Toolbox" --title "Language / Langue" \
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
        en:TITLE) echo "Kodi Pack";;
        fr:TITLE) echo "Pack Kodi";;
        en:CONFIRM) echo "\nFoclabroc Kodi pack installation script (Vstream; IPTV...).\n\nWarning: installing this pack will delete the entire .kodi folder, including all your current settings, and replace them with my pack.\n\nAre you sure you want to install the pack?";;
        fr:CONFIRM) echo "\nScript d'installation pack Kodi Foclabroc. (Vstream; IPTV...)\n\nAttention : l'installation du pack supprimera tout le dossier .kodi \ny compris tous vos paramètres actuels de Kodi, et les remplacera par ceux de mon pack.\n\nÊtes-vous sûr de vouloir installer le pack ?";;
        en:CANCEL) echo "Installation cancelled.";;
        fr:CANCEL) echo "Installation annulée.";;
        en:REMOVE_DIR) echo "Removing .kodi folder...";;
        fr:REMOVE_DIR) echo "Suppression du dossier .Kodi...";;
        en:REMOVED) echo "Folder removed.";;
        fr:REMOVED) echo "Dossier supprimé.";;
        en:DOWNLOADING) echo "Downloading ZIP file...";;
        fr:DOWNLOADING) echo "Téléchargement du fichier ZIP...";;
        en:EXTRACTING) echo "Extracting...";;
        fr:EXTRACTING) echo "Extraction en cours...";;
        en:EXTRACT_DONE) echo "Extraction completed.";;
        fr:EXTRACT_DONE) echo "Extraction terminée.";;
        en:DL_FAIL) echo "Download failed.";;
        fr:DL_FAIL) echo "Échec du téléchargement.";;
        en:CLEANUP) echo "Cleaning temporary files...";;
        fr:CLEANUP) echo "Nettoyage des fichiers temporaire...";;
        en:DONE) echo "Operation completed.";;
        fr:DONE) echo "Opération terminée.";;
        en:FINISH_TITLE) echo "Done";;
        fr:FINISH_TITLE) echo "Terminé";;
        en:FINISH_MSG) echo "Kodi pack installation completed successfully.";;
        fr:FINISH_MSG) echo "Installation du pack Kodi terminée avec succès.";;
    esac
}

select_language

# Définir l'URL du fichier ZIP
ZIP_URL="https://github.com/foclabroc/toolbox/releases/download/Fichiers/kodi.zip"

# Définir le chemin du dossier Kodi
KODI_DIR="/userdata/system/.kodi"

# Affichage d'une boîte de dialogue de confirmation
dialog --backtitle "Foclabroc Toolbox" --title "$(tr TITLE)" \
--yesno "$(tr CONFIRM)" 15 60

# Vérifier la réponse de l'utilisateur
if [ $? -ne 0 ]; then
    echo "$(tr CANCEL)"
    exit 0
fi

clear

# Vérifier si le dossier Kodi existe, puis le supprimer
if [ -d "$KODI_DIR" ]; then
    echo "$(tr REMOVE_DIR)"
    rm -rf "$KODI_DIR"
    echo "$(tr REMOVED)"
fi

# Télécharger le fichier ZIP
echo "$(tr DOWNLOADING)"
wget -q --show-progress -O /tmp/kodi.zip "$ZIP_URL"

# Vérifier si le téléchargement a réussi
if [ $? -eq 0 ]; then
    echo "$(tr EXTRACTING)"
    TOTAL_FILES=$(unzip -l /tmp/kodi.zip | wc -l)
    COUNT=0

unzip -o /tmp/kodi.zip -d /userdata/system/ | while read line; do
    COUNT=$((COUNT + 1))
    PERCENT=$((COUNT * 100 / TOTAL_FILES))
    echo -ne "Progression : $PERCENT%\r"
done

echo -e "\n$(tr EXTRACT_DONE)"
    sleep 2
else
    echo "$(tr DL_FAIL)"
    rm -f /tmp/kodi.zip
    exit 1
fi

# Nettoyage du fichier ZIP
echo "$(tr CLEANUP)"
sleep 1
rm -f /tmp/kodi.zip

echo "$(tr DONE)"
sleep 2

# Affichage du message de confirmation
dialog --backtitle "Foclabroc Toolbox" --title "$(tr FINISH_TITLE)" \
--msgbox "$(tr FINISH_MSG)" 6 50
