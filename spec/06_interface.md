# Interface

The main means of workin with RC's API are the RC class methods,
collectively called the Inteface.

Let's say we have a configuration file `config.rb` containing:

    config :example do
      "example config"
    end

    config :example, :something do
      "example config using profile"
    end

To get the configuration of the current project --relative to the 
current working directory, we can use the `configuration` method.

    RC.configuration

The configuration properties of the current project can be
had via the `properties` method.

    RC.properties

The profile names can be looked up for any given tool via the `profiles`
method.

    RC.profiles(:example)

The number of configurations in the current project can be had via
the `size` method. (This is the number of configurations we have
defined in our test fixture.)

    RC.configuration.configurations.size.assert == 2

