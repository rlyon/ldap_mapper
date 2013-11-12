require "net/ldap"
require "base64"
require "ldap_mapper/filter"
require 'active_support/core_ext'
require 'active_model'

module LdapMapper
  autoload :Connection,     'ldap_mapper/connection'
  autoload :Base,           'ldap_mapper/base'
  autoload :VERSION,        'ldap_mapper/version'
  autoload :Tools,          'ldap_mapper/tools'

  module Plugins
    autoload :Query,          'ldap_mapper/plugins/query'
    autoload :Attributes,     'ldap_mapper/plugins/attributes'
    autoload :ObjectClasses,  'ldap_mapper/plugins/objectclasses'
    autoload :ActiveModel,    'ldap_mapper/plugins/active_model'
    autoload :Identifier,     'ldap_mapper/plugins/identifier'
    autoload :BaseDn,         'ldap_mapper/plugins/base_dn'
  end

  extend Connection
end

Dir[File.join('./lib/ldap_mapper/extensions', '*.rb')].each do |ext|
  require ext
end
