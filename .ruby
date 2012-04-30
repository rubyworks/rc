---
source:
- var
- var/
authors:
- name: Trans
  email: transfire@gmail.com
copyrights:
- holder: Rubyworks
  year: '2011'
  license: BSD-2-Clause
requirements:
- name: finder
- name: loaded
- name: detroit
  groups:
  - build
  development: true
- name: qed
  groups:
  - test
  development: true
- name: ae
  groups:
  - test
  development: true
dependencies: []
alternatives: []
conflicts: []
repositories:
- uri: git://github.com/rubyworks/courtier.git
  scm: git
  name: upstream
resources:
- uri: http://rubyworks.github.com/courtier
  name: home
  type: home
- uri: http://rubydoc.info/gems/courtier/frames
  name: docs
  type: doc
- uri: http://github.com/rubyworks/courtier
  name: code
  type: code
- uri: http://groups.google.com/group/rubyworks-mailinglist
  name: mail
  type: mail
- uri: http://chat.us.freenode.net/rubyworks
  name: chat
  type: chat
extra: {}
load_path:
- lib
revision: 0
created: '2011-11-06'
summary: The best way to manage your application's configuration.
title: Courtier
version: 0.2.0
name: courtier
description: ! 'Courtier is a multi-tenant configuration system for Ruby projects.

  Courtier can configure almost any Ruby tool or library.'
organization: Rubyworks
date: '2012-04-28'
