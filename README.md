# marcus-scripts

My personal scripts for random tools.

Some of these scripts are used via CLI, others are used via a webpage (currently only one: `ffmpeg-volume-mute.php`).

## CLI scripts

### Bash / SH

Most Bash scripts are meant to be helper scripts for using other binaries, such as [megatools][megatools].

### JavaScript / node.js

For `.js` scripts you'll need [node.js/npm](https://nodejs.org/)  
Run `npm install` in the project directory to install the required dependencies

### PHP

As of right now PHP scripts don't have dependencies (besides `php` itself).  
If they ever do, make sure to install [Composer](https://getcomposer.org/) and run `composer install` in the project directory.  
If you're unsure: If there's a `composer.json` file in the project directory, get Composer and run the command. Unless `composer.json` exists at all in this project, Composer won't be necessary.

## What da script do

### ffmpeg-volume-mute.php

Generates an `ffmpeg` command where you can manually mute parts of a video.  
This is meant to be a webpage, not a CLI script.

### lolisafe-create-albums.js

Node script that creates albums based on a list (JavaScript array).  
Each album name is listed and when every album is created. By default, a Markdown-formatted list is also printed to the console. See `printFormat` in [config/lolisafe.sample.js](./config/lolisafe.sample.js).

### megatools-mkdir.sh

Bash script for [megatools][megatools].

Creates a directory in your Mega account, based on the input directory.
There's an optional prompt after creating directory to copy (upload) the local input directory to the corresponding directory on your Mega account.

### megatools-reg.sh

Bash script for [megatools][megatools].

Makes it easier to register and verify a Mega account. I use this for creating burner accounts on Mega, using [Sharklasers temporary emails][sharklasers].

### onlyfans-switch-config.sh

Bash helper script to be used with [DIGITALCRIMINAL/OnlyFans][OnlyFans].

Makes it easier to toggle between "manual" and "automatic" configs.  
"Manual" is meant to have config options that make you pick everything: What account to log in as, what creators to rip etc.  
"Automatic" is supposed to be fully automatic. I essentially set my automatic configuration to log into every OF account, rip all the creators and set the `loop_timeout` to 15 minutes (so it does the process again, 15 minutes after finishing the last one).

A longer description of the script is documented via comments at the top of the script itself.

### replace-bbcodes.js

Node script for reading BB Code formatted forum posts from clipboard and then converting it into Discord-Markdown and inserting the new Discord-Markdown formatted post into clipboard instead.

### ss-minio.sh

Bash script for uploading screenshots to my Minio server.  
The script itself has comments that describe requirements and such.

### upload-minio.sh

Bash script similar to `ss-minio.sh`.  
Not sure what the difference actually is, all I know is that `ss-minio` is tied to my screenshot handling and `upload-minio` is for uploading other files via Thunar (my file manager) or the CLI.

### vcs-folder.sh

Stupid simple Bash script for creating thumbnails of all video files (mp4, mov & mkv) in a folder using [vcs][vcs].

[megatools]: https://megatools.megous.com/
[OnlyFans]: https://github.com/DIGITALCRIMINAL/OnlyFans
[sharklasers]: https://sharklasers.com/
[vcs]: https://p.outlyer.net/vcs