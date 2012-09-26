module LdapMapper
  module Base
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      def _load(marshalled)
        new(Marshal.load(marshalled))
      end

      def base(type)
        class_eval <<-EOS, __FILE__, __LINE__
          def base
            "#{type.to_s}"
          end
        EOS
        @control = type.to_s
      end

      def objectclasses
        @objectclasses ||= []
      end

      def objectclass(name)
        objectclasses << name 
      end

      def connection
        @conn ||= ldap_connection
      end

      def ldap_connection
        ldap = Net::LDAP.new
        ldap.host = LDAP_MAPPER_HOST
        ldap.port = LDAP_MAPPER_PORT
        ldap.auth LDAP_MAPPER_ADMIN, LDAP_MAPPER_ADMIN_PASSWORD
        ldap
      end

      def attributes
        @attributes ||= []
      end

      def attribute(name, options = {})
        class_eval <<-EOS, __FILE__, __LINE__
          def #{name}
            attributes[:#{name}]
          end
        EOS
        case options[:type]
        when :integer
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
        when :password
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
        when :epoch_days
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
        else
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

        class_eval <<-EOS, __FILE__, __LINE__
          def self.find_by_#{name}(query)
            #where(:#{name} => query).first
            nil
          end
        EOS

        class_eval <<-EOS, __FILE__, __LINE__
          def #{name}_mapping
            "#{options[:map] ? options[:map] : name}"
          end
        EOS

        @attributes ||= []
        @attributes |= [name]
      end
    end

    def initialize(attrs={})
      @conn = self.class.connection
      attrs.each do |key, value|
        attributes[key] = value
      end
    end

    def attributes
      @attributes ||= {}
    end

    def connection
      @conn ||= self.class.connection
    end

    def import_attributes(entry)
      hash = entry.is_a?(Net::LDAP::Entry) ? entry.to_hash(:compress => true) : entry
      begin
        self.class.attributes.each do |attr|
          #TODO should only iterate through hash array
          mapped = send("#{attr}_mapping")
          send("#{attr}=", hash[mapped]) if hash.include?(mapped)
        end
        true
      rescue
        #TODO handle individual exceptions
        false
      end
    end

    def mapped_and_converted_attributes
      h = self.class.attributes.inject({}) do |ret,attr|
        ret[send("#{attr}_mapping")] = send("#{attr}_convert") unless attributes[attr].nil?
        ret
      end
    end
  end
end
