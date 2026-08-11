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
    dip = [140, 130, 122, 112, 104, 98, 95, 98, 104, 116, 128, 140]
    assert_includes [:dip, :fall], PA.classify(dip),
                    "a citation dip may measure low-falling on the smooth run"
    assert PA.tone_ok?(:dip, dip)
    assert_equal :silent, PA.classify([])
  end

  def test_tone_acceptance_on_tracks
    level = [180] * 20
    fall = 200.step(120, -4).to_a
    rise_with_onset_dip = [210, 205, 200, 198, 198, 203, 211, 229, 242, 262, 281]
    low_flat = [100] * 15
    assert PA.tone_ok?(:level, level)
    refute PA.tone_ok?(:level, fall), "the mislabeled ma case stays refused"
    assert PA.tone_ok?(:rise, rise_with_onset_dip), "tone 2 may dip before rising"
    assert PA.tone_ok?(:dip, low_flat), "citation tone 3 may sit low and flat"
    refute PA.tone_ok?(:dip, rise_with_onset_dip.map { |x| x + 40 }.each_with_index.map { |x, i| x + i * 6 }), "a clear pure rise is not a third tone"
    assert PA.tone_ok?(:fall, fall)
    assert PA.tone_ok?(:neutral, fall), "neutral makes no contour claim"
  end

  def test_steep_fall_accepted_on_raw_view
    # A fast tone-4 glide steps >10% per frame, fragmenting the
    # smooth vowel run; the raw trimmed track must carry it (the
    # zhèng case, 2026-08-11).
    steep = [229, 225, 213, 203, 176, 130, 119, 112]
    assert PA.tone_ok?(:fall, steep)
    refute PA.tone_ok?(:level, steep)
  end

  def test_de_octave_snaps_creak_doubling
    sr = 16_000
    # 150 Hz sine whose tail is 300 Hz — the period-halving shape
    # creak induces; the de-octave pass reads the tail as 150.
    samples = (0...(sr / 2)).map do |i|
      f = i < (sr * 3 / 8) ? 150 : 300
      (12_000 * Math.sin(2 * Math::PI * f * i / sr)).round
    end
    track = PA.pitch_track(samples.pack("s<*"))
    refute_empty track
    assert track.last < 200, "doubled tail snapped back to the base octave"
  end

  # --- M19-3: cut QA over the energy envelope. Synthetic PCM:
  # --- 150 Hz sine bursts shaped by an amplitude envelope.

  SR = 16_000

  def burst(seconds, amp: 12_000, hz: 150)
    (0...(SR * seconds).to_i).map do |i|
      # half-sine amplitude shape — a natural syllable swell
      shape = Math.sin(Math::PI * i / (SR * seconds))
      (amp * shape * Math.sin(2 * Math::PI * hz * i / SR)).round
    end
  end

  def silence(seconds) = [0] * (SR * seconds).to_i

  def pcm(samples) = samples.pack("s<*")

  def test_a_clean_single_syllable_passes_cut_qa
    ok, why = PA.cut_ok?(pcm(silence(0.05) + burst(0.5) + silence(0.05)))
    assert ok, "one hump, 0.5 s — a clean cut: #{why}"
  end

  def test_two_humps_refuse_the_yue_signature
    # The 2026-08-11 escape: yuē's cut carried 会's onset — two
    # energy humps with a near-silent valley, tone still "level".
    two = silence(0.05) + burst(0.3) + silence(0.15) + burst(0.25) + silence(0.05)
    ok, why = PA.cut_ok?(pcm(two), tone: :level)
    refute ok
    assert_match(/humps/, why)
  end

  def test_the_third_tone_glottal_closure_is_allowed_a_second_hump
    # Citation tone 3 may close the glottis completely mid-dip (the
    # kě/bǎi envelopes, 2026-08-11: dedicated single-syllable
    # recordings at ~2% RMS in the trough) — two humps for :dip is
    # one syllable, not two. Three still refuses.
    closed = silence(0.05) + burst(0.25) + silence(0.08) + burst(0.25) + silence(0.05)
    ok, why = PA.cut_ok?(pcm(closed), tone: :dip)
    assert ok, "tone-3 glottal closure refused: #{why}"
    refute PA.cut_ok?(pcm(closed), tone: :level).first,
           "the same shape in a level syllable is a wrong cut"
    three = silence(0.05) + burst(0.2) + silence(0.1) + burst(0.2) + silence(0.1) + burst(0.2)
    refute PA.cut_ok?(pcm(three), tone: :dip).first
  end

  def test_span_bounds_refuse_slivers_and_whole_words
    ok, why = PA.cut_ok?(pcm(burst(0.08)))
    refute ok, "an 80 ms sliver is not a syllable"
    assert_match(/span/, why)
    ok, why = PA.cut_ok?(pcm(burst(1.2)))
    refute ok, "a 1.2 s span is a word, not a syllable (the hū case)"
    assert_match(/span/, why)
  end

  def test_breathy_onset_does_not_split_the_hump
    # Low-level aspiration before the vowel (well under the 15%
    # valley floor) must read as ONE hump, not two.
    breath = (0...(SR * 0.08).to_i).map { rand(-600..600) }
    ok, why = PA.cut_ok?(pcm(silence(0.03) + breath + burst(0.45)))
    assert ok, "breathy onset split the hump: #{why}"
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
