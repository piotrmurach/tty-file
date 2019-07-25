# frozen_string_literal: true

RSpec.describe TTY::File, "#read_to_char" do
  it "reads file up to valid char" do
    file = tmp_pathname("binary", "unicode.txt")
    bytes = 4096

    content = TTY::File.read_to_char(file, bytes)

    expect(content.bytesize).to eq(bytes + 2)
  end
end
