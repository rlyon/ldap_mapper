module LdapMapper
  module Plugins
    module BaseDn
      extend ActiveSupport::Concern
        
      included do
        extend ActiveSupport::DescendantsTracker
      end

      module ClassMethods
        def basedn(type)
          class_eval <<-EOS, __FILE__, __LINE__
            def basedn
              "#{type.to_s}"
            end
          EOS
          @basedn = type.to_s
        end
      end

      def basedn
        raise "Base must be defined before using."
      end

    end
  end
end