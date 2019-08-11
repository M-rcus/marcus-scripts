<?php
    /**
     * Converts time in `HH:MM:SS` or `MM:SS` format to seconds.
     * Thanks to: https://stackoverflow.com/a/33030875
     */
    function timeToSeconds($time)
    {
        $timeExploded = explode(':', $time);
        if (isset($timeExploded[2])) {
            return $timeExploded[0] * 3600 + $timeExploded[1] * 60 + $timeExploded[2];
        }
        return $timeExploded[0] * 3600 + $timeExploded[1] * 60;
    }

    /**
     * Normalizes all newlines. Converts CRLF to just LF.
     *
     * @param string $string
     *
     * @return string
     */
    function normalizeNewlines($string)
    {
        return preg_replace("/\r\n|\r|\n/", "\n", $string);
    }

    function generateCommand($filename, $times, $output)
    {
        /**
         * This is honestly really ghetto lol.
         */
        $volumeParams = [];
        foreach ($times as $time)
        {
            $volumeParams[] = sprintf("volume=enable='between(t,%d,%d)':volume=0", $time['start'], $time['end']);
        }

        $command = sprintf('ffmpeg -i %s -af "%s" -c:v copy -c:a aac %s', escapeshellarg($filename), implode(', ', $volumeParams), escapeshellarg($output));
        return $command;
    }

    function convertValues($filename, $timestamps, $output)
    {
        if (!is_string($filename) || !is_string($timestamps) || !is_string($output))
        {
            /**
             * Someone tried to POST an array or some shit. Meh.
             */
            exit;
        }

        /**
         * This is a 'dumb' search for the filetype, but since mp4 is the most common in _my_ usecase, that's what I'll do.
         */
        if (empty($output)) {
            $output = str_replace('.mp4', '.MutedAudio.mp4', $filename);
        }

        $timestampPairs = explode("\n", normalizeNewlines($timestamps));
        $convertedTimestamps = [];

        foreach ($timestampPairs as $pair)
        {
            $pair = explode('-', $pair);
            
            /**
             * Silently ignore invalid lines because lazy.
             */
            if (count($pair) < 2)
            {
                continue;
            }

            $start = timeToSeconds(trim($pair[0]));
            $end = timeToSeconds(trim($pair[1]));

            $convertedTimestamps[] = ['start' => $start, 'end' => $end];
        }

        return generateCommand($filename, $convertedTimestamps, $output);
    }

    $command = null;
    if (isset($_POST['filename'], $_POST['timestamps'], $_POST['output']))
    {
        $filename = $_POST['filename'];
        $timestamps = $_POST['timestamps'];
        $output = $_POST['output'];

        $command = convertValues($filename, $timestamps, $output);
    }
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>ffmpeg command for muting audio</title>
    <link rel="stylesheet" type="text/css" href="/css/bootstrap.min.css">
    <link rel="stylesheet" type="text/css" href="/css/bootstrap.extend.css">
</head>
<body>
    <div class="container-fluid">
        <div class="card border-success top-margin">
            <h2 class="card-header bg-success text-white">ffmpeg command for muting audio:</h2>
            <div class="card-body">
                A bit of a 'niche' page I guess. I needed something to generate an ffmpeg command that did the following:
                <br>
                <div class="list-group">
                    <span class="list-group-item">Took a list of timestamps (<code>HH:MM:SS</code>) and converted each timestamp into seconds</span>
                    <span class="list-group-item">Placed the converted seconds into the proper fields for this audiofilter parameter: <code>"volume=enable='between(t,5,10)':volume=0" - This would mute from 00:00:05 to 00:00:10.</code></span>
                    <span class="list-group-item">Generated a full ffmpeg command with filename and the correct video/audio codec.</span>
                    <span class="list-group-item">Video codec should be copied, audio codec can't be copied since we're applying audiofilters. For this I use <code>aac</code>.</span>
                </div>
            </div>
        </div>

        <br>

        <?php
            if (!empty($command)) {
                ?>
                <div class="alert alert-success">
                    Your converted command: <br>
                    <code><?php echo htmlspecialchars($command); ?></code>
                </div>
                <?php
            }
        ?>

        <br>

        <div class="card border-primary">
            <h2 class="card-header bg-primary text-white">Input your details:</h2>
            <div class="card-body">
                <form action="" method="post">
                    <div class="form-group">
                        <label for="filename">Filename:</label>
                        <input type="text" name="filename" id="filename" required="1" class="form-control" placeholder="lirik_twitchvod_20190101.mp4" aria-describedby="inputFilenameHelp">
                        <small id="inputFilenameHelp" class="text-muted">The input filename</small>
                    </div>

                    <div class="form-group">
                        <div class="form-group">
                            <label for="timestamps">List of timestamps:</label>
                            <textarea class="form-control" required="1" name="timestamps" id="timestamps" rows="7"><?php
                                /**
                                 * Ghetto way of preventing weird indentation in the placeholder timestamps.
                                 * Thanks `<textarea>`
                                 */
                                echo "01:12:34-01:12:56\n02:34:56-02:35:22";
                            ?></textarea>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="output">Output filename (optional):</label>
                        <input type="text" name="output" id="output" class="form-control" placeholder="lirik_twitchvod_20190101.MutedAudio.mp4" aria-describedby="outputFilenameHelp">
                        <small id="outputFilenameHelp" class="text-muted">The filename of the output file. By default it's just changed to include <code>MutedAudio</code> before .mp4. If you're not using mp4, then this is practically required.</small>
                    </div>

                    <button type="submit" class="btn btn-primary">Submit</button>
                </form>
            </div>
        </div>
    </div>
</body>
</html>