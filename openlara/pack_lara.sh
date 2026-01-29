#!/bin/bash

LANG_UI="fr"

select_language() {
    CHOICE=$(dialog --clear --backtitle "Foclabroc Toolbox" --title "Language / Langue" \
        --menu "\nChoose your language / Choisissez votre langue :\n " 12 60 2 \
        1 "English" \
        2 "Français" \
        2>&1 >/dev/tty)

    case $CHOICE in
        1) LANG_UI="en" ;;
        2|"") LANG_UI="fr" ;;
    esac
}

tr() {
    case "$LANG_UI:$1" in
        en:PACK_NAME) echo "OpenLara Pack";;
        fr:PACK_NAME) echo "Pack OpenLara";;
        en:INFO_MSG) echo "!!!Information!!!\n\nMake sure the OpenLara system is enabled in:\n->Collection settings->Shown systems.\n\nAnd that it is not checked in:\n->Collection settings->Grouped systems.";;
        fr:INFO_MSG) echo "!!!Information!!!\n\nAssurez vous que le systeme OpenLara est bien coché dans :\n->Paramètres des collections->systèmes affichés.\n\nEt qu'il n'est pas coché dans :\n->Paramètres des collections->systèmes groupés.";;
        en:CONFIRM) echo "\n$NOM_PACK installation script.\n\nThis will completely delete the folder:\n\n[$INSTALL_DIR]\n\nand replace it with this pack.\n\nDo you want to continue?";;
        fr:CONFIRM) echo "\nScript d'installation du $NOM_PACK.\n\nCela supprimera complètement le dossier :\n\n[$INSTALL_DIR]\n\net le remplacera par ce pack.\n\nSouhaitez-vous continuer ?";;
        en:CLEAN_TITLE) echo "Cleanup";;
        fr:CLEAN_TITLE) echo "Nettoyage";;
        en:DOWNLOADING) echo "\nDownloading $GAME_NAME...";;
        fr:DOWNLOADING) echo "\nTéléchargement de $GAME_NAME...";;
        en:SPEED) echo "\nSpeed: %s MB/s | Progress: %s / %s MB";;
        fr:SPEED) echo "\nVitesse : %s Mo/s | Progression : %s / %s Mo";;
        en:DL_TITLE) echo "Download";;
        fr:DL_TITLE) echo "Téléchargement";;
        en:DL_FAIL) echo "Error: download failed.";;
        fr:DL_FAIL) echo "Erreur : le téléchargement a échoué.";;
        en:EXTRACT_TITLE) echo "Extraction";;
        fr:EXTRACT_TITLE) echo "Décompression";;
        en:EXTRACT_MSG) echo "\nExtracting [$GAME_NAME] to:\n\n[$INSTALL_DIR]";;
        fr:EXTRACT_MSG) echo "\nExtraction de [$GAME_NAME] dans :\n\n[$INSTALL_DIR]";;
        en:FINISH_TITLE) echo "Installation complete";;
        fr:FINISH_TITLE) echo "Installation terminée";;
        en:FINISH_MSG) echo "\nThe $NOM_PACK has been installed successfully!\n\n$INFO_MSG";;
        fr:FINISH_MSG) echo "\nLe $NOM_PACK a été installé avec succès !\n\n$INFO_MSG";;
    esac
}

select_language

# ========== Variables globales ==========
NOM_PACK="$(tr PACK_NAME)"
URL_ZIP="https://github.com/foclabroc/toolbox/releases/download/Fichiers/openlara.zip"
FICHIER_ZIP="/tmp/openlara.zip"
DEST_DIR="/userdata/roms"
INSTALL_DIR="$DEST_DIR/openlara"
DIALOG_BACKTITLE="Foclabroc Toolbox"
GAME_NAME="OpenLara"
INFO_MSG="$(tr INFO_MSG)"
# ========================================

# Boîte de confirmation
dialog --backtitle "$DIALOG_BACKTITLE" --title "$NOM_PACK" \
--yesno "$(tr CONFIRM)" 15 60 || exit 0

clear

