#!/bin/bash

# Example usage:
# - `xfce4-screenshooter -r -o "/home/marcus/projects/scripts/ss-minio.sh"`
# - `./ss-minio.sh /home/marcus/Pictures/MyCuteCat.png`

# Requirements:
# - xclip
# - mc (Minio CLI)
# - notify-send (libnotify) - Optional: Only if desktop notifications are enabled. If notifications are not enabled, URL will be silently copied to the clipboard.

# Generate random name
SS_FILENAME="$(date '+%Y-%m-%d')_$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 6 | head -n 1).png";
# URL prefix (will be used for clipboard copy)
URL_PREFIX="https://i.marcus.pw/ss";
# Connection alias (media), bucket (public), folder/path inside bucket (ss - optional)
BUCKET_PATH="media/public/ss";
# Location for mc (Minio CLI)
MC_PATH="/usr/bin/mc";

# Enable desktop notifications (requires libnotify)
# Change to `1` to ENABLE desktop notifications.
DESKTOP_NOTIFY_ENABLE=1;
# Notifications: Icon shown
NOTIFY_ICON_PATH="$HOME/Pictures/Apps/Camera_cropped.png";
# Notifications: Timeout in milliseconds
NOTIFY_TIMEOUT=2500;

# Copy input to bucket
$MC_PATH cp "$1" "$BUCKET_PATH/$SS_FILENAME";

# Format URL and copy to clipboard
SS_URL="$URL_PREFIX/$SS_FILENAME";
echo $SS_URL | xclip -selection clipboard;

if [[ $DESKTOP_NOTIFY_ENABLE -eq 1 ]]; then
    notify-send -t $NOTIFY_TIMEOUT -u low -i $NOTIFY_ICON_PATH "Screenshot uploaded and URL copied to clipboard:" $SS_URL;
fi