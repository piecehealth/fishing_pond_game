# typed: strict
# frozen_string_literal: true

require 'sorbet-runtime'
require_relative '../types'
require_relative '../strategy/base_strategy'
require_relative 'pond'
require_relative 'matcher'

class PairingResult < T::Struct
  const :player1_name, String
  const :player2_name, String
  const :player1_catches, T::Array[Integer]
  const :player2_catches, T::Array[Integer]
  const :turn_results, T::Array[TurnResult]
  const :player1_total, Integer
  const :player2_total, Integer
end

class RoundResult < T::Struct
  const :round_number, Integer
  const :pairings, T::Array[Pairing]
  const :pairing_results, T::Hash[String, PairingResult]
end

class Round
  extend T::Sig

  sig do
    params(
      round_number: Integer,
      strategies: T::Hash[String, BaseStrategy],
      all_players_history: T::Hash[String, PlayerHistory],
      config: GameConfig
    ).returns(RoundResult)
  end
  def self.play(round_number, strategies, all_players_history, config = GameConfig.new)
    players = strategies.keys

    # Get pairings
    pairings = if round_number == 1
                 Matcher.match_round_1(players)
               else
                 preferences = collect_preferences(round_number, strategies, players, all_players_history)
                 Matcher.match_with_preferences(players, preferences)
               end

    # Play each pairing
    pairing_results = {}
    pairings.each do |pairing|
      result = play_pairing(
        round_number,
        pairing,
        strategies,
        all_players_history,
        config
      )
      key = "#{pairing.player1_name}_vs_#{pairing.player2_name}"
      pairing_results[key] = result
    end

    RoundResult.new(
      round_number: round_number,
      pairings: pairings,
      pairing_results: pairing_results
    )
  end

  sig do
    params(
      round_number: Integer,
      strategies: T::Hash[String, BaseStrategy],
      players: T::Array[String],
      all_players_history: T::Hash[String, PlayerHistory]
    ).returns(T::Hash[String, [String, String]])
  end
  private_class_method def self.collect_preferences(round_number, strategies, players, all_players_history)
    preferences = {}
    strategies.each do |name, strategy|
      strategy.set_context(round: round_number, phase: "choose_partners")
      choices = strategy.choose_partners(round_number, players, all_players_history)
      preferences[name] = choices
    end
    preferences
  end

  sig do
    params(
      round_number: Integer,
      pairing: Pairing,
      strategies: T::Hash[String, BaseStrategy],
      all_players_history: T::Hash[String, PlayerHistory],
      config: GameConfig
    ).returns(PairingResult)
  end
  private_class_method def self.play_pairing(round_number, pairing, strategies, all_players_history, config)
    player1_name = pairing.player1_name
    player2_name = pairing.player2_name

    strategy1 = T.must(strategies[player1_name])
    strategy2 = T.must(strategies[player2_name])

    pond = Pond.new(config)
    player1_catches = []
    player2_catches = []
    turn_results = []

    config.turns_per_pairing.times do |turn_idx|
      break if pond.depleted?

      turn_number = turn_idx + 1

      strategy1.set_context(round: round_number, turn: turn_number, phase: "choose_catch")
      catch1 = strategy1.choose_catch(
        round_number,
        turn_number,
        pond.fish,
        player1_catches,
        player2_catches,
        player2_name,
        all_players_history
      )

      strategy2.set_context(round: round_number, turn: turn_number, phase: "choose_catch")
      catch2 = strategy2.choose_catch(
        round_number,
        turn_number,
        pond.fish,
        player2_catches,
        player1_catches,
        player1_name,
        all_players_history
      )

      result = pond.execute_turn(catch1, catch2)
      turn_results << result

      if result.success
        player1_catches << result.player1_catch
        player2_catches << result.player2_catch
      else
        player1_catches << 0
        player2_catches << 0
      end
    end

    # Fill remaining turns with 0 if pond depleted early
    while player1_catches.length < config.turns_per_pairing
      player1_catches << 0
      player2_catches << 0
    end

    PairingResult.new(
      player1_name: player1_name,
      player2_name: player2_name,
      player1_catches: player1_catches,
      player2_catches: player2_catches,
      turn_results: turn_results,
      player1_total: player1_catches.sum,
      player2_total: player2_catches.sum
    )
  end
end
