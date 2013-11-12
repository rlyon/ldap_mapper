module LdapMapper
  module Tools

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

    def convert(type, value)
      case type
      when :integer
        value.to_i
      when :array
        value
      when :epoch_days
        value.to_i.epoch_days
      when :password
        if value =~ /^\\{SSHA\\}/
          value.to_s
        else
          Net::LDAP::Password.generate(:ssha, value)
        end
      else
        value.to_s
      end
    end

  end
end