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

          create_accessors_for(options[:type], name)

          @attributes ||= []
          @attributes |= [name]
          @mappings ||= {}
          @mappings[name] = options[:map] ? options[:map] : name
          @types ||= {}
          @types[name] = options[:type]
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

          case type
          when :integer
            create_integer_getters_for(name)
          when :password
            create_password_getters_for(name)
          when :epoch_days
            create_epoch_days_getters_for(name)
          when :array
            create_array_getters_for(name)
          else
            create_string_getters_for(name)
          end
        end

        def create_integer_getters_for(name)
          class_eval <<-EOS, __FILE__, __LINE__
            def #{name}=(new_#{name})
              attributes[:#{name}] = new_#{name}.to_i
            end
          EOS
          class_eval <<-EOS, __FILE__, __LINE__
            def #{name}_convert
              attributes[:#{name}].to_s
            end
          EOS
        end

        def create_password_getters_for(name)
          class_eval <<-EOS, __FILE__, __LINE__
            def #{name}=(new_#{name})
              if new_#{name} =~ /^\\{SSHA\\}/
                attributes[:#{name}] = nil
                attributes[:#{name}_encrypted] = new_#{name}
              else
                attributes[:#{name}] = new_#{name}
                attributes[:#{name}_encrypted] = Net::LDAP::Password.generate(:ssha, new_#{name})
              end
            end
          EOS
          class_eval <<-EOS, __FILE__, __LINE__
            def #{name}_encrypted
              attributes[:#{name}_encrypted]
            end
          EOS
          class_eval <<-EOS, __FILE__, __LINE__
            def #{name}_convert
              attributes[:#{name}_encrypted]
            end
          EOS
        end

        def create_epoch_days_getters_for(name)
          class_eval <<-EOS, __FILE__, __LINE__
            def #{name}=(new_#{name})
              if new_#{name}.is_a?(Time)
                attributes[:#{name}] = new_#{name}
              else
                attributes[:#{name}] = new_#{name}.to_i.epoch_days
              end
            end
          EOS
          class_eval <<-EOS, __FILE__, __LINE__
            def #{name}_convert
              attributes[:#{name}].to_epoch_days.to_s
            end
          EOS
        end

        def create_array_getters_for(name)
          class_eval <<-EOS, __FILE__, __LINE__
            def #{name}=(new_#{name})
              unless new_#{name}.is_a?(Array)
                raise "You must pass an array when assigning to #{name}"
              else
                attributes[:#{name}] = new_#{name}
              end
            end
          EOS
          class_eval <<-EOS, __FILE__, __LINE__
            def #{name}_convert
              attributes[:#{name}]
            end
          EOS
        end

        def create_string_getters_for(name)
          class_eval <<-EOS, __FILE__, __LINE__
            def #{name}=(new_#{name})
              attributes[:#{name}] = new_#{name}.to_s
            end
          EOS
          class_eval <<-EOS, __FILE__, __LINE__
            def #{name}_convert
              attributes[:#{name}]
            end
          EOS
        end
      end

      def attributes
        @attributes ||= {}
      end

      def orig_attributes
        @orig_attributes ||= {}
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

      def operations
        @operations ||= {}
      end

      def operation(name)
        value = attributes[name]
        orig = orig_attributes[name]
        unless orig.nil?
          if value == orig
            :noop
          elsif value.nil? || value.empty?
            :delete
          else
            :replace
          end
        else
          if value.nil? || value.empty?
            :noop
          else
            :add
          end
        end
      end

      def generate_operations_list
        oplist = []
        attributes.keys.each do |attr|
          op = operation(attr)
          unless op == :noop
            oplist << [op, :"#{self.class.mappings[attr]}", attributes[attr]]
          end
        end
        oplist
      end

      # def mapped_and_converted_attributes
      #   h = self.class.attributes.inject({}) do |ret,attr|
      #     ret[mappings[attr]] = send("#{attr}_convert") unless attributes[attr].nil?
      #     ret
      #   end
      # end

    end
  end
end