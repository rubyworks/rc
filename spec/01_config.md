# Config Class

The Config class encapsulates a single config entry. It has a tool, profile
and procedure.

    config = RC::Config.new('foo', :profile=>'bar') do
      'example'
    end

    config.tool          #=> 'foo'
    config.command       #=> 'foo'
    config.profile       #=> 'bar'
    config.to_proc.call  #=> 'example'

