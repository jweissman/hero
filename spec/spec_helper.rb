require 'rspec'
# require 'pry'
require 'simplecov'

SimpleCov.start

require 'hero'

include Hero

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
# we'll create new instances as n
class SimpleComposer < Hero::Composer
  # resolver functions -- you can make use of current @frame...
  def division(*children, **props)
    resolved_children = resolve_children(children) #, frame: @frame)
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

