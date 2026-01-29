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
    en:NO_WINE) echo "\nNo .wine folder found.";;
    fr:NO_WINE) echo "\nAucun dossier .wine trouvé.";;
    en:SELECT_TITLE) echo "Select a Wine bottle";;
    fr:SELECT_TITLE) echo "Sélection d'une bouteille Wine";;
    en:SELECT_PROMPT) echo "\nChoose a bottle (.wine) to apply Winetricks:\n ";;
    fr:SELECT_PROMPT) echo "\nChoisissez une bouteille (.wine) pour appliquer un Winetricks :\n ";;
    en:RETURN_MENU) echo "\nReturning to Wine Tools menu...";;
    fr:RETURN_MENU) echo "\nRetour au menu Wine Tools...";;
    en:COMMON_TITLE) echo "VC++ / DirectX dependencies";;
    fr:COMMON_TITLE) echo "Dépendances VC++ / DirectX";;
    en:COMMON_ASK) echo "\nDo you want to install a common dependency like Visual C++ or DirectX9?\n\n Yes = Show common tricks list.\n\n No = Show full official Winetricks list.\n ";;
    fr:COMMON_ASK) echo "\nSouhaitez-vous installer une dépendance courante comme Visual C++ ou DirectX9 ?\n\n Oui = Affichage liste tricks courant.\n\n Non = Affichage liste winetricks officiel complete.\n ";;
    en:COMMON_SELECT) echo "\nChoose a dependency to install:\n ";;
    fr:COMMON_SELECT) echo "\nChoisissez une dépendance à installer :\n ";;
    en:CONFIRM_TITLE) echo "Confirmation";;
    fr:CONFIRM_TITLE) echo "Confirmation";;
    en:CONFIRM_MSG) echo "\nDo you really want to install:\n\nTrick: [$2]\n\nIn bottle:\n\n[$3] ?";;
    fr:CONFIRM_MSG) echo "\nVoulez-vous vraiment installer :\n\nLe Tricks : [$2]\n\nDans la Bouteille :\n\n[$3] ?";;
    en:CANCEL_INSTALL) echo "\nInstallation canceled by user...";;
    fr:CANCEL_INSTALL) echo "\nInstallation annulée par l'utilisateur...";;
    en:LOAD_LIST) echo "\nLoading official Winetricks list, please wait...";;
    fr:LOAD_LIST) echo "\nChargement de la liste officiel winetricks patientez...";;
    en:LIST_ERR) echo "Error: unable to fetch Winetricks components list.";;
    fr:LIST_ERR) echo "Erreur : impossible de récupérer la liste des composants Winetricks.";;
    en:SELECT_COMPONENT) echo "\nSelect a Winetricks component to install:\n ";;
    fr:SELECT_COMPONENT) echo "\nSélectionnez un composant Winetricks à installer :\n ";;
    en:NO_COMPONENT) echo "\nNo component selected. Returning to bottle selection.";;
    fr:NO_COMPONENT) echo "\nAucun composant sélectionné. Retour à la sélection de bouteille.";;
    en:WATCH_SCREEN) echo "\nCheck the main screen to follow the installation.";;
    fr:WATCH_SCREEN) echo "\nRegardez l'écran principal pour suivre l'installation.";;
    en:TERM_TITLE) echo "FOCLABROC TOOLBOX.";;
    fr:TERM_TITLE) echo "FOCLABROC TOOLBOX.";;
    en:TERM_INSTALL) echo "INSTALLING TRICK [$2]...";;
    fr:TERM_INSTALL) echo "INSTALLATION DU TRICKS [$2] EN COURS...";;
    en:TERM_SCREEN) echo "CHECK BATOCERA SCREEN...";;
    fr:TERM_SCREEN) echo "REGARDER L'ECRAN DE BATOCERA...";;
    en:TERM_NOTE) echo "[NOTE: IN RARE CASES KEYBOARD/MOUSE MAY BE REQUIRED FOR SOME TRICKS.]";;
    fr:TERM_NOTE) echo "[NOTE : DANS DE RARE CAS CLAVIER/SOURIS PEUVENT ETRE NECESSAIRE POUR CERTAINS TRICKS.]";;
    en:TRICKS_OK) echo "\nWinetricks installed successfully.";;
    fr:TRICKS_OK) echo "\nWinetricks installé avec succès.";;
    en:ANOTHER_SAME) echo "\nDo you want to install another component on this same bottle ?";;
    fr:ANOTHER_SAME) echo "\nSouhaitez-vous installer un autre composant sur cette même bouteille ?";;
    en:ANOTHER_BOTTLE) echo "\nDo you want to process another Wine bottle ?";;
    fr:ANOTHER_BOTTLE) echo "\nSouhaitez-vous traiter une autre bouteille Wine ?";;
  esac
}

