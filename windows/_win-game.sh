#!/bin/bash

export DIALOGRC="/userdata/system/pro/extra/.dialogrc"
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
        en:MENU_TITLE) echo "Available Games";;
        fr:MENU_TITLE) echo "Jeux disponibles";;
        en:MENU_PROMPT) echo "\nSelect a game to install:\n ";;
        fr:MENU_PROMPT) echo "\nSélectionnez un jeu à installer :\n ";;
        en:CONFIRM_TITLE) echo "Confirmation";;
        fr:CONFIRM_TITLE) echo "Confirmation";;
        en:CONFIRM_MSG) echo "\nDo you really want to install:\n\n$2";;
        fr:CONFIRM_MSG) echo "\nVoulez-vous vraiment installer :\n\n$2";;
        en:SERVER_ERR) echo "\nUnable to reach the server to download the script. Check your connection.";;
        fr:SERVER_ERR) echo "\nImpossible de joindre le serveur pour télécharger le script. Vérifiez la connexion.";;
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

base_url="https://raw.githubusercontent.com/foclabroc/toolbox/refs/heads/main/windows"

declare -A jeux
if [ "$LANG_UI" = "en" ]; then
    jeux["->Celeste 64"]="Madeline's return in 3D. (39.8MB)###c64.sh"
    jeux["->Celeste pico8"]="Help Madeline survive her inner demons on Mount Celeste. (14.8MB)###celeste.sh"
    jeux["->Crash Bandicoot bit"]="Fan-made Crash Bandicoot with custom level editor. (230MB)###cbit.sh"
    jeux["->Donkey Kong Advanced"]="A remake of the classic arcade game. (19.4MB)###dka.sh"
    jeux["->TMNT Rescue Palooza"]="TMNT: Rescue-Palooza is a free beat-em-up. (168MB)###tmntrp.sh"
    jeux["->Spelunky"]="2D platformer where you play a spelunker. (24.2MB)###spelunky.sh"
    jeux["->Sonic Triple Trouble"]="Fangame based on Sonic Triple Trouble (Game Gear). (115MB)###stt.sh"
    jeux["->Pokemon Uranium"]="Fangame based on the Pokémon series. (332MB)###pokeura.sh"
    jeux["->MiniDoom 2"]="Tribute game that turns DOOM into an action platformer. (114MB)###minidoom2.sh"
    jeux["->AM2R"]="Another Metroid 2 Remake, fan remake of Metroid II. (85.6MB)###am2r.sh"
    jeux["->Megaman X II"]="Mega Man X Innocent Impulse fangame in 8-bit style. (354MB)###mmxii.sh"
    jeux["->Super Tux Kart"]="Mario Kart-like, open source, with online mode. (662MB)###supertuxkart.sh"
    jeux["->Street of Rage R 5.2"]="Remake of Streets of Rage 1/2/3 for Windows. (331MB)###sorr52.sh"
    jeux["->Megaman 2.5D"]="Mega Man fangame in 2.5D for Windows. (855MB)###megaman25.sh"
    jeux["->Sonic Smackdown"]="Free fighting fangame with Sonic characters. (1.6GB)###sonicsmash.sh"
    jeux["->Maldita Castilla"]="Fan-made in the style of Ghouls 'n Ghosts. (60.2MB)###maldita.sh"
    jeux["->Super Smash Crusade"]="Free Super Smash Bros Crusade fangame. (1.45GB)###supersc.sh"
    jeux["->Rayman Redemption"]="Rayman Redemption fangame. (976MB)###raymanr.sh"
    jeux["->Power Bomberman"]="Bomberman fangame. (616MB)###powerb.sh"
    jeux["->Mushroom Kingdom Fusion"]="Mario crossover fangame with many franchises. (962MB)###mushkf.sh"
    jeux["->Dr. Robotnik's Racers"]="Fan-made Mario Kart-like in the Sonic universe. (698MB)###drrobo.sh"
