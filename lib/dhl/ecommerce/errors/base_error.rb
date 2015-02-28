module DHL
  module Ecommerce
    module Errors
      class BaseError < StandardError
        attr_reader :response

        def initialize(message = nil, response = nil)
          super message

          @response = response
        end
      end
    end
  end
end
