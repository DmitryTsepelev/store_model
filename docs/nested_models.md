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

### Work-around for loading database schema in Rails 7.2+

In Rails 7.2+, a [private attribute registration callback has been removed and at time of writing, no replacement is available](https://github.com/rails/rails/issues/52685).

Due to this, when using `store_model` with `accepts_nested_attributes_for` the database schema is required to be available in your database before booting your application. This will
occur for example when setting up a new environment or in CI.

The only known workaround for this currently is to load the database structure before you run your application, i.e. using psql. Please note that even `rails dbconsole` is affected
by this and hence you have to prepare your database without touching any of your rails application whatsoever. You must also use the `sql` structure dump, as loading `schema.rb` requires
to boot your application, which you won't be able to.

```bash
psql <auth flags and database name> < db/structure.sql
bundle exec rails console
```

See also [this issue](https://github.com/DmitryTsepelev/store_model/issues/187) for further discussion. Please also consider [contributing the necessary API to Rails](https://github.com/rails/rails/issues/52685#issuecomment-2310728692)
so there can be a less clunky solution to this.
