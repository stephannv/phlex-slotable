# Phlex::Slotable

Phlex::Slotable enables slots feature to Phlex views. Inspired by ViewComponent.

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

## Roadmap

[] Accepts Strings as view class name
[] Allow lambda slots
[] Allow polymorphic slots

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/stephannv/phlex-slot. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/stephannv/phlex-slotable/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Phlex::Slot project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/stephannv/phlex-slotable/blob/master/CODE_OF_CONDUCT.md).
