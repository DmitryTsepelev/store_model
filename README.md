# StoreModel [![Gem Version](https://badge.fury.io/rb/store_model.svg)](https://rubygems.org/gems/store_model) [![Coverage Status](https://coveralls.io/repos/github/DmitryTsepelev/store_model/badge.svg?branch=master)](https://coveralls.io/github/DmitryTsepelev/store_model?branch=master) ![](https://ruby-gem-downloads-badge.herokuapp.com/store_model?type=total)

**StoreModel** gem allows you to wrap JSON-backed DB columns with ActiveModel-like classes.

- 💪 **Powered with [Attributes API](https://api.rubyonrails.org/classes/ActiveRecord/Attributes/ClassMethods.html)**. You can use a number of familiar types or write your own
- 🔧 **Works like ActiveModel**. Validations, enums and nested attributes work very similar to APIs provided by Rails
- 1️⃣ **Follows single responsibility principle**. Keep the logic around the data stored in a JSON column separated from the model
- 👷‍♂️ **Born in production**.

```ruby
class Configuration
  include StoreModel::Model

  attribute :model, :string
  enum :status, %i[active archived], default: :active

  validates :model, :status, presence: true
end

class Product < ApplicationRecord
  attribute :configuration, Configuration.to_type
end
```

## Why should I wrap my JSON columns?

Imagine that you have a model `Product` with a `jsonb` column called `configuration`. This is how you likely gonna work with this column:

```ruby
product = Product.find(params[:id])
if product.configuration["model"] == "spaceship"
  product.configuration["color"] = "red"
end
product.save
```

This approach works fine when you don't have a lot of keys with logic around them and just read the data. However, when you start working with that data more intensively–you may find the code a bit verbose and error-prone.

For instance, try to find a way to validate `:model` value to be required. Despite of the fact, that you'll have to write this validation by hand, it violates single-repsponsibility principle: why parent model (`Product`) should know about the logic related to a child (`Configuration`)?

> 📖 Read more about the motivation in the [Wrapping JSON-based ActiveRecord attributes with classes](https://evilmartians.com/chronicles/wrapping-json-based-active-record-attributes-with-classes) post

## Getting started

Start with creating a class for representing the hash as an object:

```ruby
class Configuration
  include StoreModel::Model

  attribute :model, :string
  attribute :color, :string
end
```

Attributes should be defined using [Rails Attributes API](https://api.rubyonrails.org/classes/ActiveRecord/Attributes/ClassMethods.html). There is a number of types available out of the box, and you can always extend the type system.

Register the field in the ActiveRecord model class:

```ruby
class Product < ApplicationRecord
  attribute :configuration, Configuration.to_type
end
```

When you're done, the initial snippet could be rewritten in the following way:

```ruby
product = Product.find(params[:id])
if product.configuration.model == "spaceship"
  product.configuration.color = "red"
end
product.save
```

_Usage note: Rails and assigning Arrays/Hashes to records_

- Assigned attributes must be a String, Hash, Array of Hashes, or StoreModel. For example, if the attributes are coming from a controller, be sure to convert any ActionController::Parameters as needed.
- Any changes made to a StoreModel instance requires the attribute be re-assigned; Rails doesn't track mutations of objects. For example: `self.my_stored_models = my_stored_models.map(&:as_json)`

## Documentation

1. [Installation](./docs/installation.md)
2. StoreModel::Model API:
  * [Validations](./docs/validations.md)
  * [Enums](./docs/enums.md)
  * [Nested models](./docs/nested_models.md)
  * [Unknown attributes](./docs/unknown_attributes.md)
3. [Array of stored models](./docs/array_of_stored_models.md)
4. [One of](./docs/one_of.md)
4. [Alternatives](./docs/alternatives.md)
5. [Defining custom types](./docs/defining_custom_types.md)

## Credits

Initially sponsored by [Evil Martians](http://evilmartians.com).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
