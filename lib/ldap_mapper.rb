require "net/ldap"
require "base64"
require "ldap_mapper/version"
require "ldap_mapper/base"
require "ldap_mapper/filter"
require "ldap_mapper/tools"

module LdapMapper
  # Your code goes here...
end

Dir[File.join('./lib/ldap_mapper/extensions', '*.rb')].each do |ext|
  require ext
end
