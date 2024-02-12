# Phlex::Slotable

Phlex::Slotable enables slots feature to Phlex views. Inspired by ViewComponent.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG

## Usage

#### Basic

Include `Phlex::Slotable` to your Phlex view and use `slot` class method to define slots.

- `slot :slot_name` defines a single slot that will be rendered at most once per component
- `slot :slot_name, many: true` defines a slot that can be rendered multiple times per component

```ruby
class BlogComponent < Phlex::HTML
  include Phlex::Slotable

  slot :header
  slot :post, many: true

  # ...
end
```

To render a single slot, render `{slot_name}_slot`, eg. `render header_slot`.

To render a multi slot, iterate over `{slot_name}_slots` and render each element, eg. `post_slots.each { |s| render s }`

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

To set slot content, you need to use `with_{slot_name}` when rendering the view:

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

You can check if a slot has been passed to the component using `{slot_name}_slot?` when it is a single slot, or `{slot_name}_slots?` when it is a multi slot.

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

Slots can render other views, you just need to pass the view class name to `slot` method.

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
