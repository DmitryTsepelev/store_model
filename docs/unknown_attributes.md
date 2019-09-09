# Unknown attributes

Sometimes JSON structure changes and it contains more keys than attributes defined in your `StoreModel::Model` class. In such cases, "unknown" attributes can be found inside the `#unknown_attributes` hash:

```ruby
class Configuration
  include StoreModel::Model

  attribute :color, :string
end

configuration = Configuration.to_type.cast_value(color: "red", archived: true)
configuration.unknown_attributes # => { "archived" => true }

# OR

configurations = Configuration.to_array_type.cast_value( [{ color: "red", archived: true }, [{ color: "blue", archived: false }])
configurations.map { |config| config.unknown_attributes } # => [{ "archived" => true }, { "archived" => false }]

```
