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
  #   RC.config_proc(:rspec) do |config|
  #     # configuration of current profile
  #     RSpec.configure(&config)
  #   end
  #
  # Or
  #
  #   require 'rc/api'
  #
  #   RC.config_proc(:qed) do |profile, config|
  #     # configuration of each profile
  #     QED.profile(profile, &config)
  #   end
  #
  # This lets RC how to handle configuration of respective tool.
  #
  # Then, just before the tool is ready to execute,
  #
  #   RC.configure!
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

      configuration(gem).profile_name(tool)
    end

    #
    # Get current tool.
    #
    def current_tool
      File.basename(ENV['tool'] || $0)
    end

    #
    # Set current tool.
    #
    def current_tool=(tool)
      ENV['tool'] = tool.to_s
    end

    #
    # Get current profile.
    #
    def current_profile
      ENV['profile'] || 'default'
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
    #
    #
    #def current_config
    #  ConfigFilter.new(configuration, :tool=>current_tool, :profile=>current_profile)
    #end

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
    # Set current profile via ARGV switch.
    #
    # @example
    #   profile_switch('-p', '--profile')
    #
    def profile_switch(*switches)
      switches.each do |switch|
        if index = ARGV.index(switch)
          self.current_profile = ARGV[index+1]
        end
      end
    end

    #
    # Get/set current configuration callback. Tools can use
    # this to gain control over the configuration proccess.
    #
    # The block should take a single argument for a Config
    # object. Keep in mind this procedure can be called multiple
    # times.
    #
    # This might be used to save the configuration for
    # a later execution, or to evaluate the configuration
    # in a special scope, or both.
    #
    # Keep in mind that if configurations are evaluated in
    # a different scope, they may not be able to utilize
    # any shared methods defined in the config file.
    #
    # @example
    #   RC.current_proc('foo') do |config|
    #     config.call
    #   end
    #
    def current_proc(tool, &block)
      @current_proc ||= {}
      @current_proc[tool.to_s] = block if block
      @current_proc[tool.to_s]
    end

    #
    # Get/set per-profile configuration callback. Tools can use
    # this to gain control over the configuration proccess.
    #
    # @example
    #   RC.profile_proc('qed') do |name, config|
    #     QED.configure(name, &config)
    #   end
    #
    def profile_proc(tool, &block)
      @profile_proc ||= {}
      @profile_proc[tool.to_s] = block if block
      @profile_proc[tool.to_s]
    end

    #
    # Define configuration callback procedure(s). This is a convenience method for
    # the other two callback procedures, namely #current_proc and #profile_proc.
    # If the block given has an arity of `1`, then #current_proc is set. Otherwise
    # the #profile_proc is set and #current_proc is set to a no-op. These two modes
    # fit typical usage, which is why this convenience method is provided.
    #
    def config_proc(tool, options={}, &block)
      properties  # prime global properties

      if block
        if block.arity == 1
          current_proc(tool, &block)
        else
          profile_proc(tool, &block)
          current_proc(tool){}  # no current_proc in this case
        end
      else
        raise ArgumentError, "no block given"
      end

      require 'rc' # now bootstrap
    end

    #
    # Alias for #config_proc. This is the original name, so we
    # keep it for compatibility.
    #
    alias :setup, :config_proc

    #
    # Tools use this method to initialize the RC configuration
    # bootstrap.
    #
    def configure!
      require 'rc' #bootstrap ?
    end

  private

    #
    # Start RC automatically.
    #
    def bootstrap
      @bootstrap ||= (
        properties  # prime global properties

        # FIXME: It is not possible for the tool to use #profile_switch
        # first, so it may not be possible to have preconfigurations.
        #preconfigure

        tweak = File.join(TWEAKS_DIR, current_tool + '.rb')
        if File.exist?(tweak)
          require tweak
        else
          begin
            require current_tool
          rescue LoadError
            #warn ""
          end
        end

        cc = RC.current_proc(current_tool)
        configuration.each do |config|
          if pc = RC.profile_proc(config.tool)
            pc.call(config.profile, config)
          end
          if config.match?(current_tool, current_profile)
            cc ? cc.call(config) : config.call
          end
        end

        true
      )
    end

    #
    # Setup configuration.
    #
    def preconfigure(options={})
      tool    = options[:tool]    || current_tool
      profile = options[:profile] || current_profile

      preconfiguration.each do |c|
        c.call if c.match?(tool, profile)
      end
    end

    #
    #
    #
    def parse_arguments(*args)
      options  = Hash === args.last ? args.pop : {}
      argument = args.shift
      return argument, options
    end

  end

  extend Interface

end

