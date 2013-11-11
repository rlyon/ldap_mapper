module LdapMapper
  module Plugins
    module Attributes
      include ActiveSupport::Concern

      module ClassMethods
        def attributes
          @attributes ||= []
        end

        def mappings
          @mappings ||= {}
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
        end

        def mappings
          @mappings ||= {}
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
              set_operation(:#{name}, new_#{name})
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
              set_operation(:#{name}, new_#{name})
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
              set_operation(:#{name}, new_#{name})
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
              set_operation(:#{name}, new_#{name})
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
              set_operation(:#{name}, new_#{name})
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
    end
  end
end