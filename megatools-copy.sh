#!/bin/bash

FULL_PATH="$(realpath "$@")";
FOLDER_NAME=$(basename -- "${FULL_PATH}");

if [[ -z "${FOLDER_NAME}" ]]; then
    echo "Please specify folder name.";
    exit 0
fi

MEGA_FOLDER="/Root/${FOLDER_NAME}";
echo "Remote: ${MEGA_FOLDER}";
echo "Local: ${FULL_PATH}";

megatools copy --remote "${MEGA_FOLDER}" --local "${FULL_PATH}";