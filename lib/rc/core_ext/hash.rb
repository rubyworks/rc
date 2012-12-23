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

