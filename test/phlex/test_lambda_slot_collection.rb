# frozen_string_literal: true

require "test_helper"

class Phlex::TestLambdaSlotCollection < Minitest::Test
  class HeadlineComponent < Phlex::HTML
    include Phlex::Slotable

    slot :icon
    slot :title

    def initialize(size:, bg_color:)
      @size = size
      @bg_color = bg_color
    end

    def template
      div class: "headline text-#{@size} bg-#{@bg_color}" do
        render icon_slot
        render title_slot
      end
    end
  end

  class Blog < Phlex::HTML
    include Phlex::Slotable

    slot :post, ->(featured: false, &content) { p(class: featured ? "featured" : nil, &content) }, collection: true
    slot :headline, ->(size:, &content) do
      render HeadlineComponent.new(size: size, bg_color: @headline_bg_color), &content
    end, collection: true

    def initialize(headline_bg_color: nil)
      @headline_bg_color = headline_bg_color
    end

    def template
      if post_slots?
        main do
          headline_slots.each do |slot|
            render slot
          end
          post_slots.each do |slot|
            render slot
          end
        end
      end

      footer { post_slots.size }
    end
  end

  def test_with_slots
    output = Blog.new(headline_bg_color: "blue").call do |c|
      c.with_post(featured: true) { "Post A" }
      c.with_post { "Post B" }
      c.with_post { "Post C" }

      c.with_headline(size: "lg") do |h|
        h.with_title { "Headline A" }
        h.with_icon { h.i(class: "star") }
      end
      c.with_headline(size: "md") do |h|
        h.with_title { "Headline B" }
        h.with_icon { h.i(class: "heart") }
      end
    end

    expected_html = <<~HTML.join_lines
      <main>
        <div class="headline text-lg bg-blue">
          <i class="star"></i>
          Headline A
        </div>
        <div class="headline text-md bg-blue">
          <i class="heart"></i>
          Headline B
        </div>

        <p class="featured">Post A</p>
        <p>Post B</p>
        <p>Post C</p>
      </main>

      <footer>
        3
      </footer>
    HTML

    assert_equal expected_html, output
  end

  def test_with_no_slots
    output = Blog.new.call

    assert_equal output, "<footer>0</footer>"
  end
end
