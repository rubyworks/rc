require 'rc/interface'

When 'configuration file `(((\S+)))` containing' do |slots, text|
  RC.clear! #configurations.clear
  fname = [slots].flatten.first  # temporary transition to new QED
  File.open(fname, 'w'){ |f| f << text }
end

