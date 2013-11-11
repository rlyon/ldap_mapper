module LdapMapper
  module Plugins
    module Base
      extend ActiveSupport::Concern
        
      included do
        extend ActiveSupport::DescendantsTracker
      end

      module ClassMethods
        def base(type)
          class_eval <<-EOS, __FILE__, __LINE__
            def base
              "#{type.to_s}"
            end
          EOS
          @base = type.to_s
        end
      end
    end
  end
end