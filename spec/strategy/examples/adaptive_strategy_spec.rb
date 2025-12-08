# typed: false
# frozen_string_literal: true

require_relative '../../../lib/strategy/examples/adaptive_strategy'

RSpec.describe AdaptiveStrategy do
  let(:strategy) { AdaptiveStrategy.new('Adaptive') }
  let(:empty_history) { {} }

  describe '#choose_catch' do
    context 'when pond is healthy (80+ fish)' do
      it 'is aggressive' do
        catch = strategy.choose_catch(1, 1, 100, [], [], 'Partner', empty_history)
        expect(catch).to be >= 15
      end

      it 'catches up to 20 fish' do
        catch = strategy.choose_catch(1, 1, 90, [], [], 'Partner', empty_history)
        expect(catch).to be <= 20
      end
    end

    context 'when pond is moderate (30-80 fish)' do
      it 'is moderate' do
        catch = strategy.choose_catch(1, 3, 50, [15, 10], [15, 10], 'Partner', empty_history)
        expect(catch).to be >= 5
        expect(catch).to be <= 15
      end
    end

    context 'when pond is struggling (<30 fish)' do
      it 'is conservative' do
        catch = strategy.choose_catch(1, 5, 25, [15, 10, 8, 5], [15, 10, 8, 5], 'Partner', empty_history)
        expect(catch).to be <= 5
      end

      it 'catches very little when pond is nearly empty' do
        catch = strategy.choose_catch(1, 7, 10, [15, 10, 8, 5, 3, 2], [15, 10, 8, 5, 3, 2], 'Partner', empty_history)
        expect(catch).to be <= 3
      end
    end
  end

  describe '#choose_partners' do
    let(:history_with_variance) do
      {
        'Adaptive' => PlayerHistory.new(
          partners: ['Player1'],
          catches: [[20, 15, 10, 5, 3, 10, 15, 20, 10, 5]],  # High variance
          scores: [113]
        ),
        'Player1' => PlayerHistory.new(
          partners: ['Adaptive'],
          catches: [[15, 12, 10, 8, 5, 8, 10, 12, 15, 10]],  # Moderate variance
          scores: [105]
        ),
        'Player2' => PlayerHistory.new(
          partners: ['Player3'],
          catches: [[10, 10, 10, 10, 10, 10, 10, 10, 10, 10]],  # No variance (static)
          scores: [100]
        ),
        'Player3' => PlayerHistory.new(
          partners: ['Player2'],
          catches: [[30, 3, 30, 3, 30, 3, 30, 3, 30, 3]],  # Very high variance (erratic)
          scores: [165]
        )
      }
    end

    it 'makes valid partner selections based on variance' do
      players = ['Adaptive', 'Player1', 'Player2', 'Player3']
      choices = strategy.choose_partners(2, players, history_with_variance)

      # The strategy selects players based on variance closest to 25
      # All selections should be valid (2 different players, not including self)
      expect(choices.length).to eq(2)
      expect(choices[0]).not_to eq(choices[1])
      expect(choices).not_to include('Adaptive')
    end

    it 'returns two different players' do
      players = ['Adaptive', 'Player1', 'Player2', 'Player3']
      choices = strategy.choose_partners(2, players, history_with_variance)

      expect(choices[0]).not_to eq(choices[1])
      expect(choices).not_to include('Adaptive')
    end
  end
end
