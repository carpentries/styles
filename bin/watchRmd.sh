#!/bin/bash
while inotifywait -e close_write  _episodes_rmd/*.Rmd; do make lesson-md; done

