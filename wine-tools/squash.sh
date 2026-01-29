#!/bin/bash

language=$(dialog --backtitle "Foclabroc Toolbox" --clear --title "Language / Langue" \
  --menu "Choose your language / Choisissez votre langue :" 10 60 2 \
  "en" "English" \
  "fr" "Français" 3>&1 1>&2 2>&3)
exit_status=$?
clear
if [ $exit_status -ne 0 ]; then
  curl -Ls https://raw.githubusercontent.com/foclabroc/toolbox/refs/heads/main/wine-tools/wine.sh | bash
  exit 1
fi

set_language_strings() {
  if [ "$language" = "fr" ]; then
    TXT_NONE_FOUND="\nAucun dossier .wine trouvé dans /userdata/roms/windows.\nRetour au menu Wine Tools..."
    TITLE_SELECT_WINE="Sélection du jeu en .wine"
    TXT_SELECT_WINE="\nSélectionnez le dossier .wine à compresser :\n "
    TXT_CANCELED="\nAnnulé\nRetour au menu Wine Tools..."
    TXT_COMPRESS_CONFIRM="\nSouhaitez-vous compresser le dossier $selected_folder ?\n\nOptions de compression :\n- wtgz (TGZ) : Pour les petits jeux avec de nombreuses écritures.\n- wsquashfs (SquashFS) : Pour les jeux plus lourds avec peu d'écritures.\n\n(La compression convertira le dossier en une image en lecture seule avec l'extension .wtgz ou .wsquashfs.)"
    TITLE_SELECT_COMP="Sélection du type de compression"
    TXT_SELECT_COMP="\nChoisissez la méthode de compression :\n "
    OPT_WTGZ="TGZ - reconditionne rapidement, idéal pour petits jeux"
    OPT_WSQUASHFS="SquashFS - idéal pour gros jeux"
    TXT_CONVERT_TGZ="\nConversion du dossier au format TGZ (wtgz)... Veuillez patienter."
    TXT_CONVERT_SQUASH="\nConversion du dossier au format SquashFS (wsquashfs)... Veuillez patienter."
    TXT_DONE="\nCompression du dossier $selected_folder en $final_output terminée !"
    TXT_ERR_TGZ="\nErreur de compression : .TGZ introuvable ou espace disque insuffisant..."
    TXT_ERR_SQUASH="\nErreur de compression : .Squashfs introuvable ou espace disque insuffisant..."
    TXT_INVALID_OPTION="\nOption invalide sélectionnée.\nRetour au menu Wine Tools..."
    TITLE_CONFIRM="Confirmation"
    TXT_CONFIRM_DELETE="\nSouhaitez-vous supprimer le dossier .wine correspondant dans /userdata/roms/windows ?\n\n(Cela supprimera le dossier :\n$selected_folder)"
    TXT_DELETE_OK="\nLe dossier $selected_folder a été supprimé avec succès."
    TXT_DELETE_ERR="\nErreur lors de la suppression du dossier .wine :\n$new_path\nRetour au menu Wine Tools..."
    TXT_ANOTHER_FOLDER="\nSouhaitez-vous traiter un autre dossier ?"
    TXT_RETURN_MENU="\nRetour au menu Wine Tools..."
  else
    TXT_NONE_FOUND="\nNo .wine folder found in /userdata/roms/windows.\nReturning to Wine Tools menu..."
    TITLE_SELECT_WINE="Select .wine game"
    TXT_SELECT_WINE="\nSelect the .wine folder to compress :\n "
    TXT_CANCELED="\nCanceled\nReturning to Wine Tools menu..."
    TXT_COMPRESS_CONFIRM="\nDo you want to compress the folder $selected_folder ?\n\nCompression options :\n- wtgz (TGZ) : For small games with many writes.\n- wsquashfs (SquashFS) : For larger games with few writes.\n\n(Compression will convert the folder into a read-only image with the .wtgz or .wsquashfs extension.)"
    TITLE_SELECT_COMP="Select compression type"
    TXT_SELECT_COMP="\nChoose the compression method :\n "
    OPT_WTGZ="TGZ - fast repack, ideal for small games"
    OPT_WSQUASHFS="SquashFS - ideal for large games"
    TXT_CONVERT_TGZ="\nConverting folder to TGZ (wtgz)... Please wait."
    TXT_CONVERT_SQUASH="\nConverting folder to SquashFS (wsquashfs)... Please wait."
    TXT_DONE="\nCompression of folder $selected_folder to $final_output completed!"
    TXT_ERR_TGZ="\nCompression error: .TGZ not found or insufficient disk space..."
    TXT_ERR_SQUASH="\nCompression error: .Squashfs not found or insufficient disk space..."
    TXT_INVALID_OPTION="\nInvalid option selected.\nReturning to Wine Tools menu..."
    TITLE_CONFIRM="Confirmation"
    TXT_CONFIRM_DELETE="\nDo you want to delete the corresponding .wine folder in /userdata/roms/windows ?\n\n(This will delete the folder :\n$selected_folder)"
    TXT_DELETE_OK="\nFolder $selected_folder was deleted successfully."
    TXT_DELETE_ERR="\nError deleting the .wine folder :\n$new_path\nReturning to Wine Tools menu..."
    TXT_ANOTHER_FOLDER="\nDo you want to process another folder ?"
    TXT_RETURN_MENU="\nReturning to Wine Tools menu..."
  fi
}

