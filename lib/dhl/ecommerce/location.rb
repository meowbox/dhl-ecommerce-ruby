module DHL
  module Ecommerce
    class Location < Base
      include DHL::Ecommerce::Operations::Find
      include DHL::Ecommerce::Operations::List

      attr_reader :id, :account_id, :name, :address_1, :address_2, :city, :state, :postal_code, :country, :email, :contact, :phone, :fax

      def initialize(attributes)
        @id = attributes["Pickup"].to_i
        @account_id = attributes["Account"].to_i
        @name = attributes["PickupName"]
        @address_1 = attributes["Address1"]
        @address_2 = attributes["Address2"]
      end

      def account
        DHL::Ecommerce::Account.find account_id
      end
    end
  end
end
