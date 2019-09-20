# Change log

## master

- [PR #38](https://github.com/DmitryTsepelev/store_model/pull/38) Fix inspect output for false values ([@zokioki]())

## 0.6.0 (2019-09-19)

- [PR #35](https://github.com/DmitryTsepelev/store_model/pull/35) Maintain `#parent` reference for StoreModels ([@blaze182][])

## 0.5.3 (2019-09-05)

- [PR #34](https://github.com/DmitryTsepelev/store_model/pull/34) Fix `#unknown_attributes` assignment for `ArrayType` ([@iarie][])

## 0.5.2 (2019-08-23)

- [PR #29](https://github.com/DmitryTsepelev/store_model/pull/29) Properly compare enum attributes in `Model#==` ([@DmitryTsepelev][])
- [PR #26](https://github.com/DmitryTsepelev/store_model/pull/26) Add YARD docs ([@DmitryTsepelev][])

## 0.5.1 (2019-08-06)

- [PR #25](https://github.com/DmitryTsepelev/store_model/pull/25) Add `#has_attribute?` method to keep `simple_form` compatibility ([@DmitryTsepelev][])

## 0.5.0 (2019-08-05)

- [PR #22](https://github.com/DmitryTsepelev/store_model/pull/22) Store unknown attributes in `#unknown_attributes` ([@DmitryTsepelev][])

## 0.4.1 (2019-07-31)

- [PR #21](https://github.com/DmitryTsepelev/store_model/pull/21) Properly validate and handle nested models ([@DmitryTsepelev][])

## 0.4.0 (2019-07-26)

- [PR #17](https://github.com/DmitryTsepelev/store_model/pull/17) Update nested store models with `#accepts_nested_attributes_for` ([@DmitryTsepelev][])
- [PR #16](https://github.com/DmitryTsepelev/store_model/pull/16) Add support for enums ([@DmitryTsepelev][])

## 0.3.2 (2019-06-13)

- [PR #12](https://github.com/DmitryTsepelev/store_model/pull/12) Fixes [Issue #11](https://github.com/DmitryTsepelev/store_model/pull/11) ([@DmitryTsepelev][])

## 0.3.1 (2019-06-13)

- [PR #10](https://github.com/DmitryTsepelev/store_model/pull/10) Fixes [Issue #9](https://github.com/DmitryTsepelev/store_model/pull/9) ([@DmitryTsepelev][])

## 0.3.0 (2019-05-06)

- [PR #6](https://github.com/DmitryTsepelev/store_model/pull/6) Rewrite MergeErrorStrategy to work with Rails 6.1 ([@DmitryTsepelev][])

## 0.2.0 (2019-04-30)

- [PR #5](https://github.com/DmitryTsepelev/store_model/pull/5) Raise error when `#cast` cannot handle the passed instance ([@DmitryTsepelev][])
- [PR #5](https://github.com/DmitryTsepelev/store_model/pull/5) Add array type generation via Model#to_array_type ([@DmitryTsepelev][])

## 0.1.2 (2019-03-14)

- `:store_model` validation should not allow nil by default

## 0.1.1 (2019-02-21)

- Fix crash in presence validator ([@DmitryTsepelev][])

## 0.1.0 (2019-02-20)

- Initial version ([@DmitryTsepelev][])

[@DmitryTsepelev]: https://github.com/DmitryTsepelev
[@iarie]: https://github.com/iarie
[@blaze182]: https://github.com/blaze182
[@zokioki]: https://github.com/zokioki
