module DHL
  module Ecommerce
    class Location < Base
      include DHL::Ecommerce::Operations::Find
      include DHL::Ecommerce::Operations::List

      attr_reader :id, :account_id, :name, :address_1, :address_2, :city, :state, :postal_code, :country, :email, :contact, :phone, :fax

      def initialize(attributes = {})
        super attributes

        unless attributes.empty?
          @id = attributes[:pickup].to_i if attributes[:pickup]
          @account_id = attributes[:account].to_i if attributes[:account]
          @name = attributes[:pickup_name] if attributes[:pickup_name]
          @address_1 = attributes[:address1] if attributes[:address1]
          @address_2 = attributes[:address2] if attributes[:address2]
        end
      end

      def account
        @account ||= DHL::Ecommerce::Account.find(account_id)
      end
    end
  end
end
