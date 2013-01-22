# RELEASE HISTORY

## 0.4.0 / 2013-01-22

Tools that have built-in support for RC will have to call `RC.configure` to
configure the tool. The old `configure` method has been renamed to `define_config`
and is used *only* to define how calling `configure` is applied. This was done
so that tools could set `ENV['profile']` internally, say via a command line option.
This is a major change and all tools that it effects need to update to reflect the
change in order to work.

Changes:

* Rename `configure` to `define_config` (old `setup` alias is still there).
* Fix missing instance variable in Properties. [bug]


## 0.3.1 / 2012-12-09

This is bug fix release that addresses a couple of stupid oversights.

Changes:

* Fix rake tweak. Use `RC.configure` instead of `court`.
* Fix #autoconfig? method's instance variable.
* Fix #bootstrap_require to override correct hook.


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


## 0.1.1 / 2012-04-09

Initial release of RC. 

Changes:

* Happy first release.

