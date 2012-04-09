require 'rake'

module Rake
  RC_FILES = '.config.rb', 'config.rb', 'Config.rb'

  class Application
    remove_const(:DEFAULT_RAKEFILES)
    DEFAULT_RAKEFILES = [
      'rakefile', 'Rakefile', 'rakefile.rb', 'Rakefile.rb',    
    ] + RC_FILES
  end

  def self.load_rakefile(path)
    case File.basename(path)
    when *RC_FILES
      # do nothing, RC will do it
    else
      load(path)
    end
  end
end

module RC
  class Configuration
    include Rake::DSL
  end
end

