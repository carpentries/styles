# Use /bin/bash instead of /bin/sh
export SHELL = /bin/bash

# Required variables and targets
include required.mk

## I. Commands for both workshop and lesson websites.
## =================================================

## * serve            : Render website and run a local server
serve : lesson-md
ifneq (, $(JEKYLL_SERVE_CMD))
	@$(JEKYLL_SERVE_CMD)
else
$(error Jekyll not found!)
endif

## * site             : build files but do not run a server.
site : lesson-md
ifneq (, $(JEKYLL_BUILD_CMD))
	@$(JEKYLL_BUILD_CMD)
else
$(error Jekyll not found!)
endif

## * docker-serve     : use docker to serve the site.
docker-serve :
ifneq (, $(DOCKER))
	$(DOCKER) run --rm -it --volume ${PWD}:/srv/jekyll \
           --volume=${PWD}/.docker-vendor/bundle:/usr/local/bundle \
           -p 127.0.0.1:4000:$(PORT) \
           jekyll/jekyll:${JEKYLL_VERSION} \
           bin/run-make-docker-serve.sh
else
$(error Docker not found!)
endif

## * repo-check       : check repository settings.
repo-check :
ifneq (, $(PYTHON))
	@${PYTHON} bin/repo_check.py -s .
else
$(error Python3 not found!)
endif

## * clean            : clean up junk files.
clean :
	@$(JEKYLL_CLEAN_CMD)
	@rm -rf bin/__pycache__
	@find . \( -name .DS_Store -o -name '*~' -o -name '*.pyc' \) -delete

## * clean-rmd        : clean intermediate R files (that need to be committed to the repo).
clean-rmd :
	@rm -rf ${RMD_DST}
	@rm -rf fig/rmd-*

##
## II. Commands specific to workshop websites.
## =======================================

## * workshop-check   : check workshop homepage.
workshop-check :
ifneq (, $(PYTHON))
	@${PYTHON} bin/workshop_check.py .
else
$(error Python3 not found!)
endif

##
## III. Commands specific to lesson websites.
## =====================================

## * lesson-md        : convert Rmarkdown files to markdown
ifneq (None, $(RMD_SRC))
lesson-md : ${RMD_DST}
else
lesson-md :
	@:
endif

_episodes/%.md: _episodes_rmd/%.Rmd
ifneq (, $(RSCRIPT))
	@bin/knit_lessons.sh $< $@
endif

## * lesson-check     : validate lesson Markdown.
lesson-check : lesson-fixme
ifneq (, $(PYTHON))
	@${PYTHON} bin/lesson_check.py -s . -p ${PARSER} -r _includes/links.md
else
$(error Python not found!)
endif

## * lesson-check-all : validate lesson Markdown, checking line lengths and trailing whitespace.
lesson-check-all :
ifneq (, $(PYTHON))
	@${PYTHON} bin/lesson_check.py -s . -p ${PARSER} -r _includes/links.md -l -w --permissive
else
$(error Python3 not found!)
endif

## * unittest         : run unit tests on checking tools.
unittest :
ifneq (, $(PYTHON))
	@${PYTHON} bin/test_lesson_check.py
else
$(error Python3 not found!)
endif

## * lesson-files     : show expected names of generated files for debugging.
lesson-files :
	@echo RMD_SRC: ${RMD_SRC}
	@echo RMD_DST: ${RMD_DST}
	@echo MARKDOWN_SRC: ${MARKDOWN_SRC}
	@echo HTML_DST: ${HTML_DST}

## * lesson-fixme     : show FIXME markers embedded in source files.
lesson-fixme :
	@fgrep -i -n FIXME ${MARKDOWN_SRC} 2>/dev/null || true


##
## IV. Auxililary (plumbing) commands
## ================================

## * commands         : show all commands.
commands :
	@sed -n -e '/^##/s|^##[[:space:]]*||p' $(MAKEFILE_LIST)

## * install-tools    : install gems required to render site locally.
install-tools : bundler Gemfile.lock
ifeq (, $(JEKYLL))
	@bundle install
else
	$(info Jekyll appears to be installed)
	@:
endif

## * Gemfile.lock     : update Gemfile.lock
Gemfile.lock : Gemfile bundler
	@bundle lock --update

## * bundler          : install Bundler
bundler : gem
ifeq (, $(BUNDLE))
	@gem install bundler
else
	$(info Bundler appears to be installed!)
	@:
endif

gem :
ifeq (, $(GEM_CMD))
	$(error 'gem' command not found! Please install Ruby)
else
	$(info Gem appears to be installed!)
	@:
endif
