# frozen_string_literal: true

RSpec.describe TTY::File, '#binary?' do
  let(:ascii) { "This is a text file.\nWith more than one line.\nAnd a \tTab.\nAnd other printable chars too: ~!@\#$%^&*()`:\"<>?{}|_+,./;'[]\\-=\n" }

  let(:utf_8) { "Testing utf-8 unicode...\n\n\non a new line: \xE2\x80\x93\n" }

  let(:latin_1) { "Testing latin chars...\nsuch as #{0xFD.chr}mlaut.\n" }

  let(:shift_jis) { "And some kanjis:\n #{0x83.chr}#{0x80.chr}.\n" }

  it "identifies zero-length file as non-binary" do
    Tempfile.open('tty-file-binary-spec') do |file|
      expect(TTY::File.binary?(file)).to eq(false)
    end
  end

  it "indentifies text with hex as binary" do
    Tempfile.open('tty-file-binary-spec') do |file|
      file << "hi \xAD"
      file.close

      expect(TTY::File.binary?(file)).to eq(true)
    end
  end

  it "identifies image as binary" do
    file = tmp_path('blackhole.png')

    expect(TTY::File.binary?(file)).to eq(true)
  end

  it "indetifies text file as non-binary" do
    file = tmp_path('Gemfile')

    expect(TTY::File.binary?(file)).to eq(false)
  end

  it "indetifies a null-terminated string file as binary" do
    Tempfile.open('tty-file-binary-spec') do |file|
      file.write("Binary content.\0")
      file.close

      expect(TTY::File.binary?(file)).to eq(true)
    end
  end

  it "indetifies a null-terminated multi-line string file as binary" do
    Tempfile.open('tty-file-binary-spec') do |file|
      file.write("Binary content.\non manylnes\nreally\0")
      file.close

      expect(TTY::File.binary?(file)).to eq(true)
    end
  end

  context "when the default external encoding is UTF-8" do
    before do
      @saved_verbosity =  $VERBOSE
      @saved_encoding = Encoding.default_external
      $VERBOSE = nil
      Encoding.default_external = Encoding::UTF_8
    end

    after do
      Encoding.default_external = @saved_encoding
      $VERBOSE = @saved_verbosity
    end

    it "identifies ASCII as non-binary" do
      Tempfile.open('tty-file-binary-spec') do |file|
        file << ascii
        file.close

        expect(TTY::File.binary?(file)).to eq(false)
      end
    end

    it "identifies UTF-8 as non-binary" do
      Tempfile.open('tty-file-binary-spec') do |file|
        file << utf_8
        file.close

        expect(TTY::File.binary?(file)).to eq(false)
      end
    end

    it "indentifies Latin-1 as invalid UTF-8 and hence as binary" do
      Tempfile.open('tty-file-binary-spec') do |file|
        file << latin_1
        file.close

        expect(TTY::File.binary?(file)).to eq(true)
      end
    end

    it "identifies Shift-JIS as invalid UTF-8 and hence as binary" do
      Tempfile.open('tty-file-binary-spec') do |file|
        file << shift_jis
        file.close

        expect(TTY::File.binary?(file)).to eq(true)
      end
    end
  end

  context "when the default external encoding is Latin-1" do
    before do
      @saved_verbosity =  $VERBOSE
      @saved_encoding = Encoding.default_external
      $VERBOSE = nil
      Encoding.default_external = Encoding::ISO_8859_1
    end

    after do
      Encoding.default_external = @saved_encoding
      $VERBOSE = @saved_verbosity
    end

    it "identifies ASCII as non-binary" do
      Tempfile.open('tty-file-binary-spec') do |file|
        file << ascii
        file.close

        expect(TTY::File.binary?(file)).to eq(false)
      end
    end

    it "identifies UTF-8 as invalid Latin-1 and hence binary" do
      Tempfile.open('tty-file-binary-spec') do |file|
        file << utf_8
        file.close

        expect(TTY::File.binary?(file)).to eq(true)
      end
    end

    it "indentifies Latin-1 as non-binary" do
      Tempfile.open('tty-file-binary-spec') do |file|
        file << latin_1
        file.close

        expect(TTY::File.binary?(file)).to eq(false)
      end
    end

    it "identifies Shift-JIS as invalid Latin-1 and hence as binary" do
      Tempfile.open('tty-file-binary-spec') do |file|
        file << shift_jis
        file.close

        expect(TTY::File.binary?(file)).to eq(true)
      end
    end
  end

  context "when the default external encoding is Shift-JIS" do
    before do
      @saved_verbosity =  $VERBOSE
      @saved_encoding = Encoding.default_external
      $VERBOSE = nil
      Encoding.default_external = Encoding::SHIFT_JIS
    end

    after do
      Encoding.default_external = @saved_encoding
      $VERBOSE = @saved_verbosity
    end

    it "identifies ASCII as non-binary" do
      Tempfile.open('tty-file-binary-spec') do |file|
        file << ascii
        file.close

        expect(TTY::File.binary?(file)).to eq(false)
      end
    end

    it "identifies UTF-8 as invalid Shift-JIS and hence as binary" do
      Tempfile.open('tty-file-binary-spec') do |file|
        file << utf_8
        file.close

        expect(TTY::File.binary?(file)).to eq(true)
      end
    end

    it "indentifies Latin-1 as invalid Shift-JIS and hence as binary" do
      Tempfile.open('tty-file-binary-spec') do |file|
        file << latin_1
        file.close

        expect(TTY::File.binary?(file)).to eq(true)
      end
    end

    it "identifies Shift-JIS as non-binary" do
      Tempfile.open('tty-file-binary-spec') do |file|
        file << shift_jis
        file.close

        expect(TTY::File.binary?(file)).to eq(false)
      end
    end
  end
end
