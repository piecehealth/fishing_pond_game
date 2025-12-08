# typed: false
# frozen_string_literal: true

require_relative '../../lib/strategy/base_strategy'

RSpec.describe BaseStrategy do
  # Create a concrete implementation for testing
  class TestStrategy < BaseStrategy
    def choose_catch(round_number, turn_number, pond_fish, my_history, partner_history, partner_name, all_players_history)
      10
    end

    def choose_partners(round_number, all_players, all_players_history)
      others = all_players.reject { |p| p == name }
      [others[0], others[1]]
    end
  end

  let(:strategy) { TestStrategy.new('TestPlayer') }

  describe '#initialize' do
    it 'sets the player name' do
      expect(strategy.name).to eq('TestPlayer')
    end

    it 'initializes empty thoughts' do
      expect(strategy.all_thoughts).to eq({})
    end
  end

  describe '#set_context' do
    it 'sets the current round and phase' do
      strategy.set_context(round: 1, phase: 'choose_catch', turn: 5)
      # Context is set internally, verify by logging a thought
      strategy.log_thought('test')
      expect(strategy.all_thoughts[1]).to have_key('choose_catch')
    end
  end

  describe '#log_thought' do
    context 'during choose_catch phase' do
      it 'logs thoughts organized by turn' do
        strategy.set_context(round: 1, phase: 'choose_catch', turn: 3)
        strategy.log_thought('Thinking about turn 3')

        thoughts = strategy.all_thoughts
        expect(thoughts[1]['choose_catch'][3]).to include('Thinking about turn 3')
      end
    end

    context 'during choose_partners phase' do
      it 'logs thoughts as an array' do
        strategy.set_context(round: 2, phase: 'choose_partners')
        strategy.log_thought('Choosing partners')

        thoughts = strategy.all_thoughts
        expect(thoughts[2]['choose_partners']).to include('Choosing partners')
      end
    end
  end

  describe 'abstract methods' do
    it 'requires choose_catch to be implemented' do
      expect(strategy.choose_catch(1, 1, 100, [], [], 'Partner', {})).to eq(10)
    end

    it 'requires choose_partners to be implemented' do
      choices = strategy.choose_partners(2, ['TestPlayer', 'A', 'B'], {})
      expect(choices.length).to eq(2)
    end
  end
end
