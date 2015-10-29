module DHL
  module Ecommerce
    class Event < Base
      include DHL::Ecommerce::Operations::Find
      include DHL::Ecommerce::Operations::List

      attr_reader :id, :description

      def initialize(attributes = {})
        super attributes

        unless attributes.empty?
          @description.upcase! if @description
        end
      end
    end
  end
end
