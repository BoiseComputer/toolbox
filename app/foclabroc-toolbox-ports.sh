#!/bin/bash

clear

if [ -f /userdata/roms/ports/foclabroc-tools.sh ]; then
    curl -fsL --connect-timeout 10 --retry 3 https://raw.githubusercontent.com/foclabroc/toolbox/refs/heads/main/app/foclabroc-tools.sh \
         -o /userdata/roms/ports/foclabroc-tools.sh
fi

# Vérification et téléchargement de .dialogrc si nécessaire
DIALOGRC_PATH="/userdata/system/pro/extra/.dialogrc"
DIALOGRC_URL="https://raw.githubusercontent.com/foclabroc/toolbox/refs/heads/main/app/.dialogrc"

if [ ! -f "$DIALOGRC_PATH" ]; then
    mkdir -p "$(dirname "$DIALOGRC_PATH")"
    curl -Ls "$DIALOGRC_URL" -o "$DIALOGRC_PATH"
fi

export DIALOGRC="$DIALOGRC_PATH"

# Nettoyage si interruption
trap 'rm -f "$tmpfile1" "$tmpfile2"; exit' INT TERM EXIT

# Création fichier temporaire
tmpfile1=$(mktemp) && tmpfile2=$(mktemp)

LANG_UI="${LANG_UI:-}"
LANG_FILE="/userdata/system/pro/lang_ui"
LANGUAGE="fr"

if [ -z "$LANG_UI" ] && [ -f "$LANG_FILE" ]; then
  LANG_UI=$(cat "$LANG_FILE")
fi

if [ "$LANG_UI" = "en" ] || [ "$LANG_UI" = "fr" ]; then
  LANGUAGE="$LANG_UI"
fi

choose_language() {
  if [ -n "$LANG_UI" ]; then
    LANGUAGE="$LANG_UI"
    return
  fi

  CHOICE=$(dialog --clear --backtitle "Foclabroc Toolbox" --title "Language / Langue" \
    --menu "\nChoose your language / Choisissez votre langue :\n " 12 60 2 \
    1 "English" \
    2 "Français" \
    2>&1 >/dev/tty)

  case $CHOICE in
    1) LANGUAGE="en" ;;
    2|"") LANGUAGE="fr" ;;
  esac

  LANG_UI="$LANGUAGE"
  echo "$LANG_UI" > "$LANG_FILE"
}

