module Kernel
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
end

class Hash
  def to_h
    dup #rehash
  end unless method_defined?(:to_h)

  #def rekey(&block)
  #  h = {}
  #  each do |k,v|
  #    nk = block.call(k)
  #    h[nk] = v
  #  end
  #  h
  #end unless method_defined?(:rekey)
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

# @deprecated Add to Ruby Facets ?
def ARGV.env(*switches)
  mapping = (Hash === switches.last ? swithes.pop : {})

  switches.each do |s|
    mapping[s] = s.to_s.sub(/^[-]+/,'')
  end

  mapping.each do |switch, envar|
    if index = ARGV.index(switch)
      ENV[envar] = ARGV[index+1]
    elsif arg = ARGV.find{ |a| a =~ /#{switch}=(.*?)/ }
      value = $1
      value = value[1..-2] if value.start_with?('"') && value.end_with?('"')
      value = value[1..-2] if value.start_with?("'") && value.end_with?("'")
      ENV[envar] = value
    end
  end
end

