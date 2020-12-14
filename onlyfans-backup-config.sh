#!/bin/bash

# Where the DIGITALCRIMINAL/OnlyFans directory exists on your PC.
OF_PROJECT_DIR="$HOME/projects/OnlyFans";

# Where the settings directory is
# Not necessary to change unless the project changes this in the future.
OF_SETTINGS="$OF_PROJECT_DIR/.settings";

# Some of these files are extra files that normally aren't used with the project
# See `onlyfans-switch-config.sh`
FILES=( "config.json" "config.auto.json" "extra_auth.json" "old_auth.json" "test.json" );
# Date format: YEAR-MONTH-DAY_HOUR-MINUTE-SECOND
CURRENT_DT="$(date +"%Y-%m-%d_%H-%M-%S")";

# Current working directory
# Mainly used to navigate back to it after script finishes
CURRENT_PWD="$(pwd)";

# Navigate to settings directory in OF project.
cd "${OF_SETTINGS}";

for file in "${FILES[@]}"; do
    if [ ! -f "${file}" ]; then
        echo "File does not exist: ${file} -- Skipping";
        continue;
    fi

    # Take old name, remove `.json`, add datetime, add `.json` back at the end.
    backup_file="${file%%.json}.${CURRENT_DT}.json";

    cp "${file}" "${backup_file}";
    echo "Copied: ${file} => ${backup_file}";
done

cd "${CURRENT_PWD}";