module DHL
  module Ecommerce
    class TrackedEvent < Base
      include DHL::Ecommerce::Operations::Find
      include DHL::Ecommerce::Operations::List

      attr_reader :created_at, :event, :location, :postal_code

      def initialize(attributes = {})
        super attributes

        unless attributes.empty?
          @created_at = Time.parse("#{attributes[:date]} #{attributes[:time]} #{attributes[:time_zone]}") if attributes[:date] && attributes[:time] && attributes[:time_zone]
        end
      end
    end
  end
end
