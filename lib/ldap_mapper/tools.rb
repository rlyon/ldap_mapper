module LdapMapper
  class Tools
    class << self
      def to_hash(entry, options = {})
        compress = options.include?(:compress) ? options[:compress] : false
        hash = {}
        entry.attribute_names.each do |name|
          name_s = name.to_s
          if compress
            value = (entry[name_s].size > 1) ? entry[name_s] : entry[name_s].first
          else
            value = entry[name_s]
          end
          hash[name_s] = value
        end
        hash
      end
    end
  end
end