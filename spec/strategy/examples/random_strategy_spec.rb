# typed: false
# frozen_string_literal: true

require_relative '../../../lib/strategy/examples/random_strategy'

RSpec.describe RandomStrategy do
  let(:strategy) { RandomStrategy.new('Random') }
  let(:empty_history) { {} }

  describe '#choose_catch' do
    it 'catches between 10 and 30 fish' do
      # Run multiple times to test randomness
      catches = 10.times.map do
        strategy.choose_catch(1, 1, 100, [], [], 'Partner', empty_history)
      end

      expect(catches.all? { |c| c >= 10 && c < 30 }).to be true
    end

    it 'produces varied catches' do
      catches = 20.times.map do
        strategy.choose_catch(1, 1, 100, [], [], 'Partner', empty_history)
      end

      # Should have some variance (not all the same value)
      expect(catches.uniq.length).to be > 1
    end
  end

  describe '#choose_partners' do
    let(:players) { ['Random', 'Player1', 'Player2', 'Player3'] }
    let(:history) do
      {
        'Random' => PlayerHistory.new(partners: [], catches: [], scores: []),
        'Player1' => PlayerHistory.new(partners: [], catches: [], scores: []),
        'Player2' => PlayerHistory.new(partners: [], catches: [], scores: []),
        'Player3' => PlayerHistory.new(partners: [], catches: [], scores: [])
      }
    end

    it 'selects two players randomly' do
      choices = strategy.choose_partners(2, players, history)

      expect(choices.length).to eq(2)
      expect(choices[0]).to be_a(String)
      expect(choices[1]).to be_a(String)
    end

    it 'does not select itself' do
      choices = strategy.choose_partners(2, players, history)

      expect(choices).not_to include('Random')
    end

    it 'selects two different players' do
      choices = strategy.choose_partners(2, players, history)

      expect(choices[0]).not_to eq(choices[1])
    end

    it 'produces varied partner selections' do
      # Run multiple times and check for variance
      all_choices = 10.times.map do
        strategy.choose_partners(2, players, history)
      end

      # Should have some variance in selections
      expect(all_choices.uniq.length).to be > 1
    end
  end
end
