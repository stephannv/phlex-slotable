## [Unreleased]

## [0.3.1] - 2024-02-14
- Support Ruby 2.7

  *stephannv*

## [0.3.0] - 2024-02-14

- Match Slotable peformance with DeferredRender
  ```
  ruby 3.3.0 (2023-12-25 revision 5124f9ac75) [arm64-darwin23]
  Warming up --------------------------------------
              Deferred    26.779k i/100ms
        Slotable 0.2.0     21.636k i/100ms
        Slotable 0.3.0    27.013k i/100ms
  Calculating -------------------------------------
              Deferred    267.884k (± 0.6%) i/s -      1.366M in   5.098391s
        Slotable 0.2.0    216.193k (± 0.4%) i/s -      1.082M in   5.003961s
        Slotable 0.3.0    270.082k (± 0.5%) i/s -      1.351M in   5.001001s
  ```
  *stephannv*

- Allow polymorphic slots
  ```ruby
  class CardComponent < Phlex::HTML
    include Phlex::Slotable

    slot :avatar, types: { icon: IconComponent, image: ImageComponent }

    def template
      if avatar_slot?
        render avatar_slot
      end
    end
  end

  render CardComponent.new do |card|
    if user
      card.with_image_avatar(src: user.image_url)
    else
      card.with_icon_avatar(name: :user)
    end
  end
  ```

  *stephannv*

## [0.2.0] - 2024-02-13

- Allow view slots using string as class name

  *stephannv*

- Allow lambda slots

  *stephannv*

## [0.1.0] - 2024-02-12
- Add single and multi slots

  *stephannv*

- Add generic slots

  *stephannv*

- Add view slots

  *stephannv*
