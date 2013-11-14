require 'rubygems'
require 'bundler/setup'
require 'ldap_mapper'
require 'mocha/api'
require 'ladle'

if ENV['TRAVIS']
    require 'coveralls'
    Coveralls.wear!
elsif ENV['COVERAGE']
  require 'simplecov'
  FILTER_DIRS = ['spec', 'vendor']
 
  SimpleCov.start do
    FILTER_DIRS.each{ |f| add_filter f }
  end
end

LDAP_MAPPER_HOST="localhost"
LDAP_MAPPER_PORT=3897
LDAP_MAPPER_ADMIN="uid=admin,ou=system"
LDAP_MAPPER_ADMIN_PASSWORD="secret"

Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :mocha
end
