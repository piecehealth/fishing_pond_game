# typed: false
# frozen_string_literal: true

require_relative '../../../lib/strategy/examples/tit_for_tat_strategy'

RSpec.describe TitForTatStrategy do
  let(:strategy) { TitForTatStrategy.new('TitForTat') }
  let(:empty_history) { {} }

  describe '#choose_catch' do
    context 'first turn' do
      it 'starts with cooperation (5 fish)' do
        catch = strategy.choose_catch(1, 1, 100, [], [], 'Partner', empty_history)
        expect(catch).to eq(5)
      end
    end

    context 'subsequent turns' do
      it 'mirrors partner previous catch' do
        catch = strategy.choose_catch(1, 2, 80, [5], [10], 'Partner', empty_history)
        expect(catch).to eq(10)
      end

      it 'copies conservative partner' do
        catch = strategy.choose_catch(1, 3, 60, [5, 3], [10, 3], 'Partner', empty_history)
        expect(catch).to eq(3)
      end

      it 'copies greedy partner' do
        catch = strategy.choose_catch(1, 4, 40, [5, 3, 20], [10, 3, 25], 'Partner', empty_history)
        expect(catch).to eq(25)
      end
    end
  end

  describe '#choose_partners' do
    let(:history_with_varied_catches) do
      {
        'TitForTat' => PlayerHistory.new(
          partners: ['Player1'],
          catches: [[5, 10, 10, 10, 10, 10, 10, 10, 10, 10]],
          scores: [95]
        ),
        'Player1' => PlayerHistory.new(
          partners: ['TitForTat'],
          catches: [[10, 10, 10, 10, 10, 10, 10, 10, 10, 10]],  # Consistent ~10
          scores: [100]
        ),
        'Player2' => PlayerHistory.new(
          partners: ['Player3'],
          catches: [[3, 3, 3, 3, 3, 3, 3, 3, 3, 3]],  # Too conservative
          scores: [30]
        ),
        'Player3' => PlayerHistory.new(
          partners: ['Player2'],
          catches: [[30, 30, 30, 30, 30, 30, 30, 30, 30, 30]],  # Too greedy
          scores: [300]
        )
      }
    end

    it 'prefers cooperative players (moderate catches around 5-10)' do
      players = ['TitForTat', 'Player1', 'Player2', 'Player3']
      choices = strategy.choose_partners(2, players, history_with_varied_catches)

      # Player1 (avg 10) is most cooperative, Player2 (avg 3) second
      # Player3 (avg 30) is least cooperative
      expect(choices).to include('Player1')
    end

    it 'returns two different players' do
      players = ['TitForTat', 'Player1', 'Player2', 'Player3']
      choices = strategy.choose_partners(2, players, history_with_varied_catches)

      expect(choices[0]).not_to eq(choices[1])
      expect(choices).not_to include('TitForTat')
    end
  end
end
