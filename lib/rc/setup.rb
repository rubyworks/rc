module RC

  # Tool configuration setup is used to customize how a tool handles
  # configuration.
  #
  class Setup

    #
    # Intialize new configuration setup.
    #
    def initialize(feature, options={}, &block)
      @feature = feature.to_s

      @command = @feature
      @command = options[:command] || options[:tool] if options.key?(:command) || options.key?(:tool)

      @profile = options[:profile] if options.key?(:profile)

      @block = block
    end

    #
    # Feature for which this is the configuration setup.
    #
    attr :feature

    #
    #
    #
    def call(config)
      return unless config.command == @command.to_s if @command
      return unless config.profile == @profile.to_s if @profile

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
