require 'pry'
require 'spec_helper'
require 'support/query'

describe FrameDivider do
  context 'without resolution' do
    let(:divider) do
      described_class.new(children: children, frame: frame, direction: direction)
    end

    let(:frame) { Frame[0,0,100,100] }
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

      let(:top_frame) { result.first }

      it 'should have a top frame of size 95' do
        expect(top_frame).to eq(Frame[0,0,100,95])
        expect(top_frame.height).to eq(95)

        # bottom frame
        expect(result.last.height).to eq(5)
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

      let(:top) { result[0] }
      let(:middle) { result[1] }
      let(:bottom) { result[2] }

      it 'should have made middle frame six units tall' do
        expect(middle.height).to eq(6)
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
          direction: :horizontal
        ],
        space,
        # direction: :horizontal,
      ]
    }

    let(:resolved) do
      composer.resolve(*model)
    end

    let(:query) do
      Query.new(resolved)
    end

    let(:greeting) do
      query.find 'greeting'
    end

    it 'should divide a set of frames' do
      expect( greeting.id ).to eq('greeting')
      hi_frame = greeting.frame #props[:frame]
      expect( hi_frame.width ).to eq(70)
      expect( hi_frame.height ).to eq(70)
      p [ resolved: resolved ]
      expect( hi_frame.center ).to eq([50,50])
    end

    it 'works out even in nested situations' do
      wrapped_model = Container[
          Container[ Paragraph[text: 'header'], height: 5, id: 'header' ],
          model,
          Container[ Paragraph[text: 'footer'], height: 5, id: 'footer' ],
          # padding: 5
        id: 'wrapper'
      ]

      resolved = composer.resolve(*wrapped_model)
      p [ resolved: resolved ]
      q = Query.new(resolved)
      hi = q.find('greeting')
      p [ hi: hi ]
      expect( hi.id ).to eq('greeting')
      expect( hi.frame.width ).to eq(70)
      expect( hi.frame.height ).to eq(70)
      expect( hi.frame.center ).to eq([50,50])
    end
  end
end
