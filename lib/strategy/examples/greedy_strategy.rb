# typed: strict
# frozen_string_literal: true

require 'sorbet-runtime'
require_relative '../base_strategy'

# Greedy strategy: Catches maximum possible without exceeding pond, prefers high-scoring partners
class GreedyStrategy < BaseStrategy
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

    # Try to catch as much as possible, but leave some for partner
    # Assume partner will take around 10-15 fish on average
    estimated_partner_catch = 12
    safe_catch = [pond_fish - estimated_partner_catch, 30].min
    catch = [safe_catch, 0].max

    log_thought("Catching #{catch} fish (greedy but calculated)")

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
    log_thought("Looking for high-scoring partners")

    others = all_players.reject { |p| p == name }

    # Calculate total scores for each player
    player_scores = others.map do |player_name|
      history = all_players_history[player_name]
      total_score = history && !history.scores.empty? ? history.scores.sum : 0
      [player_name, total_score]
    end.to_h

    # Prefer players with highest scores (most successful)
    sorted_players = player_scores.sort_by { |_name, score| -score }.map(&:first)

    first_choice = T.must(sorted_players[0])
    second_choice = T.must(sorted_players[1])

    log_thought("Selected #{first_choice} (score: #{player_scores[first_choice]}) and #{second_choice} (score: #{player_scores[second_choice]})")

    [first_choice, second_choice]
  end
end
