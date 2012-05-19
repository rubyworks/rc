module RC
  # External requirements.
  require 'yaml'
  require 'finder'
  require 'loaded'

  # Internal requirements.
  require 'rc/core_ext'
  require 'rc/config'
  require 'rc/configuration'
  #require 'rc/config_filter'
  require 'rc/properties'
  require 'rc/setup'

  # The Interface module extends RC module.
  #
  # A tool can control RC configuration by loading `rc` and calling the
  # toplevel `court` or `RC.setup` method with a block that handles the 
  # configuration for the feature as provided by a project's config file.
  #
  # The block will often need to be conditioned on the current profile and/or the
  # then current command. This is easy enough to do with #profile? and #command?
  # methods.
  #
  #   require 'rc'
  #
  #   RC.setup('rspec') do |config|
  #     if config.profile?
  #       RSpec.configure(&config)
  #     end
  #   end
  #
  module Interface

    #
    # Configuration file pattern. The standard configuration file name is
    # `Config.rb`, and that name should be used in most cases. However, 
    # `.config.rb` can also be use and will take precedence if found.
    # Conversely, `config.rb` (lowercase form) can also be used but has
    # the least precedence.
    #
    # Config files looked for in the order or precedence:
    #
    #   * `.config.rb` or `.confile.rb`
    #   * `Config.rb`  or `Confile.rb`
    #   * `config.rb`  or `confile.rb`
    #
    # Yes, there are really too many choices here, but we haven't been able
    # to settle on a smaller list just yet. Please come argue with us about
    # what's best.
    #
    FILE_PATTERN = '{.c,C,c}on{fig.rb,file,file.rb}'

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

    # TODO: Maybe properties should come from Configuration class and be per-gem.
    #       I don't see a use for imported properties, but just in case.

    #
    # Properties of the current project. These can be used in a project's config file
    # to make configuration more interchangeable. Presently project properties are 
    # gathered from .ruby YAML or .gemspec.
    #
    # NOTE: How properties are gathered will be refined in the future.
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
      @autoconfigure
    end

  private

    #
    #
    #
    def autoconfigure
      @autoconfig = true
      configure_tool(current_tool)
    end

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
    # Setup rc system.
    #
    def bootstrap
      @bootstrap ||= (
        properties  # prime global properties
        bootstrap_require
        true
      )
    end

    # TODO: Also add loaded callback ?

    #
    # Override require.
    #
    def bootstrap_require
      def Kernel.required(feature)
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
    ## IDEA: Preconfigurations occur before other comamnd configs and
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

  extend Interface

  bootstrap  # prepare system
end

# Toplevel convenience method for `RC.config_handler`.
#
# @example
#   configure 'qed' do |config|
#     QED.configure(config.profile, &config)
#   end
#
def self.configure(tool, options={}, &block)
  RC.configure(tool, options, &block)
end

