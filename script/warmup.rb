# frozen_string_literal: true

# The spiral warm-up (rulebook cuneiform.md §8 / hieroglyphs.md §10,
# Stage C): every subject chapter opens with a generated retrieval
# panel — prompts against signs taught 1, 2, 4, and 8 seats earlier
# in the school's COMBINED curriculum sequence (a 102 chapter looks
# back into 101). Keyword-first, direction rotating, answers folded
# in native <details>. Everything here is deterministic: prompt
# choice is a function of the chapter number, never of a clock.

require_relative "sign_linker"

module Edubba
  module Warmup
    OFFSETS = [1, 2, 4, 8].freeze

    module_function

    # Combined sequence of teaching seats for a school:
    # [{course:, chapter:, signs: [sign-hash,...]}, ...] in
    # curriculum order. reg101 uses taught_in; queues (102, 103) use
    # chapter. A third course joins the spiral the moment its queue
    # exists — C103 chapters look back into 102 and 101.
    def sequence(reg101, reg102, school, reg103 = nil)
      seats = []
      Array(reg101).group_by { |s| s["taught_in"] }
                   .reject { |ch, _| ch.nil? }.sort.each do |ch, signs|
        seats << { course: "#{school}-101", chapter: ch, signs: signs }
      end
      { "102" => reg102, "103" => reg103 }.each do |course, reg|
        Array(reg).select { |s| s["chapter"] }
                  .group_by { |s| s["chapter"] }.sort.each do |ch, signs|
          seats << { course: "#{school}-#{course}", chapter: ch, signs: signs }
        end
      end
      seats
    end

    # The prompts for a page: up to 6, nearest vintages first
    # (2 signs from N-1 and N-2, 1 from N-4 and N-8), each tagged
    # with its seat for attribution. nil when the page has no seat
    # (references) or nothing behind it (a school's first chapter).
    def prompts(course, chapter, seats)
      pos = seats.index { |s| s[:course] == course && s[:chapter] == chapter }
      return nil if pos.nil? || pos.zero?

      picks = []
      OFFSETS.each_with_index do |off, i|
        seat = pos - off
        next if seat.negative?

        take = i < 2 ? 2 : 1
        signs = seats[seat][:signs]
        take.times do |k|
          break if k >= signs.size

          sign = signs[(chapter + i + k) % signs.size]
          picks << { sign: sign, seat: seats[seat], direction: direction_for(sign, chapter + picks.size) }
        end
        break if picks.size >= 6
      end
      picks.uniq { |p| p[:sign] }.first(6)
    end

    # Silent signs (no reading) always prompt keyword->draw; others
    # rotate draw / read / mean off the chapter number.
    def direction_for(sign, salt)
      return :draw if silent?(sign)

      %i[draw read mean][salt % 3]
    end

    def silent?(sign)
      v = sign["value"].to_s.strip
      v.empty? || v == "—"
    end

    def reads(sign, school)
      return "—" if silent?(sign)
      return sign["value"] unless school == "cuneiform"

      sign["display_value"] || SignLinker.display_form(sign["value"])
    end

    def ident(sign) = sign["gardiner"] || sign["name"]

    # The full folded panel, or nil.
    def panel_html(course, chapter, seats, school, chapter_urls, baseurl = "")
      picks = prompts(course, chapter, seats)
      return nil if picks.nil? || picks.empty?

      items = picks.map { |p| prompt_html(p, school, chapter_urls, baseurl) }.join("\n")
      <<~HTML
        <details class="warmup">
          <summary>Warm-up · #{picks.size} quick retrievals from earlier chapters</summary>
          <ol class="warmup-list">
        #{items}
          </ol>
        </details>
      HTML
    end

    def prompt_html(pick, school, chapter_urls, baseurl)
      s = pick[:sign]
      seat = pick[:seat]
      url = chapter_urls[[seat[:course], seat[:chapter]]]
      where = url ? %( <a href="#{baseurl}#{url}">↩</a>) : ""
      answer_tail = "#{ident(s)} · #{s['meaning']}#{where}"
      q, a =
        case pick[:direction]
        when :draw
          [%(<em>#{s['keyword']}</em> — draw it, then check),
           %(<span class="script">#{s['glyph']}</span> <span class="translit">#{reads(s, school)}</span> · #{answer_tail})]
        when :read
          [%(<span class="script">#{s['glyph']}</span> — read it),
           %(<span class="translit">#{reads(s, school)}</span> — <em>#{s['keyword']}</em> · #{answer_tail})]
        else
          [%(<span class="script">#{s['glyph']}</span> <span class="translit">#{reads(s, school)}</span> — what does it mean?),
           %(<em>#{s['keyword']}</em> · #{answer_tail})]
        end
      %(    <li><details><summary>#{q}</summary><p class="warmup-answer">#{a}</p></details></li>)
    end
  end
end
