module RC

  class Profile
    include Enumerable 

    def initialize(config, tool, profile)
      @config  = config
      @tool    = tool
      @profile = profile

      @list = config.map do |c|
        c.match?(tool, profile)
      end
    end

    #
    attr :tool

    #
    def name
      @profile
    end

    #
    #
    #
    def each(&block)
      @list.each do
        block
      end
    end

    #
    #
    #
    def size
      @list.size
    end

    #
    # Call each config.
    #
    def call(*args)
      @list.each do |c|
        if c.profile?(RC.current_profile)
          c.call(*args)
        end
      end
    end

    #
    # Convert to Proc.
    #
    def to_proc(exec=false)
      list = @list
      if exec
        Proc.new do |*args|
          list.each{ |c| instance_exec(*args, &c) }
        end
      else
        Proc.new do |*args|
          list.each{ |c| c.call(*args) }
        end
      end
    end

  end

end
