# Config Class

The Config class encapsulates a single config entry. Every Config instance has a `command`, `feature`,
and `profile` atribute, as well as a procedure.

    config = RC::Config.new('foo', :profile=>'bar') do
      'example'
    end

    config.command       #=> 'foo'
    config.feature       #=> 'foo'
    config.profile       #=> 'bar'
    config.to_proc.call  #=> 'example'

