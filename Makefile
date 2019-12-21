# Use /bin/bash instead of /bin/sh
export SHELL = /bin/bash

# #################################################
#              ** Customizations **

# Markdown parser (requires 'kramdown' & 'json')
PARSER ?= bin/markdown_ast.rb

# Local directory where
DST ?= _site

# Address and port of a locally rendered website
# Used by `jekyll` or Docker
HOST ?= 127.0.0.1
PORT ?= 4000
# ##################################################

# Variables & commands
-include tools.mk
-include commands.mk

# Default target
.DEFAULT_GOAL := commands

## I. Commands for both workshop and lesson websites
## =================================================
.PHONY: serve site docker-serve repo-check clean clean-rmd

## * serve            : render website and run a local server
serve : lesson-md
	@$(JEKYLL_SERVE_CMD)

## * site             : build website but do not run a server
site : lesson-md
	@$(JEKYLL_BUILD_CMD)

## * docker-serve     : use Docker to serve the site
docker-serve :
	@$(DOCKER_SERVE_CMD)

## * repo-check       : check repository settings
repo-check :
	@$(REPO_CHECK_CMD)

## * clean            : clean up junk files
clean :
	@$(JEKYLL_CLEAN_CMD)
	@rm -rf bin/__pycache__
	@find . -name .DS_Store -exec rm {} \;
	@find . -name '*~' -exec rm {} \;
	@find . -name '*.pyc' -exec rm {} \;

## * clean-rmd        : clean intermediate R files (that need to be committed to the repo)
clean-rmd :
	@rm -rf ${RMD_DST}
	@rm -rf fig/rmd-*


##
## II. Commands specific to workshop websites
## =================================================
.PHONY: workshop-check

## * workshop-check   : check workshop homepage
workshop-check :
	@$(WORKSHOP_CHECK_CMD)


##
## III. Commands specific to lesson websites
## =================================================
.PHONY: lesson-md lesson-check lesson-check-all \
	    unittest lesson-files lesson-fixme

## * lesson-md        : convert Rmarkdown files to markdown
lesson-md : ${RMD_DST}

_episodes/%.md: _episodes_rmd/%.Rmd
	@bin/knit_lessons.sh $< $@

# * lesson-check     : validate lesson Markdown
lesson-check : lesson-fixme
	@$(LESSON_CHECK_CMD)

## * lesson-check-all : validate lesson Markdown, checking line lengths and trailing whitespace
lesson-check-all :
	@$(LESSON_CHECK_ALL_CMD)

## * unittest         : run unit tests on checking tools
unittest :
	@$(UNITTEST_CMD)

## * lesson-files     : show expected names of generated files for debugging
lesson-files :
	@echo 'RMD_SRC:' ${RMD_SRC}
	@echo 'RMD_DST:' ${RMD_DST}
	@echo 'MARKDOWN_SRC:' ${MARKDOWN_SRC}
	@echo 'HTML_DST:' ${HTML_DST}

## * lesson-fixme     : show FIXME markers embedded in source files
lesson-fixme :
	@fgrep -i -n FIXME ${MARKDOWN_SRC} || true

##
## IV. Auxililary (plumbing) commands
## =================================================
.PHONY: commands bundle lock

## * commands         : show all commands.
commands :
	@sed -n -e '/^##/s|^##[[:space:]]*||p' $(MAKEFILE_LIST)

## * bundle           : create or update .vendor/bundle.
bundle : .vendor/bundle

.vendor/bundle : Gemfile
	@$(BUNDLE_INSTALL_CMD)

## * lock             : create or update Gemfile.lock from the current Gemfile
lock : Gemfile.lock

Gemfile.lock : Gemfile
	@$(BUNDLE_LOCK_CMD)

Gemfile :
ifeq (, $(wildcard ./Gemfile))
	$(error Gemfile not found)
endif

