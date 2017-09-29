#!/bin/bash

if command -v fswatch >/dev/null 2>&1 ; then
	watchcmd="fswatch --event Updated "
elif command -v inotifywait >/dev/null 2>&1; then
	watchcmd="inotifywait --format=%w -q -m -e close_write "
else
	echo "Cannot find fswatch or inotifywait"
	exit 1
fi
echo $watchcmd
$watchcmd _episodes_rmd/*.Rmd |xargs -n 1 Rscript -e "source('bin/generate_md_episodes.R')"  

