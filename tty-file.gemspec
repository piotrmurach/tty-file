lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tty/file/version'

Gem::Specification.new do |spec|
  spec.name          = "tty-file"
  spec.version       = TTY::File::VERSION
  spec.authors       = ["Piotr Murach"]
  spec.email         = ["me@piotrmurach.com"]
  spec.summary       = %q{File manipulation utility methods.}
  spec.description   = %q{File manipulation utility methods.}
  spec.homepage      = "https://piotrmurach.github.io/tty"
  spec.license       = "MIT"

  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://rubygems.org"
    spec.metadata["changelog_uri"] = "https://github.com/piotrmurach/tty-file/blob/master/CHANGELOG.md"
    spec.metadata["documentation_uri"] = "https://www.rubydoc.info/gems/tty-file"
    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = "https://github.com/piotrmurach/tty-file"
  end

  spec.files         = Dir['{lib,spec}/**/*.rb']
  spec.files        += Dir['{bin,tasks}/*', 'tty-file.gemspec']
  spec.files        += Dir['README.md', 'CHANGELOG.md', 'LICENSE.txt', 'Rakefile']
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.0.0'

  spec.add_dependency 'pastel',     '~> 0.7.2'
  spec.add_dependency 'tty-prompt', '~> 0.20'
  spec.add_dependency 'diff-lcs',   '~> 1.3'

  spec.add_development_dependency 'bundler', '>= 1.5'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'webmock', '~> 3.4'
end
