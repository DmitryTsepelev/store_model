## Instantiation

You can, of course, instantiate a store model object using `new`:
```ruby
class Configuration
  include StoreModel::Model

  attribute :model, :string
  attribute :color, :string

  validates :color, presence: true
end

config = Configuration.new(model: "spaceship", color: "red")
```

However, the instance will not have all of the behavior that an instance of a store model
"type" would have. For instance, instantiating with `new` will raise errors when unknown
attributes are passed, rather than providing the [Unknown attributes](./unknown_attributes.md) behavior.

Store model "types" are what are assigned to `attribute` definitions in ActiveModel classes.

E.g.:
```ruby
class Product < ApplicationRecord
  attribute :configuration, Configuration.to_type
end
```

If you want to instantiate not just a store model class, but the associated type, you can use
the `from_value` class method:
```ruby
config = Configuration.from_value(model: "spaceship", color: "red", some_other_attribute: "foo")
```

Similarly, if you want to instantiate an array of store model objects, you can use `from_values`:
```ruby
configs = Configuration.from_values([
  {model: "spaceship", color: "red", some_other_attribute: "foo"},
  {model: "car", color: "blue", some_other_attribute: "bar"}
])
```

These methods are shorthand for
```ruby
Configuration.to_type.cast_value(value)
```
and
```ruby
Configuration.to_array_type.cast_value(values)
```
respectively.
