#!/bin/bash
fswatch --event=Updated _episodes_rmd/*.Rmd | make lesson-md

