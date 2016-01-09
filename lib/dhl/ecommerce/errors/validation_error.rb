module DHL
  module Ecommerce
    module Errors
      class ValidationError < BaseError
        attr_reader :errors

        def initialize(message = nil, response = nil, errors = nil)
          super message, response
          @errors = errors
        end
      end
    end
  end
end
