module RC

  # Config encapsulates a single configuration entry as defined
  # in a project's configuration file.
  # 
  class Config

    #
    # Initialize Config instance. Config instances are per-configuration,
    # which means they are associated with one and only one config entry.
    #
    def initialize(tool, profile, &block)
      self.tool    = tool
      self.profile = profile
      self.block   = block
    end

    #
    # The name of tool being configured.
    #
    attr :tool

    #
    # Change the tool name. Note, this will rarely be used since,
    # generally speaking, configurations tend to be very tool
    # specific.
    #
    def tool=(name)
      @tool = name.to_sym
    end

    #
    # The name of the profile to which this configuration belongs.
    #
    attr :profile

    #
    # Change the profile name.
    #
    def profile=(name)
      @profile = name.to_sym if name
    end

    #
    # Most configuration are scripted. In thos cases the 
    # `@block` attributes holds the Proc instance, otherwise
    # it is `nil`.
    #
    attr :block

    #
    # Set the configuration procedure.
    #
    # @param [Proc] procedure
    #   The configuration procedure.
    #
    def block=(proc)
      @block = proc.to_proc
    end

    #
    # The arity of the configuration procedure.
    #
    # @return [Fixnum] number of arguments
    #
    def arity
      @block ? @block.arity : 0
    end

    #
    # Call the configuration procedure.
    #
    def call(*args)
      block.call(*args)
    end

    #
    # Returns underlying block.
    #
    def to_proc
      block
    end

    ##
    ## Convert block into a Hash.
    ##
    ## @return [Hash]
    ##
    #def to_h
    #  (@value || HashBuilder.new(&@block)).to_h
    #end

    #
    # Copy the configuration with alterations.
    #
    # @param [Hash] alt
    #   Alternate values for configuration attributes.
    #
    # @return [Config] copied config
    #
    def copy(alt={})
      copy = dup
      alt.each do |k,v|
        copy.__send__("#{k}=", v)
      end
      copy
    end

    #
    #
    #
    def match?(tool, profile)
      tool    = tool.to_sym
      profile = profile.to_sym if profile

      self.tool == tool && self.profile == profile
    end

    #
    # Does the given `tool` match the config's tool?
    #
    def tool?(tool)
      self.tool == tool.to_sym
    end

    #
    # Does the given `profile` match the config's profile?
    #
    def profile?(profile)
      self.profile == profile.to_sym
    end

    ##
    ## Ruby 1.9 defines #inspect as #to_s, ugh.
    ##
    #def inspect
    #  "#<#{self.class.name}:#{object_id} @tool=%s @profile=%s>" % [tool.inspect, profile.inspect]
    #end

  end

end
