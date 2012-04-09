# Setup the fixtures.

dir = File.dirname(__FILE__) + '/fixture'
Dir.entries(dir).each do |file|
  next if file == '.' or file == '..'
  path = File.join(dir, file)
  next if File.directory?(path)
  FileUtils.install(path, Dir.pwd)
end

