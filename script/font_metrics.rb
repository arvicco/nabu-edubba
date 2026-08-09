# frozen_string_literal: true

# Minimal TTF metrics reader for the vendored subset fonts: enough
# to answer "how wide is this string at font-size X" from the real
# hmtx advance widths — no gems, no network, works on the committed
# .ttf. Used by the reading-width check (script/lint.rb): a reading
# line's rendered script width is layout law, so the gate must
# measure with the same font the reader sees.
module Edubba
  module FontMetrics
    class Font
      attr_reader :units_per_em

      def initialize(path)
        @data = File.binread(path)
        @tables = parse_table_directory
        @units_per_em = @data[@tables["head"] + 18, 2].unpack1("n")
        @advances = parse_hmtx
        @cmap = parse_cmap
      end

      # advance width of one codepoint in em (Float); 0.0 if unmapped.
      def advance_em(codepoint)
        gid = @cmap[codepoint] or return 0.0
        (@advances[gid] || @advances.last).to_f / @units_per_em
      end

      # width of a whole string in em, spaces included.
      def width_em(text)
        text.each_char.sum { |c| advance_em(c.ord) }
      end

      private

      def parse_table_directory
        count = @data[4, 2].unpack1("n")
        (0...count).each_with_object({}) do |i, h|
          tag, _sum, off, _len = @data[12 + i * 16, 16].unpack("a4N3")
          h[tag] = off
        end
      end

      def parse_hmtx
        num_hmetrics = @data[@tables["hhea"] + 34, 2].unpack1("n")
        num_glyphs = @data[@tables["maxp"] + 4, 2].unpack1("n")
        off = @tables["hmtx"]
        advances = (0...num_hmetrics).map { |i| @data[off + i * 4, 2].unpack1("n") }
        # trailing glyphs reuse the last advance
        advances.fill(advances.last, num_hmetrics, num_glyphs - num_hmetrics) if num_glyphs > num_hmetrics
        advances
      end

      def parse_cmap
        base = @tables["cmap"]
        count = @data[base + 2, 2].unpack1("n")
        subtables = (0...count).map do |i|
          pid, eid, off = @data[base + 4 + i * 8, 8].unpack("nnN")
          [pid, eid, base + off]
        end
        # prefer a format-12 subtable (SMP codepoints live there)
        map = {}
        subtables.each do |_pid, _eid, off|
          format = @data[off, 2].unpack1("n")
          case format
          when 12 then parse_cmap12(off, map)
          when 4 then parse_cmap4(off, map)
          end
        end
        map
      end

      def parse_cmap12(off, map)
        ngroups = @data[off + 12, 4].unpack1("N")
        (0...ngroups).each do |i|
          s, e, gid = @data[off + 16 + i * 12, 12].unpack("N3")
          (s..e).each_with_index { |cp, k| map[cp] ||= gid + k }
        end
      end

      def parse_cmap4(off, map)
        segx2 = @data[off + 6, 2].unpack1("n")
        ends = @data[off + 14, segx2].unpack("n*")
        starts = @data[off + 16 + segx2, segx2].unpack("n*")
        deltas = @data[off + 16 + segx2 * 2, segx2].unpack("n*")
        range_off_base = off + 16 + segx2 * 3
        range_offs = @data[range_off_base, segx2].unpack("n*")
        ends.each_index do |i|
          (starts[i]..ends[i]).each do |cp|
            next if cp == 0xFFFF
            if range_offs[i].zero?
              map[cp] ||= (cp + deltas[i]) & 0xFFFF
            else
              gidx = range_off_base + i * 2 + range_offs[i] + (cp - starts[i]) * 2
              gid = @data[gidx, 2].unpack1("n")
              map[cp] ||= gid.zero? ? nil : (gid + deltas[i]) & 0xFFFF
            end
          end
        end
      end
    end
  end
end
