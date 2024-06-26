# frozen_string_literal: true

require "test_helper"

class Phlex::TestSingleGenericSlot < Minitest::Test
  class Blog < Phlex::HTML
    include Phlex::Slotable

    slot :header

    def view_template
      if header_slot?
        div id: "header" do
          render header_slot
        end
      end

      main { "My posts" }
    end
  end

  def test_with_slot
    output = Blog.new.call do |c|
      c.with_header do
        c.h1 { "Hello World!" }
      end
    end

    assert_equal output, <<~HTML.join_lines
      <div id="header">
        <h1>Hello World!</h1>
      </div>
      <main>
        My posts
      </main>
    HTML
  end

  def test_with_no_slot
    output = Blog.new.call

    assert_equal output, "<main>My posts</main>"
  end
end
