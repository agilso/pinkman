require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec
require 'jasmine'
load 'jasmine/tasks/jasmine.rake'


desc 'Compiles javascript test'

namespace :assets do
  task 'precompile' do
    system("coffee -c -o  spec/javascripts/ spec/coffee/")
  end
end

namespace :spec do
  task 'js' => ['assets:precompile', 'jasmine']
end