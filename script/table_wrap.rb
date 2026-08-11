# frozen_string_literal: true

# Render-time transform for sign tables (table-balance law, owner
# ruling 2026-08-11): every sign table is wrapped in a
# div.table-scroll scroll container, and every fixed-grid sign table
# (not --tail-fit, not --even) gets its BALANCED column grid computed
# from its own content and emitted as a static <colgroup> — width
# rebalancing by construction, per table, no authoring burden.
#
# The table itself must stay a REAL table so the grid is
# deterministic: a display:block table (the old arrangement)
# shrink-wraps an anonymous table box whose percentage columns
# resolve against an unpredictable width — the "How to see it"
# starvation the owner reported. The wrapper div carries what the
# block table used to: horizontal scroll and both hover-bubble
# reserves (style.css .table-scroll; test/style_guard_test.rb pins
# the pairing). The allocation model is script/table_balance.rb —
# the same code the table-balance lint measures with.

require_relative "table_balance"

module Edubba
  module TableWrap
    module_function

    SIGN_TABLE = %r{(?<!<div class="table-scroll">)<table class="sign-table(?<mods>[^"]*)">(?<body>.*?)</table>}m

    def wrap(html, sino: html.include?("school-sinographs"))
      html.gsub(SIGN_TABLE) do
        mods, body = Regexp.last_match[:mods], Regexp.last_match[:body]
        table = Regexp.last_match[0]
        unless mods.include?("tail-fit") || mods.include?("--even")
          rows = TableBalance.rows_of(body)
          unless rows.empty?
            table = table.sub(">", ">" + TableBalance.colgroup(rows, sino))
          end
        end
        %(<div class="table-scroll">#{table}</div>)
      end
    end
  end
end
