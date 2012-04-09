module RC

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
  FILE_PATTERN = '{.c,C,c}onfig{.rb,}'

  #
  def self.cache
    @cache ||= {}
  end

  #
  def self.configuration(gem=nil)
    gem = gem ? gem.to_s : gem
    cache[gem] ||= Configuration.new(:from=>gem)
  end

  #
  # @return [Array] List of profiles for given `tool`.
  #
  def self.profiles(tool, options={})
    tool = tool.to_s
    gem  = options[:from]
    configuration(gem).map{ |c| c.tool.to_s }
  end

  #
  # Get current tool.
  #
  def self.current_tool
    File.basename(ENV['tool'] || $0)
  end

  #
  # Set current tool.
  #
  def self.current_tool=(tool)
    ENV['tool'] = tool.to_s
  end

  #
  # Get current profile.
  #
  def self.current_profile
    ENV['profile'] || 'default'
  end

  #
  # Set current profile.
  #
  def self.current_profile=(profile)
    ENV['profile'] = (profile || 'default').to_s
  end

  #
  # Project properties.
  #
  def self.properties
    $properties ||= Properties.new
  end

  #
  # Get/set configuration processor. Tools can use this
  # to gain control over the configuration procedure.
  #
  # The block should take a single argument of the current
  # Configuration.
  #
  # This might be used to save the configuration for
  # a later execution, or to evaluate the procedures
  # in a special scope, or both.
  #
  # Keep in mind that if configurations are evaluated in
  # a different scope, they may not be able to utilize
  # any shared methods defined in the config file.
  #
  # @example
  #   RC.processor('qed') do |config|
  #     if i = ARGV.index('--profile') || ARGV.index('-p')
  #       ENV['profile'] = ARGV[i+1]
  #     end
  #     RC.configure
  #   end
  #
  def self.processor(tool, &block)
    @processors ||= {}
    @processors[tool.to_s] = block if block
    @processors[tool.to_s]
  end

  #
  # Setup configuration.
  #
  def self.configure(options={})
    tool    = (options[:tool]    || current_tool).to_s
    profile = (options[:profile] || current_profile).to_s

    configuration[tool][profile].each do |block|
      block.call
    end
  end

  #
  # Start RC.
  #
  def self.bootstrap
    properties  # prime global properties

    if proc = processor(current_tool)
      tool_config = ToolConfiguration.new(tool, configuration)
      proc.call(tool_config)
    else
      configure
    end
  end

end
