# frozen_string_literal: true

require "test_helper"

class Phlex::TestMultiSlotWithString < Minitest::Test
  class Blog < Phlex::HTML
    include Phlex::Slotable

    slot :post, "PostComponent", many: true

    def template
      if post_slots?
        main do
          post_slots.each do |slot|
            render slot
          end
        end
      end

      footer { post_slots.size }
    end

    private

    class PostComponent < Phlex::HTML
      def initialize(featured: false)
        @featured = featured
      end

      def template(&content)
        p(class: @featured ? "featured" : nil, &content)
      end
    end
  end

  def test_slots
    output = Blog.new.call do |c|
      c.with_post(featured: true) { "Post A" }
      c.with_post { "Post B" }
      c.with_post { "Post C" }
    end

    assert_equal output, <<~HTML.join_lines
      <main>
        <p class="featured">Post A</p>
        <p>Post B</p>
        <p>Post C</p>
      </main>

      <footer>
        3
      </footer>
    HTML
  end

  def test_empty_slots
    output = Blog.new.call

    assert_equal output, "<footer>0</footer>"
  end
end
