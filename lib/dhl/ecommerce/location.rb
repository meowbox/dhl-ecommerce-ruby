module DHL
  module Ecommerce
    class Location < Base
      include DHL::Ecommerce::Operations::Find
      include DHL::Ecommerce::Operations::List

      attr_reader :id, :account_id, :address, :email, :phone, :fax

      def initialize(attributes = {})
        super attributes

        unless attributes.empty?
          @id = attributes[:pickup].to_i if attributes[:pickup]
          @account_id = attributes[:account].to_i if attributes[:account]
          @address = StandardAddress.new attributes
        end
      end

      def account
        @account ||= DHL::Ecommerce::Account.find(account_id)
      end
    end
  end
end
