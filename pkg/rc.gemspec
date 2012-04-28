version = File.read('../var/version').strip

Gem::Specification.new do |s|
  s.name        = "rc"
  s.version     = version
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Rubyworks", "Trans"]
  s.email       = ["transfire@gmail.com"]
  s.homepage    = "http://github.com/rubyworks/courtier"
  s.summary     = "The best way to manage your application's configuration."
  s.description = "Courtier manages an application's configuration via a single multi-tenant project file."

  s.rubyforge_project = "courtier"

  s.add_runtime_dependency "courtier", "= #{version}"
  s.add_development_dependency "courtier", "= #{version}"

  s.files        = []
  s.executables  = []
end

