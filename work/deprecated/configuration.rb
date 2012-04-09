module RC

  # Stores the config definitions.
  #
  class Configuration

    include Enumerable

    #
    # Configuration file pattern. The standard configuration file name is
    # `Config.rb`, and that name should be used in most cases. However, 
    # `.config.rb` can also be use and will take precedence if found.
    # Conversely, `config.rb` (lowercase form) can also be used but has
    # the least precedence.
    #
    # Config files looked for in the order or precedence:
    #
    #   * `.config.rb`
    #   * `Config.rb`
    #   * `config.rb`
    #
    CONFIG_FILE = '{.c,C,c}onfig{.rb,}'

    #
    # When looking up config file, it one of these is found
    # then there is no point to looking further.
    #
    ROOT_INDICATORS = %w{.git .hg _darcs} #.ruby

    #
    # Per library cache.
    #
    def self.cache
      @cache ||= {}
    end

    #
    #
    #
    def self.current
      name = '(current)'

      return cache[name] if cache.key?(name)

      cache[name] = (
        file = lookup(CONFIG_FILE)
        Configuration.new(file) if file
      )
    end

    #
    # Get configuration for given library +name+.
    #
    def self.from(name)
      name = name.to_s

      return cache[name] if cache.key?(name)

      cache[name] = (
        file = Find.path(CONFIG_FILE, :from=>name).first
        Configuration.new(file) if file
      )
    end

    #
    # Search upward from working directory.
    #
    def self.lookup(glob, flags=0)
      pwd  = File.expand_path(Dir.pwd)
      home = File.expand_path('~')
      while pwd != '/' && pwd != home
        if file = Dir.glob(File.join(pwd, glob), flags).first
          return file
        end
        break if ROOT_INDICATORS.any?{ |r| File.exist?(File.join(pwd, r)) }
        pwd = File.dirname(pwd)
      end
      return nil   
    end

    # Initialize new configuration.
    #
    # @param [String] file
    #
    def initialize(file)
      @file = file
      @tool_configs = {}

      parse(@file)
    end

    #
    #
    #
    def initialize_copy(other)
      @file         = other.file
      @parser       = other.parser
      @tool_configs = other.tool_configs
    end

    #
    #
    #
    def parser
      @parser ||= Parser.new(self)
    end

    #
    # Parse configuration file.
    #
    def parse(file)
      parser.parse(file)
    end

    #
    # Iterate over each configurations.
    #
    def each(&block)
      @tool_configs.each(&block)
    end

    #
    # The number of configurations.
    #
    # @return [Fixnum] config count
    #
    def size
      @tool_configs.size
    end

    #
    # Define a new configuration.
    #
    def config(tool, profile, &block)
      tool = tool.to_sym
      if @too_configs.key?(tool)
        config = @tool_configs[tool]
      else
        config = ToolConfigs.new(tool)
        @tool_configs[tool] = config
      end
      config.add(profile, &block)
    end

    #
    # Add a Config instance.
    #
    def <<(conf)
      raise TypeError, "not a Config instance -- `#{conf}'" unless Config === conf
      @list << conf
    end

    #
    # Add a list of Configs.
    #
    def concat(configs)
      configs.each{ |c| self << c }
    end

    #
    # Lookup configuration by tool and profile name.
    #
    # @todo Future versions should allow this to handle regex and fnmatches.
    #
    def lookup(tool, profile=nil)
      if profile == '*'
        select do |c|
          c.tool.to_sym == tool.to_sym
        end
      else
        profile = profile.to_sym if profile

        select do |c|
          c.tool.to_sym == tool.to_sym && c.profile == profile
        end
      end
    end

    #
    # Reduce configuration by tool name.
    #
    # @todo Future versions could allow this to handle regex and fnmatches.
    #
    def [](tool)
      copy = dup
      copy.list.select! do |c|
        c.tool.to_s == tool.to_s
      end
      copy
    end

    #
    # Returns list of profiles collected from all configs.
    #
    def profiles(tool)
      names = []
      each do |c|
        names << c.profile if c.tool == tool.to_sym
      end
      names.uniq.compact
    end

    #
    # Clear configs.
    #
    def clear!
      @list = []
    end

    #
    def first
      @list.first
    end

    #
    def last
      @list.last
    end

    #
    # Copy configuration from another project.
    #
    def import(tool, profile, options)
      from_tool    = options[:tool]    || tool
      from_profile = options[:profile] || profile

      case from = options[:from]
      when String, Symbol
        config = Configuration.from(from)
      else
        config = self
      end

      raise "no configuration found for `#{from}'" unless config

      configs = config.lookup(from_tool, from_profile)

      configs.each do |config|
        self << config.copy(:tool=>tool, :profile=>profile)
      end
    end

    #
    def properties
      @properties ||= Properties.new
    end

    #
    def invoke(tool, profile)
      each do |c|
        c.call if c.match?(tool, profile)
      end
    end

  protected

    #
    # List of configs.
    #
    def list
      @list
    end

  end

end
