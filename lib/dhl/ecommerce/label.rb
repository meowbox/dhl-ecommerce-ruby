module DHL
  module Ecommerce
    class Label < Base
      attr_accessor :package_id, :location_id, :product_id, :service_endorsement, :billing_reference_1, :billing_reference_2, :mail_type_code, :facility, :expected_ship_date, :weight, :consignee_address, :return_address
      attr_reader :id, :service_level, :service_type, :zpl, :impb

      FACILITIES = {
        forest_park: "USATL1",
        franklin: "USBOS1",
        elkridge: "USBWI1",
        hebron: "USCVG1",
        denver: "USDEN1",
        grand_prairie: "USDFW1",
        secaucus: "USEWR1",
        edgewood: "USISP1",
        compton: "USLAX1",
        orlando: "USMCO1",
        memphis: "USMEM1",
        melrose_park: "USORD1",
        phoenix: "USPHX1",
        auburn: "USSEA1",
        union_city: "USSFO1",
        salt_lake_city: "USSLC1",
        st_louis: "USSTL1"
      }

      SERVICE_ENDORSEMENTS = {
        address_service: 1,
        forwarding_service: 2,
        change_service: 3,
        return_service: 4,
      }

      SERVICE_LEVELS = {
        ground: 'GRD'
      }

      def location
        @location ||= DHL::Ecommerce::Location.find location_id
      end

      def location=(location)
        @location = nil if @location_id != location.id
        @location_id = location.id
      end

      def pdf
        return false unless zpl
      end

      def png
        return false unless zpl
      end

      def product
        @product ||= DHL::Ecommerce::Product.find product_id
      end

      def product=(product)
        @product = nil if @product_id != product.id
        @product_id = product.id
      end

      def save!
        url = "https://api.dhlglobalmail.com/v1/#{self.class.resource_name.downcase}/#{consignee_address.country.to_s.upcase}/#{@location_id}/zpl"

        attributes = DHL::Ecommerce.request :post, url do |c|
          c.body = xml
        end

        @id = attributes[:mpu_list][:mpu][:mail_item_id].to_i if attributes[:mpu_list][:mpu][:mail_item_id]
        @zpl = attributes[:mpu_list][:mpu][:label_zpl] if attributes[:mpu_list][:mpu][:label_zpl]

        unless attributes[:mpu_list][:mpu][:label_detail].empty?
          @impb = attributes[:mpu_list][:mpu][:label_detail][:impb][:value].to_i if attributes[:mpu_list][:mpu][:label_detail][:impb][:value]
          @service_level = SERVICE_LEVELS.key attributes[:mpu_list][:mpu][:label_detail][:service_level] if attributes[:mpu_list][:mpu][:label_detail][:service_level]

          @service_type = attributes[:mpu_list][:mpu][:label_detail][:service_type_code].to_i if attributes[:mpu_list][:mpu][:label_detail][:service_type_code]
        end

        true
      end

      private
        def xml
          xml = Builder::XmlMarkup.new
          xml.instruct! :xml, version: "1.1", encoding: "UTF-8"
          xml.EncodeRequest do
            xml.CustomerId location_id
            xml.BatchRef DateTime.now.strftime("%Q")
            xml.HalfOnError false
            xml.RejectAllOnError true
            xml.MpuList do
              xml.Mpu do
                xml.PackageId package_id

                xml.PackageRef do
                  xml.PrintFlag true
                  xml.LabelText "PKG ID"
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
                # xml.Service ""

                xml.ServiceEndorsement SERVICE_ENDORSEMENTS.fetch service_endorsement.downcase.to_sym if service_endorsement

                # xml.DgCategory ""

                xml.Weight do
                  xml.Value weight
                  xml.Unit :lb.to_s.upcase
                end

                xml.BillingRef1 billing_reference_1
                xml.BillingRef2 billing_reference_2
                xml.FacilityCode FACILITIES.fetch facility.downcase.to_sym if facility
                xml.ExpectedShipDate (expected_ship_date || DateTime.now).strftime("%Y%m%d")
                xml.MailTypeCode 7
              end
            end
          end
        end
    end
  end
end
