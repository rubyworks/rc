module RC

  # Tool configuration setup is used to customize how a tool handles
  # configuration.
  #
  class Setup

    #
    # Intialize new configuration setup.
    #
    def initialize(feature, options={}, &block)
      @feature  = feature.to_s
      @handlers = []
      @swithes  = []

      block.call(self)
    end

    #
    # Feature for which this is the configuration setup.
    #
    attr :feature

    #
    #
    #
    def on(*match, &block)
      matchers = (Hash === match.last ? match.pop : {})
      match.each do |name|
        case name.to_sym
        when :command
          matchers[:command] = RC.current_command
        when :profile
          matchers[:profile] = RC.current_profile
        end
      end
      @handlers << [matchers, block]
    end

    #
    #
    #
    def call(config)
      @handlers.each do |matchers, block|
        if config.match?(matchers)
          block.call(config)
        end
      end
    end


=begin
    #
    # Get/set current configuration callback. Tools can use
    # this to gain control over the configuration proccess.
    #
    # The block should take a single argument for a Config
    # object. Keep in mind this procedure can be called multiple
    # times.
    #
    # This might be used to save the configuration for
    # a later execution, or to evaluate the configuration
    # in a special scope, or both.
    #
    # Keep in mind that if configurations are evaluated in
    # a different scope, they may not be able to utilize
    # any shared methods defined in the config file.
    #
    # @example
    #   # equivalent to default behavior
    #   RC.setup('foo') do |tool|
    #     tool.command_proc do |config|
    #       config.call
    #     end
    #   end
    #
    def command_proc(&block)
      @command_proc << block if block
      @command_proc
    end

    #
    # Get/set per-profile configuration callback. Tools can use
    # this to gain control over the configuration proccess.
    #
    # @example
    #   RC.profile_proc('qed') do |name, config|
    #     QED.configure(name, &config)
    #   end
    #
    def profile_proc(&block)
      @profile_proc << block if block
      @profile_proc
    end

    #
    # Define configuration callback procedure(s). This is a convenience method for
    # the other two callback procedures, namely #current_proc and #profile_proc.
    # If the block given has an arity of `1`, then #current_proc is set. Otherwise
    # the #profile_proc is set and #current_proc is set to a no-op. These two modes
    # fit typical usage, which is why this convenience method is provided.
    #
    def config_proc(&block)
      raise ArgumentError, "no block given" unless block

      if block.arity == 1
        @current_proc << block
        @profile_proc.clear
      else
        @profile_proc << block
        @current_proc.clear  # no current_proc in this case
      end
    end
=end

  end

end
