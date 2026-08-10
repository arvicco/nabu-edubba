# frozen_string_literal: true

# Nabu URN links (owner request 2026-07-31): every cited
# <code>urn:nabu:…</code> becomes a link to the Nabu axis desk that
# explains the source and how to use the URN — cuneiform shelves to
# the cuneiform axis, Egyptian shelves to the Egyptian axis. Pure
# text transformation; site/_plugins/urn_links.rb wires post_render.

module Edubba
  module UrnLinker
    AXES = {
      "cdli" => "cuneiform", "oracc" => "cuneiform",
      "etcsl" => "cuneiform", "ebl" => "cuneiform",
      "aes" => "egyptian", "tla-hf" => "egyptian",
      "kanripo" => "sinitic"
    }.freeze
    AXIS_BASE = "https://arvicco.github.io/nabu/axis/"
    URN_CODE = %r{<code>(urn:nabu:([a-z0-9-]+):[^<]*)</code>}

    module_function

    def transform(html)
      return html unless html.include?("urn:nabu:")

      html.gsub(URN_CODE) do
        urn, source = Regexp.last_match(1), Regexp.last_match(2)
        axis = AXES[source]
        if axis
          %(<a class="urn-link" href="#{AXIS_BASE}#{axis}/"><code>#{urn}</code></a>)
        else
          Regexp.last_match(0)
        end
      end
    end
  end
end
