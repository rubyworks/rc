#!/usr/bin/env ruby

#
# Detroit assembly.
#
config :detroit do
  service :email do |s|
    s.mailto = ['ruby-talk@ruby-lang.org', 
                'rubyworks-mailinglist@googlegroups.com']
  end

  service :dnote do |s|
    s.active = true
  end

  service :github do |s|
    s.folder = 'web'
  end

  service :dnote do |s|
    s.title  = 'Source Notes'
    s.output = 'log/notes.html'
  end

  service :locat do |s|
    s.output = 'log/locat.html'
  end

  service :vclog do |s|
    s.output = ['log/history.html',
                'log/changes.html']
  end
end

#
# QED test coverage report using SimpleCov.
#
# Use `$properties.coverage_folder` to set directory in which to store
# coverage report this defaults to `log/coverage`.
#
config :qed, :cov do
  require 'simplecov'

  dir = $properties.coverage_folder

  SimpleCov.start do
    coverage_dir(dir || 'log/coverage')
    #add_group "Label", "lib/qed/directory"
  end
end

#
# Rake tasks 
#
config :rake do
  desc 'run unit tests'
  task :test do
    puts "boo"
  end
end

#
# Example configuration.
#
config :example do
  puts "Configuration Example!"
end

