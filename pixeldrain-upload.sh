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

Uploads files to Pixeldrain

OPTIONS:
    -h        Show this message
    -s        Short format output: "\$FILENAME => \$URL". Short format will still display errors.
    -b        Short format only: Wrap URL and filename into "list-format" BBCode, you know... for sharing.
              Example: \`[*][URL='https://pixeldrain/u/FILE-ID']filename-blah.mp4[/URL]\`
    -k        Pixeldrain API key. Can also be defined via the \`PIXELDRAIN_API_KEY\` environment variable.
              If this option is specified, it will override the environment variable.
    -i        Echoes only the file ID, nothing else. This flag is used by the \`pixeldrain-folder-upload.sh\` wrapper.
              This will still output errors. Errors should (hopefully) display with a non-zero exit code.
              This will also cause short format options (-s and -b) to be ignored.
EOF
}

# Print usage when no parameters specified.
if [[ -z "$@" ]]; then
    usage
    exit 0
fi

SHORT_FORMAT=0;
BBCODE_FORMAT=0;
ONLY_ID=0;

while getopts "hsbk:i" opt; do
    case $opt in
        h)
            usage
            exit 0
            ;;
        s)
            SHORT_FORMAT=1;
            ;;
        b)
            BBCODE_FORMAT=1;
            ;;
        k)
            PIXELDRAIN_API_KEY="${OPTARG}";
            ;;
        i)
            ONLY_ID=1;

            # Should bypass all the other if statements
            SHORT_FORMAT=2;
            BBCODE_FORMAT=2;
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

SCRIPT_DIR="$(dirname "$0")";

shift $((OPTIND - 1));

DATE="$(date +"%Y%m%d_%H%I%S")";
RESPONSE_FILE="${SCRIPT_DIR}/output/${DATE}_pixeldrain.json";

FILE_NAME="$@";

if [[ $SHORT_FORMAT == 0 ]]; then
    echo "Uploading file: ${FILE_NAME}";
fi

if [[ ! -z "${PIXELDRAIN_API_KEY}" ]]; then
    CURL_ARGS+=" -u :${PIXELDRAIN_API_KEY}";
fi

# "URL encoding". Aka replacing the most common issues I encounter with my filenames lol
# If anyone is some form of Bash guru, feel free to PR with a better solution
URL_FILE_NAME="${FILE_NAME}";
URL_FILE_NAME="${URL_FILE_NAME/\#/%23}";
URL_FILE_NAME="${URL_FILE_NAME/ /%20}";

if [[ $SHORT_FORMAT == 1 || $ONLY_ID == 1 ]]; then
    curl -s -X PUT -T "${FILE_NAME}" $CURL_ARGS "https://pixeldrain.com/api/file/${URL_FILE_NAME}" -o "${RESPONSE_FILE}";
else
    curl --progress-bar -X PUT -T "${FILE_NAME}" $CURL_ARGS "https://pixeldrain.com/api/file/${URL_FILE_NAME}" -o "${RESPONSE_FILE}" | tee;
fi

UPLOAD_EXITCODE=$?

if [[ $SHORT_FORMAT == 0 ]]; then
    echo "Saving Pixeldrain API response for ${FILE_NAME} to: ${RESPONSE_FILE}";
fi

RESPONSE="$(cat "${RESPONSE_FILE}")";
STATUS="$(jq -r '.success' <<< "${RESPONSE}")";

# Ignore short format on errors
if [[ $STATUS == "false" ]]; then
    echo "File upload failed";
    jq -r '[.value, .message]' <<< "${RESPONSE}";
    exit 1;
fi

# I'm not sure this will ever trigger, but maybe if the API times out and doesn't give us a response?
if [[ $UPLOAD_EXITCODE != 0 ]]; then
    echo "File upload failed";
    echo "Some unknown error occurred when uploading the file";
    exit 1;
fi

RESPONSE="$(cat "${RESPONSE_FILE}")";
FILE_ID="$(jq -r '.id' <<< "${RESPONSE}")";
FILE_URL="https://pixeldrain.com/u/${FILE_ID}";

if [[ $SHORT_FORMAT == 1 ]]; then
    if [[ $BBCODE_FORMAT == 1 ]]; then
        echo "[*][URL='${FILE_URL}']${FILE_NAME}[/URL]";
    else
        echo "${FILE_NAME} => ${FILE_URL}";
    fi
    
    exit 0;
fi

if [[ $ONLY_ID == 1 ]]; then
    echo -n "${FILE_ID}";
    exit 0;
fi

echo "File uploaded: ${FILE_URL}";