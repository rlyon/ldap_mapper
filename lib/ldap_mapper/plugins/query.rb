module LdapMapper
  module Plugins
    module Query
      extend ActiveSupport::Concern

      included do
        extend ActiveSupport::DescendantsTracker
      end

      module ClassMethods
        def all(options = {})
          self.where(:all)
        end

        def connection(ldap_connection = nil)
          if ldap_connection.nil? and LdapMapper.connection
            @connection ||= LdapMapper.connection
          else
            @connection = ldap_connection
          end
          @connection
        end

        def find(id)
          filter = Net::LDAP::Filter.eq(@identifier, id)
          results = connection.search(:base => @basedn, :filter => filter, :size => 1)

          raise OperationError, connection.get_operation_result.message if results.nil?
          raise RecordNotFound, "The requested record was not found." if results.empty?
          attrs = import(results.first)
          self.new(attrs, :existing)
        end

        def where(opts = :chain, *others)
          objs = []
          filter = nil
          if opts == :all
            filter = Net::LDAP::Filter.eq(@identifier, "*")
          else
            opts.each do |key, value|
              opt = Net::LDAP::Filter.eq(@mappings[key], value.to_s)
              filter = filter ? filter & opt : opt
            end
          end

          result = connection.search(:base => @basedn, :filter => filter, :return_result => false) do |entry|
            attrs = import(entry)
            objs << self.new(attrs, :existing)
          end
          raise OperationError, connection.get_operation_result.message unless result
          objs
        end

        def import(entry)
          attrs = {}
          self.attributes.each do |attr|
            mapped_attr = mappings[attr]
            type = types[attr]
            unless entry[mapped_attr].nil?
              unless type == :array
                value = cast(type, entry[mapped_attr].first)
              else
                value = cast(type, entry[mapped_attr])
              end
              attrs[attr] = value
            else
              attrs[attr] = nil
            end
          end
          attrs
        end
      end

      def connection
        self.class.connection
      end

      def dn
        "#{self.identifier}=#{attributes[self.class.reverse_map[self.identifier]]},#{self.basedn}"
      end

      def generate_modify_list
        oplist = []
        attributes.keys.each do |attr|
          op = operations[attr]
          unless op == :noop
            oplist << [op, :"#{self.class.mappings[attr]}", convert(types[attr], attributes[attr])]
          end
        end
        oplist
      end

      def generate_add_list
        attrs = { :objectclass => objectclasses }
        self.class.attributes.each do |attr|
          mapped = mappings[attr]
          attrs[:"#{mapped}"] = convert(types[attr], attributes[attr])
        end
        attrs
      end

      def save
        create_or_update
      end

      def create_or_update
        case @_state
        when :modified
          update
        when :new
          create
        end        
      end

      def create
        connection.add(:dn => dn, :attributes => generate_add_list)
        result = connection.get_operation_result
        raise OperationError, "Unable to create: #{result.message}" unless result.code == 0
      end

      def update
        connection.modify :dn => dn, :operations => generate_modify_list
        result = connection.get_operation_result
        raise OperationError, "Unable to update: #{result.message}" unless result.code == 0
      end

      def destroy
        delete
      end

      def delete
        connection.delete :dn => dn
      end
    end
  end
end
