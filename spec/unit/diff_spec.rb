# frozen_string_literal: true

RSpec.describe TTY::File, "#diff" do
  shared_context "diffing files" do
    it "diffs two files" do
      file_a = path_factory.call("diff/file_a")
      file_b = path_factory.call("diff/file_b")

      diff = TTY::File.diff(file_a, file_b, verbose: false)

      expect(diff).to eq(strip_heredoc(<<-EOS
        --- #{file_a}
        +++ #{file_b}
        \e[36m@@ -1,4 +1,4 @@\e[0m
         aaa
        \e[31m-bbb\e[0m
        \e[32m+xxx\e[0m
         ccc
      EOS
      ))
    end

    it "diffs identical files" do
      src_a = path_factory.call("diff/file_a")

      expect(TTY::File.diff(src_a, src_a, verbose: false)).
        to eq("No differences found\n")
    end

    it "diffs a file and a string" do
      src_a = path_factory.call("diff/file_a")
      src_b = "aaa\nxxx\nccc\n"

      diff = TTY::File.diff(src_a, src_b, verbose: false)

      expect(diff).to eq(strip_heredoc(<<-EOS
        --- #{src_a}
        +++ New contents
        \e[36m@@ -1,4 +1,4 @@\e[0m
         aaa
        \e[31m-bbb\e[0m
        \e[32m+xxx\e[0m
         ccc
      EOS
      ))
    end

    it "diffs two strings" do
      file_a = "aaa\nbbb\nccc\n"
      file_b = "aaa\nxxx\nccc\n"

      diff = TTY::File.diff(file_a, file_b, verbose: false, color: false)

      expect(diff).to eq(strip_heredoc(<<-EOS
        --- Old contents
        +++ New contents
        @@ -1,4 +1,4 @@
         aaa
        -bbb
        +xxx
         ccc
      EOS
      ))
    end

    it "logs status" do
      file_a = path_factory.call("diff/file_a")
      file_b = path_factory.call("diff/file_b")

      expect {
        TTY::File.diff_files(file_a, file_b, verbose: true)
      }.to output(%r{diff(.*)/diff/file_a(.*)/diff/file_b}).to_stdout_from_any_process
    end

    it "doesn't diff files when :noop option is given" do
      file_a = path_factory.call("diff/file_a")
      file_b = path_factory.call("diff/file_b")

      diff = TTY::File.diff(file_a, file_b, verbose: false, noop: true)

      expect(diff).to eq("")
    end

    it "doesn't diff if first file is too large" do
      file_a = path_factory.call("diff/file_a")
      file_b = path_factory.call("diff/file_b")

      diff = TTY::File.diff(file_a, file_b, threshold: 10)

      expect(diff).to match(/file size of (.*) exceeds 10 bytes/)
    end

    it "doesn't diff binary files" do
      file_a = path_factory.call("blackhole.png")
      file_b = path_factory.call("diff/file_b")

      diff = TTY::File.diff(file_a, file_b)

      expect(diff).to match(/is binary, diff output suppressed/)
    end
  end

  context "when passed String instances for the file arguments" do
    let(:path_factory) { method(:tmp_path) }

    include_context "diffing files"
  end

  context "when passed Pathname instances for the file arguments" do
    let(:path_factory) { method(:tmp_pathname) }

    include_context "diffing files"
  end
end
