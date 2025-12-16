#!/usr/bin/env ruby
# typed: false
# frozen_string_literal: true

require_relative '../lib/game/pond'
require_relative '../lib/types'

puts "=" * 70
puts "Finding Optimal Cooperative Strategy"
puts "=" * 70
puts ""

def simulate_strategy(catches_per_turn, growth_rate)
  pond = Pond.new(GameConfig.new(min_growth_rate: growth_rate, max_growth_rate: growth_rate))
  total_p1 = 0
  total_p2 = 0

  catches_per_turn.each_with_index do |catch_amount, turn|
    result = pond.execute_turn(catch_amount, catch_amount)
    total_p1 += result.player1_catch
    total_p2 += result.player2_catch

    return nil unless result.success  # Failed to complete all 10 turns
  end

  total_p1
end

# Test with maximum growth (1.25)
puts "Testing with MAXIMUM growth rate (1.25)..."
puts "-" * 70

best_strategy = nil
best_total = 0

# Try different strategies
strategies = []

# Strategy 1: Constant catch
(5..15).each do |catch|
  strategies << Array.new(10, catch)
end

# Strategy 2: Linear ramp up
(5..12).each do |start_catch|
  (1..3).each do |increment|
    strategy = (0..9).map { |turn| [start_catch + turn * increment, 30].min }
    strategies << strategy
  end
end

# Strategy 3: Conservative start, aggressive end
[5, 8, 10].each do |early|
  [12, 15, 18].each do |mid|
    [20, 25, 30].each do |late|
      strategy = Array.new(5, early) + Array.new(3, mid) + Array.new(2, late)
      strategies << strategy
    end
  end
end

# Strategy 4: Exponential growth
[1.05, 1.1, 1.15].each do |factor|
  base = 8
  strategy = (0..9).map { |turn| [(base * (factor ** turn)).round, 30].min }
  strategies << strategy
end

strategies.uniq.each do |strategy|
  total = simulate_strategy(strategy, 1.25)
  next if total.nil?

  if total > best_total
    best_total = total
    best_strategy = strategy
  end
end

puts "Best strategy found (max growth 1.25):"
pond = Pond.new(GameConfig.new(min_growth_rate: 1.25, max_growth_rate: 1.25))
total = 0
best_strategy.each_with_index do |catch, turn|
  result = pond.execute_turn(catch, catch)
  total += result.player1_catch + result.player2_catch
  puts "Turn #{turn + 1}: #{result.pond_fish_before} → catch #{catch * 2} (#{catch}/player) → #{result.pond_fish_after} fish"
end
puts ""
puts "Total per player: #{best_total} fish"
puts "Strategy pattern: #{best_strategy.inspect}"
puts ""

# Now test the same strategy with average growth
puts "Testing same strategy with AVERAGE growth rate (1.20)..."
puts "-" * 70

pond = Pond.new(GameConfig.new(min_growth_rate: 1.20, max_growth_rate: 1.20))
total_avg = 0
best_strategy.each_with_index do |catch, turn|
  result = pond.execute_turn(catch, catch)
  total_avg += result.player1_catch
  if result.success
    puts "Turn #{turn + 1}: #{result.pond_fish_before} → catch #{catch * 2} (#{catch}/player) → #{result.pond_fish_after} fish"
  else
    puts "Turn #{turn + 1}: DEPLETED"
    break
  end
end
puts ""
puts "Total per player: #{total_avg} fish"
puts ""

# Test with minimum growth
puts "Testing same strategy with MINIMUM growth rate (1.15)..."
puts "-" * 70

pond = Pond.new(GameConfig.new(min_growth_rate: 1.15, max_growth_rate: 1.15))
total_min = 0
best_strategy.each_with_index do |catch, turn|
  result = pond.execute_turn(catch, catch)
  total_min += result.player1_catch
  if result.success
    puts "Turn #{turn + 1}: #{result.pond_fish_before} → catch #{catch * 2} (#{catch}/player) → #{result.pond_fish_after} fish"
  else
    puts "Turn #{turn + 1}: DEPLETED"
    break
  end
end
puts ""
puts "Total per player: #{total_min} fish"
puts ""

# Run Monte Carlo with random growth
puts "Monte Carlo simulation (100 runs with random growth 1.15-1.25)..."
puts "-" * 70

results = []
100.times do
  pond = Pond.new(GameConfig.new)  # Uses random growth
  total = 0
  success = true

  best_strategy.each do |catch|
    result = pond.execute_turn(catch, catch)
    total += result.player1_catch
    unless result.success
      success = false
      break
    end
  end

  results << total if success
end

if results.any?
  avg = results.sum / results.size.to_f
  min = results.min
  max = results.max
  success_rate = (results.size / 100.0 * 100).round(1)

  puts "Success rate: #{success_rate}% (#{results.size}/100 completed all 10 turns)"
  puts "Average: #{avg.round(1)} fish/player"
  puts "Min: #{min} fish/player"
  puts "Max: #{max} fish/player"
  puts "Std dev: #{Math.sqrt(results.map { |x| (x - avg) ** 2 }.sum / results.size).round(2)}"
else
  puts "Strategy failed in all random simulations!"
end

puts ""
puts "=" * 70
puts "FINAL ANSWER"
puts "=" * 70
puts "Theoretical maximum with perfect cooperation:"
puts "  Best case (1.25 growth): #{best_total} fish/player"
puts "  Average case (1.20 growth): #{total_avg} fish/player"
puts "  Worst case (1.15 growth): #{total_min} fish/player"
puts "  Random growth (1.15-1.25): ~#{results.any? ? (results.sum / results.size.to_f).round(0) : 'N/A'} fish/player"
puts ""
puts "Optimal strategy: #{best_strategy.inspect}"
puts "=" * 70
