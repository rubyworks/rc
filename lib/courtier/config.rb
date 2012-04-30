module Courtier

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
    def initialize(tool, properties={}, &block)
      @property = {:profile=>'default'}

      @property[:command] = tool.to_s
      @property[:feature] = tool.to_s

      @block = block

      properties.each do |k, v|
        property(k,v)
      end
    end

    #
    # Get/set property.
    #
    def property(name, value=ArgumentError)
      name = name.to_sym

      return @property[name] if value == ArgumentError

      case name
      when :feature, :command, :profile
        @property[name] = value.to_s
      else
        @property[name] = value
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

    #
    # @todo Deprecate?
    #
    alias :tool :command

    #
    # The name of the profile to which this configuration belongs.
    #
    def profile
      @property[:profile]
    end

    #
    # The library from which this configuration derives.
    # This is a shortcut for `property(:from)`.
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
    # Most configuration are scripted. In thos cases the 
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

      if tool = args.shift
        props[:command] = tool.to_s
        props[:feature] = tool.to_s
      end

      if props[:profile]
        props[:profile] = (props[:profile] || :default).to_s
      end

      props.each do |k,v|
        return false unless property(k) == v
      end

      return true
    end

    #
    # Does the given `feature` match the config's feature?
    #
    # @return [Boolean]
    #
    def feature?(feature=Courtier.current_feature)
      self.feature == feature.to_s
    end

    #
    # Does the given `command` match the config's command?
    #
    # @return [Boolean]
    #
    def command?(command=Courtier.current_command)
      self.command == command.to_s
    end

    #
    # Does the given `profile` match the config's profile?
    #
    # @return [Boolean]
    #
    def profile?(profile=Courtier.current_profile)
      self.profile == (profile || :default).to_s
    end

    #
    # @todo The feature argument might not be needed.
    #
    #def configure(feature)
    #  return false if self.feature != feature 
    #
    #  if setup = Courtier.setup(feature)
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
    def apply?()
      return false unless command? if command
      return false unless profile? if profile
      return true
    end

  end

end
