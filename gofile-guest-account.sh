#!/bin/bash

# Requirements:
# - `curl`
# - `jq`
# 
# For Debian/Ubuntu: `apt install curl jq` (as root/sudo)

VERBOSE=0;
USER_AGENT="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.4896.127 Safari/537.36";

usage()
{
cat << EOF
usage: $0 [options]

Creates a temporary Gofile guest account. Useful for "fire and forget" uploads.
By default only echoes out the Gofile account token that can be used for API requests and uploads.

Saves JSON into the \`output\` directory in the script folder.

OPTIONS:
    -h        Print help/usage information
    -v        Non-silent cURL requests and JSON dumps (verbose)
    -u        Use a custom user agent - Default: ${USER_AGENT}
EOF
}

while getopts "hvu:" opt; do
    case $opt in
        h)
            usage
            exit 0
            ;;
        v)
            VERBOSE=1;
            ;;
        u)
            USER_AGENT="${OPTARG}";
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

CURL_CMD="curl -fsSL";

if [[ $VERBOSE == 1 ]]; then
    CURL_CMD="curl -fSL";
fi

CURL_CMD="${CURL_CMD} -H 'User-Agent: ${USER_AGENT}'";
CREATE_ACCOUNT=$(eval "${CURL_CMD} -X POST https://api.gofile.io/accounts");

if [[ $VERBOSE == 1 ]]; then
    jq . <<< "${CREATE_ACCOUNT}";
fi

STATUS="$(jq -r .status <<< "${CREATE_ACCOUNT}")";

# If unsuccessful, dump the whole JSON and exit with non-zero.
if [[ "${STATUS}" != "ok" ]]; then
    jq . <<< "${CREATE_ACCOUNT}";
    exit 1;
fi

TOKEN="$(jq -r .data.token <<< "${CREATE_ACCOUNT}")";

# Add trailing newline for verbose output
if [[ $VERBOSE == 1 ]]; then
    echo $TOKEN;
    exit 0;
fi

echo -n $TOKEN;