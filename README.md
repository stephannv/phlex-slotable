> [!WARNING]
> Please note that Phlex::Slotable is currently under development and may undergo changes to its API before reaching the stable release (1.0.0). As a result, there may be breaking changes that affect its usage.

# Phlex::Slotable
[![CI](https://github.com/stephannv/phlex-slotable/actions/workflows/main.yml/badge.svg)](https://github.com/stephannv/phlex-slotable/actions/workflows/main.yml)

Phlex::Slotable enables slots feature to [Phlex](https://www.phlex.fun/) views. Inspired by ViewComponent.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add phlex-slotable

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install phlex-slotable

## Usage

#### Basic

To incorportate slots into your Phlex views, include `Phlex::Slotable` and utilize `slot` class method to define them.

- `slot :slot_name` declaration establishes a single slot intended for rendering once within a view
- `slot :slot_name, many: true` denotes a slot capable of being rendered multiple times within a view

```ruby
class BlogComponent < Phlex::HTML
  include Phlex::Slotable

  slot :header
  slot :post, many: true

  # ...
end
```

To render a single slot, utilize the  `{slot_name}_slot` method. For example, you can render the `header_slot` using `render header_slot`.

For multi-slot rendering, iterate over the `{slot_name}_slots` collection and and render each slot individually, eg. `post_slots.each { |s| render s }`.

```ruby
class BlogComponent < Phlex::HTML
  include Phlex::Slotable

  slot :header
  slot :post, many: true

  def template
    div id: "header" do
      render header_slot
    end

    div id: "main" do
      post_slots.each do |slot|
        p { render slot }
      end

      span { "Count: #{post_slots.count}" }
    end
  end
end
```

When setting slot content, ensure to utilize the  `with_{slot_name}` method while rendering the view:

```ruby
class MyPage < Phlex::HTML
  def template
    render BlogComponent.new do |blog|
      blog.with_header do
        h1 { "Hello World!" }
      end

      blog.with_post { "Post A" }
      blog.with_post { "Post B" }
      blog.with_post { "Post C" }
    end
  end
end

MyPage.new.call
```

This will output:

```html
<div id="header">
  <h1>Hello World</h1>
</div>
<div id="main">
  <p>Post A</p>
  <p>Post B</p>
  <p>Post C</p>

  <span>Count: 3</span>
</div>
```

#### Predicate methods

You can verify whether a slot has been provided to the view using `{slot_name}_slot?` for single slots or `{slot_name}_slots?` when for multi-slots.

```ruby
class BlogComponent < Phlex::HTML
  include Phlex::Slotable

  slot :header
  slot :post, many: true

  def template
    if header_slot?
      div id: "header" do
        render header_slot
      end
    end

    div id: "main" do
      if post_slots?
        post_slots.each do |slot|
          p { render slot }
        end

        span { "Count: #{post_slots.count}" }
      else
        span { "No post yet" }
      end
    end
  end
end
```

#### View slot

Slots have the capability to render other views, Simply pass the view class name to the `slot` method.

```ruby
class HeaderComponent < Phlex::HTML
  def initialize(size:)
    @size = size
  end

  def template(&content)
    h1(class: "text-#{@size}", &content)
  end
end

class PostComponent < Phlex::HTML
  def initialize(featured:)
    @featured = featured
  end

  def template(&content)
    p(class: @featured ? "featured" : nil, &content)
  end
end

class BlogComponent < Phlex::HTML
  include Phlex::Slotable

  slot :header, HeaderComponent
  slot :post, PostComponent, many: true

  def template
    if header_slot?
      div id: "header" do
        render header_slot
      end
    end

    div id: "main" do
      if post_slots?
        post_slots.each { render slot }

        span { "Count: #{post_slots.count}" }
      else
        span { "No post yet" }
      end
    end
  end
end

class MyPage < Phlex::HTML
  def template
    render BlogComponent.new do |blog|
      blog.with_header(size: :lg) { "Hello World!" }

      blog.with_post(featured: true) { "Post A" }
      blog.with_post { "Post B" }
      blog.with_post { "Post C" }
    end
  end
end

MyPage.new.call
```

The output:

```html
<div id="header">
  <h1 class="text-lg">Hello World</h1>
</div>
<div id="main">
  <p class="featured">Post A</p>
  <p>Post B</p>
  <p>Post C</p>

  <span>Count: 3</span>
</div>
```

You can pass the class name as a string for cases where the class isn't evaluated yet, such as with inner classes. For example:
```ruby
class BlogComponent < Phlex::HTML
  include Phlex::Slotable

  # This will not work
  slot :header, HeaderComponent #  uninitialized constant BlogComponent::HeaderComponent
  # You should do this
  slot :header, "HeaderComponent"

  private

  class HeaderComponent < Phlex::HTML
    # ...
  end
end
```

#### Lambda slots
Lambda slots are valuable when you prefer not to create another component for straightforward structures or when you need to render another view with specific parameters
```ruby

class BlogComponent < Phlex::HTML
  include Phlex::Slotable

  slot :header, ->(size:, &content) { render HeaderComponent.new(size: size, color: "blue"), &content }
  slot :post, ->(featured:, &content) { span(class: featured ? "featured" : nil, &content) }, many: true
end

class MyPage < Phlex::HTML
  def template
    render BlogComponent.new do |blog|
      blog.with_header(size: :lg) { "Hello World!" }

      blog.with_post(featured: true) { "Post A" }
      blog.with_post { "Post B" }
      blog.with_post { "Post C" }
    end
  end
end
```

You can access the internal view state within lambda slots. For example:
```ruby
class BlogComponent < Phlex::HTML
  include Phlex::Slotable

  slot :header, ->(size:, &content) { render HeaderComponent.new(size: size, color: @header_color), &content }

  def initialize(header_color:)
    @header_color = header_color
  end
end

class MyPage < Phlex::HTML
  def template
    render BlogComponent.new(header_color: "red") do |blog|
      blog.with_header(size: :lg) { "Hello World!" }
    end
  end
end
```

#### Polymorphic slots
Polymorphic slots can render one of several possible slots, allowing for flexibility in component content. This feature is particularly useful when you require a fixed structure but need to accommodate different types of content. To implement this, simply pass a types hash containing the types along with corresponding slot definitions.

```ruby
class CardComponent < Phlex::HTML
  include Phlex::Slotable

  slot :avatar, types: { icon: IconComponent, image: ImageComponent }

  def template
    if avatar_slot?
      figure id: "avatar" do
        render avatar_slot
      end
    end
  end
end
```

This allows you to set the icon slot using `with_icon_avatar` or the image slot using `with_image_avatar`:
```ruby
class UserCardComponent < Phlex::HTML
  def initialize(user:)
    @user = user
  end

  def template
    render CardComponent.new do |card|
      if @user.image?
        card.with_image_avatar(src: @user.image)
      else
        card.with_icon_avatar(name: :user)
      end
    end
  end
end
```

Please note that you can still utilize the other slot definition APIs:
```ruby
class CardComponent < Phlex::HTML
  include Phlex::Slotable

  slot :avatar, types: {
    icon: IconComponent,
    image: "ImageComponent",
    text: ->(size:, &content) { span(class: "text-#{size}", &content) }
  }, many: true

  def template
    if avatar_slots?
      avatar_slots.each do |slot|
        render slot
      end
    end

    span { "Count: #{avatar_slots.size}" }
  end

  ...
end

class UsersCardComponent < Phlex::HTML
  def template
    render CardComponent.new do |card|
      card.with_image_avatar(src: @user.image)
      card.with_icon_avatar(name: :user)
      card.with_text_avatar(size: :lg) { "SV" }
    end
  end
end
```


## Roadmap
- ✅ ~~Accept Strings as view class name~~
- ✅ ~~Allow lambda slots~~
- ✅ ~~Allow polymorphic slots~~

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/stephannv/phlex-slot. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/stephannv/phlex-slotable/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Phlex::Slot project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/stephannv/phlex-slotable/blob/master/CODE_OF_CONDUCT.md).
