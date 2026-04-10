# frozen_string_literal: true

#
# Benchmark: StoreModel _read_attribute performance impact
#
# Compares the cost of _read_attribute with parent assignment enabled,
# testing both the original .tap-based implementation and the optimized
# guard-clause implementation.
#
# Run from the store_model project root:
#
#   BUNDLE_GEMFILE=gemfiles/rails_8_1.gemfile bundle exec ruby benchmark/read_attribute_benchmark.rb
#

require "bundler/setup"
require "active_record"
require "store_model"
require "benchmark/ips"
require "stackprof"

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")

ActiveRecord::Schema.define do
  create_table :items, force: true do |t|
    t.string :name
    t.string :sku
    t.string :category
    t.string :status
    t.integer :quantity
    t.decimal :price, precision: 10, scale: 2
    t.boolean :active
    t.json :metadata, default: {}
  end
end

class ItemMetadata
  include StoreModel::Model
  attribute :color, :string
  attribute :size, :string
end

class Item < ActiveRecord::Base
  attribute :metadata, ItemMetadata.to_type
end

# -- Implementations to compare ----------------------------------------------

module OriginalImpl
  def _read_attribute_original(attr_name)
    _read_attribute(attr_name).tap do |attribute|
      _original_assign_parent(attribute)
    end
  end

  private

  def _original_assign_parent(attribute)
    _original_assign_singular(attribute)
    return if !attribute.is_a?(Array) && !attribute.is_a?(Hash)

    (attribute.try(:values) || attribute).each { |item| _original_assign_singular(item) }
  end

  def _original_assign_singular(item)
    item.parent = self if item.is_a?(StoreModel::Model)
  end
end

module OptimizedImpl
  def _read_attribute_optimized(attr_name)
    value = _read_attribute(attr_name)
    _optimized_assign_parent(value) if _store_model_attribute?(value)
    value
  end

  private

  def _optimized_assign_parent(attribute)
    _optimized_assign_singular(attribute)
    return if !attribute.is_a?(Array) && !attribute.is_a?(Hash)

    (attribute.try(:values) || attribute).each { |item| _optimized_assign_singular(item) }
  end

  def _optimized_assign_singular(item)
    item.parent = self if item.is_a?(StoreModel::Model)
  end

  def _store_model_attribute?(value)
    case value
    when StoreModel::Model then true
    when Array then value.first.is_a?(StoreModel::Model)
    when Hash then value.each_value.any? { |v| v.is_a?(StoreModel::Model) }
    else false
    end
  end
end

Item.include(OriginalImpl)
Item.include(OptimizedImpl)

# -- Setup -------------------------------------------------------------------

50.times do |i|
  Item.create!(
    name: "Widget #{i}", sku: "WDG-#{i.to_s.rjust(4, '0')}",
    category: "electronics", status: "active", quantity: i * 10,
    price: 19.99 + i, active: true,
    metadata: { color: "red", size: "large" }
  )
end

items = Item.all.to_a
plain_attrs = %w[name sku category status quantity price active id].freeze

puts "=" * 70
puts "StoreModel _read_attribute Benchmark"
puts "=" * 70
puts
puts "Ruby:          #{RUBY_VERSION}"
puts "ActiveRecord:  #{ActiveRecord::VERSION::STRING}"
puts "StoreModel:    #{StoreModel::VERSION}"
puts
puts "Comparing original .tap implementation vs optimized guard clause."
puts "50 records x 8 plain attributes per iteration."
puts

# -- Benchmark: original vs optimized on plain attributes --------------------

puts "-" * 70
puts "Plain attribute reads only (no StoreModel attributes)"
puts "This isolates the overhead added to non-StoreModel columns."
puts "-" * 70
puts

Benchmark.ips do |x|
  x.config(time: 5, warmup: 2)

  x.report("original (.tap + 3 is_a?)") do
    items.each do |item|
      plain_attrs.each { |attr| item._read_attribute_original(attr) }
    end
  end

  x.report("optimized (case guard)") do
    items.each do |item|
      plain_attrs.each { |attr| item._read_attribute_optimized(attr) }
    end
  end

  x.report("raw _read_attribute (no parent)") do
    items.each do |item|
      plain_attrs.each { |attr| item._read_attribute(attr) }
    end
  end

  x.compare!
end

# -- Benchmark: at scale (simulating transform batch) ------------------------

puts
puts "-" * 70
puts "At scale: 1000 iterations x 50 records x 8 attrs = 400,000 reads"
puts "-" * 70
puts

Benchmark.ips do |x|
  x.config(time: 5, warmup: 2)

  x.report("original x1000") do
    1000.times do
      items.each do |item|
        plain_attrs.each { |attr| item._read_attribute_original(attr) }
      end
    end
  end

  x.report("optimized x1000") do
    1000.times do
      items.each do |item|
        plain_attrs.each { |attr| item._read_attribute_optimized(attr) }
      end
    end
  end

  x.report("raw x1000 (no parent)") do
    1000.times do
      items.each do |item|
        plain_attrs.each { |attr| item._read_attribute(attr) }
      end
    end
  end

  x.compare!
end

# -- Object allocations ------------------------------------------------------

puts
puts "-" * 70
puts "Object allocations: 10,000 x 50 records x 8 plain attrs"
puts "-" * 70
puts

[
  ["original (.tap)", ->(item, attr) { item._read_attribute_original(attr) }],
  ["optimized (guard)", ->(item, attr) { item._read_attribute_optimized(attr) }],
  ["raw (no parent)", ->(item, attr) { item._read_attribute(attr) }]
].each do |label, reader|
  GC.start
  GC.disable
  before = GC.stat[:total_allocated_objects]

  10_000.times do
    items.each do |item|
      plain_attrs.each { |attr| reader.call(item, attr) }
    end
  end

  after = GC.stat[:total_allocated_objects]
  GC.enable

  total_reads = 10_000 * 50 * 8
  total_allocs = after - before
  per_read = total_allocs.to_f / total_reads

  puts "  %-25s %10s allocations  (%.4f per read)" % [
    label,
    total_allocs.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse,
    per_read
  ]
end

# -- StackProf ---------------------------------------------------------------

puts
puts "-" * 70
puts "StackProf: original implementation (50k x 50 x 8 reads)"
puts "-" * 70
puts

profile = StackProf.run(mode: :cpu, interval: 100) do
  50_000.times do
    items.each do |item|
      plain_attrs.each { |attr| item._read_attribute_original(attr) }
    end
  end
end
StackProf::Report.new(profile).print_text(STDOUT, 10)

puts
puts "-" * 70
puts "StackProf: optimized implementation (50k x 50 x 8 reads)"
puts "-" * 70
puts

profile = StackProf.run(mode: :cpu, interval: 100) do
  50_000.times do
    items.each do |item|
      plain_attrs.each { |attr| item._read_attribute_optimized(attr) }
    end
  end
end
StackProf::Report.new(profile).print_text(STDOUT, 10)

puts
puts "=" * 70
puts "Done"
puts "=" * 70
