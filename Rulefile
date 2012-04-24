#!/usr/bin/env ruby

ignore 'work', '.yardoc', 'doc', 'log', 'pkg', 'tmp', 'web'

desc "run specs"
task "spec" do
  cmd = "qed"
  sh cmd
end

task "spec:cov" do
  cmd = "qed -p cov"
  sh cmd
end

