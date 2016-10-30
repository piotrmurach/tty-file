# encoding: utf-8

RSpec.describe TTY::File, '#append_to_file' do
  it "appends to file" do
    file = tmp_path('Gemfile')
    TTY::File.append_to_file(file, "gem 'tty'", verbose: false)
    expect(File.read(file)).to eq([
      "gem 'nokogiri'\n",
      "gem 'rails', '5.0.0'\n",
      "gem 'rack', '>=1.0'\n",
      "gem 'tty'"
    ].join)
  end

  it "appends multiple lines to file" do
    file = tmp_path('Gemfile')
    TTY::File.append_to_file(file, "gem 'tty'\n", "gem 'rake'", verbose: false)
    expect(File.read(file)).to eq([
      "gem 'nokogiri'\n",
      "gem 'rails', '5.0.0'\n",
      "gem 'rack', '>=1.0'\n",
      "gem 'tty'\n",
      "gem 'rake'"
    ].join)
  end

  it "appends content in a block" do
    file = tmp_path('Gemfile')
    TTY::File.append_to_file(file, verbose: false) { "gem 'tty'"}
    expect(File.read(file)).to eq([
      "gem 'nokogiri'\n",
      "gem 'rails', '5.0.0'\n",
      "gem 'rack', '>=1.0'\n",
      "gem 'tty'"
    ].join)
  end

  it "logs action" do
    file = tmp_path('Gemfile')
    expect {
      TTY::File.append_to_file(file, "gem 'tty'")
    }.to output(/append.*Gemfile/).to_stdout_from_any_process
  end
end
