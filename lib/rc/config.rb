module Confection

  # Config encapsulates a single configuration entry as defined
  # in a project's configuration file.
  # 
  class Config

    #
    # Initialize Config instance. Config instances are per-configuration,
    # which means they are associated with one and only one config entry.
    #
    def initialize(tool, profile, context, value, &block)
      self.tool    = tool
      self.profile = profile
      self.value   = value
      self.block   = block if block

      @context = context
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
    # Some configuration are simple values. In those cases
    # the `@value` attributes holds the object, otherwise it
    # is `nil`. 
    #
    def value
      @value
    end

    #
    # Set the configuration value.
    #
    # @param [Object] value
    #   The configuration value.
    #
    def value=(value)
      @block = nil
      @value = value
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
      @value = nil
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
    # Call the procedure. Configuration procedures are evaluated
    # in the scope of a per-configuration file context instance,
    # which is extended by the {DSL} evaluation context.
    #
    def call(*args)
      #@value || @block.call(*args)
      @value || @context.instance_exec(*args, &block)
    end

    #
    # Convert the underlying procedure into an `instance_exec`
    # procedure. This allows the procedure to be evaluated in
    # any scope that it is be needed.
    #
    def to_proc
      if value = @value
        lambda{ value }
      else
        block = @block
        lambda do |*args|
          instance_exec(*args, &block)
        end
      end
    end

    #
    # Return the value or procedure in the form of a Hash.
    #
    # @return [Hash]
    #
    def to_h
      (@value || HashBuilder.new(&@block)).to_h
    end

    #
    # Return the value or procedure in the form of a String.
    #
    # @return [String]
    #
    def to_s
      (@value || call).to_s
    end

    #
    # Alias for #to_s.
    #
    # @todo Should this alias be deprecated?
    #
    alias text to_s

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
    # Ruby 1.9 defines #inspect as #to_s, ugh.
    #
    def inspect
      "#<#{self.class.name}:#{object_id} @tool=%s @profile=%s>" % [tool.inspect, profile.inspect]
    end

  end

end
