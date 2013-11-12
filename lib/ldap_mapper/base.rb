module LdapMapper
  module Base
    extend ActiveSupport::Concern
    extend Plugins

    include Plugins::Attributes
    include Plugins::BaseDn
    include Plugins::ActiveModel
    include Plugins::Query
    include Plugins::ObjectClasses
    include Plugins::Identifier

    included do
      extend Plugins
    end

    module ClassMethods
      def connection(ldap_connection = nil)
        if ldap_connection.nil? and LdapMapper.connection
          @connection ||= LdapMapper.connection
        else
          @connection = ldap_connection
        end
        @connection
      end
    end

    def initialize(attrs = {})
      attrs.each do |key, value|
        attributes[key] = value
        orig_attributes[key] = value
      end
    end

    def connection
      self.class.connection
    end

    def dn
      "#{self.identifier}=#{attributes[self.class.reverse_map[self.identifier]]},#{self.basedn}"
    end

    def save
      connection.modify :dn => dn, :operations => generate_operations_list
    end
  end
end
