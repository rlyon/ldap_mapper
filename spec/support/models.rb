class LdapFakeUser
  include LdapMapper::Base
  base "ou=people,dc=example,dc=org"
  identifier "uid"
  objectclass "top"
  objectclass "person"
  objectclass "organizationalPerson"
  objectclass "inetOrgPerson"
  objectclass "posixAccount"
  attribute :username,      :map => "uid"
  attribute :common_name,   :map => "cn"
  attribute :first_name,    :map => "givenName"
  attribute :last_name,     :map => "sn"
  attribute :uid_number,    :map => "uidNumber", :type => :integer
  attribute :primary_group, :map => "gidNumber", :type => :integer
  attribute :email,         :map => "mail"
  attribute :password,      :map => "userPassword", :type => :password
end

class LdapFakeGroup
  include LdapMapper::Base
  base "ou=groups,dc=example,dc=org"
  identifier "cn"
  objectclass "top"
  objectclass "posixGroup"
  attribute :common_name,   :map => "cn"
  attribute :gid,           :map => "gidNumber", :type => :integer
  attribute :description,   :map => "description"
  attribute :members,       :map => "memberUid", :type => :array
end

class LdapTestUser
  include LdapMapper::Base
  base "ou=test,dc=example,dc=org"
  objectclass "posixAccount"
  objectclass "shadowAccount"
  objectclass "inetOrgPerson"
  attribute :username,      :map => "uid"
  attribute :common_name,   :map => "cn"
  attribute :email,         :map => "mail"
  attribute :uid_number,    :map => "uidNumber", :type => :integer
  attribute :group_number,  :map => "gidNumber", :type => :integer
  attribute :last_change,   :map => "shadowLastChange", :type => :epoch_days
  attribute :password,      :map => "userPassword", :type => :password
end