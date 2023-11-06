$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "store_model/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "store_model"
  spec.version     = StoreModel::VERSION
  spec.authors     = ["DmitryTsepelev"]
  spec.email       = ["dmitry.a.tsepelev@gmail.com"]
  spec.homepage    = "https://github.com/DmitryTsepelev/store_model"
  spec.summary     = "Gem for working with JSON-backed attributes as ActiveRecord models"
  spec.description = "Gem for working with JSON-backed attributes as ActiveRecord models"
  spec.license     = "MIT"

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.required_ruby_version = ">= 2.6"

  spec.add_dependency "activerecord", ">= 5.2"

  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency "rubocop", "0.64.0"
end
