#!/bin/bash

LANG_UI="${LANG_UI:-}"
LANG_FILE="/userdata/system/pro/lang_ui"

if [ -z "$LANG_UI" ] && [ -f "$LANG_FILE" ]; then
    LANG_UI="$(cat "$LANG_FILE" 2>/dev/null)"
fi

if [ -n "$LANG_UI" ]; then
    export LANG_UI
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

    mkdir -p "$(dirname "$LANG_FILE")"
    echo "$LANG_UI" > "$LANG_FILE"
    export LANG_UI
}

tr() {
    case "$LANG_UI:$1" in
        en:REMOVE_OLD) echo "Removing old $2 if present...";;
        fr:REMOVE_OLD) echo "Suppression ancien $2 si existant...";;
        en:DOWNLOADING) echo "Downloading $2...";;
        fr:DOWNLOADING) echo "Téléchargement de $2...";;
        en:SPEED) echo "Speed: $2 MB/s | Downloaded: $3 / $4 MB";;
        fr:SPEED) echo "Vitesse : $2 Mo/s | Téléchargé : $3 / $4 Mo";;
        en:UNZIP) echo "Extracting $2...";;
        fr:UNZIP) echo "Décompression de $2...";;
        en:PAD2KEY) echo "Downloading pad2key...";;
        fr:PAD2KEY) echo "Téléchargement du pad2key...";;
        en:INSTALL_TITLE) echo "Installing $2";;
        fr:INSTALL_TITLE) echo "Installation de $2";;
        en:INSTALL_GAUGE) echo "\nDownloading and installing $2...";;
        fr:INSTALL_GAUGE) echo "\nTéléchargement et installation de $2 en cours...";;
        en:GAMELIST_TITLE) echo "Gamelist update";;
        fr:GAMELIST_TITLE) echo "Edition du gamelist";;
        en:GAMELIST_GAUGE) echo "\nAdding images and video to Windows gamelist...";;
        fr:GAMELIST_GAUGE) echo "\nAjout images et video au gamelist windows...";;
        en:DONE_TITLE) echo "Installation complete";;
        fr:DONE_TITLE) echo "Installation terminée";;
        en:DONE_MSG) echo "\n$2 has been added to Windows!\n\nRemember to update game lists to see it in the menu.\n$3";;
        fr:DONE_MSG) echo "\n$2 a été ajouté dans windows !\n\nPensez à mettre à jour les listes de jeux pour le voir apparaître dans le menu. \n$3";;
    esac
}

select_language

if [ "$LANG_UI" = "en" ]; then
    export LANG=en_US.UTF-8
    export LC_ALL=en_US.UTF-8
else
    export LANG=fr_FR.UTF-8
    export LC_ALL=fr_FR.UTF-8
fi

##############################################################################################################
##############################################################################################################
# VARIABLE DU JEU
URL_TELECHARGEMENT="https://github.com/foclabroc/toolbox/releases/download/Fichiers/Celeste.wsquashfs"
URL_TELECHARGEMENT_KEY=""
CHEMIN_SCRIPT=""
FICHIER_ZIP=""
PORTS_DIR="/userdata/roms/ports"
WIN_DIR="/userdata/roms/windows"
GAME_FILE="Celeste.wsquashfs"
GAME_FILE_FINAL="Celeste.wsquashfs"
INFO_MESSAGE=""
##############################################################################################################
##############################################################################################################
# VARIABLES GAMELIST
IMAGE_BASE_URL="https://raw.githubusercontent.com/foclabroc/toolbox/refs/heads/main/_images"
GAME_NAME="Celeste-pico8"
GIT_NAME="celeste"
DESC=""
DEV="Matt Thorson"
PUBLISH="Noel Berry"
GENRE="Plateforme"
LANG=""
REGION="eu"
########################################
IMAGE_DIR="$WIN_DIR/images"
VIDEO_DIR="$WIN_DIR/videos"
SCREENSHOT="$IMAGE_DIR/$GIT_NAME-s.png"
WHEEL="$IMAGE_DIR/$GIT_NAME-w.png"
THUMBNAIL="$IMAGE_DIR/$GIT_NAME-b.png"
VIDEO="$VIDEO_DIR/$GIT_NAME-v.mp4"

if [ "$LANG_UI" = "en" ]; then
    DESC="Help Madeline survive her inner demons on Mount Celeste in this tough-as-nails platformer. Brave hundreds of hand-crafted challenges, uncover hidden secrets, and piece together the mountain's mystery."
    LANG="en"
    INFO_MESSAGE=""
