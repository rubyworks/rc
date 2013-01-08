require 'rake'

RC.configure 'rake' do |config|
  Module.new do
    extend Rake::DSL
    module_eval(&config)
  end
end

module Rake
  RC_FILES = '.rubyrc', '.ruby'

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

# Must manually configure tweaked libraries.
#RC.send(:configure_tool, 'rake')

