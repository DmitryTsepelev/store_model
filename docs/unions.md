
### Unions

For a common pattern where you want to select a model based on a discriminator field (like a `type` field), StoreModel provides a `union` method that wraps `OneOf`.

Note the database field must have a default value of `nil` or be a value hash, an empty hash will cause errors because it doesn't have a discriminator.

```ruby
class Dog
  include StoreModel::Model

  discriminator_attribute value: "dog"

  attribute :breed, :string
  attribute :good_boy, :boolean, default: true
end

class Cat
  include StoreModel::Model

  discriminator_attribute value: "cat"

  attribute :color, :string
  attribute :lives, :integer, default: 9
end

class Reptile
  include StoreModel::Model

  discriminator_attribute value: "reptile"

  attribute :species, :string
  attribute :cold_blooded, :boolean, default: true
end

# Create a union type
AnimalType = StoreModel.union([Dog, Cat, Reptile])

class Pet < ApplicationRecord
  attribute :animal, AnimalType.to_type
end

class Zoo < ApplicationRecord
  attribute :animals, AnimalType.to_array_type
end
```

Now you can work with different animal types seamlessly:

```ruby
# Create pets with different types
dog_owner = Pet.create!(animal: { type: 'dog', breed: 'Golden Retriever' })
cat_owner = Pet.create!(animal: { type: 'cat', color: 'orange', lives: 8 })

# The correct model class is automatically instantiated
dog_owner.animal # => #<Dog type: "dog", breed: "Golden Retriever", good_boy: true>
cat_owner.animal # => #<Cat type: "cat", color: "orange", lives: 8>

# Works with arrays too
zoo = Zoo.create!(
  animals: [
    { type: 'dog', breed: 'Husky' },
    { type: 'cat', color: 'black' },
    { type: 'reptile', species: 'Iguana' }
  ]
)

zoo.animals[0] # => #<Dog ...>
zoo.animals[1] # => #<Cat ...>
zoo.animals[2] # => #<Reptile ...>
```

#### Customizing the Union Type

You can customize which field is used as the discriminator:

```ruby
class PaymentMethod
  include StoreModel::Model

  discriminator_attribute :kind, value: 'credit_card'
  attribute :card_number, :string
end

class BankTransfer
  include StoreModel::Model

  discriminator_attribute :kind, value: 'bank_transfer'
  attribute :account_number, :string
end

# Use 'kind' as discriminator field
PaymentType = StoreModel.union([PaymentMethod, BankTransfer], discriminator: 'kind')

class Order < ApplicationRecord
  attribute :payment, PaymentType.to_type
end
```
