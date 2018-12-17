# frozen_string_literal: true

if ENV['COVERAGE'] || ENV['TRAVIS']
  require 'simplecov'
  require 'coveralls'

  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::HTMLFormatter,
    Coveralls::SimpleCov::Formatter
  ]

  SimpleCov.start do
    command_name 'spec'
    add_filter 'spec'
  end
end

require 'tty/file'
require 'find'
require "webmock/rspec"

module Helpers
  def gem_root
    ::File.join(File.dirname(__FILE__), "..")
  end

  def dir_path(*args)
    path = ::File.join(gem_root, *args)
    ::FileUtils.mkdir_p(path) unless ::File.exist?(path)
    ::File.realpath(path)
  end

  def fixtures_path(filename = nil)
    ::File.join(dir_path('spec', 'fixtures'), filename.to_s)
  end

  def tmp_path(filename = nil)
    ::File.join(dir_path('tmp'), filename.to_s)
  end

  def exists_and_identical?(source, dest)
    dest_path = tmp_path(dest)
    expect(::File.exist?(dest_path)).to be(true)

    source_path = fixtures_path(source)
    expect(::FileUtils).to be_identical(source_path, dest_path)
  end

  def strip_heredoc(content)
    indent = content.scan(/^[ \t]*(?=\S)/).min.size || 0
    content.gsub(/^[ \t]{#{indent}}/, '')
  end
end

RSpec.configure do |config|
  config.include(Helpers)

  config.before(:each) do
    FileUtils.cp_r(fixtures_path('/.'), tmp_path)
  end

  config.after(:each) do
    FileUtils.rm_rf(tmp_path)
  end

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  # Limits the available syntax to the non-monkey patched syntax that is recommended.
  config.disable_monkey_patching!

  # This setting enables warnings. It's recommended, but in some cases may
  # be too noisy due to issues in dependencies.
  config.warnings = true

  if config.files_to_run.one?
    config.default_formatter = 'doc'
  end

  config.profile_examples = 2

  config.order = :random

  Kernel.srand config.seed
end
