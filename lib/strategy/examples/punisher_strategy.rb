# typed: strict
# frozen_string_literal: true

require 'sorbet-runtime'
require_relative '../base_strategy'

# Punisher strategy: Catches 4 fish normally, but catches 30 if partner ever exceeded 10
class PunisherStrategy < BaseStrategy
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

    # Check if partner ever exceeded 10 fish
    if partner_history.any? { |catch| catch > 10 }
      catch = 30
      log_thought("Partner was greedy (caught >10), PUNISHING with #{catch} fish!")
    else
      catch = 4
      log_thought("Partner is cooperative, catching #{catch} fish")
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
    log_thought("Looking for non-greedy partners")

    others = all_players.reject { |p| p == name }

    # Prefer players who never caught more than 10 fish in a single turn
    player_greediness = others.map do |player_name|
      history = all_players_history[player_name]
      if history && !history.catches.empty?
        max_catch = history.catches.flatten.max || 0
        # Lower max catch = better partner
        [player_name, max_catch]
      else
        [player_name, 0]
      end
    end.to_h

    sorted_players = player_greediness.sort_by { |_name, max_catch| max_catch }.map(&:first)

    first_choice = T.must(sorted_players[0])
    second_choice = T.must(sorted_players[1])

    log_thought("Selected #{first_choice} (max catch: #{player_greediness[first_choice]}) and #{second_choice} (max catch: #{player_greediness[second_choice]})")

    [first_choice, second_choice]
  end
end