set_language_strings() {
  if [ "$LANGUAGE" = "en" ]; then
    TXT_WELCOME_TITLE="Welcome"
    TXT_INFO_TITLE="Foclabroc Toolbox"
    TXT_INFO_OK_LABEL=">CONTINUE<"
    TXT_INFO_BODY=$(cat <<'EOF'

Welcome to my Toolbox!

It brings together a set of scripts designed to make it easier to install my different packs (Switch, Kodi, NES 3D, etc.).

You will also find several useful tools, like downloading and managing your Wine bottles and runners.
There is also a "Tools" section, with features such as taking screenshots and video capture on Batocera (available only when launching the Toolbox via SSH).

There is also a "Windows games download" section where you will find various Windows games, mostly fan games, with automatic media added to your gamelist.

Cherry on the cake: you can also install the Toolbox in the "Ports" section of Batocera Linux to access it directly with a controller.

I will probably keep enriching it with new features over time.

HUGS.
EOF
)
    TXT_ERROR_TITLE="Error"
    TXT_NO_INTERNET="\nNo Internet connection detected!"
    TXT_ARCH_TITLE_FMT="Architecture %s Detected"
    TXT_ARCH_MSG_FMT="\nArchitecture %s detected.\nThis script can only be run on x86_64 PCs (AMD/Intel)."

    TXT_MENU_RECORD_PROMPT="\nChoose a recording option:\n "
    TXT_RECORD_MANUAL="Manual record (with Stop button)"
    TXT_RECORD_15="Record 15 seconds (auto stop)"
    TXT_RECORD_35="Record 35 seconds (auto stop)"
    TXT_BACK="Back"
    TXT_VIDEO_CAPTURE_TITLE="Video Capture"
    TXT_VIDEO_CAPTURE_PROMPT="\nVideo capture in progress. Press Stop to finish...\n "
    TXT_STOP_CAPTURE="Stop Capture"
    TXT_RECORDING_ALREADY="\nA recording is already in progress."
    TXT_RECORDING_AUTO_INFO_FMT="\nRecording %s seconds in progress. Please wait..."
    TXT_RECORDING_SAVED="\nVideo capture saved successfully.\n"
    TXT_NO_RECORDING="\nNo recording in progress.\n"

    TXT_SYSINFO_TITLE="System Information"
    TXT_TOOLS_MENU_TITLE="Tools Menu"
    TXT_TOOLS_MENU_PROMPT="\nChoose an option:\n "
    TXT_TOOLS_INFOS="[Infos]      -> Show Batocera system information."
    TXT_TOOLS_BACK="[Back]       -> Return to the main toolbox menu"

    TXT_CONFIRM_TITLE="Confirmation"
    TXT_CONFIRM_INSTALL_FMT="\nDo you really want to install %s ?"

    TXT_MAIN_MENU_TITLE="Main Menu"
    TXT_MAIN_MENU_PROMPT="\nSelect an option:\n "
    MENU_MAIN_1="[Nintendo Switch]  -> Install Switch emulation on Batocera"
    MENU_MAIN_2="[Rgsx]             -> Install RGSX, the game download tool for Batocera"
    MENU_MAIN_3="[Fpinball]         -> Install the Future Pinball launcher for V42 and +"
    MENU_MAIN_4="[Youtube TV]       -> Install Youtube TV"
    MENU_MAIN_5="[Gparted]          -> Install Gparted"
    MENU_MAIN_6="[Pack Kodi]        -> Install the streaming/IPTV Kodi pack"
    MENU_MAIN_7="[Pack Nes3D]       -> Install the Nintendo NES 3D pack"
    MENU_MAIN_8="[Pack OpenLara]    -> Install the OpenLara pack (Batocera V38 to V41 only)"
    MENU_MAIN_9="[Pack Music]       -> Install the Music pack for ES"
    MENU_MAIN_10="[PC Games]         -> Download Windows games..."
    MENU_MAIN_11="[Wine Toolbox]     -> Download Wine runners and wsquash tools..."
    MENU_MAIN_12="[Update/Downgrade] -> Update and downgrade Batocera..."
    MENU_MAIN_13="[Tools]            -> Batocera tools (light). More options via SSH"
    MENU_MAIN_14="[Underground]      -> !!!Password required !!!"
    MENU_MAIN_15="[Exit]             -> Exit the script"

    TXT_EXIT_TITLE="Exit"
    TXT_EXIT_LABEL=">EXIT<"
    TXT_THANKS_LINE="                     THANK YOU FOR USING MY TOOLBOX                     "
    TXT_X86_ONLY_LINE="                        FOR BATOCERA PC X86_64 ONLY                        "
  else
    TXT_WELCOME_TITLE="Bienvenue"
    TXT_INFO_TITLE="Foclabroc Toolbox"
    TXT_INFO_OK_LABEL=">CONTINUE<"
    TXT_INFO_BODY=$(cat <<'EOF'

Bienvenue dans ma Toolbox !

Elle regroupe un ensemble de scripts conçus pour vous faciliter l'installation de mes différents packs (Switch, Kodi, NES 3D, etc.).

Vous y trouverez aussi plusieurs outils pratiques, comme le téléchargement et la gestion de vos bouteilles et Runners Wine.
Une section "Tools" est également disponible, avec des fonctionnalités comme la prise de screenshots et la capture vidéo sur Batocera (disponible uniquement en lançant la Toolbox via SSH).

Mais aussi une section "Télechargement de jeux windows" dans laquelle vous trouverez différents jeux Windows, majoritairement FanGame, avec ajout des médias à votre gamelist automatique.

Cerise sur le gâteau : vous pouvez aussi installer la Toolbox dans la section "Ports" de Batocera Linux pour y accéder directement à la manette.

Je continuerai sûrement à l’enrichir avec de nouvelles fonctionnalités au fil du temps.

LA BISE.
EOF
)
    TXT_ERROR_TITLE="Erreur"
    TXT_NO_INTERNET="\nPas de connexion Internet détectée !"
    TXT_ARCH_TITLE_FMT="Architecture %s Détectée"
    TXT_ARCH_MSG_FMT="\nArchitecture %s Détectée.\nCe script ne peut être exécuté que sur des PC x86_64 (AMD/Intel)."

    TXT_MENU_RECORD_PROMPT="\nChoisissez une option d'enregistrement :\n "
    TXT_RECORD_MANUAL="Record manuel (avec bouton Stop)"
    TXT_RECORD_15="Record 15 secondes (arrêt auto)"
    TXT_RECORD_35="Record 35 secondes (arrêt auto)"
    TXT_BACK="Retour"
    TXT_VIDEO_CAPTURE_TITLE="Capture vidéo"
    TXT_VIDEO_CAPTURE_PROMPT="\nCapture vidéo en cours. Appuyez sur Stop pour terminer...\n "
    TXT_STOP_CAPTURE="Stop Capture"
    TXT_RECORDING_ALREADY="\nUn enregistrement est déjà en cours."
    TXT_RECORDING_AUTO_INFO_FMT="\nCapture de %s secondes en cours. Veuillez patienter..."
    TXT_RECORDING_SAVED="\nCapture vidéo enregistrée avec succès.\n"
    TXT_NO_RECORDING="\nAucun enregistrement en cours.\n"

    TXT_SYSINFO_TITLE="Information Système"
    TXT_TOOLS_MENU_TITLE="Menu des outils"
    TXT_TOOLS_MENU_PROMPT="\nChoisissez une option :\n "
    TXT_TOOLS_INFOS="[Infos]      -> Afficher les informations système de Batocera."
    TXT_TOOLS_BACK="[Retour]     -> Retour au menu principal de la toolbox"

    TXT_CONFIRM_TITLE="Confirmation"
    TXT_CONFIRM_INSTALL_FMT="\nVoulez-vous vraiment installer %s ?"

    TXT_MAIN_MENU_TITLE="Menu Principal"
    TXT_MAIN_MENU_PROMPT="\nSélectionnez une option :\n "
    MENU_MAIN_1="[Nintendo Switch]  -> Installer l'émulation Switch sur Batocera"
    MENU_MAIN_2="[Rgsx]             -> Installer RGSX l'outils de telechargement de jeux pour Batocera"
    MENU_MAIN_3="[Fpinball]         -> Installer le launcher Future Pinball pour V42 et +"
    MENU_MAIN_4="[Youtube TV]       -> Installer Youtube TV"
    MENU_MAIN_5="[Gparted]          -> Installer Gparted"
    MENU_MAIN_6="[Pack Kodi]        -> Installer le pack streaming/iptv kodi"
    MENU_MAIN_7="[Pack Nes3D]       -> Installer le pack Nintendo Nes 3D"
    MENU_MAIN_8="[Pack OpenLara]    -> Installer le pack OpenLara Batocera V38 à V41 seulement"
    MENU_MAIN_9="[Pack Music]       -> Installer le pack Music pour ES"
    MENU_MAIN_10="[Jeux Pc]          -> Téléchargement de Jeux Windows..."
    MENU_MAIN_11="[Wine Toolbox]     -> Téléchargement de Runner Wine et outils wsquash..."
    MENU_MAIN_12="[Update/Downgrade] -> Mise à jour et Downgrade de Batocera..."
    MENU_MAIN_13="[Tools]            -> Outils pour Batocera version light. (Plus d'options dispo via ssh)"
    MENU_MAIN_14="[Underground]      -> !!!Mot de passe nécessaire !!!"
    MENU_MAIN_15="[Exit]             -> Quitter le script"

    TXT_EXIT_TITLE="Quitter"
    TXT_EXIT_LABEL=">QUITTER<"
    TXT_THANKS_LINE="                      MERCI D'AVOIR UTILISÉ MA TOOLBOX                    "
    TXT_X86_ONLY_LINE="                    POUR BATOCERA PC X86_64 UNIQUEMENT                    "
  fi
}

