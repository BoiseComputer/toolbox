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
		en:FETCH) echo "\nFetching Wine Vanilla/Regular versions...";;
		fr:FETCH) echo "\nRécupération des versions de Wine Vanilla/Regular...";;
		en:FETCH_ERR) echo "Error: unable to fetch information from GitHub.";;
		fr:FETCH_ERR) echo "Erreur : impossible de récupérer les informations depuis GitHub.";;
		en:NO_VERSIONS) echo "Error: no versions available.";;
		fr:NO_VERSIONS) echo "Erreur : aucune version disponible.";;
		en:MENU_TITLE) echo "Wine-vanilla";;
		fr:MENU_TITLE) echo "Wine-vanilla";;
		en:MENU_PROMPT) echo "\nChoose a version to download:\n ";;
		fr:MENU_PROMPT) echo "\nChoisissez une version à télécharger :\n ";;
		en:RETURN_MENU) echo "\nReturning to Wine Tools menu...";;
		fr:RETURN_MENU) echo "\nRetour Menu Wine Tools...";;
		en:INVALID_CHOICE) echo "Error: invalid choice ($2).";;
		fr:INVALID_CHOICE) echo "Erreur : choix invalide ($2).";;
		en:INFO_MISSING) echo "Error: unable to retrieve info for version $2.";;
		fr:INFO_MISSING) echo "Erreur : impossible de récupérer les informations pour la version $2.";;
		en:CONFIRM_INSTALL) echo "\nDo you want to download and install $2 ?";;
		fr:CONFIRM_INSTALL) echo "\nVoulez-vous télécharger et installer $2 ?";;
		en:DL_CANCEL) echo "\nDownload of $2 canceled.";;
		fr:DL_CANCEL) echo "\nTéléchargement de $2 annulé.";;
		en:DL_PROGRESS) echo "\nDownloading $2. Please wait...";;
		fr:DL_PROGRESS) echo "\nTéléchargement de $2 Patientez...";;
		en:DL_FAIL) echo "Error: download failed for $2.";;
		fr:DL_FAIL) echo "Erreur : échec du téléchargement de $2.";;
		en:ARCHIVE_EMPTY) echo "Error: archive empty or unreadable.";;
		fr:ARCHIVE_EMPTY) echo "Erreur : archive vide ou illisible.";;
		en:EXTRACT_PROGRESS) echo "\nExtracting $2...";;
		fr:EXTRACT_PROGRESS) echo "\nExtraction de $2 en cours...";;
		en:EXTRACT_OK) echo "\nDownload and extraction of $2 completed successfully.";;
		fr:EXTRACT_OK) echo "\nTéléchargement et extraction de $2 terminé avec succès.";;
		en:EXTRACT_FAIL) echo "Error during extraction.";;
		fr:EXTRACT_FAIL) echo "Erreur lors de l'extraction.";;
	esac
}

select_language

# API endpoint pour récupérer les versions
REPO_URL="https://api.github.com/repos/Kron4ek/Wine-Builds/releases?per_page=300"

# Répertoire d'installation des versions Wine personnalisées
INSTALL_DIR="/userdata/system/wine/custom/"
mkdir -p "$INSTALL_DIR"

# Récupération des versions disponibles
(
	dialog --backtitle "Foclabroc Toolbox" --infobox "$(tr FETCH)" 5 60
  sleep 1
) 2>&1 >/dev/tty
release_data=$(curl -s "$REPO_URL")

# Vérification du succès de la requête
if [[ $? -ne 0 || -z "$release_data" ]]; then
	echo -e "$(tr FETCH_ERR)"
    exit 1
fi

