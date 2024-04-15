## Disabling Parent Tracking and Active Record extensions

`store_model` tracks the parent object of models using `StoreModel::Model`.
This allows your store model, to know where it got assigned.

```ruby
class Configuration
  include StoreModel::Model

  attribute :model, :string
end

class Product < ApplicationRecord
  attribute :configuration, Configuration.to_type
end

product = Product.first
product.configuration.parent # returns the `product` object
```

This behavior is achieved via Active Record extensions and it can be disabled globally:

```ruby
# config/initializers/store_model.rb
StoreModel.config.enable_parent_assignment = false
```
