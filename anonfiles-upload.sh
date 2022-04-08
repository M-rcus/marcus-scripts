#!/bin/bash

# Requirements:
# - `curl` - Used for uploading
# - `jq` - Used for extracting the file URL from the API
# - `date` - Used for logging and data filenames in `output`
# 
# For Debian/Ubuntu: `apt install curl jq` (as root/sudo)

usage()
{
cat << EOF
usage: $0 [FileName]

Uploads files to Anonfiles

OPTIONS:
    -h        Show this message
EOF
}

# Print usage when no parameters specified.
if [[ -z "$@" ]]; then
    usage
    exit 0
fi

while getopts "h" opt; do
    case $opt in
        h)
            usage
            exit 0
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

SCRIPT_DIR="$(dirname "$(readlink "$0")")";

shift $((OPTIND - 1));

DATE="$(date +"%Y%m%d_%H%I%S")";
RESPONSE_FILE="${SCRIPT_DIR}/output/${DATE}_anonfiles.json";

FILE_NAME="$@";
echo "Uploading file: ${FILE_NAME}";
curl --progress-bar -X POST -F "file=@\"${FILE_NAME}\"" "https://api.anonfiles.com/upload" -o "${RESPONSE_FILE}" | tee;

echo "Saving Anonfiles API response for ${FILE_NAME} to: ${RESPONSE_FILE}";
RESPONSE="$(cat "${RESPONSE_FILE}")";
STATUS="$(jq -r '.status' <<< "${RESPONSE}")";

if [[ $STATUS == "false" ]]; then
    echo "File upload failed";
    jq -r '.error' <<< "${RESPONSE}";
    exit 1;
fi

RESPONSE="$(cat "${RESPONSE_FILE}")";
FILESIZE="$(jq -r '.data.file.metadata.size.readable' <<< "${RESPONSE}")";
FILE_URL="$(jq -r '.data.file.url.full' <<< "${RESPONSE}")"
echo "File uploaded (${FILESIZE}): ${FILE_URL}";