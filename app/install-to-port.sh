#!/bin/bash

LANG_UI="fr"
if [[ "$LANG" == en* ]]; then
    LANG_UI="en"
fi

tr() {
    case "$LANG_UI:$1" in
        en:ARCH_ERR) echo "This script only runs on AMD or Intel (x86_64) CPUs, not on $2.";;
        fr:ARCH_ERR) echo "Ce script ne fonctionne que sur les processeurs AMD/Intel (x86_64), pas sur $2.";;
        en:INSTALLING) echo "Installing Foclabroc Toolbox in Ports...";;
        fr:INSTALLING) echo "Installation de Foclabroc-toolbox dans Ports...";;
        en:REFRESH) echo "Refreshing Ports menu...";;
        fr:REFRESH) echo "Refreshing Ports menu...";;
        en:ADD_GAMELIST) echo "Adding toolbox to gamelist.xml...";;
        fr:ADD_GAMELIST) echo "Ajout toolbox dans le gamelist.xml...";;
        en:XML_ALREADY) echo "XMLStarlet is already installed, continuing...";;
        fr:XML_ALREADY) echo "XMLStarlet est déjà installé, passage à la suite...";;
        en:XML_INSTALL) echo "Installing XMLStarlet (for gamelist editing)...";;
        fr:XML_INSTALL) echo "Installation de XMLStarlet (pour l'édition du gamelist)...";;
        en:XML_DL) echo "Downloading XMLStarlet...";;
        fr:XML_DL) echo "Téléchargement de XMLStarlet...";;
        en:XML_CHMOD) echo "Making XMLStarlet executable...";;
        fr:XML_CHMOD) echo "Rendre XMLStarlet exécutable...";;
        en:XML_SYMLINK) echo "Creating symlink in /usr/bin/xmlstarlet for immediate use...";;
        fr:XML_SYMLINK) echo "Création du lien symbolique dans /usr/bin/xmlstarlet pour un usage immédiat...";;
        en:INSTALL_DONE) echo "Foclabroc Toolbox installed successfully in Ports.";;
        fr:INSTALL_DONE) echo "Foclabroc-Toolbox Installé avec succés dans Ports.";;
    esac
}

# Get the machine hardware name
architecture=$(uname -m)

# Check if the architecture is x86_64 (AMD/Intel)
if [ "$architecture" != "x86_64" ]; then
    echo "$(tr ARCH_ERR "$architecture")"
    exit 1
fi

# Check if /userdata/system/pro does not exist and create it if necessary
if [ ! -d "/userdata/system/pro" ]; then
    mkdir -p /userdata/system/pro
fi


echo "$(tr INSTALLING)"
sleep 3
# Add Foclabroc-tool.sh to "ports"
curl -L https://raw.githubusercontent.com/foclabroc/toolbox/refs/heads/main/app/foclabroc-tools.sh -o /userdata/roms/ports/foclabroc-tools.sh

# Add Foclabroc-tool.keys to "ports"
curl -L  https://raw.githubusercontent.com/foclabroc/toolbox/refs/heads/main/app/foclabroc-tools.sh.keys -o /userdata/roms/ports/foclabroc-tools.sh.keys

# Set execute permissions for the downloaded scripts
chmod +x /userdata/roms/ports/foclabroc-tools.sh

# Refresh the Ports menu
echo "$(tr REFRESH)"
curl http://127.0.0.1:1234/reloadgames

# Add an entry to gamelist.xml#################################xmledit#########################################################
ports_dir="/userdata/roms/ports"
mkdir -p "$ports_dir"
echo "$(tr ADD_GAMELIST)"
gamelist_file="$ports_dir/gamelist.xml"
screenshot_url="https://raw.githubusercontent.com/foclabroc/toolbox/refs/heads/main/app/foctool-screenshot.jpg"
screenshot_path="$ports_dir/images/foctool-screenshot.jpg"
logo_url="https://raw.githubusercontent.com/foclabroc/toolbox/refs/heads/main/app/foctool-wheel.png"
logo_path="$ports_dir/images/foctool-wheel.png"
box_url="https://raw.githubusercontent.com/foclabroc/toolbox/refs/heads/main/app/foctool-box.png"
box_path="$ports_dir/images/foctool-box.png"

# Ensure the logo directory exists and download the logo
mkdir -p "$(dirname "$logo_path")"
curl -L -o "$logo_path" "$logo_url"
mkdir -p "$(dirname "$screenshot_path")"
curl -L -o "$screenshot_path" "$screenshot_url"
mkdir -p "$(dirname "$box_path")"
curl -L -o "$box_path" "$box_url"

