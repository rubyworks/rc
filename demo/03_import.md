# Importing
 
## Configuration Importing

Configurations can be imported from another project using the `:from` option.

    rc = RC::Configuration.new

    rc.config :qed, :profile=>'example', :from=>'test'

    rc.to_a.size.assert == 1

The configuration can also be imported from a different profile.

    rc.config :qed, :profile=>:coverage, :from=>['test', :profile=>'simplecov']

    rc.to_a.size.assert == 2

Although it will very rarely be of use, it may also be imported from another
feature or command too.

    rc.config :example, :from=>['test', :command=>'sample']

Imported configurations can also be augmented via a block.

    rc = RC::Configuration.new

    rc.config :qed, :from=>['test', :profile=>'simplecov'] do
      # additional code here
    end

    rc.to_a.size.assert == 2

Technically this last form just creates two configurations for the same
tool and profile, but the ultimate effect is the same.

## Script Importing

Library files can be imported directly into configuration blocks via the
`#import` method.

    rc.config :example do
      import "fruitbasket/example.rb"
    end

This looks up the file via the `finder` gem and then evals it in the context
of the config block.

