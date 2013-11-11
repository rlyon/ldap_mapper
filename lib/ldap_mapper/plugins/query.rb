module LdapMapper
  module Plugins
    module Query
      extend ActiveSupport::Concern

      module ClassMethods
        def connection(ldap_connection = nil)
          if ldap_connection.nil? and LdapMapper.connection
            @connection ||= LdapMapper.connection
          else
            @connection = ldap_connection
          end
          @connection
        end

        def all(options = {})
          self.where(:all)
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
            filter = Net::LDAP::Filter.eq(@identifier, "*")
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
      end
    end
  end
end
