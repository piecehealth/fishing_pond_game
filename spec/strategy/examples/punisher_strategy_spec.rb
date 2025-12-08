# typed: false
# frozen_string_literal: true

require_relative '../../../lib/strategy/examples/punisher_strategy'

RSpec.describe PunisherStrategy do
  let(:strategy) { PunisherStrategy.new('Punisher') }
  let(:empty_history) { {} }

  describe '#choose_catch' do
    context 'when partner is cooperative (never exceeded 10)' do
      it 'catches 4 fish' do
        catch = strategy.choose_catch(1, 1, 100, [], [], 'Partner', empty_history)
        expect(catch).to eq(4)
      end

      it 'continues catching 4 fish' do
        catch = strategy.choose_catch(1, 3, 80, [4, 4], [5, 8], 'Partner', empty_history)
        expect(catch).to eq(4)
      end
    end

    context 'when partner exceeded 10 fish' do
      it 'punishes by catching 30 fish' do
        catch = strategy.choose_catch(1, 2, 90, [4], [15], 'Partner', empty_history)
        expect(catch).to eq(30)
      end

      it 'continues punishing in subsequent turns' do
        catch = strategy.choose_catch(1, 5, 50, [4, 30, 30, 30], [15, 5, 5, 5], 'Partner', empty_history)
        expect(catch).to eq(30)
      end

      it 'punishes even if partner only exceeded 10 once' do
        # Partner was greedy on turn 2 (caught 20), then became cooperative
        catch = strategy.choose_catch(1, 4, 60, [4, 30, 30], [10, 20, 5], 'Partner', empty_history)
        expect(catch).to eq(30)
      end
    end

    context 'boundary case' do
      it 'does not punish for exactly 10 fish' do
        catch = strategy.choose_catch(1, 2, 90, [4], [10], 'Partner', empty_history)
        expect(catch).to eq(4)
      end

      it 'punishes for 11 fish' do
        catch = strategy.choose_catch(1, 2, 90, [4], [11], 'Partner', empty_history)
        expect(catch).to eq(30)
      end
    end
  end

  describe '#choose_partners' do
    let(:history_with_max_catches) do
      {
        'Punisher' => PlayerHistory.new(
          partners: ['Player1'],
          catches: [[4, 4, 4, 4, 4, 4, 4, 4, 4, 4]],
          scores: [40]
        ),
        'Player1' => PlayerHistory.new(
          partners: ['Punisher'],
          catches: [[5, 5, 5, 5, 5, 5, 5, 5, 5, 5]],  # Max catch: 5
          scores: [50]
        ),
        'Player2' => PlayerHistory.new(
          partners: ['Player3'],
          catches: [[8, 8, 8, 8, 8, 8, 8, 8, 8, 8]],  # Max catch: 8
          scores: [80]
        ),
        'Player3' => PlayerHistory.new(
          partners: ['Player2'],
          catches: [[15, 10, 10, 10, 10, 10, 10, 10, 10, 10]],  # Max catch: 15 (greedy!)
          scores: [105]
        )
      }
    end

    it 'prefers players who never exceeded 10 fish' do
      players = ['Punisher', 'Player1', 'Player2', 'Player3']
      choices = strategy.choose_partners(2, players, history_with_max_catches)

      # Player1 (max 5) and Player2 (max 8) never exceeded 10
      # Player3 (max 15) should be avoided
      expect(choices).to contain_exactly('Player1', 'Player2')
    end

    it 'prefers players with lower max catches' do
      players = ['Punisher', 'Player1', 'Player2', 'Player3']
      choices = strategy.choose_partners(2, players, history_with_max_catches)

      # First choice should be Player1 (max 5), second should be Player2 (max 8)
      expect(choices[0]).to eq('Player1')
      expect(choices[1]).to eq('Player2')
    end

    it 'returns two different players' do
      players = ['Punisher', 'Player1', 'Player2', 'Player3']
      choices = strategy.choose_partners(2, players, history_with_max_catches)

      expect(choices[0]).not_to eq(choices[1])
      expect(choices).not_to include('Punisher')
    end
  end
end
