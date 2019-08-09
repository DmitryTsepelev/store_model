Firstly, you should define your custom type (for instance, they can be kept inside the `app/types` directory):

```ruby
class Iso8601Type < ActiveRecord::Type::Value
  def type
    :datetime_iso8601
  end

  def cast(value)
    return value if value.is_a?(Time)
    return value.to_time if value.is_a?(Date)
    return nil if value.blank?

    Time.iso8601(value)
  rescue ArgumentError, TypeError
    nil
  end
end

```

Secondly, register the type (initializer is a good place to do that):

```ruby
ActiveModel::Type.register(:datetime_iso8601, Iso8601Type)
```

Finally, use the type in your model:

```ruby
class Configuration
  include StoreModel::Model

  attribute :archived_at, :datetime_iso8601
end
```

Alternatively, you can skip registering the type globally in a following way:

```ruby
class Configuration
  include StoreModel::Model

  attribute :archived_at, Iso8601Type.new
end
```