else
    DESC="Aidez Madeline à survivre à ses démons intérieurs au mont Celeste, dans ce jeu de plateformes ultra relevé. Relevez des centaines de défis faits à la main, découvrez tous les secrets et dévoilez le mystère de la montagne."
    LANG="fr"
    INFO_MESSAGE=""
fi

##############################################################################################################
##############################################################################################################
#XMLSTARLET VARIABLES
GAMELIST_FILE="$WIN_DIR/gamelist.xml"
XMLSTARLET_DIR="/userdata/system/pro/extra"
XMLSTARLET_BIN="$XMLSTARLET_DIR/xmlstarlet"
XMLSTARLET_SYMLINK="/usr/bin/xmlstarlet"
CUSTOM_SH="/userdata/system/custom.sh"
##############################################################################################################

# Fonction de chargement
afficher_barre_progression() {
    TMP_FILE=$(mktemp)

    FILE_PATH="$WIN_DIR/$GAME_FILE"
    FILE_PATH_PC="$WIN_DIR/$GAME_FILE_FINAL"
    if [ -f "$FILE_PATH" ]; then
        rm -f "$FILE_PATH"
        rm -rf "$FILE_PATH_PC"
    fi

    (
        echo "XXX"
        echo -e "\n\n$(tr REMOVE_OLD "$GAME_NAME")"
        echo "XXX"
        for i in {0..10}; do
            echo "$i"; sleep 0.10
        done
        mkdir -p "$WIN_DIR"

        FILE_SIZE=$(curl -sIL "$URL_TELECHARGEMENT" | grep -i Content-Length | tail -1 | awk '{print $2}' | tr -d '\r')
        [ -z "$FILE_SIZE" ] && FILE_SIZE=0

        curl -sL "$URL_TELECHARGEMENT" -o "$FILE_PATH" &
        PID_CURL=$!
        START_TIME=$(date +%s)

        while kill -0 $PID_CURL 2>/dev/null; do
            if [ -f "$FILE_PATH" ] && [ "$FILE_SIZE" -gt 0 ]; then
                CURRENT_SIZE=$(stat -c%s "$FILE_PATH" 2>/dev/null)
                NOW=$(date +%s)
                ELAPSED=$((NOW - START_TIME))
                [ "$ELAPSED" -eq 0 ] && ELAPSED=1
                SPEED_MO=$(echo "scale=2; $CURRENT_SIZE / $ELAPSED / 1048576" | bc)
                CURRENT_MB=$((CURRENT_SIZE / 1024 / 1024))
                TOTAL_MB=$((FILE_SIZE / 1024 / 1024))
                PROGRESS_DL=$((CURRENT_SIZE * 90 / FILE_SIZE))  # 90 pts = 10 à 100
                PROGRESS=$((10 + PROGRESS_DL))
                [ "$PROGRESS" -gt 100 ] && PROGRESS=100

                echo "XXX"
                echo -e "\n\n$(tr DOWNLOADING "$GAME_NAME")"
                echo -e "\n$(tr SPEED "${SPEED_MO}" "${CURRENT_MB}" "${TOTAL_MB}")"
                echo "XXX"
                echo "$PROGRESS"
            fi
            sleep 0.5
        done

        wait $PID_CURL

        if [[ "$FILE_PATH" == *.zip ]]; then
            echo "XXX"
            echo -e "\n\n$(tr UNZIP "$GAME_NAME")"
            echo "XXX"
            for i in {0..100..2}; do
                echo "$i"; sleep 0.05
            done
            unzip -o "$FILE_PATH" -d "$WIN_DIR" >/dev/null 2>&1
            rm -f "$FILE_PATH"
        fi

        if [ -n "$URL_TELECHARGEMENT_KEY" ]; then
            echo "XXX"
            echo -e "\n\n$(tr PAD2KEY)"
            echo "XXX"
            curl -L --progress-bar "$URL_TELECHARGEMENT_KEY" -o "$WIN_DIR/${GAME_FILE}.keys" > /dev/null 2>&1
            for i in {0..100..2}; do
                echo "$i"; sleep 0.01
            done
        fi

    ) |
    dialog --backtitle "Foclabroc Toolbox" \
           --title "$(tr INSTALL_TITLE "$GAME_NAME")" \
           --gauge "$(tr INSTALL_GAUGE "$GAME_NAME")" 10 60 0 \
           2>&1 >/dev/tty

    rm -f "$TMP_FILE"
}

