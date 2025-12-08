# typed: strict
# frozen_string_literal: true

require 'sorbet-runtime'
require_relative '../base_strategy'

# Conservative strategy: Always catches 3 fish, prefers partners with low average catches
class ConservativeStrategy < BaseStrategy
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

    # Always conservative - catch only 3 fish
    catch = 3

    log_thought("Catching #{catch} fish (conservative approach)")

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
    log_thought("Looking for conservative partners")

    others = all_players.reject { |p| p == name }

    # Calculate average catch per turn for each player
    player_averages = others.map do |player_name|
      history = all_players_history[player_name]
      if history && !history.catches.empty?
        total_catches = history.catches.flatten.sum
        total_turns = history.catches.flatten.length
        avg = total_turns > 0 ? total_catches.to_f / total_turns : 0.0
        [player_name, avg]
      else
        [player_name, 0.0]
      end
    end.to_h

    # Prefer players with lowest average catches (most conservative)
    sorted_players = player_averages.sort_by { |_name, avg| avg }.map(&:first)

    first_choice = T.must(sorted_players[0])
    second_choice = T.must(sorted_players[1])

    log_thought("Selected #{first_choice} (avg: #{player_averages[first_choice]&.round(1)}) and #{second_choice} (avg: #{player_averages[second_choice]&.round(1)})")

    [first_choice, second_choice]
  end
end
