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
        en:CONFIRM_TITLE) echo "Confirmation";;
        fr:CONFIRM_TITLE) echo "Confirmation";;
        en:CONFIRM_MSG) echo "\nDo you want to download and install ge-custom V40 ?";;
        fr:CONFIRM_MSG) echo "\nSouhaitez-vous télécharger et installer ge-custom V40 ?";;
        en:RETURN_MENU) echo "\nReturning to Wine Tools menu...";;
        fr:RETURN_MENU) echo "\nRetour Menu Wine Tools...";;
        en:DL_PROGRESS) echo "Downloading ge-custom v40...";;
        fr:DL_PROGRESS) echo "Téléchargement de ge-custom v40 en cours...";;
        en:DL_FAIL) echo "\nError downloading files!";;
        fr:DL_FAIL) echo "\nErreur lors du téléchargement des fichiers!";;
        en:ASSEMBLE) echo "\nAssembling the 2 parts...";;
        fr:ASSEMBLE) echo "\nAssemblage des 2 parties en cours...";;
        en:ASSEMBLE_FAIL) echo "\nAssembly of the 2 parts failed!!!";;
        fr:ASSEMBLE_FAIL) echo "\nEchec de l'assemblage des 2 parties !!!";;
        en:UNXZ) echo "\nDecompressing .xz...";;
        fr:UNXZ) echo "\nDécompression du .xz en cours...";;
        en:UNXZ_FAIL) echo "\nFailed to decompress .xz !!!";;
        fr:UNXZ_FAIL) echo "\nEchec de la décompression du .xz !!!";;
        en:UNTAR) echo "\nExtracting .tar...";;
        fr:UNTAR) echo "\nDécompression du .tar en cours...";;
        en:INSTALL_OK) echo "\nInstallation of ge-custom V40 completed successfully in $2.";;
        fr:INSTALL_OK) echo "\nInstallation de ge-custom V40 terminée avec succès dans $2.";;
        en:INSTALL_FAIL) echo "\nge-custom V40 installation failed!!!";;
        fr:INSTALL_FAIL) echo "\nEchec de l'installation de ge-custom V40 !!!";;
    esac
}

select_language

# Définir les URLs pour les fichiers split
URL_PART1="https://github.com/foclabroc/toolbox/raw/refs/heads/main/wine-tools/ge-customv40.tar.xz.001"
URL_PART2="https://github.com/foclabroc/toolbox/raw/refs/heads/main/wine-tools/ge-customv40.tar.xz.002"

# Définir le répertoire de téléchargement et le chemin de destination pour l'extraction
DOWNLOAD_DIR="/tmp/ge-custom-download"
EXTRACT_DIR="/userdata/system/wine/custom"

# Créer les répertoires
mkdir -p "$DOWNLOAD_DIR"
mkdir -p "$EXTRACT_DIR"

# Demander à l'utilisateur s'il souhaite lancer le téléchargement
dialog --backtitle "Foclabroc Toolbox" --title "$(tr CONFIRM_TITLE)" --yesno "$(tr CONFIRM_MSG)" 7 60 2>&1 >/dev/tty

# Si l'utilisateur appuie sur "Non" (retourne 1)
if [[ $? -eq 1 ]]; then
    (
        dialog --backtitle "Foclabroc Toolbox" --infobox "$(tr RETURN_MENU)" 5 60 2>&1 >/dev/tty
        sleep 1
    ) 2>&1 >/dev/tty
    # Lancer le script précédent (ici tu retournes dans le menu Wine Tools)
    curl -Ls https://raw.githubusercontent.com/foclabroc/toolbox/refs/heads/main/wine-tools/wine.sh | bash
    exit 0
fi

# Téléchargement des 2 parties
(
  echo 10 ; curl -Ls -o "$DOWNLOAD_DIR/ge-customv40.tar.xz.001" "$URL_PART1" --progress-bar && echo 50
  curl -Ls -o "$DOWNLOAD_DIR/ge-customv40.tar.xz.002" "$URL_PART2" --progress-bar && echo 100
) | dialog --gauge "$(tr DL_PROGRESS)" 7 55 0 2>&1 >/dev/tty

# Vérification de la réussite des téléchargements
if [[ ! -f "$DOWNLOAD_DIR/ge-customv40.tar.xz.001" || ! -f "$DOWNLOAD_DIR/ge-customv40.tar.xz.002" ]]; then
    dialog --backtitle "Foclabroc Toolbox" --infobox "$(tr DL_FAIL)" 5 55 2>&1 >/dev/tty
    exit 1
fi

# Assemblage des 2 parties
cd "$DOWNLOAD_DIR"
dialog --backtitle "Foclabroc Toolbox" --infobox "$(tr ASSEMBLE)" 5 55 2>&1 >/dev/tty
sleep 2
cat ge-customv40.tar.xz.001 ge-customv40.tar.xz.002 > ge-customv40.tar.xz

# Vérification de l'assemblage
if [[ ! -f "ge-customv40.tar.xz" ]]; then
    dialog --backtitle "Foclabroc Toolbox" --infobox "$(tr ASSEMBLE_FAIL)" 5 55 2>&1 >/dev/tty
	sleep 2
    exit 1
fi

# Décompression du .xz
dialog --backtitle "Foclabroc Toolbox" --infobox "$(tr UNXZ)" 5 55 2>&1 >/dev/tty
sleep 2
xz -d ge-customv40.tar.xz

# Vérification du fichier décompressé
if [[ ! -f "ge-customv40.tar" ]]; then
    dialog --backtitle "Foclabroc Toolbox" --infobox "$(tr UNXZ_FAIL)" 5 55 2>&1 >/dev/tty
    exit 1
fi

# Suppression ancien dossier
rm -rf /userdata/system/wine/custom/ge-custom

# Décompression du .tar
dialog --backtitle "Foclabroc Toolbox" --infobox "$(tr UNTAR)" 5 55 2>&1 >/dev/tty
tar -xf ge-customv40.tar -C "$EXTRACT_DIR"

# Vérification du fichier extrait
if [[ $? -eq 0 ]]; then
    dialog --backtitle "Foclabroc Toolbox" --infobox "$(tr INSTALL_OK "$EXTRACT_DIR")" 6 60 2>&1 >/dev/tty
    sleep 3
else
    dialog --backtitle "Foclabroc Toolbox" --infobox "$(tr INSTALL_FAIL)" 4 55 2>&1 >/dev/tty
    exit 1
fi

# Nettoyage des fichiers temporaires
cd /tmp || exit 1
rm -rf "$DOWNLOAD_DIR"

# Retourner au script précédent (Menu Wine Tools)
(
    dialog --backtitle "Foclabroc Toolbox" --infobox "$(tr RETURN_MENU)" 5 60 2>&1 >/dev/tty
    sleep 1
) 2>&1 >/dev/tty
curl -Ls https://raw.githubusercontent.com/foclabroc/toolbox/refs/heads/main/wine-tools/wine.sh | bash
exit 0
