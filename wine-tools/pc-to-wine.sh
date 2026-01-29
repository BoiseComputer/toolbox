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
    en:CONF_TITLE) echo "Game configuration confirmation";;
    fr:CONF_TITLE) echo "Confirmation de configuration du jeu";;
    en:CONF_MSG) echo "\nYou must have launched the game in .pc at least once\nso Batocera can generate the .wine bottle.\n\nContinue?";;
    fr:CONF_MSG) echo "\nVous devez avoir lancé le jeu en .pc au moins une fois\npour que Batocera génère la bouteille en .wine. \n\nContinuer ?";;
    en:CANCEL) echo "\nCancelled\nReturning to Wine Tools menu...";;
    fr:CANCEL) echo "\nAnnulé\nRetour au menu Wine Tools...";;
    en:NO_PC) echo "\nNo .pc folder found in /userdata/roms/windows.\nReturning to Wine Tools menu...";;
    fr:NO_PC) echo "\nAucun dossier .pc trouvé dans /userdata/roms/windows.\nRetour au menu Wine Tools...";;
    en:PC_TITLE) echo "Select the .pc game";;
    fr:PC_TITLE) echo "Sélection du jeu en .pc";;
    en:PC_PROMPT) echo "\nSelect the .pc folder to convert:\n ";;
    fr:PC_PROMPT) echo "\nSélectionnez le dossier .pc à convertir :\n ";;
    en:NO_WINE) echo "\nNo .wine folder found in /userdata/system/wine-bottles.\nReturning to Wine Tools menu...";;
    fr:NO_WINE) echo "\nAucun dossier .wine trouvé dans /userdata/system/wine-bottles.\nRetour au menu Wine Tools...";;
    en:WINE_TITLE) echo "Select the Wine bottle";;
    fr:WINE_TITLE) echo "Sélection de la bouteille Wine";;
    en:WINE_PROMPT) echo "\nSelect the matching Wine bottle:\n ";;
    fr:WINE_PROMPT) echo "\nSélectionnez la bouteille wine correspondante :\n ";;
    en:CONFIRM_OP) echo "\nThis will copy data from:\n\n$selected_wine\n\ninto:\n\n$selected_pc\n\nand then delete the Wine bottle and rename the .pc folder to .wine.\n\nContinue?";;
    fr:CONFIRM_OP) echo "\nCela copiera les données depuis :\n\n$selected_wine\n\nvers :\n\n$selected_pc\n\npuis supprimera la bouteille Wine et renommera le dossier .pc en .wine.\n\nContinuer ?";;
    en:COPY_ERR) echo "\nError copying data from Wine bottle.\nReturning to Wine Tools menu...";;
    fr:COPY_ERR) echo "\nErreur lors de la copie des données depuis la bouteille wine.\nRetour au menu Wine Tools...";;
    en:DELETE_ERR) echo "Error deleting Wine folder:\n$selected_wine\nReturning to Wine Tools menu...";;
    fr:DELETE_ERR) echo "Erreur lors de la suppression du dossier wine :\n$selected_wine\nRetour au menu Wine Tools...";;
    en:RENAME_ERR) echo "\nError renaming folder:\n$selected_pc\ninto\n$new_path\nReturning to Wine Tools menu...";;
    fr:RENAME_ERR) echo "\nErreur lors du renommage du dossier :\n$selected_pc\nen\n$new_path\nRetour au menu Wine Tools...";;
    en:DONE) echo "\nConversion complete!\n\nNew folder:\n\n$new_path";;
    fr:DONE) echo "\nConversion terminée !\n\nNouveau dossier :\n\n$new_path";;
    en:COMPRESS_Q) echo "\nDo you want to compress the new .wine folder?\n\nCompression options:\n- wtgz (TGZ): for small games with many writes.\n- wsquashfs (SquashFS): for larger games with few writes.\n\n(Compression converts the folder into a read-only image with .wtgz or .wsquashfs extension.)";;
    fr:COMPRESS_Q) echo "\nSouhaitez-vous compresser le nouveau dossier .wine ?\n\nOptions de compression :\n- wtgz (TGZ) : Pour les petits jeux avec de nombreuses écritures.\n- wsquashfs (SquashFS) : Pour les jeux plus lourds avec peu d'écritures.\n\n(La compression convertira le dossier en une image en lecture seule avec l'extension .wtgz ou .wsquashfs.)";;
    en:COMPRESS_TITLE) echo "Select compression type";;
    fr:COMPRESS_TITLE) echo "Sélection du type de compression";;
    en:COMPRESS_PROMPT) echo "\nChoose compression method:\n ";;
    fr:COMPRESS_PROMPT) echo "\nChoisissez la méthode de compression :\n ";;
    en:TGZ) echo "TGZ - fast repack, ideal for small games";;
    fr:TGZ) echo "TGZ - reconditionne rapidement, idéal pour petits jeux";;
    en:SQFS) echo "SquashFS - ideal for large games";;
    fr:SQFS) echo "SquashFS - idéal pour gros jeux";;
    en:TGZ_INFO) echo "\nConverting folder to TGZ... Please wait.";;
    fr:TGZ_INFO) echo "\nConversion du dossier au format TGZ (tgz)... Veuillez patienter.";;
    en:SQFS_INFO) echo "\nConverting folder to SquashFS... Please wait.";;
    fr:SQFS_INFO) echo "\nConversion du dossier au format SquashFS (wsquashfs)... Veuillez patienter.";;
    en:COMPRESS_OK) echo "\nCompression of $new_name to $final_output completed!";;
    fr:COMPRESS_OK) echo "\nCompression du dossier $new_name en $final_output terminée !";;
    en:COMPRESS_FAIL) echo "\nCompression failed\n(check disk space).";;
    fr:COMPRESS_FAIL) echo "\nÉchec de la compression\n(vérifier si assez espace disque).";;
    en:INVALID_OPT) echo "\nInvalid option selected.\nReturning to Wine Tools menu...";;
    fr:INVALID_OPT) echo "\nOption invalide sélectionnée.\nRetour au menu Wine Tools...";;
    en:DELETE_WINE_Q) echo "\nDo you want to delete the .wine folder in /userdata/roms/windows?\n\n(This will delete:\n$new_path)";;
    fr:DELETE_WINE_Q) echo "\nSouhaitez-vous supprimer le dossier .wine correspondant dans /userdata/roms/windows ?\n\n(Cela supprimera le dossier :\n$new_path)";;
    en:DELETE_WINE_OK) echo "\nFolder $new_name was deleted successfully.";;
    fr:DELETE_WINE_OK) echo "\nLe dossier $new_name a été supprimé avec succès.";;
    en:DELETE_WINE_ERR) echo "\nError deleting .wine folder:\n$new_path\nReturning to Wine Tools menu...";;
    fr:DELETE_WINE_ERR) echo "\nErreur lors de la suppression du dossier .wine :\n$new_path\nRetour au menu Wine Tools...";;
    en:ANOTHER_Q) echo "\nDo you want to process another folder?";;
    fr:ANOTHER_Q) echo "\nSouhaitez-vous traiter un autre dossier ?";;
    en:BACK_WINE) echo "\nReturning to Wine Tools menu...";;
    fr:BACK_WINE) echo "\nRetour au menu Wine Tools...";;
  esac
}

