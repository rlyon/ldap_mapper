require "net/ldap"
require "base64"
require 'active_support/core_ext'
require 'active_model'

module LdapMapper
  autoload :Error,              'ldap_mapper/exceptions'
  autoload :RecordNotFound,     'ldap_mapper/exceptions'
  autoload :ConnectionError,    'ldap_mapper/exceptions'
  autoload :OperationError,     'ldap_mapper/exceptions'
  autoload :NotAuthorizedError, 'ldap_mapper/exceptions'
  autoload :InvalidOptionError, 'ldap_mapper/exceptions'
  autoload :Connection,         'ldap_mapper/connection'
  autoload :Base,               'ldap_mapper/base'
  autoload :Authenticatable,    'ldap_mapper/authenticatable'
  autoload :Tools,              'ldap_mapper/tools'
  autoload :VERSION,            'ldap_mapper/version'

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
