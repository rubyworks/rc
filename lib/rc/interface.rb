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
  def self.configuration(gem=nil)
    if gem
      file = find(gem)
    else
      file = lookup
    end
    file ? Parser.parse(file) : {}
  end

  #
  def self.profiles(tool, options={})
    tool = tool.to_s
    gem  = options[:from]
    config(gem)[tool].keys
  end

  #
  # Get project configuration from another library.
  #
  # This method uses the Finder gem.
  #
  # @param [String] lib
  #   Library name.
  #
  # @return [Project,nil] Located project.
  #
  def self.find(lib)
    lib = lib.to_s
    return cache[lib] if cache.key?(lib)
    cache[lib] ||= Find.path(FILE_PATTERN, :from=>lib).first
  end

  #
  #
  #
  def self.lookup
    Dir[FILE_PATTERN].first
  end

  #
  # Find a toplevel module or class for corresponding tool.
  # This is used to process configuration in the appropriate
  # namespace.
  #
  # This lookup function is a bit primative, but efficient.
  # Given a tool name, it simply looks for a class or module
  # with a capialized or all uppercase form of the same name.
  #
#  def self.scope(tool)
#    name = tool.to_s.capitalize
#    if Object.const_defined?(name)
#      mod = Object.const_get(name)
#    elsif Object.const_defined?(name.upcase)
#      mod = Object.const_get(name.upcase)
#    end
#    return mod if Module === mod
#  end

  #
  #
  #
  def self.current_tool
    File.basename(ENV['tool'] || $0)
  end

  #
  #
  #
  def self.current_tool=(tool)
    ENV['tool'] = tool.to_s
  end

  #
  #
  #
  def self.current_profile
    ENV['profile'] || 'default'
  end

  #
  #
  #
  def self.current_profile=(profile)
    ENV['profile'] = (profile || 'default').to_s
  end

  #
  # Project properties.
  #
  # @todo Use cascading class instead of OpenStruct, e.g. Confstruct.
  #
  def self.properties
    $properties ||= Properties.new
  end
  
  #
  #
  #
  def self.bootstrap(toplevel=TOPLEVEL_BINDING.self)
    ## prime project proerties
    properties

    ## extend toplevel with confection processor
    toplevel.extend(RC::Processor)

    #tool    = ENV['tool']    || $0
    #profile = ENV['profile'] || 'default'

    #configuration.invoke(tool,profile)

    if file = Dir.glob('./{.c,c,C}onfig.rb').first
      load(file, true)
    end
  end

end
