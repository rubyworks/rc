# R C - Runtime Configuration

[Homepage](http://rubyworks.github.com/rc) /
[Source Code](http://github.com/rubyworks/rc) /
[Report Issue](http://github.com/rubyworks/rc/issues) /
[Mailing List](http://googlegroups.com/group/rubyworks-mailinglist) /
[IRC Channel](http://chat.us.freenode.net/rubyworks)

[![Build Status](https://secure.travis-ci.org/rubyworks/rc.png)](http://travis-ci.org/rubyworks/rc)


## About

RC is a is multi-tenant runtime configuration system for Ruby tools.
If was designed to facilitate Ruby-based configuration for multiple
tools in a single file, and designed to work regardless if the tool
has dedicated support for R.C. built-in. The syntax is simple, 
univerally applicable and flexible in use.


## Installation

To use RC via tools that support RC directly, there is nothing you need to
install. Installing the said tool should install `rc` via a dependency and
load `rc` when the tool is used.

To use RC with tools that don't provide direct support, first install RC
in the usual manner via RubyGems.

    $ gem install rc

Then add `-rc` to your system's `RUBYOPT` environment variable.

    $ export RUBYOPT='-rc'

You will want to add that to your `.bashrc`, `.profile` or equivalent configuration
script.


## Instruction

To use RC in a project create a master configuration file for the project called
`Config.rb`. The file can have any name that matches `.config.rb`, `Config.rb`
or `config.rb`, in that order of precedence. In this file add configuration
blocks by name of the commandline tool. For example, let's demonstrate how we could
use this to configure Rake tasks.

    $ cat Config.rb
    config :rake do
      desc 'generate yard docs'
      task :yard do
        sh 'yard'
      end
    end

Now when `rake` is run the tasks defined in this configuration will be available.

You might wonder why anyone would do this. That's where the *multi-tenancy*
comes into play. Let's add another configuration.

    $ cat Config.rb
    title = "MyApp"

    config :rake do
      desc 'generate yard docs'
      task :yard do
        sh "yard doc --title #{title}"
      end
    end

    config :qedoc do |doc|
      doc.title = "#{title} Demos"
    end

Now we have configuration for both the rake tool and the qedoc tool in
a single file. Thus we gain the advantage of reducing the file count of our 
project while pulling our tool configurations together into one place.
Moreover, these configurations can potentially share settings as demonstrated
here via the `title` local variable.

RC also supports profiles, either via a `profile` block:

    profile :cov
      config :qed do
        require 'simplecov'
        ...
      end
    end

Or via a second config argument:

    config :qed, :cov do
      require 'simplecov'
      ...
    end

When utilizing the tool, set the profile via an environment variable.

    $ profile='cov' qed

Some tools that support RC out-of-the-box, may support a profile command
line option for specifying the profile.

    $ qed -p cov

Still other tools might utilize profiles to a more specific purpose of
the tool at hand. Consult the tool's documentation for details.


## Qualifications

RC can be used with any Ruby-based commandline tool and there exists some
means of configuring the tool via a toplevel/global interface, or the tool
has been desinged to directly support RC.


## Customization

A tool can provide dedicated support for RC by loading `rc/api` and using the
`court` method to define a configuration procedure. For example, 
the `detroit` project defines:

    require 'rc/api'

    court 'detroit' do |config|
      if config.command?
        Detroit.rc_config << config
      end
    end

In our example, `detroit` is required this configuration will be proccessed.
The `if config.command?` condition ensures that it only happens if the config's
`command` property matches the current command, i.e. `$0 == 'detroit'`. We can
see that Detroit stores the configuration for later us. When Detroit gets
around to loading a project's build assemblies, it will check this `rc_config`
setting and evaluate the configurations found there via Detroit's own DSL.

It is important that RC be required first, ideally before anything else. This
ensures it will pick up all configured features.

Some tools will want to support a command line option for selecting a 
configuration profile. RC has a convenience method to make this very
easy to do.

    RC.profile_switch('qed', '-p', '--profile')

It does not remove the argument from `ARGV`, so the tool's command line option
parser should still account for it. This simply ensures RC will know what the
profile is by setting `ENV['profile']` to the entry following the switch.


## Dependencies

### Libraries

RC depends on the [Finder](http://rubyworks.github.com/finder) library
to provide reliable load path and Gem searching. This is used when importing
configurations from other projects.

### Core Extensions

RC uses two core extensions, `#to_h`, which applies to a few different
classes, and `String#tabto`. These are *copied* from
[Ruby Facets](http://rubyworks.github.com/facets) to ensure a high
standard of interoperability.

Both of these methods have been suggested for inclusion in Ruby proper.
Please head over to Ruby Issue Tracker and add your support.

* http://bugs.ruby-lang.org/issues/749
* http://bugs.ruby-lang.org/issues/6056


## Release Notes

Please see HISTORY.rdoc file.


## Copyrights

Copyright (c) 2011 Rubyworks

Confection is distributable in accordance with the **BSD-2-Clause** license.

See LICENSE.txt file for details.

