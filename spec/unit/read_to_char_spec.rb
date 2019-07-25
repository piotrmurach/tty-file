# frozen_string_literal: true

RSpec.describe TTY::File, "#read_to_char" do
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

  it "reads file up to valid char", unless: RSpec::Support::OS.windows? do
    file = tmp_pathname("binary", "unicode.txt")
    bytes = 4096

    content = TTY::File.read_to_char(file, bytes)

    expect(content.bytesize).to eq(bytes + 2)
  end
end
