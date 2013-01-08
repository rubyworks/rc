module RC

  # External requirements.
  require 'yaml'
  require 'finder'
  #require 'loaded'

  # Internal requirements.
  require 'rc/constants'
  require 'rc/required'
  require 'rc/core_ext'
  require 'rc/config'
  require 'rc/configuration'
  require 'rc/dsl'
  #require 'rc/config_filter'
  require 'rc/properties'
  require 'rc/setup'

  # The Interface module extends the RC module.
  #
  # A tool can control RC configuration by loading `rc/api` and calling the
  # `RC.configure` method with a block that handles the configuration
  # for the feature as provided by a project's config file.
  #
  # The block will often need to be conditioned on the current profile and/or the
  # the current command. This is easy enough to do with #profile? and #command?
  # methods.
  #
  # For example, is RSpec wanted to support RC out-of-the-box, the code would
  # look something like:
  #
  #   require 'rc/api'
  #
  #   RC.configure('rspec') do |config|
  #     if config.profile?
  #       RSpec.configure(&config)
  #     end
  #   end
  #
  module Interface

    #
    # The tweaks directory is where special augementation script reside
    # the are used to adjust behavior of certain popular tools to work
    # with RC that would not otherwise do so.
    #
    TWEAKS_DIR = File.dirname(__FILE__) + '/tweaks'

    #
    # Library configuration cache. Since configuration can be imported from
    # other libraries, we keep a cache for each library.
    #
    # @return [Hash]
    #
    def cache
      @cache ||= {}
    end

    #
    # Clear the library configuration cache. This is mostly used 
    # for testing.
    #
    def clear!
      @cache = {}
    end

    #
    # Load library configuration for a given +gem+. If no +gem+ is
    # specified then the current project's configuration is used.
    #
    # @return [Configuration]
    #
    def configuration(gem=nil)
      key = gem ? gem.to_s : nil #Dir.pwd
      cache[key] ||= Configuration.load(:from=>gem)
    end

    #
    # Return a list of names of defined profiles for a given +tool+.
    #
    # @param [#to_sym] tool
    #   Tool for which lookup defined profiles. If none given
    #   the current tool is used.
    #
    # @param [Hash] opts
    #   Options for looking up profiles.
    #
    # @option opts [#to_s] :gem
    #   Name of library from which to load the configuration.
    #
    # @example
    #   profile_names(:qed)
    #
    def profile_names(tool=nil, opts={})
      if Hash === tool
        opts, tool = tool, nil
      end

      tool = tool || current_tool
      gem  = opts[:from]

      configuration(gem).profile_names(tool)
    end

    #
    # Get current tool.
    #
    # @todo Not so sure `ENV['tool']` is a good idea.
    #
    def current_tool
      File.basename(ENV['tool'] || $0)
    end

    alias current_command current_tool

    #
    # Set current tool.
    #
    def current_tool=(tool)
      ENV['tool'] = tool.to_s
    end

    alias current_command= current_tool=

    #
    # Get current profile.
    #
    def current_profile
      ENV['profile'] || ENV['p'] || 'default'
    end

    #
    # Set current profile.
    #
    def current_profile=(profile)
      if profile
        ENV['profile'] = profile.to_s
      else
        ENV['profile'] = nil
      end
    end

    #
    # Properties of the current project. These can be used in a project's config file
    # to make configuration more interchangeable. Presently project properties are 
    # gathered from .index YAML or .gemspec.
    #
    # It's important to note that properties are not per-gem. Rather they are global
    # and belong only the current project.
    #
    def properties
      $properties ||= Properties.new
    end

    #
    # Remove a configuration setup.
    # 
    # NOTE: This is probably a YAGNI.
    #
    def unconfigure(tool)
      @setup[tool.to_s] = false
    end

    alias :unset :unconfigure

    #
    # Define a custom configuration handler.
    #
    # If the current tool matches the given tool, and autoconfiguration is not being used,
    # then configuration is applied immediately.
    #
    def configure(tool, options={}, &block)
      tool = tool.to_s

      @setup ||= {}

      if block
        @setup[tool] = Setup.new(tool, options, &block)

        if tool == current_tool
          configure_tool(tool) unless autoconfig?
        end
      end     

      @setup[tool]
    end

    #
    # Original name of `#configure`.
    #
    def setup(tool, options={}, &block)
      configure(tool, options, &block)
    end

    #
    # Set current profile via ARGV switch. This is done immediately,
    # setting `ENV['profile']` to the switch value if this setup is
    # for the current commandline tool. The reason it is done immediately,
    # rather than assigning it in bootstrap, is b/c option parsers somtimes
    # consume ARGV as they parse it, and by then it would too late.
    #
    # @example
    #   RC.profile_switch('qed', '-p', '--profile')
    #
    def profile_switch(command, *switches)
      return unless command.to_s == RC.current_command

      switches.each do |switch, envar|
        if index = ARGV.index(switch)
          self.current_profile = ARGV[index+1]
        elsif arg = ARGV.find{ |a| a =~ /#{switch}=(.*?)/ }
          value = $1
          value = value[1..-2] if value.start_with?('"') && value.end_with?('"')
          value = value[1..-2] if value.start_with?("'") && value.end_with?("'")
          self.currrent_profile = value
        end
      end
    end

    #
    # Set enviroment variable(s) to command line switch value(s). This is a more general
    # form of #profile_switch and will probably not get much use in this context.
    #
    # @example
    #   RC.switch('qed', '-p'=>'profile', '--profile'=>'profile')
    #
    def switch(command, switches={})
      return unless command.to_s == RC.current_command

      switches.each do |switch, envar|
        if index = ARGV.index(switch)
          ENV[envar] = ARGV[index+1]
        elsif arg = ARGV.find{ |a| a =~ /#{switch}=(.*?)/ }
          value = $1
          value = value[1..-2] if value.start_with?('"') && value.end_with?('"')
          value = value[1..-2] if value.start_with?("'") && value.end_with?("'")
          ENV[envar] = value
        end
      end
    end

    #
    #
    #
    def autoconfig?
      @autoconfig
    end

  protected

    #
    #
    #
    def autoconfigure
      @autoconfig = true
      configure_tool(current_tool)
    end

  private

    #
    # Configure current commnad.
    #
    def configure_tool(tool)
      tweak(tool)

      configs = RC.configuration[tool]

      return unless configs

      configs.each do |config|
        next unless config.apply_to_tool?
        config.require_feature if autoconfig?
        setup = setup(tool)
        next if setup == false  # deactivated
        setup ? setup.call(config) : config.call
      end
    end

    #
    # Setup the system.
    #
    def bootstrap
      @bootstrap ||= (
        properties  # prime global properties
        bootstrap_require
        true
      )
    end

    #
    # Tap into require via loaded hook. The hook is only
    # triggered on #require, not #load.
    #
    def bootstrap_require
      def RC.required(feature)
        config = RC.configuration[feature]
        if config
          config.each do |config|
            next unless config.apply_to_feature?
            config.call
          end
        end
        super(feature) if defined?(super)
      end
    end

    #
    #
    #
    def tweak(command)
      tweak = File.join(TWEAKS_DIR, command + '.rb')
      if File.exist?(tweak)
        require tweak
      end
    end

    ##
    ## IDEA: Preconfigurations occur before other command configs and
    ##       do not require feature.
    ##
    #def preconfigure(options={})
    #  tool    = options[:tool]    || current_tool
    #  profile = options[:profile] || current_profile
    #
    #  preconfiguration.each do |c|
    #    c.call if c.match?(tool, profile)
    #  end
    #end
  end

  # The Interface extends RC module.
  extend Interface

  # Prep the system.
  bootstrap

end
