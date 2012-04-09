# Importing
 
## Configuration Importing

Configurations can be imported from another project
using the `:from` option.

    rc = RC::Configuration.new

    rc.config :qed, :profile=>'example', :from=>'qed'

    rc.size.assert == 1

The configuration can also be imported from a different profile.

    rc.config :qed, :coverage, :from=>'qed', :profile=>:simplecov

    rc.size.assert == 2

Although it will rarely be useful, it may also be imported from another tool.

    rc.config :example, :from=>'qed', :tool=>:sample

Imported configurations can also be augmented via a block.

    rc = RC::Configuration.new

    rc.config :qed, :from=>'qed', :profile=>:simplecov do
      # additional code here
    end

    rc.size.assert == 2

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

