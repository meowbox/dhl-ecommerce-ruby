module DHL
  module Ecommerce
    class StandardAddress < Base
      attr_accessor :name, :firm, :address_1, :address_2, :city, :state, :postal_code, :country

      def initialize(attributes = {})
        super attributes

        unless attributes.empty?
          @name = attributes[:contact] if attributes[:contact]
          @name = attributes[:recipient] if attributes[:recipient]
          @firm = attributes[:account_name] if attributes[:account_name]
          @firm = attributes[:pickup_name] if attributes[:pickup_name]
          @address_1 = attributes[:address1] if attributes[:address1]
          @address_2 = attributes[:address2] if attributes[:address2]
        end
      end
    end
  end
end
