#
# Configure QED demo tool.
#
config 'qed' do
  puts "QED!"
end

#
# QED test coverage report using SimpleCov.
#
# Use `$properties.coverage_folder` to set directory in which to store
# coverage report this defaults to `log/coverage`.
#
# IMPORTANT! Unfortunately this will not give us a reliable report
# b/c QED uses the RC gem, so SimpleCov can't differentiate the two.
#
config 'qed', profile: 'cov' do
  puts "QED w/coverage!"

  require 'simplecov'

  dir = $properties.coverage_folder

  SimpleCov.start do
    coverage_dir(dir || 'log/coverage')
    #add_group "Label", "lib/qed/directory"
  end
end

