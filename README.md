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
  * [2.1. chmod](#21-chmod)
  * [2.2. copy_file](#22-copy_file)
  * [2.3. create_file](#23-create_file)
  * [2.4. diff](#24-diff)
  * [2.5. inject_into_file](#25-inject_into_file)
  * [2.6. replace_in_file](#26-replace_in_file)
  * [2.7. append_to_file](#27-apend_to_file)
  * [2.8. prepend_to_file](#28-prepend_to_file)


## 1. Usage

```ruby
TTY::File.replace_in_file('Gemfile', /gem 'rails'/, "gem 'hanami'")
```

## 2. Interface

The following are methods available for creating and manipulating files.

If you wish to silence verbose output use `verbose: false`. Similarly if you wish to run action without actually triggering any action use `noop: true`.

### 2.1. chmod

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

### 2.2. copy_file

Copies a file content from relative source to relative destination.

```ruby
TTY::File.copy_file 'Gemfile', 'Gemfile.bak'
```

If the destination is a directory, then copies source inside that directory.

```ruby
TTY::File.copy_file 'docs/README.md', 'app'
```

### 2.3. create_file

To create a file at a given destination with the given content use `create_file`:

```ruby
TTY::File.create_file 'docs/README.md', '## Title header'
```

On collision with already existing file, a menu is displayed:

You can force to always overwrite file with `:force` option or always skip by providing `:skip`.

### 2.4. diff

To compare files line by line in a system independent way use `diff`:

```ruby
TTY::File.diff('file_a', 'file_b')
# =>
#  @@ -1,4 +1,4 @@
#   aaa
#  -bbb
#  +xxx
#   ccc
```

You can also pass additional arguments such as `:format` and `:context_lines`.

Accepted formats are `:old`, `:unified`, `:context`, `:ed`, `:reverse_ed`, by default the `:unified` format is used.

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

### 2.5. inject_into_file

Inject content into a file at a given location

```ruby
TTY::File.inject_into_file 'filename.rb', after: "Code below this line\n" do
  "text to add"
end
```

You can also use Regular Expressions in `:after` or `:before` to match file location. The `append_to_file` and `prepend_to_file` allow you to add content at the end and the begging of a file.

### 2.6. replace_in_file

Replace content of a file matching condition.

```ruby
TTY::File.replace_in_file 'filename.rb', /matching condition/, 'replacement'
```

### 2.7. append_to_file

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

### 2.8. prepend_to_file

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

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/piotrmurach/tty-file. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Copyright

Copyright (c) 2016 Piotr Murach. See LICENSE for further details.
