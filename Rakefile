#!/usr/bin/env rake
require 'rspec/core/rake_task'
require 'bundler/gem_tasks'
require 'flog'
require 'reek/rake/task'

task :default => :spec

desc "Run all specs. Use COVERAGE to generate coverage data."
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = %w{--colour --format progress}
  t.pattern = 'spec/*_spec.rb'
end

# desc "Flog the code"
# task :flog do
#   class
# end
# namespace :flog do
#   desc "Analyze total code complexity with flog"
#   task :total do
#     puts 'Running flog total complexity'
#     threshold = 1000
#     flog = Flog.new
#     flog.flog 'lib/**/*.rb'
#     flog.report
#     fail "Your code is way too confusing... Fix your crap! (#{flog.total} > #{threshold})" if flog.total > threshold
#   end
# end

Reek::Rake::Task.new do |t|
  t.fail_on_error = false
end

