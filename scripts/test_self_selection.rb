#!/usr/bin/env ruby
# typed: false
# frozen_string_literal: true

require_relative '../lib/game/round'
require_relative '../lib/strategy/base_strategy'

# Create a strategy that tries to select itself
class SelfSelectingStrategy < BaseStrategy
  extend T::Sig

  sig do
    override.params(
      round_number: Integer,
      turn_number: Integer,
      pond_fish: Integer,
      my_history: T::Array[Integer],
      partner_history: T::Array[Integer],
      partner_name: String,
      all_players_history: T::Hash[String, PlayerHistory]
    ).returns(Integer)
  end
  def choose_catch(round_number, turn_number, pond_fish, my_history, partner_history, partner_name, all_players_history)
    5
  end

  sig do
    override.params(
      round_number: Integer,
      all_players: T::Array[String],
      all_players_history: T::Hash[String, PlayerHistory]
    ).returns([String, String])
  end
  def choose_partners(round_number, all_players, all_players_history)
    puts "  → #{@name} is attempting to select itself as both partners..."
    [@name, @name]  # Try to select self (this should be prevented)
  end
end

# Create strategies
strategies = {
  'Player_A' => SelfSelectingStrategy.new('Player_A'),
  'Player_B' => SelfSelectingStrategy.new('Player_B'),
  'Player_C' => SelfSelectingStrategy.new('Player_C'),
  'Player_D' => SelfSelectingStrategy.new('Player_D')
}

# Initialize history (need to have played round 1 first)
history = {}
strategies.each_key do |name|
  history[name] = PlayerHistory.new(
    partners: ['dummy'],
    catches: [[5, 5, 5, 5, 5, 5, 5, 5, 5, 5]],
    scores: [50]
  )
end

puts "\n🧪 Testing Self-Selection Prevention"
puts "=" * 60

result = Round.play(2, strategies, history)

puts "\n📊 Pairings for Round 2:"
all_valid = true
result.pairings.each do |pairing|
  puts "  • #{pairing.player1_name} ⟷ #{pairing.player2_name}"

  # Verify no self-pairing
  if pairing.player1_name == pairing.player2_name
    puts "    ❌ ERROR: Player paired with themselves!"
    all_valid = false
  else
    puts "    ✅ Valid pairing (not paired with self)"
  end
end

puts "\n" + "=" * 60
if all_valid
  puts "✅ SUCCESS: All players were prevented from pairing with themselves!"
else
  puts "❌ FAILURE: Some players were paired with themselves!"
  exit 1
end
