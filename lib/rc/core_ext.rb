# All core extensions come from Ruby Facets to maintain high standard for
# careful core extensions.

require 'facets/string/tabto'
#require 'facets/to_hash'
require 'facets/binding/self'

#require 'facets/ostruct/to_h'  # TODO: Newer version of facets.
require 'ostruct'
class OpenStruct
  def to_h
    @table.dup
  end
end

class Symbol
  def /(other)
    "#{self}/#{other}".to_sym
  end
end

module Kernel
  #
  # Evaluate script directory into current scope.
  #
  def import(feature)
    file = Find.load_path(feature).first
    raise LoadError, "no such file -- #{feature}" unless file
    instance_eval(::File.read(file), file) if file
  end
end

