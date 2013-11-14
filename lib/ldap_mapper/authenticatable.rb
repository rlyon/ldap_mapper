module LdapMapper
  module Authenticatable
    extend ActiveSupport::Concern

    included do 
      extend ActiveSupport::DescendantsTracker
    end

    module ClassMethods
      def auth_attributes_allowed(*attrs)
        @auth_allowed = attrs
      end

      def authenticate(value, password)
        authenticate_do(default_id, value, password)
      end

      def authenticate_by(options = {})
        raise NotAuthorizedError, "Unable to authenticate using #{options[:attr]}." unless auth_allowed.include?(options[:attr])
        mapped_attr = self.mappings[options[:attr]]
        authenticate_do(mapped_attr, options[:value], options[:password])
      end

      def auth_allowed
        @auth_allowed ||= @auth_allowed.empty? [default_id]
      end

    private
      def authenticate_do(mapped_attr, value, password)
        filter = "(#{mapped_attr}=#{value})"
        result = connection.bind_as(
          :base => prefix,
          :filter => filter,
          :password => password)
        if result
          true
        else
          false
        end
      end
    end
  end
end