write_intro_files() {
  cat <<'EOF' > "$tmpfile1"

███████╗ ██████╗  ██████╗██╗      █████╗ ██████╗ ██████╗  ██████╗  ██████╗
██╔════╝██╔═══██╗██╔════╝██║     ██╔══██╗██╔══██╗██╔══██╗██╔═══██╗██╔════╝
█████╗  ██║   ██║██║     ██║     ███████║██████╔╝██████╔╝██║   ██║██║
██╔══╝  ██║   ██║██║     ██║     ██╔══██║██╔══██╗██╔══██╗██║   ██║██║
██║     ╚██████╔╝╚██████╗███████╗██║  ██║██████╔╝██║  ██║╚██████╔╝╚██████╗
╚═╝      ╚═════╝  ╚═════╝╚══════╝╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝ ╚═════╝  ╚═════╝
   ████████╗ ██████╗  ██████╗ ██╗     ██████╗  ██████╗ ██╗  ██╗
   ╚══██╔══╝██╔═══██╗██╔═══██╗██║     ██╔══██╗██╔═══██╗╚██╗██╔╝
      ██║   ██║   ██║██║   ██║██║     ██████╔╝██║   ██║ ╚███╔╝
      ██║   ██║   ██║██║   ██║██║     ██╔══██╗██║   ██║ ██╔██╗
      ██║   ╚██████╔╝╚██████╔╝███████╗██████╔╝╚██████╔╝██╔╝ ██╗
      ╚═╝    ╚═════╝  ╚═════╝ ╚══════╝╚═════╝  ╚═════╝ ╚═╝  ╚═╝

EOF
  printf "%s\n" "$TXT_THANKS_LINE" >> "$tmpfile1"

  cat <<'EOF' > "$tmpfile2"

███████╗ ██████╗  ██████╗██╗      █████╗ ██████╗ ██████╗  ██████╗  ██████╗
██╔════╝██╔═══██╗██╔════╝██║     ██╔══██╗██╔══██╗██╔══██╗██╔═══██╗██╔════╝
█████╗  ██║   ██║██║     ██║     ███████║██████╔╝██████╔╝██║   ██║██║
██╔══╝  ██║   ██║██║     ██║     ██╔══██║██╔══██╗██╔══██╗██║   ██║██║
██║     ╚██████╔╝╚██████╗███████╗██║  ██║██████╔╝██║  ██║╚██████╔╝╚██████╗
╚═╝      ╚═════╝  ╚═════╝╚══════╝╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝ ╚═════╝  ╚═════╝
   ████████╗ ██████╗  ██████╗ ██╗     ██████╗  ██████╗ ██╗  ██╗
   ╚══██╔══╝██╔═══██╗██╔═══██╗██║     ██╔══██╗██╔═══██╗╚██╗██╔╝
      ██║   ██║   ██║██║   ██║██║     ██████╔╝██║   ██║ ╚███╔╝
      ██║   ██║   ██║██║   ██║██║     ██╔══██╗██║   ██║ ██╔██╗
      ██║   ╚██████╔╝╚██████╔╝███████╗██████╔╝╚██████╔╝██╔╝ ██╗
      ╚═╝    ╚═════╝  ╚═════╝ ╚══════╝╚═════╝  ╚═════╝ ╚═╝  ╚═╝

EOF
  printf "%s\n" "$TXT_X86_ONLY_LINE" >> "$tmpfile2"
}

