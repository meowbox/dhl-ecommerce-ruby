module DHL
  module Ecommerce
    class Base
      def initialize(attributes = {})
        attributes.each do |attribute, value|
          next if attribute.to_sym == :class

          if respond_to? "#{attribute}="
            send "#{attribute}=", value
          elsif respond_to?("#{attribute}")
            instance_variable_set "@#{attribute}", value
          end
        end unless attributes.empty?
      end

      private
        def self.resource_name
          self.name.split("::").last
        end
    end
  end
end
