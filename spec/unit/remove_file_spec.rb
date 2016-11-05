# encoding: utf-8

RSpec.describe TTY::File, '#remove_file' do
  it "removes a given file" do
    src_path = tmp_path('Gemfile')

    TTY::File.remove_file(src_path, verbose: false)

    expect(::File.exist?(src_path)).to be(false)
  end

  it "removes a directory" do
    src_path = tmp_path('templates')

    TTY::File.remove_file(src_path, verbose: false)

    expect(::File.exist?(src_path)).to be(false)
  end

  it "pretends removing file" do
    src_path = tmp_path('Gemfile')

    TTY::File.remove_file(src_path, noop: true, verbose: false)

    expect(::File.exist?(src_path)).to be(true)
  end

  it "logs status" do
    src_path = tmp_path('Gemfile')

    expect {
      TTY::File.remove_file(src_path, noop: true)
    }.to output(/remove(.*)Gemfile/).to_stdout_from_any_process
  end
end