show_intro() {
    # Affichage sans fermeture automatique
  dialog --backtitle "Foclabroc Toolbox" --exit-label "$TXT_EXIT_LABEL" --title "$TXT_WELCOME_TITLE" --textbox "$tmpfile2" 20 78 &
    pid=$!
    sleep 3
    kill "$pid"
}

show_info() {
dialog --backtitle "Foclabroc Toolbox" --ok-label "$TXT_INFO_OK_LABEL" --title "$TXT_INFO_TITLE" --msgbox \
"$TXT_INFO_BODY" 30 70 2>&1 >/dev/tty
}

# Vérification de la connexion Internet
check_internet() {
    if ! curl -s --head --connect-timeout 3 https://www.google.com >/dev/null; then
        dialog --backtitle "Foclabroc Toolbox" \
         --title "$TXT_ERROR_TITLE" \
         --msgbox "$TXT_NO_INTERNET" 6 40 2>&1 >/dev/tty
        exit 1
    fi
}

# Vérification de l'architecture
arch_check() {
    ARCH=$(uname -m)
    clear
    if [ "$ARCH" != "x86_64" ]; then
    ARCH_TITLE=$(printf "$TXT_ARCH_TITLE_FMT" "$ARCH")
    ARCH_MSG=$(printf "$TXT_ARCH_MSG_FMT" "$ARCH")
    dialog --backtitle "FOCLABROC TOOLBOX SCRIPT FOR BATOCERA" --title "$ARCH_TITLE" --msgbox "$ARCH_MSG" 9 50 2>&1 >/dev/tty
        killall -9 xterm
        exit 1
    fi
}

