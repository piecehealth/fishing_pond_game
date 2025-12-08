# typed: false
# frozen_string_literal: true

require 'fileutils'
require_relative '../lib/report_generator'
require_relative '../lib/game/round'
require_relative '../lib/strategy/examples/conservative_strategy'
require_relative '../lib/strategy/examples/greedy_strategy'

RSpec.describe ReportGenerator do
  let(:strategies) do
    {
      'Alice' => ConservativeStrategy.new('Alice'),
      'Bob' => GreedyStrategy.new('Bob')
    }
  end

  let(:all_players_history) do
    {
      'Alice' => PlayerHistory.new(
        partners: ['Bob'],
        catches: [[3, 3, 3, 3, 3, 3, 3, 3, 3, 3]],
        scores: [30]
      ),
      'Bob' => PlayerHistory.new(
        partners: ['Alice'],
        catches: [[10, 10, 10, 10, 10, 10, 10, 10, 10, 10]],
        scores: [100]
      )
    }
  end

  let(:round_result) do
    Round.play(1, strategies, {
      'Alice' => PlayerHistory.new(partners: [], catches: [], scores: []),
      'Bob' => PlayerHistory.new(partners: [], catches: [], scores: [])
    })
  end

  let(:temp_output_path) { 'spec/tmp/test_report.html' }

  before do
    FileUtils.mkdir_p('spec/tmp')
  end

  after do
    FileUtils.rm_f(temp_output_path)
  end

  describe '.generate_round_report' do
    it 'creates an HTML file' do
      ReportGenerator.generate_round_report(round_result, all_players_history, temp_output_path)

      expect(File.exist?(temp_output_path)).to be true
    end

    it 'generates valid HTML' do
      ReportGenerator.generate_round_report(round_result, all_players_history, temp_output_path)

      content = File.read(temp_output_path)
      expect(content).to include('<!DOCTYPE html>')
      expect(content).to include('<html')
      expect(content).to include('</html>')
    end

    it 'includes round number in title' do
      ReportGenerator.generate_round_report(round_result, all_players_history, temp_output_path)

      content = File.read(temp_output_path)
      expect(content).to include("Round #{round_result.round_number}")
    end

    it 'includes player names' do
      ReportGenerator.generate_round_report(round_result, all_players_history, temp_output_path)

      content = File.read(temp_output_path)
      expect(content).to include('Alice')
      expect(content).to include('Bob')
    end

    it 'includes pairing information' do
      ReportGenerator.generate_round_report(round_result, all_players_history, temp_output_path)

      content = File.read(temp_output_path)
      expect(content).to include('Pairings')
      expect(content).to match(/Alice.*vs.*Bob|Bob.*vs.*Alice/)
    end

    it 'includes turn-by-turn results' do
      ReportGenerator.generate_round_report(round_result, all_players_history, temp_output_path)

      content = File.read(temp_output_path)
      expect(content).to include('Turn')
      expect(content).to include('Pond Fish')
      expect(content).to include('Catch')
    end

    it 'includes leaderboard' do
      ReportGenerator.generate_round_report(round_result, all_players_history, temp_output_path)

      content = File.read(temp_output_path)
      expect(content).to include('Leaderboard')
      expect(content).to include('Total Score')
    end

    it 'includes strategy insights' do
      ReportGenerator.generate_round_report(round_result, all_players_history, temp_output_path)

      content = File.read(temp_output_path)
      expect(content).to include('Strategy Insights')
      expect(content).to include('Cooperation Rate')
    end

    it 'includes CSS styling' do
      ReportGenerator.generate_round_report(round_result, all_players_history, temp_output_path)

      content = File.read(temp_output_path)
      expect(content).to include('<style>')
      expect(content).to include('</style>')
    end

    context 'with strategy thoughts' do
      it 'includes strategy thoughts section when strategies are provided' do
        ReportGenerator.generate_round_report(round_result, all_players_history, temp_output_path, strategies)

        content = File.read(temp_output_path)
        expect(content).to include('Strategy Thoughts')
        expect(content).to include('Phase/Turn')
        expect(content).to include('<div class="thoughts">')
      end

      it 'includes player names in thoughts section' do
        ReportGenerator.generate_round_report(round_result, all_players_history, temp_output_path, strategies)

        content = File.read(temp_output_path)
        expect(content).to include('Alice')
        expect(content).to include('Bob')
      end

      it 'does not include thoughts section when strategies not provided' do
        ReportGenerator.generate_round_report(round_result, all_players_history, temp_output_path, nil)

        content = File.read(temp_output_path)
        expect(content).not_to include('Strategy Thoughts')
      end
    end
  end
end
