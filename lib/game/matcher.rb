# typed: strict
# frozen_string_literal: true

require 'sorbet-runtime'
require_relative '../types'

class Matcher
  extend T::Sig

  sig do
    params(
      players: T::Array[String]
    ).returns(T::Array[Pairing])
  end
  def self.match_round_1(players)
    shuffled = players.shuffle
    pairings = []

    shuffled.each_slice(2) do |pair|
      if pair.length == 2
        pairings << Pairing.new(
          player1_name: T.must(pair[0]),
          player2_name: T.must(pair[1]),
          was_mutual_first_choice: false
        )
      end
    end

    pairings
  end

  sig do
    params(
      players: T::Array[String],
      preferences: T::Hash[String, [String, String]]
    ).returns(T::Array[Pairing])
  end
  def self.match_with_preferences(players, preferences)
    matched = T.let(Set.new, T::Set[String])
    pairings = T.let([], T::Array[Pairing])

    # Find mutual first-choice pairs
    players.each do |player|
      next if matched.include?(player)

      prefs = preferences[player]
      next if prefs.nil?

      first_choice = prefs[0]
      next if first_choice.nil?
      next if matched.include?(first_choice)

      # Check if first_choice also picked player as #1
      partner_prefs = preferences[first_choice]
      if partner_prefs && partner_prefs[0] == player
        pairings << Pairing.new(
          player1_name: player,
          player2_name: first_choice,
          was_mutual_first_choice: true
        )
        matched.add(player)
        matched.add(first_choice)
      end
    end

    # Randomly pair remaining players
    remaining = players.reject { |p| matched.include?(p) }.shuffle
    remaining.each_slice(2) do |pair|
      if pair.length == 2
        pairings << Pairing.new(
          player1_name: T.must(pair[0]),
          player2_name: T.must(pair[1]),
          was_mutual_first_choice: false
        )
      end
    end

    pairings
  end
end
