module Courtier

  # The Configuration class encapsulates a project/library's tool 
  # configuration.
  #
  class Configuration < Module

    #
    # Configuration is Enumerable.
    #
    include Enumerable

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
    # The `.rb` suffix is optional for `confile` variations, but recommended.
    # It is not optional for `config` b/c very old version of setup.rb script
    # still in use by some projects use `.config` for it's own purposes.
    #
    # TODO: Yes, there are really too many choices for config file name, but
    # we haven't been able to settle on a smaller list just yet. Please come
    # argue with us about what's best.
    #
    CONFIG_FILE = '{.c,C,c}onfi{g.rb,le.rb,le}'

    #
    # When looking up config file, it one of these is found
    # then there is no point to looking further.
    #
    ROOT_INDICATORS = %w{.git .hg _darcs .ruby}

    #
    # Load configuration file from local project or other gem.
    #
    # @param options [Hash] Load options.
    #
    # @option options [String] :from
    #   Name of gem or library.
    #
    def self.load(options={})
      if from = options[:from]
        file = Find.path(CONFIG_FILE, :from=>from).first
      else
        file = lookup(CONFIG_FILE)
      end
      new(file)
    end

    #
    # Initialize new Configuration object.
    #
    # @param [String] file
    #   Configuration file (optional).
    #
    def initialize(file=nil)
      @file = file

      @_config = Hash.new{ |h,k| h[k]=[] }
      #@_onload = Hash.new{ |h,k| h[k]=[] }

      # TODO: does this rescue make sense here?
      begin
        dsl = DSL.new(self)
        dsl.instance_eval(File.read(file), file) if file      
      rescue => e
        raise e if $DEBUG
        warn e.message
      end
    end

    #
    def evaluate(*args, &block)
      dsl = DSL.new(self)
      dsl.instance_eval(*args, &block)
    end

    #
    # Configure a tool.
    #
    # @param [Symbol] tool
    #   The name of the command or feature to configure.
    #
    # @param [Hash] opts
    #   Configuration options.
    #
    # @options opts [String] :command
    #   Name of command, or false if not a command configuration.
    #
    # @options opts [String] :feature
    #   Alternate require if differnt than command name.
    #
    # @options opts [String] :from
    #   Library from which to import configuration.
    #
    # @example
    #   profile :coverage do
    #     config :qed, :from=>'qed'
    #   end
    #
    def config(target, options={}, &block)
      #options[:profile] = (options[:profile] || 'default').to_s
      #options[:command] = command.to_s unless options.key?(:command)
      #options[:feature] = command.to_s unless options.key?(:feature)
      #command = options[:command].to_s

      # IDEA: other import options such as local file?

      configs_from(options).each do |c|
        @_config[target.to_s] << c.copy(options)
      end

      return unless block

      @_config[target.to_s] << Config.new(target, options, &block)
    end

=begin
    #
    #
    #
    def onload(feature, options={}, &block)
      #options[:profile] = (options[:profile] || 'default').to_s

      #options[:feature] = feature.to_s unless options.key?(:feature)
      #options[:command] = feature.to_s unless options.key?(:command)

      feature = options[:feature].to_s

      # IDEA: what about local file import?
      configs_from(options).each do |c|
        @_onload[feature] << c.copy(options)
      end

      return unless block

      @_onload[feature] << Config.new(feature, options, &block)
    end
=end

    #
    #
    #
    def [](feature)
      @_config[feature.to_s]
    end

    #
    # Iterate over each feature config.
    #
    # @example
    #   confgiuration.each do |feature, configs|
    #     configs.each do |config|
    #       ...
    #     end
    #   end
    #
    def each(&block)
      @_config.each(&block)
    end

    #
    # The number of feature configs.
    #
    def size
      @_config.size
    end

    #
    # Get a list of the defined configurations.
    #
    # @return [Array] List of all defined configurations.
    #
    def to_a
      list = []
      @_config.each do |feature, configs|
        list.concat(configs)
      end
      list
    end

    #
    # @deprecated
    #
    alias :configurations :to_a

    #
    # Get a list of defined profiles names for the given +command+.
    # use the current command if no +command+ is given.
    #
    def profile_names(command=nil)
      command = command || Courtier.current_command

      list = []
      @_config.each do |feature, configs|
        configs.each do |c|
          if c.command?(command)
            list << c.profile
          end
        end
      end
      list.uniq
    end

    #def inspect
    #  "#<Courtier::Configuration:#{object_id} @file=#{@file}>"
    #end

  private

    #
    # Search upward from working directory.
    #
    def self.lookup(glob, flags=0)
      pwd  = File.expand_path(Dir.pwd)
      home = File.expand_path('~')
      while pwd != '/' && pwd != home
        if file = Dir.glob(File.join(pwd, glob), flags).first
          return file
        end
        break if ROOT_INDICATORS.any?{ |r| File.exist?(File.join(pwd, r)) }
        pwd = File.dirname(pwd)
      end
      return nil   
    end

    # TODO: other import options such as local file?

    #
    #
    #
    def configs_from(options)
      from = options[:from]
      list = []

      return list unless from

      if Array === from
        from_name, from_opts = *from
      else
        from_name, from_opts = from, {}
      end

      from_config = Courtier.configuration(from_name)

      from_opts[:feature] = options[:feature] unless from_opts.key?(:feature) if options[:feature]
      from_opts[:command] = options[:command] unless from_opts.key?(:command) if options[:command]
      from_opts[:profile] = options[:profile] unless from_opts.key?(:profile) if options[:profile]

      from_opts[:feature] = from_opts[:feature].to_s if from_opts[:feature]
      from_opts[:command] = from_opts[:command].to_s if from_opts[:command]
      from_opts[:profile] = from_opts[:profile].to_s if from_opts[:profile]

      from_config.each do |ftr, confs|
        confs.each_with_index do |c, i|
          if c.match?(from_opts)
            list << c.copy(options)
          end
        end
      end

      list
    end

    #
    class DSL

      #
      #
      #
      def initialize(configuration)
        @configuration = configuration
        @_options = {}
      end

      #
      #
      #
      def profile(name, &block)
        raise SyntaxError, "nested profile sections" if @_options[:profile]
        @_options[:profile] = name.to_s
        instance_eval(&block)
        @_options.delete(:profile)
      end

      #
      # Profile block.
      #
      # @param [String,Symbol] name
      #   A profile name.
      #
      def profile(name, state={}, &block)
        raise SyntaxError, "nested profile sections" if @_options[:profile]
        original_state = @_options.dup
        @_options.update(state)
        @_options[:profile] = name.to_s
        instance_eval(&block)
        @_options = original_state
      end

      #
      #
      def config(command, options={}, &block)
        nested_keys = @_options.keys & options.keys.map{|k| k.to_sym}
        raise ArgumentError, "nested #{nested_keys.join(', ')}" unless nested_keys.empty?

        options = @_options.merge(options)
        @configuration.config(command, options, &block)
      end

      #
      #
      def onload(feature, options={}, &block)
        nested_keys = @_options.keys & options.keys.map{|k| k.to_sym}
        raise ArgumentError, "nested #{nested_keys.join(', ')}" unless nested_keys.empty?

        options = @_options.merge(options)
        options[:onload] = true
        @configuration.config(feature, options, &block)
      end

    end

  end

end
