# frozen_string_literal: true

require "test_helper"

class Phlex::TestSingleLambdaSlot < Minitest::Test
  class SubtitleComponent < Phlex::HTML
    include Phlex::Slotable

    slot :icon
    slot :content

    def initialize(size:, bg_color:)
      @size = size
      @bg_color = bg_color
    end

    def template(&content)
      h3(class: "text-#{@size} bg-#{@bg_color}") do
        render icon_slot
        render content_slot
      end
    end
  end

  class Blog < Phlex::HTML
    include Phlex::Slotable

    slot :title, ->(size:, &content) { h1(class: "text-#{size}", &content) }
    slot :subtitle, ->(size:, &content) do
      render SubtitleComponent.new(size: size, bg_color: @subtitle_bg_color), &content
    end

    def initialize(subtitle_bg_color: nil)
      @subtitle_bg_color = subtitle_bg_color
    end

    def template
      div id: "header" do
        render title_slot if title_slot?
        render subtitle_slot if subtitle_slot?
      end

      main { "My posts" }
    end
  end

  def test_with_slot
    output = Blog.new(subtitle_bg_color: "gray").call do |c|
      c.with_title(size: :lg) { "Hello World!" }
      c.with_subtitle(size: :sm) do |s|
        s.with_icon { s.i(class: "home") }
        s.with_content { "Welcome to your posts" }
      end
    end

    assert_equal output, <<~HTML.join_lines
      <div id="header">
        <h1 class="text-lg">Hello World!</h1>
        <h3 class="text-sm bg-gray">
          <i class="home"></i>
          Welcome to your posts
        </h3>
      </div>
      <main>
        My posts
      </main>
    HTML
  end

  def test_with_no_slot
    output = Blog.new.call

    assert_equal output, <<~HTML.join_lines
      <div id="header"></div>
      <main>My posts</main>
    HTML
  end
end
