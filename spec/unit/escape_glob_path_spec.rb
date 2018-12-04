# frozen_string_literal: true

RSpec.describe TTY::File, '#escape_glob_path' do
  {
    "foo?" => "foo\\?",
    "*foo" => "\\*foo",
    "foo[bar]" => "foo\\[bar\\]",
    "foo{bar}" => "foo\\{bar\\}"
  }.each do |glob, escaped_glob|
    it "escapes #{glob} to #{escaped_glob}" do
      expect(TTY::File.escape_glob_path(glob)).to eq(escaped_glob)
    end
  end
end
