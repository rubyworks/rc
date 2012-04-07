module RC

  # Parse a configuration file. This is primarily used
  # to get a list of defined profiles from a given tool.
  #
  class Parser < Module

    # Parse a file.
    #
    # @param [String] File path.
    #
    # @return [Hash] Configurations.
    #
    # @todo Does the exception rescue make sense here?
    #
    def self.parse(file, table=nil)
      begin
        text = File.read(file)
      rescue => e
        raise e if $DEBUG
        warn e.message
      end
      parser = new(table)
      parser.instance_eval(text, file)
      parser.configurations
    end

    #
    # Initialize new Parser object.
    #
    # @param [String] file
    #   Configuration file to load.
    #
    # @param [Hash] table
    #   The configuration storage instance.
    #
    def initialize(table=nil)
      @_table = table || Hash.new{ |h,k| h[k] = {} }
      @_state  = {}
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
        from_store   = RC.config(from)
        from_tool    = (options[:tool]    || tool).to_s
        from_profile = (options[:profile] || profile).to_s

        @_table[tool] ||= {}
        @_table[tool][profile] ||= []
        @_table[tool][profile].concat(from_store[fron_tool][from_profile])

        return unless block
      end

      @_table[tool] ||= {}
      @_table[tool][profile] ||= []
      @_table[tool][profile] << block
    end

    #
    #
    #
    def configurations
      @_table
    end

  end

end
