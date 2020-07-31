#!/bin/bash

# Usage:
# 1. Navigate to folder
# 2. Assuming `vcs-folder` is in your $PATH somewhere, run `vcs-folder` or the direct path to script `~/Downloads/vcs-folder.sh`
# 
# This also assumes you've created a VCS configuration file that contains all the options you want:
# https://p.outlyer.net/vcs/docs/conf_files

for vid in *.{mp4,mkv,mov};
do
    vcs "$vid";
done