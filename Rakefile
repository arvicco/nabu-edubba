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

# The standard-voice pipeline (rulebook §2, owner ruling
# 2026-08-15). batch/integrate are agent-run; synth/voices are
# OWNER-run (they need ELEVENLABS_API_KEY — the key never enters
# the repo, and the agent never runs network-mutating commands).
namespace :voice do
  desc "Write pending synthesis work to voice-batch.json (voice:batch[all] regenerates everything)"
  task :batch, [:mode] do |_, args|
    ruby "bin/pinyin_voice.rb batch#{args[:mode] == 'all' ? ' --all' : ''}"
  end

  desc "OWNER: synthesize the batch via ElevenLabs (env: ELEVENLABS_API_KEY, _VOICE_ID, _MODEL_ID, _OUTPUT_FORMAT)"
  task :synth do
    ruby "bin/pinyin_voice.rb synth"
  end

  desc "QA staged clips (tone/span/duration + loudness) and encode into the site"
  task :integrate do
    ruby "bin/pinyin_voice.rb integrate"
  end

  desc "OWNER: list the ElevenLabs account's voices (needs ELEVENLABS_API_KEY)"
  task :voices do
    ruby "bin/pinyin_voice.rb voices"
  end
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
  # CI is a fresh container per job — sole ownership by construction
  # (and the runner's own processes false-matched a bare "jekyll"
  # pattern there: red gate on PR #24, 2026-08-11).
  next if ENV["CI"]

  # A serve pinned to its private _build/serve is the SANCTIONED
  # pattern (rake serve) and cannot touch the gate's dir — only a
  # jekyll writing anywhere else is a racing second writer.
  offenders = `pgrep -fl "jekyll (serve|build)"`.lines
              .map { |l| l.split(" ", 2) }
              .reject { |pid, cmd| pid.to_i == Process.pid || cmd.include?("_build/serve") }
              .map(&:first)
  unless offenders.empty?
    abort "gate: another jekyll process is alive (PID #{offenders.join(', ')}) — " \
          "a second writer races the gate build (2026-08-11 incident); " \
          "stop it first (kill #{offenders.join(' ')})"
  end
end

desc "Pre-commit gate: all green or no commit"
task gate: %i[sole_writer lint test build check] do
  puts "GATE GREEN"
end

task default: :gate
