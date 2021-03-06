# hero :star: :sparkles: :dizzy:

* [Homepage](https://rubygems.org/gems/hero)
* [Documentation](http://rubydoc.info/gems/hero/frames)

[![Code Climate GPA](https://codeclimate.com/github/jweissman/hero/badges/gpa.svg)](https://codeclimate.com/github/jweissman/hero)
[ ![Codeship Status for jweissman/hero](https://app.codeship.com/projects/6df88540-cc7e-0135-1888-0691da0382ae/status?branch=master)](https://app.codeship.com/projects/261921)

## Description

Target-agnostic implementation of component pattern with a DSL for Rubyists.

Idiomatically describe components with lambdas or classes for state management.

## Features

- Inherit from `Hero::Component` to write state-based components
- Inherit from `Hero::Composer` for composition DSL (to help parse component hierarchies)
- Use `Hero::Engine` to mount components and route click events

## Examples

Just require the library to get started...

```ruby
require 'hero'
```
### Simple proc-based components

The most basic components are procs that take `(*children, **props)`.

```ruby
Paragraph = ->(*children, **props) {
  body = props.delete(:text) { raise 'paragraph must have text prop' }
  [ :paragraph, *children, **(props.merge(body: body)) ]
}

Container = ->(*children, **props) {
  [ :division, *children, **props ]
}

Button = ->(*children, **props) {
  action = props.delete(:action) { 'okay' }
  Container[
    Paragraph[props.merge(text: action)]
  ]
}
```

Note we're inventing the 'target' language wholesale here. We'll see later how to make use of the
resulting document tree that results from rendering components.

### Components with state

Inherit from `Hero::Component` to manage state.

```ruby
class Counter < Hero::Component
  def initialize
    @state = {
      value: 0
    }
  end

  def inc
    value = @state[:value]
    apply(value: value+1)
  end

  def dec
    value = @state[:value]
    apply(value: value-1)
  end

  def render(**props)
    Container[
      Button[
        action: 'increment',
        on_click: method(:inc)
      ],
      Paragraph[
        text: "current value: #{@state[:value]}"
      ],
      Button[
        action: 'decrement',
        on_click: method(:dec)
      ]
    ]
  end
end
```

### Composition

We can use the Composer DSL to parse the abstract document trees into, e.g.,
a list of drawing commands that a graphics pipeline could render.

```ruby
class SimpleComposer < Hero::Composer
  # in resolver functions, you can make use of current @frame...
  def division(*children, **props)
    resolved_children = resolve_children(children)
    [
      [ :rect, props.merge({ frame: @frame })]
    ] + resolved_children
  end

  def paragraph(**props)
    [
      [ :text, props.merge({ frame: @frame }) ]
    ]
  end
end
```

The built-in composition engine will resolve frames while attempting to respect the following props: `height`, `width`, `padding`, and `direction` (to indicate "flow" orientation; must be `:horizontal` or `:vertical`).

### Engines

We can use Hero::Engine to 'mount' a component. The engine provides a `click(position:)` method which
triggers `on_click` events for elements in the rendered view.

```ruby
engine = Hero::Engine.new(
  klass: Counter,
  viewport_dimensions: [100,100],
  composer_provider: SimpleComposer
)

engine.click(position: [10,10]) # => changes counter.state[:value] from 0 to 1
```


## Requirements

  - Ruby 2.x

## Install

  Just add `gem 'hero', github: 'jweissman/hero'` to your Gemfile for now.

## Copyright

Copyright (c) 2017 Joseph Weissman

See LICENSE.txt for details.
