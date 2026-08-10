# frozen_string_literal: true

# Read it cold (rulebook cuneiform.md §8, Stage C): a subject
# chapter's LAST reading figure is repeated before the bottom nav
# with the script bare and the transliteration + gloss folded in
# native <details> — always a repetition of a fully-walked reading,
# never a first presentation (the clone carries the original's
# citation). Pure HTML transformation; the Jekyll plugin wires it
# post_render, so no chapter is ever edited by hand.

module Edubba
  module ColdRead
    FIGURE = %r{<figure class="reading reading--script[^"]*">.*?</figure>}m
    NAV = %r{<nav class="chapter-nav chapter-nav-bottom"}

    module_function

    def transform(html)
      figures = html.scan(FIGURE)
      return html if figures.empty? || !html.match?(NAV)

      original = figures.last
      # A script span may carry nested logogram voice-marks
      # (<span class="logo">, rulebook §9 2026-08-09); the clone
      # keeps them — the green is part of how the line reads.
      script_only = original.scan(%r{<span class="script">(?:[^<]|<span class="logo">[^<]*</span>)*</span>})
                            .map { |s| %(<div class="reading-line">#{s}</div>) }
      return html if script_only.empty?

      # the clone keeps the original's figure classes (a
      # reading--stacked original must not un-stack, §5)
      classes = original[/<figure class="([^"]*)"/, 1]
      section = <<~HTML
        <section class="cold-read">
        <h2>Read it cold</h2>
        <p>This chapter's last reading, once more — script only.
        Read it aloud before you unfold.</p>
        <figure class="#{classes}">
          <div class="reading-lines">
        #{script_only.join("\n")}
          </div>
        </figure>
        <details class="cold-read-check"><summary>Check yourself</summary>
        #{original}
        </details>
        </section>
      HTML
      html.sub(NAV) { "#{section}#{Regexp.last_match(0)}" }
    end
  end
end
