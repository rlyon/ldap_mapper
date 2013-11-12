module LdapMapper
  module Plugins
    module Query
      extend ActiveSupport::Concern
      extend LdapMapper::Tools

      included do
        extend ActiveSupport::DescendantsTracker
        extend LdapMapper::Tools
      end

      module ClassMethods
        def all(options = {})
          self.where(:all)
        end

        def find(id)
          filter = Net::LDAP::Filter.eq(@identifier, id)
          results = connection.search(:base => @basedn, :filter => filter)
          if results
            attrs = import(results.first)
            self.new(attrs)
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

          connection.search(:base => @basedn, :filter => filter, :return_result => false) do |entry|
            attrs = import(entry)
            objs << self.new(attrs)
          end
          objs
        end

        def import(entry)
          attrs = {}
          self.attributes.each do |attr|
            mapped_attr = mappings[attr]
            type = types[attr]
            unless entry[mapped_attr].nil?
              unless type == :array
                value = convert(type, entry[mapped_attr].first)
              else
                value = convert(type, entry[mapped_attr])
              end
              attrs[attr] = value
            else
              attrs[attr] = nil
            end
          end
          attrs
        end

      end
    end
  end
end
