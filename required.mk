# PHONY targets
.PHONY : clean clean-rmd commands docker-serve \
  lesson-check lesson-check-all lesson-files \
  lesson-fixme lesson-md repo-check serve site \
  unittest workshop-check install-tools bundler gem

# Default target
.DEFAULT_GOAL := commands

# Markdown parser
PARSER ?= bin/markdown_ast.rb

# Destination directory
DST = _site

HOST ?= 127.0.0.1
PORT ?= 4000

# Gems and programs for building site locally
GEM_CMD ?= $(shell which gem)
JEKYLL ?= $(shell which jekyll)
BUNDLE ?= $(shell which bundle)
DOCKER ?= $(shell which docker)
RSCRIPT ?= $(shell which Rscript)

# Check if Python 3 is installed and determine if it's called via python3 or python
# (https://stackoverflow.com/a/4933395)
ifeq (,$(PYTHON))
  PYTHON_EXE := $(shell which python3 2>/dev/null)
  ifneq (,$(PYTHON_EXE))
    ifeq (,$(findstring Microsoft/WindowsApps/python3,$(subst \,/,$(PYTHON_EXE))))
      PYTHON_VERSION := $(word 1,$(wordlist 2,4,$(subst ., ,$(shell $(PYTHON_EXE) --version 2>&1))))
      ifeq (3,$(PYTHON_VERSION))
        PYTHON := python3
      endif
    else
      $(info "Your `python3` is a link to Microsoft Store.")
    endif
  endif

  ifeq (,$(PYTHON))
    PYTHON_EXE := $(shell which python 2>/dev/null)
    ifneq (, $(PYTHON_EXE))
      PYTHON_VERSION := $(word 1,$(wordlist 2,4,$(subst ., ,$(shell $(PYTHON_EXE) --version 2>&1))))
      ifeq (3,$(call python_version,$(PYTHON_EXE)))
        PYTHON := python
      else
        $(error "Your system does not appear to have Python 3 installed.")
      endif
    else
        $(error "Your system does not appear to have any Python installed.")
    endif
  endif
else
  PYTHON_VERSION := $(word 1,$(wordlist 2,4,$(subst ., ,$(shell $(PYTHON) --version 2>&1))))
  ifneq (3,$(PYTHON_VERSION))
    $(error "Python 3 is required. Your Python version: $(PYTHON_VERSION)")
  endif
endif

# Jekyll version on GitHub
ifneq (, $(wildcard ./Gemfile.lock))
  GITHUB_JEKYLL_VERSION := $(shell sed -n '/jekyll\ (=.*)/s|.*(= \(.*\))|\1|p' Gemfile.lock)
else
  # Sync with https://pages.github.com/versions/
  GITHUB_JEKYLL_VERSION = 3.8.5
endif

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

