# Configuration

The Configuration class handle evaluation of a project configuration file.

   rc = RC::Configuration.new

We can use the `#instance_eval` method to evaluate a configuration for our
demonstration.

    rc.instance_eval(<<-HERE)
      config :sample1 do
        "block code"
      end
    HERE

Evaluation of a configuration file, populate the Confection.config instance.

    sample = rc.configurations.last
    sample.tool     #=> 'sample1'
    sample.profile  #=> 'default'
    sample.class    #=> RC::Config

A profile can be used as a means fo defining multiple configurations
for a single tool. This can be done by setting the second argument to
a Symbol.

    rc.instance_eval(<<-HERE)
      config :sample2, :opt1 do
        "block code"
      end
    HERE

    sample = rc.configurations.last
    sample.tool     #=> 'sample2'
    sample.profile  #=> 'opt1'

Or it can be done by using a `profile` block.

    rc.instance_eval(<<-HERE)
      profile :opt1 do
        config :sample2 do
          "block code"
        end
      end
    HERE

    sample = rc.configurations.last
    sample.tool     #=> 'sample2'
    sample.profile  #=> 'opt1'

RC also support YAML-based configuration, if the last argument is
a multi-line string it will create a block using `YAML.load`.

    rc.instance_eval(<<-HERE)
      config :sample3, %{
        ---
        note: This is the note.
      }
    HERE

    sample = rc.configurations.last
    sample.tool        #=> 'sample3'
    sample.profile     #=> 'default'
    sample.call.assert == {'note'=>'This is the note.'}

