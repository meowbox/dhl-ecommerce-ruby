module DHL
  module Ecommerce
    class Account < Base
      include DHL::Ecommerce::Operations::Find
      include DHL::Ecommerce::Operations::List

      attr_reader :id, :name, :address_1, :address_2, :city, :state, :postal_code, :country, :email, :contact

      def initialize(attributes = {})
        super attributes

        @id = attributes.account.to_i
        @name = attributes.account_name
        @address_1 = attributes.address1
        @address_2 = attributes.address2
      end

      def locations
        response = DHL::Ecommerce.request :get, "https://api.dhlglobalmail.com/v1/accounts/#{id}/locations"
        response["Account"]["Locations"].map { |_, attributes| DHL::Ecommerce::Location.new(attributes) }
      end
    end
  end
end
