#!/bin/bash

FULL_PATH="$(realpath "$@")";
FOLDER_NAME=$(basename -- "${FULL_PATH}");

if [[ -z "${FOLDER_NAME}" ]]; then
    echo "Please specify folder name.";
    exit 0
fi

MEGA_FOLDER="/Root/${FOLDER_NAME}";

# Print out the account email address used
MEGA_CONFIG="$HOME/.megarc";
if [[ -f "${MEGA_CONFIG}" ]]; then
    MEGA_USERNAME=`sed -n 's/^Username = \(.*\)/\1/p' < ${MEGA_CONFIG}`;
    echo "Using account: ${MEGA_USERNAME}";
fi

echo "Creating remote folder: ${MEGA_FOLDER}";
megatools mkdir "${MEGA_FOLDER}";

echo "Run copy command? [y/N]"
read RUN_COPY

RUN_COPY=${RUN_COPY,,}
if [[ $RUN_COPY == *"y"* ]]; then
    echo "* Copying:"
    echo "Remote: ${MEGA_FOLDER}"
    echo "Local: ${FULL_PATH}"

    megatools copy --remote "${MEGA_FOLDER}" --local "${FULL_PATH}";
else
    exit 0
fi