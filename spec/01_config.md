# Config Class

The Config class encapsulates a single config entry. It has a tool, profile
and procedure.

    config = RC::Config.new('foo', 'bar') do
      :baz
    end

    config.tool          #=> :foo
    config.profile       #=> :bar
    config.to_proc.call  #=> :baz


