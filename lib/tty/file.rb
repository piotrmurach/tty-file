# encoding: utf-8

require 'pastel'
require 'tty-prompt'
require 'erb'
require 'tempfile'
require 'pathname'

require_relative 'file/create_file'
require_relative 'file/digest_file'
require_relative 'file/download_file'
require_relative 'file/differ'
require_relative 'file/version'

module TTY
  module File
    def self.private_module_function(method)
      module_function(method)
      private_class_method(method)
    end
    # Invalid path erorr
    InvalidPathError = Class.new(ArgumentError)

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

    # Check if file is binary
    #
    # @param [String] relative_path
    #   the path to file to check
    #
    # @example
    #   binary?('Gemfile') # => false
    #
    # @example
    #   binary?('image.jpg') # => true
    #
    # @return [Boolean]
    #   Returns `true` if the file is binary, `false` otherwise
    #
    # @api public
    def binary?(relative_path)
      bytes = ::File.stat(relative_path).blksize
      bytes = 4096 if bytes > 4096
      buffer = ::File.read(relative_path, bytes, 0) || ''
      buffer = buffer.force_encoding(Encoding.default_external)
      begin
        return buffer !~ /\A[\s[[:print:]]]*\z/m
      rescue ArgumentError => error
        return true if error.message =~ /invalid byte sequence/
        raise
      end
    end
    module_function :binary?

    # Create checksum for a file, io or string objects
    #
    # @param [File,IO,String] source
    #   the source to generate checksum for
    # @param [String] mode
    # @param [Hash[Symbol]] options
    # @option options [String] :noop
    #   No operation
    #
    # @example
    #   checksum_file('/path/to/file')
    #
    # @example
    #   checksum_file('Some string content', 'md5')
    #
    # @return [String]
    #   the generated hex value
    #
    # @api public
    def checksum_file(source, *args, **options)
      mode     = args.size.zero? ? 'sha256' : args.pop
      digester = DigestFile.new(source, mode, options)
      digester.call unless options[:noop]
    end
    module_function :checksum_file

    # Change file permissions
    #
    # @param [String] relative_path
    # @param [Integer,String] permisssions
    # @param [Hash[Symbol]] options
    # @option options [Symbol] :noop
    # @option options [Symbol] :verbose
    # @option options [Symbol] :force
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
    def chmod(relative_path, permissions, **options)
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

    # Create directory structure
    #
    # @param [String, Hash] destination
    #   the path or data structure describing directory tree
    #
    # @example
    #   create_directory('/path/to/dir')
    #
    # @example
    #   tree =
    #     'app' => [
    #       'README.md',
    #       ['Gemfile', "gem 'tty-file'"],
    #       'lib' => [
    #         'cli.rb',
    #         ['file_utils.rb', "require 'tty-file'"]
    #       ]
    #       'spec' => []
    #     ]
    #
    #   create_directory(tree)
    #
    # @return [void]
    #
    # @api public
    def create_directory(destination, *args, **options)
      parent = args.size.nonzero? ? args.pop : nil
      if destination.is_a?(String)
        destination = { destination => [] }
      end

      destination.each do |dir, files|
        path = parent.nil? ? dir : ::File.join(parent, dir)
        unless ::File.exist?(path)
          ::FileUtils.mkdir_p(path)
          log_status(:create, path, options.fetch(:verbose, true), :green)
        end

        files.each do |filename, contents|
          if filename.respond_to?(:each_pair)
            create_directory(filename, path, options)
          else
            create_file(::File.join(path, filename), contents, options)
          end
        end
      end
    end
    module_function :create_directory

    alias create_dir create_directory
    module_function :create_dir

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
    def create_file(relative_path, *args, **options, &block)
      content = block_given? ? block[] : args.join

      CreateFile.new(self, relative_path, content, options).call
    end
    module_function :create_file

    alias add_file create_file
    module_function :add_file

    # Copy file from the relative source to the relative
    # destination running it through ERB.
    #
    # @example
    #   copy_file 'templates/test.rb', 'app/test.rb'
    #
    # @example
    #   vars = OpenStruct.new
    #   vars[:name] = 'foo'
    #   copy_file 'templates/%name%.rb', 'app/%name%.rb', context: vars
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
    def copy_file(source_path, *args, **options, &block)
      dest_path = (args.first || source_path).sub(/\.erb$/, '')

      ctx = if (vars = options[:context])
              vars.instance_eval('binding')
            else
              instance_eval('binding')
            end

      create_file(dest_path, options) do
        template = ERB.new(::File.binread(source_path), nil, "-", "@output_buffer")
        content = template.result(ctx)
        content = block[content] if block
        content
      end
      return unless options[:preserve]
      copy_metadata(source_path, dest_path, options)
    end
    module_function :copy_file

    # Copy file metadata
    #
    # @param [String] src_path
    #   the source file path
    # @param [String] dest_path
    #   the destination file path
    #
    # @api public
    def copy_metadata(src_path, dest_path, **options)
      stats = ::File.lstat(src_path)
      ::File.utime(stats.atime, stats.mtime, dest_path)
      chmod(dest_path, stats.mode, options)
    end
    module_function :copy_metadata

    # Copy directory recursively from source to destination path
    #
    # Any files names wrapped within % sign will be expanded by
    # executing corresponding method and inserting its value.
    # Assuming the following directory structure:
    #
    #  app/
    #    %name%.rb
    #    command.rb.erb
    #    README.md
    #
    #  Invoking:
    #    copy_directory("app", "new_app")
    #  The following directory structure should be created where
    #  name resolves to 'cli' value:
    #
    #  new_app/
    #    cli.rb
    #    command.rb
    #    README
    #
    # @param [Hash[Symbol]] options
    # @option options [Symbol] :preserve
    #   If true, the owner, group, permissions and modified time
    #   are preserved on the copied file, defaults to false.
    # @option options [Symbol] :recursive
    #   If false, copies only top level files, defaults to true.
    # @option options [Symbol] :exclude
    #   A regex that specifies files to ignore when copying.
    #
    # @example
    #   copy_directory("app", "new_app", recursive: false)
    #   copy_directory("app", "new_app", exclude: /docs/)
    #
    # @api public
    def copy_directory(source_path, *args, **options, &block)
      check_path(source_path)
      source = escape_glob_path(source_path)
      dest_path = args.first || source
      opts = {recursive: true}.merge(options)
      pattern = opts[:recursive] ? ::File.join(source, '**') : source
      glob_pattern = ::File.join(pattern, '*')

      Dir.glob(glob_pattern, ::File::FNM_DOTMATCH).sort.each do |file_source|
        next if ::File.directory?(file_source)
        next if opts[:exclude] && file_source.match(opts[:exclude])

        dest = ::File.join(dest_path, file_source.gsub(source_path, '.'))
        file_dest = ::Pathname.new(dest).cleanpath.to_s

        copy_file(file_source, file_dest, **options, &block)
      end
    end
    module_function :copy_directory

    alias copy_dir copy_directory
    module_function :copy_dir

    # Diff files line by line
    #
    # @param [String] path_a
    # @param [String] path_b
    # @param [Hash[Symbol]] options
    # @option options [Symbol] :format
    #   the diffining output format
    # @option options [Symbol] :context_lines
    #   the number of extra lines for the context
    # @option options [Symbol] :threshold
    #   maximum file size in bytes
    #
    # @example
    #   diff(file_a, file_b, format: :old)
    #
    # @api public
    def diff(path_a, path_b, **options)
      threshold = options[:threshold] || 10_000_000
      output = ''

      open_tempfile_if_missing(path_a) do |file_a|
        if ::File.size(file_a) > threshold
          raise ArgumentError, "(file size of #{file_a.path} exceeds #{threshold} bytes, diff output suppressed)"
        end
        if binary?(file_a)
          raise ArgumentError, "(#{file_a.path} is binary, diff output suppressed)"
        end
        open_tempfile_if_missing(path_b) do |file_b|
          if binary?(file_b)
            raise ArgumentError, "(#{file_a.path} is binary, diff output suppressed)"
          end
          if ::File.size(file_b) > threshold
            return "(file size of #{file_b.path} exceeds #{threshold} bytes, diff output suppressed)"
          end

          log_status(:diff, "#{file_a.path} - #{file_b.path}",
                     options.fetch(:verbose, true), :green)
          return output if options[:noop]

          block_size = file_a.lstat.blksize
          while !file_a.eof? && !file_b.eof?
            output << Differ.new(file_a.read(block_size),
                                 file_b.read(block_size),
                                 options).call
          end
        end
      end
      output
    end
    module_function :diff

    alias diff_files diff
    module_function :diff_files

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
    def download_file(uri, *args, **options, &block)
      dest_path = args.first || ::File.basename(uri)

      unless uri =~ %r{^https?\://}
        copy_file(uri, dest_path, options)
        return
      end

      content = DownloadFile.new(uri, dest_path, options).call

      if block_given?
        content = (block.arity.nonzero? ? block[content] : block[])
      end

      create_file(dest_path, content, options)
    end
    module_function :download_file

    alias get_file download_file
    module_function :get_file

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
    def prepend_to_file(relative_path, *args, **options, &block)
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
    def append_to_file(relative_path, *args, **options, &block)
      log_status(:append, relative_path, options.fetch(:verbose, true), :green)
      options.merge!(after: /\z/, verbose: false)
      inject_into_file(relative_path, *(args << options), &block)
    end
    module_function :append_to_file

    alias add_to_file append_to_file
    module_function :add_to_file

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
    def inject_into_file(relative_path, *args, **options, &block)
      replacement = block_given? ? block[] : args.join

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
    module_function :insert_into_file

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
    def replace_in_file(relative_path, *args, **options, &block)
      check_path(relative_path)
      contents    = IO.read(relative_path)
      replacement = (block ? block[] : args[1..-1].join).gsub('\0', '')

      log_status(:replace, relative_path, options.fetch(:verbose, true), :green)

      return if options[:noop]

      if options[:force] || !contents.include?(replacement)
        if !contents.gsub!(*args, &block)
          find = args[0]
          raise "#{find.inspect} not found in #{relative_path}"
        end
        ::File.open(relative_path, 'wb') do |file|
          file.write(contents)
        end
      end
    end
    module_function :replace_in_file

    alias gsub_file replace_in_file
    module_function :gsub_file

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
    def remove_file(relative_path, *args, **options)
      log_status(:remove, relative_path, options.fetch(:verbose, true), :red)

      return if options[:noop]

      ::FileUtils.rm_r(relative_path, force: options[:force], secure: true)
    end
    module_function :remove_file

    # Escape glob character in a path
    #
    # @param [String] path
    #   the path to escape
    #
    # @example
    #   escape_glob_path("foo[bar]") => "foo\\[bar\\]"
    #
    # @return [String]
    #
    # @api public
    def escape_glob_path(path)
      path.gsub(/[\\\{\}\[\]\*\?]/) { |x| "\\" + x }
    end
    module_function :escape_glob_path

    # Check if path exists
    #
    # @param [String] path
    #
    # @raise [ArgumentError]
    #
    # @api private
    def check_path(path)
      return if ::File.exist?(path)
      raise InvalidPathError, "File path \"#{path}\" does not exist."
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
    private_module_function :log_status

    # If content is not a path to a file, create a
    # tempfile and open it instead.
    #
    # @param [String] object
    #   a path to file or content
    #
    # @api private
    def open_tempfile_if_missing(object, &block)
      if ::FileTest.file?(object)
        ::File.open(object, &block)
      else
        tempfile = Tempfile.new('tty-file-diff')
        tempfile << object
        tempfile.rewind

        block[tempfile]

        unless tempfile.nil?
          tempfile.close
          tempfile.unlink
        end
      end
    end
    private_module_function :open_tempfile_if_missing
  end # File
end # TTY
