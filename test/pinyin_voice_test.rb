# frozen_string_literal: true

require "minitest/autorun"
require_relative "../bin/pinyin_voice"

class PinyinVoiceTest < Minitest::Test
  PLAN = {
    "engine" => { "vendor" => "elevenlabs", "model_id" => "eleven_multilingual_v2",
                  "output_format" => "mp3_44100_128", "language" => "zh",
                  "voice_id" => nil },
    "syllables" => {
      "ren" => { "pinyin" => "rén", "text" => "人" },
      "ma-neutral" => { "pinyin" => "ma", "text" => "嗎", "verify" => "loudness" }
    },
    "lines" => {
      "102-15-dao-fa-zi-ran" => { "text" => "道法自然。", "pinyin" => "dào fǎ zì rán" }
    }
  }.freeze

  def test_env_overrides_plan_engine_and_key_stays_out
    eng = Edubba::PinyinVoice.resolve_engine(
      PLAN["engine"],
      { "ELEVENLABS_VOICE_ID" => "v123", "ELEVENLABS_MODEL_ID" => "eleven_v3",
        "ELEVENLABS_OUTPUT_FORMAT" => "mp3_22050_32", "ELEVENLABS_API_KEY" => "secret" }
    )
    assert_equal "v123", eng["voice_id"]
    assert_equal "eleven_v3", eng["model_id"]
    assert_equal "mp3_22050_32", eng["output_format"]
    refute eng.values.include?("secret"), "the API key never enters the engine config"
  end

  def test_empty_env_falls_back_to_plan_and_defaults
    eng = Edubba::PinyinVoice.resolve_engine({ "voice_id" => "pinned" }, {})
    assert_equal "pinned", eng["voice_id"]
    assert_equal "eleven_multilingual_v2", eng["model_id"]
    assert_equal "mp3_44100_128", eng["output_format"]
  end

  def test_pending_items_skip_ledgered_clips_unless_all
    ledger = { "built" => { "ren" => { "date" => "2026-08-15" } } }
    ids = Edubba::PinyinVoice.pending_items(PLAN, ledger).map { |i| i["id"] }
    assert_equal %w[ma-neutral 102-15-dao-fa-zi-ran], ids
    all = Edubba::PinyinVoice.pending_items(PLAN, ledger, all: true).map { |i| i["id"] }
    assert_equal %w[ren ma-neutral 102-15-dao-fa-zi-ran], all
  end

  def test_items_carry_kind_verify_and_out_paths
    items = Edubba::PinyinVoice.pending_items(PLAN, { "built" => {} })
    ren = items.find { |i| i["id"] == "ren" }
    assert_equal "tone", ren["verify"]
    assert_equal "site/assets/audio/pinyin/ren.mp3", ren["out"]
    neutral = items.find { |i| i["id"] == "ma-neutral" }
    assert_equal "loudness", neutral["verify"], "neutral tone has no contour to pitch-check"
    line = items.find { |i| i["id"] == "102-15-dao-fa-zi-ran" }
    assert_equal "line", line["kind"]
    assert_equal "site/assets/audio/lines/102-15-dao-fa-zi-ran.mp3", line["out"]
  end

  def test_middle_token_picks_center_run_when_tokens_separate
    # three voiced runs (frames of high RMS) split by quiet valleys
    env = [0, 9, 9, 9, 0, 0, 8, 8, 8, 0, 0, 9, 9, 9, 0].map(&:to_f)
    from, to = Edubba::PinyinVoice.middle_token(env)
    assert_in_delta 6 * 0.025, from, 1e-9
    assert_in_delta 9 * 0.025, to, 1e-9
  end

  def test_middle_token_splits_a_connected_triple_at_its_valleys
    # one voiced run with two internal dips — connected 大大大
    env = [9, 9, 9, 9, 3, 9, 9, 9, 9, 3, 9, 9, 9, 9].map(&:to_f)
    from, to = Edubba::PinyinVoice.middle_token(env)
    assert_in_delta 5 * 0.025, from, 1e-9
    assert_in_delta 9 * 0.025, to, 1e-9
  end

  def test_middle_token_refuses_silence_and_too_short_runs
    assert_nil Edubba::PinyinVoice.middle_token([0.0, 0.0, 0.0])
    assert_nil Edubba::PinyinVoice.middle_token([9.0] * 5), "5 frames can't hold three tokens"
  end

  def test_variant_fan_out_expands_strategies_times_rolls
    plan = PLAN.merge("syllables" => {
                        "shi" => { "pinyin" => "shí", "text" => "時",
                                   "variants" => [
                                     { "text" => "詩、時、史、是。", "cut" => "second" },
                                     { "text" => "時" }
                                   ] }
                      }, "lines" => {})
    items = Edubba::PinyinVoice.pending_items(plan, { "built" => {} }, rolls: 2)
    assert_equal %w[shi~v0a shi~v0b shi~v1a shi~v1b], items.map { |i| i["id"] }
    assert items.all? { |i| i["base"] == "shi" }
    assert items.all? { |i| i["out"] == "site/assets/audio/pinyin/shi.mp3" }
    assert_equal "second", items[0]["cut"]
    assert_nil items[2]["cut"]
    # no variants + one roll → the plain unsuffixed item
    plain = Edubba::PinyinVoice.pending_items(PLAN, { "built" => {} })
    assert_equal "ren", plain.first["id"]
    assert_equal "ren", plain.first["base"]
  end

  def test_plan_cut_flag_travels_into_the_batch
    plan = PLAN.merge("syllables" => {
                        "da" => { "pinyin" => "dà", "text" => "大、大、大。", "cut" => "middle" }
                      })
    item = Edubba::PinyinVoice.pending_items(plan, { "built" => {} }).first
    assert_equal "middle", item["cut"]
  end

  def test_cut_ok_accepts_a_span_override
    # 0.30 s of steady tone at 16 kHz — inside the legacy 0.15–0.85
    # window, below the pedagogical 0.4 floor.
    pcm = ([12_000] * (16_000 * 3 / 10)).pack("s<*")
    ok, = Edubba::PinyinAudio.cut_ok?(pcm)
    assert ok, "legacy span accepts 0.30 s"
    ok, why = Edubba::PinyinAudio.cut_ok?(pcm, span: (0.4..1.5))
    refute ok, "the length law refuses it"
    assert_match(/voiced span 0\.\d+ s outside 0\.40–1\.50 s/, why)
  end

  def test_syllable_items_inherit_the_deliberate_pace
    plan = PLAN.merge("engine" => PLAN["engine"].merge("syllable_voice_settings" => { "speed" => 0.7 }))
    items = Edubba::PinyinVoice.pending_items(plan, { "built" => {} })
    ren = items.find { |i| i["base"] == "ren" }
    assert_equal({ "speed" => 0.7 }, ren["voice_settings"])
    neutral = items.find { |i| i["base"] == "ma-neutral" }
    assert_nil neutral["voice_settings"], "loudness-verified demos keep natural pace"
    line = items.find { |i| i["kind"] == "line" }
    assert_nil line["voice_settings"], "lines keep natural prosody"
  end

  def test_clean_track_kills_octave_spikes_and_keeps_the_contour
    dirty = [119, 327, 85, 320, 320, 356, 107, 103, 94, 86, 89, 90, 94, 86, 85, 348, 102]
    cleaned = Edubba::PinyinVoice.clean_track(dirty)
    assert cleaned.all? { |f| f < 200 }, "octave-doubled spikes removed: #{cleaned}"
    smooth = [225, 213, 232, 184, 174, 157, 122, 119, 118]
    assert_equal smooth.length, Edubba::PinyinVoice.clean_track(smooth).length,
                 "a clean falling contour passes through whole"
    assert_equal [150, 150], Edubba::PinyinVoice.clean_track([150, 150])
  end

  def test_syllable_count_reads_the_pinyin_line
    assert_equal 4, Edubba::PinyinVoice.syllable_count("dào fǎ zì rán")
    assert_equal 9, Edubba::PinyinVoice.syllable_count("xué ér shí xí zhī, bù yì yuè hū")
    assert_equal 10, Edubba::PinyinVoice.syllable_count("jūn shǐ chén yǐ lǐ, chén shì jūn yǐ zhōng")
  end

  def test_live_plan_covers_every_published_syllable_mp3
    plan = YAML.safe_load_file(File.expand_path("../assets-src/data/voice-plan.yml", __dir__))
    disk = Dir[File.expand_path("../site/assets/audio/pinyin/*.mp3", __dir__)]
           .map { |f| File.basename(f, ".mp3") }
    missing = disk - plan["syllables"].keys
    assert_empty missing, "published syllable mp3s with no voice-plan entry"
    plan["syllables"].each do |id, s|
      assert s["text"].to_s != "", "#{id}: no carrier text"
      assert s["pinyin"].to_s != "", "#{id}: no pinyin"
    end
    assert plan["engine"]["voice_id"].to_s != "", "the standard voice must stay pinned"
    # The say-audio lint reads tone declarations from the old
    # manifest; the voice plan must never drift from it.
    manifest = YAML.safe_load_file(
      File.expand_path("../assets-src/data/pinyin-audio-sources.yml", __dir__)
    )["sources"]
    manifest.each do |slug, src|
      assert_equal src["pinyin"], plan["syllables"][slug]["pinyin"],
                   "#{slug}: voice-plan pinyin drifted from the manifest's declaration"
    end
  end
end
