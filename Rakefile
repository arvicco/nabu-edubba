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

desc "Regenerate the cuneiform font subset from site/ usage (authoring-time; needs hb-subset)"
task :fonts do
  ruby "script/subset_fonts.rb"
end

desc "Local preview at http://127.0.0.1:4000"
task :serve do
  # Own destination: a long-running serve regenerating into the
  # gate's BUILD_DIR races the gate build (and its memoized
  # sign-map goes stale across data edits) — 2026-08-11 incident.
  sh "bundle exec jekyll serve --source site --destination _build/serve"
end

# No second writer (M19-5, 2026-08-11 incident): a live `jekyll
# serve` regenerated into the gate's build dir mid-gate and 110
# phantom link failures shipped into the report. The gate asserts
# sole ownership of the build before it starts.
task :sole_writer do
  pids = `pgrep -f "jekyll"`.split.map(&:to_i) - [Process.pid]
  unless pids.empty?
    abort "gate: another jekyll process is alive (PID #{pids.join(', ')}) — " \
          "a second writer races the gate build (2026-08-11 incident); " \
          "stop it first (kill #{pids.join(' ')})"
  end
end

desc "Pre-commit gate: all green or no commit"
task gate: %i[sole_writer lint test build check] do
  puts "GATE GREEN"
end

task default: :gate
