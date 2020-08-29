#!/bin/bash

# Helper script for faster creation of Mega accounts using `megatools`
#
# * Requirements:
# - megatools: https://megatools.megous.com/
#   - At the time of writing I'm using 1.11.0 (experimental)
# - Bash, I guess?

# If `$HOME/.megarc` is already defined with a password
# We attempt to load it from there.
MEGA_PASSWORD=`sed -n 's/^Password = \(.*\)/\1/p' < $HOME/.megarc`;

echo "Email address?";
read EMAIL;

if [ -z "${MEGA_PASSWORD}" ]; then
    echo "Password?";
    read PASSWORD;
else
    echo "Found password in .megarc, using this one: ${MEGA_PASSWORD}";
    PASSWORD="${MEGA_PASSWORD}";
fi

echo "Name?"
read FULL_NAME;

VERIFY_CMD="$(megatools reg --scripted --register --email "${EMAIL}" --password "${PASSWORD}" --name "${FULL_NAME}")";
# Replace `@LINK@` with an empty string, so the eval further down actually fucking works :rolling_eyes:
VERIFY_CMD=`sed -n 's/@LINK@//g' -- ${VERIFY_CMD}`;

echo "Verification link?"
read VERIFY_LINK;

echo "$VERIFY_CMD $VERIFY_LINK";
`$VERIFY_CMD $VERIFY_LINK`