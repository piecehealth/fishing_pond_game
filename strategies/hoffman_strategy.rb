# typed: strict
# frozen_string_literal: true

require 'sorbet-runtime'
require_relative '../lib/strategy/base_strategy'

# Carol's Strategy: The Grudge Holder
# If partner ever betrays (catches too much), remember forever and retaliate
class HoffmanStrategy < BaseStrategy
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
      # First turn: conservative start
      catch = 5
      log_thought("First turn, playing it safe: #{catch} fish")
    elsif turn_number >= 9
      catch = [[30, (pond_fish - 10)].min, pond_fish/2].max
    elsif pond_fish >= 30 * (11 - turn_number)
      catch = [[30, (pond_fish - 10)].min, pond_fish/2].max
    else
      partner_conservative = true
      # Follow partner but be slightly more conservative
      partner_history.each do |catch|
        if catch > 20
          partner_conservative = false
          break
        end
      end

      catch = partner_conservative ? 5 : [[30, (pond_fish - 10)].min, pond_fish/2].max
      partner_avg = partner_history.empty? ? 0 : partner_history.sum.to_f / partner_history.length
      log_thought("Partner avg #{partner_avg.round(1)}, following conservatively: #{catch} fish")
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
    log_thought("Choosing stable partners")

    others = all_players.reject { |p| p == name }

    player_stability = others.map do |player_name|
      history = all_players_history[player_name]
      if history && history.catches.length > 0
        catches = history.catches.flatten
        if catches.length > 0
        avg = catches.sum.to_f / catches.length
        [player_name, avg]
        else
        [player_name, 100]
        end
      else
        [player_name, 100]
      end
    end.to_h

    sorted = player_stability.sort_by { |_, score| score }.map(&:first)

    # Handle case with fewer than 2 other players
    if sorted.length < 2
      if others.length >= 2 - sorted.length
        # We have enough others to fill the remaining slots
        sorted += T.cast(others.sample(2 - sorted.length), T::Array[String])
      else
        # Not enough others, just pad with empty strings or duplicate existing
        padding_count = 2 - sorted.length
        sorted += Array.new(padding_count, "")
      end
    end

    [T.must(sorted[0]), T.must(sorted[1])]
  end
end