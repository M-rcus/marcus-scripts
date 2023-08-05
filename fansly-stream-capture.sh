#!/bin/bash

# Things to install if you don't already have it:
# - curl
# - ffmpeg
# - jq

# All three values below can also be set as environment variables, or before you call the script.
# Example: `FANSLY_TOKEN="your-token-here" USER_AGENT="your-user-agent-here" ./fansly-stream-capture.sh Kati3kat`

# You can get the token by opening the browser console and pasting this: `copy(JSON.parse(localStorage.session_active_session).token);`
# It will copy your Fansly token to the clipboard.
# Note that you need to be logged into an account. Some Fansly creators may also restrict streams for certain subscription tiers, followers etc.
# FANSLY_TOKEN=""

# You can either just Google for "what is my user agent", or use this in the browser console: `copy(navigator.userAgent);`
# USER_AGENT=""

# The initial path where livestreams will be stored to
# The resulting path will be something like: $BASE_PATH/$USERNAME/$DATE_$ACCOUNTID_$STREAMID_$TIMESTAMP.ts
# If not set, it will default to the current working directory.
# BASE_PATH="/home/marcus/media/fansly-livestreams"

#################################################################################
#################################################################################
## Unless you know what you are doing, don't change anything below this block. ##
#################################################################################
#################################################################################

if [[ -z "$FANSLY_TOKEN" ]]; then
    echo "Missing Fansly token (\`\$FANSLY_TOKEN\`)";
    exit 1;
fi

if [[ -z "$USER_AGENT" ]]; then
    echo "Missing user agent (\`\$USER_AGENT\`)";
    exit 1;
fi

if [[ -z "$BASE_PATH" ]]; then
    echo "Base path not set. Defaulting to $(pwd)";
    BASE_PATH="$(pwd)";
fi

function request()
{
    curl -H "User-Agent: ${USER_AGENT}" -H "Referer: https://fansly.com/" -H "Authorization: ${FANSLY_TOKEN}" -fsSL "${1}"
}

if [[ -z "$1" ]]; then
    echo "Missing username (first parameter)";
    exit 1;
fi

# The username of the stream you're trying to capture. `${1}` means it gets defined when you run the script.
# Example: `bash fansly-stream-capture.sh badbitch69420xd`
# Would result in: `USERNAME="badbitch69420xd"`
USERNAME="${1}";
ACCOUNT_ID="$(request "https://apiv3.fansly.com/api/v1/account?usernames=${USERNAME}" | jq -r .response[0].id)";
STREAM="$(request "https://apiv3.fansly.com/api/v1/streaming/channel/${ACCOUNT_ID}")";

if [[ $? -ne 0 ]]; then
    echo "Error occurred getting data from Fansly API. Make sure your token/user agent is valid";
    exit 1;
fi

PLAYBACK_URL="$(echo "${STREAM}" | jq -r .response.stream.playbackUrl)";

# Stream not live.
NOW="$(date "+%Y-%m-%d %H:%M:%S")";
if [[ "${PLAYBACK_URL}" == "null" ]]; then
    echo "[${NOW}] ${USERNAME} is not live.";
    exit 0;
fi

STREAM_ID="$(echo "${STREAM}" | jq -r .response.id)";
STREAM_START="$(echo "${STREAM}" | jq -r .response.stream.startedAt)";
STREAM_START=$(( STREAM_START / 1000 ));

STREAM_DATE="$(date -d "@${STREAM_START}" "+%Y-%m-%d")";
NOW="$(date "+%s")";

mkdir -p "${BASE_PATH}/${USERNAME}";
# Append `-report` to this command if you want debug logs
ffmpeg -v warning -hide_banner -stats -user_agent "${USER_AGENT}" -http_persistent 0 -i "${PLAYBACK_URL}" -c copy "${BASE_PATH}/${USERNAME}/${STREAM_DATE}_${ACCOUNT_ID}_${STREAM_ID}_${NOW}.ts"

# In some cases I've noticed that ffmpeg will just detect the stream as offline (playlist ended) for reasons.
# ffmpeg will quit with a successfuly exit code (0), so in those case, I simply trigger the script again.
# When the stream _actually_ goes offline, the script will stop triggering itself as ffmpeg will exit with a non-zero code.
if [[ $? -eq 0 ]]; then
    $0 "${USERNAME}";
fi