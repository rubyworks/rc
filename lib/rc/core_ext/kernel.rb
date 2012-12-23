module Kernel

  private

=begin
  #
  # Evaluate script directly into current scope.
  #
  def import(feature)
    file = Find.feature(feature, :absolute=>true).first
    raise LoadError, "no such file -- #{feature}" unless file
    instance_eval(::File.read(file), file) if file
  end

  #
  # Evaluate script directly into current scope.
  #
  # TODO: Shouldn't this be relative to calling file instead of Dir.pwd?
  #
  def import_relative(file)
    raise LoadError, "no such file -- #{file}" unless File.file?(file)
    instance_eval(::File.read(file), file) if file
  end
=end

  #
  # Alias original Kernel#require method.
  #
  alias_method :require_without_rc, :require

  #
  # Redefine Kernel#require with callback.
  #
  def require(feature, options=nil)
    result = require_without_rc(feature)
    RC.required(feature) if result
    result
  end

  class << self
    #
    # Alias original Kernel.require method.
    #
    alias_method :require_without_rc, :require

    #
    # Redefine Kernel.require with callback.
    #
    def require(feature)
      result = require_without_rc(feature)
      RC.required(feature) if result
      result
    end
  end

end

