module RC

  # The Configuration class encapsulates a project/library's tool 
  # configuration.
  #
  class Configuration < Module

    #
    # Configuration is Enumerable.
    #
    include Enumerable

    #
    # Runtime configuration file glob pattern.
    #
    CONFIG_FILE = '.ruby{rc,}'

    class << self
      #
      # Load configuration file from local project or other gem.
      #
      # @param options [Hash] Load options.
      #
      # @option options [String] :from
      #   Name of gem or library.
      #
      def load(options={})
        if options[:from]
          load_from(options[:from])
        else
          load_local()
        end
      end

      #
      # Load configuration from another gem.
      #
      def load_from(gem)
        files = Find.path(CONFIG_FILE, :from=>gem)
        file  = files.find{ |f| File.file?(f) }
        new(*file)

        #if file
        #  paths = [file]
        #else
        #  #paths = Find.path(CONFIG_DIR + '/**/*', :from=>gem)
        #end
        #files = paths.select{ |path| File.file?(path) }
        #new(*files)
      end

      #
      # Load configuration for current project.
      #
      def load_local
        files = lookup(CONFIG_FILE)
        file  = files.find{ |f| File.file?(f) }
        new(*file)

        #if file
        #  paths = [file]
        #else
        #  dir = lookup(CONFIG_DIR).find{ |f| File.directory?(f) }
        #  paths = dir ? Dir.glob(File.join(dir, '**/*')) : []
        #end
        #files = paths.select{ |path| File.file?(path) }
      end

    private

      #
      # Search upward from working directory.
      #
      def lookup(glob, flags=0)
        pwd  = File.expand_path(Dir.pwd)
        home = File.expand_path('~')
        while pwd != '/' && pwd != home
          paths = Dir.glob(File.join(pwd, glob), flags)
          return paths unless paths.empty?
          break if ROOT_INDICATORS.any?{ |r| File.exist?(File.join(pwd, r)) }
          pwd = File.dirname(pwd)
        end
        return []
      end

    end

    #
    # Initialize new Configuration object.
    #
    # @param [Array<String>] files
    #   Configuration files (optional).
    #
    def initialize(*files)
      @files = files

      @_config = Hash.new{ |h,k| h[k]=[] }
      #@_onload = Hash.new{ |h,k| h[k]=[] }

      load_files(*files)
    end

    #
    # Import other runtime configuration files.
    #
    # @param [String] glob
    #   File pattern of configutation files to load.
    #
    # @param opts [Hash] Load options.
    #
    # @option opts [String] :from
    #   Name of gem or library.
    #
    # @option opts [Boolean] :first
    #   Only match a single file.
    #
    def import(glob, opts={})
      paths = []

      glob = glob + '**/*' if glob.end_with?('/')

      if from = opts[:from]
        paths = Find.path(glob, :from=>from)
      else
        if glob.start_with?('/')
          if root = lookup_root
            glob = File.join(root, glob)
          else
            raise "no project root for #{glob}" unless root
          end
        end
        paths = Dir.glob(glob)
      end

      paths = paths.select{ |path| File.file?(path) }
      paths = paths[0..0] if opts[:first]

      load_files(*paths)

      paths.empty? ? nil : paths
    end

    #
    # Load configuration files.
    #
    # TODO: begin/rescue around instance_eval?
    #
    # TODO: Does each file need it's own DSL instance?
    #
    def load_files(*files)
      dsl = DSL.new(self)
      files.each do |file|
        next unless File.file?(file)  # TODO: warn ?
        #begin
          dsl.instance_eval(File.read(file), file)
        #rescue => e
        #  raise e if $DEBUG
        #  warn e.message
        #end
      end
    end

    alias :load_file :load_files

    #
    # Evaluate configuration code.
    #
    # @yieldparm cfg
    #   Configuration code block.
    #
    def evaluate(*args, &cfg)
      dsl = DSL.new(self)
      dsl.instance_eval(*args, &cfg)
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
      command = command || RC.current_command

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
    #  "#<RC::Configuration:#{object_id} @file=#{@file}>"
    #end

  private

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

      from_config = RC.configuration(from_name)

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
    # Search upward from project root directory.
    #
    def lookup_root
      pwd  = File.expand_path(Dir.pwd)
      home = File.expand_path('~')
      while pwd != '/' && pwd != home
        return pwd if ROOT_INDICATORS.any?{ |r| File.exist?(File.join(pwd, r)) }
        pwd = File.dirname(pwd)
      end
      return nil
    end

    # Configuration::DSL
    #
    class DSL < Module

      #
      #
      #
      def initialize(configuration)
        @configuration = configuration
        @_options = {}
      end

      #
      def import(glob, opts={})
        @configuration.import(glob, *opts)
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
