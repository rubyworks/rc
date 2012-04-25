module RC

  # Tool configuration setup is used to customize how a tool handles
  # configuration.
  #
  # TODO: It may be useful to create "open configurations" that are run for all
  #       tools that have a setup defined when bootstrap is run regardless
  #       of the current tool. If we do this then `RC.commit_configuration` is
  #       necessary. If we don't do this then `RC.commit_configuration` could
  #       be made automatic by adding it to the end of the `RC.setup` method.
  #
  class Setup

    #
    # Intialize new configuration setup.
    #
    def initialize(feature, &block)
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
      @config = config
      @block.call(self)
    end

    #
    # Delegate to config.
    #
    # @todo Make explict methods, instead of delegating all?
    #
    def method_missing(s, *a, &b)
      @config.send(s, *a, &b) if @config.respond_to?(s)
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

    #
    # Set current profile via ARGV switch. This is done immediately,
    # setting `ENV['profile']` to the switch value if this setup is
    # for the current tool. The reason it is done immediately, rather
    # than assigning it in bootstrap, is b/c option parsers somtimes
    # consume ARGV as they parse it, and by then it would too late.
    # If this approach proves to be an issue we could move it to
    # bootstrap and just make a copy of ARGV here for later use.
    #
    # @example
    #   profile_switch('-p', '--profile')
    #
    def profile_switch(*switches)
      return unless @config.command?

      switches.each do |switch|
        if index = ARGV.index(switch)
          ENV['profile'] = ARGV[index+1]
        end
      end
    end

  end

end
