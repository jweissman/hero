# hero

* [Homepage](https://rubygems.org/gems/hero)
* [Documentation](http://rubydoc.info/gems/hero/frames)

[![Code Climate GPA](https://codeclimate.com/github/jweissman/hero/badges/gpa.svg)](https://codeclimate.com/github/jweissman/hero)

## Description

Target-agnostic implementation of component pattern with a DSL for Rubyists.

Idiomatically describe components with lambdas or classes for state management.

## Features

- [ ] `Hero::Composer` composition DSL for 'parsing' component hierarchies

## Examples

Just require the library to get started.

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

Container = ->(*children, **props) { [ :division, *children, **props ] }

Button = ->(*children, **props) {
  action = props.delete(:action) { 'okay' }
  Container[
    Paragraph[props.merge(text: action)]
  ]
}
```

Note we're inventing the 'target' language wholesale here. (We'll see later how to make use of the
resulting document tree that results from rendering components.)

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

    $ gem install hero

## Copyright

Copyright (c) 2017 Joseph Weissman

See LICENSE.txt for details.
