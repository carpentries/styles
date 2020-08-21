#!/usr/bin/env bash


Rscript -e "source(file.path('bin', 'dependencies.R')); install_dependencies(identify_dependencies())"