# Fonction edit gamelist
ajouter_entree_gamelist() {
    (
        for i in {1..50..1}; do
            echo "$i"; sleep 0.01
        done
        mkdir -p "$IMAGE_DIR"
        mkdir -p "$VIDEO_DIR"
        curl -s -L -o "$WHEEL" "$IMAGE_BASE_URL/$GIT_NAME-w.png"
        echo "51"; sleep 0.1
        curl -s -L -o "$SCREENSHOT" "$IMAGE_BASE_URL/$GIT_NAME-s.png"
        echo "52"; sleep 0.1
        curl -s -L -o "$THUMBNAIL" "$IMAGE_BASE_URL/$GIT_NAME-b.png"
        echo "53"; sleep 0.1
        curl -s -L -o "$VIDEO" "$IMAGE_BASE_URL/$GIT_NAME-v.mp4"
        for i in {54..64..2}; do
            echo "$i"; sleep 0.1
        done

        if [ ! -f "$GAMELIST_FILE" ]; then
            echo '<?xml version="1.0" encoding="UTF-8"?><gameList></gameList>' > "$GAMELIST_FILE"
        fi

        echo "65"; sleep 0.1

        if [ ! -f "$XMLSTARLET_BIN" ]; then
            mkdir -p "$XMLSTARLET_DIR"
            curl -s -L "https://github.com/foclabroc/toolbox/raw/refs/heads/main/app/xmlstarlet" -o "$XMLSTARLET_BIN"
            chmod +x "$XMLSTARLET_BIN"
            ln -sf "$XMLSTARLET_BIN" "$XMLSTARLET_SYMLINK"
            if [ ! -f "$CUSTOM_SH" ]; then
                echo "#!/bin/bash" > "$CUSTOM_SH"
                chmod +x "$CUSTOM_SH"
            fi
            if ! grep -q "ln -sf $XMLSTARLET_BIN $XMLSTARLET_SYMLINK" "$CUSTOM_SH"; then
                echo "ln -sf $XMLSTARLET_BIN $XMLSTARLET_SYMLINK" >> "$CUSTOM_SH"
            fi
        fi

        for i in {66..94..1}; do
            echo "$i"; sleep 0.01
        done

        xmlstarlet ed -L \
            -s "/gameList" -t elem -n "game" -v "" \
            -s "/gameList/game[last()]" -t elem -n "path" -v "./$GAME_FILE_FINAL" \
            -s "/gameList/game[last()]" -t elem -n "name" -v "$GAME_NAME" \
            -s "/gameList/game[last()]" -t elem -n "desc" -v "$DESC" \
            -s "/gameList/game[last()]" -t elem -n "image" -v "./images/$GIT_NAME-s.png" \
            -s "/gameList/game[last()]" -t elem -n "video" -v "./videos/$GIT_NAME-v.mp4" \
            -s "/gameList/game[last()]" -t elem -n "marquee" -v "./images/$GIT_NAME-w.png" \
            -s "/gameList/game[last()]" -t elem -n "thumbnail" -v "./images/$GIT_NAME-b.png" \
            -s "/gameList/game[last()]" -t elem -n "rating" -v "1.00" \
            -s "/gameList/game[last()]" -t elem -n "developer" -v "$DEV" \
            -s "/gameList/game[last()]" -t elem -n "publisher" -v "$PUBLISH" \
            -s "/gameList/game[last()]" -t elem -n "genre" -v "$GENRE" \
            -s "/gameList/game[last()]" -t elem -n "lang" -v "$LANG" \
            -s "/gameList/game[last()]" -t elem -n "region" -v "$REGION" \
            "$GAMELIST_FILE"

        for i in {95..99..2}; do
            echo "$i"; sleep 0.1
        done
        echo "100"; sleep 0.2
    ) |
    dialog --backtitle "Foclabroc Toolbox" --title "$(tr GAMELIST_TITLE)" --gauge "$(tr GAMELIST_GAUGE)" 8 60 0 2>&1 >/dev/tty
}

# Exécution
afficher_barre_progression
ajouter_entree_gamelist

# Message de fin
dialog --backtitle "Foclabroc Toolbox" --title "$(tr DONE_TITLE)" --msgbox "$(tr DONE_MSG "$GAME_NAME" "$INFO_MESSAGE")" 13 60 2>&1 >/dev/tty
clear
