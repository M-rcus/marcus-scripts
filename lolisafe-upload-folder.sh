#!/bin/bash

# Base URL for Lolisafe instance.
# Resulting URLs will be something like: ${BASE_URL}/api/albums
# For example: https://cyberdrop.me/api/albums
BASE_URL="https://cyberdrop.me";
UPLOAD_FOLDER="$(realpath "$@")";

if [[ ! -d "${UPLOAD_FOLDER}" ]]; then
    echo "Folder does not exist: ${UPLOAD_FOLDER}";
    exit 1;
fi

# API token used for creating album and whatever.
# The token can be retrieved from the "Dashboard" page and then "Manage your token"
# The default setting expects the token to be set in the environment variable: `CYBERDROP_TOKEN`.
# Change this as you see fit.
TOKEN="${CYBERDROP_TOKEN}";
ALBUM_NAME="$(basename -- "${UPLOAD_FOLDER}")";

ALBUM_JSON='{"name": "", "description": "", "public": true, "download": true}';
ALBUM_JSON="$(echo "${ALBUM_JSON}" | jq --arg name "${ALBUM_NAME}" '.name = $name')";

echo "Creating album: ${ALBUM_NAME}";

ALBUMS_URL="${BASE_URL}/api/albums";
CREATE_ALBUM="$(curl -fssL -X POST -H "Content-Type: application/json" -H "token: ${TOKEN}" --data "${ALBUM_JSON}" "${ALBUMS_URL}")";

ALBUM_ID="$(echo "${CREATE_ALBUM}" | jq -r '.id')";

if [[ "${ALBUM_ID}" == "null" ]]; then
    echo "Error occurred creating album:";
    echo "${CREATE_ALBUM}" | jq;
    exit 1;
fi

# Navigate to directory.
OLD_DIR="$(pwd)";
cd "${UPLOAD_FOLDER}";

FILES="$(find . -maxdepth 1 -type f)";
UPLOAD_FILE_URL="${BASE_URL}/api/upload";

OIFS="$IFS";
IFS=$'\n';
for file in $FILES;
do
    file="$(basename -- "$file")";
    POST_FILE="$(curl -fsSL -H "token: ${TOKEN}" -H "albumid: ${ALBUM_ID}" -F files[]="@${file}" "${UPLOAD_FILE_URL}")"
    STATUS="$(echo "${POST_FILE}" | jq '.success')";

    if [[ "${STATUS}" == "false" ]]; then
        echo "Unable to upload file: ${file}";
        echo "${POST_FILE}" | jq;
        continue;
    fi

    FINAL_URL="$(echo "${POST_FILE}" | jq -r '.files[].url')";
    echo "File ${file} upload to URL: ${FINAL_URL}";
done

IFS="$OIFS";
cd "${OLD_DIR}";


echo "Retrieving album list from API and attempting to extract album information.";
# Generate a timestamp that should hopefully bypass the API cache, if any?
DATE_TS="$(date +%s)";
# Retrieve albums
GET_ALBUMS="$(curl -fsSL -H "token: ${TOKEN}" "${ALBUMS_URL}?${DATE_TS}")";
# Filter by ID
ALBUM_INFO="$(echo "${GET_ALBUMS}" | jq --arg albumId "${ALBUM_ID}" '.albums[] | select(.id == ($albumId | tonumber))')";

if [[ "${ALBUM_INFO}" == "" ]]; then
    echo "Unless you saw other errors, album was created and files uploaded successfully."
    echo "However, the script could not extract information about the new album from the API - potentially due to cache. Otherwise it'd display the URL here.";
else
    # Extract the actual name, in case of any filtering/stripping etc.
    ALBUM_NAME="$(echo "${ALBUM_INFO}" | jq -r '.name')";
    # Extract the album slug used for the URL.
    ALBUM_SLUG="$(echo "${ALBUM_INFO}" | jq -r '.identifier')";

    echo "Upload complete for album: ${ALBUM_NAME}";
    echo "Album URL: ${BASE_URL}/a/${ALBUM_SLUG}";
fi