# frozen_string_literal: true

require "minitest/autorun"
require_relative "../script/term_linker"
require_relative "../script/urn_linker"

class TermLinkerTest < Minitest::Test
  TERMS = [
    { "name" => "determinative", "slug" => "determinative", "def" => "a silent classifier" },
    { "name" => "glottal stop", "slug" => "glottal-stop", "def" => "a throat catch — <careful>" },
    { "name" => "phonetic complement", "slug" => "phonetic-complement", "def" => "a repeated sound" }
  ].freeze

  def t(html, baseurl: "")
    Edubba::TermLinker.transform(html, TERMS, "/terms/", baseurl)
  end

  def test_term_becomes_link_with_bubble
    out = t("<p>a determinative here</p>")
    assert_includes out,
                    %(<a class="term" href="/terms/#term-determinative">determinative) +
                    %(<span class="sign-tip" aria-hidden="true">a silent classifier</span></a>)
  end

  def test_multiword_term_plural_and_case
    out = t("<p>Glottal stops and phonetic complements.</p>")
    assert_includes out, %(#term-glottal-stop">Glottal stops<)
    assert_includes out, %(#term-phonetic-complement">phonetic complements<)
  end

  def test_definition_html_is_escaped
    assert_includes t("<p>glottal stop</p>"), "a throat catch — &lt;careful&gt;"
  end

  def test_headings_links_and_code_are_untouched
    html = "<h2>The determinative</h2><a href=\"/x/\">determinative</a><code>determinative</code>"
    assert_equal html, t(html)
  end

  def test_baseurl_prefixes_href
    out = t("<p>determinative</p>", baseurl: "/nabu-edubba")
    assert_includes out, %(href="/nabu-edubba/terms/#term-determinative")
  end

  def test_no_match_inside_longer_words
    assert_equal "<p>indeterminatives?</p>", t("<p>indeterminatives?</p>")
  end
end

class UrnLinkerTest < Minitest::Test
  def test_cuneiform_urn_links_to_cuneiform_axis
    out = Edubba::UrnLinker.transform("<code>urn:nabu:cdli:p010064</code>")
    assert_equal %(<a class="urn-link" href="https://arvicco.github.io/nabu/axis/cuneiform/"><code>urn:nabu:cdli:p010064</code></a>), out
  end

  def test_egyptian_urn_links_to_egyptian_axis
    out = Edubba::UrnLinker.transform("<code>urn:nabu:aes:x:y</code> <code>urn:nabu:tla-hf:z</code>")
    assert_equal 2, out.scan("nabu/axis/egyptian/").size
  end

  def test_unknown_source_and_plain_code_untouched
    html = "<code>urn:nabu:mystery:1</code><code>not a urn</code>"
    assert_equal html, Edubba::UrnLinker.transform(html)
  end
end
