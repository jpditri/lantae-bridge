# frozen_string_literal: true

require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new

task default: %i[rubocop spec]

desc 'Run tests with coverage'
task :coverage do
  ENV['COVERAGE'] = 'true'
  Rake::Task['spec'].invoke
end

desc 'Install dependencies'
task :setup do
  sh 'bundle install'
end

desc 'Console with project loaded'
task :console do
  require 'pry'
  require_relative 'lib/lantae_bridge'
  
  binding.pry
end