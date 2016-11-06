# encoding: utf-8

require 'diff/lcs'
require 'diff/lcs/hunk'
require 'enumerator'

module TTY
  module File
    class Differ
      # Create a Differ
      #
      # @api public
      def initialize(string_a, string_b, options = {})
        @string_a      = string_a
        @string_b      = string_b
        @format        = options.fetch(:format, :unified)
        @context_lines = options.fetch(:context_lines, 3)
      end

      # Find character difference between two strings
      #
      # @return [String]
      #   the difference between content or empty if no
      #   difference found
      #
      # @api public
      def call
        diffs  = Diff::LCS.diff(string_a_lines, string_b_lines)
        return '' if diffs.empty?
        hunks  = extract_hunks(diffs)
        format_hunks(hunks)
      end

      private

      def convert_to_lines(string)
        string.split(/\n/).map(&:chomp)
      end

      def string_a_lines
        convert_to_lines(@string_a)
      end

      def string_b_lines
        convert_to_lines(@string_b)
      end

      # @api public
      def extract_hunks(diffs)
        file_length_difference = 0

        diffs.map do |piece|
          hunk = Diff::LCS::Hunk.new(string_a_lines, string_b_lines, piece,
                                     @context_lines, file_length_difference)
          file_length_difference = hunk.file_length_difference
          hunk
        end
      end

      # @api public
      def format_hunks(hunks)
        output = ""
        hunks.each_cons(2) do |prev_hunk, current_hunk|
          begin
            if current_hunk.overlaps?(prev_hunk)
              current_hunk.unshift(prev_hunk)
            else
              output << prev_hunk.diff(@format).to_s
            end
          ensure
            output << "\n"
          end
        end
        output << hunks.last.diff(@format) << "\n" if hunks.last
      end
    end # Differ
  end # File
end # TTY