while true; do
    # Préparation des options pour le menu
    options=()
    i=0

    # Construire la liste des options (index et name)
    while IFS= read -r line; do
        tag=$(echo "$line" | jq -r '.name')
        options+=("$i" "$tag")
        ((i++))
    done < <(echo "$release_data" | jq -c '.[]')

    # Vérifier que des options existent
    if [[ ${#options[@]} -eq 0 ]]; then
		echo -e "$(tr NO_VERSIONS)"
        exit 1
    fi

    # Affichage du menu et récupération du choix
	choice=$(dialog --clear --backtitle "Foclabroc Toolbox" --title "$(tr MENU_TITLE)" --menu "$(tr MENU_PROMPT)" 22 76 16 "${options[@]}" 2>&1 >/dev/tty)

    # Nettoyage de l'affichage
    clear

# Si l'utilisateur appuie sur "Annuler" (retourne 1)
	if [[ $? -eq 1 ]]; then
		(
			dialog --backtitle "Foclabroc Toolbox" --infobox "$(tr RETURN_MENU)" 5 60
			sleep 1
		) 2>&1 >/dev/tty
		curl -Ls https://raw.githubusercontent.com/foclabroc/toolbox/refs/heads/main/wine-tools/wine.sh | bash
		exit 0
	fi

# Si l'utilisateur annule la sélection (choix vide)
	if [[ -z "$choice" ]]; then
		(
			dialog --backtitle "Foclabroc Toolbox" --infobox "$(tr RETURN_MENU)" 5 60
			sleep 1
		) 2>&1 >/dev/tty
		curl -Ls https://raw.githubusercontent.com/foclabroc/toolbox/refs/heads/main/wine-tools/wine.sh | bash
		exit 0
	fi

    # Vérification que le choix est bien un nombre
    if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
		echo -e "$(tr INVALID_CHOICE "$choice")"
        sleep 2
        continue
    fi

# Extraire la version et l'URL
	version=$(echo "$release_data" | jq -r ".[$choice].tag_name" 2>/dev/null)
	version="Vanilla-${version}"
	url=$(echo "$release_data" | jq -r ".[$choice].assets[] | select(.name | endswith(\"amd64.tar.xz\")).browser_download_url" | head -n1 2>/dev/null)

# Vérifier si la version est bien récupérée
	if [[ -z "$version" || -z "$url" ]]; then
		echo -e "$(tr INFO_MISSING "$choice")"
		sleep 2
		continue
	fi

# Sauvegarder la version dans un fichier temporaire
	echo -e "$version" > /tmp/version.txt

# Récupérer la version depuis le fichier temporaire pour l'utiliser plus tard
	version=$(cat /tmp/version.txt)

	response=$(dialog --backtitle "Foclabroc Toolbox" --yesno "$(tr CONFIRM_INSTALL "$version")" 7 60 2>&1 >/dev/tty)
	if [[ $? -ne 0 ]]; then
		(
			dialog --backtitle "Foclabroc Toolbox" --infobox "$(tr DL_CANCEL "$version")" 5 60
			sleep 1
		) 2>&1 >/dev/tty
		continue
	fi

	# Création du répertoire de destination
	WINE_DIR="${INSTALL_DIR}${version}"
	mkdir -p "$WINE_DIR"
	cd "${WINE_DIR}"
	clear

	# Préparer le fichier de téléchargement
	ARCHIVE="${WINE_DIR}/${version}.tar.xz"

	# Télécharger le fichier avec wget et afficher la progression dans une boîte dialog
	(
		# Lancer wget avec l'option --progress=dot pour avoir des mises à jour fréquentes
		wget --tries=10 --no-check-certificate --no-cache --no-cookies --progress=dot --timeout=60 -O "$ARCHIVE" "$url" 2>&1 | \
		while read -r line; do
			# Chercher le pourcentage dans la sortie de wget
			if [[ "$line" =~ ([0-9]+)% ]]; then
				PERCENT=${BASH_REMATCH[1]}  # Récupère le pourcentage

				# Mettez à jour la progression de la boîte de dialogue toutes les 10 %
				# Assure-toi que la progression est un multiple de 10
				if (( PERCENT % 10 == 0 )); then
					echo "$PERCENT"  # Envoie la progression à la boîte de dialogue
				fi
			fi
		done

    # Une fois que le téléchargement est terminé, forcer la barre de progression à 100 %
    echo "100"
	) | dialog --backtitle "Foclabroc Toolbox" --gauge "$(tr DL_PROGRESS "$version")" 9 75 0 2>&1 >/dev/tty

	# Vérification du téléchargement
	if [ ! -f "$ARCHIVE" ]; then
		echo -e "$(tr DL_FAIL "$version")"
		sleep 2
		continue
	fi

######################################################################
    # Taille totale de l'archive
    TOTAL_FILES=$(tar -tf "$ARCHIVE" | wc -l)
    if [[ "$TOTAL_FILES" -eq 0 ]]; then
		dialog --msgbox "$(tr ARCHIVE_EMPTY)" 7 60
        exit 1
    fi

    # Création du FIFO pour suivre l'extraction
    TMP_PROGRESS="/tmp/extract_progress"
    rm -f "$TMP_PROGRESS"
    mkfifo "$TMP_PROGRESS"

    # Processus d'extraction en arrière-plan
    COUNT=0
    (
        tar --strip-components=1 -xJf "$ARCHIVE" -C "$WINE_DIR" --checkpoint=10 --checkpoint-action=echo="%u" > "$TMP_PROGRESS" 2>/dev/null &
        TAR_PID=$!

        while read -r CHECKPOINT; do
            COUNT=$((COUNT + 10))
            PERCENT=$((COUNT * 100 / TOTAL_FILES))
            echo "$PERCENT"
        done < "$TMP_PROGRESS"

        wait "$TAR_PID"
        echo 100
	) | dialog --gauge "$(tr EXTRACT_PROGRESS "$version")" 7 60 0 2>&1 >/dev/tty

    rm -f "$TMP_PROGRESS"

    if [ $? -eq 0 ]; then
        rm "$ARCHIVE"
		dialog --backtitle "Foclabroc Toolbox" --infobox "$(tr EXTRACT_OK "$version")" 7 60 2>&1 >/dev/tty
        sleep 2
    else
        rm "$ARCHIVE"
		dialog --msgbox "$(tr EXTRACT_FAIL)" 7 60
    fi
done
