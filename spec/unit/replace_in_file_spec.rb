# encoding: utf-8

RSpec.describe TTY::File, '#replace_in_file' do
  before do
    FileUtils.rm_rf(tmp_path)
    FileUtils.cp_r(fixtures_path, tmp_path)
  end

  it "replaces file content" do
    content = "gem 'hanami'"
    file = File.join(tmp_path, 'Gemfile')
    expect {
      TTY::File.replace_in_file(file, /gem 'rails'/, content)
    }.to output(/replace/).to_stdout_from_any_process
    expect(File.read(file)).to eq([
      "gem 'nokogiri'\n",
      "gem 'hanami', '5.0.0'\n",
      "gem 'rack', '>=1.0'\n"
    ].join)
  end

  it "replaces file content in block" do
    file = File.join(tmp_path, 'Gemfile')
    expect {
      TTY::File.replace_in_file(file, /gem 'rails'/, verbose: false) do |match|
        match = "gem 'hanami'"
      end
    }.to_not output(/replace/).to_stdout_from_any_process
    expect(File.read(file)).to eq([
      "gem 'nokogiri'\n",
      "gem 'hanami', '5.0.0'\n",
      "gem 'rack', '>=1.0'\n"
    ].join)
  end

  it "doesn't match file content" do
    content = 'content'
    file = File.join(tmp_path, 'Gemfile')
    expect {
      TTY::File.replace_in_file(file, /unknown/, content, verbose: false)
    }.to raise_error(RuntimeError, /\/unknown\/ not found in/)
  end

  it "silences verbose output" do
    content = "gem 'hanami'"
    file = File.join(tmp_path, 'Gemfile')
    expect {
      TTY::File.replace_in_file(file, /gem 'rails'/, content, verbose: false)
    }.to_not output(/replace/).to_stdout_from_any_process
  end

  it "fails to replace non existent file" do
    expect {
      TTY::File.replace_in_file('/non-existent-path',
        /gem 'rails'/, "gem 'hanami'", verbose: false)
    }.to raise_error(ArgumentError, /File path (.)* does not exist/)
  end

  it "allows for noop run" do
    content = "gem 'hanami'"
    file = File.join(tmp_path, 'Gemfile')
    expect {
      TTY::File.replace_in_file(file, /gem 'rails'/, content, noop: true)
    }.to output(/replace/).to_stdout_from_any_process

    expect(File.read(file)).to eq([
      "gem 'nokogiri'\n",
      "gem 'rails', '5.0.0'\n",
      "gem 'rack', '>=1.0'\n"
    ].join)
  end

  it "doesn't replace content if already present" do
    content = "gem 'hanami'"
    file = File.join(tmp_path, 'Gemfile')
    TTY::File.replace_in_file(file, /gem 'rails'/, content, verbose: false)
    expect(File.read(file)).to eq([
      "gem 'nokogiri'\n",
      "gem 'hanami', '5.0.0'\n",
      "gem 'rack', '>=1.0'\n"
    ].join)

    TTY::File.replace_in_file(file, /gem 'rails'/, content, verbose: false)
    expect(File.read(file)).to eq([
      "gem 'nokogiri'\n",
      "gem 'hanami', '5.0.0'\n",
      "gem 'rack', '>=1.0'\n"
    ].join)
  end
end
