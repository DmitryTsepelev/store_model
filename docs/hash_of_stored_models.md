## Hash of stored models

When you need to store a keyed collection of stored models (similar to a dictionary or map), use the `#to_hash_type` method:

```ruby
class Product < ApplicationRecord
  attribute :configurations, Configuration.to_hash_type
end
```

After that, your attribute will return a hash with string keys and `Configuration` instances as values.

### Basic Usage

```ruby
# Create a new product with configurations
product = Product.new
product.configurations["primary"] = Configuration.new(color: "red", model: "spaceship")
product.configurations["secondary"] = Configuration.new(color: "blue", model: "rocket")

# Access configurations by key
product.configurations["primary"].color     # => "red"
product.configurations["secondary"].model   # => "rocket"

# Update a configuration
product.configurations["primary"].color = "green"

# Remove a configuration
product.configurations.delete("secondary")

# Check if a key exists
product.configurations.key?("primary")      # => true

# Iterate over configurations
product.configurations.each do |key, config|
  puts "#{key}: #{config.color}"
end
```

### JSON Structure

The hash is stored as a JSON object in the database:

```json
{
  "primary": {
    "color": "red",
    "model": "spaceship",
    "active": true
  },
  "secondary": {
    "color": "blue",
    "model": "rocket",
    "active": false
  }
}
```

### Assigning Values

You can assign values in several ways:

```ruby
# Assign a hash of attributes
product.configurations = {
  "primary" => { color: "red", model: "spaceship" },
  "secondary" => { color: "blue", model: "rocket" }
}

# Assign a hash of Configuration instances
product.configurations = {
  "primary" => Configuration.new(color: "red"),
  "secondary" => Configuration.new(color: "blue")
}

# Assign from JSON string
product.configurations = '{"primary": {"color": "red"}, "secondary": {"color": "blue"}}'
```

### Validation

When using hash types with validations, all values in the hash will be validated:

```ruby
class Configuration
  include StoreModel::Model
  
  attribute :color, :string
  validates :color, presence: true
end

class Product < ApplicationRecord
  attribute :configurations, Configuration.to_hash_type
  validates :configurations, store_model: true
end

product = Product.new
product.configurations["invalid"] = Configuration.new(color: nil)
product.valid? # => false
product.errors.full_messages # => ["Configurations is invalid"]
```

#### Using merge_hash_errors

By default, hash validation errors are reported generically. You can use the `merge_hash_errors` option to get more detailed error messages that include the hash key:

```ruby
class Product < ApplicationRecord
  attribute :configurations, Configuration.to_hash_type
  validates :configurations, store_model: { merge_hash_errors: true }
end

product = Product.new
product.configurations["primary"] = Configuration.new(color: nil)
product.configurations["secondary"] = Configuration.new(color: nil)
product.valid? # => false
product.errors.full_messages 
# => ["Configurations [primary] Color can't be blank", 
#     "Configurations [secondary] Color can't be blank"]
```

### Important Notes

> **Heads up!** The attribute is not the same as an association. It's just a hash stored as JSON. `assign_attributes` (and similar) is going to _override_ the whole hash, not merge it with a previous value.

> **Note:** Keys are always stored and returned as strings, even if you use symbols when setting values.

### Using with Polymorphic Models (one_of)

You can use `StoreModel.one_of` with hash types to store different model types based on their content:

```ruby
ConfigurationV1 = Class.new do
  include StoreModel::Model
  attribute :version, :string, default: "v1"
  attribute :timeout, :integer
end

ConfigurationV2 = Class.new do
  include StoreModel::Model
  attribute :version, :string, default: "v2"
  attribute :timeout, :integer
  attribute :retries, :integer
end

class Product < ApplicationRecord
  attribute :configurations, StoreModel.one_of { |json|
    json[:version] == "v2" ? ConfigurationV2 : ConfigurationV1
  }.to_hash_type
end

# Usage
product = Product.new
product.configurations = {
  "api" => { version: "v1", timeout: 30 },
  "database" => { version: "v2", timeout: 60, retries: 3 }
}

product.configurations["api"]       # => ConfigurationV1 instance
product.configurations["database"]  # => ConfigurationV2 instance
```