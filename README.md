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
  * [2.1. inject_into_file](#21-inject_into_file)
  * [2.2. replace_in_file](#22-replace_in_file)

## 1. Usage

```ruby
TTY::File.replace_in_file('Gemfile', /gem 'rails'/, "gem 'hanami'")
```

## 2. Interface

The following are methods available for creating and manipulating files.

### 2.1. inject_into_file

Inject content into a file at a given location

```ruby
TTY::File.inject_into_file 'filename.rb', after: "Code below this line\n" do
  "text to add"
end
```

You can also use Regular Expressions in `:after` or `:before` to match file location. The `append_to_file` and `prepend_to_file` allow you to add content at the end and the begging of a file.

### 2.2. replace_in_file

Replace content of a file matching condition.

```ruby
TTY::File.replace_in_file 'filename.rb', /matching condition/, 'replacement'
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
