module DHL
  module Ecommerce
    class StandardAddress < Base
      attr_accessor :name, :firm, :address_1, :address_2, :city, :state, :postal_code, :country
    end
  end
end
