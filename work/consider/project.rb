module Confection

  # Project configuration.
  #
  class ProjectConfig

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
    PATTERN = '{.,}config{.rb,}'

    #
    # Per library cache.
    #
    def self.cache
      @cache ||= {}
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
    def self.load(lib=nil)
      if lib
        lib = lib.to_s
        return cache[lib] if cache.key?(lib)
        cache[lib] ||= (
          config_path = Find.path(PATTERN, :from=>lib).first
          config_path ? new(File.dirname(config_path)) : nil
        )
      else
        lookup
      end
    end

    #
    # Lookup configuation file.
    #
    # @param dir [String]
    #   Optional directory to begin search.
    #
    # @return [String] file path
    #
    def self.lookup(dir=nil)
      dir = dir || Dir.pwd
      home = File.expand_path('~')
      while dir != '/' && dir != home
        if file = Dir.glob(File.join(dir, PATTERN), File::FNM_CASEFOLD).first
          return new(File.dirname(file))
        end
        dir = File.dirname(dir)
      end
      return nil
    end

    #
    # Initialize new ProjectConfig.
    #
    # @param [String] root
    #   Project root directory.
    #
    def initialize(root)
      @root  = root
    end

    #
    # Project root directory.
    #
    # @return [String] project's root directory
    #
    attr :root

    #
    # Alias for #root.
    #
    alias :directory :root

    #
    # Configuration store tracks a project's confirguration entries.
    #
    def store
      @store ||= Store.new(*source)
    end

    #
    # The file path of the project's configuration file.
    #
    # @return [String] path to configuration file
    #
    def source
      Dir.glob(File.join(root, PATTERN), File::FNM_CASEFOLD).first
    end

    #
    # List of configuration profiles.
    #
    # @return [Array] profile names
    #
    def profiles(tool)
      store.profiles(tool)
    end

    #
    # Project properties.
    #
    # @todo Use cascading class, e.g. Confstruct.
    #
    def properties
      dotruby = File.join(directory,'.ruby')
      if File.exist?(dotruby)
        data = YAML.load_file(dotruby)
        OpenStruct.new(data)
      else
        OpenStruct.new
      end
    end

    #
    # Create a configuration controller.
    #
    # @param [Object] scope
    #   Context for which controller is being created.
    #
    # @param [Symbol] tool
    #   The tool of the configuration to select.
    #
    def controller(scope, tool, options={})
      profile = options[:profile]
      configs = store.lookup(tool, profile)
      Controller.new(scope, *configs)
    end

    #
    # Iterate over each configurations.
    #
    def each(&block)
      store.each(&block)
    end

    #
    # The number of configurations.
    #
    # @return [Fixnum] config count
    #
    def size
      store.size
    end

  end

end
