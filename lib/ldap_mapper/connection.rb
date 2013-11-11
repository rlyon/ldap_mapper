module LdapMapper
  module Connection
    @@connection = nil

    def connection
      @connection ||= Net::LDAP.new(
        :host => LDAP_MAPPER_HOST,
        :port => LDAP_MAPPER_PORT,
        :auth => {
          :method => :simple,
          :username => LDAP_MAPPER_ADMIN,
          :password => LDAP_MAPPER_ADMIN_PASSWORD
        })
    end

    def connection?
      !!@@connection
    end
  end
end