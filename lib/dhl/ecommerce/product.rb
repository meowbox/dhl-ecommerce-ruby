module DHL
  module Ecommerce
    class Product < Base
      include DHL::Ecommerce::Operations::Find
      include DHL::Ecommerce::Operations::List

      TYPES = {
        domestic: "DomesticUS",
        international: "International"
      }

      CATEGORIES = {
        clearance: "Clearance",
        expedited: "Expedited",
        expedited_parcel: "Expedited P",
        ground: "Ground",
        other: "Other Services",
        priority: "Priority",
        standard: "Standard"
      }

      attr_reader :id, :name, :category, :type

      def initialize(attributes = {})
        super attributes

        unless attributes.empty?
          @category = CATEGORIES.key(attributes[:category]) if attributes[:category]
          @type = TYPES.key(attributes[:class]) if attributes[:class]
        end
      end
    end
  end
end
