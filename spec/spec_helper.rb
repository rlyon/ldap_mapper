puts ENV['COVERAGE']
if ENV['COVERAGE'] == "true"
  require 'simplecov'
  FILTER_DIRS = ['spec', 'vendor']
 
  SimpleCov.start do
    FILTER_DIRS.each{ |f| add_filter f }
  end
end

require 'rubygems'
require 'bundler/setup'
require 'ldap_mapper'
require 'mocha/api'
require 'ladle'

Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.mock_with        :mocha
end
