# Configuration

The Configuration class handle evaluation of a project configuration file.

   rc = RC::Configuration.new

We can use the `#instance_eval` method to evaluate a configuration for our
demonstration.

    rc.evaluate(<<-HERE)
      config :sample1 do
        "block code"
      end
    HERE

Evaluation of a configuration file, populate the Confection.config instance.

    sample = rc.configurations.last
    sample.command  #=> 'sample1'
    sample.profile  #=> 'default'
    sample.class    #=> RC::Config

A profile can be used as a means fo defining multiple configurations
for a single tool. This can be done by setting the second argument to
a Symbol.

    rc.evaluate(<<-HERE)
      config :sample2, profile: 'opt1' do
        "block code"
      end
    HERE

    sample = rc.configurations.last
    sample.command  #=> 'sample2'
    sample.profile  #=> 'opt1'

Or it can be done by using a `profile` block.

    rc.evaluate(<<-HERE)
      profile :opt1 do
        config :sample2 do
          "block code"
        end
      end
    HERE

    sample = rc.configurations.last
    sample.command  #=> 'sample2'
    sample.profile  #=> 'opt1'


