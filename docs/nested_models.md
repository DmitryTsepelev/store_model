## Nested Models

In some cases, you might need to have a stored model as an attribute of another one:

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

To make it work with nested Rails forms (i.e., define a method called `#{attribute_name}_attributes=`) you should add `accepts_nested_attributes_for :supplier`, which works in the same way as the [built-in Rails method](https://api.rubyonrails.org/classes/ActiveRecord/NestedAttributes/ClassMethods.html), to the parent model.

### Validation

If you want to validate the nested model, you must use the `StoreModelValidator` validator:

```ruby
attribute :supplier, Supplier.to_type # existing attribute definition
validates :supplier, store_model: true
```