#Recherche de dossiers .wine dans /userdata/roms/windows
wine_folders=()
for dir in /userdata/roms/windows/*.wine; do
  [ -d "$dir" ] || continue
  wine_folders+=( "$dir" "" )
done

set_language_strings

if [ ${#wine_folders[@]} -eq 0 ]; then
  dialog --backtitle "Foclabroc Toolbox" --infobox "$TXT_NONE_FOUND" 12 40 2>&1 >/dev/tty
  sleep 3
  curl -Ls https://raw.githubusercontent.com/foclabroc/toolbox/refs/heads/main/wine-tools/wine.sh | bash
  exit 1
fi

#Sélectionner le dossier .wine dans /userdata/roms/windows
selected_folder=$(dialog --backtitle "Foclabroc Toolbox" --clear --title "$TITLE_SELECT_WINE" \
  --menu "$TXT_SELECT_WINE" 30 95 4 "${wine_folders[@]}" 3>&1 1>&2 2>&3)
exit_status=$?
clear
if [ $exit_status -ne 0 ]; then
  dialog --backtitle "Foclabroc Toolbox" --infobox "$TXT_CANCELED" 6 40 2>&1 >/dev/tty
  sleep 2
  curl -Ls https://raw.githubusercontent.com/foclabroc/toolbox/refs/heads/main/wine-tools/wine.sh | bash
  exit 1
fi

#Compression du dossier
dialog --backtitle "Foclabroc Toolbox" --yesno "$TXT_COMPRESS_CONFIRM" 15 70 2>&1 >/dev/tty
if [ $? -ne 0 ]; then
  curl -Ls https://raw.githubusercontent.com/foclabroc/toolbox/refs/heads/main/wine-tools/squash.sh | bash
  exit 1
fi

compression_choice=$(dialog --backtitle "Foclabroc Toolbox" --clear --title "$TITLE_SELECT_COMP" \
  --menu "$TXT_SELECT_COMP" 12 85 3 \
  "1-wtgz" "$OPT_WTGZ" \
  "2-wsquashfs" "$OPT_WSQUASHFS" 3>&1 1>&2 2>&3)
exit_status=$?
clear
if [ $exit_status -ne 0 ]; then
  curl -Ls https://raw.githubusercontent.com/foclabroc/toolbox/refs/heads/main/wine-tools/squash.sh | bash
  exit 1
fi

#Compression et renommage
case "$compression_choice" in
  1-wtgz)
    dialog --backtitle "Foclabroc Toolbox" --infobox "$TXT_CONVERT_TGZ" 6 50 2>&1 >/dev/tty
    batocera-wine windows wine2winetgz "$selected_folder" 2>&1 >/dev/tty
    old_output="${selected_folder}.wtgz"
    final_output="${selected_folder%.wine}.wtgz"
    if [ -f "$old_output" ]; then
      mv "$old_output" "$final_output"
      dialog --backtitle "Foclabroc Toolbox" --msgbox "$TXT_DONE" 9 70 2>&1 >/dev/tty
    else
      dialog --backtitle "Foclabroc Toolbox" --msgbox "$TXT_ERR_TGZ" 6 80 2>&1 >/dev/tty
      sleep 2
      curl -Ls https://raw.githubusercontent.com/foclabroc/toolbox/refs/heads/main/wine-tools/squash.sh | bash
      exit 1
    fi
    ;;
  2-wsquashfs)
    dialog --backtitle "Foclabroc Toolbox" --infobox "$TXT_CONVERT_SQUASH" 6 50 2>&1 >/dev/tty
    batocera-wine windows wine2squashfs "$selected_folder" 2>&1 >/dev/tty
    old_output="${selected_folder}.wsquashfs"
    final_output="${selected_folder%.wine}.wsquashfs"
    if [ -f "$old_output" ]; then
      mv "$old_output" "$final_output"
      dialog --backtitle "Foclabroc Toolbox" --msgbox "$TXT_DONE" 9 70 2>&1 >/dev/tty
    else
      dialog --backtitle "Foclabroc Toolbox" --msgbox "$TXT_ERR_SQUASH" 6 80 2>&1 >/dev/tty
      sleep 2
      curl -Ls https://raw.githubusercontent.com/foclabroc/toolbox/refs/heads/main/wine-tools/squash.sh | bash
      exit 1
    fi
    ;;
  *)
    dialog --backtitle "Foclabroc Toolbox" --msgbox "$TXT_INVALID_OPTION" 6 40 2>&1 >/dev/tty
    sleep 2
    curl -Ls https://raw.githubusercontent.com/foclabroc/toolbox/refs/heads/main/wine-tools/wine.sh | bash
    exit 1
    ;;
esac

#Proposer la suppression du dossier .wine
dialog --backtitle "Foclabroc Toolbox" --title "$TITLE_CONFIRM" --yesno "$TXT_CONFIRM_DELETE" 11 60 2>&1 >/dev/tty
if [ $? -eq 0 ]; then
  rm -rf "$selected_folder"
  if [ $? -eq 0 ]; then
    dialog --backtitle "Foclabroc Toolbox" --msgbox "$TXT_DELETE_OK" 9 40 2>&1 >/dev/tty
  else
    dialog --backtitle "Foclabroc Toolbox" --msgbox "$TXT_DELETE_ERR" 10 40 2>&1 >/dev/tty
    sleep 2
    curl -Ls https://raw.githubusercontent.com/foclabroc/toolbox/refs/heads/main/wine-tools/squash.sh | bash
    exit 1
  fi
fi

#Proposer de traiter un autre dossier
dialog --backtitle "Foclabroc Toolbox" --title "$TITLE_CONFIRM" --yesno "$TXT_ANOTHER_FOLDER" 8 40 2>&1 >/dev/tty
if [ $? -ne 0 ]; then
  clear
  dialog --backtitle "Foclabroc Toolbox" --infobox "$TXT_RETURN_MENU" 5 40 2>&1 >/dev/tty
  sleep 2
  curl -Ls https://raw.githubusercontent.com/foclabroc/toolbox/refs/heads/main/wine-tools/wine.sh | bash
  exit 1
fi
clear
curl -Ls https://raw.githubusercontent.com/foclabroc/toolbox/refs/heads/main/wine-tools/squash.sh | bash
exit 1
