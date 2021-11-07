#!/bin/bash

# Chumbi Image Downloader
# By Rasmez

# Script Version
VERSION="1.1"

# Image Sizes // Sticker:320px MAX // Emoji:128px MAX 
S_SIZE="320"
E_SIZE="128"
# Set working dir to current directory
dir=$(cd -P -- "$(dirname -- "$0")" && pwd -P) || exit

# Download directories
E_DIR="${dir%/}/emojis/"
S_DIR="${dir%/}/stickers/"

# Image Lists
E_FILE="${dir%/}/chumbi-emoji-list.txt"
S_FILE="${dir%/}/chumbi-sticker-list.txt"

# GUI Constants
DIALOG_CANCEL=1
DIALOG_ESC=255
HEIGHT=0
WIDTH=0

# Automatic Mode (no gui)
if [ "$1" == "auto" ]; then
	printf "Automatic mode engaged!"
	if [ ! -d "$E_DIR" ]; then
	  			mkdir "$E_DIR"
	  	fi
      	if test -f "$E_FILE"; then
	  		input="$E_FILE"
	  		while IFS= read -r line
				do
					URL="https://media.discordapp.net/emojis/"
					URL+="$line"
					URL+="?size="
					URL+="$E_SIZE"
					wget -q -c --show-progress -O "$E_DIR/$line" "$URL"
				done < "$input"
      	else
        	display_result "ERROR, $E_FILE not found!"
      	fi
      	
      	if [ ! -d "$S_DIR" ]; then
	  			mkdir "$S_DIR"
	  	fi
      	if test -f "$S_FILE"; then
	  		input="$S_FILE"
	  		while IFS= read -r line
				do
					URL="https://media.discordapp.net/stickers/"
					URL+="$line"
					URL+="?size="
					URL+="$S_SIZE"
					wget -q -c --show-progress -O "$S_DIR/$line" "$URL" 
				done < "$input"
      	else
        	display_result "ERROR, $S_FILE not found!"
      	fi
	
# Manual Mode

else
	printf "ERROR! Invalid argument"
	display_result() {
  	dialog --title "$1" \
    	--no-collapse \
    	--msgbox "$result" 0 0
	}
	
	while true; do
  	exec 3>&1
  	selection=$(dialog \
    	--backtitle "Chumbi Image Downloader v$VERSION" \
    	--title "Menu" \
    	--clear \
    	--cancel-label "Exit" \
    	--menu "Please select:" $HEIGHT $WIDTH 4 \
    	"1" "Download Chumbi Emojis" \
    	"2" "Download Chumbi Stickers" \
    	"3" "Check for Emoji and Sticker Lists" \
    	2>&1 1>&3)
  	exit_status=$?
  	exec 3>&-
  	case $exit_status in
    	$DIALOG_CANCEL)
      	clear
      	echo "Program terminated."
      	exit
      	;;
    	$DIALOG_ESC)
      	clear
      	echo "Program aborted." >&2
      	exit 1
      	;;
  	esac
  	case $selection in
    	1 )
      	if [ ! -d "$E_DIR" ]; then
	  			mkdir "$E_DIR"
	  	fi
      	if test -f "$E_FILE"; then
	  		input="$E_FILE"
	  		while IFS= read -r line
				do
					URL="https://media.discordapp.net/emojis/"
					URL+="$line"
					URL+="?size="
					URL+="$E_SIZE"
					wget -q -c --progress=dot --show-progress -O "$E_DIR/$line" "$URL" 2>&1 |\
					grep "%" |\
					sed -u -e "s,\.,,g" | awk '{print $2}' | sed -u -e "s,\%,,g"  | dialog --gauge "Downloading $line..." 10 100
				done < "$input"
      	else
        	display_result "ERROR, $E_FILE not found!"
      	fi
      	;;
    	2 )
      	if [ ! -d "$S_DIR" ]; then
	  			mkdir "$S_DIR"
	  	fi
      	if test -f "$S_FILE"; then
	  		input="$S_FILE"
	  		while IFS= read -r line
				do
					URL="https://media.discordapp.net/stickers/"
					URL+="$line"
					URL+="?size="
					URL+="$S_SIZE"
					wget -q -c --progress=dot --show-progress -O "$S_DIR/$line" "$URL" 2>&1 |\
					grep "%" |\
					sed -u -e "s,\.,,g" | awk '{print $2}' | sed -u -e "s,\%,,g"  | dialog --gauge "Downloading $line..." 10 100
				done < "$input"
      	else
        	display_result "ERROR, $S_FILE not found!"
      	fi
      	;;
    	3 )
      	if test -f "$E_FILE"; then
        	display_result "The Emoji List is installed!"
      	else
        	display_result "ERROR, $E_FILE list not found! You can get it here: https://github.com/Rasmez/chumbi-image-downloader"
      	fi
      	if test -f "$S_FILE"; then
        	display_result "The Sticker List is installed!"
            	else
        	display_result "ERROR, $S_FILE not found! You can get it here: https://github.com/Rasmez/chumbi-image-downloader"
      	fi
      	;;
  	esac
	done
fi
