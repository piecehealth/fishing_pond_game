# typed: false
# frozen_string_literal: true

require_relative '../../lib/game/tournament'
require_relative '../../lib/strategy/examples/conservative_strategy'
require_relative '../../lib/strategy/examples/greedy_strategy'

RSpec.describe Tournament do
  let(:strategies) do
    {
      'Alice' => ConservativeStrategy.new('Alice'),
      'Bob' => GreedyStrategy.new('Bob'),
      'Carol' => ConservativeStrategy.new('Carol'),
      'Dave' => GreedyStrategy.new('Dave')
    }
  end

  describe '.play' do
    it 'returns a TournamentResult' do
      result = Tournament.play(strategies, 2)

      expect(result).to be_a(TournamentResult)
      expect(result.total_rounds).to eq(2)
    end

    it 'plays the correct number of rounds' do
      result = Tournament.play(strategies, 3)

      expect(result.round_results.length).to eq(3)
    end

    it 'tracks final scores for all players' do
      result = Tournament.play(strategies, 2)

      expect(result.final_scores.keys).to contain_exactly('Alice', 'Bob', 'Carol', 'Dave')
      expect(result.final_scores.values.all? { |score| score.is_a?(Integer) && score >= 0 }).to be true
    end

    it 'determines a winner' do
      result = Tournament.play(strategies, 2)

      expect(result.winner).to be_a(String)
      expect(strategies.keys).to include(result.winner)
    end

    it 'updates player history after each round' do
      result = Tournament.play(strategies, 2)

      # Each player should have history for 2 rounds
      result.round_results.each do |round_result|
        round_result.pairing_results.each_value do |pairing|
          expect(pairing.player1_catches.length).to eq(10)
          expect(pairing.player2_catches.length).to eq(10)
        end
      end
    end
  end
end
