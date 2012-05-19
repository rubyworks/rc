module RC

  #
  # Configuration setup is used to customize how a tool handles
  # configuration.
  #
  class Setup

    #
    # Intialize new configuration setup.
    #
    def initialize(command, options={}, &block)
      @command = command.to_s
      #@command = options[:command] || options[:tool] if options.key?(:command) || options.key?(:tool)

      @profile = options[:profile] if options.key?(:profile)

      @block = block
    end

    #
    # Command for which this is the configuration setup.
    #
    attr :command

    #
    # Specific profile for which this is the configuration is the setup.
    #
    attr :profile

    #
    #
    #
    def call(config)
      return unless config.command == @command #.to_s if @command

      case profile
      when true
        return unless RC.profile?
      when nil, false
      else
        return unless config.profile == @profile.to_s #if @profile
      end

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
