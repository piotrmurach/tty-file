# encoding: utf-8

require 'stringio'
require 'openssl'

module TTY
  module File
    class DigestFile
      attr_reader :source

      def initialize(source, mode, options)
        @source = source
        @digest = OpenSSL::Digest.new(mode)
      end

      def call
        if ::FileTest.file?(source.to_s)
          ::File.open(source, 'rb') { |f| checksum_io(f, @digest) }
        else
          non_file = source
          if non_file.is_a?(String)
            non_file = StringIO.new(non_file)
          end
          if non_file.is_a?(StringIO)
            checksum_io(non_file, @digest)
          end
        end
      end

      def checksum_io(io, digest)
        while (chunk = io.read(1024 * 8))
          digest << chunk
        end
        digest.hexdigest
      end
    end # DigestFile
  end # File
end # TTY
