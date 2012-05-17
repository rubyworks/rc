# R.C.

The purpose of R.C. is to provide unified configuration management
for Ruby tools.

R.C. designates a single per-project configuration file, named
either `.config.rb`, `Config.rb` or `config.rb`, looked up in that 
order. The structure of this configuration file is very simple.
It is a ruby script sectioned into named `config` and `onload`
blocks:

  config 'rubytest' do
    # ... configure rubytest command ...
  end

  onload 'rake' do
    # ... when rake is required then ...
  end

Utilization of the these configurations may be handled by the consuming 
application, but can be used on any Ruby-based tool if `-rc` is added 
to RUBYOPT.

