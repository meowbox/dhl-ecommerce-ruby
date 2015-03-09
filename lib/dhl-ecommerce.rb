require "builder"
require "faraday"
require "faraday_middleware"
require "faraday_middleware/response/rashify"
require "hashie"
require "multi_xml"
require "rash"

# Errors
require_relative "dhl/ecommerce/errors/base_error"
require_relative "dhl/ecommerce/errors/authentication_error"

# Operations
require_relative "dhl/ecommerce/operations/find"
require_relative "dhl/ecommerce/operations/list"

# Resources
require_relative "dhl/ecommerce/base"
require_relative "dhl/ecommerce/account"
require_relative "dhl/ecommerce/event"
require_relative "dhl/ecommerce/label"
require_relative "dhl/ecommerce/location"
require_relative "dhl/ecommerce/product"
require_relative "dhl/ecommerce/standard_address"

# Version
require_relative "dhl/ecommerce/version"

module DHL
  module Ecommerce
    @access_token = ENV["DHL_ECOMMERCE_ACCESS_TOKEN"]
    @client_id = ENV["DHL_ECOMMERCE_CLIENT_ID"]
    @password = ENV["DHL_ECOMMERCE_PASSWORD"]
    @username = ENV["DHL_ECOMMERCE_USERNAME"]

    class << self
      attr_accessor :access_token, :client_id, :password, :username

      def configure
        yield self
      end
    end

    def self.request(method, url, &block)
      client.params = {
        access_token: access_token,
        client_id: client_id
      }

      response = client.run_request method.downcase.to_sym, url, nil, nil, &block

      case response.status
      when 400
        case response.body.response.meta.error.error_type
        when "INVALID_CLIENT_ID", "INVALID_TOKEN"
          throw AuthenticationError.new response.body.response.meta.error.error_message, response
        end
      end

      response.body.response.data
    end

    private
      def self.client
        @client ||= Faraday.new url: "https://api.dhlglobalmail.com/v1/", headers: { accept: "application/xml", content_type: "application/xml;charset=UTF-8" } do |c|
          c.adapter :net_http
          c.response :rashify
          c.response :xml, :content_type => /\bxml$/
        end
      end
  end
end
