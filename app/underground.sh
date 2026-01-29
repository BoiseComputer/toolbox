#!/bin/bash
clear

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
        en:PW_PROMPT) echo "Password required:";;
        fr:PW_PROMPT) echo "Mot de passe nécessaire :";;
        en:CANCEL) echo "\nCancelled. Returning to menu.";;
        fr:CANCEL) echo "\nAnnulé retour menu.";;
        en:OK) echo "\nPassword correct...";;
        fr:OK) echo "\nMot de passe correct...";;
        en:ERR) echo "\nIncorrect password or network error.\nReturn to menu";;
        fr:ERR) echo "\nMot de passe incorrect ou erreur réseau.\nRetour menu";;
    esac
}

select_language

# Demande du mot de passe via dialog
mdp=$(dialog --backtitle "Foclabroc Toolbox" --inputbox "$(tr PW_PROMPT)" 8 40 2>&1 >/dev/tty)

if [[ $? -ne 0 || -z "$mdp" ]]; then
    clear
    dialog --backtitle "Foclabroc Toolbox" --infobox "$(tr CANCEL)" 5 30 2>&1 >/dev/tty
    sleep 3
    exit 0
fi

# URL du script distant
url="https://foclabroc.freeboxos.fr:55973/share/mux738iMucMr3Cr1/underground_${mdp}.sh"
tmpfile="/tmp/underground_script.sh"

# Téléchargement et exécution
if curl -fsSL "$url" -o "$tmpfile"; then
    chmod +x "$tmpfile"
    dialog --backtitle "Foclabroc Toolbox" --infobox "$(tr OK)" 5 30 2>&1 >/dev/tty
    sleep 2
    bash "$tmpfile"
    rm -f "$tmpfile"
else
    dialog --backtitle "Foclabroc Toolbox" --msgbox "$(tr ERR)" 8 50 2>&1 >/dev/tty
fi
