def check_password(password, ssha)
  salt = Base64.decode64(ssha.gsub(/^\{SSHA\}/, ''))[20..-1]
  Net::LDAP::Password.generate(:ssha, password, salt)
end

# def check_hashed(password, ssha)
#   decoded = Base64.decode64(ssha.gsub(/^{SSHA}/, ''))
#   hash = decoded[0,20] # isolate the hash
#   salt = decoded[20,-1] # isolate the salt
#   hash_password(password, salt) == ssha
# end