#!/bin/bash

# Requirements:
# - `curl`
# - `jq`
# 
# For Debian/Ubuntu: `apt install curl jq` (as root/sudo)
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

if [[ -z "${GOFILE_SERVER}" ]]; then
    echo "No Gofile server specified. Requesting new one";
    GOFILE_SERVER="$(curl -fsSL https://api.gofile.io/getServer | jq -r '.data.server')";

    if [[ -z "${GOFILE_SERVER}" ]]; then
        echo "Unable to get Gofile server from API. Exiting.";
        exit 1;
    fi

    echo "Gofile server set to: ${GOFILE_SERVER}";
fi

# If no folder ID is specified, we either:
# - Use the root folder
# - Prompt the user to create one.
# 
# At the moment it will just default to use the root folder.
# 
# Eventually I'll add a flag or something to create a folder,
# which allows for specifying a folder name, of course.
if [[ -z "${FOLDER_ID}" ]]; then
    ROOT_FOLDER_ID="$(curl -fsSL "https://api.gofile.io/getAccountDetails?token=${GOFILE_ACCESS_TOKEN}" | jq -r '.data.rootFolder')";

    FOLDER_ID="${ROOT_FOLDER_ID}";
fi

shift $((OPTIND - 1));

FILE_NAME="$@";
curl --progress-bar -X POST -F folderId="${FOLDER_ID}" -F token="${GOFILE_ACCESS_TOKEN}" -F "file=@\"${FILE_NAME}\"" "https://${GOFILE_SERVER}.gofile.io/uploadFile" | tee;

# Just to add spacing
echo;