# frozen_string_literal: true

require "minitest/autorun"
require_relative "../script/cold_read"

class ColdReadTest < Minitest::Test
  FIG = <<~HTML.strip
    <figure class="reading reading--script">
      <div class="reading-lines">
        <div class="reading-line"><span class="script">𒀀𒈬</span><span class="translit">a mu</span><span class="gloss">x</span></div>
      </div>
      <figcaption class="citation">urn:nabu:cdli:p1 · license: attribution</figcaption>
    </figure>
  HTML
  NAV = %(<nav class="chapter-nav chapter-nav-bottom" aria-label="x"></nav>)

  def test_repeats_last_figure_script_only_with_folded_check
    html = "<p>a</p>#{FIG}<p>b</p>#{NAV}"
    out = Edubba::ColdRead.transform(html)
    assert_includes out, "Read it cold"
    cold = out[/<section class="cold-read">.*?<\/section>/m]
    assert_includes cold, %(<div class="reading-line"><span class="script">𒀀𒈬</span></div>)
    assert_includes cold, %(<details class="cold-read-check">)
    assert_includes cold, "urn:nabu:cdli:p1"
    assert out.index("cold-read") < out.index("chapter-nav-bottom")
  end

  def test_untouched_without_figures_or_nav
    assert_equal NAV.to_s, Edubba::ColdRead.transform(NAV.dup)
    assert_equal FIG.to_s, Edubba::ColdRead.transform(FIG.dup)
  end

  # A script span carrying a logogram voice-mark (rulebook §9,
  # 2026-08-09) must clone whole — the nested span may not make
  # the line silently vanish from the cold read.
  def test_keeps_lines_with_logo_marks
    fig = FIG.sub("𒀀𒈬", %(𒀀𒈾 𒀭<span class="logo">𒀀𒇉</span>))
    out = Edubba::ColdRead.transform("<p>a</p>#{fig}#{NAV}")
    cold = out[/<section class="cold-read">.*?<\/section>/m]
    assert_includes cold,
                    %(<div class="reading-line"><span class="script">𒀀𒈾 𒀭<span class="logo">𒀀𒇉</span></span></div>)
  end

  def test_uses_the_last_figure
    fig2 = FIG.sub("𒀀𒈬", "𒁀𒋾").sub("a mu", "ba ti")
    out = Edubba::ColdRead.transform("#{FIG}#{fig2}#{NAV}")
    cold = out[/<section class="cold-read">.*?<\/section>/m]
    assert_includes cold, "𒁀𒋾"
    refute_includes cold[/<figure.*?<\/figure>/m], "𒀀𒈬"
  end
end
