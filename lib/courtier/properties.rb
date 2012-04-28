module Courtier

  # Currently properties derive from a project's .ruby file.
  # This will be expanded upon in future version to allow 
  # additional customization.
  #
  # @todo Lookup project root directory.
  #
  class Properties

    #
    #
    #
    DATA_FILE = '.ruby'

    #
    #
    #
    def initialize
      @data = {}

      if file = Dir[DATA_FILE].first
        @data.update(YAML.load_file(file))
      end
    end

    #
    #
    #
    def method_missing(s)
      @data[s.to_s]
    end

  private

    # @todo Support gemspec as properties source ?
    def import_gemspec
      file = Dir['{*,,pkg/*}.gemspec'].first
      # ...
    end

  end

end
