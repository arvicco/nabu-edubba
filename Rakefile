# frozen_string_literal: true

require "rake/testtask"

BUILD_DIR = "_build/site"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.pattern = "test/*_test.rb"
  t.warning = false
end

desc "Conventions scan over site sources (no-JS, front matter, links)"
task :lint do
  ruby "script/lint.rb"
end

desc "Build the site (site/ -> #{BUILD_DIR})"
task :build do
  sh "bundle exec jekyll build --source site --destination #{BUILD_DIR}"
end

desc "Check the built site: internal links, images, HTML (offline)"
task :check do
  abort "#{BUILD_DIR} missing — run `rake build` first" unless File.directory?(BUILD_DIR)
  sh "bundle exec htmlproofer #{BUILD_DIR} --disable-external --no-enforce-https"
end

desc "Local preview at http://127.0.0.1:4000"
task :serve do
  sh "bundle exec jekyll serve --source site --destination #{BUILD_DIR}"
end

desc "Pre-commit gate: all green or no commit"
task gate: %i[lint test build check] do
  puts "GATE GREEN"
end

task default: :gate
