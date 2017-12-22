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

  it 'should respect width/height specifications' do
    rendered = Container[
      Paragraph[ text: 'hi', height: 10 ],
      Paragraph[ text: 'okay' ],
      color: 'blue'
    ]

    resolved = composer.resolve(*rendered)
    expect(resolved).to eq(
      [
        [:rect, color: 'blue', frame: Frame[0,0,100,100]],
        [:text, height: 10, body: 'hi', frame: Frame[0,0,100,10]],
        [:text, body: 'okay', frame: Frame[0,10,100,100]]
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
