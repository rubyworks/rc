module RC
  # External requirements.
  require 'yaml'
  require 'finder'

  # Internal requirements.
  require 'rc/core_ext'
  require 'rc/config'
  require 'rc/configuration'
  #require 'rc/config_filter'
  require 'rc/properties'
  require 'rc/setup'

  # The Interface module extends RC module.
  #
  # A tool can control RC configuration by loading `rc/api` and calling the
  # `RC.configure` method. There are two approaches to usage, which is used
  # depends on the needs of the tool. The distinction between the two uses in
  # depends on the arguments and arity of the block passed to the `configure()`
  # method.
  #
  #   require 'rc/api'
  #
  #   RC.setup('rspec') do |tool|
  #     # configuration of current profile
  #     tool.config_proc do |config|
  #       RSpec.configure(&config)
  #     end
  #   end
  #
  # Or
  #
  #   require 'rc/api'
  #
  #   RC.setup('qed') do |tool|
  #     # configuration of each profile
  #     tool.config_proc do |profile, config|
  #       QED.profile(profile, &config)
  #     end
  #   end
  #
  # This lets RC know how to handle configuration of the respective tool.
  #
  # Then, to process the configuration, just before the tool is ready to execute,
  # call the `commit_configuruation` method.
  #
  #   RC.commit_configuration
  #
  # It's important to not call `RC.configure!` in "load space". That is
  # to say, do not call it in code that is run when loading a library.
  # It ought to be run as part of commands executation procedure.
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

    # TODO: Maybe properties should comf Configuration class and be per-gem.
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
    # Specialize feature's configuration setup.
    #
    def setup(tool, options={}, &block)
      @setup ||= {}
      @setup[tool.to_s] = Setup.new(tool, options, &block) if block
      @setup[tool.to_s]
    end

    #
    # Set current profile via ARGV switch. This is done immediately,
    # setting `ENV['profile']` to the switch value if this setup is
    # for the current commandline tool. The reason it is done immediately,
    # rather than assigning it in bootstrap, is b/c option parsers somtimes
    # consume ARGV as they parse it, and by then it would too late.
    #
    # NOTE: If this approach proves to be an issue we might be able to
    # move it to bootstrap and just make a copy of ARGV here for later use.
    #
    # @example
    #   profile_switch('-p', '--profile')
    #
    def profile_switch(*switches)
      commands = []
      commands << switches.shift.to_s until switches.first.to_s.start_with?('-')
      commands << @feature if commands.empty?

      return unless commands.include?(RC.current_command)

      switches.each do |switch|
        if index = ARGV.index(switch)
          RC.current_profile = ARGV[index+1]
        elsif arg = ARGV.find{ |a| a =~ /#{switch}=(.*?)/ }
          RC.current_profile = $1  # TODO: better match system
        end
      end
    end

  private

    #
    # Activate RC configuration.
    #
    def bootstrap
      @bootstrap ||= (
        properties  # prime global properties

        tweak = File.join(TWEAKS_DIR, current_command + '.rb')
        if File.exist?(tweak)
          require tweak # FIXME: invoke necessary config's b/c of this
        end

        bootstrap_require

        true
      )
    end

    # TODO: Need to override `Kernel.require` class method too.

    #
    # Override require.
    #
    def bootstrap_require
      Kernel.module_eval do
        alias_method :require_without_rc, :require

        def require(feature)
          result = require_without_rc(feature)

          return result unless result

          feature_config = RC.configuration[feature]

          return result unless feature_config

          if setup = RC.setup(feature)
            feature_config.each do |config|
              setup.call(config)
            end
          else
            feature_config.each do |config|
              config.call if config.command?
            end
          end

          return result
        end
      end
    end

    ##
    ## Setup configuration.
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

end

# Toplevel convenience method for `RC.setup`.
#
# @example
#   court 'qed' do |config|
#     QED.configure(config.profile, &config)
#   end
#
def self.court(tool, options={}, &block)
  RC.setup(tool, options, &block)
end

