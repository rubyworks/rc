module RC

  # The File class is used to parse a configuration file, rather
  # than evaluate it. This is used when one needs to get information
  # about the configuration without running it, primarily to get
  # a list of available profiles.
  #
  class Parser < Module

    #
    # Create new DSL instance and parse file.
    #
    # @todo Does the exception rescue make sense here?
    #
    def self.parse(file, store=nil)
      parser = new(store)
      parser.parse(file)
    end

    #
    # Initialize new Parser object.
    #
    # @param [String] file
    #   Configuration file to load.
    #
    # @param [Hash] store
    #   The configuration storage instance.
    #
    def initialize(store=nil)
      @_store   = store || Hash.new{ |h,k| h[k] = Hash.new }

      @_options = {}
    end

    # TODO: Separate properties from project metadata ?

    #
    # Profile block.
    #
    def profile(name, options={}, &block)
      raise SyntaxError, "nested profile sections" if @_options[:profile]

      original_state = @_options.dup

      @_options.update(options)  # TODO: maybe be more exacting about this
      @_options[:profile] = name.to_sym

      instance_eval(&block)

      @_options = original_state
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
        profiles = args.shift unless args.first.index("\n")
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
      raise SyntaxError,   "nested profile sections" if profile && @_options[:profile]
      #raise ArgumentError, "use block or :from  setting" if options[:from]  && block

      profile = @_options[:profile] unless profile

      tool    = tool.to_sym
      profile = profile.to_sym if profile

      if from
        from_store   = Confection.config(fron)
        from_tool    = (options[:tool]    || tool)
        from_profile = (options[:profile] || profile)

        @_store[tool][profile] = from_store[fron_tool][from_profile]

        return unless block
      end

      #original_state = @_options.dup

      @_store[tool][profile] = block

      #@_options = original_state
    end

    # TODO: use `:default` profile instead of `nil` ?

    #
    # Evaluate script directory into current scope.
    #
    # @todo Make a core extension ?
    #
    def import(feature)
      file = Find.load_path(feature).first
      raise LoadError, "no such file -- #{feature}" unless file
      instance_eval(::File.read(file), file) if file
    end

    #
    # Parse a file.
    #
    # @param [String] File path.
    #
    # @return [Hash] Configurations.
    #
    def parse(file)
      begin
        text = File.read(file)
      rescue => e
        raise e if $DEBUG
        warn e.message
      end

      instance_eval(text, file)

      return @_store
    end

  end

end
