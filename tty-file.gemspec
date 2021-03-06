# frozen_string_literal: true

require_relative "lib/tty/file/version"

Gem::Specification.new do |spec|
  spec.name          = "tty-file"
  spec.version       = TTY::File::VERSION
  spec.authors       = ["Piotr Murach"]
  spec.email         = ["piotr@piotrmurach.com"]
  spec.summary       = %q{File manipulation utility methods.}
  spec.description   = %q{File manipulation utility methods.}
  spec.homepage      = "https://ttytoolkit.org"
  spec.license       = "MIT"

  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://rubygems.org"
    spec.metadata["bug_tracker_uri"] = "https://github.com/piotrmurach/tty-file/issues"
    spec.metadata["changelog_uri"] = "https://github.com/piotrmurach/tty-file/blob/master/CHANGELOG.md"
    spec.metadata["documentation_uri"] = "https://www.rubydoc.info/gems/tty-file"
    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = "https://github.com/piotrmurach/tty-file"
  end

  spec.files         = Dir["lib/**/*.rb"]
  spec.extra_rdoc_files = Dir["README.md", "CHANGELOG.md", "LICENSE.txt"]
  spec.require_paths = ["lib"]
  spec.required_ruby_version = ">= 2.0.0"

  spec.add_dependency "pastel",     "~> 0.8"
  spec.add_dependency "tty-prompt", "~> 0.22"
  spec.add_dependency "diff-lcs",   "~> 1.3"

  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", ">= 3.0"
  spec.add_development_dependency "webmock", "~> 3.4"
end
