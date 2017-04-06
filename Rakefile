require "bundler/gem_tasks"
require "rspec/core/rake_task"
require 'pinkman'
require Pinkman.root.join('spec/support/sprockets')

task :default => :spec
require 'jasmine'
load 'jasmine/tasks/jasmine.rake'
RSpec::Core::RakeTask.new(:spec)


namespace :pinkman do
  desc 'Precompile pinkman.js'
  task :precompile do
    f = File.open(Pinkman.root.join('public','javascripts','pinkman.min.js'),'w+') {|f| f.write Assets.app_environment['pinkman'].to_s }
  end
end

namespace :spec do
  
  desc 'Compile spec.js and coffeescripts specs to js'
  task precompile: ['pinkman:precompile'] do
    f = File.open(Pinkman.root.join('spec','javascripts','spec.js'),'w+') {|f| f.write Assets.spec_environment['support/spec_helper'].to_s }
  end

  desc 'Run JS (Jasmine) Specs'
  task :js => ['spec:precompile', 'jasmine']

end