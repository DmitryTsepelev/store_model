# Change log

## 3.0.0 (eventually)

- Make `StoreModel.config.serialize_enums_using_as_json = true` default

## master

- [PR #162](https://github.com/DmitryTsepelev/store_model/pull/162) Improve inspect readability ([@neilvcarvalho])
- [PR #161](https://github.com/DmitryTsepelev/store_model/pull/161) Addresses error deserializing malformed json string ([@agiveygives])

## 2.1.2 (2023-10-07)

- [PR #156](https://github.com/DmitryTsepelev/store_model/pull/156) Override of accepts_nested_attributes_for breaks app start when connection to db is not available ([@Supernich])

## 2.1.1 (2023-08-29)

- [PR #154](https://github.com/DmitryTsepelev/store_model/pull/154) Fix serialization on nested objects ([@mweitzel])

## 2.1.0 (2023-06-31)

- [PR #152](https://github.com/DmitryTsepelev/store_model/pull/152) Use accepts_nested_attributes_for with StoreModel::NestedAttributes   ([@morgangrubb])
- [PR #153](https://github.com/DmitryTsepelev/store_model/pull/153) Model#as_json serializes key-value enums using keys  ([@DmitryTsepelev])

## 2.0.1 (2023-05-09)

- [PR #148](https://github.com/DmitryTsepelev/store_model/pull/148) Fix defaults issue ([@RudskikhIvan])

## 2.0.0 (2023-05-06)

- [PR #146](https://github.com/DmitryTsepelev/store_model/pull/146) Serializing and deserializing values during save. Fixes lockbox but changes the way dates are stored (this might be a breaking change) ([@RudskikhIvan])

## 1.6.2 (2023-03-17)

- [PR #143](https://github.com/DmitryTsepelev/store_model/pull/143) Propogate validation context to store model ([@penguoir])

## 1.6.1 (2023-03-10)

- [PR #136](https://github.com/DmitryTsepelev/store_model/pull/136) Remove enum mapping instance method ([@jas14])

## 1.6.0 (2023-02-19)

- [PR #135](https://github.com/DmitryTsepelev/store_model/pull/135) Create class enum accessor ([@jas14])

## 1.5.1 (2023-01-21)

- [PR #139](https://github.com/DmitryTsepelev/store_model/pull/139) Add _destroy attr_accessor for association in nested attributes ([@mateusnava])

## 1.5.0 (2023-01-17)

- [PR #138](https://github.com/DmitryTsepelev/store_model/pull/138) Support option `allow_destroy` to accepts_nested_attributes_for ([@mateusnava])

## 1.3.0 (2022-10-21)

- [PR #128](https://github.com/DmitryTsepelev/store_model/pull/128) Fix fetch to handle `nil` values ([@danielvdao])

## 1.2.0 (2022-08-18)

- [PR #126](https://github.com/DmitryTsepelev/store_model/pull/126) Add access to attributes using brackets ([@raphox])

## 1.1.0 (2022-07-31)

- [PR #125](https://github.com/DmitryTsepelev/store_model/pull/125) Add config option serialize_unknown_attributes ([@Flixt])
- [PR #124](https://github.com/DmitryTsepelev/store_model/pull/124) Alias :== as :eql? ([@jdeff])

## 1.0.0 (2022-06-27)

- [PR #117](https://github.com/DmitryTsepelev/store_model/pull/117) Rails 7 support ([@DmitryTsepelev])
- [PR #112](https://github.com/DmitryTsepelev/store_model/pull/111) Fix validation for cast attributes ([@zk475811])

## 0.13.0 (2022-02-11)

- [PR #112](https://github.com/DmitryTsepelev/store_model/pull/112) Deprecate ruby 2.5 ([@DmitryTsepelev])
- [PR #108](https://github.com/DmitryTsepelev/store_model/pull/108) Fix saving unknown_attributes ([@nikokon])

## 0.12.0 (2021-10-03)

- [PR #102](https://github.com/DmitryTsepelev/store_model/pull/102) Add support for enum affixes ([@CodeMogul])

## 0.11.1 (2021-09-09)

- [PR #99](https://github.com/DmitryTsepelev/store_model/pull/99) Don't load railtie if there is no rails ([@mherold])

## 0.11.0 (2021-09-08)

- [PR #99](https://github.com/DmitryTsepelev/store_model/pull/99) Add `#hash` method ([@skryukov])

## 0.10.0 (2021-07-06)

- [PR #97](https://github.com/DmitryTsepelev/store_model/pull/97) Add predicate methods ([@f-mer])

## 0.9.0 (2021-04-21)

- [PR #93](https://github.com/DmitryTsepelev/store_model/pull/93) Handle aliases with has_attributes ([@Zooip])

## 0.8.2 (2021-02-10)

- [PR #88](https://github.com/DmitryTsepelev/store_model/pull/88) Avoid overriding parent validation messages when child is invalid ([@DmitryTsepelev])

## 0.8.1 (2021-01-25)

- [PR #79](https://github.com/DmitryTsepelev/store_model/pull/79) Fix infinite loop with nested model and :attributes key ([@timhwang21]())

## 0.8.0 (2020-06-12)

- Rename type classes to One/Many ([@DmitryTsepelev][])
- [PR #61](https://github.com/DmitryTsepelev/store_model/pull/61) Add polymorfic associations ([@HolyWalley]())

## 0.7.0 (2019-11-19)

- [PR #48](https://github.com/DmitryTsepelev/store_model/pull/46) Support merging errors for ArrayType ([@bostanio]())

## 0.6.2 (2019-11-17)

- [PR #46](https://github.com/DmitryTsepelev/store_model/pull/46) Validate all elements of ArrayType ([@bostanio]())

## 0.6.1 (2019-10-14)

- [PR #42](https://github.com/DmitryTsepelev/store_model/pull/42) Depend on activerecord only in the gemspec ([@keithpitt]())
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
[@keithpitt]: https://github.com/keithpitt
[@bostanio]: https://github.com/bostanio
[@timhwang21]: https://github.com/timhwang21
[@Zooip]: https://github.com/Zooip
[@f-mer]: https://github.com/f-mer
[@skryukov]: https://github.com/skryukov
[@mherold]: https://github.com/mherold
[@CodeMogul]: https://github.com/CodeMogul
[@nikokon]: https://github.com/nikokon
[@zk475811]: https://github.com/zk475811
[@jdeff]: https://github.com/jdeff
[@Flixt]: https://github.com/Flixt
[@raphox]: https://github.com/raphox
[@danielvdao]: https://github.com/danielvdao
[@mateusnava]: https://github.com/mateusnava
[@jas14]: https://github.com/jas14
[@penguoir]: https://github.com/penguoir
[@RudskikhIvan]: https://github.com/RudskikhIvan
[@morgangrubb]: https://github.com/morgangrubb
[@mweitzel]: https://github.com/mweitzel
[@Supernich]: https://github.com/Supernich
[@agiveygives]: https://github.com/agiveygives
[@neilvcarvalho]: https://github.com/neilvcarvalho
