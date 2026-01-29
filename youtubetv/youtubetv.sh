#!/bin/bash

LANG_UI="fr"
if [[ "$LANG" == en* ]]; then
    LANG_UI="en"
fi

tr() {
    case "$LANG_UI:$1" in
        en:URL_ERR) echo "Error: Failed to fetch the download URL for YouTube TV.";;
        fr:URL_ERR) echo "Erreur : impossible de récupérer l'URL de téléchargement de YouTube TV.";;
        en:DEBUG) echo "Debugging information:";;
        fr:DEBUG) echo "Informations de debug :";;
        en:INSTALLING) echo "Installation of YouTube TV...";;
        fr:INSTALLING) echo "Installation de YouTube TV...";;
        en:DL_FAIL) echo "Failed to download YouTube TV archive.";;
        fr:DL_FAIL) echo "Échec du téléchargement de l'archive YouTube TV.";;
        en:EXTRACTING) echo "Extracting...";;
        fr:EXTRACTING) echo "Extraction en cours...";;
        en:EXTRACT_DONE) echo "Extraction completed!";;
        fr:EXTRACT_DONE) echo "Extraction terminée !";;
        en:ARCHIVE_ERR) echo "Error: archive is invalid or corrupted.";;
        fr:ARCHIVE_ERR) echo "Erreur : l'archive est invalide ou corrompue.";;
        en:FILES_MOVED) echo "Extraction complete. Files moved to $2.";;
        fr:FILES_MOVED) echo "Extraction terminée. Fichiers déplacés vers $2.";;
        en:CREATE_PORTS) echo "Creating YouTube TV script in Ports...";;
        fr:CREATE_PORTS) echo "Création d'un script YouTube TV dans Ports...";;
        en:DL_KEYS) echo "Downloading keys file...";;
        fr:DL_KEYS) echo "Téléchargement du fichier keys...";;
        en:DL_KEYS_FAIL) echo "Failed to download keys file.";;
        fr:DL_KEYS_FAIL) echo "Échec du téléchargement du fichier keys.";;
        en:DL_KEYS_OK) echo "Keys file downloaded to $2.";;
        fr:DL_KEYS_OK) echo "Fichier keys téléchargé dans $2.";;
        en:REFRESH) echo "Refreshing Ports menu...";;
        fr:REFRESH) echo "Refreshing Ports menu...";;
        en:ADD_GAMELIST) echo "Adding YouTube TV entry to gamelist.xml...";;
        fr:ADD_GAMELIST) echo "Ajout de l'entrée YouTube TV dans gamelist.xml...";;
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
        en:DONE) echo "Installation complete! You can now launch YouTube TV from the Ports menu.";;
        fr:DONE) echo "Installation terminée !! Vous pouvez désormais lancer YouTube TV depuis le menu « Ports ».";;
    esac
}

# Validate app_url
app_url=https://github.com/foclabroc/toolbox/raw/refs/heads/main/youtubetv/extra/YouTubeonTV-linux-x64.zip
if [ -z "$app_url" ]; then
        echo "$(tr URL_ERR)"
        echo "$(tr DEBUG)"
    curl -s https://github.com/foclabroc/toolbox/raw/refs/heads/main/youtubetv/extra/YouTubeonTV-linux-x64.zip
    exit 1
fi

# Download the archive
echo -e "\e[1;34m$(tr INSTALLING)\e[1;37m"
rm -rf /userdata/system/pro/youtubetv 2>/dev/null
rm -rf /userdata/system/pro/youtube-tv 2>/dev/null
mkdir -p "/userdata/system/pro/youtubetv"
app_dir="/userdata/system/pro/youtubetv"
temp_dir="$app_dir/temp"
mkdir -p "$temp_dir"
wget -q --show-progress -O "$temp_dir/youtube-tv.zip" "$app_url"

if [ $? -ne 0 ]; then
    echo "$(tr DL_FAIL)"
    exit 1
fi

