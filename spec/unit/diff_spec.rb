# encoding: utf-8

RSpec.describe TTY::File, '#diff' do
  it "diffs two files" do
    file_a = tmp_path('diff/file_a')
    file_b = tmp_path('diff/file_b')

    diff = TTY::File.diff(file_a, file_b, verbose: false)

    expect(diff).to eq(strip_heredoc(<<-EOS
      @@ -1,4 +1,4 @@
       aaa
      -bbb
      +xxx
       ccc
    EOS
    ))
  end

  it "diffs identical files" do
    src_a = tmp_path('diff/file_a')

    expect(TTY::File.diff(src_a, src_a, verbose: false)).to eq('')
  end

  it "diffs a file and a string" do
    src_a = tmp_path('diff/file_a')
    src_b = "aaa\nxxx\nccc\n"

    diff = TTY::File.diff(src_a, src_b, verbose: false)

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

    diff = TTY::File.diff(file_a, file_b, verbose: false)

    expect(diff).to eq(strip_heredoc(<<-EOS
      @@ -1,4 +1,4 @@
       aaa
      -bbb
      +xxx
       ccc
    EOS
    ))
  end

  it "doesn't diff large files" do
    file_a = tmp_path('diff/file_a')
    file_b = tmp_path('diff/file_b')

    diff = TTY::File.diff(file_a, file_b, threshold: 10)

    expect(diff).to eq('(file sizes exceed 10 bytes, diff output suppressed)')
  end

  it "logs status" do
    file_a = tmp_path('diff/file_a')
    file_b = tmp_path('diff/file_b')

    expect {
      TTY::File.diff(file_a, file_b, verbose: true)
    }.to output(%r{diff(.*)/diff/file_a(.*)/diff/file_b}).to_stdout_from_any_process
  end

  it "doesn't diff files when :noop option is given" do
    file_a = tmp_path('diff/file_a')
    file_b = tmp_path('diff/file_b')

    diff = TTY::File.diff(file_a, file_b, verbose: false, noop: true)

    expect(diff).to eq('')
  end
end
