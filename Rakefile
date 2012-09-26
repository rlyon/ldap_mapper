#!/usr/bin/env rake
require 'rspec/core/rake_task'
require "bundler/gem_tasks"

task :default => :spec

desc "Run all specs"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = %w{--colour --format progress}
  t.pattern = 'spec/*_spec.rb'
end
