# frozen_string_literal: true

require "minitest/autorun"
require_relative "../script/table_balance"
require_relative "../script/table_wrap"

# The table-balance law (owner ruling 2026-08-11): width first —
# the build gives every sign table its balanced per-table grid —
# and the 15% hard rule points at concentrated text only when no
# width remains to give.
class TableBalanceTest < Minitest::Test
  TB = Edubba::TableBalance

  def table(cells_rows)
    rows = cells_rows.map do |cells|
      "<tr>" + cells.map { |c| c.start_with?("<t") ? c : "<td>#{c}</td>" }.join + "</tr>"
    end
    rows.join
  end

  def test_labels_keep_their_width_prose_splits_the_rest
    body = table([
      ['<td class="script sign-cell">人</td>', "person", "a short label",
       "long prose " * 30]
    ])
    rows = TB.rows_of(body)
    w = TB.allocate(rows, true)
    assert_in_delta TB::TABLE_REM, w.sum, 0.01, "widths always sum to the measure"
    assert_operator w.last, :>, w[0..2].max * 2,
                    "the long-prose column takes the width the labels do not need"
    assert_operator w[0], :>=, 2.6 + TB::CELL_PAD - 0.01,
                    "the glyph column keeps its natural width whole"
  end

  def test_short_tables_spread_slack_evenly
    rows = TB.rows_of(table([["a", "b", "c"]]))
    w = TB.allocate(rows, false)
    assert_in_delta w[0], w[1], 0.01, "identical demands share slack equally"
    assert_in_delta TB::TABLE_REM, w.sum, 0.01
  end

  def test_excess_flags_only_concentrated_text
    balanced = TB.rows_of(table([
      ['<td class="script sign-cell">人</td>', "person", "short note"]
    ] * 4))
    assert_empty TB.excesses(balanced, true),
                 "short cells under the glyph row height add nothing"

    bloated = TB.rows_of(table([
      ['<td class="script sign-cell">人</td>', "person", "x " * 220]
    ] * 4))
    cols = TB.excesses(bloated, true).map(&:first)
    assert_includes cols, 2,
                    "a column of very long prose still drives height at max width — " \
                    "the 15% rule points at the content"
  end

  def test_colgroup_percentages_sum_to_one_hundred
    rows = TB.rows_of(table([["a", "b", "long prose " * 20]]))
    cg = TB.colgroup(rows, false)
    pcts = cg.scan(/width:([\d.]+)%/).flatten.map(&:to_f)
    assert_equal 3, pcts.size
    assert_in_delta 100.0, pcts.sum, 0.5
  end

  def test_wrap_adds_scroll_container_and_grid
    html = %(<p>x</p><table class="sign-table"><tr><td>a</td><td>b</td></tr></table>)
    out = Edubba::TableWrap.wrap(html, sino: false)
    assert_includes out, '<div class="table-scroll"><table class="sign-table"><colgroup>'
    assert_equal out, Edubba::TableWrap.wrap(out, sino: false),
                 "wrapping is idempotent — a wrapped table is left alone"
  end

  def test_opt_out_tables_scroll_but_keep_their_own_layout
    %w[sign-table--tail-fit sign-table--even].each do |mod|
      html = %(<table class="sign-table #{mod}"><tr><td>a</td><td>b</td></tr></table>)
      out = Edubba::TableWrap.wrap(html, sino: false)
      assert_includes out, '<div class="table-scroll">', "#{mod} still scrolls"
      refute_includes out, "<colgroup>", "#{mod} keeps auto layout — no computed grid"
    end
  end
end
