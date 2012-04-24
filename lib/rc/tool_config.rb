module RC

  # ToolConfig encapsulates configurations for a specific tool.
  # It is essentially a subset taken from a project's full set of
  # configurations. In most respects it is like ConfigFilter, and
  # uses an instance of ConfigFilter under the hood. But it offers
  # some features not suited to ConfigFilter.
  #
  # 1. It is a subclass of Module and includes the Configuration
  #    instance passed to it. This makes it possible to include it
  #    into a DSL context in order to get access to local methods
  #    defined in the configuration (note, such usage has limitations
  #    users should be aware).
  #
  # 2. It provides some helper methods suiteable to the context, instead
  #    of having to call RC class methods with redundant arguments.
  #
  class Tool < Module
    include Enumerable

    #
    # Initialize new ToolConfiguration.
    #
    # @param [String,Symbol] Tool name.
    #
    # @param [Configuraiton] Project configuration instance.
    #
    def initialize(config, tool)
      include config

      @tool = tool

      #profile_names = configuration(gem).profiles(tool)

      @filter = ConfigFilter.new(config, :tool=>tool, :preset=>false)
    end   

    #
    #
    #
    def tool
      @tool
    end

    #
    # Returns list of profiles.
    #
    def profiles
      @filter.profiles
    end

    #
    #
    #
    def [](profile)
      @filter[profile]
    end

    #
    #
    #
    def each(&block)
      @filter.each(&block)
    end

    #
    #
    #
    def size
      @filter.size
    end

    #
    # Run the tool configs for current profile.
    #
    def call(*args)
      @filter[RC.current_profile].call(*args)
    end

    #
    #
    #
    def to_proc(exec=false)
      @filter[RC.current_profile].to_proc(exec)
    end

    #
    # Set current profile via ARGV switch.
    #
    def profile_switch(*switches)
      RC.profile_switch(*switches)
    end

  end

end
