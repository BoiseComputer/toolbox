#!/bin/bash

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
    en:REC_MENU) echo "Choose a recording option";;
    fr:REC_MENU) echo "Choisissez une option d'enregistrement";;
    en:REC_MANUAL) echo "Manual record (with Stop button)";;
    fr:REC_MANUAL) echo "Record manuel (avec bouton Stop)";;
    en:REC_15) echo "Record 15 seconds (auto stop)";;
    fr:REC_15) echo "Record 15 secondes (arrêt auto)";;
    en:REC_35) echo "Record 35 seconds (auto stop)";;
    fr:REC_35) echo "Record 35 secondes (arrêt auto)";;
    en:BACK) echo "Back";;
    fr:BACK) echo "Retour";;
    en:ALREADY) echo "A recording is already in progress.";;
    fr:ALREADY) echo "Un enregistrement est déjà en cours.";;
    en:CAPTURE_TITLE) echo "Video Capture";;
    fr:CAPTURE_TITLE) echo "Capture vidéo";;
    en:CAPTURE_PROMPT) echo "Video capture in progress. Press Stop to finish...";;
    fr:CAPTURE_PROMPT) echo "Capture vidéo en cours. Appuyez sur Stop pour terminer...";;
    en:STOP) echo "Stop Capture";;
    fr:STOP) echo "Stop Capture";;
    en:REC_INFO) echo "Recording %s seconds in progress. Please wait...";;
    fr:REC_INFO) echo "Capture de %s secondes en cours. Veuillez patienter...";;
    en:REC_SAVED) echo "Video capture saved successfully.";;
    fr:REC_SAVED) echo "Capture vidéo enregistrée avec succès.";;
    en:NO_REC) echo "No recording in progress.";;
    fr:NO_REC) echo "Aucun enregistrement en cours.";;
    en:MENU_PROMPT) echo "Choose an option";;
    fr:MENU_PROMPT) echo "Choisissez une option";;
    en:SCREENSHOT) echo "[Screenshot] -> Take Batocera screenshots.";;
    fr:SCREENSHOT) echo "[Screenshot] -> Prendre des captures d'écran de Batocera.";;
    en:RELOAD) echo "[Reload]     -> Refresh the game list.";;
    fr:RELOAD) echo "[Reload]     -> Actualiser la liste des jeux.";;
    en:RECORD) echo "[Record]     -> Capture Batocera screen videos";;
    fr:RECORD) echo "[Record]     -> Capturer des vidéos de l'écran de Batocera";;
    en:BACK_MENU) echo "[Back]       -> Return to the main toolbox menu";;
    fr:BACK_MENU) echo "[Retour]     -> Retour au menu principal de la toolbox";;
    en:SCREENSHOT_OK) echo "Screenshot saved successfully in the Screenshots folder.";;
    fr:SCREENSHOT_OK) echo "Screenshot enregistré dans le dossier Screenshots avec succès.";;
    en:RELOAD_OK) echo "Game list refreshed successfully.";;
    fr:RELOAD_OK) echo "Liste des jeux actualisée avec succès.";;
  esac
}

select_language

tools_options() {
  show_message() {
    dialog --msgbox "$1" 6 50
  }

# Fonction pour exécuter l'enregistrement avec sous-menu
  start_recording_menu() {
    CHOICE=$(dialog --menu "$(tr REC_MENU)" 15 60 4 \
      1 "$(tr REC_MANUAL)" \
      2 "$(tr REC_15)" \
      3 "$(tr REC_35)" \
      4 "$(tr BACK)" \
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
      show_message "$(tr ALREADY)"
      return
    fi

    tmux new-session -d -s record_session "bash -c 'batocera-record'"
    RECORD_PID=$(pgrep -f "batocera-record" | head -n 1)
    echo $RECORD_PID > /tmp/record_pid

    CHOICE=$(dialog --title "$(tr CAPTURE_TITLE)" --backtitle "Foclabroc Toolbox" \
      --no-items --stdout \
      --menu "$(tr CAPTURE_PROMPT)" 15 60 1 \
      "$(tr STOP)")

    if [ "$CHOICE" == "$(tr STOP)" ]; then
      stop_recording
    fi
  }

  # Fonction pour l'enregistrement automatique avec arrêt après X secondes
  start_recording_auto() {
    DURATION=$1
    if [ -f /tmp/record_pid ]; then
      show_message "$(tr ALREADY)"
      return
    fi

    tmux new-session -d -s record_session "bash -c 'batocera-record'"
    RECORD_PID=$(pgrep -f "batocera-record" | head -n 1)
    echo $RECORD_PID > /tmp/record_pid

    REC_INFO=$(printf "$(tr REC_INFO)" "$DURATION")
    dialog --infobox "$REC_INFO" 6 50
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
      show_message "$(tr REC_SAVED)"
    else
      show_message "$(tr NO_REC)"
    fi
  }

  # Fonction pour afficher le menu principal
  main_menu() {
    while true; do
      CHOICE=$(dialog --menu "$(tr MENU_PROMPT)" 15 80 4 \
        1 "$(tr SCREENSHOT)" \
        2 "$(tr RELOAD)" \
        3 "$(tr RECORD)" \
        4 "$(tr BACK_MENU)" \
        2>&1 >/dev/tty)

      case $CHOICE in
        1)
          # Option Screenshot
          batocera-screenshot
          show_message "$(tr SCREENSHOT_OK)"
          ;;
        2)
          # Option Reload
          curl http://127.0.0.1:1234/reloadgames
          show_message "$(tr RELOAD_OK)"
          ;;
        3)
          # Option Record
          start_recording_menu
          ;;
        4)
          # Retour
		  clear
          break
          ;;
        *)
          # Quitter
		  clear
          break
          ;;
      esac
    done
  }
  clear
  main_menu
}

# Appel de la fonction pour afficher le menu principal
tools_options
