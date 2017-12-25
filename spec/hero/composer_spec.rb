require 'spec_helper'

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

  it 'should respect padding' do
    rendered = Container[
      Paragraph[ text: 'ok', height: 10 ],
      Paragraph[ text: 'cool' ],
      padding: 20,
      color: 'green'
    ]

    resolved = composer.resolve(*rendered)
    expect(resolved).to eq([
      [ :rect, color: 'green', frame: Frame[0,0,100,100]],
      [ :text, height: 10, body: 'ok', frame: Frame[20,20,80,30]],
      [ :text, body: 'cool', frame: Frame[20,30,80,80]]
    ])
  end
end

