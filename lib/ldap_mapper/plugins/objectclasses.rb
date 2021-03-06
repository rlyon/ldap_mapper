module LdapMapper
  module Plugins
    module ObjectClasses
      extend ActiveSupport::Concern
        
      included do
        extend ActiveSupport::DescendantsTracker
      end

      module ClassMethods
        def objectclasses
          @objectclasses ||= []
        end

        def objectclass(name)
          objectclasses << name 
        end
      end

      def objectclasses
        @objectclasses ||= self.class.objectclasses
      end
    end
  end
end