select_language

# Afficher la boîte de dialogue. Ajuster la hauteur et la largeur si nécessaire.
dialog --backtitle "Foclabroc Toolbox" --title "$(tr CONF_TITLE)" --yesno "$(tr CONF_MSG)" 10 60 2>&1 >/dev/tty
response=$?

# Effacer l'écran (optionnel)
clear

if [ $response -eq 0 ]; then
    echo "L'utilisateur a choisi de continuer."
else
  dialog --backtitle "Foclabroc Toolbox" --infobox "$(tr CANCEL)" 6 40 2>&1 >/dev/tty
    sleep 2
    curl -Ls https://raw.githubusercontent.com/foclabroc/toolbox/refs/heads/main/wine-tools/wine.sh | bash
    exit 1
fi

while true; do
  #Sélectionner le dossier .pc dans /userdata/roms/windows
  pc_folders=()
  for dir in /userdata/roms/windows/*.pc; do
    [ -d "$dir" ] || continue
    pc_folders+=( "$dir" "" )
  done

  if [ ${#pc_folders[@]} -eq 0 ]; then
    dialog --backtitle "Foclabroc Toolbox" --infobox "$(tr NO_PC)" 12 40 2>&1 >/dev/tty
    sleep 2
    curl -Ls https://raw.githubusercontent.com/foclabroc/toolbox/refs/heads/main/wine-tools/wine.sh | bash
    exit 1
  fi

  selected_pc=$(dialog --backtitle "Foclabroc Toolbox" --clear --title "$(tr PC_TITLE)" \
    --menu "$(tr PC_PROMPT)" 30 95 4 "${pc_folders[@]}" 3>&1 1>&2 2>&3)
  exit_status=$?
  clear
  if [ $exit_status -ne 0 ]; then
    dialog --backtitle "Foclabroc Toolbox" --infobox "$(tr CANCEL)" 6 40 2>&1 >/dev/tty
    sleep 2
    curl -Ls https://raw.githubusercontent.com/foclabroc/toolbox/refs/heads/main/wine-tools/wine.sh | bash
    exit 1
  fi

  #Sélectionner le dossier Wine correspondant dans /userdata/system/wine-bottles
  wine_folders=()
  while IFS= read -r folder; do
    wine_folders+=( "$folder" "" )
  done < <(find /userdata/system/wine-bottles -type d -name "*.wine")

  if [ ${#wine_folders[@]} -eq 0 ]; then
    dialog --backtitle "Foclabroc Toolbox" --infobox "$(tr NO_WINE)" 10 40 2>&1 >/dev/tty
    sleep 2
    curl -Ls https://raw.githubusercontent.com/foclabroc/toolbox/refs/heads/main/wine-tools/wine.sh | bash
    exit 1
  fi

  selected_wine=$(dialog --backtitle "Foclabroc Toolbox" --clear --title "$(tr WINE_TITLE)" \
    --menu "$(tr WINE_PROMPT)" 30 95 4 "${wine_folders[@]}" 3>&1 1>&2 2>&3)
  exit_status=$?
  clear
  if [ $exit_status -ne 0 ]; then
    continue
  fi

  #Confirmer l'opération
  dialog --backtitle "Foclabroc Toolbox" --title "Confirmation" --yesno "$(tr CONFIRM_OP)" 20 60 2>&1 >/dev/tty
  if [ $? -ne 0 ]; then
	continue
  fi

  #Copier les données Wine dans le dossier .pc
  cp -a "$selected_wine"/. "$selected_pc"/
  if [ $? -ne 0 ]; then
    dialog --backtitle "Foclabroc Toolbox" --infobox "$(tr COPY_ERR)" 10 40 2>&1 >/dev/tty
    sleep 2
    curl -Ls https://raw.githubusercontent.com/foclabroc/toolbox/refs/heads/main/wine-tools/wine.sh | bash
    exit 1
  fi

  #Supprimer le dossier Wine original
  rm -rf "$selected_wine"
  if [ $? -ne 0 ]; then
    dialog --backtitle "Foclabroc Toolbox" --infobox "$(tr DELETE_ERR)" 11 40 2>&1 >/dev/tty
    sleep 2
    curl -Ls https://raw.githubusercontent.com/foclabroc/toolbox/refs/heads/main/wine-tools/wine.sh | bash
    exit 1
  fi

  #Renommer le dossier .pc en .wine dans /userdata/roms/windows
  base_name=$(basename "$selected_pc")
  new_name="${base_name%.pc}.wine"
  parent_dir=$(dirname "$selected_pc")
  new_path="${parent_dir}/${new_name}"

  mv "$selected_pc" "$new_path"
  if [ $? -ne 0 ]; then
    dialog --backtitle "Foclabroc Toolbox" --infobox "$(tr RENAME_ERR)" 11 40 2>&1 >/dev/tty
    sleep 2
    curl -Ls https://raw.githubusercontent.com/foclabroc/toolbox/refs/heads/main/wine-tools/wine.sh | bash
    exit 1
  fi

  dialog --backtitle "Foclabroc Toolbox" --msgbox "$(tr DONE)" 12 70 2>&1 >/dev/tty

# Compression facultative du dossier
   dialog --backtitle "Foclabroc Toolbox" --yesno "$(tr COMPRESS_Q)" 15 70 2>&1 >/dev/tty
   if [ $? -eq 0 ]; then
     compression_choice=$(dialog --backtitle "Foclabroc Toolbox" --clear --title "$(tr COMPRESS_TITLE)" \
       --menu "$(tr COMPRESS_PROMPT)" 12 85 3 \
       "1-wtgz" "$(tr TGZ)" \
       "2-wsquashfs" "$(tr SQFS)" 3>&1 1>&2 2>&3)
     exit_status=$?
     clear
     if [ $exit_status -eq 0 ]; then
       case "$compression_choice" in
         1-wtgz)
           dialog --backtitle "Foclabroc Toolbox" --infobox "$(tr TGZ_INFO)" 6 50 2>&1 >/dev/tty
           if batocera-wine windows wine2winetgz "$new_path" 2>&1 >/dev/tty; then
             old_output="${new_path}.wtgz"
             final_output="${new_path%.wine}.wtgz"
             if [ -f "$old_output" ]; then
               mv "$old_output" "$final_output"
             fi
             dialog --backtitle "Foclabroc Toolbox" --msgbox "$(tr COMPRESS_OK)" 8 70 2>&1 >/dev/tty
           else
             dialog --backtitle "Foclabroc Toolbox" --title "Erreur!" --msgbox "$(tr COMPRESS_FAIL)" 9 60 2>&1 >/dev/tty
           fi
           ;;
         2-wsquashfs)
           dialog --backtitle "Foclabroc Toolbox" --infobox "$(tr SQFS_INFO)" 6 50 2>&1 >/dev/tty
           if batocera-wine windows wine2squashfs "$new_path" 2>&1 >/dev/tty; then
             old_output="${new_path}.wsquashfs"
             final_output="${new_path%.wine}.wsquashfs"
             if [ -f "$old_output" ]; then
               mv "$old_output" "$final_output"
             fi
             dialog --backtitle "Foclabroc Toolbox" --msgbox "$(tr COMPRESS_OK)" 8 70 2>&1 >/dev/tty
           else
             dialog --backtitle "Foclabroc Toolbox" --title "Erreur!" --msgbox "$(tr COMPRESS_FAIL)" 9 60 2>&1 >/dev/tty
           fi
           ;;
         *)
           dialog --backtitle "Foclabroc Toolbox" --msgbox "$(tr INVALID_OPT)" 6 40 2>&1 >/dev/tty
           sleep 2
           curl -Ls https://raw.githubusercontent.com/foclabroc/toolbox/refs/heads/main/wine-tools/wine.sh | bash
           exit 1
           ;;
       esac

       # Vérifier si le fichier compressé existe avant de proposer la suppression du dossier .wine
       if [ -f "$final_output" ]; then
         dialog --backtitle "Foclabroc Toolbox" --title "Confirmation" --yesno "$(tr DELETE_WINE_Q)" 11 60 2>&1 >/dev/tty
         if [ $? -eq 0 ]; then
           rm -rf "$new_path"
           if [ $? -eq 0 ]; then
             dialog --backtitle "Foclabroc Toolbox" --msgbox "$(tr DELETE_WINE_OK)" 9 40 2>&1 >/dev/tty
           else
             dialog --backtitle "Foclabroc Toolbox" --msgbox "$(tr DELETE_WINE_ERR)" 10 40 2>&1 >/dev/tty
             sleep 2
             curl -Ls https://raw.githubusercontent.com/foclabroc/toolbox/refs/heads/main/wine-tools/wine.sh | bash
             exit 1
           fi
         fi
       fi
     fi
   fi

   #Proposer de traiter un autre dossier
   dialog --backtitle "Foclabroc Toolbox" --title "Confirmation" --yesno "$(tr ANOTHER_Q)" 8 40 2>&1 >/dev/tty
   if [ $? -ne 0 ]; then
     clear
     dialog --backtitle "Foclabroc Toolbox" --infobox "$(tr BACK_WINE)" 5 40 2>&1 >/dev/tty
     sleep 2
     curl -Ls https://raw.githubusercontent.com/foclabroc/toolbox/refs/heads/main/wine-tools/wine.sh | bash
     exit 1
   fi
   clear
   curl -Ls https://raw.githubusercontent.com/foclabroc/toolbox/refs/heads/main/wine-tools/pc-to-wine.sh | bash
   exit 1
 done