else
    jeux["->Celeste 64"]="Le retour de Madeline mais en 3D.(39.8Mo)###c64.sh"
    jeux["->Celeste pico8"]="Aidez Madeline à survivre à ses démons intérieurs au mont Celeste.(14.8Mo)###celeste.sh"
    jeux["->Crash Bandicoot bit"]="Crash Bandicoot Fan-Made avec éditeur de stage personnalisé.(230Mo)###cbit.sh"
    jeux["->Donkey Kong Advanced"]="Un remake du jeu d'arcade classique.(19.4MB)###dka.sh"
    jeux["->TMNT Rescue Palooza"]="TMNT: Rescue-Palooza est un jeu de beat-em-up gratuit.(168MB)###tmntrp.sh"
    jeux["->Spelunky"]="Spelunky jeu de plates-formes en deux dimensions. Le joueur incarne un spéléologue.(24.2Mo)###spelunky.sh"
    jeux["->Sonic Triple Trouble"]="Sonic Triple Touble un fangame du jeu Game Gear Sonic Triple Trouble.(115Mo)###stt.sh"
    jeux["->Pokemon Uranium"]="Fangame basé sur les séries Pokémon.(332Mo)###pokeura.sh"
    jeux["->MiniDoom 2"]="Le jeu hommage qui transforme DOOM en un jeu de plateforme d'action.(114Mo)###minidoom2.sh"
    jeux["->AM2R"]="Another Metroid 2 Remake, remake non officiel du jeu Game Boy de 1991 Metroid II.(85.6Mo)###am2r.sh"
    jeux["->Megaman X II"]="Mega Man X Innocent Impulse FanGame style 8bits.(354Mo)###mmxii.sh"
    jeux["->Super Tux Kart"]="Mario Kart like, open source avec mode online.(662Mo)###supertuxkart.sh"
    jeux["->Street of Rage R 5.2"]="Remake de Street Of Rage 1/2/3 pour Windows.(331Mo)###sorr52.sh"
    jeux["->Megaman 2.5D"]="Fangame de Mega Man en 2.5D pour Windows.(855Mo)###megaman25.sh"
    jeux["->Sonic Smackdown"]="Fangame de combat, faites combattre vos héros de l'univers Sonic.(1.6Go)###sonicsmash.sh"
    jeux["->Maldita Castilla"]="Fanmade dans le style de Ghouls 'n Ghosts.(60.2Mo)###maldita.sh"
    jeux["->Super Smash Crusade"]="Fanmade Super Smash Bros Crusade.(1.45Go)###supersc.sh"
    jeux["->Rayman Redemption"]="Fanmade Rayman Redemption.(976Mo)###raymanr.sh"
    jeux["->Power Bomberman"]="Fanmade de Bomberman.(616Mo)###powerb.sh"
    jeux["->Mushroom Kingdom Fusion"]="Fanmade Mario croisé avec de nombreuses autres franchises de jeux.(962Mo)###mushkf.sh"
    jeux["->Dr. Robotnik's Racers"]="Fanmade Mario Kart like dans l'univers de Sonic.(698Mo)###drrobo.sh"
fi

while true; do
    menu_entries=()
    IFS=$'\n' sorted_keys=($(printf "%s\n" "${!jeux[@]}" | sort))
    for key in "${sorted_keys[@]}"; do
        desc="${jeux[$key]%%###*}"
        menu_entries+=("$key" "$desc")
    done

    choix=$(dialog --clear --backtitle "Foclabroc Toolbox" \
        --title "$(tr MENU_TITLE)" \
        --menu "$(tr MENU_PROMPT)" 33 124 15 \
        "${menu_entries[@]}" \
        2>&1 >/dev/tty)

    [ -z "$choix" ] && { curl -s http://127.0.0.1:1234/reloadgames; clear; exit 0; }

    valeur="${jeux[$choix]}"
    script="${valeur##*###}"

    CONFIRM_MSG=$(tr CONFIRM_MSG "$choix")
    dialog --backtitle "Foclabroc Toolbox" --title "$(tr CONFIRM_TITLE)" \
        --yesno "$CONFIRM_MSG" 10 50 2>&1 >/dev/tty

    if [ $? -eq 0 ]; then
        clear
        script_url="$base_url/$script"
        http_code=$(curl -s -o /dev/null -w "%{http_code}" "$script_url")
        if [ "$http_code" -ne 200 ]; then
            dialog --msgbox "$(tr SERVER_ERR)" 8 60 2>&1 >/dev/tty
            sleep 2
        else
            curl -s "$script_url" | bash
        fi
    fi
done
