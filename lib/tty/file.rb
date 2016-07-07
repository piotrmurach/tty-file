# encoding: utf-8

require 'pastel'
require 'tty-prompt'
require 'tty/file/create_file'
require 'tty/file/version'

module TTY
  module File
    def self.private_module_function(method)
      module_function(method)
      private_class_method(method)
    end

    # File permissions
    U_R = 0400
    U_W = 0200
    U_X = 0100
    G_R = 0040
    G_W = 0020
    G_X = 0010
    O_R = 0004
    O_W = 0002
    O_X = 0001
    A_R = 0444
    A_W = 0222
    A_X = 0111

    # Change file permissions
    #
    # @param [String] relative_path
    # @param [Integer,String] permisssions
    # @param [Hash[Symbol]] options
    #
    # @example
    #   chmod('Gemfile', 0755)
    #
    # @example
    #   chmod('Gemilfe', TTY::File::U_R | TTY::File::U_W)
    #
    # @example
    #   chmod('Gemfile', 'u+x,g+x')
    #
    # @api public
    def chmod(relative_path, permissions, options = {})
      mode = ::File.lstat(relative_path).mode
      if permissions.to_s =~ /\d+/
        mode = permissions
      else
        permissions.scan(/[ugoa][+-=][rwx]+/) do |setting|
          who, action = setting[0], setting[1]
          setting[2..setting.size].each_byte do |perm|
            mask = const_get("#{who.upcase}_#{perm.chr.upcase}")
            (action == '+') ? mode |= mask : mode ^= mask
          end
        end
      end
      log_status(:chmod, relative_path, options.fetch(:verbose, true), :green)
      ::FileUtils.chmod_R(mode, relative_path) unless options[:noop]
    end
    module_function :chmod

    # Create new file if doesn't exist
    #
    # @param [String] relative_path
    # @param [String|nil] content
    #   the content to add to file
    # @param [Hash] options
    # @option options [Symbol] :force
    #   forces ovewrite if conflict present
    #
    # @example
    #   create_file('doc/README.md', '# Title header')
    #
    # @example
    #   create_file 'doc/README.md' do
    #     '# Title Header'
    #   end
    #
    # @api public
    def create_file(relative_path, *args, &block)
      options = args.last.is_a?(Hash) ? args.pop : {}

      content = block_given? ? block.call : args.join

      CreateFile.new(relative_path, content, options).call
    end
    module_function :create_file

    # Prepend to a file
    #
    # @param [String] relative_path
    # @param [Array[String]] content
    #   the content to preped to file
    #
    # @example
    #   prepend_to_file('Gemfile', "gem 'tty'")
    #
    # @example
    #   prepend_to_file('Gemfile') do
    #     "gem 'tty'"
    #   end
    #
    # @api public
    def prepend_to_file(relative_path, *args, &block)
      options = args.last.is_a?(Hash) ? args.pop : {}
      log_status(:prepend, relative_path, options.fetch(:verbose, true), :green)
      options.merge!(before: /\A/, verbose: false)
      inject_into_file(relative_path, *(args << options), &block)
    end
    module_function :prepend_to_file

    # Append to a file
    #
    # @param [String] relative_path
    # @param [Array[String]] content
    #   the content to append to file
    #
    # @example
    #   append_to_file('Gemfile', "gem 'tty'")
    #
    # @example
    #   append_to_file('Gemfile') do
    #     "gem 'tty'"
    #   end
    #
    # @api public
    def append_to_file(relative_path, *args, &block)
      options = args.last.is_a?(Hash) ? args.pop : {}
      log_status(:append, relative_path, options.fetch(:verbose, true), :green)
      options.merge!(after: /\z/, verbose: false)
      inject_into_file(relative_path, *(args << options), &block)
    end
    module_function :append_to_file
    alias add_to_file append_to_file

    # Inject content into file at a given location
    #
    # @param [String] relative_path
    #
    # @param [Hash] options
    # @option options [Symbol] :before
    #   the matching line to insert content before
    # @option options [Symbol] :after
    #   the matching line to insert content after
    # @option options [Symbol] :force
    #   insert content more than once
    # @option options [Symbol] :verbose
    #   log status
    #
    # @example
    #   inject_into_file('Gemfile', "gem 'tty'", after: "gem 'rack'\n")
    #
    # @example
    #   inject_into_file('Gemfile', "gem 'tty'\n", "gem 'loaf'", after: "gem 'rack'\n")
    #
    # @example
    #   inject_into_file('Gemfile', after: "gem 'rack'\n") do
    #     "gem 'tty'\n"
    #   end
    #
    # @api public
    def inject_into_file(relative_path, *args, &block)
      options = args.last.is_a?(Hash) ? args.pop : {}

      replacement = block_given? ? block.call : args.join

      flag, match = if options.key?(:after)
                      [:after, options.delete(:after)]
                    else
                      [:before, options.delete(:before)]
                    end

      match = match.is_a?(Regexp) ? match : Regexp.escape(match)
      content = if flag == :after
                  '\0' + replacement
                else
                  replacement + '\0'
                end

      replace_in_file(relative_path, /#{match}/, content, options.merge(verbose: false))

      log_status(:inject, relative_path, options.fetch(:verbose, true), :green)
    end
    module_function :inject_into_file
    alias insert_into_file inject_into_file

    # Replace content of a file matching string
    #
    # @options [Hash[String]] options
    # @option options [Symbol] :force
    #   replace content even if present
    # @option options [Symbol] :verbose
    #   log status
    #
    # @example
    #   replace_in_file('Gemfile', /gem 'rails'/, "gem 'hanami'")
    #
    # @example
    #   replace_in_file('Gemfile', /gem 'rails'/) do |match|
    #     match = "gem 'hanami'"
    #   end
    #
    # @api public
    def replace_in_file(relative_path, *args, &block)
      check_path(relative_path)
      options = args.last.is_a?(Hash) ? args.pop : {}

      contents = IO.read(relative_path)

      replacement = (block ? block.call : args[1..-1].join).gsub('\0', '')

      log_status(:replace, relative_path, options.fetch(:verbose, true), :green)

      return if options[:noop]

      if options[:force] || !contents.include?(replacement)
        if !contents.gsub!(*args, &block)
          find = args[0]
          fail "#{find.inspect} not found in #{relative_path}"
        end
        ::File.open(relative_path, 'w') do |file|
          file.write(contents)
        end
      end
    end
    module_function :replace_in_file
    alias gsub_file replace_in_file

    # Check if path exists
    #
    # @raise [ArgumentError]
    #
    # @api private
    def check_path(path)
      return if ::File.exist?(path)
      fail ArgumentError, "File path #{path} does not exist."
    end
    private_module_function :check_path

    @output = $stdout
    @pastel = Pastel.new(enabled: true)

    def decorate(message, color)
      @pastel.send(color, message)
    end
    private_module_function :decorate

    # Log file operation
    #
    # @api private
    def log_status(cmd, message, verbose, color = false)
      return unless verbose

      cmd = cmd.to_s.rjust(12)
      cmd = decorate(cmd, color) if color

      message = "#{cmd} #{message}"
      message += "\n" unless message.end_with?("\n")

      @output.print(message)
      @output.flush
    end
    module_function :log_status
  end # File
end # TTY
