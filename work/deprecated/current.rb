module Confection

  #
  # Global properties is set for parsing project configuration.
  # It is *always* the properties of the current project.
  #
  $properties = nil

  # Current mixin extends the Confection module. Primarily is provides
  # class methods for working with the current project's configurations.
  #
  module Current

    #
    def controller(scope, tool, *options)
      params = (Hash === options.last ? options.pop : {})
      params[:profile] = options.shift unless options.empty?

      if from = params[:from]
        projects[from] ||= Project.load(from)
        projects[from].controller(scope, tool, params)
      else
        bootstrap if $properties.nil?  # TODO: better way to go about this?
        current_project.controller(scope, tool, params)
      end
    end

    #
    def bootstrap
      $properties = current_project.properties
    end

    #
    def projects
      @projects ||= {}
    end

    #
    def current_directory
      @current_directory ||= Dir.pwd
    end

    #
    def current_project
      projects[current_directory] ||= Project.lookup(current_directory)
    end

    #
    def clear!
      current_project.store.clear!
    end

    #
    def profiles(tool, options={})
      current_project.profiles(tool)
    end

    #
    def each(&block)
      current_project.each(&block)
    end

    #
    def size
      current_project.size
    end

    #
    # Project properties.
    #
    def properties
      current_project.properties
    end

  end

  extend Current

end
