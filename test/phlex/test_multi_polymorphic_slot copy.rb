# frozen_string_literal: true

require "test_helper"

class Phlex::TestMultiPolymorphicSlot < Minitest::Test
  class ImageComponent < Phlex::HTML
    def initialize(src:)
      @src = src
    end

    def template
      img(class: "image", src: @src)
    end
  end

  class UsersList < Phlex::HTML
    include Phlex::Slotable

    slot :avatar, types: {
      image: ImageComponent,
      icon: "IconComponent",
      text: ->(size:, &content) do
        span(class: "text-#{size}", &content)
      end
    }, many: true

    def template
      if avatar_slots?
        div id: "users" do
          avatar_slots.each { |slot| render slot }
        end
      end

      span { "Users: #{avatar_slots.size}" }
    end

    private

    class IconComponent < Phlex::HTML
      def initialize(name:)
        @name = name
      end

      def template
        i(class: @name)
      end
    end
  end

  def test_slots
    output = UsersList.new.call do |c|
      c.with_image_avatar(src: "user.png")
      c.with_icon_avatar(name: "home")
      c.with_text_avatar(size: "lg") { "SV" }

      c.with_image_avatar(src: "user2.png")
      c.with_icon_avatar(name: "heart")
      c.with_text_avatar(size: "sm") { "TV" }
    end

    assert_equal output, <<~HTML.join_lines
      <div id="users">
        <img class="image" src="user.png">
        <i class="home"></i>
        <span class="text-lg">SV</span>
        <img class="image" src="user2.png">
        <i class="heart"></i>
        <span class="text-sm">TV</span>
      </div>
      <span>
        Users: 6
      </span>
    HTML
  end

  def test_empty_slots
    output = UsersList.new.call

    assert_equal output, "<span>Users: 0</span>"
  end
end
