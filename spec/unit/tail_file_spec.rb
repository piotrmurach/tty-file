# frozen_string_literal: true

RSpec.shared_context '#tail_file' do
  it "tails file for lines with chunks smaller than file size" do
    file = path_factory.call('tail/lines')

    lines = TTY::File.tail_file(file, 5, chunk_size: 2**3)

    expect(lines).to eq([
      "line12",
      "line13",
      "line14",
      "line15",
      "line16"
    ])
  end

  it "tails file for lines with chunks equal file size" do
    file = path_factory.call('tail/lines')

    lines = TTY::File.tail_file(file, 5, chunk_size: file.size)

    expect(lines).to eq([
      "line12",
      "line13",
      "line14",
      "line15",
      "line16"
    ])

  end

  it "tails file for lines with chunks larger than file size" do
    file = path_factory.call('tail/lines')

    lines = TTY::File.tail_file(file, 5, chunk_size: 2**9)

    expect(lines).to eq([
      "line12",
      "line13",
      "line14",
      "line15",
      "line16"
    ])
  end

  it "tails file and yields lines" do
    file = path_factory.call('tail/lines')
    lines = []

    TTY::File.tail_file(file, 5, chunk_size: 8) do |line|
      lines << line
    end

    expect(lines).to eq([
      "line12",
      "line13",
      "line14",
      "line15",
      "line16"
    ])
  end
end

module TTY::File
  RSpec.describe "#tail_file" do
    context "when passed a String instance for the file argument" do
      let(:path_factory) { method(:tmp_path) }

      it_behaves_like "#tail_file"
    end

    context "when passed a Pathname instance for the file argument" do
      let(:path_factory) { method(:tmp_pathname) }

      it_behaves_like "#tail_file"
    end
  end
end
