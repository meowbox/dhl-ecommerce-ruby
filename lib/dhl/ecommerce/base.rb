module DHL
  module Ecommerce
    class Base
      def initialize(attributes = {})
        attributes.each do |attribute, value|
          instance_variable_set "@#{attribute}", value if respond_to? attribute
        end
      end

      private
        def self.resource_name
          self.name.split("::").last
        end
    end
  end
end
