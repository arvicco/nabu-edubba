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
  end
end
