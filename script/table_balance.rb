# frozen_string_literal: true

# The table-balance law (owner ruling 2026-08-11, a HARD rule): no
# single column of a sign table may add more than 15% to the table's
# height over what the table would measure without that column. The
# remedy is WIDTH first — the height-driving column is under-allotted
# and takes every rem the label columns can spare — and only when no
# width remains to give does the rule point at the content: excessive
# text concentrated in one column gets trimmed or compressed.
#
# One model, two consumers, zero drift:
#   - the BUILD (site/_plugins/table_wrap.rb) computes each sign
#     table's balanced column grid with `allocate` and emits it as a
#     static <colgroup> — rebalancing by construction, per table;
#   - the LINT (script/lint.rb check_table_balance) measures the 15%
#     rule against the SAME allocation with `excesses` — what
#     survives allocation is a content problem, not a width problem.
#
# Heights are modeled at the content measure with documented
# approximations: average Latin advance 0.5 em, CJK/boxes 1.4 em,
# glyph cells at their sign-cell size. Approximate by construction —
# the law needs a deterministic, offline height model, not pixels.

module Edubba
  module TableBalance
    module_function

    TABLE_REM = 44.0     # --measure: tables are modeled at the measure
    CELL_PAD = 1.5       # rem of inline padding per cell
    LATIN_EM = 0.5       # average body-text advance, em
    WIDE_EM = 1.4        # CJK, boxes and other wide glyphs inline
    PROSE_LINE = 1.5     # rem per wrapped prose line
    LABEL_MAX = 8.0      # rem — columns needing less are labels: never shrunk
    PROSE_FLOOR = 8.0    # rem — no prose column shrinks below this
    LIMIT = 0.15

    ROW = %r{<tr>(.*?)</tr>}m
    CELL = %r{<t(?:d|h)(?<attrs>[^>]*)>(?<cell>.*?)</t(?:d|h)>}m

    # [[attrs, text], ...] per row, tags/Liquid stripped from text.
    def rows_of(body)
      body.scan(ROW).map do |(row)|
        row.scan(CELL).map do |attrs, cell|
          text = cell.gsub(/\{\{.*?\}\}|\{%.*?%\}|<[^>]+>/m, "")
                     .gsub(/&\w+;/, "x").gsub(/\s+/, " ").strip
          [attrs, text]
        end
      end.reject(&:empty?)
    end

    def glyph_size(sino) = sino ? 2.6 : 2.0

    # Natural (unwrapped) width of a cell, rem, padding included.
    def cell_demand(attrs, text, sino)
      return CELL_PAD if text.empty?

      if attrs.include?("sign-cell")
        text.length * glyph_size(sino) + CELL_PAD
      else
        text.each_char.sum { |c| c.ord < 0x2E80 ? LATIN_EM : WIDE_EM } + CELL_PAD
      end
    end

    # Balanced widths, rem, summing to TABLE_REM: label columns get
    # their natural width whole; prose columns divide what remains in
    # proportion to their demand, floored so none is starved.
    def allocate(rows, sino)
      ncols = rows.map(&:size).max
      demands = Array.new(ncols) do |i|
        rows.filter_map { |cells| cells[i] && cell_demand(*cells[i], sino) }.max || CELL_PAD
      end
      if demands.sum <= TABLE_REM
        spare = (TABLE_REM - demands.sum) / ncols
        return demands.map { |d| d + spare }
      end

      labels = demands.map { |d| d <= LABEL_MAX }
      fixed = demands.zip(labels).sum { |d, l| l ? d : 0.0 }
      pool = demands.zip(labels).filter_map { |d, l| d unless l }
      room = TABLE_REM - fixed
      widths = demands.zip(labels).map do |d, l|
        next d if l

        [room * d / pool.sum, PROSE_FLOOR].max
      end
      # floors may overrun the room; scale the prose columns back
      over = widths.sum - TABLE_REM
      if over > 0.01
        prose_total = widths.zip(labels).sum { |w, l| l ? 0.0 : w }
        widths = widths.zip(labels).map { |w, l| l ? w : w * (prose_total - over) / prose_total }
      end
      widths
    end

    # Height of one cell at its allotted width, rem.
    def cell_height(attrs, text, width, sino)
      usable = [width - CELL_PAD, 1.0].max
      return PROSE_LINE if text.empty?

      if attrs.include?("sign-cell")
        size = glyph_size(sino)
        [(text.length * size / usable).ceil, 1].max * size * 1.2
      else
        em = text.each_char.sum { |c| c.ord < 0x2E80 ? LATIN_EM : WIDE_EM }
        [(em / usable).ceil, 1].max * PROSE_LINE
      end
    end

    # Per-column excess height share under the balanced allocation:
    # [ [col_index, added_fraction], ... ] for columns over LIMIT.
    # Glyph (sign-cell) columns are exempt: their height comes from
    # font size, not wrapping — no width can lower it, and it IS the
    # row's intended scale.
    def excesses(rows, sino)
      widths = allocate(rows, sino)
      grid = rows.map do |cells|
        cells.each_with_index.map { |(attrs, text), i| cell_height(attrs, text, widths[i], sino) }
      end
      full = grid.sum(&:max)
      glyph_col = (0...widths.size).map do |c|
        rows.any? { |cells| cells[c] && cells[c][0].include?("sign-cell") }
      end
      (0...widths.size).filter_map do |c|
        next if glyph_col[c]

        without = grid.sum do |row|
          rest = row.each_with_index.reject { |_, i| i == c }.map(&:first)
          rest.max || PROSE_LINE
        end
        added = full / without - 1.0
        [c, added] if added > LIMIT
      end
    end

    # <colgroup> percentages for the balanced grid.
    def colgroup(rows, sino)
      widths = allocate(rows, sino)
      cols = widths.map { |w| format(%(<col style="width:%.1f%%">), 100.0 * w / TABLE_REM) }
      "<colgroup>#{cols.join}</colgroup>"
    end
  end
end
