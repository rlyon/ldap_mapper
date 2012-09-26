require 'digest/sha1'
require 'digest/md5'
class Net::LDAP::Password
  class << self
    def generate(type, str, salt=nil)
      case type
      when :md5
        digest = Digest::MD5.new
        digest << str.to_s
        "{MD5}" + [digest.digest].pack('m').chomp
      when :sha
        digest = Digest::SHA1.new
        digest << str.to_s
        "{SHA}" + [digest.digest].pack('m').chomp
      when :ssha
        salt = String.random :length => 8 unless salt
        "{SSHA}"+Base64.encode64(Digest::SHA1.digest(str+salt)+salt).gsub(/\n/, '')
      else
        raise Net::LDAP::LdapError, "Unsupported password-hash type (#{type})"
      end
    end
  end
end