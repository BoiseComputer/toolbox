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
    TXT_NONE_FOUND="\nAucun fichier (.wtgz ou .wsquashfs) trouvé dans /userdata/roms/windows.\nRetour au menu Wine Tools..."
    TITLE_SELECT_COMPRESSED="Sélection du jeu en compressé"
    TXT_SELECT_FILE="\nSélectionnez le fichier à décompresser :\n "
    TXT_CANCELED="\nAnnulé\nRetour au menu Wine Tools..."
    TXT_DECOMPRESS_TGZ="\nDécompression du fichier TGZ (wtgz)... Veuillez patienter."
    TXT_DECOMPRESS_SQUASH="\nDécompression du fichier SquashFS (wsquashfs)... Veuillez patienter."
    TXT_DECOMPRESS_ERR="\nErreur de décompression : répertoire déjà existant\nOu espace disque insuffisant"
    TXT_DECOMPRESS_OK="Decompression effectué avec succès !\n\nEmplacement: $final_dir"
    TXT_UNSUPPORTED_EXT="\nErreur extension de fichier non supporté..."
    TXT_DELETE_COMPRESSED="\nVoulez-vous supprimer le fichier compressé ?\n\n($selected_file)"
    TXT_DELETE_OK="\nLe fichier $selected_file a été supprimé avec succès."
    TXT_DELETE_ERR="\nErreur lors de la suppression du fichier :\n$selected_file\nRetour au menu Wine Tools..."
    TITLE_CONFIRM="Confirmation"
    TXT_ANOTHER_FILE="\nSouhaitez-vous traiter un autre fichier compressé ?"
    TXT_RETURN_MENU="\nRetour au menu Wine Tools..."
  else
    TXT_NONE_FOUND="\nNo (.wtgz or .wsquashfs) file found in /userdata/roms/windows.\nReturning to Wine Tools menu..."
    TITLE_SELECT_COMPRESSED="Select compressed game"
    TXT_SELECT_FILE="\nSelect the file to decompress :\n "
    TXT_CANCELED="\nCanceled\nReturning to Wine Tools menu..."
    TXT_DECOMPRESS_TGZ="\nDecompressing TGZ (wtgz) file... Please wait."
    TXT_DECOMPRESS_SQUASH="\nDecompressing SquashFS (wsquashfs) file... Please wait."
    TXT_DECOMPRESS_ERR="\nDecompression error: folder already exists\nOr insufficient disk space"
    TXT_DECOMPRESS_OK="Decompression completed successfully!\n\nLocation: $final_dir"
    TXT_UNSUPPORTED_EXT="\nUnsupported file extension..."
    TXT_DELETE_COMPRESSED="\nDo you want to delete the compressed file ?\n\n($selected_file)"
    TXT_DELETE_OK="\nFile $selected_file was deleted successfully."
    TXT_DELETE_ERR="\nError deleting file :\n$selected_file\nReturning to Wine Tools menu..."
    TITLE_CONFIRM="Confirmation"
    TXT_ANOTHER_FILE="\nDo you want to process another compressed file ?"
    TXT_RETURN_MENU="\nReturning to Wine Tools menu..."
  fi
}

