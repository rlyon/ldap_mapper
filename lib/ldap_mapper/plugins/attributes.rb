module LdapMapper
  module Plugins
    module Attributes
      extend ActiveSupport::Concern

      included do
        extend ActiveSupport::DescendantsTracker
      end

      module ClassMethods
        def attributes
          @attributes ||= []
        end

        def mappings
          @mappings ||= {}
        end

        def types
          @types ||= {}
        end

        def attribute(name, options = {})
          if options[:map]
            options[:map].downcase!
          end

          type = options[:type].nil? ? :string : options[:type]

          create_accessors_for(type, name)

          @attributes ||= []
          @attributes |= [name]
          @mappings ||= {}
          @mappings[name] = options[:map] ? options[:map] : name
          @types ||= {}
          @types[name] = options[:type] ? options[:type] : :string
        end

        def reverse_map
          @inverted_mappings ||= @mappings.invert
        end

      private
        def create_accessors_for(type, name)
          class_eval <<-EOS, __FILE__, __LINE__
            def #{name}
              attributes[:#{name}]
            end
          EOS

          class_eval <<-EOS, __FILE__, __LINE__
            def #{name}=(new_#{name})
              value = cast(:#{type}, new_#{name})
              set_operation(:#{name}, value)
              attributes[:#{name}] = value
            end
          EOS
        end
      end

      def attributes
        @attributes ||= {}
      end

      def ldap_attributes
        @ldap_attributes ||= {}
      end

      def set_operation(name, value)
        if @_state == :new
          operations[name] = :add
        else
          orig = ldap_attributes[name]
          if orig.nil?
            operations[name] = :add
          elsif value.nil?
            operations[name] = :delete
          else
            operations[name] = :replace
          end
        end
        @_state = :modified
      end

      def identifier
        raise "Identifier must be defined before using."
      end

      def mappings
        @mappings ||= self.class.mappings
      end

      def types
        @types ||= self.class.types
      end

      def operation(name)
        operations[name]
      end

      def operations
        @operations ||= self.class.attributes.inject({}) { |a,k| a[k] = :noop ; a }
      end
    end
  end
end