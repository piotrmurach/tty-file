# frozen_string_literal: true

RSpec.describe TTY::File, '#prepend_to_file' do
  it "appends to file" do
    file = tmp_path('Gemfile')
    result = TTY::File.prepend_to_file(file, "gem 'tty'\n", verbose: false)
    expect(result).to eq(true)
    expect(File.read(file)).to eq([
      "gem 'tty'\n",
      "gem 'nokogiri'\n",
      "gem 'rails', '5.0.0'\n",
      "gem 'rack', '>=1.0'\n",
    ].join)
  end

  it "prepends multiple lines to file" do
    file = tmp_path('Gemfile')
    TTY::File.prepend_to_file(file, "gem 'tty'\n", "gem 'rake'\n", verbose: false)
    expect(File.read(file)).to eq([
      "gem 'tty'\n",
      "gem 'rake'\n",
      "gem 'nokogiri'\n",
      "gem 'rails', '5.0.0'\n",
      "gem 'rack', '>=1.0'\n",
    ].join)
  end

  it "prepends content in a block" do
    file = tmp_path('Gemfile')
    TTY::File.prepend_to_file(file, verbose: false) { "gem 'tty'\n"}
    expect(File.read(file)).to eq([
      "gem 'tty'\n",
      "gem 'nokogiri'\n",
      "gem 'rails', '5.0.0'\n",
      "gem 'rack', '>=1.0'\n",
    ].join)
  end

  it "doesn't prepend if already present" do
    file = tmp_path('Gemfile')
    TTY::File.prepend_to_file(file, "gem 'nokogiri'\n", force: false, verbose: false)
    expect(::File.read(file)).to eq([
      "gem 'nokogiri'\n",
      "gem 'rails', '5.0.0'\n",
      "gem 'rack', '>=1.0'\n",
    ].join)
  end

  it "checks if a content can be safely prepended" do
    file = tmp_path('Gemfile')
    TTY::File.safe_prepend_to_file(file, "gem 'nokogiri'\n", verbose: false)
    expect(::File.read(file)).to eq([
      "gem 'nokogiri'\n",
      "gem 'rails', '5.0.0'\n",
      "gem 'rack', '>=1.0'\n",
    ].join)
  end

  it "doesn't prepend if already present for multiline content" do
    file = tmp_path('Gemfile')
    TTY::File.prepend_to_file(file, "gem 'nokogiri'\n", verbose: false)
    TTY::File.prepend_to_file(file, "gem 'nokogiri'\n", "gem 'nokogiri'\n", force: false, verbose: false)
    expect(::File.read(file)).to eq([
      "gem 'nokogiri'\n",
      "gem 'nokogiri'\n",
      "gem 'rails', '5.0.0'\n",
      "gem 'rack', '>=1.0'\n",
    ].join)
  end

  it "prepends multiple times if forced" do
    file = tmp_path('Gemfile')
    TTY::File.prepend_to_file(file, "gem 'nokogiri'\n", force: true, verbose: false)
    TTY::File.prepend_to_file(file, "gem 'nokogiri'\n", "gem 'nokogiri'\n", force: true, verbose: false)
    expect(::File.read(file)).to eq([
      "gem 'nokogiri'\n",
      "gem 'nokogiri'\n",
      "gem 'nokogiri'\n",
      "gem 'nokogiri'\n",
      "gem 'rails', '5.0.0'\n",
      "gem 'rack', '>=1.0'\n"
    ].join)
  end

  it "logs action" do
    file = tmp_path('Gemfile')
    expect {
      TTY::File.prepend_to_file(file, "gem 'tty'")
    }.to output(/\e\[32mprepend\e\[0m.*Gemfile/).to_stdout_from_any_process
  end

  it "logs action without color" do
    file = tmp_path('Gemfile')
    expect {
      TTY::File.prepend_to_file(file, "gem 'tty'", color: false)
    }.to output(/\s+prepend.*Gemfile/).to_stdout_from_any_process
  end
end
