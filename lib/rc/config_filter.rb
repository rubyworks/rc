module RC

  #
  class ConfigFilter
    include Enumerable

    #
    # Initialize new ConfigFilter.
    #
    # @param [Array<Config>] List if Config instances.
    #
    def initialize(configuration, criteria={})
      @configuration = configuration
      @criteria      = criteria

      @list = []

      configuration.each do |c|
        @list << c if c.match?(criteria)
      end
    end   

    #
    #
    #
    def tool
      @criteria[:tool]
    end

    #
    #
    #
    def profile
      @criteria[:profile]
    end

    #
    # Returns list of profiles.
    #
    def profiles
      @list.map{ |c| c.profile }
    end

    #
    #
    #
    def [](subset)
      return method_missing(:[]) if profile
      if tool
        criteria = @criteria.dup
        criteria[:profile] = subset
      else
        criteria = @criteria.dup
        criteria[:tool] = subset
      end
      self.class.new(@configuration, criteria)
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
