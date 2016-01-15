module DHL
  module Ecommerce
    class Manifest < Base
      attr_reader :id, :location_id

      def location_id=(location_id)
        @location = nil
        @location_id = location_id
      end

      def location
        @location ||= DHL::Ecommerce::Location.find location_id
      end

      def file
        @base64_decoded_file ||= StringIO.new(Base64.decode64(@file))
      end

      def self.create(labels)
        labels.group_by(&:location_id).each.collect do |location_id, location_labels|
          closeout_id = DHL::Ecommerce.request :get, "https://api.dhlglobalmail.com/v1/#{DHL::Ecommerce::Location.resource_name.downcase}s/#{location_id}/closeout/id"

          location_labels.each_slice(500) do |slice_labels|
            xml = Builder::XmlMarkup.new
            xml.instruct! :xml, version: "1.1", encoding: "UTF-8"

            xml.ImpbList do
              slice_labels.each do |label|
                xml.Impb do
                  xml.Construct label.impb.construct
                  xml.Value label.impb.value
                end
              end
            end

            DHL::Ecommerce.request :post, "https://api.dhlglobalmail.com/v1/#{DHL::Ecommerce::Location.resource_name.downcase}s/#{location_id}/closeout/#{closeout_id}" do |request|
              request.body = xml.target!
            end
          end

          response = DHL::Ecommerce.request :get, "https://api.dhlglobalmail.com/v1/#{DHL::Ecommerce::Location.resource_name.downcase}s/#{location_id}/closeout/#{closeout_id}"
          response[:manifest_list][:manifest] = [response[:manifest_list][:manifest]] unless response[:manifest_list][:manifest].is_a? Array
          response[:manifest_list][:manifest].each.collect do |attributes|
            new attributes.merge(location_id: location_id)
          end
        end.flatten
      end
    end
  end
end
