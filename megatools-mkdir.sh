#!/bin/bash

FOLDER_NAME=$(basename -- "$@");

if [[ -z "${FOLDER_NAME}" ]]; then
    echo "Please specify folder name.";
    exit 0
fi

MEGA_FOLDER="/Root/${FOLDER_NAME}";

echo "Creating remote folder: ${MEGA_FOLDER}";
megatools mkdir "${MEGA_FOLDER}";

echo "Run copy command? [y/N]"
read RUN_COPY

RUN_COPY=${RUN_COPY,,}
if [[ $RUN_COPY == *"y"* ]]; then
    megatools copy --remote "${MEGA_FOLDER}" --local "${FOLDER_NAME}";
else
    exit 0
fi