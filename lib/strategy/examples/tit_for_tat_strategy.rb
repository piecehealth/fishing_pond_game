# typed: strict
# frozen_string_literal: true

require 'sorbet-runtime'
require_relative '../base_strategy'

# Tit-for-Tat strategy: Mirrors partner's previous catch
class TitForTatStrategy < BaseStrategy
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

    if partner_history.empty?
      # First turn: start with cooperation (moderate catch)
      catch = 5
      log_thought("First turn, starting with cooperation: #{catch} fish")
    else
      # Mirror partner's previous catch
      catch = T.must(partner_history.last)
      log_thought("Mirroring partner's previous catch: #{catch} fish")
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
    log_thought("Looking for cooperative partners")

    others = all_players.reject { |p| p == name }

    # Prefer players who have been most cooperative (moderate catches)
    player_cooperation = others.map do |player_name|
      history = all_players_history[player_name]
      if history && !history.catches.empty?
        catches = history.catches.flatten
        # Ideal cooperation is around 5-10 fish per turn
        # Calculate how close to this ideal each player is
        cooperation_score = catches.sum { |c| -(c - 7.5).abs }
        [player_name, cooperation_score]
      else
        [player_name, 0.0]
      end
    end.to_h

    sorted_players = player_cooperation.sort_by { |_name, score| -score }.map(&:first)

    first_choice = T.must(sorted_players[0])
    second_choice = T.must(sorted_players[1])

    log_thought("Selected #{first_choice} and #{second_choice} (most cooperative)")

    [first_choice, second_choice]
  end
end
