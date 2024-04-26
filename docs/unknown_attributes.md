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

configurations = Configuration.to_array_type.cast_value([{ color: "red", archived: true }, { color: "blue", archived: false }])
configurations.map { |config| config.unknown_attributes } # => [{ "archived" => true }, { "archived" => false }]

```

## Serialization of unknown attributes

By default `StoreModel` will serialize unknown attributes when you call `as_json` on an instance.

```ruby
configuration = Configuration.to_type.cast_value(color: "red", archived: true)
configuration.as_json # => {"color": "red", "archived": true}
```

You can change that behavior globally by turning off serialization for unknown attributes.

```ruby
StoreModel.config.serialize_unknown_attributes = false

configuration = Configuration.to_type.cast_value(color: "red", archived: true)
configuration.as_json # => {"color": "red"}
```

You can always pass the `serialize_unknown_attributes` option to the `as_json` method to override the globally configured behavior.

```ruby
StoreModel.config.serialize_unknown_attributes = false

configuration = Configuration.to_type.cast_value(color: "red", archived: true)
configuration.as_json(serialize_unknown_attributes: true) # => {"color": "red", "archived": true}
```

In any case unknown attributes are always stored in the database.
