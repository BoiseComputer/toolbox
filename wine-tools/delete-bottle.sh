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
        en:WARN_TITLE) echo "WARNING!";;
        fr:WARN_TITLE) echo "ATTENTION !";;
        en:WARN_MSG) echo "\nWarning! This script will list all Wine bottles for your Windows games in /system/wine-bottle/windows.\n\nYou can then delete the ones you no longer need (with confirmation).\n\nBe sure of your choice because bottles contain your game settings and saves.\nDeletion is irreversible.\n\nContinue?";;
        fr:WARN_MSG) echo "\nAttention ! Ce script va faire un listing de toutes les bouteilles Wine de vos jeux Windows disponibles dans /system/wine-bottle/windows.\n\nVous pourrez ensuite supprimer, avec confirmation, celles dont vous n'avez plus besoin.\n\nSoyez sûr de votre choix car les bouteilles contiennent les paramètres et sauvegardes de vos jeux Windows.\nLa suppression est irréversible.\n\nContinuer ?";;
        en:CANCEL) echo "\nCancelled.\nReturning to Wine Tools menu...";;
        fr:CANCEL) echo "\nAnnulé.\nRetour au menu Wine Tools...";;
        en:NO_BOTTLES) echo "\nNo .wine, .wsquashfs or .wtgz folders found.\nReturning to Wine Tools menu...";;
        fr:NO_BOTTLES) echo "\nAucun dossier .wine, .wsquashfs ou .wtgz trouvé.\nRetour au menu Wine Tools...";;
        en:SELECT_TITLE) echo "Select a bottle to delete";;
        fr:SELECT_TITLE) echo "Sélectionner une bouteille à supprimer";;
        en:LIST_PROMPT) echo "\nBottle list:\n ";;
        fr:LIST_PROMPT) echo "\nListe des bouteilles :\n ";;
        en:CONFIRM_TITLE) echo "Confirmation";;
        fr:CONFIRM_TITLE) echo "Confirmation";;
        en:CONFIRM_MSG) echo "\nAre you sure you want to delete the bottle?\n\n$2";;
        fr:CONFIRM_MSG) echo "\nEs-tu sûr de vouloir supprimer la bouteille ?\n\n$2";;
        en:DELETED) echo "\nBottle $2 was deleted successfully.";;
        fr:DELETED) echo "\nLa bouteille $2 a été supprimé avec succès.";;
        en:ABORTED) echo "\nDeletion cancelled.";;
        fr:ABORTED) echo "\nSuppression annulée.";;
    esac
}

select_language

# Avertissement initial
dialog --backtitle "Foclabroc Toolbox" --title "$(tr WARN_TITLE)" --yesno "$(tr WARN_MSG)" 18 70 2>&1 >/dev/tty

if [ $? -ne 0 ]; then
    clear
    dialog --backtitle "Foclabroc Toolbox" --infobox "$(tr CANCEL)" 6 40 2>&1 >/dev/tty
    sleep 2
    curl -Ls https://raw.githubusercontent.com/foclabroc/toolbox/refs/heads/main/wine-tools/wine.sh | bash
    exit 0
fi

# Répertoire cible
TARGET_DIR="/userdata/system/wine-bottles/windows"

# Fonction pour afficher le menu principal
afficher_menu() {
    # Créer une liste des dossiers cibles
    mapfile -t dossiers < <(find "$TARGET_DIR" -type d \( -name "*.wine" -o -name "*.wsquashfs" -o -name "*.wtgz" \) 2>/dev/null)

    # Vérifier s’il y a des dossiers à afficher
    if [ ${#dossiers[@]} -eq 0 ]; then
        dialog --backtitle "Foclabroc Toolbox" --msgbox "$(tr NO_BOTTLES)" 8 50 2>&1 >/dev/tty
        sleep 2
        curl -Ls https://raw.githubusercontent.com/foclabroc/toolbox/refs/heads/main/wine-tools/wine.sh | bash
        exit 1
    fi

    # Construire la liste pour dialog
    MENU_ITEMS=()
    for i in "${!dossiers[@]}"; do
        MENU_ITEMS+=("$i" "${dossiers[$i]}")
    done

    # Afficher le menu
    CHOIX=$(dialog --backtitle "Foclabroc Toolbox" --clear \
        --title "$(tr SELECT_TITLE)" \
        --menu "$(tr LIST_PROMPT)" 25 105 10 \
        "${MENU_ITEMS[@]}" \
        3>&1 1>&2 2>&3)

    RETOUR=$?

    if [ $RETOUR -ne 0 ]; then
        clear
        dialog --backtitle "Foclabroc Toolbox" --infobox "$(tr CANCEL)" 6 40 2>&1 >/dev/tty
        sleep 2
        curl -Ls https://raw.githubusercontent.com/foclabroc/toolbox/refs/heads/main/wine-tools/wine.sh | bash
        exit 1
    fi

    # Obtenir le chemin réel du dossier sélectionné
    DOSSIER_SELECTIONNE="${dossiers[$CHOIX]}"

    confirmer_suppression "$DOSSIER_SELECTIONNE"
}

# Fonction de confirmation de suppression
confirmer_suppression() {
    DOSSIER="$1"
    CONFIRM_MSG=$(tr CONFIRM_MSG "$DOSSIER")
    dialog --backtitle "Foclabroc Toolbox" --title "$(tr CONFIRM_TITLE)" --yesno "$CONFIRM_MSG" 10 60 2>&1 >/dev/tty

    if [ $? -eq 0 ]; then
        rm -rf "$DOSSIER"
        dialog --backtitle "Foclabroc Toolbox" --msgbox "$(tr DELETED "$DOSSIER")" 8 75 2>&1 >/dev/tty
    else
        dialog --backtitle "Foclabroc Toolbox" --msgbox "$(tr ABORTED)" 7 40 2>&1 >/dev/tty
    fi

    # Retour au menu principal
    afficher_menu
}

# Démarrage du script
afficher_menu

clear
