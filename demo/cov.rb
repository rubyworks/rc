# Usage: qed -r ./spec/cov
require 'simplecov'
SimpleCov.start do
  coverage_dir 'log/coverage'
  #add_group "Label", "lib/qed/directory"
end

