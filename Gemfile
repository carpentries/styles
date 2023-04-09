# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

# Synchronize with https://pages.github.com/versions
ruby '>=2.7.1'

group :jekyll_plugins do
  if ENV["GITHUB_ACTIONS"]
    # When building GitHub Pages via GitHub Actions
    gem 'github-pages'
  else
    # Or elsewhere and if additional gems are necessary.
    # Note that the 'github-pages' plugin disables any
    # non-whitelisted plugin.
    # See PR #521 for additional context

    # Dependency list from 'github-pages'
    # See: https://github.com/github/pages-gem/blob/75fd58be0f294a6bf55a1990643838d5984a1f62/lib/github-pages/dependencies.rb#L8
    gem 'jekyll', '>= 3.9.0'
    gem 'jekyll-sass-converter', '>= 1.5.2'
    # Converters
    gem 'kramdown', '>= 2.3.1'
    gem 'kramdown-parser-gfm', '>= 1.1.0'
    gem 'jekyll-commonmark-ghpages', '>= 0.1.6'
    # Misc
    gem 'liquid', '>= 4.0.3'
    gem 'rouge', '>= 3.26.0'
    # gem 'github-pages-health-check', '>= 1.17.1'  # Not necessary outside GitHub
    # Plugins
    gem 'jekyll-redirect-from', '>= 0.16.0'
    gem 'jekyll-sitemap', '>= 1.4.0'
    gem 'jekyll-feed', '>= 0.15.1'
    gem 'jekyll-gist', '>= 1.5.0'
    gem 'jekyll-paginate', '>= 1.1.0'
    gem 'jekyll-coffeescript', '>= 1.1.1'
    gem 'jekyll-seo-tag', '>= 2.7.1'
    # gem 'jekyll-github-metadata', '>= 2.13.0'  # Not necessary outside GitHub
    gem 'jekyll-avatar', '>= 0.7.0'
    gem 'jekyll-remote-theme', '>= 0.4.3'
    # Plugins to match GitHub.com Markdown
    gem 'jemoji', '>= 0.12.0'
    gem 'jekyll-mentions', '>= 1.6.0'
    gem 'jekyll-relative-links', '>= 0.6.1'
    gem 'jekyll-optional-front-matter', '>= 0.3.2'
    gem 'jekyll-readme-index', '>= 0.3.0'
    gem 'jekyll-default-layout', '>= 0.1.4'
    gem 'jekyll-titles-from-headings', '>= 0.5.3'
    # Extra dependency that allows accessing ENV variables in other CI environments
    gem 'jekyll-environment-variables', '>= 1.0.1'
  end
end

if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('3.0.0')
    gem 'webrick', '>= 1.6.1'
end
