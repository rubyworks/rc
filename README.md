# RC - Runtime Configuration

[Homepage](http://rubyworks.github.com/rc) /
[Source Code](http://github.com/rubyworks/rc) /
[Report Issue](http://github.com/rubyworks/rc/issues) /
[Mailing List](http://googlegroups.com/group/rubyworks-mailinglist) /
[IRC Channel](http://chat.us.freenode.net/rubyworks)

[![Build Status](https://secure.travis-ci.org/rubyworks/rc.png)](http://travis-ci.org/rubyworks/rc)


## Description

RC, short for *Runtime Configuration*, is multi-tenant configuration system
for Ruby tools. If was designed to facilitate Ruby-based configuration for
multiple tools in a single file. It is extremely simple, and univerally applicable
which makes it easy to understand and flexible in use.


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

RC can be used with any Ruby-based commandline tool that can be required by
the same name as the tool, e.g. `rake` can be required via `require 'rake'`,
and there exists some means of configuring the tool via a toplevel/global
interface, or the tool has been customized to directly support RC.


## Customization

A tool can provide dedicated support for RC by loading the `rc/interface` script
and defining a `run` procedure. For example, the `detroit` project defines:

    require 'rc/interface'

    RC.run('detroit') do |configs|
      Detroit.rc_configs = configs
    end

When `detroit` gets around to loading a project's build assemblies, it will
check this setting and evaluate the configs via Detroit's confgiruation DSL.

Some tools may also need to run preconfiguration code before allowing RC to
process configuration. Probably the most common use for this is to parse
commandline arguments for a profile setting as an alternative to normal
environment variable.

    RC.run('qed') do
      if i = ARGV.index('--profile') || ARGV.index('-p')
        ENV['profile'] = ARGV[i+1]
      end
    end

The `run` method forces the loading of `rc`, which triggers tool configuration,
regardless of whether the end-user has set `RUBYOPT="-rc"`. If you wish for your
tool to only work when `RUBYOPT` is set, then define `RC.processor` instead of
`run`.


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

