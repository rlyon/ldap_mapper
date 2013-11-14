module LdapMapper
  module Plugins
    module Identifier
      extend ActiveSupport::Concern
        
      included do
        extend ActiveSupport::DescendantsTracker
      end

      module ClassMethods
        def identifier(id)
          class_eval <<-EOS, __FILE__, __LINE__
            def identifier
              "#{id.to_s}"
            end
          EOS
          @identifier = id
        end

        def default_id
          @identifier
        end
      end
    end
  end
end