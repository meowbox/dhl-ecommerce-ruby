module DHL
  module Ecommerce
    module Operations
      module List
        module ClassMethods
          def all
            response = DHL::Ecommerce.request :get, "https://api.dhlglobalmail.com/v1/#{resource_name.downcase}s"
            response["#{resource_name}s"][resource_name] = [response["#{resource_name}s"][resource_name]] unless response["#{resource_name}s"][resource_name].is_a? Array
            response["#{resource_name}s"][resource_name].map do |attributes| new attributes end
          end
        end

        def self.included(base)
          base.extend ClassMethods
        end
      end
    end
  end
end
