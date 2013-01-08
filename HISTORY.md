# RELEASE HISTORY

## 0.3.0 / 2012-13-08

This release is of the project finally begins to settle down the API.
The most significant change since the last release is the use of `.rubyrc`,
or just `.ruby`, as the name for the standard configuration file. It was 
changed from the previous `Config.rb` file name in order to avoid any
confusion with Rails `config` directory or any other use of the word.
If you still prefer the old name, simply add a `.rubyrc` file to your
project containing `import "Config.rb"` to get equivalent functionality.
Other than that the majority of changes have been to improve the library
internally.

Changes:

* Change default config file name to `.rubyrc`, or just `.ruby`.
* Improve configuration loading code.
* Remove dependency on Courtier.


## 0.2.0 / 2012-04-16

Major improvements and simplifications to design and API.
Basically, just read the README to see what is new.

Changes:

* Add support for require-based configuration setups.
* Overhaul and drastically simplify design.


## 0.1.1 . 2012-04-09

Initial release of RC. 

Changes:

* Happy first release.

