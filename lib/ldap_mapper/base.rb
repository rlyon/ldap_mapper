module LdapMapper
  module Base
    extend ActiveSupport::Concern
    extend Plugins
    extend Tools

    include Plugins::ActiveModel
    include Plugins::Attributes
    include Plugins::BaseDn
    include Plugins::Identifier
    include Plugins::ObjectClasses
    include Plugins::Query

    included do
      extend Plugins
      extend Tools
    end

    include Tools

    VALID_STATES = [:new, :existing, :modified]
    
    def initialize(attrs = {}, state = :new)
      attrs.each do |key, value|
        attributes[key] = cast(types[key], value)
        ldap_attributes[key] = value if state == :existing
      end
      @_state = state
    end
  end
end
