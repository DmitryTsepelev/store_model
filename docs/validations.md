## Validations

`StoreModel` supports all validations shipped with `ActiveModel`. Start with defining validation for the store model:

```ruby
class Configuration
  include StoreModel::Model

  attribute :model, :string
  attribute :color, :string

  validates :color, presence: true
end
```

Then, configure your ActiveRecord model to validates this field as a store model:

```ruby
class Product < ApplicationRecord
  attribute :configuration, Configuration.to_type

  validates :configuration, store_model: true
end
```

When attribute is invalid, error messages are not copied to the parent model by default:

```ruby
product = Product.new
puts product.valid? # => false
puts product.errors.messages # => { configuration: ["is invalid"] }
puts product.configuration.errors.messages # => { color: ["can't be blank"] }
```

The errors object itself is still available in the error's details:

```ruby
puts product.errors.details[:configuration].first.messages # => { color: ["can't be blank"] }
```

You can change this behavior to have these errors on the root level (instead of `["is invalid"]`):

```ruby
class Product < ApplicationRecord
  attribute :configuration, Configuration.to_type

  validates :configuration, store_model: { merge_errors: true }
end
```

In this case errors look this way:

```ruby
product = Product.new
puts product.valid? # => false
puts product.errors.messages # => { color: ["can't be blank"] }
```

When using array type, merging errors happens in a following way:

```ruby
class Product < ApplicationRecord
  attribute :configurations, Configuration.to_array_type

  validates :configurations, store_model: { merge_array_errors: true }
end

product = Product.new
product.configurations << Configuration.new
puts product.valid? # => false
puts product.errors.messages # => { color: ["[0] Color can't be blank"] }
```

You can change the global behavior using `StoreModel.config`:

```ruby
StoreModel.config.merge_errors = true
```

> **Heads up!** Due to the [changes](https://github.com/rails/rails/pull/32313) of error internals in Rails >= 6.1 it's impossible to add an error with a key that does not have a corresponding attribute with the same name. Because of that, the behavior of `merge_error` strategy will be different–all errors are going to be placed under the attribute name (`{ configuration: ["Color can't be blank"] }` instead of `{ color: ["can't be blank"] }`).

You can also add your own custom strategies to handle errors. All you need to do is to provide a callable object to `StoreModel.config.merge_errors` or as value of `:merge_errors`. It should accept three arguments–_attribute_, _base_errors_ and _store_model_errors_:

```ruby
lambda_strategy = lambda do |attribute, base_errors, _store_model_errors|
  base_errors.add(attribute, "cthulhu fhtagn")
end

StoreModel.config.merge_errors = lambda_strategy

StoreModel.config.merge_array_errors = lambda_strategy
```

If the logic is complex enough–it worth defining a separate class with a `#call` method:

```ruby
class FhtagnErrorStrategy
  def call(attribute, base_errors, store_model_errors)
    base_errors.add(attribute, "cthulhu fhtagn")
  end
end

class FhtagnArrayErrorStrategy
  def call(attribute, base_errors, store_models)
    base_errors.add(attribute, "cthulhu fhtagn")
  end
end
```

You can provide its instance or snake-cased name when configuring global `merge_errors`:

```ruby
StoreModel.config.merge_errors = :fhtagn_error_strategy

class Product < ApplicationRecord
  attribute :configuration, Configuration.to_type

  validates :configuration, store_model: { merge_errors: :fhtagn_error_strategy }
end
```

or when calling `validates` method on a class level:

```ruby
StoreModel.config.merge_errors = FhtagnErrorStrategy.new

class Product < ApplicationRecord
  attribute :configuration, Configuration.to_type

  validates :configuration, store_model: { merge_errors: FhtagnErrorStrategy.new }
end
```

> **Heads up!** `:store_model` validator does not allow nils by default, if you want to change this behavior–configure the validation with `allow_nil: true`:

```ruby
class Product < ApplicationRecord
  attribute :configuration, Configuration.to_type

  validates :configuration, store_model: true, allow_nil: true
end
```
