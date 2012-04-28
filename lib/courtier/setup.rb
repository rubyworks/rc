module Courtier

  # Tool configuration setup is used to customize how a tool handles
  # configuration.
  #
  class Setup

    #
    # Intialize new configuration setup.
    #
    def initialize(feature, options={}, &block)
      @feature = feature.to_s
      @block   = block
    end

    #
    # Feature for which this is the configuration setup.
    #
    attr :feature

    #
    #
    #
    def call(config)
      @block.call(config)
    end

    #
    #
    #
    def to_proc
      @block
    end

  end

end
