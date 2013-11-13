module LdapMapper
  module Tools
    def convert(type, value)
      case type
      when :array
        value
      when :epoch_days
        value.to_i.epoch_days
      else
        value.to_s
      end
    end

    def cast(type, value)
      return nil if value.nil?

      case type
      when :integer
        value.to_i
      when :array
        value
      when :epoch_days
        if value.is_a?(Time)
          value
        else
          value.to_i.epoch_days
        end
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