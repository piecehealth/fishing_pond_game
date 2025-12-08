# typed: false
# frozen_string_literal: true

require_relative '../../lib/game/round'
require_relative '../../lib/strategy/examples/conservative_strategy'
require_relative '../../lib/strategy/examples/greedy_strategy'

RSpec.describe Round do
  let(:strategies) do
    {
      'Alice' => ConservativeStrategy.new('Alice'),
      'Bob' => GreedyStrategy.new('Bob'),
      'Carol' => ConservativeStrategy.new('Carol'),
      'Dave' => GreedyStrategy.new('Dave')
    }
  end

  let(:empty_history) do
    {
      'Alice' => PlayerHistory.new(partners: [], catches: [], scores: []),
      'Bob' => PlayerHistory.new(partners: [], catches: [], scores: []),
      'Carol' => PlayerHistory.new(partners: [], catches: [], scores: []),
      'Dave' => PlayerHistory.new(partners: [], catches: [], scores: [])
    }
  end

  describe '.play' do
    context 'round 1' do
      it 'uses random pairing' do
        result = Round.play(1, strategies, empty_history)

        expect(result.round_number).to eq(1)
        expect(result.pairings.length).to eq(2)
        expect(result.pairings.first.was_mutual_first_choice).to be false
      end

      it 'plays 10 turns per pairing' do
        result = Round.play(1, strategies, empty_history)

        pairing_result = result.pairing_results.values.first
        expect(pairing_result.player1_catches.length).to eq(10)
        expect(pairing_result.player2_catches.length).to eq(10)
      end

      it 'calculates total scores' do
        result = Round.play(1, strategies, empty_history)

        pairing_result = result.pairing_results.values.first
        expect(pairing_result.player1_total).to eq(pairing_result.player1_catches.sum)
        expect(pairing_result.player2_total).to eq(pairing_result.player2_catches.sum)
      end
    end

    context 'round 2+' do
      let(:history_with_one_round) do
        {
          'Alice' => PlayerHistory.new(
            partners: ['Bob'],
            catches: [[3, 3, 3, 3, 3, 3, 3, 3, 3, 3]],
            scores: [30]
          ),
          'Bob' => PlayerHistory.new(
            partners: ['Alice'],
            catches: [[10, 10, 10, 10, 10, 10, 10, 10, 10, 10]],
            scores: [100]
          ),
          'Carol' => PlayerHistory.new(
            partners: ['Dave'],
            catches: [[3, 3, 3, 3, 3, 3, 3, 3, 3, 3]],
            scores: [30]
          ),
          'Dave' => PlayerHistory.new(
            partners: ['Carol'],
            catches: [[10, 10, 10, 10, 10, 10, 10, 10, 10, 10]],
            scores: [100]
          )
        }
      end

      it 'uses preference-based pairing' do
        result = Round.play(2, strategies, history_with_one_round)

        expect(result.round_number).to eq(2)
        expect(result.pairings.length).to eq(2)
      end
    end

    context 'when pond depletes early' do
      let(:greedy_strategies) do
        {
          'Alice' => GreedyStrategy.new('Alice'),
          'Bob' => GreedyStrategy.new('Bob')
        }
      end

      it 'fills remaining turns with 0' do
        result = Round.play(1, greedy_strategies, empty_history)

        pairing_result = result.pairing_results.values.first
        # Should still have 10 entries even if pond depleted early
        expect(pairing_result.player1_catches.length).to eq(10)
        expect(pairing_result.player2_catches.length).to eq(10)
      end
    end
  end
end
