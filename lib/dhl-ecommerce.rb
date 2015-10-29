require "builder"
require "faraday"
require "faraday_middleware"
require "faraday_middleware/response/rashify"
require "hashie"
require "multi_xml"
require "rash"

# Errors
require "dhl/ecommerce/errors/base_error"
require "dhl/ecommerce/errors/authentication_error"
require "dhl/ecommerce/errors/validation_error"

# Operations
require "dhl/ecommerce/operations/find"
require "dhl/ecommerce/operations/list"

# Resources
require "dhl/ecommerce/base"
require "dhl/ecommerce/account"
require "dhl/ecommerce/event"
require "dhl/ecommerce/impb"
require "dhl/ecommerce/label"
require "dhl/ecommerce/location"
require "dhl/ecommerce/manifest"
require "dhl/ecommerce/product"
require "dhl/ecommerce/standard_address"
require "dhl/ecommerce/tracked_event"

# Version
require "dhl/ecommerce/version"

module DHL
  module Ecommerce
    @access_token = ENV["DHL_ECOMMERCE_ACCESS_TOKEN"]
    @client_id = ENV["DHL_ECOMMERCE_CLIENT_ID"]
    @password = ENV["DHL_ECOMMERCE_PASSWORD"]
    @username = ENV["DHL_ECOMMERCE_USERNAME"]
    @label_format = :png

    class << self
      attr_accessor :client_id, :label_format
      attr_writer :access_token, :password, :username

      def configure
        yield self
      end
    end

    def self.access_token
      # TODO This needs better error handling.
      @access_token ||= client.get("https://api.dhlglobalmail.com/v1/auth/access_token", username: @username, password: @password, state: Time.now.to_i).body.response.data[:access_token]
    end

    def self.request(method, url, &block)
      client.params = {
        access_token: self.access_token,
        client_id: client_id
      }

      response = client.run_request method.downcase.to_sym, url, nil, nil, &block

      puts response.to_yaml

      case response.status
      when 400
        case response.body.response.meta.error.error_type
        when "INVALID_CLIENT_ID", "INVALID_KEY", "INVALID_TOKEN", "INACTIVE_KEY"
          throw Errors::AuthenticationError.new response.body.response.meta.error.error_message, response
        when "VALIDATION_ERROR", "INVALID_FACILITY_CODE"
          throw Errors::ValidationError.new response.body.response.meta.error.error_message, response
        else
          throw Errors::BaseError.new response.body.response.meta.error.error_message, response
        end
      end

      response.body.response.data
    end

    private
      def self.client
        @client ||= Faraday.new url: "https://api.dhlglobalmail.com/v1/", headers: { accept: "application/xml", content_type: "application/xml;charset=UTF-8" } do |c|
          c.response :rashify
          c.response :xml, :content_type => /\bxml$/
          c.adapter :net_http
        end
      end
  end
end
