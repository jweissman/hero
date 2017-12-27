require 'pry'
require 'spec_helper'
require 'support/query'

describe FrameDivider do
  context 'without resolution' do
    let(:divider) do
      described_class.new(children: children, frame: frame, direction: direction)
    end

    let(:frame) { Frame[0,0,10,10] }
    let(:direction) { :vertical }

    let(:result) { divider.split }

    context 'with a few children' do
      let(:children) {
        [
          Container[ height: 10 ],
          Container[ ],
          Container[ height: 10 ]
        ]
      }
      it 'should have as many elements as children' do
        # p [ result: result ]
        expect(result.length).to eq(3)
      end
    end

    context 'should sum children size...' do
      let(:children) {
        [
          Container[ ],
          Container[
            Container[ height: 2 ],
            Container[ height: 1 ],
            Container[ height: 2 ]
          ],
        ]
      }

      it 'should have a top frame of size 5' do
        expect(result.first).to eq(Frame[0,0,10,5])
      end
    end

    context 'should manage double-containment' do
      let(:children) {
        [
          Container[],
          Container[
            Container[],
            Container[ width: 6, height: 6 ],
            Container[]
          ],
          Container[]
        ]
      }

      it 'should have made other frames 2' do
        p [ result: result ]
        expect(result[0]).to eq( Frame[0,0,10,2] )
        expect(result[1]).to eq( Frame[0,2,10,8] )
        expect(result[2]).to eq( Frame[0,8,10,10] )
      end
    end
  end

  context 'with a composer' do
    let(:composer) {
      SimpleComposer.new(
        frame: Frame[0,0,100,100]
      )
    }

    let(:space) do
      Container[ Paragraph[ text: 'space' ]]
    end

    let(:model) {
      Container[
        space,
        Container[
          space,
          Container[
            Paragraph[ text: 'hello' ],
            id: 'greeting',
            width: 70,
            height: 70
          ],
          space,
        ],
        space,
        direction: :horizontal,
      ]
    }

    it 'should divide a set of frames' do
      resolved = composer.resolve(*model)
      q = Query.new(resolved)
      hi = q.find('greeting')
      expect( hi.id ).to eq('greeting')
      expect( hi.props[:frame] ).to eq(Frame[15,15,85,85])
    end

    it 'works out even in nested situations' do
      wrapped_model = Container[
          Container[ Paragraph[text: 'header'], height: 10, id: 'header' ],
          model,
          Container[ Paragraph[text: 'footer'], height: 10, id: 'footer' ],
          # padding: 5
        id: 'wrapper'
      ]

      resolved = composer.resolve(*wrapped_model)
      p [ resolved: resolved ]
      q = Query.new(resolved)
      hi = q.find('greeting')
      p [ hi: hi ]
      expect( hi.id ).to eq('greeting')
      expect( hi.frame ).to eq(Frame[15,15,85,85])
    end
  end
end
