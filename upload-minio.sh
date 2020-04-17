#!/bin/bash

RANDOM_NAME="$(date '+%Y-%m-%d')_$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 6 | head -n 1)";
# URL prefix (will be used for clipboard copy)
URL_PREFIX="https://i.titty.stream/f";
# Connection alias (media), bucket (public), folder/path inside bucket (ss - optional)
BUCKET_PATH="media/public/f";
# Location for mc (Minio CLI)
MC_PATH="/usr/bin/mc";

# Enable desktop notifications (requires libnotify)
# Change to `1` to ENABLE desktop notifications.
DESKTOP_NOTIFY_ENABLE=1;
# Notifications: Icon shown
NOTIFY_ICON_PATH="$HOME/Pictures/Apps/Camera_cropped.png";
# Notifications: Timeout in milliseconds
NOTIFY_TIMEOUT=2500;

INPUT_FILE="$@";
INPUT_BASE=$(basename -- "$INPUT_FILE");
INPUT_EXT="${INPUT_BASE##*.}"

OUTPUT_FILE="${RANDOM_NAME}.${INPUT_EXT}";

# Copy input to bucket
$MC_PATH cp $1 "$BUCKET_PATH/$OUTPUT_FILE";

# Format URL and copy to clipboard
FILE_URL="$URL_PREFIX/$OUTPUT_FILE";

echo $FILE_URL;
echo $FILE_URL | xclip -selection clipboard;

if [[ $DESKTOP_NOTIFY_ENABLE -eq 1 ]]; then
    notify-send -t $NOTIFY_TIMEOUT -u low -i $NOTIFY_ICON_PATH "File uploaded and URL copied to clipboard:" $FILE_URL;
fi