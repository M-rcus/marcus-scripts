#!/bin/bash

# Requirements:
# - `curl`
# - `jq`
# - `parallel`
# 
# For Debian/Ubuntu: `apt install curl jq parallel`

usage()
{
cat << EOF
usage: $0 [space_separated_creators]

Downloads posts from creators on ofans.party

As of right now, the script downloads to the following directory:
    [output-directory]/[creator-name]/[post-id]_[date:YYYY-mm-dd]_[media-id].[filetype]

* Dates are according to the API, which is either "OnlyFans create date" (I assume that's when it was posted to OnlyFans)
  and just "create date", which I believe is when the post was added to ofans.party.
  - Because sometimes the "OnlyFans create date" can be missing and the "create date" is pretty unreliable,
    I've decided to use the post ID at the beginning of the file name, for sorting purposes.
  - I also have no idea if my theories are correct in any regard lol


If metadata is requested (\`-d\`), it will be written as a JSON dump under:
    [output-directory]/[creator-name]/metadata.json
Keep in mind that metadata.json will be overwritten every time you run the script for said creator.

OPTIONS:
    -p        How many \`NUM\` post downloads to run in parallel (default: 2).
    -o        Output directory. Default is: `pwd`/ofans
    -h        Show this message
    -d        Dump metadata for creator as JSON
EOF
}

# Print usage when no parameters specified.
if [[ -z "$@" ]]; then
    usage
    exit 0
fi

which curl jq parallel > /dev/null;
DEP_RESULT=$?;
if [[ $DEP_RESULT -ne 0 ]]; then
    echo "curl, jq or parallel are missing. Please verify that they are all installed.";
    exit $DEP_RESULT;
fi

# Default settings
PARALLEL_DL=2;
DUMP_METADATA=0;
OUTPUT_DIR="$(pwd)/ofans";

while getopts "hdp:o:" opt; do
    case $opt in
        h)
            usage
            exit 0
            ;;
        p)
            PARALLEL_DL=$OPTARG;
            echo "Parallel downloads: ${PARALLEL_DL}";
            ;;
        d)
            DUMP_METADATA=1;
            ;;
        o)
            OUTPUT_DIR="${OPTARG}";
            echo "Output directory specified: ${OUTPUT_DIR}";
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

# You can override the IPFS URL by setting it as an environment variable
# before running the script.
# 
# We fall back to the Cloudflare one, but I'm not sure if it's the most ideal...
if [[ -z "${OFANS_IPFS_URL}" ]]; then
    OFANS_IPFS_URL="https://cloudflare-ipfs.com/ipfs";
fi

# Shorter variable name
IPFS="${OFANS_IPFS_URL}";

# Get rid of command flags from input params
shift $((OPTIND - 1));

CREATORS=$@;
DL_DIR=$OUTPUT_DIR;
for creator in $CREATORS;
do
    echo "Fetching OnlyFans posts for creator: ${creator}";
    CREATOR_URL="https://api.ofans.party/posts/${creator}";
    FETCH_CREATOR="$(curl --fail --silent -L "${CREATOR_URL}")";

    if [[ $? -ne 0 ]]; then
        echo "[Skipping] Error occurred fetching creator: ${creator}";
        continue;
    fi

    CREATOR_DATA="$(jq -r . <<< "${FETCH_CREATOR}")";
    POSTS="$(jq -r '.response.posts' <<< "${FETCH_CREATOR}")";
    POST_COUNT="$(jq -r 'length' <<< "${POSTS}")";

    if [[ $POST_COUNT -lt 1 ]]; then
        echo "[Skipping] No posts found for creator: ${creator}";
        continue;
    fi

    echo "Found ${POST_COUNT} posts from ${creator} on ofans.party";

    CREATOR_DIR="${DL_DIR}/${creator}";
    if [[ -d "${CREATOR_DIR}" ]]; then
        echo "Creator directory exists: ${CREATOR_DIR}";
    else
        echo "Attempting to create directory: ${CREATOR_DIR}";
        mkdir -p "${CREATOR_DIR}";

        if [[ $? -ne 0 ]]; then
            echo "[Skipping] Unable to create directory: ${CREATOR_DIR}";
            continue;
        fi
    fi

    # Metadata
    if [[ $DUMP_METADATA -eq 1 ]]; then
        echo "${CREATOR_DATA}" > "${CREATOR_DIR}/metadata.json";
        echo "[Metadata] Saved to: ${CREATOR_DIR}/metadata.json";
    fi

    # Attempt to create temp file to
    # store the cURL commands in for the creator.
    TMP_PREFIX="ofans_${creator}.XXXXXXX";
    TMP_FILE="$(mktemp -t "${TMP_PREFIX}")";
    if [[ $? -ne 0 ]]; then
        echo "[Skipping] Unable to create TEMP file for creator: ${creator}";
        continue;
    fi

    echo "Temp file created: ${TMP_FILE}";

    # Thanks homie: https://unix.stackexchange.com/a/477218
    # Process each post
    for pIdx in $(jq -r 'keys | .[]' <<< "${POSTS}"); do
        POST="$(jq ".[${pIdx}]" <<< "${POSTS}")";

        POST_ID="$(jq -r '.post_id' <<< "${POST}")";
        POST_DATE="$(jq -r '.of_create_date' <<< "${POST}")";

        # Fall back to `create_date` if `of_create_date` is not defined.
        if [[ "${POST_DATE}" == "null" ]]; then
            POST_DATE="$(jq -r '.create_date' <<< "${POST}")";
        fi

        FILE_DATE="$(date --date="${POST_DATE}" +"%Y-%m-%d")";

        # Process each media file
        MEDIAS="$(jq -r '.media' <<< "${POST}")";
        for mIdx in $(jq -r 'keys | .[]' <<< "${MEDIAS}"); do
            # Extract values we want to use
            MEDIA="$(jq -r ".[${mIdx}]" <<< "${MEDIAS}")";
            MEDIA_ID="$(jq -r '.of_media_id' <<< "${MEDIA}")";
            TYPE="$(jq -r '.type' <<< "${MEDIA}")";

            # File extensions are best guesses
            # Based on my own experience videos uploaded to OnlyFans ALWAYS get
            # converted to MP4s (H264) and photos are ALWAYS JPGs.
            EXTENSION='';
            if [[ "${TYPE}" == "photo" ]]; then
                EXTENSION=".jpg";
            elif [[ "${TYPE}" == "video" ]]; then
                EXTENSION=".mp4";
            fi

            IPFS_HASH="$(jq -r '.ipfs_media_hash' <<< "${MEDIA}")";
            FILE_NAME="${POST_ID}_${FILE_DATE}_${MEDIA_ID}${EXTENSION}";

            # Alright, I know this is ghetto, but I figured it was the easiest
            # way after parsing the JSON by calling jq 9 billion times
            # Bash wasn't exactly the right tool for this, but whatever.
            CMD="curl -fLo '${CREATOR_DIR}/${FILE_NAME}' ${IPFS}/${IPFS_HASH}";
            echo "${CMD}" >> "${TMP_FILE}";
        done

        echo "[Processing] Processed post ID ${POST_ID} from creator: ${creator}";
    done

    echo "[Processing] Finished processing creator: ${creator}";

    echo "[Downloading] Medias from creator: ${creator}";
    echo "[Downloading] Downloads in parallel: ${PARALLEL_DL}";
    echo "[Info] Please keep in mind that since the files are hosted using IPFS (https://ipfs.io/), they may take a long time to download. Please be patient.";

    parallel -j $PARALLEL_DL < "${TMP_FILE}";

    echo "[Downloading] Downloads complete for: ${creator}";
done
