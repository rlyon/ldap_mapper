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

class Net::LDAP::Entry
  def to_hash(options = {})
    compress = options.include?(:compress) ? options[:compress] : false
    hash = {}
    self.attribute_names.each do |name|
      name_s = name.to_s
      if compress
        value = (self[name_s].size > 1) ? self[name_s] : self[name_s].first
      else
        value = self[name_s]
      end
      hash[name_s] = value
    end
    hash
  end
end