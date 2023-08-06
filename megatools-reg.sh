#!/bin/bash

# Helper script for faster creation of Mega accounts using `megatools`
#
# * Requirements:
# - megatools: https://megatools.megous.com/
#   - At the time of writing I'm using 1.11.0 (experimental)
# - Bash, I guess?
# - `sed` - Though I think this is available by default on Debian / Ubuntu, and probably on other systems.

# If `$HOME/.megarc` is already defined with a password
# We attempt to load it from there.
MEGA_PASSWORD=`sed -n 's/^Password = \(.*\)/\1/p' < $HOME/.megarc`;
MEGA_FULL_NAME=`sed -n 's/^FullName = \(.*\)/\1/p' < $HOME/.megarc`;

EMAIL="${1}";
if [[ -z "${EMAIL}" ]]; then
    echo "Email address?";
    read EMAIL;
fi

if [ -z "${MEGA_PASSWORD}" ]; then
    echo "Password?";
    read PASSWORD;
else
    echo "Found password in .megarc, using this one: ${MEGA_PASSWORD}";
    PASSWORD="${MEGA_PASSWORD}";
fi

FULL_NAME="${MEGA_FULL_NAME}";
if [[ -z "${FULL_NAME}" ]]; then
    echo "Name?"
    read FULL_NAME;
fi

# Replace `@LINK@` with an empty string, so the eval further down actually fucking works :rolling_eyes:
# Not sure why the `--scripted` parameter is so fucking retarded and includes `@LINK@` like... why?
VERIFY_CMD="$(megatools reg --scripted --register --email "${EMAIL}" --password "${PASSWORD}" --name "${FULL_NAME}")";
VERIFY_CMD="${VERIFY_CMD// @LINK@/}";

echo "Verification link?"
read VERIFY_LINK;

echo "$VERIFY_CMD $VERIFY_LINK";
eval "${VERIFY_CMD} ${VERIFY_LINK}"

# If you want the script to override the `Username` value in `.megarc`, then you can set this variable
# I recommend setting it as an environment variable, e.g. in .bashrc or similar, but you can optionally uncomment the line below.
# MEGA_REGISTER_OVERRIDE_USERNAME="1"
if [[ "${MEGA_REGISTER_OVERRIDE_USERNAME}" == 1 ]]; then
    echo "Replacing username in $HOME/.megarc";
    sed -i "s/^Username = \(.*\)$/Username = ${EMAIL}/" "$HOME/.megarc";
fi