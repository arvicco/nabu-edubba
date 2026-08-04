# frozen_string_literal: true

# Drill shelves (rulebook cuneiform.md §8, Stage C): every taught
# sign as disclosure-cards in three directions, deterministically
# interleaved — the order is a stable function of the sign data
# (codepoint-keyed hashing plus a fix-up pass that keeps
# chapter-mates apart), never of a clock. Confusables stand
# adjacent as contrast rows. A print stylesheet turns the page
# into cut-out Leitner cards.

require_relative "warmup"
require_relative "rulebook"

module Edubba
  module Drills
    DIRECTIONS = %i[read write mean].freeze

    module_function

    # All cards for a school's seats: each sign in up to three
    # directions (silent signs drop :read/:mean prompts that need a
    # reading and keep draw-style :write), pseudo-shuffled stably.
    def cards(seats)
      list = []
      seats.each do |seat|
        seat[:signs].each do |sign|
          dirs = Warmup.silent?(sign) ? %i[write mean] : DIRECTIONS
          dirs.each { |d| list << { sign: sign, seat: seat, direction: d } }
        end
      end
      shuffled = list.sort_by { |c| sort_key(c) }
      spread(shuffled)
    end

    def sort_key(card)
      cp = (card[:sign]["codepoint"] || card[:sign]["glyph"].to_s.codepoints.first.to_s(16)).to_s.hex
      (cp * 2_654_435_761 + DIRECTIONS.index(card[:direction]) * 7_919) % 104_729
    end

    # One deterministic pass: adjacent cards from the same seat swap
    # apart so interleaving holds.
    def spread(list)
      out = list.dup
      (0...out.size - 2).each do |i|
        next unless out[i][:seat].equal?(out[i + 1][:seat])

        out[i + 1], out[i + 2] = out[i + 2], out[i + 1]
      end
      out
    end

    def card_html(card, school)
      s = card[:sign]
      reads = Warmup.reads(s, school)
      keyword = s["keyword"]
      tail = "#{Warmup.ident(s)} · #{s['meaning']}"
      front, back =
        case card[:direction]
        when :read
          [%(<span class="script">#{s['glyph']}</span> — read it),
           %(<span class="translit">#{reads}</span> · <em>#{keyword}</em> · #{tail})]
        when :write
          if Warmup.silent?(s)
            [%(<em>#{keyword}</em> — draw the sign),
             %(<span class="script">#{s['glyph']}</span> · #{tail})]
          else
            [%(<span class="translit">#{reads}</span> · <em>#{keyword}</em> — write it),
             %(<span class="script">#{s['glyph']}</span> · #{tail})]
          end
        else
          [%(<span class="script">#{s['glyph']}</span> <span class="translit">#{reads}</span> — what does it mean?),
           %(<em>#{keyword}</em> · #{tail})]
        end
      %(<li class="drill-card"><details><summary>#{front}</summary><p class="warmup-answer">#{back}</p></details></li>)
    end

    # Confusable clusters (deduped, order-stable) for contrast rows.
    def clusters(seats)
      by_ident = {}
      seats.each { |seat| seat[:signs].each { |s| by_ident[Warmup.ident(s)] = s } }
      seen = {}
      out = []
      by_ident.each_value do |s|
        partners = Array(s["confusable_with"])
        next if partners.empty?

        group = ([Warmup.ident(s)] + partners).sort
        key = group.join("|")
        next if seen[key]

        seen[key] = true
        out << group.filter_map { |n| by_ident[n] }
      end
      out.reject { |g| g.size < 2 }
    end

    def shelf_html(seats, school, slug_base, baseurl = "")
      items = cards(seats).map { |c| card_html(c, school) }.join("\n")
      rows = clusters(seats).map do |group|
        cells = group.map do |s|
          slug = Rulebook.sign_slug(Warmup.ident(s))
          %(<a class="drill-contrast-cell" href="#{baseurl}#{slug_base}#{slug}/"><span class="script">#{s['glyph']}</span> <em>#{s['keyword']}</em></a>)
        end.join("\n    ")
        %(  <li class="drill-contrast-row">\n    #{cells}\n  </li>)
      end.join("\n")
      { cards: %(<ol class="drill-list">\n#{items}\n</ol>),
        contrasts: %(<ul class="drill-contrasts">\n#{rows}\n</ul>) }
    end
  end
end
