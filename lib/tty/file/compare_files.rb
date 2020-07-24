# frozen_string_literal: true

require_relative "differ"

module TTY
  module File
    class CompareFiles
      extend Forwardable

      def initialize(base, format: :unified, header: true, context_lines: 5,
                     verbose: true, color: :green, noop: false)
        @base = base
        @format = format
        @header = header
        @context_lines = context_lines
        @verbose = verbose
        @color = color
        @noop = noop
      end

      # Compare files
      #
      # @api public
      def call(file_a, file_b, temp_a, temp_b)
        file_a_path = temp_a ? "Old contents" : relative_path_from(file_a.path)
        file_b_path = temp_b ? "New contents" : relative_path_from(file_b.path)

        differ = Differ.new(format: @format, context_lines: @context_lines)
        block_size = file_a.lstat.blksize
        file_a_chunk = file_a.read(block_size)
        file_b_chunk = file_b.read(block_size)
        hunks = differ.(file_a_chunk, file_b_chunk)

        return "" if file_a_chunk.empty? && file_b_chunk.empty?
        return "No differences found\n" if hunks.empty?

        output = []

        if %i[unified context old].include?(@format) && @header
          output << "#{differ.delete_char * 3} #{file_a_path}\n"
          output << "#{differ.add_char * 3} #{file_b_path}\n"
        end

        output << color_diff_lines(hunks, color: @color, format: @format)
        while !file_a.eof? && !file_b.eof?
          output << differ.(file_a.read(block_size), file_b.read(block_size))
        end
        output.join
      end

      private

      # @api private
      def color_diff_lines(hunks, color: true, format: :unified)
        return hunks unless color && format == :unified

        newline = "\n"
        hunks.gsub(/^(\+[^+].*?)\n/, decorate("\\1", :green) + newline)
            .gsub(/^(\-[^-].*?)\n/, decorate("\\1", :red) + newline)
            .gsub(/^(@.+?)\n/, decorate("\\1", :cyan) + newline)
      end

      def relative_path_from(path)
        @base.__send__(:relative_path_from, path)
      end

      def decorate(*args)
        @base.__send__(:decorate, *args)
      end
    end # CompareFiles
  end # File
end # TTY
