# frozen_string_literal: true

require "test_helper"

class Phlex::TestKitCompatibility < Minitest::Test
  class Headline < Phlex::HTML
    include Phlex::Slotable

    slot :icon
    slot :title

    def initialize(size:, bg_color:)
      @size = size
      @bg_color = bg_color
    end

    def view_template
      div class: "headline text-#{@size} bg-#{@bg_color}" do
        render icon_slot
        render title_slot
      end
    end
  end

  class Header < Phlex::HTML
    def view_template(&)
      h1(&)
    end
  end

  module Components
    extend Phlex::Kit

    Headline = Phlex::TestKitCompatibility::Headline
    Header = Phlex::TestKitCompatibility::Header
  end

  class Page < Phlex::HTML
    include Components

    def view_template
      Headline(size: :lg, bg_color: :red) do |h|
        h.with_icon { h.i(class: "star") }
        h.with_title do
          Header { "Hello World!" }
        end
      end
    end
  end

  def test_with_slots
    output = Page.new.call

    expected_html = <<~HTML.join_lines
      <div class="headline text-lg bg-red">
        <i class="star"></i>
        <h1>Hello World!</h1>
      </div>
    HTML

    assert_equal expected_html, output
  end
end
