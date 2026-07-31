# frozen_string_literal: true

# Technical-term bubbles (owner request 2026-07-31): every glossary
# term appearing in rendered prose becomes a link to its /terms/
# entry, carrying a pure-CSS hover bubble with the short definition —
# same mechanism as sign links. Pure text transformation over
# rendered HTML; site/_plugins/term_links.rb wires it to post_render.
#
# Rules:
# - Case-insensitive whole-word match; an optional plural -s rides
#   along. Longer terms win over shorter ones.
# - Never inside <a>, <title>, <svg>, <script>, <style>, <code>,
#   <pre>, <sub>, or headings (h1-h3) — prose and table cells only.

module Edubba
  module TermLinker
    TOKEN = /<[^>]*>|[^<]+/m
    SKIP = /\A<(\/?)(a|title|svg|script|style|code|pre|sub|h1|h2|h3)[\s>\/]/i

    module_function

    # terms: [{ "name" => ..., "slug" => ..., "def" => ... }, ...]
    def transform(html, terms, terms_url, baseurl = "")
      return html if terms.empty?

      pattern = build_pattern(terms)
      by_name = terms.each_with_object({}) do |t, h|
        h[t["name"].downcase] = t
      end
      skip_depth = 0
      html.gsub(TOKEN) do |tok|
        if tok.start_with?("<")
          if (m = SKIP.match(tok))
            m[1] == "/" ? (skip_depth -= 1 if skip_depth.positive?) : skip_depth += 1
          end
          tok
        elsif skip_depth.positive?
          tok
        else
          tok.gsub(pattern) do |word|
            base = word.downcase.sub(/s\z/, "")
            term = by_name[word.downcase] || by_name[base]
            next word unless term

            %(<a class="term" href="#{baseurl}#{terms_url}#term-#{term['slug']}">#{word}<span class="sign-tip" aria-hidden="true">#{escape(term['def'])}</span></a>)
          end
        end
      end
    end

    def build_pattern(terms)
      names = terms.map { |t| Regexp.escape(t["name"]) }
                   .sort_by { |n| -n.length }
      /\b(?:#{names.join('|')})s?\b/i
    end

    def escape(text)
      text.to_s.gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;")
    end
  end
end
