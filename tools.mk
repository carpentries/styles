# Detect required programs: Gem, Docker, Rscript, Jekyll
GEM ?= $(shell which gem 2>/dev/null)
DOCKER ?= $(shell which docker 2>/dev/null)
RSCRIPT ?= $(shell which Rscript 2>/dev/null)
JEKYLL ?= $(shell which jekyll 2>/dev/null)
BUNDLE ?= $(shell which bundle 2>/dev/null)
CURL ?= $(shell which curl 2>/dev/null)
SED ?= $(shell which sed 2>/dev/null)


# Determine Jekyll version that we need
ifeq (,$(JEKYLL_VERSION))
  ifneq (, $(SED))
    # Obtain required version from https://pages.github.com/versions
    ifneq (, $(CURL))
        JEKYLL_VERSION_GITHUB := $(shell curl -s https://pages.github.com/versions.json | sed -n "s|.*\"jekyll\":\"\([^\"]*\)\".*|\1|p")
    endif

    # Get Jekyll version from the Gemfile.lock
    ifneq (, $(wildcard ./Gemfile.lock))
      JEKYLL_VERSION_LOCK := $(shell sed -n "/jekyll\ (=.*)/s|.*(= \(.*\))|\1|p" Gemfile.lock)

      # Compare two verions of Jekyll, if both are available
      ifneq (, $(JEKYLL_VERSION_GITHUB))
        ifneq ($(JEKYLL_VERSION_LOCK),$(JEKYLL_VERSION_GITHUB))
          ifneq ($(MAKECMDGOALS),lock)
            $(warning )
            $(warning GitHub requires Jekyll $(JEKYLL_VERSION_GITHUB))
            $(warning Gemfile.lock specifies Jekyll $(JEKYLL_VERSION_LOCK))
            $(warning Please update Gemfile.lock by running 'make -B lock')
            $(warning )
          endif
        endif
      endif
    endif
  else
    $(warning Your system does not have Sed installed.)
  endif
endif


# Python
# Check Python 3 is installed and determine if it's called via python3 or python
PYTHON3_EXE := $(shell which python3 2>/dev/null)
ifneq (, $(PYTHON3_EXE))
  ifeq (,$(findstring Microsoft/WindowsApps/python3,$(subst \,/,$(PYTHON3_EXE))))
    PYTHON := python3
  endif
endif

ifeq (,$(PYTHON))
  PYTHON_EXE := $(shell which python 2>/dev/null)
  ifneq (, $(PYTHON_EXE))
    PYTHON_VERSION_FULL := $(wordlist 2,4,$(subst ., ,$(shell python --version 2>&1)))
    PYTHON_VERSION_MAJOR := $(word 1,${PYTHON_VERSION_FULL})
    ifneq (3, ${PYTHON_VERSION_MAJOR})
      $(warning Your system does not appear to have Python 3 installed)
    else
      PYTHON := python
    endif
  else
      $(warning Your system does not appear to have any Python installed)
  endif
endif

# RMarkdown files
RMD_SRC = $(wildcard _episodes_rmd/??-*.Rmd)
RMD_DST = $(patsubst _episodes_rmd/%.Rmd,_episodes/%.md,$(RMD_SRC))

# Lesson source files in the order they appear in the navigation menu.
MARKDOWN_SRC = \
  index.md \
  CODE_OF_CONDUCT.md \
  setup.md \
  $(sort $(wildcard _episodes/*.md)) \
  reference.md \
  $(sort $(wildcard _extras/*.md)) \
  LICENSE.md

# Generated lesson files in the order they appear in the navigation menu.
HTML_DST = \
  ${DST}/index.html \
  ${DST}/conduct/index.html \
  ${DST}/setup/index.html \
  $(patsubst _episodes/%.md,${DST}/%/index.html,$(sort $(wildcard _episodes/*.md))) \
  ${DST}/reference/index.html \
  $(patsubst _extras/%.md,${DST}/%/index.html,$(sort $(wildcard _extras/*.md))) \
  ${DST}/license/index.html
