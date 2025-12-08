# typed: false
# frozen_string_literal: true

require_relative '../../../lib/strategy/examples/greedy_strategy'

RSpec.describe GreedyStrategy do
  let(:strategy) { GreedyStrategy.new('Greedy') }
  let(:empty_history) { {} }

  describe '#choose_catch' do
    it 'attempts to catch a large amount when pond is healthy' do
      catch = strategy.choose_catch(1, 1, 100, [], [], 'Partner', empty_history)
      expect(catch).to be >= 10
      expect(catch).to be <= 30
    end

    it 'leaves room for estimated partner catch' do
      catch = strategy.choose_catch(1, 1, 50, [], [], 'Partner', empty_history)
      # Should be around pond_fish - 12 (estimated partner catch)
      expect(catch).to be < 50
    end

    it 'never catches more than 30' do
      catch = strategy.choose_catch(1, 1, 200, [], [], 'Partner', empty_history)
      expect(catch).to be <= 30
    end

    it 'catches 0 when pond is very small' do
      catch = strategy.choose_catch(1, 5, 5, [10, 10, 10, 10], [10, 10, 10, 10], 'Partner', empty_history)
      # 5 - 12 (estimated) = -7, capped to 0
      expect(catch).to eq(0)
    end
  end

  describe '#choose_partners' do
    let(:history_with_scores) do
      {
        'Greedy' => PlayerHistory.new(
          partners: ['Player1'],
          catches: [[20, 20, 20, 20, 20, 20, 20, 20, 20, 20]],
          scores: [200]
        ),
        'Player1' => PlayerHistory.new(
          partners: ['Greedy'],
          catches: [[10, 10, 10, 10, 10, 10, 10, 10, 10, 10]],
          scores: [100]
        ),
        'Player2' => PlayerHistory.new(
          partners: ['Player3'],
          catches: [[5, 5, 5, 5, 5, 5, 5, 5, 5, 5]],
          scores: [50]
        ),
        'Player3' => PlayerHistory.new(
          partners: ['Player2'],
          catches: [[15, 15, 15, 15, 15, 15, 15, 15, 15, 15]],
          scores: [150]
        )
      }
    end

    it 'prefers players with higher total scores' do
      players = ['Greedy', 'Player1', 'Player2', 'Player3']
      choices = strategy.choose_partners(2, players, history_with_scores)

      # Should prefer Player3 (150) and Player1 (100) over Player2 (50)
      expect(choices).to contain_exactly('Player3', 'Player1')
    end

    it 'returns two different players' do
      players = ['Greedy', 'Player1', 'Player2', 'Player3']
      choices = strategy.choose_partners(2, players, history_with_scores)

      expect(choices[0]).not_to eq(choices[1])
      expect(choices).not_to include('Greedy')
    end
  end
end
