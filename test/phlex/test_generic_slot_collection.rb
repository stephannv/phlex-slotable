# frozen_string_literal: true

require "test_helper"

class Phlex::TestGenericSlotCollection < Minitest::Test
  class Blog < Phlex::HTML
    include Phlex::Slotable

    slot :post, collection: true

    def view_template
      if post_slots?
        main do
          post_slots.each do |slot|
            render slot
          end
        end
      end

      footer { post_slots.size }
    end
  end

  def test_with_slots
    output = Blog.new.call do |c|
      c.with_post do
        c.p { "Post A" }
      end
      c.with_post do
        c.p { "Post B" }
      end
      c.with_post do
        c.p { "Post C" }
      end
    end

    assert_equal output, <<~HTML.join_lines
      <main>
        <p>Post A</p>
        <p>Post B</p>
        <p>Post C</p>
      </main>

      <footer>
        3
      </footer>
    HTML
  end

  def test_with_no_slots
    output = Blog.new.call

    assert_equal output, "<footer>0</footer>"
  end
end
