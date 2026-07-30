# frozen_string_literal: true

require "minitest/autorun"
require_relative "../script/subscript_render"

class SubscriptRenderTest < Minitest::Test
  def transform(html)
    Edubba::SubscriptRender.transform(html)
  end

  def test_subscript_digit_becomes_sub_element
    assert_equal "<em>lu<sub>2</sub>-dingir-mu</em>",
                 transform("<em>lu₂-dingir-mu</em>")
  end

  def test_run_of_subscripts_becomes_one_sub
    assert_equal "x<sub>12</sub>", transform("x₁₂")
  end

  def test_all_ten_digits_map
    assert_equal "<sub>0123456789</sub>", transform("₀₁₂₃₄₅₆₇₈₉")
  end

  def test_title_code_pre_svg_are_untouched
    html = "<title>še₃</title><code>e₂</code><pre>u₄</pre>" \
           "<svg><text>i₃</text></svg><p>ke₄</p>"
    assert_equal "<title>še₃</title><code>e₂</code><pre>u₄</pre>" \
                 "<svg><text>i₃</text></svg><p>ke<sub>4</sub></p>",
                 transform(html)
  end

  def test_existing_sub_is_not_double_wrapped
    html = "<sub>₂</sub>"
    assert_equal html, transform(html)
  end

  def test_attributes_pass_through_whole
    html = %(<a href="#el₂" id="e₂">e₂</a>)
    assert_equal %(<a href="#el₂" id="e₂">e<sub>2</sub></a>), transform(html)
  end

  def test_html_without_subscripts_is_returned_as_is
    html = "<p>plain</p>"
    assert_same html, transform(html)
  end
end
