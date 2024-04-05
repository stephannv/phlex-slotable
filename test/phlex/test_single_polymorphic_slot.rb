# frozen_string_literal: true

require "test_helper"

class Phlex::TestSinglePolymorphicSlot < Minitest::Test
  class ImageComponent < Phlex::HTML
    def initialize(src:)
      @src = src
    end

    def view_template
      img(class: "image", src: @src)
    end
  end

  class ProfileCard < Phlex::HTML
    include Phlex::Slotable

    slot :avatar, types: {
      image: ImageComponent,
      icon: "IconComponent",
      text: ->(size:, &content) do
        span(class: "text-#{size}", &content)
      end
    }

    def view_template
      if avatar_slot?
        div id: "avatar" do
          render avatar_slot
        end
      end

      span { "User name" }
    end

    private

    class IconComponent < Phlex::HTML
      def initialize(name:)
        @name = name
      end

      def view_template
        i(class: @name)
      end
    end
  end

  def test_component_slot
    output = ProfileCard.new.call do |c|
      c.with_image_avatar(src: "user.png")
    end

    assert_equal output, <<~HTML.join_lines
      <div id="avatar">
        <img class="image" src="user.png">
      </div>
      <span>
        User name
      </span>
    HTML
  end

  def test_component_string_slot
    output = ProfileCard.new.call do |c|
      c.with_icon_avatar(name: "home")
    end

    assert_equal output, <<~HTML.join_lines
      <div id="avatar">
        <i class="home"></i>
      </div>
      <span>
        User name
      </span>
    HTML
  end

  def test_lambda_slot
    output = ProfileCard.new.call do |c|
      c.with_text_avatar(size: "lg") { "SV" }
    end

    assert_equal output, <<~HTML.join_lines
      <div id="avatar">
        <span class="text-lg">SV</span>
      </div>
      <span>
        User name
      </span>
    HTML
  end

  def test_with_no_slot
    output = ProfileCard.new.call

    assert_equal output, "<span>User name</span>"
  end
end
