module DHL
  module Ecommerce
    class Label < Base
      attr_accessor :customer_confirmation_number, :service_endorsement, :reference, :batch, :mail_type, :facility, :expected_ship_date, :weight, :consignee_address, :return_address, :service
      attr_reader :id, :location_id, :product_id, :events, :service_type, :file, :impb

      FACILITIES = {
        auburn: "USSEA1",
        compton: "USLAX1",
        denver: "USDEN1",
        edgewood: "USISP1",
        elkridge: "USBWI1",
        forest_park: "USATL1",
        franklin: "USBOS1",
        grand_prairie: "USDFW1",
        hebron: "USCVG1",
        melrose_park: "USORD1",
        memphis: "USMEM1",
        orlando: "USMCO1",
        phoenix: "USPHX1",
        salt_lake_city: "USSLC1",
        secaucus: "USEWR1",
        st_louis: "USSTL1",
        union_city: "USSFO1"
      }

      MAIL_TYPES = {
        bound_printed_matter: 6,
        irregular_parcel: 2,
        machinable_parcel: 3,
        marketing_parcel_gte_6oz: 30,
        marketing_parcel_lt_6oz: 20,
        media_mail: 9,
        parcel_select_machinable: 7,
        parcel_select_nonmachinable: 8
      }

      SERVICES = {
        delivery_confirmation: "DELCON",
        signature_confirmation: "SIGCON"
      }

      SERVICE_ENDORSEMENTS = {
        address_service: 1,
        change_service: 3,
        forwarding_service: 2,
        return_service: 4
      }

      def location_id=(location_id)
        @location = nil
        @location_id = location_id
      end

      def location
        @location ||= DHL::Ecommerce::Location.find location_id
      end

      def location=(location)
        @location = nil if @location_id != location.id
        @location_id = location.id
      end

      def product_id=(product_id)
        @product = nil
        @product_id = product_id
      end

      def product
        @product ||= DHL::Ecommerce::Product.find product_id
      end

      def product=(product)
        @product = nil if @product_id != product.id
        @product_id = product.id
      end

      def self.create(attributes)
        array = attributes.is_a? Array
        attributes = [attributes] unless array

        labels = self.create_in_batches attributes

        array ? labels : labels.first
      end

      def self.find(id)
        attributes = DHL::Ecommerce.request :get, "https://api.dhlglobalmail.com/v1/mailitems/track" do |request|
          request.params[:number] = id
        end

        attributes[:mail_items][:mail_item] = attributes[:mail_items][:mail_item].first if attributes[:mail_items][:mail_item].is_a? Array

        new attributes[:mail_items][:mail_item]
      end

      def initialize(attributes = {})
        super attributes

        unless attributes.empty?
          if attributes[:mail]
            @id = attributes[:mail][:mailIdentifier] if attributes[:mail][:mailIdentifier]
            @weight = attributes[:mail][:weight] if attributes[:mail][:weight]
            @product_id = attributes[:mail][:product_id] if attributes[:mail][:product_id]
            @reference = attributes[:mail][:customer_reference] if attributes[:mail][:customer_reference]
            @batch = attributes[:mail][:batch_reference] if attributes[:mail][:batch_reference]
            @impb = attributes[:mail][:intelligent_mail_barcode] if attributes[:mail][:intelligent_mail_barcode]
            @customer_confirmation_number = attributes[:mail][:customer_confirmation_number] if attributes[:mail][:customer_confirmation_number]

            @services = :delivery_confirmation if attributes[:mail][:delivery_confirmation_flag] == '1'
            @services = :signature_confirmation if attributes[:mail][:signature_confirmation_flag] == '1'
          end

          if attributes[:pickup]
            @location_id = attributes[:pickup][:pickup] if attributes[:pickup][:pickup]
          end

          if attributes[:recipient]
            @consignee_address = StandardAddress.new attributes[:recipient]
          end

          if attributes[:events]
            @events = []

            attributes[:events][:event] = [attributes[:events][:event]] unless attributes[:events][:event].is_a? Array
            attributes[:events][:event].each do |event_attributes|
              event = TrackedEvent.new event_attributes
              event.instance_variable_set :@event, Event.new(event_attributes)

              @events << event
            end
          end
        end
      end

      private

      def xml
        xml = Builder::XmlMarkup.new
        xml.Mpu do
          xml.PackageId customer_confirmation_number

          xml.PackageRef do
            xml.PrintFlag customer_confirmation_number.present?
            # xml.LabelText ""
          end

          xml.ConsigneeAddress do
            xml.StandardAddress do
              xml.Name consignee_address.name
              xml.Firm consignee_address.firm
              xml.Address1 consignee_address.address_1
              xml.Address2 consignee_address.address_2
              xml.City consignee_address.city
              xml.State consignee_address.state.to_s.upcase
              xml.Zip consignee_address.postal_code
              xml.CountryCode consignee_address.country.to_s.upcase
            end
          end

          xml.ReturnAddress do
            xml.StandardAddress do
              xml.Name return_address.name
              xml.Firm return_address.firm
              xml.Address1 return_address.address_1
              xml.Address2 return_address.address_2
              xml.City return_address.city
              xml.State return_address.state.to_s.upcase
              xml.Zip return_address.postal_code
              xml.CountryCode return_address.country.to_s.upcase
            end
          end if return_address

          xml.OrderedProductCode product_id
          xml.Service SERVICES.fetch service.downcase.to_sym if service
          xml.ServiceEndorsement SERVICE_ENDORSEMENTS.fetch service_endorsement.downcase.to_sym if service_endorsement

          # xml.DgCategory ""
          # xml.ContactPhoneNumber ""

          xml.Weight do
            xml.Value weight

            # TODO Add support for other units supported by DHL e-Commerce.
            xml.Unit :lb.to_s.upcase
          end

          xml.BillingRef1 reference
          xml.BillingRef2 batch
          xml.FacilityCode FACILITIES.fetch facility.downcase.to_sym if facility
          xml.ExpectedShipDate (expected_ship_date || DateTime.now).strftime("%Y%m%d")
          xml.MailTypeCode MAIL_TYPES.fetch mail_type ? mail_type.downcase.to_sym : :parcel_select_machinable
        end
      end

      def self.create_in_batches(attributes)
        attributes.group_by do |value| value[:location_id] end.each.collect do |location_id, location_attributes|
          case DHL::Ecommerce.label_format
          when :png, :image
            url = "https://api.dhlglobalmail.com/v1/#{self.resource_name.downcase}/US/#{location_id}/image"
          when :zpl
            url = "https://api.dhlglobalmail.com/v1/#{self.resource_name.downcase}/US/#{location_id}/zpl"
          end

          # DHL e-Commerce's documentation says they support creating 500 labels
          # at once but as it turns out, they don't.
          location_attributes.each_slice(1).collect do |slice|
            labels = slice.map do |slice_attributes|
              new slice_attributes
            end

            xml = Builder::XmlMarkup.new
            xml.instruct! :xml, version: "1.1", encoding: "UTF-8"
            xml.EncodeRequest do
              xml.CustomerId location_id
              xml.BatchRef DateTime.now.strftime("%Q")
              xml.HalfOnError false
              xml.RejectAllOnError true
              xml.MpuList do
                xml << labels.map do |label| label.send :xml end.join
              end
            end

            response = DHL::Ecommerce.request :post, url do |request|
              request.body = xml.target!
            end

            response[:mpu_list][:mpu] = [response[:mpu_list][:mpu]] unless response[:mpu_list][:mpu].is_a? Array

            labels.zip(response[:mpu_list][:mpu]).map do |label, label_response|
              label.instance_variable_set :@id, label_response[:mail_item_id].to_i if label_response[:mail_item_id]

              case DHL::Ecommerce.label_format
              when :png, :image
                label.instance_variable_set :@file, StringIO.new(Base64.decode64(label_response[:label_image])) if label_response[:label_image]
              when :zpl
                label.instance_variable_set :@file, StringIO.new(Base64.decode64(label_response[:label_zpl])) if label_response[:label_zpl]
              end

              if label_response[:label_detail]
                label.instance_variable_set :@impb, Impb.new(label_response[:label_detail][:impb]) if label_response[:label_detail][:impb]
                label.instance_variable_set :@service_type, label_response[:label_detail][:service_type_code].to_i if label_response[:label_detail][:service_type_code]
              end

              label
            end
          end
        end.flatten
      end
    end
  end
end
