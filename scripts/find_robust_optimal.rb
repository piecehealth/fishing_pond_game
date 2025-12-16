#!/usr/bin/env ruby
# typed: false
# frozen_string_literal: true

require_relative '../lib/game/pond'
require_relative '../lib/types'

puts "=" * 70
puts "Finding ROBUST Optimal Strategy (works with random growth)"
puts "=" * 70
puts ""

def monte_carlo_test(strategy, runs = 100)
  results = []
  runs.times do
    pond = Pond.new(GameConfig.new)  # Random growth 1.15-1.25
    total = 0
    success = true

    strategy.each do |catch|
      result = pond.execute_turn(catch, catch)
      total += result.player1_catch
      unless result.success
        success = false
        break
      end
    end

    results << total if success
  end

  {
    success_rate: results.size / runs.to_f,
    avg: results.any? ? results.sum / results.size.to_f : 0,
    min: results.min || 0,
    max: results.max || 0,
    results: results
  }
end

# Generate conservative strategies
strategies = []

# Type 1: Constant catch
(3..12).each do |catch|
  strategies << { name: "Constant #{catch}", pattern: Array.new(10, catch) }
end

# Type 2: Gentle ramp
[3, 4, 5, 6, 7, 8].each do |start|
  [0.5, 1, 1.5, 2].each do |increment|
    pattern = (0..9).map { |turn| [start + (turn * increment).round, 25].min }
    strategies << { name: "Ramp #{start}+#{increment}", pattern: pattern }
  end
end

# Type 3: Conservative with final burst
[5, 6, 7, 8].each do |early|
  [10, 12, 15].each do |late|
    pattern = Array.new(7, early) + Array.new(2, late) + [20]
    strategies << { name: "Conservative #{early}, finish #{late}-20", pattern: pattern }
  end
end

# Type 4: Two-phase
[4, 5, 6, 7, 8].each do |phase1|
  [10, 12, 15, 18].each do |phase2|
    pattern = Array.new(6, phase1) + Array.new(4, phase2)
    strategies << { name: "Two-phase #{phase1}→#{phase2}", pattern: pattern }
  end
end

puts "Testing #{strategies.size} strategies with 100 Monte Carlo runs each..."
puts ""

best_strategies = []

strategies.each do |strat|
  result = monte_carlo_test(strat[:pattern])

  # Only consider strategies with >90% success rate
  next unless result[:success_rate] >= 0.9

  best_strategies << {
    name: strat[:name],
    pattern: strat[:pattern],
    success_rate: result[:success_rate],
    avg: result[:avg],
    min: result[:min],
    max: result[:max]
  }
end

# Sort by average catch
best_strategies.sort_by! { |s| -s[:avg] }

puts "Top 10 ROBUST strategies (>90% success rate):"
puts "-" * 70
best_strategies.first(10).each_with_index do |strat, idx|
  puts "#{idx + 1}. #{strat[:name]}"
  puts "   Pattern: #{strat[:pattern].inspect}"
  puts "   Success: #{(strat[:success_rate] * 100).round(1)}%"
  puts "   Avg: #{strat[:avg].round(1)} fish/player"
  puts "   Range: #{strat[:min]}-#{strat[:max]} fish"
  puts ""
end

if best_strategies.any?
  best = best_strategies.first

  puts "=" * 70
  puts "BEST ROBUST STRATEGY"
  puts "=" * 70
  puts "Name: #{best[:name]}"
  puts "Pattern: #{best[:pattern].inspect}"
  puts "Success rate: #{(best[:success_rate] * 100).round(1)}%"
  puts ""

  # Detailed simulation
  puts "Detailed breakdown with different growth rates:"
  puts "-" * 70

  [1.15, 1.20, 1.25].each do |growth|
    puts ""
    puts "Growth rate: #{(growth * 100 - 100).round(0)}% (×#{growth})"
    pond = Pond.new(GameConfig.new(min_growth_rate: growth, max_growth_rate: growth))
    total = 0

    best[:pattern].each_with_index do |catch, turn|
      result = pond.execute_turn(catch, catch)
      total += result.player1_catch
      if result.success
        puts "  Turn #{turn + 1}: #{result.pond_fish_before} → catch #{catch * 2} → #{result.pond_fish_after} fish"
      else
        puts "  Turn #{turn + 1}: DEPLETED"
        break
      end
    end
    puts "  Total: #{total} fish/player"
  end

  puts ""
  puts "=" * 70
  puts "ANSWER: With perfect cooperation and random growth (15%-25%)"
  puts "Expected catch: ~#{best[:avg].round(0)} fish/player per round"
  puts "Range: #{best[:min]}-#{best[:max]} fish/player"
  puts "=" * 70
end
