# TTY::File [![Gitter](https://badges.gitter.im/Join%20Chat.svg)][gitter]
[![Gem Version](https://badge.fury.io/rb/tty-file.svg)][gem]
[![Build Status](https://secure.travis-ci.org/piotrmurach/tty-file.svg?branch=master)][travis]
[![Code Climate](https://codeclimate.com/github/piotrmurach/tty-file/badges/gpa.svg)][codeclimate]
[![Coverage Status](https://coveralls.io/repos/github/piotrmurach/tty-file/badge.svg)][coverage]
[![Inline docs](http://inch-ci.org/github/piotrmurach/tty-file.svg?branch=master)][inchpages]

[gitter]: https://gitter.im/piotrmurach/tty
[gem]: http://badge.fury.io/rb/tty-file
[travis]: http://travis-ci.org/piotrmurach/tty-file
[codeclimate]: https://codeclimate.com/github/piotrmurach/tty-file
[coverage]: https://coveralls.io/github/piotrmurach/tty-file
[inchpages]: http://inch-ci.org/github/piotrmurach/tty-file

> File manipulation utility methods

## Motivation

Though Ruby's `File` and `FileUtils` provide very robust apis for dealing with files, this library aims to provide level of abstraction that is much convenient with useful logging capabilities.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tty-file'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tty-file

## Contents

* [1. Usage](#1-usage)
* [2. Interface](#2-interface)
  * [2.1. binary?](#21-binary)
  * [2.2. checksum_file](#22-checksum_file)
  * [2.3. chmod](#23-chmod)
  * [2.4. copy_file](#24-copy_file)
  * [2.5. create_file](#25-create_file)
  * [2.6. copy_dir](#26-copy_dir)
  * [2.7. create_dir](#27-create_dir)
  * [2.8. diff](#28-diff)
  * [2.9. download_file](#29-download_file)
  * [2.10. inject_into_file](#210-inject_into_file)
  * [2.11. replace_in_file](#211-replace_in_file)
  * [2.12. append_to_file](#212-apend_to_file)
  * [2.13. prepend_to_file](#213-prepend_to_file)
  * [2.14. remove_file](#214-remove_file)

## 1. Usage

```ruby
TTY::File.replace_in_file('Gemfile', /gem 'rails'/, "gem 'hanami'")
```

## 2. Interface

The following are methods available for creating and manipulating files.

If you wish to silence verbose output use `verbose: false`. Similarly if you wish to run action without actually triggering any action use `noop: true`.

### 2.1. binary?

To check whether a file is a binary file, i.e. image, executable etc. do:

```ruby
TTY::File.binary?('image.png') # => true
```

### 2.2. checksum_file

To generate checksum for a file, IO object or String use `checksum_file`. By default `MD5` algorithm is used which can be changed by passing second argument.

Among supported message digest algorithms are:

* `sha`, `sha1`, `sha224`, `sha256`, `sha384`, `sha512`
* `md2`, `md4`, `md5`

For example, to create digest for string using `SHA1` do:

```ruby
TTY::File.checksum_file("Some content\nThe end", 'sha1')
# => "289388f187404135e6c15b21460442cf867180dd"
```

### 2.3. chmod

To change file modes use `chmod` like so:

```ruby
TTY::File.chmod('filename.rb', 0777)
```

There are number of constants available to represent common mode bits such as `TTY::File::U_R`, `TTY::File::O_X` and can be used as follows:

```ruby
TTY::File.chmod('filename.rb', TTY::File::U_R | TTY::File::O_X)
```

Apart from traditional octal number definition for file permissions, you can use more convenient permission notation accepted by Unix `chmod` command:

```ruby
TTY::File.chmod('filename.rb', 'u=wrx,g+x')
```

The `u`, `g`, and `o` specify the user, group, and other parts of the mode bits. The `a` symbol is equivalent to `ugo`.

### 2.4. copy_file

Copies a file content from relative source to relative destination.

```ruby
TTY::File.copy_file 'Gemfile', 'Gemfile.bak'
```

If you provide a block then the file content is yielded:

```ruby
TTY::File.copy_file('Gemfile', 'app/Gemfile') do |content|
  "https://rubygems.org\n" + content
end
```

If the source file is an `ERB` template then you can provide `:context` in which the file gets evaluted or if `TTY::File` gets included as a module then approprite object context will be used by default. To use `:context` do:

```ruby
variables = OpenStruct.new
variables[:foo] = 'bar'

TTY::File.copy_file('templates/application.html.erb', context: variables)
```

You can also specifie template name surrounding any dynamic variables with `%` to be evaluted:

```ruby
variables = OpenStruct.new
variables[:file_name] = 'foo'

TTY::File.copy_file('templates/%file_name%.rb', context: variables)
# => Creates templates/foo.rb
```

If the destination is a directory, then copies source inside that directory.

```ruby
TTY::File.copy_file 'docs/README.md', 'app'
```

If the destination file already exists, a prompt menu will be displayed to enquire about action:

If you wish to preserve original owner, group, permission and modified time use `:preserve` option:

```ruby
TTY::File.copy_file 'docs/README.md', 'app', preserve: true
```

### 2.5. create_file

To create a file at a given destination with the given content use `create_file`:

```ruby
TTY::File.create_file 'docs/README.md', '## Title header'
```

On collision with already existing file, a menu is displayed:

You can force to always overwrite file with `:force` option or always skip by providing `:skip`.

### 2.6. copy_dir

To recursively copy a directory of files from source to destination location use `copy_directory` or its alias 'copy_dir'.

Assuming you have the following directory structure:

```ruby
# doc/
#   subcommands/
#     command.rb.erb
#   README.md
#   %name%.rb
```

you can copy `doc` folder to `docs` by invoking:

```ruby
TTY::File.copy_directory('doc', 'docs', context: ...)
```

The `context` needs to respond to `name` message and given it returns `foo` value the following directory gets created:

```ruby
# docs/
#   subcommands/
#     command.rb
#   README.md
#   foo.rb
```

If you only need to copy top level files use option `recursive: false`:

```ruby
TTY::File.copy_directory('doc', 'docs', recursive: false)
```

By passing `:exclude` option you can instruct the method to ignore any files including the given pattern:

```ruby
TTY::File.copy_directory('doc', 'docs', exclude: 'subcommands')
```

### 2.7. create_dir

To create directory use `create_directory` or its alias `create_dir` passing as a first argument file path:

```ruby
TTY::File.create_dir(/path/to/directory)
```

or a data structure describing the directory tree including any files with or without content:

```ruby
tree =
  'app' => [
    'README.md',
    ['Gemfile', "gem 'tty-file'"],
    'lib' => [
      'cli.rb',
      ['file_utils.rb', "require 'tty-file'"]
    ]
    'spec' => []
  ]
```

```ruby
TTY::File.create_dir(tree)
# =>
# app
# app/README.md
# app/Gemfile
# app/lib
# app/lib/cli.rb
# app/lib/file_utils.rb
# app/spec
```

As a second argument you can provide a parent directory, otherwise current directory will be assumed:

```ruby
TTy::File.create_dir(tree, '/path/to/parent/dir')
```

### 2.8. diff

To compare files line by line in a system independent way use `diff`, or `diff_files`:

```ruby
TTY::File.diff('file_a', 'file_b')
# =>
#  @@ -1,4 +1,4 @@
#   aaa
#  -bbb
#  +xxx
#   ccc
```

You can also pass additional arguments such as `:format`, `:context_lines` and `:threshold`.

Accepted formats are `:old`, `:unified`, `:context`, `:ed`, `:reverse_ed`, by default the `:unified` format is used.

The `:context_lines` specifies how many extra lines around the differing lines to include in the output. By default its 3 lines.

The `:threshold` sets maximum file size in bytes, by default files larger than `10Mb` are not processed.

```ruby
TTY::File.diff('file_a', 'file_b', format: :old)
# =>
#  1,4c1,4
#  < aaa
#  < bbb
#  < ccc
#  ---
#  > aaa
#  > xxx
#  > ccc
```

Equally, you can perform a comparison between a file content and a string content like so:

```ruby
TTY::File.diff('/path/to/file', 'some long text')
```

### 2.9. download_file

To download a content from a given address and to save at a given relative location do:

```ruby
TTY::File.download_file("https://gist.github.com/4701967", "doc/README.md")
```

If you pass a block then the content will be yielded to allow modification:

```ruby
TTY::File.download_file("https://gist.github.com/4701967", "doc/README.md") do |content|
  content.gsub("\n", " ")
end
```

By default `download_file` will follow maximum 3 redirects. This can be changed by passing `:limit` option:

```ruby
TTY::File.download_file("https://gist.github.com/4701967", "doc/README.md", limit: 5)
# => raises TTY::File::DownloadError
```

### 2.10. inject_into_file

Inject content into a file at a given location

```ruby
TTY::File.inject_into_file 'filename.rb', after: "Code below this line\n" do
  "text to add"
end
```

You can also use Regular Expressions in `:after` or `:before` to match file location. The `append_to_file` and `prepend_to_file` allow you to add content at the end and the begging of a file.

### 2.11. replace_in_file

Replace content of a file matching condition by calling `replace_in_file` or `gsub_file`

```ruby
TTY::File.replace_in_file 'filename.rb', /matching condition/, 'replacement'
```

The replacement content can be provided in a block

```ruby
TTY::File.gsub_file 'filename.rb', /matching condition/ do
  'replacement'
end
```

### 2.12. append_to_file

Appends text to a file. You can provide the text as a second argument:

```ruby
TTY::File.append_to_file('Gemfile', "gem 'tty'")
```

or inside a block:

```ruby
TTY::File.append_to_file('Gemfile') do
  "gem 'tty'"
end
```

### 2.13. prepend_to_file

Prepends text to a file. You can provide the text as a second argument:

```ruby
TTY::File.prepend_to_file('Gemfile', "gem 'tty'")
```

or inside a block:

```ruby
TTY::File.prepend_to_file('Gemfile') do
  "gem 'tty'"
end
```

### 2.14. remove_file

To remove a file do:

```ruby
TTY::File.remove_file 'doc/README.md'
```

You can also pass in `:force` to remove file ignoring any errors:

```ruby
TTY::File.remove_file 'doc/README.md', force: true
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/piotrmurach/tty-file. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Copyright

Copyright (c) 2016-2017 Piotr Murach. See LICENSE for further details.
