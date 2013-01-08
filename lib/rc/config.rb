module RC

  # Config encapsulates a single configuration entry as defined in a project's
  # ruby rc file. A config consists of a possible `command`, `feature`,
  # `profile` and `onload` flag.
  #
  # If `command` or `feature` are nil, then the configuration applies to all
  # commands and/or features.
  #
  # If profile is `nil` it automatically becomes `default`, which is the 
  # profile used when no profile is specified.
  #
  class Config

    #
    # Initialize Config instance. Config instances are per-configuration,
    # which means they are associated with one and only one config entry.
    #
    # @param [#to_s] target 
    #   The command or feature name. (optional)
    #
    # @param [Hash] properties
    #   Any additional properties associated with the config entry.
    #
    def initialize(*args, &block)
      properties = (Hash === args.last ? args.pop : {})
      target     = args.first

      @property = {:command=>nil, :feature=>nil, :profile=>'default'}

      if target
        @property[:command] = target.to_s
        @property[:feature] = target.to_s
      end

      @block = block

      properties.each do |k, v|
        property(k,v)
      end
    end

    #
    # Get/set property.
    #
    def property(name, value=ArgumentError)
      if value == ArgumentError
        get(name)
      else
        set(name, value)
      end
    end

    #
    # The feature being configured.
    #
    def feature
      @property[:feature]
    end

    #
    # The name of command being configured.
    #
    def command
      @property[:command]
    end

    # @todo Deprecate #tool alias?
    alias :tool :command

    #
    # The name of the profile to which this configuration belongs.
    #
    def profile
      @property[:profile]
    end

    #
    # The library from which this configuration derives.
    #
    def from
      @property[:from]
    end

    #
    #
    #
    def onload?
      @property[:onload]
    end

    #
    # Most configurations are scripted. In those cases the 
    # `@block` attributes holds the Proc instance, otherwise
    # it is `nil`.
    #
    attr :block

    #
    # IDEA: Presets would be processed first and not require the underlying feature.
    #
    #def preset?
    #  @property[:preset]
    #end

    #
    # The arity of the configuration procedure.
    #
    # @return [Fixnum] number of arguments
    #
    def arity
      @block ? @block.arity : 0
    end

    #
    # Require the feature.
    #
    def require_feature
      begin
        require feature
      rescue LoadError
        #warn "No such feature -- `#{feature}'"
      end
    end

    #
    # Call the configuration procedure.
    #
    def call(*args)
      block.call(*args) if block
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
    #  HashBuilder.new(&self).to_h
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
      tool = @property[:feature] || @property[:command]
      copy = self.class.new(tool, @property.dup, &@block)
      alt.each do |k,v|
        copy.property(k, v)
      end
      copy
    end

    #
    # Match config against tool and/or profile names.
    #
    # @return [Boolean]
    #
    def match?(*args)
      props = Hash === args.last ? args.pop : {}

      if target = args.shift
        props[:command] = target.to_s
        props[:feature] = target.to_s
      end

      if props[:profile]
        props[:profile] = (props[:profile] || :default).to_s
      end

      props.each do |k,v|
        pv = property(k)
        return false unless (pv.nil? || pv == v)
      end

      return true
    end

    #
    # Does the given `feature` match the config's feature?
    #
    # @return [Boolean]
    #
    def feature?(feature=RC.current_feature)
      return true if self.feature.nil?
      self.feature == feature.to_s
    end

    #
    # Does the given `command` match the config's command?
    #
    # @return [Boolean]
    #
    def command?(command=RC.current_command)
      return true if self.command.nil?
      self.command == command.to_s
    end
    alias_method :tool, :command?

    #
    # Does the given `profile` match the config's profile?
    #
    # @return [Boolean]
    #
    def profile?(profile=RC.current_profile)
      self.profile == (profile || 'default').to_s
    end

    #
    # @todo The feature argument might not be needed.
    #
    #def configure(feature)
    #  return false if self.feature != feature 
    #
    #  if setup = RC.setup(feature)
    #    setup.call(self)
    #  else
    #    block.call if command?
    #  end
    #end

    ##
    ## Ruby 1.9 defines #inspect as #to_s, ugh.
    ##
    #def inspect
    #  "#<#{self.class.name}:#{object_id} @tool=%s @profile=%s>" % [tool.inspect, profile.inspect]
    #end

    #
    # Does the configuration apply?
    #
    # @return [Boolean]
    #
    def apply_to_command?
      return false if onload?
      return false unless command? if command
      return false unless profile? if profile
      return true
    end
    alias_method :apply_to_tool?, :apply_to_command?

    def apply_to_feature?
      return false unless onload?
      return false unless command? if command
      return false unless profile? if profile
      return true
    end

  private

    #
    # Get property.
    #
    def get(name)
      @property[name.to_sym]
    end

    #
    # Set property.
    #
    def set(name, value)
      case name.to_sym
      when :command
        self.command = value
      when :tool  # deprecate ?
        self.command = value
      when :feature
        self.feature = value
      when :profile
        self.profile = value
      else
        @property[name.to_sym] = value
      end
    end

    #
    def command=(name)
      @property[:command] = name ? name.to_str : nil
    end

    #
    def feature=(path)
      @property[:feature] = path ? path.to_str : nil
    end

    #
    def profile=(name)
      @property[:profile] = name ? name.to_str : 'default'
    end

  end

end
