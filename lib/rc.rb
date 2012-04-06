# Runtime Configuration system.
#
module RC
  # External requirements.
  require 'yaml'
  require 'ostruct'
  require 'finder'

  # Internal requirements.
  require 'rc/core_ext'
  require 'rc/parser'
  require 'rc/processor'
  require 'rc/properties'
  require 'rc/interface'

  #require 'rc/config'
  #require 'rc/project'
end

# Bootstrap properties
RC.bootstrap

# Copyright (c) 2011 Rubyworks (BSD-2-Clause)