# Ensure the gamelist.xml exists
if [ ! -f "$gamelist_file" ]; then
    echo '<?xml version="1.0" encoding="UTF-8"?><gameList></gameList>' > "$gamelist_file"
fi

curl http://127.0.0.1:1234/reloadgames

# Installation de xmlstarlet si absent.
XMLSTARLET_DIR="/userdata/system/pro/extra"
XMLSTARLET_BIN="$XMLSTARLET_DIR/xmlstarlet"
XMLSTARLET_URL="https://github.com/foclabroc/toolbox/raw/refs/heads/main/app/xmlstarlet"
XMLSTARLET_SYMLINK="/usr/bin/xmlstarlet"
CUSTOM_SH="/userdata/system/custom.sh"

if [ -f "$XMLSTARLET_BIN" ]; then
    echo -e "\e[1;34m$(tr XML_ALREADY)\e[1;37m"
else
    echo -e "\e[1;34m$(tr XML_INSTALL)\e[1;37m"
    mkdir -p "$XMLSTARLET_DIR"

    echo "$(tr XML_DL)"
    curl -# -L "$XMLSTARLET_URL" -o "$XMLSTARLET_BIN"

    echo "$(tr XML_CHMOD)"
    chmod +x "$XMLSTARLET_BIN"

    echo "$(tr XML_SYMLINK)"
    ln -sf "$XMLSTARLET_BIN" "$XMLSTARLET_SYMLINK"

    # Assure-toi que le fichier custom.sh existe
    if [ ! -f "$CUSTOM_SH" ]; then
        echo "#!/bin/bash" > "$CUSTOM_SH"
        chmod +x "$CUSTOM_SH"
    fi

    # Ajoute la création du lien symbolique au démarrage (si non déjà présent)
    if ! grep -q "ln -sf $XMLSTARLET_BIN $XMLSTARLET_SYMLINK" "$CUSTOM_SH"; then
        echo "ln -sf $XMLSTARLET_BIN $XMLSTARLET_SYMLINK" >> "$CUSTOM_SH"
    fi
fi
remove_game_by_path() {
    local file="$1"
    local gamepath="$2"

    xmlstarlet ed -L -d "/gameList/game[path='$gamepath']" "$file" 2>/dev/null
}

remove_game_by_path "$gamelist_file" "./foclabroc-tools.sh"
DESC_EN="Foclabroc toolbox for easy installation of various packs and tools for Batocera Linux"
DESC_FR="Boite à outils de Foclabroc permettant l'installation facile de divers pack et outils pour Batocera Linux"
DESC_VALUE="$DESC_FR"
LANG_VALUE="fr"
if [ "$LANG_UI" = "en" ]; then
    DESC_VALUE="$DESC_EN"
    LANG_VALUE="en"
fi
xmlstarlet ed -L \
    -s "/gameList" -t elem -n "game" -v "" \
    -s "/gameList/game[last()]" -t elem -n "path" -v "./foclabroc-tools.sh" \
    -s "/gameList/game[last()]" -t elem -n "name" -v "Foclabroc Toolbox" \
        -s "/gameList/game[last()]" -t elem -n "desc" -v "$DESC_VALUE" \
    -s "/gameList/game[last()]" -t elem -n "developer" -v "Foclabroc" \
    -s "/gameList/game[last()]" -t elem -n "publisher" -v "Foclabroc" \
    -s "/gameList/game[last()]" -t elem -n "genre" -v "Toolbox" \
    -s "/gameList/game[last()]" -t elem -n "rating" -v "1.00" \
    -s "/gameList/game[last()]" -t elem -n "region" -v "eu" \
    -s "/gameList/game[last()]" -t elem -n "lang" -v "$LANG_VALUE" \
    -s "/gameList/game[last()]" -t elem -n "image" -v "./images/foctool-screenshot.jpg" \
    -s "/gameList/game[last()]" -t elem -n "marquee" -v "./images/foctool-wheel.png" \
    -s "/gameList/game[last()]" -t elem -n "thumbnail" -v "./images/foctool-box.png" \
    "$gamelist_file"
# Add an entry to gamelist.xml#################################xmledit#########################################################

killall -9 emulationstation

sleep 1


echo -e "\e[1;32m$(tr INSTALL_DONE)\e[1;37m"
sleep 2
