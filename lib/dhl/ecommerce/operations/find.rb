module DHL
  module Ecommerce
    module Operations
      module Find
        module ClassMethods
          def find(id)
            attributes = DHL::Ecommerce.request :get, "https://api.dhlglobalmail.com/v1/#{resource_name.downcase}s/#{id}"
            new attributes[resource_name]
          end
        end

        def self.included(base)
          base.extend ClassMethods
        end
      end
    end
  end
end
