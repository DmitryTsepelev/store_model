[![Gem Version](https://badge.fury.io/rb/store_model.svg)](https://rubygems.org/gems/store_model)
[![Build Status](https://travis-ci.org/DmitryTsepelev/store_model.svg?branch=master)](https://travis-ci.org/DmitryTsepelev/store_model)
[![Coverage Status](https://coveralls.io/repos/github/DmitryTsepelev/store_model/badge.svg?branch=master)](https://coveralls.io/github/DmitryTsepelev/store_model?branch=master)

# StoreModel

<a href="https://evilmartians.com/?utm_source=store_model">
<img src="https://evilmartians.com/badges/sponsored-by-evil-martians.svg" alt="Sponsored by Evil Martians" width="236" height="54"></a>

StoreModel allows to work with JSON-backed database columns in a similar way we work with ActiveRecord models. Supports Ruby >= 2.3 and Rails >= 5.2.

For instance, imagine that you have a model `Product` with a `jsonb` column called `configuration`. Your usual workflow probably looks like:

```ruby
product = Product.find(params[:id])
if product.configuration["model"] == "spaceship"
  product.configuration["color"] = "red"
end
product.save
```

This approach works fine when you don't have a lot of keys with logic around them and just read the data. However, when you start working with that data more intensively (for instance, adding some validations around it) - you may find the code a bit verbose and error-prone. With this gem, the snipped above could be rewritten this way:

```ruby
product = Product.find(params[:id])
if product.configuration.model == "spaceship"
  product.configuration.color = "red"
end
product.save
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'store_model'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install store_model
```

## How to register stored model

Start with creating a class for representing the hash as an object:

```ruby
class Configuration
  include StoreModel::Model

  attribute :model, :string
  attribute :color, :string
end
```

Attributes should be defined using [Rails Attributes API](https://api.rubyonrails.org/classes/ActiveRecord/Attributes/ClassMethods.html). There is a number of types available out of the box, and you can always extend the type system with your own ones.

Register the field in the ActiveRecord model class:

```ruby
class Product < ApplicationRecord
  attribute :configuration, Configuration.to_type
end
```

## Handling arrays

Should you store an array of models, you can use `#to_array_type` method:

```ruby
class Product < ApplicationRecord
  attribute :configurations, Configuration.to_array_type
end
```

After that, your attribute will return array of `Configuration` instances.

## Validations

`StoreModel` supports all the validations shipped with `ActiveModel`. Start with defining validation for the store model:

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

When attribute is invalid, errors are not copied to the parent model by default:

```ruby
product = Product.new
puts product.valid? # => false
puts product.errors.messages # => { configuration: ["is invalid"] }
puts product.configuration.errors.messages # => { color: ["can't be blank"] }
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

You can change the global behavior using `StoreModel.config`:

```ruby
StoreModel.config.merge_errors = true
```

You can also add your own custom strategies to handle errors. All you need to do is to provide a callable object to `StoreModel.config.merge_errors` or as value of `:merge_errors`. It should accept three arguments - _attribute_, _base_errors_ and _store_model_errors_:

```ruby
StoreModel.config.merge_errors = lambda do |attribute, base_errors, _store_model_errors| do
  base_errors.add(attribute, "cthulhu fhtagn")
end
```

If the logic is complex enough - it worth defining a separate class with a `#call` method:

```ruby
class FhtagnErrorStrategy
  def call(attribute, base_errors, _store_model_errors)
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

**Note**: `:store_model` validator does not allow nils by default, if you want to change this behavior - configure the validation with `allow_nil: true`:

```ruby
class Product < ApplicationRecord
  attribute :configuration, Configuration.to_type

  validates :configuration, store_model: true, allow_nil: true
end
```

## Alternatives

- [store_attribute](https://github.com/palkan/store_attribute) - work with JSON fields as an attributes, defined on the ActiveRecord model (not in the separate class)
- [jsonb_accessor](https://github.com/devmynd/jsonb_accessor) - same thing, but with built-in queries
- [attr_json](https://github.com/jrochkind/attr_json) - works like previous one, but using `ActiveModel::Type`

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
