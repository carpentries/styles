#  JEKYLL_BUILD_CMD
#  JEKYLL_CLEAN_CMD
#  JEKYLL_SERVE_CMD
ifneq (, $(JEKYLL))
  JEKYLL_CMD := jekyll
  # We can use 'bundle exec' only if we have a Gemfile
  ifneq (, $(wildcard ./Gemfile))
    ifneq (, $(BUNDLE))
      JEKYLL_CMD := bundle exec $(JEKYLL_CMD)
    endif
  endif
  JEKYLL_BUILD_CMD := $(JEKYLL_CMD) build
  JEKYLL_CLEAN_CMD := $(JEKYLL_CMD) clean
  JEKYLL_SERVE_CMD := $(JEKYLL_CMD) serve -H $(HOST) -P $(PORT)
else
  JEKYLL_BUILD_CMD = $(error Can't build a website: Jekyll not found)
  JEKYLL_CLEAN_CMD = rm -rf $(DST) .jekyll-metadata .sass-cache
  JEKYLL_SERVE_CMD = $(error Can't serve a website: Jekyll not found)
endif


#  DOCKER_SERVE_CMD
ifneq (, $(DOCKER))
  DOCKER_SERVE_CMD = \
  $(DOCKER) run --rm -it \
  --volume ${PWD}:/srv/jekyll \
  --volume ${PWD}/.docker-vendor/bundle:/usr/local/bundle \
  --publish $(HOST):$(PORT):4000 \
  jekyll/jekyll:${JEKYLL_VERSION} \
  bin/run-make-docker-serve.sh
else
  DOCKER_SERVE_CMD = $(error Can't serve the site using Docker: Docker not found)
endif


#  REPO_CHECK_CMD
#  WORKSHOP_CHECK_CMD
#  LESSON_CHECK_CMD
#  LESSON_CHECK_ALL_CMD
#  UNITTEST_CMD
ifneq (, $(PYTHON))
  REPO_CHECK_CMD = ${PYTHON} bin/repo_check.py -s .
  WORKSHOP_CHECK_CMD = ${PYTHON} bin/workshop_check.py .
  LESSON_CHECK_CMD = ${PYTHON} bin/lesson_check.py -s . -p ${PARSER} -r _includes/links.md
  LESSON_CHECL_ALL_CMD = ${PYTHON} bin/lesson_check.py -s . -p ${PARSER} -r _includes/links.md -l -w --permissive
  UNITTEST_CMD = ${PYTHON} bin/test_lesson_check.py
else
  REPO_CHECK_CMD = $(error Can't check repository settings: Python 3 not found!)
  WORKSHOP_CHECK_CMD = $(error Can't check workshop homepage: Python 3 not found)
  LESSON_CHECK_CMD = $(error Can't validate lesson files: Python 3 not found)
  LESSON_CHECK_ALL_CMD = $(error Can't validate lesson files: Python 3 not found)
  UNITTEST_CMD = $(error Can't perform unit testing: Python 3 not found)
endif


#  BUNDLE_INSTALL_CMD
#  BUNDLE_LOCK_CMD
ifneq (, $(BUNDLE))
  define BUNDLE_INSTALL_CMD
  $(BUNDLE) install --path .vendor/bundle
  $(BUNDLE) update
  endef
  BUNDLE_LOCK_CMD = $(BUNDLE) lock --update
else
  BUNDLE_INSTALL_CMD = $(error Can't create .vendor/bundle: Bundle not found)
  BUNDLE_LOCK_CMD = $(error Can't create/update Gemfile.lock: Bundle not found)
endif


