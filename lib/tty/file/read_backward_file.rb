# frozen_string_literal: true

class ReadBackwardFile
  attr_reader :file,
              :chunk_size

  # Create a ReadBackwardFile
  #
  # @param [File] file
  #   the file to read backward from
  # @param [Integer] chunk_size
  #   the chunk size used to step through the file backwards
  #
  # @api public
  def initialize(file, chunk_size = 512)
    @file        = file
    @chunk_size  = chunk_size
    @file_size   = ::File.stat(file).size
  end

  # Read file in chunks
  #
  # @yield [String]
  #   the chunk from file content
  #
  # @api public
  def each_chunk
    file.seek(0, IO::SEEK_END)
    while file.tell > 0
      if file.tell < @chunk_size # don't read beyond file size
        @chunk_size = file.tell
      end
      file.seek(-@chunk_size, IO::SEEK_CUR)
      chunk = file.read(@chunk_size)
      yield(chunk)
      file.seek(-@chunk_size, IO::SEEK_CUR)
    end
  end
end # ReadBackwardFile
