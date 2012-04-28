module Courtier
  # External requirements.
  require 'yaml'
  require 'finder'

  # Internal requirements.
  require 'courtier/core_ext'
  require 'courtier/config'
  require 'courtier/configuration'
  #require 'courtier/config_filter'
  require 'courtier/properties'
  require 'courtier/setup'

  # The Interface module extends Courtier module.
  #
  # A tool can control Courtier configuration by loading `courtier` and calling the
  # toplevel `court` or `Courtier.setup` method with a block that handles the 
  # configuration for the feature as provided by a project's config file.
  #
  # The block will often need to be conditioned on the current profile and/or the
  # then current command. This is easy enough to do with #profile? and #command?
  # methods.
  #
  #   require 'courtier'
  #
  #   Courtier.setup('rspec') do |config|
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
    # with Courtier that would not otherwise do so.
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
    # Same as #setup.
    #
    alias_method :court, :setup

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

      return unless commands.include?(Courtier.current_command)

      switches.each do |switch|
        if index = ARGV.index(switch)
          Courtier.current_profile = ARGV[index+1]
        elsif arg = ARGV.find{ |a| a =~ /#{switch}=(.*?)/ }
          Courtier.current_profile = $1  # TODO: better match system
        end
      end
    end

  private

    #
    # Activate Courtier configuration.
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
        alias_method :require_without_courtier, :require

        def require(feature)
          result = require_without_courtier(feature)

          return result unless result

          Courtier.configure(feature)

          return result
        end
      end
    end

  public

    #
    #
    #
    def configure(feature)
      feature_config = Courtier.configuration[feature]

      return result unless feature_config

      if setup = Courtier.setup(feature)
        feature_config.each do |config|
          setup.call(config)
        end
      else
        feature_config.each do |config|
          config.call if config.command?
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

# Toplevel convenience method for `Courtier.setup`.
#
# @example
#   court 'qed' do |config|
#     QED.configure(config.profile, &config)
#   end
#
def self.court(tool, options={}, &block)
  Courtier.court(tool, options, &block)
end

