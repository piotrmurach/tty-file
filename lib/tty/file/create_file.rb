# frozen_string_literal: true

require "tty-prompt"

module TTY
  module File
    class CreateFile

      attr_reader :base, :relative_path, :content, :prompt, :context

      def initialize(base, relative_path, content, context: nil, force: false,
                     skip: false, verbose: true, noop: false, color: :green,
                     quiet: true)
        @base    = base
        @content = content
        @context = context || @base
        @force   = force
        @skip    = skip
        @noop    = noop
        @verbose = verbose
        @color   = color
        @relative_path = convert_encoded_path(relative_path)
        @prompt  = TTY::Prompt.new(quiet: quiet)
      end

      def exist?
        ::File.exist?(relative_path)
      end

      def identical?
        ::File.binread(relative_path) == content
      end

      # Create a file
      #
      # @api public
      def call
        detect_collision do
          FileUtils.mkdir_p(::File.dirname(relative_path))
          ::File.open(relative_path, "wb") { |f| f.write(content) }
        end
        relative_path
      end

      protected

      def convert_encoded_path(filename)
        filename.gsub(/%(.*?)%/) do |match|
          method = $1.strip
          if context.respond_to?(method, true)
            context.public_send(method)
          else
            match
          end
        end
      end

      # Check if file already exists and ask for user input on collision
      #
      # @api private
      def detect_collision
        if exist?
          if identical?
            notify(:identical, :cyan)
          elsif @force
            notify(:force, :yellow)
            yield unless @noop
          elsif @skip
            notify(:skip, :yellow)
          else
            notify(:collision, :red)
            yield if file_collision(relative_path, content)
          end
        else
          notify(:create, :green)
          yield unless @noop
        end
      end

      # Notify console about performed action
      #
      # @api private
      def notify(name, color)
        base.__send__(:log_status, name, relative_path,
                      verbose: @verbose, color: @color ? color : false)
      end

      # Display conflict resolution menu and gather answer
      #
      # @api private
      def file_collision(relative_path, content)
        choices = [
          { key: "y", name: "yes, overwrite", value: :yes },
          { key: "d", name: "diff, compare files", value: :diff },
          { key: "n", name: "no, do not overwrite", value: :no },
          { key: "q", name: "quit, abort", value: :quit }
        ]
        while (answer = prompt.expand("Overwrite #{relative_path}?", choices)) == :diff do
          show_diff
        end
        interpret_answer(answer)
      end

      # Display difference between old and new file
      #
      # @api private
      def show_diff
        print base.__send__(:diff_files, relative_path, content, verbose: @verbose)
      end

      # @api private
      def interpret_answer(answer)
        case answer
        when :yes
          true
        when :no
          false
        when :quit
          abort
        end
      end
    end # CreateFile
  end # File
end # TTY
