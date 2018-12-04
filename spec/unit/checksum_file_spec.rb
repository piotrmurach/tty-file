# frozen_string_literal: true

RSpec.describe TTY::File, '#checksum_file' do
  it "generates checksum for a file" do
    file = tmp_path('checksum/README.md')

    checksum = TTY::File.checksum_file(file)
    expected = '76ba1beb6c611fa32624ed253444138cdf23eb938a3812137f8a399c5b375bfe'

    expect(checksum).to eq(expected)
  end

  it "generates checksum for IO object" do
    io = StringIO.new("Some content\nThe end")

    checksum = TTY::File.checksum_file(io, 'md5')
    expected = "ad0962e2374b1899fcfb818896703e50"

    expect(checksum).to eq(expected)
  end

  it "generates checksum for String" do
    string = "Some content\nThe end"

    checksum = TTY::File.checksum_file(string, 'sha1')
    expected = "289388f187404135e6c15b21460442cf867180dd"

    expect(checksum).to eq(expected)
  end

  it "doesn't digest when :noop option" do
    digester = double(:digester)
    allow(TTY::File::DigestFile).to receive(:new).and_return(digester)

    TTY::File.checksum_file('string', noop: true)

    expect(digester).to_not receive(:call)
  end
end