select_language

# Boucle principale
while true; do

  # Rechercher les dossiers .wine
  wine_bottles=()

  # Recherche récursive dans /userdata/system/wine-bottles
  while IFS= read -r folder; do
    wine_bottles+=( "$folder" "" )
  done < <(find /userdata/system/wine-bottles -type d -name "*.wine")

  # Recherche dans /userdata/roms/windows
  for dir in /userdata/roms/windows/*.wine; do
    [ -d "$dir" ] || continue
    wine_bottles+=( "$dir" "" )
  done

  if [ ${#wine_bottles[@]} -eq 0 ]; then
    dialog --backtitle "Foclabroc Toolbox" --msgbox "$(tr NO_WINE)" 10 40 2>&1 >/dev/tty
    exit 1
  fi

  # Sélection de la bouteille Wine
  selected_bottle=$(dialog --backtitle "Foclabroc Toolbox" --clear --title "$(tr SELECT_TITLE)" \
    --menu "$(tr SELECT_PROMPT)" 25 100 6 "${wine_bottles[@]}" 3>&1 1>&2 2>&3)

  exit_status=$?
  clear
  if [ $exit_status -ne 0 ]; then
    dialog --backtitle "Foclabroc Toolbox" --infobox "$(tr RETURN_MENU)" 5 40 2>&1 >/dev/tty
    sleep 2
    curl -Ls https://raw.githubusercontent.com/foclabroc/toolbox/refs/heads/main/wine-tools/wine.sh | bash
    exit 1
  fi

  # Boucle interne : appliquer plusieurs tricks sur la même bouteille
  while true; do
    FINAL_PACKAGE=""
    # Installation d'une dépendance courante VC++ ou DirectX
    dialog --backtitle "Foclabroc Toolbox" --title "$(tr COMMON_TITLE)" --yesno "$(tr COMMON_ASK)" 12 80 2>&1 >/dev/tty
	if [ $? -eq 0 ]; then
  COMMON_WT=$(dialog --backtitle "Foclabroc Toolbox" --stdout --menu "$(tr COMMON_SELECT)" 18 80 8 \
		"vcrun2008" "Visual C++ 2008" \
		"vcrun2010" "Visual C++ 2010" \
		"vcrun2012" "Visual C++ 2012" \
		"vcrun2013" "Visual C++ 2013" \
		"vcrun2022" "Visual C++ 2015 à 2022" \
		"openal" "OpenAL Runtime Creative 2023" \
		"directplay" "MS DirectPlay from DirectX" \
		"d3dx9_43" "DirectX9 (d3dx9_43)")

	if [ -n "$COMMON_WT" ]; then
		FINAL_PACKAGE=$COMMON_WT
		# Confirmation avant installation
    dialog --backtitle "Foclabroc Toolbox" --title "$(tr CONFIRM_TITLE)" --yesno "$(tr CONFIRM_MSG "$FINAL_PACKAGE" "$selected_bottle")" 13 95 2>&1 >/dev/tty
		if [ $? -ne 0 ]; then
    dialog --backtitle "Foclabroc Toolbox" --infobox "$(tr CANCEL_INSTALL)" 5 60 2>&1 >/dev/tty
		sleep 2
		break
		fi
	fi
    else
    	dialog --backtitle "Foclabroc Toolbox" --infobox "$(tr LOAD_LIST)" 5 60 2>&1 >/dev/tty
        WT_URL="https://raw.githubusercontent.com/Winetricks/winetricks/master/files/verbs/all.txt"
        TEMP_LIST=$(mktemp)
        curl -Ls "$WT_URL" -o "$TEMP_LIST"

        if [ ! -s "$TEMP_LIST" ]; then
          dialog --backtitle "Foclabroc Toolbox" --msgbox "$(tr LIST_ERR)" 8 50 2>&1 >/dev/tty
          FINAL_PACKAGE=""
        else
          PARSED_LIST=$(mktemp)
          grep -v '^=====' "$TEMP_LIST" | grep -v '^[[:space:]]*$' > "$PARSED_LIST"
          OPTIONS=()
          while IFS= read -r line; do
            pkg=$(echo "$line" | awk '{print $1}')
            desc=$(echo "$line" | cut -d' ' -f2-)
            OPTIONS+=("$pkg" "$desc")
          done < "$PARSED_LIST"
          FINAL_PACKAGE=$(dialog --backtitle "Foclabroc Toolbox" --stdout --menu "$(tr SELECT_COMPONENT)" 35 100 10 "${OPTIONS[@]}")
          rm -f "$TEMP_LIST" "$PARSED_LIST"
		  if [ -n "$FINAL_PACKAGE" ]; then
		    # Confirmation avant installation
        dialog --backtitle "Foclabroc Toolbox" --title "$(tr CONFIRM_TITLE)" --yesno "$(tr CONFIRM_MSG "$FINAL_PACKAGE" "$selected_bottle")" 13 95 2>&1 >/dev/tty
		    if [ $? -ne 0 ]; then
        dialog --backtitle "Foclabroc Toolbox" --infobox "$(tr CANCEL_INSTALL)" 5 60 2>&1 >/dev/tty
			  sleep 2
			  break
		    fi
		  fi
        fi
    fi

    # Aucune sélection effectuée
    if [ -z "$FINAL_PACKAGE" ]; then
      dialog --backtitle "Foclabroc Toolbox" --infobox "$(tr NO_COMPONENT)" 8 50 2>&1 >/dev/tty
      break
    fi

    # Application du Winetricks
    dialog --backtitle "Foclabroc Toolbox" --infobox "$(tr WATCH_SCREEN)" 6 40 2>&1 >/dev/tty
	sleep 3
	clear
	echo
  echo -e "\033[1;32m$(tr TERM_TITLE)\033[0m"
  echo -e "\033[1;32m$(tr TERM_INSTALL "$FINAL_PACKAGE")\033[0m"
  echo -e "\033[1;32m$(tr TERM_SCREEN)\033[0m"
  echo -e "\033[1;32m$(tr TERM_NOTE)\033[0m"
	DISPLAY=:0.0 xterm -fs 12 -maximized -fg white -bg black -fa "DejaVuSansMono" -en UTF-8 \
	-e bash -c '
		unclutter-remote -s
		batocera-wine windows tricks "'"$selected_bottle"'" "'"$FINAL_PACKAGE"'" unattended
		unclutter-remote -h
	'
  dialog --backtitle "Foclabroc Toolbox" --msgbox "$(tr TRICKS_OK)" 6 40 2>&1 >/dev/tty

    # Nouvelle action sur la même bouteille ?
    dialog --backtitle "Foclabroc Toolbox" --yesno "$(tr ANOTHER_SAME)" 8 50 2>&1 >/dev/tty
    [ $? -eq 0 ] || break
    clear
  done

  # Traiter une autre bouteille ?
  dialog --backtitle "Foclabroc Toolbox" --yesno "$(tr ANOTHER_BOTTLE)" 8 50 2>&1 >/dev/tty
  [ $? -eq 0 ] || {
    clear
    break
  }
  clear
done

# retour au menu Wine Tools
dialog --backtitle "Foclabroc Toolbox" --infobox "$(tr RETURN_MENU)" 5 40 2>&1 >/dev/tty
sleep 2
curl -Ls https://raw.githubusercontent.com/foclabroc/toolbox/refs/heads/main/wine-tools/wine.sh | bash
