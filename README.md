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

    ```ruby

    require 'hero'

    # simple proc-based components
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

    class Counter < Component
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

    # little composer for our target language (divisions, messages)
    class SimpleComposer < Hero::Composer
      # in resolver functions, you can make use of current @frame...
      def division(*children, **props)
        puts "--- resolving DIVISION props=#{props}"
        resolved_children = resolve_children(children)
        [
          [ :rect, props.merge({ frame: @frame })]
        ] + resolved_children
      end

      def paragraph(**props)
        puts "--- resolving PARAGRAPH props=#{props}"
        [
          [ :text, props.merge({ frame: @frame }) ]
        ]
      end
    end

    # we can use Hero::Engine to 'mount' the components
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

## Synopsis

    $ hero

## Copyright

Copyright (c) 2017 Joseph Weissman

See LICENSE.txt for details.
