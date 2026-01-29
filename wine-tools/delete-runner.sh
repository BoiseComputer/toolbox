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
        en:DIR_MISSING) echo "The folder $CUSTOM does not exist.";;
        fr:DIR_MISSING) echo "Le dossier $CUSTOM n'existe pas.";;
        en:NO_RUNNER) echo "\nNo runner found in $CUSTOM.";;
        fr:NO_RUNNER) echo "\nAucun runner trouvé dans $CUSTOM.";;
        en:BACK) echo "Back to previous menu";;
        fr:BACK) echo "Retour au menu précédent";;
        en:MENU_TITLE) echo "Delete custom runner";;
        fr:MENU_TITLE) echo "Suppression de runner custom";;
        en:MENU_PROMPT) echo "\nSelect a runner to delete:\n ";;
        fr:MENU_PROMPT) echo "\nSélectionnez un runner à supprimer :\n ";;
        en:BACK_WINE) echo "\nReturn to Wine Tools menu...";;
        fr:BACK_WINE) echo "\nRetour Menu Wine Tools...";;
        en:CONFIRM) echo "\nDo you really want to delete runner '$NOM' ?";;
        fr:CONFIRM) echo "\nVoulez-vous vraiment supprimer le runner '$NOM' ?";;
        en:DELETED) echo "\nRunner '$NOM' has been deleted.";;
        fr:DELETED) echo "\nLe Runner '$NOM' a été supprimé.";;
        en:DELETE_FAIL) echo "\nDeletion failed or invalid folder.";;
        fr:DELETE_FAIL) echo "\nSuppression échouée ou dossier invalide.";;
        en:CANCELLED) echo "\nDeletion cancelled.";;
        fr:CANCELLED) echo "\nSuppression annulée.";;
    esac
}

select_language

# Chemin des dossiers à lister
CUSTOM="/userdata/system/wine/custom"

# Vérifie si le dossier existe
if [ ! -d "$CUSTOM" ]; then
    dialog --backtitle "Foclabroc Toolbox" --infobox "$(tr DIR_MISSING)" 7 50 2>&1 >/dev/tty
    clear
    exit 1
fi

while true; do
    # Récupère la liste des dossiers
    IFS=$'\n' DOSSIERS=($(find "$CUSTOM" -mindepth 1 -maxdepth 1 -type d | sort))
    unset IFS

    # Vérifie s'il y a des dossiers
    if [ ${#DOSSIERS[@]} -eq 0 ]; then
        dialog --backtitle "Foclabroc Toolbox" --infobox "$(tr NO_RUNNER)" 7 50 2>&1 >/dev/tty
        sleep 2
        break
    fi

    # Construire la liste pour dialog
    LISTE=()
    for DOSSIER in "${DOSSIERS[@]}"; do
        NOM=$(basename "$DOSSIER")
        TAILLE=$(du -sh "$DOSSIER" | cut -f1)
        DATE=$(stat -c "%y" "$DOSSIER" 2>/dev/null | cut -d'.' -f1)
        LISTE+=("-> [$NOM]" "-->| Taille: $TAILLE | Créé le: $DATE")
    done

    # Ajout de l'option retour
    LISTE+=("<- [Retour]" "$(tr BACK)")

    # Affiche le menu de sélection
    CHOIX=$(dialog --clear --backtitle "Foclabroc Toolbox" --title "$(tr MENU_TITLE)" \
        --menu "$(tr MENU_PROMPT)" 25 105 15 \
        "${LISTE[@]}" \
        3>&1 1>&2 2>&3)

    # Si annulation ou retour
    if [ -z "$CHOIX" ] || [ "$CHOIX" = "<- [Retour]" ]; then
        dialog --backtitle "Foclabroc Toolbox" --infobox "$(tr BACK_WINE)" 5 60 2>&1 >/dev/tty
        sleep 1
        exec bash <(curl -Ls https://raw.githubusercontent.com/foclabroc/toolbox/refs/heads/main/wine-tools/wine.sh)
    fi

    # Extraire le nom réel sans la déco "-> [ ... ]"
    NOM=$(echo "$CHOIX" | sed 's/^-> \[\(.*\)\]$/\1/')

    # Confirmation
    dialog --backtitle "Foclabroc Toolbox" --title "Confirmation" --yesno "$(tr CONFIRM)" 8 50 2>&1 >/dev/tty
    REPONSE=$?
    cd /tmp || exit 1
    if [ "$REPONSE" -eq 0 ]; then
        if [[ -n "$NOM" && "$NOM" != "/" && -d "$CUSTOM/$NOM" ]]; then
            rm -rf "$CUSTOM/$NOM"
            dialog --backtitle "Foclabroc Toolbox" --infobox "$(tr DELETED)" 6 50 2>&1 >/dev/tty
            sleep 2
        else
            dialog --backtitle "Foclabroc Toolbox" --infobox "$(tr DELETE_FAIL)" 6 50 2>&1 >/dev/tty
            sleep 3
        fi
    else
        dialog --backtitle "Foclabroc Toolbox" --infobox "$(tr CANCELLED)" 6 50 2>&1 >/dev/tty
        sleep 1
    fi
done

clear
exit 0
