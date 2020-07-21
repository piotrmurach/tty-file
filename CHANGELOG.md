# Change log

## [v0.10.0] - 2020-07-xx

### Changed
* Change to update tty-prompt & pastel dependencies

## [v0.9.0] - 2020-04-28

### Changed
* Change #chmod custom permission implementation for built-in FileUtils one
* Change to update tty-prompt dependency
* Change gemspec to include metadata and stop loading test artefacts

### Fixed
* Fix Ruby 2.7 hash to keywords conversion warnings

## [v0.8.0] - 2019-07-25

### Added
* Add #read_to_char for reading file content limited by bytes until a valid char

### Fixed
* Fix #binary? to correctly identify large UTF-8 files as non-binary

## [v0.7.1] - 2019-05-06

### Changed
* Change all methods to accept Pathname instances as argument by Chris Hoffman(@yarmiganosca)

### Fixed
* Fix Ruby 2.6.0 ERB#new arguments deprecation warnings
* Fix #replace_in_file to handle character encoding

## [v0.7.0] - 2018-12-17

### Added
* Add :secure option to #remove_file call
* Add #safe_append_to_file, #safe_prepend_to_file, #safe_inject_into_file

### Changed
* Change #replace_in_file, #append_to_file, #prepend_to_file, and #inject_into_file to perform operation unsafely without checking prior content
* Change to load gemspec files directly
* Change to update tty-prompt
* Change to freeze strings
* Change to relax tty-prompt & diff-lcs version constraints

### Fixed
* Fixed windows tests

## [v0.6.0] - 2018-05-21

### Changed
* Change identical files conflict message from blue to cyan for readability
* Change replace_in_file to stop raising error and allow forcing file overwrite
* Change replace_in_file, inject_into_file, prepend_to_file, append_to_file to return true when operation is performed successfully, false otherwise
* Update tty-prompt dependency
* Change download_file to preserve query parameters

### Fixed
* Fix replace_in_file to preserve file original encoding

## [v0.5.0] - 2018-01-06

### Changed
* Update tty-prompt dependency
* Change gemspec to require ruby >= 2.0.0

## [v0.4.0] - 2017-09-16

### Added
* Add tail_file for reading a given number of lines from end of a file

### Changed
* Change api calls to accept :color option for disabling/coloring log status
* Update tty-prompt dependency

### Fixed
* Fix #log_status to properly handle wrapping of keywords in color
* Fix #binary? to work correctly on Windows

## [v0.3.0] - 2017-03-26

### Changed
* Change file loading
* Update tty-prompt dependency

## [v0.2.1] - 2017-02-12

### Fixed
* Fix File::create_file when :force is true by Edoardo Tenani(@endorama)

## [v0.2.0] - 2017-01-22

### Added
* Add #checksum_file to generate checksum for a file, IO object or String
* Add #create_dir to create directory structure with directories and files
* Add #copy_dir to copy directory recurisvely
* Add #escape_glob_path for escaping glob characters in a path

### Changed
* Change #binary? to only read max 4Kb of file
* Change CreateFile to accept context in constructor
* Change to separate config_options from utility options

### Fixed
* Fix all aliases being incorrectly defined
* Fix #copy_file to stop appending to source paths

## [v0.1.0] - 2016-11-06

* Initial implementation and release

[v0.10.0]: https://github.com/piotrmurach/tty-file/compare/v0.9.0...v0.10.0
[v0.9.0]: https://github.com/piotrmurach/tty-file/compare/v0.8.0...v0.9.0
[v0.8.0]: https://github.com/piotrmurach/tty-file/compare/v0.7.1...v0.8.0
[v0.7.1]: https://github.com/piotrmurach/tty-file/compare/v0.7.0...v0.7.1
[v0.7.0]: https://github.com/piotrmurach/tty-file/compare/v0.6.0...v0.7.0
[v0.6.0]: https://github.com/piotrmurach/tty-file/compare/v0.5.0...v0.6.0
[v0.5.0]: https://github.com/piotrmurach/tty-file/compare/v0.4.0...v0.5.0
[v0.4.0]: https://github.com/piotrmurach/tty-file/compare/v0.3.0...v0.4.0
[v0.3.0]: https://github.com/piotrmurach/tty-file/compare/v0.2.1...v0.3.0
[v0.2.1]: https://github.com/piotrmurach/tty-file/compare/v0.2.0...v0.2.1
[v0.2.0]: https://github.com/piotrmurach/tty-file/compare/v0.1.0...v0.2.0
[v0.1.0]: https://github.com/piotrmurach/tty-file/compare/v0.1.0
