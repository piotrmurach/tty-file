# encoding: utf-8

RSpec.describe TTY::File, '#diff' do
  it "diffs two files" do
    file_a = ::File.open(tmp_path('diff/file_a'))
    file_b = ::File.open(tmp_path('diff/file_b'))

    diff = TTY::File.diff(file_a, file_b)

    expect(diff).to eq(strip_heredoc(<<-EOS
      @@ -1,4 +1,4 @@
       aaa
      -bbb
      +xxx
       ccc
    EOS
    ))
  end

  it "diffs two strings" do
    file_a = "aaa\nbbb\nccc\n"
    file_b = "aaa\nxxx\nccc\n"

    diff = TTY::File.diff(file_a, file_b)

    expect(diff).to eq(strip_heredoc(<<-EOS
      @@ -1,4 +1,4 @@
       aaa
      -bbb
      +xxx
       ccc
    EOS
    ))
  end
end
