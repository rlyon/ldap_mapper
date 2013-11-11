module LdapMapper
  module Base
    extend ActiveSupport::Concern
    extend Plugins

    include Plugins::ActiveModel
    include Plugins::Query
    include Plugins::Attributes
    include Plugins::ObjectClasses
    include Plugins::Base
    include Plugins::Identifier

    included do
      extend Plugins
    end

    ####
    ####
    #### INSTANCE METHODS
    ####
    ####
    def initialize(attrs={})
      attrs.each do |key, value|
        attributes[key] = value
      end

      self.class.attributes.each do |attr|
        operations[attr] = :noop
      end
    end

    def attributes
      @attributes ||= {}
    end

    def connection(ldap_connection = nil)
      if ldap_connection.nil? and LdapMapper.connection
        @connection ||= LdapMapper.connection
      else
        @connection = ldap_connection
      end
      @connection
    end

    def base
      raise "Base must be defined before using."
    end

    def dn
      "#{self.identifier}=#{attributes[self.class.reverse_map[self.identifier]]},#{self.base}"
    end

    def identifier
      raise "Identifier must be defined before using."
    end

    def mappings
      @mappings ||= self.class.mappings
    end

    def operations
      @operations ||= {}
    end

    def set_operation(name, new_value)
      value = attributes[:"#{name}"]
      if value == nil
        operations[name] = :add
      elsif value != nil and new_value == nil
        operations[name] = :delete
      else
        operations[name] = :replace
      end
    end

    def import_attributes(entry)
      hash = entry.is_a?(Net::LDAP::Entry) ? LdapMapper::Tools.to_hash(entry,:compress => true) : entry
      begin
        self.class.attributes.each do |attr|
          #TODO should only iterate through hash array
          mapped = mappings[attr]
          send("#{attr}=", hash[mapped]) if hash.include?(mapped)
        end
        self.class.attributes.each do |attr|
          operations[attr] = :noop
        end
        true
      rescue
        #TODO handle individual exceptions
        false
      end
    end

    def mapped_and_converted_attributes
      h = self.class.attributes.inject({}) do |ret,attr|
        ret[mappings[attr]] = send("#{attr}_convert") unless attributes[attr].nil?
        ret
      end
    end

    def generate_operations_list
      oplist = []
      operations.each do |attr, op|
        unless op == :noop
          oplist << [op, :"#{self.class.mappings[attr]}", attributes[attr]]
        end
      end
      oplist
    end

    def save
      connection.modify :dn => dn, :operations => generate_operations_list
    end
  end
end
