#!/bin/bash

FOLDER_NAME=$(basename -- "$@");

if [[ -z "${FOLDER_NAME}" ]]; then
    echo "Please specify folder name.";
    exit 0
fi

megatools mkdir "/Root/${FOLDER_NAME}";

echo "Run copy command? [y/N]"
read RUN_COPY

RUN_COPY=${RUN_COPY,,}
if [[ $RUN_COPY == *"y"* ]]; then
    megatools copy --remote "/Root/${FOLDER_NAME}" --local "${FOLDER_NAME}";
else
    exit 0
fi