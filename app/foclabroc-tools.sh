#!/bin/bash
if [[ "$LANG" == en* ]]; then
	echo "Add script to temp then execute"
else
	echo "Ajout du script en temporaire puis exécution"
fi
rm /tmp/scripttool.sh 2>/dev/null
curl -L https://raw.githubusercontent.com/foclabroc/toolbox/refs/heads/main/app/foclabroc-toolbox-ports.sh -o /tmp/scripttool.sh
dos2unix /tmp/scripttool.sh 2>/dev/null

# Ouvrir un terminal interactif et exécuter le script
DISPLAY=:0.0
xterm -fullscreen -hold -bg black -fa "DejaVuSansMono" -fs 12 -en UTF-8 -e "bash /tmp/scripttool.sh"
