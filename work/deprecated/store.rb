module Confection

  class Store

    include Enumerable

=begin
    #
    # Bootstrap the system, loading current configurations.
    #
    def bootstrap
      if file
        @config[root] = []
        begin
          DSL.load_file(file)
        rescue => e
          raise e if $DEBUG
          warn e.message
        end
      end
      @config[root]
    end
=end

    #
    def initialize(*sources)
      @sources = sources

      @list = []

      sources.each do |source|
        if File.file?(source)
          parse(source)
        else
          # ignore directories
        end
      end
    end

    #
    attr :sources

    #
    def parse(file)
      Parser.parse(self, file)
    end

    #
    # Iterate over each configurations.
    #
    def each(&block)
      @list.each(&block)
    end

    #
    # The number of configurations.
    #
    # @return [Fixnum] config count
    #
    def size
      @list.size
    end

    #
    # Add as configuratio to the store.
    #
    def <<(conf)
      raise TypeError, "not a configuration instance -- `#{conf}'" unless Config === conf
      @list << conf
    end

    #
    # Add a list of configs.
    #
    def concat(configs)
      configs.each{ |c| self << c }
    end

    #
    # Lookup configuration by tool and profile name.
    #
    # @todo Future versions should allow this to handle regex and fnmatches.
    #
    def lookup(tool, profile=nil)
      if profile == '*'
        select do |c|
          c.tool.to_sym == tool.to_sym
        end
      else
        profile = profile.to_sym if profile

        select do |c|
          c.tool.to_sym == tool.to_sym && c.profile == profile
        end
      end
    end

    #
    # Returns list of profiles collected from all configs.
    #
    def profiles(tool)
      names = []
      each do |c|
        names << c.profile if c.tool == tool.to_sym
      end
      names.uniq.compact
    end

    #
    # Clear configs.
    #
    def clear!
      @list = []
    end

    #
    def first
      @list.first
    end

    #
    def last
      @list.last
    end

    #
    #def config(*args, &block)
    #  dsl.config(*args, &block)
    #end

    #
    #def controller(scope, name, profile=nil)
    #  configs = lookup(name, profile)
    #  Controller.new(scope, *configs)
    #end

    #
    # Import configuration from another project.
    #
    def import(tool, profile, options, &block)
      from_tool    = options[:tool]    || tool
      from_profile = options[:profile] || profile

      case from = options[:from]
      when String, Symbol
        project = Project.load(from.to_s)
        store   = project ? project.store : nil
      else
        from  = '(self)'
        store = self
      end

      raise "no configuration found in `#{from}'" unless store

      configs = store.lookup(from_tool, from_profile)

      configs.each do |config|
        new_config = config.copy(:tool=>tool, :profile=>profile)

        #new_options = @_options.dup
        #new_options[:tool]    = tool
        #new_options[:profile] = profile
        #new_options[:block]   = config.block
        #new_options[:text]    = config.text

        # not so sure about this one
        if String === new_config.value
          new_config.value += ("\n" + options[:text].to_s) if options[:text]
        end

        self << new_config
      end

      #if block
      #  self << Config::Block.new(tool, profile, nil, &block)
      #end
    end

  end

end

