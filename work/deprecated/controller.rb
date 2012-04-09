module Confection

  # The Controller class is used to encapsulate the various methods of invocation
  # that are posible on configuration blocks. It applies those invocations 
  # across it's set of configurations.
  #
  class Controller

    include Enumerable

    #
    # Initialize new Controller instance.
    #
    # @param [Object] scope
    #
    # @param [Array<Config>] configs
    #
    def initialize(scope, *configs)
      @scope   = scope
      @configs = configs
    end

    #
    # Iterate over each config.
    #
    def each(&block)
      @configs.each(&block)
    end

    #
    # Number of configs.
    #
    def size
      @configs.size
    end

    #
    # Execute the configuration code.
    #
    def call(*args)
      result = nil
      each do |config|
        result = config.call(*args)
      end
      result
    end

    #
    # Special configuration call.
    #
    def configure
      result = nil
      each do |config|
        case config.arity
        when 0
          exec
        when 1
          result = config.call(@scope)
        end
      end
      result
    end

    #
    # Evaluate configuration in the context of the caller.
    #
    # This is the same as calling:
    #
    #   instance_exec(*args, &config)
    #
    def exec(*args)
      result = nil
      each do |config|
        if config.respond_to?(:to_proc)
          #@scope.extend(config.dsl) # ?
          result = @scope.instance_exec(*args, &config)
        end
      end
      result
    end

    #
    # Load config as script code in context of TOPLEVEL.
    #
    # This is the same as calling:
    #
    #   main = ::TOPLEVEL_BINDING.eval('self')
    #   main.instance_exec(*args, &config)
    #
    def main_exec(*args)
      result = nil
      main = ::Kernel.eval('self', ::TOPLEVEL_BINDING)  # ::TOPLEVEL_BINDING.eval('self') [1.9+]
      each do |config|
        if config.respond_to?(:to_proc)
          #main.extend(config.dsl)
          result = main.instance_exec(*args, &config)
        end
      end
      result
    end

    # @deprecated Alias for `#main_exec` might be deprecated in future.
    alias load main_exec

    #
    # Only applicable to script and block configs, this method converts
    # a set of code configs into a single block ready for execution.
    #
    def to_proc
      #properties = ::Confection.properties  # do these even matter here ?
      __configs__ = @configs
      block = Proc.new do |*args|
        result = nil
        #extend dsl  # TODO: extend DSL into instance context ?
        __configs__.each do |config|
          if config.respond_to?(:to_proc)
            result = instance_exec(*args, &config)
          end
        end
        result
      end
    end

    #
    # Configurations texts joins together the contents of each
    # configuration separated by two newlines (`\n\n`).
    #
    def to_s
      txt = []
      @configs.each do |c|
        txt << c.to_s #if c.text
      end
      txt.join("\n\n")
    end

    alias text to_s

    #
    #
    #
    def to_h
      hsh = {}
      @configs.each do |c|
        hsh.merge!(c.to_h)
      end
      hsh
    end

    ##
    ## Treat configurations as YAML mappings, load, merge and return.
    ##
    #def yaml
    #  @configs.inject({}) do |h, c|
    #    h.merge(c.yaml)
    #  end
    #end

    #
    # Inspection string for controller.
    #
    def inspect
      "#<#{self.class}##{object_id}>"
    end

  end

  #
  #class NullController
  #  def exec(*); end
  #  def call(*); end
  #  def text; ''; end
  #  alias to_s text
  #end

end
