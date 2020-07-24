# frozen_string_literal: true

require_relative "../lib/tty-file"

content = <<-EOS
aaaaa
bbbbb
xxxxx

ddddd
eeeee
fffff
yyyyy
EOS

file_a = ::File.join(File.dirname(__FILE__), "file-a")

TTY::File.create_file(file_a, content)
