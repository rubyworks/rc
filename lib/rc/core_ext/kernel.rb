#require 'finder/import'

module Kernel

  private

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