#Recherche de fichiers compressé (.wtgz et .wsquashfs) dans /userdata/roms/windows
compressed_files=()
for file in /userdata/roms/windows/*.wtgz \
            /userdata/roms/windows/*.WTGZ \
            /userdata/roms/windows/*.wsquashfs \
            /userdata/roms/windows/*.WSQUASHFS; do
  [ -f "$file" ] || continue
  compressed_files+=( "$file" "" )
done

set_language_strings

if [ ${#compressed_files[@]} -eq 0 ]; then
  dialog --backtitle "Foclabroc Toolbox" --infobox "$TXT_NONE_FOUND" 12 40 2>&1 >/dev/tty
  sleep 3
  curl -Ls https://raw.githubusercontent.com/foclabroc/toolbox/refs/heads/main/wine-tools/wine.sh | bash
  exit 1
fi

#Choix fichier compressé
selected_file=$(dialog --backtitle "Foclabroc Toolbox" --clear --title "$TITLE_SELECT_COMPRESSED" \
  --menu "$TXT_SELECT_FILE" 25 90 4 "${compressed_files[@]}" 3>&1 1>&2 2>&3)
exit_status=$?
clear
if [ $exit_status -ne 0 ]; then
  dialog --backtitle "Foclabroc Toolbox" --infobox "$TXT_CANCELED" 6 40 2>&1 >/dev/tty
  sleep 2
  curl -Ls https://raw.githubusercontent.com/foclabroc/toolbox/refs/heads/main/wine-tools/wine.sh | bash
  exit 1
fi

# Determiner l'extension du fichier
extension="${selected_file##*.}"
extension=$(echo "$extension" | tr '[:upper:]' '[:lower:]')

#Decompression du fichier
case "$extension" in
  wtgz)
    dialog --backtitle "Foclabroc Toolbox" --infobox "$TXT_DECOMPRESS_TGZ" 6 50 2>&1 >/dev/tty
    base_name=$(basename "$selected_file" .wtgz)
    base_name=$(basename "$base_name" .WTGZ)
    final_dir="/userdata/roms/windows/${base_name}.wine"
    rm -rf "$final_dir"
    mkdir -p "$final_dir"
    tar -xzf "$selected_file" -C "$final_dir" >/dev/tty 2>&1
    if [ $? -ne 0 ]; then
      dialog --backtitle "Foclabroc Toolbox" --msgbox "$TXT_DECOMPRESS_ERR" 7 60 2>&1 >/dev/tty
      sleep 2
      curl -Ls https://raw.githubusercontent.com/foclabroc/toolbox/refs/heads/main/wine-tools/unsquash.sh | bash
    fi
    dialog --backtitle "Foclabroc Toolbox" --msgbox "$TXT_DECOMPRESS_OK" 8 60 2>&1 >/dev/tty
    ;;
  wsquashfs)
    dialog --backtitle "Foclabroc Toolbox" --infobox "$TXT_DECOMPRESS_SQUASH" 6 50 2>&1 >/dev/tty
    base_name=$(basename "$selected_file" .wsquashfs)
    base_name=$(basename "$base_name" .WSQUASHFS)
    final_dir="/userdata/roms/windows/${base_name}.wine"
    rm -rf "$final_dir"
    unsquashfs -d "$final_dir" "$selected_file" 2>&1 >/dev/tty
    if [ $? -ne 0 ]; then
      dialog --backtitle "Foclabroc Toolbox" --msgbox "$TXT_DECOMPRESS_ERR" 7 60 2>&1 >/dev/tty
      sleep 2
      curl -Ls https://raw.githubusercontent.com/foclabroc/toolbox/refs/heads/main/wine-tools/unsquash.sh | bash
    fi
    dialog --backtitle "Foclabroc Toolbox" --msgbox "$TXT_DECOMPRESS_OK" 8 60 2>&1 >/dev/tty
    ;;
  *)
    dialog --backtitle "Foclabroc Toolbox" --infobox "$TXT_UNSUPPORTED_EXT" 5 60 2>&1 >/dev/tty
    sleep 2
    curl -Ls https://raw.githubusercontent.com/foclabroc/toolbox/refs/heads/main/wine-tools/unsquash.sh | bash
    exit 1
    ;;
esac

#Suppression du fichier source (compréssé)
dialog --backtitle "Foclabroc Toolbox" --yesno "$TXT_DELETE_COMPRESSED" 9 60 2>&1 >/dev/tty
if [ $? -eq 0 ]; then
  rm -f "$selected_file"
  if [ $? -eq 0 ]; then
    dialog --backtitle "Foclabroc Toolbox" --msgbox "$TXT_DELETE_OK" 9 60 2>&1 >/dev/tty
  else
    dialog --backtitle "Foclabroc Toolbox" --msgbox "$TXT_DELETE_ERR" 10 40 2>&1 >/dev/tty
    sleep 2
    curl -Ls https://raw.githubusercontent.com/foclabroc/toolbox/refs/heads/main/wine-tools/wine.sh | bash
    exit 1
  fi
fi

#Proposer de traiter un autre dossier
dialog --backtitle "Foclabroc Toolbox" --title "$TITLE_CONFIRM" --yesno "$TXT_ANOTHER_FILE" 8 40 2>&1 >/dev/tty
if [ $? -ne 0 ]; then
  clear
  dialog --backtitle "Foclabroc Toolbox" --infobox "$TXT_RETURN_MENU" 5 40 2>&1 >/dev/tty
  sleep 2
  curl -Ls https://raw.githubusercontent.com/foclabroc/toolbox/refs/heads/main/wine-tools/wine.sh | bash
  exit 1
fi
clear
curl -Ls https://raw.githubusercontent.com/foclabroc/toolbox/refs/heads/main/wine-tools/unsquash.sh | bash
exit 1
