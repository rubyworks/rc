# exmaple configuration file

config :example do
  "example config"
end

config :example, :yaml, %{
  ---
  note: example text config
}

config :example, :data do |ex|
  ex.name = 'Tommy'
  ex.age  = 42
end

