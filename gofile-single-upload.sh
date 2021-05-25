#!/bin/bash

# Requirements:
# - `curl`
# 
# For Debian/Ubuntu: `apt install curl` (as root/sudo)
# 
# This script is _incredibly_ dumb, because it requires you to "create" an upload already, by uploading one file, before uploading your "main" file(s).
# e.g. In the instances where I upload a small image first (via browser), copy the admin code and then use my server to upload the video (usually a few GBs).

usage()
{
cat << EOF
usage: $0 [FileName]

Uploads files to Gofile

OPTIONS:
    -a        Admin code. Used for uploading files to an existing upload.
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
ADMIN_CODE="";

while getopts "hs:a:" opt; do
    case $opt in
        h)
            usage
            exit 0
            ;;
        s)
            GOFILE_SERVER="${OPTARG}";
            echo "Gofile server: ${GOFILE_SERVER}";
            ;;
        a)
            ADMIN_CODE="${OPTARG}";
            echo "Admin code specified: ${ADMIN_CODE}";
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

if [[ -z "${GOFILE_EMAIL}" ]]; then
    echo "Please set the GOFILE_EMAIL environment variable";
    exit 1;
fi

# TODO: Add support for auto-selecting server and such.
if [[ -z "${GOFILE_SERVER}" || -z "${ADMIN_CODE}" ]]; then
    echo "Please specify Gofile server and admin code";
    exit 1;
fi

shift $((OPTIND - 1));

FILE_NAME="$@";
curl --progress-bar -X POST -F email="${GOFILE_EMAIL}" -F ac="${ADMIN_CODE}" -F file="@${FILE_NAME}" "https://${GOFILE_SERVER}.gofile.io/uploadFile" | tee;