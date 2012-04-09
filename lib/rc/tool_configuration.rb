module RC

  # ToolConfiguration encapsulates configurations for a specific tool.
  # It is essentially a subset taken from a project's full set of
  # configurations.
  #
  class ToolConfiguration < Module
    include Enumerable

    #
    # Initialize new ToolConfiguration.
    #
    # @param [String,Symbol] Tool name.
    #
    # @param [Configuraiton] Project configuration instance.
    #
    def initialize(tool, configuration)
      include configuration

      @_tool = tool.to_s
      @_list = configuration.select{ |c| c.tool?(tool) }
    end   

    #
    #
    #
    def tool
      @_tool
    end

    #
    #
    #
    def [](profile)
      @_list.select{ |c| c.profile?(profile) }
    end

    #
    #
    #
    def each(&block)
      @_list.each(&block)
    end

    #
    #
    #
    def size(&block)
      @_list.size
    end

  end

end
