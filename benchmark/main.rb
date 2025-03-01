RubyVM::YJIT.enable

require "benchmark"
require "benchmark/ips"
require_relative "../lib/phlex/slotable"

require "phlex/version"

puts "Phlex #{Phlex::VERSION}"
puts "Phlex::Slotable #{Phlex::Slotable::VERSION}"

class DeferredList < Phlex::HTML
  def before_template(&)
    vanish(&)
    super
  end

  def initialize
    @items = []
  end

  def view_template
    if @header
      h1(class: "header", &@header)
    end

    ul do
      @items.each do |item|
        li { render(item) }
      end
    end
  end

  def header(&block)
    @header = block
  end

  def with_item(&content)
    @items << content
  end
end

class SlotableList < Phlex::HTML
  include Phlex::Slotable

  slot :header
  slot :item, collection: true

  def view_template
    if header_slot
      h1(class: "header", &header_slot)
    end

    ul do
      item_slots.each do |slot|
        li { render(slot) }
      end
    end
  end
end

class DeferredListExample < Phlex::HTML
  def view_template
    render DeferredList.new do |list|
      list.header do
        "Header"
      end

      list.with_item do
        "One"
      end

      list.with_item do
        "two"
      end
    end
  end
end

class SlotableListExample < Phlex::HTML
  def view_template
    render SlotableList.new do |list|
      list.with_header do
        "Header"
      end

      list.with_item do
        "One"
      end

      list.with_item do
        "two"
      end
    end
  end
end

puts RUBY_DESCRIPTION

deferred_list = DeferredListExample.new.call
slotable_list = SlotableListExample.new.call

raise unless deferred_list == slotable_list

Benchmark.bmbm do |x|
  x.report("Deferred") { 1_000_000.times { DeferredListExample.new.call } }
  x.report("Slotable") { 1_000_000.times { SlotableListExample.new.call } }
end

puts

Benchmark.ips do |x|
  x.report("Deferred") { DeferredListExample.new.call }
  x.report("Slotable") { SlotableListExample.new.call }
  x.compare!
end