tools_options() {
  show_message() {
    dialog --backtitle "Foclabroc Toolbox" --msgbox "$1" 7 50 2>&1 >/dev/tty
  }

# Fonction pour exécuter l'enregistrement avec sous-menu
  start_recording_menu() {
    CHOICE=$(dialog --backtitle "Foclabroc Toolbox" --menu "$TXT_MENU_RECORD_PROMPT" 15 60 4 \
      1 "$TXT_RECORD_MANUAL" \
      2 "$TXT_RECORD_15" \
      3 "$TXT_RECORD_35" \
      4 "$TXT_BACK" \
      2>&1 >/dev/tty)

    case $CHOICE in
      1)
        start_recording_manual
        ;;
      2)
        start_recording_auto 15
        ;;
      3)
        start_recording_auto 35
        ;;
      4)
        return
        ;;
    esac
  }

  # Fonction pour l'enregistrement manuel
  start_recording_manual() {
    if [ -f /tmp/record_pid ]; then
      show_message "$TXT_RECORDING_ALREADY"
      return
    fi

    tmux new-session -d -s record_session "bash -c 'batocera-record'"
    RECORD_PID=$(pgrep -f "batocera-record" | head -n 1)
    echo $RECORD_PID > /tmp/record_pid

    CHOICE=$(dialog --title "$TXT_VIDEO_CAPTURE_TITLE" --backtitle "Foclabroc Toolbox" \
      --no-items --stdout \
      --menu "$TXT_VIDEO_CAPTURE_PROMPT" 10 60 1 \
      "$TXT_STOP_CAPTURE")

    if [ "$CHOICE" == "$TXT_STOP_CAPTURE" ]; then
      stop_recording
    fi
  }

  # Fonction pour l'enregistrement automatique avec arrêt après X secondes
  start_recording_auto() {
    DURATION=$1
    if [ -f /tmp/record_pid ]; then
      show_message "$TXT_RECORDING_ALREADY"
      return
    fi

    tmux new-session -d -s record_session "bash -c 'batocera-record'"
    RECORD_PID=$(pgrep -f "batocera-record" | head -n 1)
    echo $RECORD_PID > /tmp/record_pid

    RECORDING_AUTO_INFO=$(printf "$TXT_RECORDING_AUTO_INFO_FMT" "$DURATION")
    dialog --infobox "$RECORDING_AUTO_INFO" 6 50 2>&1 >/dev/tty
    sleep $DURATION
    stop_recording
  }

  # Fonction pour arrêter l'enregistrement
  stop_recording() {
    if tmux has-session -t record_session 2>/dev/null; then
      tmux send-keys -t record_session C-c
      sleep 2 #pour eviter la corruption de la capture
      tmux kill-session -t record_session 2>/dev/null
      rm /tmp/record_pid
      show_message "$TXT_RECORDING_SAVED"
    else
      show_message "$TXT_NO_RECORDING"
    fi
    start_recording_menu  # Retour automatique au sous-menu d'enregistrement
  }

