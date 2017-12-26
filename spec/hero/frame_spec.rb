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

  it 'handles uneven subdivisions' do
    expect( frame.subdivide(3, direction: :horizontal)  ).to eq(
      [
        Frame[0,0,3,10],
        Frame[3,0,6,10],
        Frame[6,0,10,10],
      ]
    )
  end

  it 'can tell if it contains a point' do
    expect(frame.contains?(position: [5,5])).to be true
    expect(frame.contains?(position: [-5,15])).to be false
  end

  it 'should be paddable' do
    expect(frame.pad(2)).to eq(Frame[2,2,8,8])
  end

  it 'can be sliced' do
    expect( frame.slice(5,direction: :vertical) ).to eq(
      [
        Frame[0,0,10,5],
        Frame[0,5,10,10]
      ]
    )

    expect( frame.slice(3,6,direction: :vertical) ).to eq(
      [
        Frame[0,0,10,3],
        Frame[0,3,10,6],
        Frame[0,6,10,10]
      ]
    )

    f2 = Frame[10,10,20,20]
    expect( f2.slice(15,direction: :vertical) ).to eq(
      [
        Frame[10,10,20,15],
        Frame[10,15,20,20],
      ]
    )

    expect( f2.slice(15,direction: :horizontal) ).to eq(
      [
        Frame[10,10,15,20],
        Frame[15,10,20,20],
      ]
    )
  end
end
