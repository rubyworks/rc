module RC

  # Mixin for TOPLEVEL scope for processing configurations.
  #
  module Processor

    #
    #
    #
    def profile(name, &block)
      original, @_profile = @_profile, name.to_s
      instance_eval(&block)
      @_profile = original
    end

    #
    # Run confgiruation.
    #
    # @example
    #   config :qed/:coverage do
    #     require 'simplecov'
    #   end
    #
    def config(tool, *args, &block)
      tool = tool.to_s
      data = args.shift
      opts = (Hash===args.last ? args.pop : {})

      if tool.index('/')
        tool, profile = tool.split('/')
      else
        profile = nil
      end

      raise SyntaxError, "nested profile sections" if profile && @_profile
      profile = profile || @_profile || 'default'

      current_tool    = RC.current_tool
      current_profile = RC.current_profile

      return unless current_tool    == tool
      return unless current_profile == profile

      begin
        require tool
      rescue LoadError => e
        warn e.message if $VERBOSE
      end

      if gem = opts[:from]
        # lookup project config file
        file = RC.find(gem)
        RC.current_tool    = opts[:tool]    if opts[:tool]
        RC.current_profile = opts[:profile] if opts[:profile]
        begin
          require file
        ensure
          RC.current_tool    = current_tool
          RC.current_profile = current_profile
        end
      end

      if data = args.shift
        raise ArgumentError, "must use data or block, not both" if block
        data  = data.tabto(0)
        block = Proc.new do
          YAML.load(data)
        end
      end

      return unless block

      main = eval('self', TOPLEVEL_BINDING)
      if main.respond_to?("rc_#{tool}")
        main.__send__("rc_#{tool}", &block)
      else
        block.call
      end

      #if scope = RC.scope(tool)
      #  if block.arity == 1
      #    block.call(scope)
      #  else
      #    scope.module_eval(&block)
      #  end
      #else
      #  block.call
      #end
    end

  end

end
