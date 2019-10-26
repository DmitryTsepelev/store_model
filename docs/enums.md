## Enums

If you worked with [Rails Enums](https://api.rubyonrails.org/v5.2.3/classes/ActiveRecord/Enum.html) or [enumerize](https://github.com/brainspec/enumerize)–built-in enums should look familiar to you:

```ruby
class Configuration
  include StoreModel::Model

  enum :status, %i[active archived], default: :active
end

config = Configuration.new
config.status # => active

config.status = :archived
config.archived? # => true
config.active? # => false
config.status_value # => 0

config.status_values # => { :active => 0, :archived => 1 }
```

Under the hood, values are stored as integers, according to the index of the element in the array:

```ruby
Configuration.new.inspect # => #<Configuration status: 0>
```

You can specify values explicitly using the `:in` kwarg:

```ruby
class Review
  include StoreModel::Model

  enum :rating, in: { excellent: 100, okay: 50, bad: 25, awful: 10 }, default: :okay
end
```
