#!/usr/bin/env ruby

import 'rc/**/*'

config 'pry' do
  puts "Pry on RC!"
  $LOAD_PATH.unshift('lib')
end

#
# Detroit assembly.
#
config 'detroit' do |asm|
  asm.service :email do |s|
    s.mailto = ['ruby-talk@ruby-lang.org', 
                'rubyworks-mailinglist@googlegroups.com']
  end

  asm.service :gem do |s|
    s.gemspec = 'pkg/rc.gemspec'
  end

  asm.service :github do |s|
    s.folder = 'web'
  end

  asm.service :dnote do |s|
    s.title  = 'Source Notes'
    s.output = 'log/notes.html'
  end

  asm.service :locat do |s|
    s.output = 'log/locat.html'
  end

  asm.service :vclog do |s|
    s.output = ['log/history.html',
                'log/changes.html']
  end
end


#
# Rake tasks 
#
config 'rake' do
  desc 'run unit tests'
  task 'test' do
    puts "Rake Boo!"
  end
end

#
# Example configuration.
#
config 'example' do
  puts "Configuration Example!"
end

