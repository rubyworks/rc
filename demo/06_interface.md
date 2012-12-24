# Interface

The main means of workin with RC's API are the RC class methods,
collectively called the Inteface.

Let's say we have a configuration file `.ruby` containing:

    config :example do
      "example config"
    end

    config :example, :profile=>:something do
      "example config using profile"
    end

To get the configuration of the current project --relative to the 
current working directory, use the `configuration` method.

    RC.configuration

The configuration properties of the current project can be
had via the `properties` method.

    RC.properties

The profile names can be looked up for any given tool via the `profile_names`
method.

    RC.profile_names(:example)  #=> ['default', 'something']

The number of feature configurations in the current project can be
had via the `size` method.

    RC.configuration.size  #=> 1

A list of all configuration entries can be had by calling #to_a.

    RC.configuration.to_a.size  #=> 2

