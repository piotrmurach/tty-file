# encoding: utf-8

require 'forwardable'

module TTY
  module File
    class CreateFile
      extend Forwardable

      attr_reader :relative_path, :content, :options, :prompt

      def_delegators "@base", :log_status

      def initialize(base, relative_path, content, options = {})
        @base    = base
        @content = content
        @options = options
        @relative_path = convert_encoded_path(relative_path)
        @prompt  = TTY::Prompt.new
      end

      def context
        options[:context] || @base
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
          ::File.open(relative_path, 'wb') { |f| f.write(content) }
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
            log_status(:identical, relative_path, options.fetch(:verbose, true), :blue)
          elsif options[:force]
            log_status(:force, relative_path, options.fetch(:verbose, true), :yellow)
            yield unless options[:noop]
          elsif options[:skip]
            log_status(:skip, relative_path, options.fetch(:verbose, true), :yellow)
          else
            log_status(:collision, relative_path, options.fetch(:verbose, true), :red)
            yield if file_collision(relative_path, content)
          end
        else
          log_status(:create, relative_path, options.fetch(:verbose, true), :green)
          yield unless options[:noop]
        end
      end

      # Display conflict resolution menu and gather answer
      #
      # @api private
      def file_collision(relative_path, content)
        choices = [
          { key: 'y', name: 'yes, overwrite', value: :yes },
          { key: 'n', name: 'no, do not overwrite', value: :no },
          { key: 'q', name: 'quit, abort', value: :quit }
        ]
        answer = prompt.expand("Overwrite #{relative_path}?", choices)
        interpret_answer(answer)
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
