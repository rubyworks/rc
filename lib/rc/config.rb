module RC

  # Config encapsulates a single configuration entry as defined
  # in a project's configuration file.
  # 
  class Config

    #
    # Initialize Config instance. Config instances are per-configuration,
    # which means they are associated with one and only one config entry.
    #
    # @param [#to_sym] tool
    #   The tool's name.
    #
    # @param [#to_sym,nil] profile
    #   Profile name, or +nil+.
    #
    # @param [Hash] properties
    #   Any additional properties associated with the config entry.
    #
    def initialize(tool, profile, properties={}, &block)
      @properties = {}

      self.tool    = tool
      self.profile = profile || :default
      self.block   = block

      properties.each do |k, v|
        @properties[k.to_sym] = v || false
      end
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
    # @param [#to_sym] name
    #   The tool's name.
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
    # @param [#to_sym,nil] name
    #   Profile name, or +nil+.
    #
    def profile=(name)
      @profile = (name || :default).to_sym
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
    def block=(block)
      @block = block #.to_proc
    end

    #
    #
    #
    def preset?
      @properties[:preset]
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
    #  HashBuilder.new(&self)).to_h
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
    # Match config properties against given criteria.
    #
    # @return [Boolean]
    #
    def match_critera?(criteria={})
      criteria = criteria.dup

      tool    = criteria.delete(:tool)
      profile = criteria.delete(:profile)

      return false if tool    && tool.to_sym    != self.tool
      return false if profile && profile.to_sym != self.profile

      criteria.each do |k,v|
        return false unless @properties[k.to_sym] == v
      end

      return true
    end

    #
    # Match config against tool and/or profile names.
    #
    # @return [Boolean]
    #
    def match?(tool, profile=nil)
      tool = tool.to_sym
      if profile
        profile = profile.to_sym
        self.tool == tool && self.profile == profile
      else
        self.tool == tool
      end
    end

    #
    # Does the given `tool` match the config's tool?
    #
    # @return [Boolean]
    #
    def tool?(tool)
      self.tool == tool.to_sym
    end

    #
    # Does the given `profile` match the config's profile?
    #
    # @return [Boolean]
    #
    def profile?(profile)
      self.profile == (profile || :default).to_sym
    end

    ##
    ## Ruby 1.9 defines #inspect as #to_s, ugh.
    ##
    #def inspect
    #  "#<#{self.class.name}:#{object_id} @tool=%s @profile=%s>" % [tool.inspect, profile.inspect]
    #end

  end

end
