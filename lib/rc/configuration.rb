module RC

  # Configuration
  #
  class Configuration < Module

    #
    # Configuration file pattern. The standard configuration file name is
    # `Config.rb`, and that name should be used in most cases. However, 
    # `.config.rb` can also be use and will take precedence if found.
    # Conversely, `config.rb` (lowercase form) can also be used but has
    # the least precedence.
    #
    # Config files looked for in the order or precedence:
    #
    #   * `.config.rb`
    #   * `Config.rb`
    #   * `config.rb`
    #
    CONFIG_FILE = '{.c,C,c}onfig{.rb,}'

    #
    # When looking up config file, it one of these is found
    # then there is no point to looking further.
    #
    ROOT_INDICATORS = %w{.git .hg _darcs} #.ruby

    #
    # Initialize new Configuration object.
    #
    def initialize(options={})
      @library = options[:from]

      @_list  = []
      @_state = {}

      if @library
        @file = Find.path(CONFIG_FILE, :from=>@library).first
      else
        @file = lookup(CONFIG_FILE)
      end

      # TODO: does this rescue make sense here?
      begin
        import(@file) if @file
      rescue => e
        raise e if $DEBUG
        warn e.message
      end
    end

    #
    # Profile block.
    #
    def profile(name, &block)
      raise SyntaxError, "nested profile sections" if @_state[:profile]
      original_state = @_state.dup
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
    # @todo Clean this code up.
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

      from = options[:from]

      raise ArgumentError, "too many arguments"      if args.first
      raise SyntaxError,   "nested profile sections" if profile && @_state[:profile]
      #raise ArgumentError, "use block or :from  setting" if options[:from]  && block

      profile = @_state[:profile] unless profile

      tool    = tool.to_s
      profile = (profile || 'default').to_s

      if from
        from_config  = RC.configuration(from)
        from_tool    = (options[:tool]    || tool).to_s
        from_profile = (options[:profile] || profile).to_s

        from_config.each do |c|
          if c.match?(from_tool, from_profile)
            @_list << Config.new(tool, profile, &c)
          end
        end

        return unless block
      end

      @_list << Config.new(tool, profile, &block)
    end

    #
    # @return [Hash] Defined configurations.
    #
    def configurations
      @_list
    end

    #
    # @return [ToolConfiguration] Subset of Configuration.
    #
    def [](tool)
      subset = @_list.select{ |c| c.tool?(tool) }
      ToolConfiguration.new(tool, subset)
    end

    # Configuration is Enumerable.
    include Enumerable

    # 
    def each(&block)
      @_list.each(&block)
    end

    #
    def size
      @_list.size
    end

  private

    #
    # Search upward from working directory.
    #
    def lookup(glob, flags=0)
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