echo "$(tr EXTRACTING)"
if unzip -t "$temp_dir/youtube-tv.zip" >/dev/null 2>&1; then
    TOTAL_FILES=$(unzip -l "$temp_dir/youtube-tv.zip" | grep -E '^\s*[0-9]+' | wc -l)
    COUNT=0
    unzip -o "$temp_dir/youtube-tv.zip" -d "$temp_dir/youtube-tv-extracted" | while read -r line; do
        COUNT=$((COUNT + 1))
        PERCENT=$((COUNT * 100 / TOTAL_FILES))
        echo -ne "Progression : $PERCENT% \r"
    done
    echo -e "\n$(tr EXTRACT_DONE)"
    mv "$temp_dir/youtube-tv-extracted/"*/* "$app_dir"
    chmod a+x "$app_dir/YouTubeonTV"
else
    echo "$(tr ARCHIVE_ERR)"
    exit 1
fi

# Cleanup temp files
rm -rf "$temp_dir"
echo "$(tr FILES_MOVED "$app_dir")"

# make Launcher
cat << EOF > "$app_dir/Launcher"
#!/bin/bash
unclutter-remote -s
sed -i "s,!appArgs.disableOldBuildWarning,1 == 0,g" /userdata/system/pro/youtubetv/resources/app/lib/main.js 2>/dev/null && mkdir /userdata/system/pro/youtubetv/home 2>/dev/null; mkdir /userdata/system/pro/youtubetv/config 2>/dev/null; mkdir /userdata/system/pro/youtubetv/roms 2>/dev/null; LD_LIBRARY_PATH="/userdata/system/pro/.dep:${LD_LIBRARY_PATH}" HOME=/userdata/system/pro/youtubetv/home XDG_CONFIG_HOME=/userdata/system/pro/youtubetv/config QT_SCALE_FACTOR="1" GDK_SCALE="1" XDG_DATA_HOME=/userdata/system/pro/youtubetv/home DISPLAY=:0.0 /userdata/system/pro/youtubetv/YouTubeonTV --no-sandbox --test-type "${@}"
EOF
dos2unix "$app_dir/Launcher"
chmod a+x "$app_dir/Launcher"

# .DEP FILES
mkdir -p "/userdata/system/pro/.dep"
wget -q --show-progress -O "/userdata/system/pro/.dep/dep.zip" "https://github.com/foclabroc/toolbox/raw/refs/heads/main/gparted/extra/dep.zip";
cd /userdata/system/pro/.dep/
unzip -o -qq /userdata/system/pro/.dep/dep.zip 2>/dev/null

# Create a launcher script using the original command
echo "$(tr CREATE_PORTS)"
sleep 3
ports_dir="/userdata/roms/ports"
mkdir -p "$ports_dir"

# PURGE PORTS DIR
rm $ports_dir/YouTubeTV.sh 2>/dev/null
rm $ports_dir/YoutubeTV.sh 2>/dev/null
rm $ports_dir/YoutubeTV.sh.keys 2>/dev/null
rm $ports_dir/YouTubeTV.sh.keys 2>/dev/null

cat << EOF > "$ports_dir/YoutubeTV.sh"
#!/bin/bash
unclutter-remote -s
killall -9 YouTubeonTV && unclutter-remote -s
/userdata/system/pro/youtubetv/Launcher
EOF

chmod +x "$ports_dir/YoutubeTV.sh"

# Step 6: Download keys file
echo "$(tr DL_KEYS)"
keys_url="https://raw.githubusercontent.com/foclabroc/toolbox/refs/heads/main/youtubetv/extra/YoutubeTV.sh.keys"
keys_file="$ports_dir/YoutubeTV.sh.keys"
curl -L -o "$keys_file" "$keys_url"

if [ $? -ne 0 ]; then
    echo "$(tr DL_KEYS_FAIL)"
    exit 1
fi

echo "$(tr DL_KEYS_OK "$keys_file")"

# Step 7: Refresh the Ports menu
echo "$(tr REFRESH)"
curl http://127.0.0.1:1234/reloadgames

# Step 8: Add an entry to gamelist.xml
echo "$(tr ADD_GAMELIST)"
gamelist_file="$ports_dir/gamelist.xml"
screenshot_url="https://raw.githubusercontent.com/foclabroc/toolbox/refs/heads/main/youtubetv/extra/YoutubeTV-screenshot.png"
screenshot_path="$ports_dir/images/YoutubeTV-screenshot.png"
logo_url="https://raw.githubusercontent.com/foclabroc/toolbox/refs/heads/main/youtubetv/extra/YoutubeTV-wheel.png"
logo_path="$ports_dir/images/YoutubeTV-wheel.png"
box_url="https://raw.githubusercontent.com/foclabroc/toolbox/refs/heads/main/youtubetv/extra/YoutubeTV-cartridge.png"
box_path="$ports_dir/images/YoutubeTV-cartridge.png"

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

# Add the YouTube TV entry

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
remove_game_by_path "$gamelist_file" "./YoutubeTV.sh"
DESC_EN="YouTube TV for Batocera Linux. Discover what’s watched worldwide: from current music videos to popular videos about gaming, fashion, beauty, news, education, and more."
DESC_FR="Youtube TV pour Batocera Linux. Découvrez les contenus regardés partout dans le monde : des clips musicaux du moment aux vidéos populaires sur les jeux vidéo, la mode, la beauté, les actualités, l'éducation et bien plus encore."
DESC_VALUE="$DESC_FR"
GENRE_VALUE="Divertissement"
LANG_VALUE="fr"
if [ "$LANG_UI" = "en" ]; then
    DESC_VALUE="$DESC_EN"
    GENRE_VALUE="Entertainment"
    LANG_VALUE="en"
fi
xmlstarlet ed -L \
    -s "/gameList" -t elem -n "game" -v "" \
    -s "/gameList/game[last()]" -t elem -n "path" -v "./YoutubeTV.sh" \
    -s "/gameList/game[last()]" -t elem -n "name" -v "Youtube TV" \
        -s "/gameList/game[last()]" -t elem -n "desc" -v "$DESC_VALUE" \
    -s "/gameList/game[last()]" -t elem -n "developer" -v "Youtube" \
    -s "/gameList/game[last()]" -t elem -n "publisher" -v "Youtube" \
        -s "/gameList/game[last()]" -t elem -n "genre" -v "$GENRE_VALUE" \
    -s "/gameList/game[last()]" -t elem -n "rating" -v "1.00" \
    -s "/gameList/game[last()]" -t elem -n "region" -v "eu" \
        -s "/gameList/game[last()]" -t elem -n "lang" -v "$LANG_VALUE" \
    -s "/gameList/game[last()]" -t elem -n "image" -v "./images/YoutubeTV-screenshot.png" \
    -s "/gameList/game[last()]" -t elem -n "wheel" -v "./images/YoutubeTV-wheel.png" \
    -s "/gameList/game[last()]" -t elem -n "thumbnail" -v "./images/YoutubeTV-cartridge.png" \
    "$gamelist_file"

# Refresh the Ports menu
curl http://127.0.0.1:1234/reloadgames

echo
echo -e "\e[1;32m$(tr DONE)\e[1;37m"
echo -e "-----------------------------------------------------------------------------------------"
sleep 5
