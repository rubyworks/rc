= RC

The purpose of RC is to provide unified configuration management across multiple
tools for Ruby. The structure of an RC configuration file is very simple.
It is a ruby script sectioned into named blocks:

  config :rake do
    # ... rake tasks ...
  end

  config :vclog do
    # ... configure vclog ...
  end

Utilization of the these configurations may be handled by the consuming 
application, but can be used by any tool if `rc` is loaded via RUBYOPT.

To work with RC in this specification, we want to avoid the automatic
bootstrap, so we load the `interface` script instead.

  require 'rc/interface'

