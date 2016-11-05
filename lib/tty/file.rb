# encoding: utf-8

require 'pastel'
require 'tty-prompt'
require 'erb'

require 'tty/file/create_file'
require 'tty/file/download_file'
require 'tty/file/differ'
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

    # Copy file from the relative source to the relative
    # destination running it through ERB.
    # 
    # @example
    #   copy_file 'templates/test.rb', 'app/test.rb'
    #
    # @param [Hash] options
    # @option options [Symbol] :context
    #   the binding to use for the template
    # @option options [Symbol] :preserve
    #   If true, the owner, group, permissions and modified time
    #   are preserved on the copied file, defaults to false.
    # @option options [Symbol] :noop
    #   If true do not execute the action.
    # @option options [Symbol] :verbose
    #   If true log the action status to stdout
    #
    # @api public
    def copy_file(source_path, *args, &block)
      options = args.last.is_a?(Hash) ? args.pop : {}
      dest_path = args.first || source_path.sub(/\.erb$/, '')

      if ::File.directory?(dest_path)
        dest_path = ::File.join(dest_path, ::File.basename(source_path))
      end

      ctx = if (vars = options[:context])
              vars.instance_eval('binding')
            else
              instance_eval('binding')
            end

      options[:context] ||= self
      create_file(dest_path, options) do
        template = ERB.new(::File.binread(source_path), nil, "-", "@output_buffer")
        content = template.result(ctx)
        content = block.call(content) if block
        content
      end
      if options[:preserve]
        copy_metadata(source_path, dest_path, options)
      end
    end
    module_function :copy_file

    # Copy file metadata
    #
    # @api public
    def copy_metadata(src_path, dest_path, options = {})
      stats = ::File.lstat(src_path)
      ::File.utime(stats.atime, stats.mtime, dest_path)
      chmod(dest_path, stats.mode, options)
    end
    module_function :copy_metadata

    # Diff files line by line
    #
    # @param [String] path_a
    # @param [String] path_b
    # @param [Hash[Symbol]] options
    # @option options [Symbol] :format
    #   the diffining output format
    # @option options [Symbol] :context_lines
    #   the number of extra lines for the context
    #
    # @example
    #   diff(file_a, file_b, format: :old)
    #
    # @api public
    def diff(path_a, path_b, options = {})
      if FileTest.file?(path_a) && FileTest.file?(path_b)
        diff_files(path_a, path_b, options)
      else
        diff_strings(path_a, path_b, options)
      end
    end
    module_function :diff

    # Diff strings
    #
    # @api private
    def diff_strings(string_a, string_b, options)
      Differ.new(string_a, string_b, options).call
    end
    private_module_function :diff_strings

    # Diff files
    #
    # @api private
    def diff_files(path_a, path_b, options)
      return '' if ::FileUtils.identical?(path_a, path_b)
      output = ''
      ::File.open(path_a) do |file_a|
        ::File.open(path_b) do |file_b|
          block_size = file_a.lstat.blksize
          while !file_a.eof? && !file_b.eof?
            output << diff_strings(file_a.read(block_size),
                                   file_b.read(block_size),
                                   options)

          end
        end
      end
      output
    end
    private_module_function :diff_files

    # Download the content from a given address and
    # save at the given relative destination. If block
    # is provided in place of destination, the content of
    # of the uri is yielded.
    #
    # @param [String] uri
    #   the URI address
    # @param [String] dest
    #   the relative path to save
    # @param [Hash[Symbol]] options
    # @param options [Symbol] :limit
    #   the limit of redirects
    #
    # @example
    #   download_file("https://gist.github.com/4701967",
    #                 "doc/benchmarks")
    #
    # @example
    #   download_file("https://gist.github.com/4701967") do |content|
    #     content.gsub("\n", " ")
    #   end
    #
    # @api public
    def download_file(uri, *args, &block)
      options = args.last.is_a?(Hash) ? args.pop : {}
      dest_path = args.first || ::File.basename(uri)

      unless uri =~ %r{^https?\://}
        copy_file(uri, dest_path, options)
        return
      end

      content = DownloadFile.new(uri, dest_path, options).call

      if block_given?
        content = (block.arity == 1 ? block.call(content) : block.call)
      end

      create_file(dest_path, content, options)
    end
    module_function :download_file

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

    # Remove a file or a directory at specified relative path.
    #
    # @param [Hash[:Symbol]] options
    # @option options [Symbol] :noop
    #   pretend removing file
    # @option options [Symbol] :force
    #   remove file ignoring errors
    # @option options [Symbol] :verbose
    #   log status
    #
    # @example
    #   remove_file 'doc/README.md'
    #
    # @api public
    def remove_file(relative_path, *args, &block)
      options = args.last.is_a?(Hash) ? args.pop : {}

      log_status(:remove, relative_path, options.fetch(:verbose, true), :red)

      return if options[:noop]

      ::FileUtils.rm_r(relative_path, {force: options[:force], secure: true})
    end
    module_function :remove_file

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
