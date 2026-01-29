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
        en:MENU_TITLE) echo "Wine Toolbox";;
        fr:MENU_TITLE) echo "Wine Toolbox";;
        en:MENU_PROMPT) echo "\nChoose an option:\n ";;
        fr:MENU_PROMPT) echo "\nChoisissez une option:\n ";;
        en:OPT1) echo "Download Wine Runner (vanilla/regular) builds [Kron4ek/Wine-Builds]";;
        fr:OPT1) echo "Telechargement Runner Wine (vanilla/regular) builds [Kron4ek/Wine-Builds]";;
        en:OPT2) echo "Download Wine-TKG-Staging Runner builds [Kron4ek/Wine-Builds/tkg]";;
        fr:OPT2) echo "Telechargement Runner Wine-TKG-Staging builds [Kron4ek/Wine-Builds/tkg]";;
        en:OPT3) echo "Download Wine-GE Custom Runner builds [GloriousEggroll/wine-ge-custom]";;
        fr:OPT3) echo "Telechargement Runner Wine-GE Custom builds [GloriousEggroll/wine-ge-custom]";;
        en:OPT4) echo "Download GE-Proton Runner builds [GloriousEggroll/proton-ge-custom]";;
        fr:OPT4) echo "Telechargement Runner GE-Proton builds [GloriousEggroll/proton-ge-custom]";;
        en:OPT5) echo "Download GE-Custom Runner V40 (keep old bottles/saves)";;
        fr:OPT5) echo "Telechargement Runner GE-Custom de la V40 (pour garder vos anciennes bottles/sauvegarde)";;
        en:OPT6) echo "Install custom Winetricks";;
        fr:OPT6) echo "Installation de Winetricks personnalisé";;
        en:OPT7) echo "Convert .pc folder to .wine folder";;
        fr:OPT7) echo "Convertir dossier .pc en dossier .wine";;
        en:OPT8) echo "Compress .wine folder into .wsquashfs or .tgz";;
        fr:OPT8) echo "Compresser dossier .wine en fichier .wsquashfs ou .tgz";;
        en:OPT9) echo "Decompress .wsquashfs/.wtgz into .wine folder";;
        fr:OPT9) echo "Decompresser fichiers .wsquashfs ou .wtgz en dossier .wine";;
        en:OPT10) echo "Delete unused custom runners in /system/wine/custom";;
        fr:OPT10) echo "Suppression de runners custom inutiles dans /system/wine/custom";;
        en:OPT11) echo "Delete .wine/.wsquashfs/.wtgz bottles in /system/wine-bottle/windows";;
        fr:OPT11) echo "Suppression de bouteilles .wine .wsquashfs .wtgz dans /system/wine-bottle/windows";;
        en:INVALID) echo "Invalid choice or no choice made. Exiting.";;
        fr:INVALID) echo "Choix invalide ou annulé. Fermeture.";;
    esac
}

select_language

# Define the options
OPTIONS=(
    "1" "$(tr OPT1)"
    "2" "$(tr OPT2)"
    "3" "$(tr OPT3)"
    "4" "$(tr OPT4)"
    "5" "$(tr OPT5)"
    "6" "$(tr OPT6)"
    "7" "$(tr OPT7)"
    "8" "$(tr OPT8)"
    "9" "$(tr OPT9)"
    "10" "$(tr OPT10)"
    "11" "$(tr OPT11)"
)

# Use dialog to display the menu
CHOICE=$(dialog --clear --backtitle "Foclabroc Toolbox" \
                --title "$(tr MENU_TITLE)" \
                --menu "$(tr MENU_PROMPT)" \
               22 106 11 \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

# Clear the dialog artifacts
clear

# Run the appropriate script based on the user's choice
case $CHOICE in
    1)
        #echo "Liste Wine Vanilla and Proton."
        curl -Ls https://raw.githubusercontent.com/foclabroc/toolbox/refs/heads/main/wine-tools/vanilla.sh | bash
        ;;
    2)
        #echo "Liste Wine-tkg staging."
        curl -Ls https://raw.githubusercontent.com/foclabroc/toolbox/refs/heads/main/wine-tools/tkg.sh | bash
        ;;
    3)
        #echo "Liste Wine-GE Custom."
        curl -Ls https://raw.githubusercontent.com/foclabroc/toolbox/refs/heads/main/wine-tools/wine-ge.sh | bash
        ;;
    4)
        #echo "Liste GE-Proton."
        curl -Ls https://raw.githubusercontent.com/foclabroc/toolbox/refs/heads/main/wine-tools/ge-proton.sh | bash
        ;;
    5)
        #echo "Ge-custom V40."
        curl -Ls https://raw.githubusercontent.com/foclabroc/toolbox/refs/heads/main/wine-tools/v40wine.sh | bash
        ;;
    6)
        #echo "Winetricks."
        curl -Ls https://raw.githubusercontent.com/foclabroc/toolbox/refs/heads/main/wine-tools/tricks.sh | bash
        ;;
    7)
        #echo ".pc to .wine."
        curl -Ls https://raw.githubusercontent.com/foclabroc/toolbox/refs/heads/main/wine-tools/pc-to-wine.sh | bash
        ;;
    8)
        #echo ".wine to .squashFS."
        curl -Ls https://raw.githubusercontent.com/foclabroc/toolbox/refs/heads/main/wine-tools/squash.sh | bash
        ;;
    9)
        #echo ".squashFS to .wine."
        curl -Ls https://raw.githubusercontent.com/foclabroc/toolbox/refs/heads/main/wine-tools/unsquash.sh | bash
        ;;
    10)
        #echo "Suppression runner."
        curl -Ls https://raw.githubusercontent.com/foclabroc/toolbox/refs/heads/main/wine-tools/delete-runner.sh | bash
        ;;
    11)
        #echo "Suppression bottle"
        curl -Ls https://raw.githubusercontent.com/foclabroc/toolbox/refs/heads/main/wine-tools/delete-bottle.sh | bash
        ;;
    *)
        echo "$(tr INVALID)"
        ;;
esac
