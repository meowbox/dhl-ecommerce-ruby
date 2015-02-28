module DHL
  module Ecommerce
    class Product < Base
      include DHL::Ecommerce::Operations::Find
      include DHL::Ecommerce::Operations::List

      attr_reader :id, :name, :category, :class
    end
  end
end
