#!/bin/bash

# This script creates a profile directory that is the new "extra_auth" as of v6.1.
# The profile directory and `auth.json` file will be in the format `.profiles/OnlyFans/YYYY-MM-DD_USER-INPUT-HERE/auth.json`
# Like most of my scripts, it's biased after my own personal preferences. Feel free to modify as you like though.
# 
# Keep in mind that the script isn't "idiot proof", so you should probably be a bit cautious when using it.
# It doesn't remove anything (or at least shouldn't), but based on the input name you might create recursive folders
# as the script uses `mkdir -p` and doesn't check the input before using it.

# Where the DIGITALCRIMINAL/OnlyFans directory exists on your PC.
OF_PROJECT_DIR="${HOME}/projects/OnlyFans";

# Where the `.profiles` directory is
# Should not be necessary to change, but it might be different depending on `config.json`????
# Legit no idea. Try it out I guess?
OF_PROFILES="${OF_PROJECT_DIR}/.profiles/OnlyFans";

TODAY="$(date +"%Y-%m-%d")";

echo "Name? - Used in the folder name after the date";
read FOLDER_NAME;

PROFILE_DIR="${OF_PROFILES}/${TODAY}_${FOLDER_NAME}";
if [[ -d "${PROFILE_DIR}" ]]; then
    echo "Profile directory already exists -- Quitting: ${PROFILE_DIR}";
    exit 1;
fi

mkdir -p "${PROFILE_DIR}";
touch "${PROFILE_DIR}/auth.json";

# Check & open Sublime Text if it's installed
# fallback to `nano` instead.
# `nano` is installed on all of my personal systems, can't speak for everyone else...
HAS_SUBLIME="$(which subl)";
if [[ $? -eq 0 ]]; then
    subl "${PROFILE_DIR}/auth.json";
else
    nano "${PROFILE_DIR}/auth.json";
fi