#!/bin/bash

# Requirements:
# - `curl`
# - `findutils` - Typically pre-installed on Debian/Ubuntu
# - `jq`
# 
# For Debian/Ubuntu: `apt install curl jq findutils` (as root/sudo)
# 
# REQUIRED:
# - Set the `GOFILE_ACCESS_TOKEN` environment variable.
# - Uses the `gofile-single-upload.sh` script in this repository. It's easiest if you just clone it. Alternatively, override the `$GOFILE_UPLOAD` variable below.
#
# If you clone the repository, you can still use symlinks to shortcut `gofile-folder-upload.sh` to for instance "gofile-folder".
# A symlink will still resolve to the "marcus-scripts" directory and thus the "gofile-single-upload" script can easily be picked up.
# 
# OPTIONAL:
# - Set the `GOFILE_PARENT_FOLDER` environment variable as the default parent ID. `-p` can still be used to override the environment variable.

SCRIPT_DIR="$( cd "$( dirname $( realpath "${BASH_SOURCE}" ) )" &> /dev/null && pwd )";
GOFILE_UPLOAD="${SCRIPT_DIR}/gofile-single-upload.sh";

usage()
{
cat << EOF
usage: $0 [FolderName]

Creates a folder based on the input folder names.
Uploads files from input folder to the created Gofile folder.

OPTIONS:
    -p        Parent folder ID.
EOF
}

# Print usage when no parameters specified.
if [[ -z "$@" ]]; then
    usage
    exit 0
fi

PARENT_FOLDER="${GOFILE_PARENT_FOLDER}";

while getopts "hp:" opt; do
    case $opt in
        h)
            usage
            exit 0
            ;;
        p)
            if [[ ! -z "${PARENT_FOLDER}" ]]; then
                echo "Overriding parent folder ID from environment variable - Previous parent folder ID: ${GOFILE_PARENT_FOLDER}";
            fi

            PARENT_FOLDER="${OPTARG}";
            echo "Parent folder ID specified: ${PARENT_FOLDER}";
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

shift $((OPTIND - 1));

if [[ -z "${GOFILE_ACCESS_TOKEN}" ]]; then
    echo "Make sure to set the \`GOFILE_ACCESS_TOKEN\` environment variable.";
    exit 1;
fi

# No parent folder ID specified, so we use the account's root folder.
if [[ -z "${PARENT_FOLDER}" ]]; then
    PARENT_FOLDER="$(curl -fsSL "https://api.gofile.io/getAccountDetails?token=${GOFILE_ACCESS_TOKEN}" | jq -r '.data.rootFolder')";
fi

UPLOAD_FOLDER="$(realpath "$@")";
if [[ ! -d "${UPLOAD_FOLDER}" ]]; then
    echo "Folder does not exist: ${UPLOAD_FOLDER}";
    exit 1;
fi

FOLDER_NAME="$(basename -- "${UPLOAD_FOLDER}")";
CREATED_FOLDER="$(curl -s -X PUT "https://api.gofile.io/createFolder" --data-raw "parentFolderId=${PARENT_FOLDER}&token=${GOFILE_ACCESS_TOKEN}&folderName=${FOLDER_NAME}")";

STATUS="$(echo "${CREATED_FOLDER}" | jq -r .status)";

echo -e "Created folder with status: ${STATUS}\n";

if [[ "${STATUS}" != "ok" ]]; then
    echo "An error occurred creating Gofile folder: ${FOLDER_NAME}";
    jq '.' <<< $CREATED_FOLDER;
    exit 1;
fi

FOLDER_ID="$(echo "${CREATED_FOLDER}" | jq -r .data.id)";
FOLDER_CODE="$(echo "${CREATED_FOLDER}" | jq -r .data.code)";

# Set folder to public
FOLDER_UPDATE="$(curl -s -X PUT "https://api.gofile.io/setFolderOption" --data-raw "folderId=${FOLDER_ID}&token=${GOFILE_ACCESS_TOKEN}&option=public&value=true")";

echo "Set Gofile folder ID ${FOLDER_ID} to be public";

# Navigate to directory.
OLD_DIR="$(pwd)";
cd "${UPLOAD_FOLDER}";
FILES="$(find "." -maxdepth 1 -type f)";

OIFS="$IFS";
IFS=$'\n';
for file in $FILES;
do
    file="$(basename -- "$file")";
    $GOFILE_UPLOAD -f "${FOLDER_ID}" "${file}";
done

IFS="$OIFS";
cd "${OLD_DIR}";

echo -e "\nFiles in ${FOLDER_NAME} uploaded to the following URL: https://gofile.io/d/${FOLDER_CODE}";