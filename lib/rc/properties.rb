module RC

  # Project properties make it easy for configurations to utilize
  # information about a project for config settings. Properties
  # are stored in a global variables called `$properties`.
  #
  #   $properties.name #=> 'rc'
  #
  # Properties derive from a project's `.index` file and `var/` files.
  # This may expand in the future to include a project's gemspec.
  #
  class Properties

    #
    # Initialize new Properties instance.
    #
    def initialize(path=nil)
      @root  = find_root(path || Dir.pwd)
      @index = load_index
    end

    #
    # Root directory of project.
    #
    # @return [String] Full path to project's root directory.
    #
    def root
      @root
    end

    #
    # Route missing method to index lookup and failing that var file lookup.
    #
    def method_missing(s)
      name = s.to_s.downcase
      index(name) || var(name)
    end

  private

    #
    #
    #
    def find_root(path)
      pwd  = File.expand_path(path)
      home = File.expand_path('~')

      while pwd != '/' && pwd != home
        return pwd if ROOT_INDICATORS.any?{ |r| File.exist?(File.join(pwd, r)) }
        pwd = File.dirname(pwd)
      end

      nil
    end

    #
    #
    #
    def index(name)
      @index[name]
    end

    #
    #
    #
    def var(name)
      return @var[name] if @var.key?(name)

      glob = File.join(root, 'var', name)
      file = Dir[glob].first
      if file
        data = File.read(file)
        if data =~ /\A(---|%YAML)/
          data = YAML.load(data)
        end
        @var[name] = data
      else
        nil
      end
    end

    #
    #
    #
    def load_index
      index = {}
      file = File.join(root, '.index')
      if File.exist?(file)
        begin
          index = YAML.load_file(file)
        rescue SyntaxError => error
          warn error.to_s
        end
      end
      index
    end

    #
    # @todo Support gemspec as properties source ?
    #
    def load_gemspec
      file = Dir['{*,,pkg/*}.gemspec'].first
      # ...
    end

  end

end
