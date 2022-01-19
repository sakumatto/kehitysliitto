#!/bin/bash
STARTTIME=$SECONDS


# A script to automate Valo-liitto.fi Hugo built sites data pushing to server by Saku Mättö.
# Read server IP, username & port (in that order each on its own line) from file
# so as to not divulge them to the public.


# Set script to exit at any error.

set -e

# Load times and file locations

TIME=$(date +"%H:%M")
DATE=$(date +"%d.%m.%Y")
DIR=$(eval echo "/Users/saku/Documents/GitHub")
DEVDIR=$DIR/kehitysliitto
PUBDIR=$DEVDIR/public
FILE=$DIR/server.ip.txt

# Load server IP, username & port

IP=$(head -n 1 "$FILE")
USER=$(sed -n '2p' "$FILE")
PORT=$(tail -n 1 "$FILE")

# Build the site in dev directory and then go to created "public" dir
cd $DEVDIR && \
hugo --gc --minify --buildDrafts=false && \
cd $PUBDIR && \

# Search through the public directory for files containing the term "icons/" and 
# swap every instance to "ikonit/", yet excluding filenames ending ".iconsbu".
# After replacing, save file back to original location and create bu-file with ending ".iconsbu".
# You can manually rm all the bu-files when all's ok.
#
# Then sync all to server excluding certain filenames (such as .iconsbu).
#
# This is logically one command depending on the previous cmd executing correctly,
# using the "&&" logic is failsafe, making sure all previous executed correctly.

grep -rlZ 'icons/' --exclude="*.iconsbu" . | tr '\n' '\0' | xargs -0 sed -i.iconsbu 's%icons/%ikonit/%g' && \
rsync -vauc -e "ssh -p$PORT" --exclude .git --exclude .DS_Store --exclude .iconsbu \
--exclude .ftpquota "$PUBDIR/" \
"$USER@$IP:/home/$USER/www"

# Print IP and port on cmd line and execution time.

ENDTIME=$((SECONDS-STARTTIME))
printf "%10s %5s IP:portti %11s : %5s %2ssekuntia\n" "$DATE" "$TIME" "$IP" "$PORT" "$ENDTIME"



