# Change log

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

[v0.2.0]: https://github.com/piotrmurach/tty-file/compare/v0.1.0...v0.2.0
[v0.1.0]: https://github.com/piotrmurach/tty-file/compare/v0.1.0
