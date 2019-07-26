## Array of stored models

Should you store an array of stored models, use `#to_array_type` method:

```ruby
class Product < ApplicationRecord
  attribute :configurations, Configuration.to_array_type
end
```

After that, your attribute will return an array of `Configuration` instances.

> **Heads up!** The attribute is not the same as the association, in this case–it's just a hash. `assign_attributes` (and similar) is going to _override_ the whole hash, not merge it with a previous value.
