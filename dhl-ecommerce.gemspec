require "dhl/ecommerce/version"

Gem::Specification.new do |s|
  s.name          = "dhl-ecommerce"
  s.version       = DHL::Ecommerce::VERSION
  s.authors       = ["Francois Deschenes"]
  s.email         = ["francois@meowbox.com"]
  s.description   = %q{}
  s.summary       = %q{}
  s.homepage      = "https://github.com/meowbox/dhl-ecommerce-ruby"
  s.license       = "MIT"

  s.files         = Dir["LICENSE.txt", "README.md", "lib/**/*"]
  s.test_files    = Dir["spec/**/*"]
  s.require_paths = ["lib"]

  s.add_development_dependency "bundler", "~> 1.3"
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
  s.add_development_dependency "vcr"
  s.add_development_dependency "webmock"

  s.add_dependency "builder"
  s.add_dependency "faraday"
  s.add_dependency "faraday_middleware"
  s.add_dependency "hashie", "~> 2.0.0"
  s.add_dependency "multi_xml"
  s.add_dependency "rash"
end
