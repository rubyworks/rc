module RC

  # Configuration's DSL
  #
  class DSL < Module

    #
    #
    #
    def initialize(configuration)
      @configuration = configuration
      @_options = {}
    end

    #
    def import(glob, opts={})
      @configuration.import(glob, *opts)
    end

    #
    #
    #
    #def profile(name, &block)
    #  raise SyntaxError, "nested profile sections" if @_options[:profile]
    #  @_options[:profile] = name.to_s
    #  instance_eval(&block)
    #  @_options.delete(:profile)
    #end

    #
    # Profile block.
    #
    # @param [String,Symbol] name
    #   A profile name.
    #
    def profile(name, state={}, &block)
      raise SyntaxError, "nested profile sections" if @_options[:profile]
      original_state = @_options.dup
      @_options.update(state)
      @_options[:profile] = name.to_s

      instance_eval(&block)

      @_options = original_state
    end

    #
    #
    def config(command=nil, options={}, &block)
      nested_keys = @_options.keys & options.keys.map{|k| k.to_sym}
      raise ArgumentError, "nested #{nested_keys.join(', ')}" unless nested_keys.empty?

      options = @_options.merge(options)

      @configuration.config(command, options, &block)
    end

    #
    #
    def onload(feature, options={}, &block)
      nested_keys = @_options.keys & options.keys.map{|k| k.to_sym}
      raise ArgumentError, "nested #{nested_keys.join(', ')}" unless nested_keys.empty?

      options = @_options.merge(options)
      options[:onload] = true

      @configuration.config(feature, options, &block)
    end

  end

end
