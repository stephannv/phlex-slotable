# frozen_string_literal: true

require "test_helper"

class Phlex::TestSingleSlotWithComponent < Minitest::Test
  class HeaderComponent < Phlex::HTML
    def initialize(size:)
      @size = size
    end

    def template(&content)
      h1(class: "text-#{@size}", &content)
    end
  end

  class Blog < Phlex::HTML
    include Phlex::Slotable

    slot :header, HeaderComponent

    def template
      if header_slot?
        div id: "header" do
          render header_slot if header_slot?
        end
      end

      main { "My posts" }
    end
  end

  def test_slot
    output = Blog.new.call do |c|
      c.with_header(size: "lg") { "Hello World!" }
    end

    assert_equal output, <<~HTML.join_lines
      <div id="header">
        <h1 class="text-lg">Hello World!</h1>
      </div>
      <main>
        My posts
      </main>
    HTML
  end

  def test_empty_slot
    output = Blog.new.call

    assert_equal output, "<main>My posts</main>"
  end
end
