## One of

In case when you want to use different models depending on some condition you can use `StoreModel.one_of` method:

```ruby
OneOfConfigurations = StoreModel.one_of do |json|
  json[:v] == 2 ? ConfigurationV2 : Configuration
end

class Product < ApplicationRecord
  attribute :configuration, OneOfConfigurations.to_type
end

class ProductList < ApplicationRecord
  attribute :configurations, OneOfConfigurations.to_aray_type
end
```
