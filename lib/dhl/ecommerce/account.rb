module DHL
  module Ecommerce
    class Account < Base
      include DHL::Ecommerce::Operations::Find
      include DHL::Ecommerce::Operations::List

      attr_reader :id, :name, :address_1, :address_2, :city, :state, :postal_code, :country, :email, :contact

      def initialize(attributes = {})
        super attributes

        unless attributes.empty?
          @id = attributes[:account].to_i if attributes[:account]
          @name = attributes[:account_name] if attributes[:account_name]
          @address_1 = attributes[:address1] if attributes[:address1]
          @address_2 = attributes[:address2] if attributes[:address2]
        end
      end

      def locations
        response = DHL::Ecommerce.request :get, "https://api.dhlglobalmail.com/v1/{DHL::Ecommerce::Location.resource_name.downcase}s/#{id}/#{DHL::Ecommerce::Location.resource_name.downcase}s"
        response[self.resource_name]["#{DHL::Ecommerce::Location.resource_name}s"][DHL::Ecommerce::Location.resource_name] = [response[self.resource_name]["#{DHL::Ecommerce::Location.resource_name}s"][DHL::Ecommerce::Location.resource_name]] unless response[self.resource_name]["#{DHL::Ecommerce::Location.resource_name}s"][DHL::Ecommerce::Location.resource_name].is_a? Array
        response[self.resource_name]["#{DHL::Ecommerce::Location.resource_name}s"].map { |attributes| DHL::Ecommerce::Location.new attributes }
      end
    end
  end
end
