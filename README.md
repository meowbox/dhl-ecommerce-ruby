# DHL eCommerce API Wrapper for Ruby

[![Build Status](https://travis-ci.org/meowbox/dhl-ecommerce-ruby.svg)](https://travis-ci.org/meowbox/dhl-ecommerce-ruby)

## Installation

Installation is as simple at adding the following to your `Gemfile`.

```ruby
gem "dhl-ecommerce"
```

## Configuration

The only configuration necessary is your `client_id` and either a `username`
and `password` or an `access_token`.

```ruby
# DHL e-Commerce configuration.
DHL::Ecommerce.configure do |config|
  config.username = "meowbox"
  config.password = "password"
  config.client_id = 6369

  # Label format can be either :png or :zpl.
  config.label_format = :png
end
```

## Usage

### Accounts

```ruby
# Find all accounts.
accounts = DHL::Ecommerce::Account.all

# Find a particular account.
account = DHL::Ecommerce::Account.find 6369
```

### Locations

```ruby
# Find all locations.
locations = DHL::Ecommerce::Location.all

# Find a particular location.
location = DHL::Ecommerce::Location.find 6369
```

It's also possible to obtain a list of locations from an account by calling the
`locations` method.

### Labels

```ruby
# Create the consignee's address.
consignee_address = DHL::Ecommerce::StandardAddress.new firm: "meowbox Inc.",
                                                        address_1: "816 PEACE PORTAL DR",
                                                        address_2: "STE 103",
                                                        city: "BLAINE",
                                                        postal_code: "98230",
                                                        state: "WA",
                                                        country: "US"

# Create a single label.
label = DHL::Ecommerce::Label.create consignee_address: consignee_address,
                                     facility: :auburn,
                                     location_id: 5325183,
                                     product_id: 83,
                                     weight: 1
```

The `file` method of any valid label object will return a `StringIO` object
containing either the PNG or ZPL representation of the label depending on your
configuration.

It's also possible to create multiple labels at once by passing an array of
attributes to the `create` method.

```ruby
# Create multiple labels.
labels = DHL::Ecommerce::Label.create [ label_attributes_1, label_attributes_2 ]
```

### Manifests

Unlike other models, the `create` method will always return an array of
`Manifest` objects – that's because the DHL e-Commerce API will return a
manifest for each location and/or facility.

```ruby
# Create manifests
manifests = DHL::Ecommerce::Manifest.create labels
```

### Tracking

```ruby
# Find events for a particular label.
events = DHL::Ecommerce::Label.find("420000000000000001").events
```

### Other models

A few supporting models are also available.

- `Event`
- `Imbp`
- `Product`
- `StandardAddress`
