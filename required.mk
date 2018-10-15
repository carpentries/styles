# PHONY targets
.PHONY : clean clean-rmd commands docker-serve \
  lesson-check lesson-check-all lesson-files \
  lesson-fixme lesson-md repo-check serve site \
  unittest workshop-check install-tools bundler gem

# Default target
.DEFAULT_GOAL := commands

PARSER ?= bin/markdown_ast.rb
DST = _site

HOST ?= 127.0.0.1
PORT ?= 4000

# Gems and programs for building site locally
GEM_CMD ?= $(shell which gem)
JEKYLL ?= $(shell which jekyll)
BUNDLE ?= $(shell which bundle)
DOCKER ?= $(shell which docker)
PYTHON ?= $(shell which python3)
RSCRIPT ?= $(shell which Rscript)

# Jekyll version on GitHub
# Sync with https://pages.github.com/versions/
GITHUB_JEKYLL_VERSION = 3.7.4

ifneq (, $(JEKYLL))
JEKYLL_SERVE_CMD := jekyll serve -H $(HOST) -P $(PORT)
JEKYLL_BUILD_CMD := jekyll build
JEKYLL_CLEAN_CMD := jekyll clean
ifneq (, $(BUNDLE))
JEKYLL_SERVE_CMD := bundle exec $(JEKYLL_SERVE_CMD)
JEKYLL_BUILD_CMD := bundle exec $(JEKYLL_BUILD_CMD)
JEKYLL_CLEAN_CMD := bundle exec $(JEKYLL_CLEAN_CMD)
endif
else
JEKYLL_CLEAN_CMD = rm -rf $(DST) .jekyll-metadata .sass-cache
endif

# RMarkdown files
RMD_SRC := $(wildcard _episodes_rmd/??-*.Rmd)
RMD_DST := $(patsubst _episodes_rmd/%.Rmd,_episodes/%.md,$(RMD_SRC))
ifeq (, $(RMD_SRC))
  RMD_SRC := None
  RMD_DST := None
endif


# Lesson source files in the order
# they appear in the navigation menu.
MARKDOWN_SRC = \
  index.md \
  CODE_OF_CONDUCT.md \
  setup.md \
  $(sort $(wildcard _episodes/*.md)) \
  reference.md \
  $(sort $(wildcard _extras/*.md)) \
  LICENSE.md

# Generated lesson files in the order
# they appear in the navigation menu.
HTML_DST = \
  $(DST)/index.html \
  $(DST)/conduct/index.html \
  $(DST)/setup/index.html \
  $(patsubst _episodes/%.md,$(DST)/%/index.html,$(sort $(wildcard _episodes/*.md))) \
  $(DST)/reference/index.html \
  $(patsubst _extras/%.md,$(DST)/%/index.html,$(sort $(wildcard _extras/*.md))) \
  $(DST)/license/index.html