# Suppression de l'ancien dossier
if [ -d "$INSTALL_DIR" ]; then
    {
        echo "XXX"
        echo -e "\n\nSuppression de l'ancien dossier $GAME_NAME..."
        echo "XXX"
        for i in {0..100}; do
            echo "$i"; sleep 0.01
        done
    } | dialog --backtitle "$DIALOG_BACKTITLE" --title "$(tr CLEAN_TITLE)" --gauge "" 8 50

    rm -rf "$INSTALL_DIR"
    sleep 0.5
fi

# Fonction de téléchargement avec progression et vitesse
telechargement_zip() {
    FILE_PATH="$FICHIER_ZIP"
    FILE_SIZE=$(curl -sIL "$URL_ZIP" | grep -i Content-Length | tail -1 | awk '{print $2}' | tr -d '\r')
    [ -z "$FILE_SIZE" ] && FILE_SIZE=0

    START_TIME=$(date +%s)

    curl -sL -o "$FILE_PATH" "$URL_ZIP" &
    PID_CURL=$!

    (
        while kill -0 $PID_CURL 2>/dev/null; do
            if [ -f "$FILE_PATH" ] && [ "$FILE_SIZE" -gt 0 ]; then
                CURRENT_SIZE=$(stat -c%s "$FILE_PATH" 2>/dev/null)
                NOW=$(date +%s)
                ELAPSED=$((NOW - START_TIME))
                [ "$ELAPSED" -eq 0 ] && ELAPSED=1
                SPEED_MO=$(echo "scale=2; $CURRENT_SIZE / $ELAPSED / 1048576" | bc)
                CURRENT_MB=$((CURRENT_SIZE / 1024 / 1024))
                TOTAL_MB=$((FILE_SIZE / 1024 / 1024))
                PROGRESS_DL=$((CURRENT_SIZE * 100 / FILE_SIZE))
                PROGRESS=$((10 + PROGRESS_DL))
                [ "$PROGRESS" -gt 100 ] && PROGRESS=100

                echo "XXX"
                echo -e "$(tr DOWNLOADING)"
                SPEED_MSG=$(printf "$(tr SPEED)" "$SPEED_MO" "$CURRENT_MB" "$TOTAL_MB")
                echo -e "$SPEED_MSG"
                echo "XXX"
                echo "$PROGRESS"
            fi
            sleep 0.2
        done
    ) | dialog --backtitle "$DIALOG_BACKTITLE" --title "$(tr DL_TITLE)" --gauge "" 10 60 0 2>&1 >/dev/tty

    wait $PID_CURL

    if [ ! -s "$FILE_PATH" ]; then
        dialog --backtitle "$DIALOG_BACKTITLE" --msgbox "$(tr DL_FAIL)" 6 50 2>&1 >/dev/tty
        exit 1
    fi
}

# Fonction d’extraction avec progression réelle
extraction_zip() {
    TOTAL_FILES=$(unzip -l "$FICHIER_ZIP" | grep -E "^\s*[0-9]" | wc -l)
    [ "$TOTAL_FILES" -eq 0 ] && TOTAL_FILES=1
    COUNT=0

    (
        unzip -o "$FICHIER_ZIP" -d "$DEST_DIR" | while read -r line; do
            COUNT=$((COUNT + 1))
            PERCENT=$((COUNT * 100 / TOTAL_FILES))
            [ "$PERCENT" -gt 100 ] && PERCENT=100

            echo "XXX"
            echo "$PERCENT"
            echo "$(tr EXTRACT_MSG)"
            echo "XXX"
        done
    ) | dialog --backtitle "$DIALOG_BACKTITLE" --title "$(tr EXTRACT_TITLE)" --gauge "" 10 60 0 2>&1 >/dev/tty

    rm -f "$FICHIER_ZIP"
}

# Lancer les étapes
telechargement_zip
extraction_zip

# Message final
dialog --backtitle "$DIALOG_BACKTITLE" --title "$(tr FINISH_TITLE)" \
--msgbox "$(tr FINISH_MSG)" 16 80
curl -s http://127.0.0.1:1234/reloadgames
clear
exit 0
