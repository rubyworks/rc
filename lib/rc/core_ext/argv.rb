#
# @deprecated Add to Ruby Facets ?
#
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

