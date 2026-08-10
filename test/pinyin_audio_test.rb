# frozen_string_literal: true

require "minitest/autorun"
require_relative "../bin/pinyin_audio"

class PinyinAudioTest < Minitest::Test
  PA = Edubba::PinyinAudio

  def test_tone_from_diacritic
    assert_equal :level, PA.tone_of("tiān")
    assert_equal :rise, PA.tone_of("rén")
    assert_equal :dip, PA.tone_of("shuǐ")
    assert_equal :fall, PA.tone_of("dà")
    assert_equal :level, PA.tone_of("yuē")
    assert_equal :dip, PA.tone_of("nǚ")
    assert_equal :neutral, PA.tone_of("ma")
  end

  def test_contour_classification
    assert_equal :level, PA.classify([180] * 20)
    assert_equal :rise, PA.classify((100..160).step(3).to_a)
    assert_equal :fall, PA.classify(200.step(120, -4).to_a)
    dip = [140, 120, 100, 95, 92, 90, 92, 100, 120, 145]
    assert_equal :dip, PA.classify(dip)
    assert_equal :silent, PA.classify([])
  end

  def test_tone_acceptance
    assert PA.tone_ok?(:level, :level)
    refute PA.tone_ok?(:level, :fall)
    assert PA.tone_ok?(:dip, :fall), "citation third tone may realize low-falling"
    assert PA.tone_ok?(:neutral, :fall), "neutral makes no contour claim"
  end

  def test_pitch_track_reads_synthetic_tone
    sr = 16_000
    samples = (0...(sr / 2)).map { |i| (12_000 * Math.sin(2 * Math::PI * 150 * i / sr)).round }
    track = PA.pitch_track(samples.pack("s<*"))
    refute_empty track
    assert_in_delta 150, track.sum / track.length.to_f, 6,
                    "a 150 Hz sine tracks at 150 Hz"
  end
end
