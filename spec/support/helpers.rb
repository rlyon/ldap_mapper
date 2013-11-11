def check_password(password, ssha)
  salt = Base64.decode64(ssha.gsub(/^\{SSHA\}/, ''))[20..-1]
  Net::LDAP::Password.generate(:ssha, password, salt)
end