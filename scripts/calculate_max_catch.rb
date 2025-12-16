#!/usr/bin/env ruby
# typed: false
# frozen_string_literal: true

require_relative '../lib/game/pond'
require_relative '../lib/types'

puts "=" * 70
puts "Theoretical Maximum Fish Calculation"
puts "=" * 70
puts ""

# Scenario 1: Both players catch 0 (maximize growth)
puts "Scenario 1: Maximum Growth (both catch 0)"
puts "-" * 70
pond = Pond.new(GameConfig.new(min_growth_rate: 1.25, max_growth_rate: 1.25))
total_catch = 0
10.times do |turn|
  result = pond.execute_turn(0, 0)
  puts "Turn #{turn + 1}: #{result.pond_fish_before} fish → catch 0 → #{result.pond_fish_after} fish (×1.25)"
  total_catch += result.player1_catch + result.player2_catch
end
puts "Total caught: #{total_catch} fish per player"
puts "Final pond: #{pond.fish} fish (wasted potential!)"
puts ""

# Scenario 2: Greedy - catch maximum possible each turn
puts "Scenario 2: Maximum Greedy (catch 30+30 each turn)"
puts "-" * 70
pond = Pond.new(GameConfig.new(min_growth_rate: 1.25, max_growth_rate: 1.25))
total_p1 = 0
total_p2 = 0
10.times do |turn|
  result = pond.execute_turn(30, 30)
  total_p1 += result.player1_catch
  total_p2 += result.player2_catch
  if result.success
    puts "Turn #{turn + 1}: #{result.pond_fish_before} → catch 60 → #{result.pond_fish_after} fish"
  else
    puts "Turn #{turn + 1}: DEPLETED (attempted 60, pond had #{result.pond_fish_before})"
    break
  end
end
puts "Total caught: P1=#{total_p1}, P2=#{total_p2} fish"
puts ""

# Scenario 3: Intelligent cooperation - find optimal catch rate
puts "Scenario 3: Optimal Cooperation (testing different catch amounts)"
puts "-" * 70

best_catch_amount = 0
best_total = 0
best_simulation = nil

# Test different constant catch amounts
(0..30).step(1) do |catch_per_player|
  pond = Pond.new(GameConfig.new(min_growth_rate: 1.25, max_growth_rate: 1.25))
  total = 0
  turns_completed = 0
  simulation_log = []

  10.times do |turn|
    result = pond.execute_turn(catch_per_player, catch_per_player)
    total += result.player1_catch + result.player2_catch
    turns_completed += 1
    simulation_log << {
      turn: turn + 1,
      before: result.pond_fish_before,
      catch: result.player1_catch + result.player2_catch,
      after: result.pond_fish_after,
      success: result.success
    }
    break unless result.success
  end

  # Penalize if didn't complete all 10 turns
  effective_total = turns_completed == 10 ? total : total * 0.5

  if effective_total > best_total
    best_total = effective_total
    best_catch_amount = catch_per_player
    best_simulation = simulation_log
  end
end

puts "Best strategy: Each player catches #{best_catch_amount} fish per turn"
puts ""
best_simulation.each do |log|
  status = log[:success] ? "✓" : "✗"
  puts "Turn #{log[:turn]} #{status}: #{log[:before]} → catch #{log[:catch]} → #{log[:after]} fish"
end
puts ""
puts "Total caught: #{best_total.to_i} fish total (#{(best_total / 2).to_i} per player)"
puts ""

# Scenario 4: Adaptive strategy - catch more when pond is healthy
puts "Scenario 4: Adaptive Strategy (dynamic catch based on pond size)"
puts "-" * 70

pond = Pond.new(GameConfig.new(min_growth_rate: 1.25, max_growth_rate: 1.25))
total_p1 = 0
total_p2 = 0

10.times do |turn|
  # Adaptive rule: catch 15% of pond size, but never more than 20 per player
  catch_amount = [(pond.fish * 0.15).floor, 20].min

  result = pond.execute_turn(catch_amount, catch_amount)
  total_p1 += result.player1_catch
  total_p2 += result.player2_catch

  if result.success
    puts "Turn #{turn + 1}: #{result.pond_fish_before} → catch #{catch_amount * 2} (15% rule) → #{result.pond_fish_after} fish"
  else
    puts "Turn #{turn + 1}: DEPLETED"
    break
  end
end

puts ""
puts "Total caught: P1=#{total_p1}, P2=#{total_p2} fish"
puts ""

# Scenario 5: Conservative start, aggressive end
puts "Scenario 5: Conservative Start, Aggressive Finish"
puts "-" * 70

pond = Pond.new(GameConfig.new(min_growth_rate: 1.25, max_growth_rate: 1.25))
total_p1 = 0
total_p2 = 0

10.times do |turn|
  # First 7 turns: conservative (10 each)
  # Turns 8-9: medium (15 each)
  # Turn 10: take everything left
  if turn < 7
    catch_amount = 10
  elsif turn < 9
    catch_amount = 15
  else
    catch_amount = [pond.fish / 2, 30].min
  end

  result = pond.execute_turn(catch_amount, catch_amount)
  total_p1 += result.player1_catch
  total_p2 += result.player2_catch

  if result.success
    puts "Turn #{turn + 1}: #{result.pond_fish_before} → catch #{result.player1_catch + result.player2_catch} → #{result.pond_fish_after} fish"
  else
    puts "Turn #{turn + 1}: DEPLETED"
    break
  end
end

puts ""
puts "Total caught: P1=#{total_p1}, P2=#{total_p2} fish"
puts ""

# Scenario 6: With average growth rate (1.20)
puts "Scenario 6: Realistic - Using Average Growth Rate (1.20)"
puts "-" * 70

pond = Pond.new(GameConfig.new(min_growth_rate: 1.20, max_growth_rate: 1.20))
total_p1 = 0
total_p2 = 0

10.times do |turn|
  catch_amount = best_catch_amount  # Use the optimal from max growth scenario

  result = pond.execute_turn(catch_amount, catch_amount)
  total_p1 += result.player1_catch
  total_p2 += result.player2_catch

  if result.success
    puts "Turn #{turn + 1}: #{result.pond_fish_before} → catch #{result.player1_catch + result.player2_catch} → #{result.pond_fish_after} fish"
  else
    puts "Turn #{turn + 1}: DEPLETED"
    break
  end
end

puts ""
puts "Total caught: P1=#{total_p1}, P2=#{total_p2} fish"
puts ""

puts "=" * 70
puts "SUMMARY"
puts "=" * 70
puts "With MAXIMUM growth (1.25):"
puts "  Optimal catch per turn: #{best_catch_amount} fish/player"
puts "  Maximum total per player: ~#{(best_total / 2).to_i} fish"
puts ""
puts "With AVERAGE growth (1.20):"
puts "  Expected total per player: ~#{total_p1} fish"
puts ""
puts "Key insight: Cooperation allows sustaining the pond while maximizing catch!"
puts "=" * 70
