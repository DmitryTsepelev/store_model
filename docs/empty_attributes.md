# Empty attributes

In some cases, you might want to skip attributes if values were not provided
For example, here if value was not provided then supplier will be saved as `null` for Configuration instance:

```ruby
class Supplier
  include StoreModel::Model

  attribute :title, :string
end

class Configuration
  include StoreModel::Model

  attribute :supplier, Supplier.to_type
end
```

## Serialization of empty attributes

By default `StoreModel` will serialize empty attributes when you call `as_json` on an instance.
You can change that behavior globally by turning off serialization for empty attributes.

```ruby
StoreModel.config.serialize_empty_attributes = false
```

This option is propagated to array items and nested structures as well.
