require 'spec_helper'
require 'hero'

describe Hero do
  # "self-test" of paragraph function defn
  it 'should be invokable' do
    expect( Paragraph[ text: 'hello' ] ).to eq(
      [ :paragraph, body: 'hello' ]
    )

    expect( Paragraph[ [ :child, info: 'sub-paragraph' ], text: 'hello' ] ).to eq(
      [ :paragraph, [ :child, info: 'sub-paragraph' ], body: 'hello' ]
    )
  end

  # hero just calls the function in this case
  it 'should define a component as a function' do
    expect( Hero.render_component(Paragraph, text: 'hello world') ).to eq(
      [ :paragraph, body: 'hello world' ]
    )

    expect( Hero.render_component(Paragraph, [ :child, info: 'content' ], text: 'hi') ).to eq(
      [ :paragraph, [ :child, info: 'content' ], body: 'hi' ]
    )

    # okay, so the idea is that you could build a wrapper to parse these!!!
    # let's play with that, maybe there's a good dsl
  end

  it 'should define a component with state' do
    counter = Counter.new
    expect( counter.render ).to eq(
      [ :division,
        [ :division,
          [ :paragraph, {body: "increment", on_click: counter.method(:inc)}], {}
        ],
        [ :paragraph, {body: 'current value: 0'}],
        [ :division,
          [ :paragraph, {body: "decrement", on_click: counter.method(:dec)}], {}
        ],
        {}
      ]
    )
  end
end

describe Hero::Composer do
  subject(:composer) do
    SimpleComposer.new(frame: Frame[0,0,100,100])
  end

  it 'should resolve resulting structures...' do
    # we want a resolver that breaks down the
    # position of each component ... and can
    # route paragraphs to them based on these positions!
    rendered = Container[
      Paragraph[ text: 'hi' ],
      Paragraph[ text: 'okay' ],
      color: 'blue'
    ]

    expect(rendered).to eq(
      [ :division,
        [ :paragraph, body: 'hi' ],
        [ :paragraph, body: 'okay' ],
        color: 'blue'
      ]
    )

    # we want to turn this into a list of elements with positions...
    # i.e., for a drawing pipeline...
    resolved = composer.resolve(*rendered)
    expect(resolved).to eq(
      [
        [:rect, color: 'blue', frame: Frame[0,0,100,100]],
        [:text, body: 'hi', frame: Frame[0,0,100,50]],
        [:text, body: 'okay', frame: Frame[0,50,100,100]]
      ]
    )
  end
end

describe 'Hero::Engine' do
  subject(:engine) do
    Hero::Engine.new(
      klass: Counter,
      viewport_dimensions: [100,100],
      composer_provider: SimpleComposer
    )
  end

  let(:counter) { engine.root }

  it 'should manage the state of a tree of components' do
    # inc
    expect{ engine.click(position: [10,10])}.to change{counter.state[:value]}.from(0).to(1)
    expect{ engine.click(position: [10,10])}.to change{counter.state[:value]}.from(1).to(2)

    # dec
    expect{ engine.click(position: [10,90])}.to change{counter.state[:value]}.from(2).to(1)
  end
end
