# frozen_string_literal: true

source "https://rubygems.org"

# CI pins Ruby 3.3; local dev runs newer interpreters. Both must satisfy.
ruby ">= 3.3"

# Approved dependency budget (see CLAUDE.md rule 2). Ask before adding.
gem "jekyll", "~> 4.4"

group :development, :test do
  gem "html-proofer", "~> 5.0"
  gem "minitest"
  gem "rake"
end
