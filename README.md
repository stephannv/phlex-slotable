> [!WARNING]
> Please note that Phlex::Slotable is currently under development and may undergo changes to its API before reaching the stable release (1.0.0). As a result, there may be breaking changes that affect its usage.

# Phlex::Slotable
[![CI](https://github.com/stephannv/phlex-slotable/actions/workflows/main.yml/badge.svg)](https://github.com/stephannv/phlex-slotable/actions/workflows/main.yml)

Phlex::Slotable enables slots feature to [Phlex](https://www.phlex.fun/) views. Inspired by ViewComponent.

- [What is a slot?](#what-is-a-slot)
- [Getting started](#getting-started)
- [Generic slot](#generic-slot)
- [Slot collection](#slot-collection)
- [Component slot](#component-slot)
- [Lambda slot](#lambda-slot)
- [Polymorphic slot](#polymorphic-slot)
- [Performance](#performance)
- [Development](#development)
- [Contributing](#contributing)

## What is a slot?

In the context of view components, a **slot** serves as a  placeholder inside a component that can be filled with custom content.  Essentially, slots enable a component to accept external content and  autonomously organize it within its structure. This abstraction allows developers to work with components without needing to understand their internals, thereby ensuring visual consistency and improving developer experience.

## Getting started

Install the gem and add to the application's Gemfile by executing:

    $ bundle add phlex-slotable

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install phlex-slotable

> [!TIP]
> If you prefer not to add another dependency to your project, you can simply copy the [Phlex::Slotable](https://github.com/stephannv/phlex-slotable/blob/main/lib/phlex/slotable.rb) file into your project.

Afterward, simply include `Phlex::Slotable` into your Phlex component and utilize `slot` macro to define the component's slots. For example:

```ruby
class MyComponent < Phlex::HTML
  include Phlex::Slotable

  slot :my_slot
end
```

Below, you will find a more detailed explanation of how to use the `slot` API.

## Generic slot

Any content can be passed to components through generic slots, also known as passthrough slots. To define a generic slot, use `slot :{slot_name}`. For example:

```ruby
class PageComponent < Phlex::HTML
  include Phlex::Slotable

  slot :title
end
```

To render a slot, render the `{slot_name}_slot`:

```ruby
class PageComponent < Phlex::HTML
  include Phlex::Slotable

  slot :title

  def template
    header { render title_slot }
  end
end
```

To pass content to the component's slot, you should use `with_{slot_name}`:

```ruby
PageComponent.new.call do |page|
  page.with_title do
    h1 { "Hello World!" }
  end
end
```

Returning:

```html
<header>
  <h1>Hello World!</h1>
</header>
```

You can test if a slot has been passed to the component with `{slot_name}_slot?` method. For example:

```ruby
class PageComponent < Phlex::HTML
  include Phlex::Slotable

  slot :title

  def template
    if header_slot?
      header { render title_slot }
    else
      plain "No title"
    end
  end
end
```

## Slot collection

A slot collection denotes a slot capable of being rendered multiple times within a component. It has some minor differences compared to a single slot seen previously. First, you should pass `collection: true` when defining the slot:

```ruby
class ListComponent < Phlex::HTML
  include Phlex::Slotable

  slot :item, collection: true
end
```

To render a collection of slots, iterate over the `{slot_name}_slots` collection and render each slot individually:

```ruby
class ListComponent < Phlex::HTML
  include Phlex::Slotable

  slot :item, collection: true

  def template
    if item_slots?
      ul do
        item_slots.each do |item_slot|
          li { render item_slot }
        end
      end
    end

    span { "Total: #{item_slots.size}" }
  end
end
```

To set slot content, use the `with_{slot_name}` method when rendering the component. Unlike the single slot,  `with_{slot_name}` can be called multiple times:

```ruby
ListComponent.new.call do |list|
  list.with_item { "Item A" }
  list.with_item { "Item B" }
  list.with_item { "Item C" }
end
```

Returning:

```html
<ul>
  <li>Item A</li>
  <li>Item B</li>
  <li>Item C</li>
</ul>

<span>Total: 3</span>
```

## Component slot

Slots have the capability to render other components. When defining a slot, provide the name of a component class as the second argument to define a component slot

```ruby
class ListHeaderComponent < Phlex::HTML
  # omitted code
end

class ListItemComponent < Phlex::HTML
  # omitted code
end

class ListComponent < Phlex::HTML
  include Phlex::Slotable

  slot :header, ListHeaderComponent
  slot :item, ListItemComponent, collection: true

  def template
    div id: "header" do
      render header_slot if header_slot?
    end

    ul do
      item_slots.each { |slot| render slot }
    end
  end
end

ListComponent.new.call do |list|
  list.with_header(size: "lg") { "Hello World!" }

  list.with_item(active: true) { "Item A" }
  list.with_item { "Item B" }
  list.with_item { "Item C" }
end
```

Returning:

```html
<div id="header">
  <h1 class="text-lg">Hello World!</h1>

  <ul>
    <li class="active">Item A</li>
    <li>Item B</li>
    <li>Item C</li>
  </ul>
</div>
```

> [!TIP]
> You can also pass the component class as a string if your component class hasn't been defined yet. For example:
>
> ```ruby
> slot :header, "HeaderComponent"
> slot :item, "ItemComponent", collection: true
>```


## Lambda slot

Lambda slots are valuable when you prefer not to create another component for straightforward structures or when you need to render another component with specific parameters.

```ruby
class ListComponent < Phlex::HTML
  include Phlex::Slotable

  slot :header, ->(size:, &content) do
    render HeaderComponent.new(size: size, color: "primary")
  end
  slot :item, ->(href:, &content) { li { a(href: href, &content) } }, collection: true

  def template
    div id: "header" do
      render header_slot if header_slot?
    end

    ul do
      item_slots.each { |slot| render slot }
    end
  end
end

ListComponent.new.call do |list|
  list.with_header(size: "lg") { "Hello World!" }

  list.with_item(href: "/a") { "Item A" }
  list.with_item(href: "/b") { "Item B" }
  list.with_item(href: "/c") { "Item C" }
end
```

Returning:

```html
<div id="header">
  <h1 class="text-lg text-primary">Hello World!</h1>

  <ul>
    <li><a href="/a">Item A</a></li>
    <li><a href="/b">Item B</a></li>
    <li><a href="/c">Item C</a></li>
  </ul>
</div>
```

> [!TIP]
> You can access the internal component state within lambda slots. For example
>
> ```ruby
> slot :header, ->(&content) { render HeaderComponent.new(featured: @featured), &content }
>
> def initialize(featured:)
>   @featured = feature
> end
> ```

## Polymorphic slot

Polymorphic slots can render one of several possible  slots, allowing for flexibility in component content. This feature is  particularly useful when you require a fixed structure but need to  accommodate different types of content. To implement this, simply pass a types hash containing the types along with corresponding slot definitions.

```ruby
class IconComponent < Phlex::HTML
  # omitted code
end

class ImageComponent < Phlex::HTML
  # omitted code
end

class CardComponent < Phlex::HTML
  include Phlex::Slotable

  slot :avatar, types: { icon: IconComponent, image: ImageComponent }

  def template
    if avatar_slot?
      div id: "avatar" do
        render avatar_slot
      end
    end
  end
end

User = Data.define(:image_url)
user = User.new(image_url: "user.png")

CardComponent.new.call do |card|
  if user.image_url
    card.with_image_avatar(src: user.image_url)
  else
    card.with_icon_avatar(name: :user)
  end
end
```

Returning:

```html
<div id="avatar">
  <img src="user.png"/>
</div>
```

Note that you need to use `with_{type}_{slot_name}` to set slot content. In the example above, it was used `with_image_avatar` and `with_icon_avatar`.

> [!TIP]
> You can take advantage of all the previously introduced features, such as lambda slot and slot collection:
>
> ```ruby
> slot :avatar, collection: true, types: {
>   icon: IconComponent,
>   image: "ImageComponent",
>   text: ->(&content) { span(class: "avatar", &content) }
> }
> ```

## Performance
Using Phlex::Slotable you don't suffer a performance penalty compared to using Phlex::DeferredRender, sometimes it can even be a little faster.

```
Generated using `ruby benchmark/main.rb`

Phlex 1.11.0
Phlex::Slotable 0.5.0

ruby 3.3.5 (2024-09-03 revision ef084cc8f4) [arm64-darwin23]
Warming up --------------------------------------
            Deferred    22.176k i/100ms
            Slotable    23.516k i/100ms
Calculating -------------------------------------
            Deferred    222.727k (± 0.8%) i/s    (4.49 μs/i) -      1.131M in   5.078157s
            Slotable    237.405k (± 0.6%) i/s    (4.21 μs/i) -      1.199M in   5.051936s

Comparison:
            Slotable:   237405.0 i/s
            Deferred:   222726.8 i/s - 1.07x  slower
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/stephannv/phlex-slotable. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/stephannv/phlex-slotable/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Phlex::Slot project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/stephannv/phlex-slotable/blob/master/CODE_OF_CONDUCT.md).
