# typed: strict
# frozen_string_literal: true

require 'sorbet-runtime'
require_relative '../base_strategy'

# Adaptive strategy: Adjusts based on pond health (80+ fish = aggressive, <30 = conservative)
class AdaptiveStrategy < BaseStrategy
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
    log_thought("Pond has #{pond_fish} fish")

    catch = if pond_fish >= 80
              # Pond is healthy, be aggressive
              aggressive_catch = [20, pond_fish / 3].min
              log_thought("Pond is healthy (>=80), being aggressive: #{aggressive_catch} fish")
              aggressive_catch
            elsif pond_fish >= 30
              # Moderate pond health
              moderate_catch = [10, pond_fish / 4].min
              log_thought("Pond is moderate (30-80), moderate catch: #{moderate_catch} fish")
              moderate_catch
            else
              # Pond is struggling, be very conservative
              conservative_catch = [3, pond_fish / 5].min
              log_thought("Pond is struggling (<30), being conservative: #{conservative_catch} fish")
              conservative_catch
            end

    catch
  end

  sig do
    override.params(
      round_number: Integer,
      all_players: T::Array[String],
      all_players_history: T::Hash[String, PlayerHistory]
    ).returns([String, String])
  end
  def choose_partners(round_number, all_players, all_players_history)
    log_thought("Looking for balanced partners")

    others = all_players.reject { |p| p == name }

    # Prefer players who show adaptive behavior (varied catches based on circumstances)
    player_adaptiveness = others.map do |player_name|
      history = all_players_history[player_name]
      if history && history.catches.length > 0
        catches = history.catches.flatten
        if catches.length > 3
          # Calculate variance as a measure of adaptiveness
          mean = catches.sum.to_f / catches.length
          variance = catches.sum { |c| (c - mean) ** 2 } / catches.length
          [player_name, variance]
        else
          [player_name, 0.0]
        end
      else
        [player_name, 0.0]
      end
    end.to_h

    # Prefer moderate variance (some adaptation but not erratic)
    sorted_players = player_adaptiveness.sort_by { |_name, var| -(var - 25).abs }.map(&:first)

    first_choice = T.must(sorted_players[0])
    second_choice = T.must(sorted_players[1])

    log_thought("Selected #{first_choice} and #{second_choice} (adaptive players)")

    [first_choice, second_choice]
  end
end
