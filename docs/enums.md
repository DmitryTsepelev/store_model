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
Configuration.status_values # => { :active => 0, :archived => 1 }
Configuration.statuses # => { :active => 0, :archived => 1 }
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

There was a [bug](https://github.com/DmitryTsepelev/store_model/pull/151) related to `:in` causing values to be returned from `#as_json`:

```ruby
Review.new(rating: :okay).as_json # => "{\"type\": 1}"
```

Please use `StoreModel.config.serialize_enums_using_as_json = true` to turn this behavior on; this will be a new default in the next major release.

You can use the `:_prefix` or `:_suffix` options when you need to define multiple enums with same values. If the passed value is true, the methods are prefixed/suffixed with the name of the enum. It is also possible to supply a custom value:

```ruby
class Review
  include StoreModel::Model

  enum status: [:active, :archived], _suffix: true
  enum comments_status: [:active, :inactive], _prefix: :comments
end
```
With the above example, the predicate methods are now prefixed and/or suffixed accordingly:

```ruby
review = Review.new(status: :active, comment_status: :inactive)

review.active_status? # => true
review.archived_status? # => false

review.comments_active? # => false
review.comments_inactive? # => true
```

You can use the `:raise_on_invalid_values` options when you need to allow the enum to accept invalid values. However, in this case you'll need to handle validation of the values manually:

```ruby
class Review
  include StoreModel::Model

  enum status: [:active, :archived], raise_on_invalid_values: false

  validate_inclusion_of :status, in: ['active', 'archived']
end
```
