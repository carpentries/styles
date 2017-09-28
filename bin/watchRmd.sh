#!/bin/bash
while fswatch --event=Updated _episodes_rmd/*.Rmd; do make lesson-md; done

