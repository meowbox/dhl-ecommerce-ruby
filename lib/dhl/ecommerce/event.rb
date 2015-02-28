module DHL
  module Ecommerce
    class Event < Base
      include DHL::Ecommerce::Operations::Find
      include DHL::Ecommerce::Operations::List

      attr_reader :id, :description
    end
  end
end
