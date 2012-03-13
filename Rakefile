desc 'Run all the tests'
task :default => :spec

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = ['-c', '-f progress', '-r ./spec/spec_helper.rb']
  t.pattern = 'spec/**/*_spec.rb'
end

task :environment do 
  require 'urbanairship'
end

desc "Run the console"
task :console => [:environment] do
  require 'irb'
  ARGV.clear
  IRB.start
end
