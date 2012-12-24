# exmaple configuration file

config :example do
  "example config"
end

config :example, :profile=>:data do |ex|
  ex.name = 'Tommy'
  ex.age  = 42
end

