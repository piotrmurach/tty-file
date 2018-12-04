# frozen_string_literal: true
require 'ostruct'

RSpec.describe TTY::File, '#copy_file' do
  def exists_and_identical?(source, dest)
    dest_path = File.join(tmp_path, dest)
    expect(::File.exist?(dest_path)).to be(true)

    source_path = File.join(fixtures_path, source)
    expect(::FileUtils).to be_identical(source_path, dest_path)
  end

  it "copies file without destination" do
    src = tmp_path('Gemfile')

    TTY::File.copy_file(src, verbose: false)

    exists_and_identical?('Gemfile', 'Gemfile')
  end

  it "copies file to the destination" do
    src  = tmp_path('Gemfile')
    dest = tmp_path('app/Makefile')

    TTY::File.copy_file(src, dest, verbose: false)

    exists_and_identical?('Gemfile', 'app/Makefile')
  end

  it "copies file to existing destination" do
    src  = tmp_path('Gemfile')
    dest = tmp_path('app/Gemfile')

    TTY::File.copy_file(src, dest, verbose: false)

    exists_and_identical?('Gemfile', 'app/Gemfile')
  end

  it "copies file with block content" do
    src  = tmp_path('Gemfile')
    dest = tmp_path('app/Gemfile')

    TTY::File.copy_file(src, dest, verbose: false) do |content|
      "https://rubygems.org\n" + content
    end
    expect(File.read(dest)).to eq("https://rubygems.org\ngem 'nokogiri'\ngem 'rails', '5.0.0'\ngem 'rack', '>=1.0'\n")
  end

  it "copies file and preservs metadata" do
    src  = tmp_path('Gemfile')
    dest = tmp_path('app/Gemfile')

    expect {
      TTY::File.copy_file(src, dest, verbose: false, preserve: true)
    }.to output('').to_stdout_from_any_process

    expect(File.stat(src)).to eq(File.stat(dest))
  end

  it "doesn't copy file if :noop is true" do
    src  = tmp_path('Gemfile')
    dest = tmp_path('app/Gemfile')

    TTY::File.copy_file(src, dest, verbose: false, noop: true)

    expect(File.exist?(dest)).to eq(false)
  end

  it "logs status" do
    src  = tmp_path('Gemfile')
    dest = tmp_path('app/Gemfile')

    expect {
      TTY::File.copy_file(src, dest)
    }.to output(/\e\[32mcreate\e\[0m.*Gemfile/).to_stdout_from_any_process
  end

  it "logs status without color" do
    src  = tmp_path('Gemfile')
    dest = tmp_path('app/Gemfile')

    expect {
      TTY::File.copy_file(src, dest, color: false)
    }.to output(/\s+create.*Gemfile/).to_stdout_from_any_process
  end

  it "removes template .erb extension" do
    src = tmp_path('templates/application.html.erb')

    TTY::File.copy_file(src, verbose: false)

    exists_and_identical?('templates/application.html.erb',
                          'templates/application.html')
  end

  it "converts filename based on context" do
    src = tmp_path('templates/%file_name%.rb')
    dest = tmp_path('app/%file_name%.rb')

    variables = OpenStruct.new
    variables[:foo] = 'bar'
    variables[:file_name] = 'expected'

    TTY::File.copy_file(src, dest, context: variables, verbose: false)

    expected = tmp_path('app/expected.rb')
    expect(File.read(expected)).to eq("bar\n")
  end

  it "converts filename based on class context" do
    src  = tmp_path('templates/%file_name%.rb')
    dest = tmp_path('templates/expected.rb')

    stub_const('TestCase', Class.new {
      def foo
        'bar'
      end

      def file_name
        'expected'
      end
    })
    TestCase.send(:include, TTY::File)

    TestCase.new.send(:copy_file, src, verbose: false)

    expect(File.read(dest)).to eq("bar\n")
  end

  it "copies file with custom class context" do
    src  = tmp_path('templates/unit_test.rb')
    dest = tmp_path('test/unit_test.rb')

    stub_const('TestCase', Class.new {
      def self.class_name
        'Example'
      end
    })
    TestCase.extend(TTY::File)

    TestCase.send(:copy_file, src, dest, verbose: false)

    expect(File.read(dest)).to eq("class ExampleTest; end\n")
  end

  it "copies template with custom context binding" do
    src  = tmp_path('templates/unit_test.rb')
    dest = tmp_path('test/unit_test.rb')

    variables = OpenStruct.new
    variables[:class_name] = 'Example'

    TTY::File.copy_file(src, dest, context: variables, verbose: false)

    expect(File.read(dest)).to eq("class ExampleTest; end\n")
  end
end
