require 'spec_helper'

describe Frame do
  subject(:frame) do
    Frame[0,0,10,10]
  end

  it 'has coordinate accessors' do
    expect( frame.x0 ).to eq(0)
    expect( frame.x1 ).to eq(10)
    expect( frame.y0 ).to eq(0)
    expect( frame.y1 ).to eq(10)
  end

  it 'has dimensions' do
    expect( frame.width ).to eq(10)
    expect( frame.height ).to eq(10)
    expect( frame.area ).to eq(100)
  end

  it 'can be subdivided' do
    expect( frame.subdivide(2)  ).to eq(
      [
        Frame[0,0,10,5],
        Frame[0,5,10,10]
      ]
    )

    expect( frame.subdivide(2, direction: :horizontal)  ).to eq(
      [
        Frame[0,0,5,10],
        Frame[5,0,10,10]
      ]
    )
  end

  it 'can tell if it contains a point' do
    expect(frame.contains?(position: [5,5])).to be true
    expect(frame.contains?(position: [-5,15])).to be false
  end
end
