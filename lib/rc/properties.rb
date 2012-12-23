module RC

  # Project properties.
  #
  # Currently properties derive from a project's .index file,
  # if it has one. This will be expanded upon in future version
  # to allow sources, such as a gemspec.
  #
  class Properties

    #
    #
    #
    DATA_FILE = '.index'

    #
    #
    #
    def initialize(path=nil)
      @data = {}
      @root = find_root(path || Dir.pwd)

      load_index
    end

    #
    # Root directory of project.
    #
    def root
      @root
    end

    #
    #
    #
    def method_missing(s)
      @data[s.to_s]
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
    def load_index
      file = File.join(root, '.index')
      if File.exist?(file)
        begin
          data = YAML.load_file(file)
          @data.update(data)
        rescue SyntaxError => error
          warn error.to_s
        end
      end
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