# Fonction pour afficher les infos systeme
show_batocera_info() {
    echo "" > /tmp/batocera_info.txt
    batocera-info >> /tmp/batocera_info.txt
  dialog --title "$TXT_SYSINFO_TITLE" --backtitle "Foclabroc Toolbox" --textbox /tmp/batocera_info.txt 21 45 2>&1 >/dev/tty
    rm /tmp/batocera_info.txt
}

  # Fonction pour afficher le menu principal
  main_menu() {
    while true; do
      CHOICE=$(dialog --title "$TXT_TOOLS_MENU_TITLE" --backtitle "Foclabroc Toolbox" --menu "$TXT_TOOLS_MENU_PROMPT" 15 80 4 \
        1 "$TXT_TOOLS_INFOS" \
        2 "$TXT_TOOLS_BACK" \
        2>&1 >/dev/tty)

      case $CHOICE in
        1)
          # Option Info systeme
          show_batocera_info
          ;;
        2)
          # Retour
          break
          ;;
        *)
          # Quitter
          break
          ;;
      esac
    done
  }

  main_menu
}

# Confirmation d'installation
confirm_install() {
  CONFIRM_MSG=$(printf "$TXT_CONFIRM_INSTALL_FMT" "$1")
  dialog --backtitle "Foclabroc Toolbox" --title "$TXT_CONFIRM_TITLE" --yesno "$CONFIRM_MSG" 7 60 2>&1 >/dev/tty
    return $?
}

