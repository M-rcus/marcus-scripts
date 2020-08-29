#!/bin/bash

# Bash script for swapping DIGITALCRIMINAL/OnlyFans configs
# so that I can easily change between "manual ripping" of profiles
# or automatic ripping which just runs continuously every 15 minutes.
# 
# For the script to work, you need to make a copy of the `config.json` file
# and configure it to be either the MANUAL or AUTOMATIC one.
# 
# If you make a copy that's named the same as $CONFIG_MANUAL, the script will assume that the
# current config is the one used for AUTOMATIC ripping.
# 
# The opposite occurs if you make a copy same as $CONFIG_AUTO,
# current config is considered the one used for MANUAL ripping.
# 
# TL;DR Make a copy that's either $CONFIG_MANUAL or $CONFIG_AUTO, not both.
# 
# The idea is that $CONFIG_AUTO can rip everything automatically by itself constantly.
# In my case that means:
# - `loop_timeout` is set to a sensible value (e.g. 900 = runs 15 minutes after last completed rip)
# - `auto_scrape_names` and `auto_scrape_apis` = true
# - `choose_auth` = false*
# 
# For $CONFIG_MANUAL it's basically the complete opposite:
# - `loop_timeout` = "0" or ""
# - `auto_scrape_names` and `auto_scrape_apis` = false
# - `choose_auth` = true*
# 
# * `choose_auth` assumes you have `extra_auth` = true
#    since it's meant for the times you have multiple accounts configured.

# Where the DIGITALCRIMINAL/OnlyFans directory exists on your PC.
OF_PROJECT_DIR="$HOME/projects/OnlyFans";

# Where the settings directory is
# Not necessary to change unless the project changes this in the future.
OF_SETTINGS="$OF_PROJECT_DIR/.settings";

# Current working directory
# Mainly used to navigate back to it after script finishes
CURRENT_PWD="$(pwd)";

# Config file names
CONFIG_CURRENT="config.json";
CONFIG_AUTO="config.auto.json";
CONFIG_MANUAL="config.manual.json";

# Navigate to settings directory in OF project.
cd "${OF_SETTINGS}";

# If both configs exist we quit the script
# to not fuck up any of the configs.
if [[ -f "${CONFIG_AUTO}" && -f "${CONFIG_MANUAL}" ]]; then
    echo "Both manual ripping config (${CONFIG_MANUAL}) and automatic ripping config (${CONFIG_AUTO}) exist.";
    echo "The script is not smart enough to figure out which one to use.";
    echo "Please fix before running script again.";
    echo "Thank you.";
    cd "${CURRENT_PWD}";
    exit 1;
fi

# Check if the "automatic ripping" config exists
# If it does, we assume that the current config is the "manual ripping" config.
# Then we do a little switcharoo.
if [[ -f "${CONFIG_AUTO}" ]]; then
    echo "Current config (old): Manual ripping";
    echo "Moving current config to ${CONFIG_MANUAL}";
    mv $CONFIG_CURRENT $CONFIG_MANUAL;
    mv $CONFIG_AUTO $CONFIG_CURRENT;
    echo "Current config (new): Automatic ripping";
elif [[ -f "${CONFIG_MANUAL}" ]]; then
    # Here we assume the opposite, that since the manual config file
    # exists, the current config is the automatic one.
    # But again it's just a switcharoo.
    echo "Current config (old): Automatic ripping";
    echo "Moving current config to ${CONFIG_AUTO}";
    mv $CONFIG_CURRENT $CONFIG_AUTO;
    mv $CONFIG_MANUAL $CONFIG_CURRENT;
    echo "Current config (new): Manual ripping";
else
    # Neither config file could be found, so we basically don't know wtf to do.
    echo "Could not find config for automatic ripping or manual ripping";
fi

# Navigate back to old directory.
cd "${CURRENT_PWD}";