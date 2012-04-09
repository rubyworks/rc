module RC
  # External requirements.
  require 'yaml'
  require 'finder'

  # Internal requirements.
  require 'rc/core_ext'
  require 'rc/config'
  require 'rc/configuration'
  require 'rc/tool_configuration'
  require 'rc/properties'

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
  def self.clear!
    @cache = {}
  end

  #
  def self.configuration(gem=nil)
    key = gem ? gem.to_s : nil #Dir.pwd
    cache[key] ||= Configuration.load(:from=>gem)
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
    ENV['profile']
  end

  #
  # Set current profile.
  #
  def self.current_profile=(profile)
    if profile
      ENV['profile'] = profile.to_s
    else
      ENV['profile'] = nil
    end
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
    tool    = options[:tool]    || current_tool
    profile = options[:profile] || current_profile

    configuration.each do |c|
      c.call if c.match?(tool, profile)
    end
  end

  #
  # Start RC.
  #
  def self.bootstrap
    properties  # prime global properties

    tweak = File.join(File.dirname(__FILE__), 'tweaks', current_tool + '.rb')
    if File.exist?(tweak)
      require tweak
    else
      begin
        require current_tool
      rescue LoadError      
      end
    end

    if proc = processor(current_tool)
      tool_config = ToolConfiguration.new(current_tool, configuration)
      proc.call(tool_config)
    else
      configure
    end
  end

  # @todo: I'm sure this, #bootstrap and #processor can be simplifed.
  def self.run(tool, &block)
    processor(tool, &block)
    require 'rc'
  end

end