# Fonction pour afficher le menu principal
main_menu() {
    while true; do
        main_menu=$(dialog --clear --backtitle "Foclabroc Toolbox" \
        --title "$TXT_MAIN_MENU_TITLE" \
        --menu "$TXT_MAIN_MENU_PROMPT" 24 100 15 \
        1 "$MENU_MAIN_1" \
        2 "$MENU_MAIN_2" \
        3 "$MENU_MAIN_3" \
        4 "$MENU_MAIN_4" \
        5 "$MENU_MAIN_5" \
        6 "$MENU_MAIN_6" \
        7 "$MENU_MAIN_7" \
        8 "$MENU_MAIN_8" \
        9 "$MENU_MAIN_9" \
        10 "$MENU_MAIN_10" \
        11 "$MENU_MAIN_11" \
        12 "$MENU_MAIN_12" \
        13 "$MENU_MAIN_13" \
        14 "$MENU_MAIN_14" \
        15 "$MENU_MAIN_15" \
            2>&1 >/dev/tty)
        clear

        case $main_menu in
            1)
                confirm_install "Nintendo Switch" || continue
                clear
                DISPLAY=:0.0 xterm -fs 12 -maximized -fg white -bg black -fa "DejaVuSansMono" -en UTF-8 -e bash -c "DISPLAY=:0.0  curl -Ls bit.ly/foclabroc-switch-all | bash"
                ;;
            2)
                confirm_install "Rgsx" || continue
                clear
                DISPLAY=:0.0 xterm -fs 12 -maximized -fg white -bg black -fa "DejaVuSansMono" -en UTF-8 -e bash -c "DISPLAY=:0.0  curl -L bit.ly/rgsx-install | sh"
                ;;
            3)
                confirm_install "Fpinball" || continue
                clear
                DISPLAY=:0.0 xterm -fs 12 -maximized -fg white -bg black -fa "DejaVuSansMono" -en UTF-8 -e bash -c "DISPLAY=:0.0  curl -Ls https://raw.githubusercontent.com/foclabroc/toolbox/refs/heads/main/fpinball/fpinball.sh | bash"
                ;;
            4)
                confirm_install "Youtube TV" || continue
                clear
                DISPLAY=:0.0 xterm -fs 12 -maximized -fg white -bg black -fa "DejaVuSansMono" -en UTF-8 -e bash -c "DISPLAY=:0.0  curl -Ls https://raw.githubusercontent.com/foclabroc/toolbox/refs/heads/main/youtubetv/youtubetv.sh | bash"
                ;;
            5)
                confirm_install "Gparted" || continue
                clear
                DISPLAY=:0.0 xterm -fs 12 -maximized -fg white -bg black -fa "DejaVuSansMono" -en UTF-8 -e bash -c "DISPLAY=:0.0  curl -Ls https://raw.githubusercontent.com/foclabroc/toolbox/refs/heads/main/gparted/gparted.sh | bash"
                ;;
            6)
                confirm_install "Pack Kodi" || continue
                clear
                DISPLAY=:0.0 xterm -fs 12 -maximized -fg white -bg black -fa "DejaVuSansMono" -en UTF-8 -e bash -c "DISPLAY=:0.0  curl -Ls https://raw.githubusercontent.com/foclabroc/toolbox/refs/heads/main/kodi/pack_kodi.sh | bash"
                ;;
            7)
                confirm_install "Pack Nes 3D" || continue
                clear
                DISPLAY=:0.0 xterm -fs 12 -maximized -fg white -bg black -fa "DejaVuSansMono" -en UTF-8 -e bash -c "DISPLAY=:0.0  curl -Ls https://raw.githubusercontent.com/foclabroc/toolbox/refs/heads/main/3d/pack_3d.sh | bash"
                ;;
            8)  #Pack openlara
                clear
                DISPLAY=:0.0 xterm -fs 12 -maximized -fg white -bg black -fa "DejaVuSansMono" -en UTF-8 -e bash -c "DISPLAY=:0.0  curl -Ls https://raw.githubusercontent.com/foclabroc/toolbox/refs/heads/main/openlara/pack_lara.sh | bash"
                ;;
            9)  #Pack Music
                clear
                DISPLAY=:0.0 xterm -fs 12 -maximized -fg white -bg black -fa "DejaVuSansMono" -en UTF-8 -e bash -c "DISPLAY=:0.0  curl -Ls https://raw.githubusercontent.com/foclabroc/toolbox/refs/heads/main/music/music.sh | bash"
                ;;
            10)  #Jeux windows et linux
                clear
                DISPLAY=:0.0 xterm -fs 12 -maximized -fg white -bg black -fa "DejaVuSansMono" -en UTF-8 -e bash -c "DISPLAY=:0.0  curl -Ls https://raw.githubusercontent.com/foclabroc/toolbox/refs/heads/main/windows/_win-game.sh | bash"
                ;;
            11)  #wine tools
                clear
                DISPLAY=:0.0 xterm -fs 12 -maximized -fg white -bg black -fa "DejaVuSansMono" -en UTF-8 -e bash -c "DISPLAY=:0.0  curl -Ls https://raw.githubusercontent.com/foclabroc/toolbox/refs/heads/main/wine-tools/wine.sh | bash"
                ;;
            12)  #update tools
                clear
                DISPLAY=:0.0 xterm -fs 12 -maximized -fg white -bg black -fa "DejaVuSansMono" -en UTF-8 -e bash -c "DISPLAY=:0.0  curl -Ls https://raw.githubusercontent.com/foclabroc/toolbox/refs/heads/main/updatebat/updatebat.sh | bash"
                ;;
            13)  #record tools
                clear
                tools_options
                ;;
            14)  #Underground
                clear
                DISPLAY=:0.0 xterm -fs 12 -maximized -fg white -bg black -fa "DejaVuSansMono" -en UTF-8 -e bash -c "DISPLAY=:0.0  curl -Ls https://raw.githubusercontent.com/foclabroc/toolbox/refs/heads/main/app/underground.sh | bash"
                ;;
            15)# Afficher un message de remerciement
              dialog --backtitle "Foclabroc Toolbox" --title "$TXT_EXIT_TITLE" --textbox "$tmpfile1" 20 78 2>&1 >/dev/tty
                killall -9 xterm
                clear
                exit 0
                ;;
            *)
              dialog --backtitle "Foclabroc Toolbox" --title "$TXT_EXIT_TITLE" --textbox "$tmpfile1" 20 78 2>&1 >/dev/tty
                killall -9 xterm
                clear
                exit 0
                ;;
        esac
    done
}

# Lancer les vérifications et afficher le menu
choose_language
set_language_strings
export LANG_UI
show_intro
show_info
arch_check
#check_internet
main_menu
