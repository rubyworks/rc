module RC

  # The Configuration class encapsulates a project/library's tool 
  # configuration.
  #
  class Configuration < Module

    #
    # Configuration is Enumerable.
    #
    include Enumerable

    #
    # Configuration file pattern. The standard configuration file name is
    # `Config.rb`, and that name should be used in most cases. However, 
    # `.config.rb` can also be use and will take precedence if found.
    # Conversely, `config.rb` (lowercase form) can also be used but has
    # the least precedence.
    #
    # Config files looked for in the order or precedence:
    #
    #   * `.config.rb` or `.confile.rb`
    #   * `Config.rb`  or `Confile.rb`
    #   * `config.rb`  or `confile.rb`
    #
    # The `.rb` suffix is optional for `confile` variations, but recommended.
    # It is not optional for `config` b/c very old version of setup.rb script
    # still in use by some projects use `.config` for it's own purposes.
    #
    # TODO: Yes, there are really too many choices for config file name, but
    # we haven't been able to settle on a smaller list just yet. Please come
    # argue with us about what's best.
    #
    CONFIG_FILE = '{.c,C,c}onfi{g.rb,le.rb,le}'

    #
    # When looking up config file, it one of these is found
    # then there is no point to looking further.
    #
    ROOT_INDICATORS = %w{.git .hg _darcs .ruby}

    #
    # Load configuration file from local project or other gem.
    #
    # @param options [Hash] Load options.
    #
    # @option options [String] :from
    #   Name of gem or library.
    #
    def self.load(options={})
      if from = options[:from]
        file = Find.path(CONFIG_FILE, :from=>from).first
      else
        file = lookup(CONFIG_FILE)
      end
      new(file)
    end

    #
    # Initialize new Configuration object.
    #
    # @param [String] file
    #   Configuration file (optional).
    #
    def initialize(file=nil)
      @file = file

      @_store = []
      @_state = {}

      # TODO: does this rescue make sense here?
      begin
        instance_eval(File.read(file), file) if file      
      rescue => e
        raise e if $DEBUG
        warn e.message
      end
    end

    #
    # Profile block.
    #
    # @param [String,Symbol] name
    #   A profile name.
    #
    def profile(name, state={}, &block)
      raise SyntaxError, "nested profile sections" if @_state[:profile]
      original_state = @_state.dup
      @_state.update(state)
      @_state[:profile] = name.to_s
      instance_eval(&block)
      @_state = original_state
    end

    #
    # Configure a tool.
    #
    # @param [Symbol] tool
    #   The name of the tool to configure.
    #
    # @param [Hash] opts
    #   Configuration options.
    #
    # @options opts [String] :from
    #   Library from which to extract configuration.
    #
    # @example
    #   profile :coverage do
    #     config :qed, :from=>'qed'
    #   end
    #
    def config(tool, *args, &block)
      options = (Hash===args.last ? args.pop : {})

      # @todo Might we have an option to lockdown tool 
      #       So that we do without ToolConfiguration?

      case args.first
      when Symbol
        profile = args.shift
      when String
        profile = args.shift unless args.first.index("\n")
      end

      data = args.shift
      raise ArgumentError, "must use data or block, not both" if data && block
      if data
        data = data.tabto(0)
        block = Proc.new do
          YAML.load(data)
        end
      end

      raise ArgumentError, "too many arguments"      if args.first
      raise SyntaxError,   "nested profile sections" if profile && @_state[:profile]

      profile = @_state[:profile] unless profile

      # TODO: other options such as :file and/or :load ?

      from = options[:from]

      if from
        from_config  = RC.configuration(from)
        from_tool    = options[:tool]    || tool
        from_profile = options[:profile] || profile
        from_options = options.merge(:tool=>tool, :profile=>profile)

        from_config.each do |c|
          if c.match?(from_tool, from_profile)
            @_store << c.copy(from_options)
          end
        end

        return unless block
      end

      config = Config.new(tool, profile, options, &block)

      @_store << config
    end

    #
    # Iterate over each config.
    #
    def each(&block)
      @_store.each(&block)
    end

    #
    # The number of configs.
    #
    def size
      @_store.size
    end

    #
    # Get a list of the defined configurations. The list is a duplication
    # of the underlying list so it can't be easily tampered.
    #
    # @return [Array] List of defined configurations.
    #
    def to_a
      @_store.dup
    end

    #
    alias :configurations, :to_a

    #
    # Get a list of defined profiles names for the given +tool+.
    # use the current tool if no +tool+ is given.
    #
    def profile_names(tool=nil)
      tool = tool || RC.current_tool

      list = []
      each do |c|
        if c.tool?(tool)
          list << c.profile
        end
      end
      list.uniq
    end

  private

    #
    # Search upward from working directory.
    #
    def self.lookup(glob, flags=0)
      pwd  = File.expand_path(Dir.pwd)
      home = File.expand_path('~')
      while pwd != '/' && pwd != home
        if file = Dir.glob(File.join(pwd, glob), flags).first
          return file
        end
        break if ROOT_INDICATORS.any?{ |r| File.exist?(File.join(pwd, r)) }
        pwd = File.dirname(pwd)
      end
      return nil   
    end

  end

end
