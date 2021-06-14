#!/bin/bash

# Requirements:
# - `curl`
# 
# For Debian/Ubuntu: `apt install curl` (as root/sudo)
# 
# This script is _incredibly_ dumb, because it requires you to "create" an upload already, by uploading one file, before uploading your "main" file(s).
# e.g. In the instances where I upload a small image first (via browser), copy the admin code and then use my server to upload the video (usually a few GBs).
# 
# REQUIRED:
# Set the `GOFILE_ACCESS_TOKEN` environment variable.

usage()
{
cat << EOF
usage: $0 [FileName]

Uploads files to Gofile

OPTIONS:
    -f        Folder ID. Used for uploading files to an existing upload/folder.
    -s        What server to use (e.g. 'srv-store8'). Used in the format of https://srv-store8.gofile.io
    -h        Show this message
EOF
}

# Print usage when no parameters specified.
if [[ -z "$@" ]]; then
    usage
    exit 0
fi

GOFILE_SERVER="";
FOLDER_ID=""

while getopts "hs:f:" opt; do
    case $opt in
        h)
            usage
            exit 0
            ;;
        s)
            GOFILE_SERVER="${OPTARG}";
            echo "Gofile server specified: ${GOFILE_SERVER}";
            ;;
        f)
            FOLDER_ID="${OPTARG}";
            echo "Folder ID specified: ${FOLDER_ID}";
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            exit 1
            ;;
    esac
done

if [[ -z "${GOFILE_ACCESS_TOKEN}" ]]; then
    echo "Make sure to set the \`GOFILE_ACCESS_TOKEN\` environment variable.";
    exit 1;
fi

# TODO: Add support for auto-selecting server and such.
if [[ -z "${GOFILE_SERVER}" ]]; then
    echo "No Gofile server specified. Requesting new one";
    GOFILE_SERVER="$(curl -fsSL https://api.gofile.io/getServer | jq -r '.data.server')";

    if [[ -z "${GOFILE_SERVER}" ]]; then
        echo "Unable to get Gofile server from API. Exiting.";
        exit 1;
    fi

    echo "Gofile server set to: ${GOFILE_SERVER}";
fi

shift $((OPTIND - 1));

FILE_NAME="$@";
curl --progress-bar -X POST -F folderId="${FOLDER_ID}" -F token="${GOFILE_ACCESS_TOKEN}" -F file="@${FILE_NAME}" "https://${GOFILE_SERVER}.gofile.io/uploadFile" | tee;