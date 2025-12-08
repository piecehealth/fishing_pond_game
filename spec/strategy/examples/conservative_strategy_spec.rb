# typed: false
# frozen_string_literal: true

require_relative '../../../lib/strategy/examples/conservative_strategy'

RSpec.describe ConservativeStrategy do
  let(:strategy) { ConservativeStrategy.new('Conservative') }
  let(:empty_history) do
    {
      'Conservative' => PlayerHistory.new(partners: [], catches: [], scores: []),
      'Player1' => PlayerHistory.new(partners: [], catches: [], scores: []),
      'Player2' => PlayerHistory.new(partners: [], catches: [], scores: [])
    }
  end

  describe '#choose_catch' do
    it 'always catches 3 fish' do
      catch = strategy.choose_catch(1, 1, 100, [], [], 'Partner', empty_history)
      expect(catch).to eq(3)
    end

    it 'catches 3 fish regardless of pond size' do
      catch1 = strategy.choose_catch(1, 1, 100, [], [], 'Partner', empty_history)
      catch2 = strategy.choose_catch(1, 2, 20, [3], [5], 'Partner', empty_history)

      expect(catch1).to eq(3)
      expect(catch2).to eq(3)
    end

    it 'catches 3 fish regardless of partner behavior' do
      catch = strategy.choose_catch(1, 3, 50, [3, 3], [30, 30], 'GreedyPartner', empty_history)
      expect(catch).to eq(3)
    end
  end

  describe '#choose_partners' do
    let(:history_with_data) do
      {
        'Conservative' => PlayerHistory.new(
          partners: ['Player1'],
          catches: [[3, 3, 3, 3, 3, 3, 3, 3, 3, 3]],
          scores: [30]
        ),
        'Player1' => PlayerHistory.new(
          partners: ['Conservative'],
          catches: [[5, 5, 5, 5, 5, 5, 5, 5, 5, 5]],
          scores: [50]
        ),
        'Player2' => PlayerHistory.new(
          partners: ['Player3'],
          catches: [[20, 20, 20, 20, 20, 20, 20, 20, 20, 20]],
          scores: [200]
        ),
        'Player3' => PlayerHistory.new(
          partners: ['Player2'],
          catches: [[3, 3, 3, 3, 3, 3, 3, 3, 3, 3]],
          scores: [30]
        )
      }
    end

    it 'prefers players with lower average catches' do
      players = ['Conservative', 'Player1', 'Player2', 'Player3']
      choices = strategy.choose_partners(2, players, history_with_data)

      # Player3 has avg catch of 3, Player1 has avg catch of 5, Player2 has avg catch of 20
      # Should prefer Player3 and Player1 over Player2
      expect(choices).to contain_exactly('Player3', 'Player1')
    end

    it 'returns two different players' do
      players = ['Conservative', 'Player1', 'Player2', 'Player3']
      choices = strategy.choose_partners(2, players, history_with_data)

      expect(choices[0]).not_to eq(choices[1])
      expect(choices).not_to include('Conservative')
    end
  end
end
