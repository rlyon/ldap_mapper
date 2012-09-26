require 'rubygems'
require 'bundler/setup'
require 'ldap_mapper'

def check_password(password, ssha)
  salt = Base64.decode64(ssha.gsub(/^\{SSHA\}/, ''))[20..-1]
  Net::LDAP::Password.generate(:ssha, password, salt)
end

RSpec.configure do |config|
  config.mock_with :mocha
end
