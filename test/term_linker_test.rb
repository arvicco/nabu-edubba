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

  def test_school_terms_route_to_their_own_glossary
    terms = TERMS + [
      { "name" => "serekh", "slug" => "serekh", "def" => "a palace-facade frame", "school" => "hieroglyphs" }
    ]
    urls = { nil => "/terms/", "hieroglyphs" => "/hieroglyphs/addenda/terms/" }
    out = Edubba::TermLinker.transform("<p>a serekh, a determinative</p>", terms, urls, "")
    assert_includes out, %(href="/hieroglyphs/addenda/terms/#term-serekh")
    assert_includes out, %(href="/terms/#term-determinative")
  end

  def test_school_term_falls_back_to_general_glossary_with_string_url
    terms = [{ "name" => "serekh", "slug" => "serekh", "def" => "x", "school" => "hieroglyphs" }]
    out = Edubba::TermLinker.transform("<p>serekh</p>", terms, "/terms/", "")
    assert_includes out, %(href="/terms/#term-serekh")
  end
end

class UrnLinkerTest < Minitest::Test
  def test_scoped_term_bubbles_only_under_its_prefix
    terms = [{ "name" => "perfect", "slug" => "perfect",
               "def" => "has happened", "scope" => "/cuneiform/" }]
    inside = Edubba::TermLinker.transform(
      "<p>the perfect tense</p>", terms, "/terms/", "",
      page_url: "/cuneiform/103/15-x/"
    )
    assert_includes inside, %(class="term")

    outside = Edubba::TermLinker.transform(
      "<p>the perfect reading drill</p>", terms, "/terms/", "",
      page_url: "/hieroglyphs/101/06-x/"
    )
    refute_includes outside, %(class="term"),
                    "a scoped term is plain English outside its prefix"

    no_url = Edubba::TermLinker.transform(
      "<p>perfect</p>", terms, "/terms/", ""
    )
    refute_includes no_url, %(class="term"),
                    "without a page URL a scoped term stays unlinked"
  end

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
