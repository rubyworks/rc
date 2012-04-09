module Kernel
  #
  # Evaluate script directly into current scope.
  #
  def import(feature)
    file = Find.load_path(feature).first
    raise LoadError, "no such file -- #{feature}" unless file
    instance_eval(::File.read(file), file) if file
  end
end

class Hash
  def to_h
    dup #rehash
  end unless method_defined?(:to_h)
end

class String
  def tabto(n)
    if self =~ /^( *)\S/
      indent(n - $1.length)
    else
      self
    end
  end unless method_defined?(:tabto)

  def indent(n, c=' ')
    if n >= 0
      gsub(/^/, c * n)
    else
      gsub(/^#{Regexp.escape(c)}{0,#{-n}}/, "")
    end
  end unless method_defined?(:indent)
end

#class Symbol
#  def /(other)
#    "#{self}/#{other}".to_sym
#  end
#end

