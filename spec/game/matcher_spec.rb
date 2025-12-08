# typed: false
# frozen_string_literal: true

require_relative '../../lib/game/matcher'
require_relative '../../lib/types'

RSpec.describe Matcher do
  describe '.match_round_1' do
    it 'pairs all players randomly' do
      players = ['Alice', 'Bob', 'Carol', 'Dave']
      pairings = Matcher.match_round_1(players)

      expect(pairings.length).to eq(2)
      expect(pairings.all? { |p| p.is_a?(Pairing) }).to be true
    end

    it 'marks all pairings as not mutual first choice' do
      players = ['Alice', 'Bob', 'Carol', 'Dave']
      pairings = Matcher.match_round_1(players)

      expect(pairings.all? { |p| !p.was_mutual_first_choice }).to be true
    end

    it 'handles odd number of players' do
      players = ['Alice', 'Bob', 'Carol']
      pairings = Matcher.match_round_1(players)

      # Only 1 pairing should be made, 1 player sits out
      expect(pairings.length).to eq(1)
    end
  end

  describe '.match_with_preferences' do
    let(:players) { ['Alice', 'Bob', 'Carol', 'Dave'] }

    context 'with mutual first choices' do
      it 'pairs players who selected each other as #1' do
        preferences = {
          'Alice' => ['Bob', 'Carol'],
          'Bob' => ['Alice', 'Dave'],
          'Carol' => ['Dave', 'Alice'],
          'Dave' => ['Carol', 'Bob']
        }

        pairings = Matcher.match_with_preferences(players, preferences)

        # Alice-Bob should be mutual, Carol-Dave should be mutual
        mutual_pairings = pairings.select(&:was_mutual_first_choice)
        expect(mutual_pairings.length).to eq(2)
      end
    end

    context 'without mutual first choices' do
      it 'randomly pairs remaining players' do
        preferences = {
          'Alice' => ['Bob', 'Carol'],
          'Bob' => ['Carol', 'Dave'],
          'Carol' => ['Dave', 'Alice'],
          'Dave' => ['Alice', 'Bob']
        }

        pairings = Matcher.match_with_preferences(players, preferences)

        # No mutual first choices, all should be random
        mutual_pairings = pairings.select(&:was_mutual_first_choice)
        expect(mutual_pairings.length).to eq(0)
        expect(pairings.length).to eq(2)
      end
    end

    context 'with mixed mutual and non-mutual' do
      it 'pairs mutual first, then random' do
        preferences = {
          'Alice' => ['Bob', 'Carol'],
          'Bob' => ['Alice', 'Dave'],
          'Carol' => ['Dave', 'Bob'],
          'Dave' => ['Carol', 'Alice']
        }

        pairings = Matcher.match_with_preferences(players, preferences)

        # Alice-Bob mutual, Carol-Dave mutual
        expect(pairings.length).to eq(2)
        mutual_count = pairings.count(&:was_mutual_first_choice)
        expect(mutual_count).to eq(2)
      end
    end
  end
end
