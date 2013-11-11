require "net/ldap"
require "base64"
require "ldap_mapper/version"
require "ldap_mapper/filter"
require "ldap_mapper/tools"
require 'active_support/core_ext'
require 'active_model'

module LdapMapper
  autoload :Connection,     'ldap_mapper/connection'
  autoload :Base,           'ldap_mapper/base'

  module Plugins
    autoload :Query,          'ldap_mapper/plugins/query'
    autoload :Attributes,     'ldap_mapper/plugins/attributes'
    autoload :ObjectClasses,  'ldap_mapper/plugins/objectclasses'
    autoload :ActiveModel,    'ldap_mapper/plugins/active_model'
    autoload :Identifier,     'ldap_mapper/plugins/identifier'
    autoload :Base,           'ldap_mapper/plugins/base'
  end

  extend Connection
end

Dir[File.join('./lib/ldap_mapper/extensions', '*.rb')].each do |ext|
  require ext
end
