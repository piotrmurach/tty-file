# frozen_string_literal: true

require_relative "../lib/tty-file"

file_a = ::File.join(__dir__, "file-a")
file_b = ::File.join(__dir__, "file-b")
print TTY::File.diff(file_a, file_b)
