module LdapMapper
  module Base
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def _load(marshalled)
        new(Marshal.load(marshalled))
      end

      def all(options = {})
        self.where(:all)
      end

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
        class_eval <<-EOS, __FILE__, __LINE__
          def #{name}
            attributes[:#{name}]
          end
        EOS
        case options[:type]
        when :integer
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
        when :password
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
        when :epoch_days
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
        else
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

        # class_eval <<-EOS, __FILE__, __LINE__
        #   def self.find_by_#{name}(query)
        #     puts "Removing to slim this down even more"
        #     where(:#{name} => query)
        #   end
        # EOS

        # class_eval <<-EOS, __FILE__, __LINE__
        #   def #{name}_mapping
        #     puts "Deprecating"
        #     "#{options[:map] ? options[:map] : name}"
        #   end
        # EOS

        @attributes ||= []
        @attributes |= [name]
        @mappings ||= {}
        @mappings[name] = options[:map] ? options[:map] : name
      end

      def base(type)
        class_eval <<-EOS, __FILE__, __LINE__
          def base
            "#{type.to_s}"
          end
        EOS
        @base = type.to_s
      end

      def connection
        @conn ||= ldap_connection
      end

      def find(id)
        # dn = "#{@identifier}=#{id},#{@base}"
        filter = Net::LDAP::Filter.eq(@identifier, id)
        results = connection.search(:base => @base, :filter => filter)
        if results
          obj = self.new
          obj.import_attributes(results.first)
          obj
        else
          nil
        end
      end

      def where(opts = :chain, *others)
        objs = []
        filter = nil
        if opts == :all
          filter = Net::LDAP::Filter.eq("objectclass", "*")
        else
          filter = nil
          # opt = opts.flatten
          # filter = Net::LDAP::Filter.eq(@mappings[opt[0]], opt[1])
          opts.each do |key, value|
            opt = Net::LDAP::Filter.eq(@mappings[key], value.to_s)
            filter = filter ? filter & opt : opt
          end
        end

        connection.search(:base => @base, :filter => filter, :return_result => false) do |entry|
          obj = self.new
          obj.import_attributes(entry)
          objs << obj
        end
        objs
      end

      def and()
        nil
      end

      def or()
        nil
      end

      def identifier(id)
        class_eval <<-EOS, __FILE__, __LINE__
          def identifier
            "#{id.to_s}"
          end
        EOS
        @identifier = id
      end

      def ldap_connection
        Net::LDAP.new(
          :host => LDAP_MAPPER_HOST,
          :port => LDAP_MAPPER_PORT,
          :auth => {
            :method => :simple,
            :username => LDAP_MAPPER_ADMIN,
            :password => LDAP_MAPPER_ADMIN_PASSWORD
          })
      end

      def mappings
        @mappings ||= {}
      end

      def objectclasses
        @objectclasses ||= []
      end

      def objectclass(name)
        objectclasses << name 
      end

      def reverse_map
        @inverted_mappings ||= @mappings.invert
      end
    end

    ####
    ####
    #### INSTANCE METHODS
    ####
    ####
    def initialize(attrs={})
      @conn = self.class.connection
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

    def base
      raise "Base must be defined before using."
    end

    def connection
      @conn ||= self.class.connection
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
      oplist = []
      connection.modify :dn => dn, :operations => generate_operations_list
    end
  end
end
