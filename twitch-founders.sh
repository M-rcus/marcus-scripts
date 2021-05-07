#!/bin/bash

URL="https://founders.titty.stream/?channel=";

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )";
OUTPUT_DIR="${SCRIPT_DIR}/output";

if [[ -d "${OUTPUT_DIR}" ]]; then
    mkdir -p "${OUTPUT_DIR}";
fi

OUTPUT="${OUTPUT_DIR}/twitch_founders.txt";
NOW="$(date +"%Y-%m-%d_%s")";

if [[ -f "${OUTPUT}" ]]; then
    mv "${OUTPUT}" "${OUTPUT_DIR}/twitch_founders.${NOW}.txt";
fi

while read channel;
do
    DATA="$(curl -fsSL "${URL}${channel}")";
    FOUNDERS_COUNT="$(jq '.subscription.founders.count' <<< "${DATA}")";

    # No founders available
    # Either too many subs or no sub button.
    if [[ $FOUNDERS_COUNT -lt 1 ]]; then
        continue;
    fi

    echo $channel >> "${OUTPUT}";
done < "$@";