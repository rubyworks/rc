module RC

  # ToolConfiguration encapsulates configurations for a specific tool.
  # It is essentially a subset taken from a project's full set of
  # configurations.
  #
  class ToolConfiguration < Module
    include Enumerable

    #
    #
    #
    def initialize(tool, configs)
      include configuration

      @_tool = tool.to_s
      @_list = configs
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
