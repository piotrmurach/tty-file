# frozen_string_literal: true

RSpec.describe TTY::File, '#replace_in_file' do
  it "replaces file content with a matching string" do
    file = tmp_path('Gemfile')
    status = nil
    expect {
      status = TTY::File.replace_in_file(file, /gem 'rails'/, "gem 'hanami'")
    }.to output(/replace/).to_stdout_from_any_process

    expect(status).to eq(true)
    expect(File.read(file)).to eq([
      "gem 'nokogiri'\n",
      "gem 'hanami', '5.0.0'\n",
      "gem 'rack', '>=1.0'\n"
    ].join)
  end

  it "replaces file content with a matching block value" do
    file = tmp_path('Gemfile')
    status = nil
    expect {
      status =TTY::File.replace_in_file(file, /gem 'rails'/, verbose: false) do |match|
        match = "gem 'hanami'"
      end
    }.to_not output(/replace/).to_stdout_from_any_process

    expect(status).to eq(true)
    expect(File.read(file)).to eq([
      "gem 'nokogiri'\n",
      "gem 'hanami', '5.0.0'\n",
      "gem 'rack', '>=1.0'\n"
    ].join)
  end

  it "doesn't match file content" do
    file = tmp_path('Gemfile')
    content = ::File.read(file)
    status = TTY::File.replace_in_file(file, /unknown/, 'Hello', verbose: false)

    expect(status).to eq(false)
    expect(::File.read(file)).to eq(content)
  end

  it "silences verbose output" do
    content = "gem 'hanami'"
    file = tmp_path('Gemfile')
    expect {
      TTY::File.replace_in_file(file, /gem 'rails'/, content, verbose: false)
    }.to_not output(/replace/).to_stdout_from_any_process
  end

  it "fails to replace content when missing correct file path" do
    expect {
      TTY::File.replace_in_file('/non-existent-path',
        /gem 'rails'/, "gem 'hanami'", verbose: false)
    }.to raise_error(ArgumentError, /File path (.)* does not exist/)
  end

  it "logs action" do
    content = "gem 'hanami'"
    file = tmp_path('Gemfile')

    expect {
      TTY::File.replace_in_file(file, /gem 'rails'/, content, noop: true)
    }.to output(/\e\[32mreplace\e\[0m(.*)Gemfile/).to_stdout_from_any_process
  end

  it "logs action without color" do
    content = "gem 'hanami'"
    file = tmp_path('Gemfile')

    expect {
      TTY::File.replace_in_file(file, /gem 'rails'/, content,
                                noop: true, color: false)
    }.to output(/\s+replace(.*)Gemfile/).to_stdout_from_any_process
  end

  it "allows for noop run" do
    content = "gem 'hanami'"
    file = tmp_path('Gemfile')

    TTY::File.replace_in_file(file, /gem 'rails'/, content,
                              noop: true, verbose: false)

    expect(File.read(file)).to eq([
      "gem 'nokogiri'\n",
      "gem 'rails', '5.0.0'\n",
      "gem 'rack', '>=1.0'\n"
    ].join)
  end

  it "doesn't replace content when no match found" do
    content = "gem 'hanami'"
    file = tmp_path('Gemfile')

    status = TTY::File.gsub_file(file, /gem 'rails'/, content, verbose: false)
    expect(status).to eq(true)
    expect(File.read(file)).to eq([
      "gem 'nokogiri'\n",
      "gem 'hanami', '5.0.0'\n",
      "gem 'rack', '>=1.0'\n"
    ].join)

    status = TTY::File.gsub_file(file, /gem 'rails'/, content, verbose: false)
    expect(status).to eq(false)

    expect(File.read(file)).to eq([
      "gem 'nokogiri'\n",
      "gem 'hanami', '5.0.0'\n",
      "gem 'rack', '>=1.0'\n"
    ].join)
  end

  it "replaces with multibyte content" do
    content = "gem 'ようこそ'"
    file = tmp_path('Gemfile')

    TTY::File.gsub_file(file, /gem 'rails'/, content, verbose: false)
    expect(File.open(file, 'r:UTF-8', &:read)).to eq([
      "gem 'nokogiri'\n",
      "#{content}, '5.0.0'\n",
      "gem 'rack', '>=1.0'\n"
    ].join)
  end
end
