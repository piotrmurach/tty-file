# frozen_string_literal: true

RSpec.describe TTY::File::Differ, '#call' do
  it "diffs identical content" do
    string_a = "aaa bbb ccc"

    diff = TTY::File::Differ.new(string_a, string_a).call

    expect(diff).to eq('')
  end

  it "diffs two files with single line content" do
    string_a = "aaa bbb ccc"
    string_b = "aaa xxx ccc"

    diff = TTY::File::Differ.new(string_a, string_b).call

    expect(diff).to eq(strip_heredoc(<<-EOS
      @@ -1,2 +1,2 @@
      -aaa bbb ccc
      +aaa xxx ccc
    EOS
    ))
  end

  it "diffs two files with multi line content" do
    string_a = "aaa\nbbb\nccc\nddd\neee\nfff\nggg\nhhh\niii\njjj\nkkk\nlll\n"
    string_b = "aaa\nbbb\nzzz\nddd\neee\nfff\nggg\nhhh\niii\njjj\nwww\n"

    diff = TTY::File::Differ.new(string_a, string_b).call

    expect(diff).to eq(strip_heredoc(<<-EOS
      @@ -1,6 +1,6 @@
       aaa
       bbb
      -ccc
      +zzz
       ddd
       eee
       fff
      @@ -8,6 +8,5 @@
       hhh
       iii
       jjj
      -kkk
      -lll
      +www
    EOS
    ))
  end

  it "handles differently encoded files" do
    string_a = "wikipedia".encode('us-ascii')
    string_b = "ウィキペディア".encode('UTF-8')

    diff = TTY::File::Differ.new(string_a, string_b).call

    expect(diff).to eq(strip_heredoc(<<-EOS
      @@ -1,2 +1,2 @@
      -wikipedia
      +ウィキペディア
    EOS
    ))
  end

  it "accepts format" do
    string_a = "aaa\nbbb\nccc\n"
    string_b = "aaa\nxxx\nccc\n"

    diff = TTY::File::Differ.new(string_a, string_b, format: :old).call

    expect(diff).to eq(strip_heredoc(<<-EOS
      1,4c1,4
      < aaa
      < bbb
      < ccc
      ---
      > aaa
      > xxx
      > ccc

    EOS
    ))
  end

  it "accepts context lines" do
    string_a = "aaa\nbbb\nccc\nddd\neee\nfff"
    string_b = "aaa\nbbb\nccc\nddd\nxxx\nfff"

    diff = TTY::File::Differ.new(string_a, string_b, context_lines: 1).call

    expect(diff).to eq(strip_heredoc(<<-EOS
      @@ -4,3 +4,3 @@
       ddd
      -eee
      +xxx
       fff
    EOS
    ))
  end
end
