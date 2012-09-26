require "ldap_mapper/version"
require "ldap_mapper/base"
require "net/ldap"
require "base64"

module LdapMapper
  # Your code goes here...
end

Dir[File.join('./lib/ldap_mapper/extensions', '*.rb')].each do |ext|
  require ext
end
