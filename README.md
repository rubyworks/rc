# RC - Runtime Configuration

[Homepage](http://rubyworks.github.com/rc) /
[Report Issue](http://github.com/rubyworks/rc/issues) /
[Source Code](http://github.com/rubyworks/rc)
( [![Build Status](https://secure.travis-ci.org/rubyworks/rc.png)](http://travis-ci.org/rubyworks/rc) )


## About

RC is a is multi-tenant runtime configuration system for Ruby tools.
It is designed to facilitate Ruby-based configuration for multiple
tools in a single file, and designed to work whether the tool
has built-in support for RC or not. The syntax is simple, universally
applicable, yet flexible.

RC can be used with any Ruby-based commandline tool or library utilized by
such tool, where there exists some means of configuring it via a toplevel/global
interface; or the tool has been designed to directly support RC, of course.


## Installation

To use RC with tools that support RC directly, there is likely nothing to
install. Installing the tool should install `rc` via a dependency and
load runtime configurations when the tool is used.

To use RC with a tool that does not provide built-in support, first install
the RC library, typically via RubyGems:

    gem install rc

Then add `-rc` to your system's `RUBYOPT` environment variable.

    $ export RUBYOPT='-rc'

You will want to add that to your `.bashrc`, `.profile` or equivalent configuration
script, so it is always available.


## Instruction

To use RC in a project create a configuration file called either `.ruby` or `.rubyrc`. 
The longer name has precedence if both are present. In this file add configuration blocks
by name of the commandline tool.

For example, let's demonstrate how we could use this to configure Rake tasks.
(Yes, Rake is not the most obvious choice, since developers are just as happy
to keep using a Rakefile. But using Rake as an example serves to show that it
*can* be done, and also it makes a good tie-in with next example.)

    $ cat .rubyrc
    config :rake do
      desc 'generate yard docs'
      task :yard do
        sh 'yard'
      end
    end

Now when `rake` is run the tasks defined in this configuration will be available.

You might wonder why anyone would do this. That's where the *multi-tenancy*
comes into play. Let's add another configuration.

    $ cat .rubyrc
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

Now we have configuration for both the `rake` tool and the `qedoc` tool in
a single file. Thus we gain the advantage of reducing the file count of our 
project while pulling our tool configurations together into one place.
Moreover, these configurations can potentially share settings as demonstrated
here via the `title` local variable.

Of course, if we want configurations stored in multiple files, that can be done
too. Simple use the `import` method to load them, e.g.

    import 'rc/*.rb'

RC also supports profiles, either via a `profile` block:

    profile :cov do
      config :qed do
        require 'simplecov'
        ...
      end
    end

Or via a keyword parameter:

    config 'qed', profile: 'cov' do
      require 'simplecov'
      ...
    end

When utilizing the tool, set the profile via an environment variable.

    $ profile=cov qed

RC also support just `p` as a convenient shortcut.

    $ p=cov qed

Some tools that support RC out-of-the-box, may support a profile command
line option for specifying the profile.

    $ qed -p cov

Beyond mere namespacing, some tools might utilize profiles for a more specific
purpose fitting the tool. Consult the tool's documentation for details.

Configurations can also be pulled in from other gems using the `from` option.

    config :qed, :profile=>'simplecov', :from=>'qed'

As long as a project includes its `.rubyrc` file (and any imported files)
in it's gem package, it's possible to share configurations in this manner.


## Customization

A tool can provide dedicated support for RC by loading `rc/api` and using the
`configure` method to define a configuration procedure. For example, 
the `detroit` project defines:

    require 'rc/api'

    RC.configure 'detroit' do |config|
      if config.command?
        Detroit.rc_config << config
      end
    end

In our example, when `detroit` is required this configuration will be processed.
The `if config.command?` condition ensures that it only happens if the config's
`command` property matches the current command, i.e. `$0 == 'detroit'`. We see
here that Detroit stores the configuration for later use. When Detroit gets
around to doing it's thing, it checks this `rc_config` setting and evaluates
the configurations found there.

It is important that RC be required first, ideally before anything else. This
ensures it will pick up all configured features.

Some tools will want to support a command line option for selecting a 
configuration profile. RC has a convenience method to make this very
easy to do. For example, `qed` uses it:

    RC.profile_switch('qed', '-p', '--profile')

It does not remove the argument from `ARGV`, so the tool's command line option
parser should still account for it. This simply ensures RC will know what the
profile is by setting `ENV['profile']` to the entry following the switch.


## Dependencies

### Libraries

RC depends on the [Finder](http://rubyworks.github.com/finder) library
to provide reliable load path and Gem searching. This is used when importing
configurations from other projects. (It's very much a shame Ruby and RubyGems
does not have this kind of functionality built-in.)

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

Please see HISTORY.md file.


## Copyrights

Copyright (c) 2011 Rubyworks

Confection is distributable in accordance with the **BSD-2-Clause** license.

See LICENSE.txt file for details.

