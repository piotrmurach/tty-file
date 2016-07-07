# encoding: utf-8

RSpec.describe TTY::File, '#diff' do
  before do
    FileUtils.rm_rf(tmp_path)
    FileUtils.cp_r(fixtures_path, tmp_path)
  end

  it "diffs two files" do
    file_a = ::File.open(::File.join(tmp_path, 'diff/file_a'))
    file_b = ::File.open(::File.join(tmp_path, 'diff/file_b'))

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
