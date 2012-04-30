# Config Class

The Config class encapsulates a single config entry. It has a tool, profile
and procedure.

    config = RC::Config.new('foo', :profile=>'bar') do
      'example'
    end

    config.command       #=> 'foo'
    config.feature       #=> 'foo'
    config.profile       #=> 'bar'
    config.to_proc.call  #=> 'example'

