# 🏆 Tournament Guide - How to Run Real Tournaments

## For Players

### Step 1: Write Your Strategy

Create a file in the `strategies/` directory (e.g., `strategies/your_name_strategy.rb`):

```ruby
# typed: strict
# frozen_string_literal: true

require 'sorbet-runtime'
require_relative '../lib/strategy/base_strategy'

# Your strategy description
class YourNameStrategy < BaseStrategy
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
    log_thought("Your thinking process here")

    # Your logic here
    catch = 10

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
    others = all_players.reject { |p| p == name }

    # Your partner selection logic
    # Make sure to handle case with < 2 other players

    [others[0], others[1]]
  end
end
```

### Step 2: Validate Your Strategy

```bash
bin/validate strategies/your_name_strategy.rb
```

You should see:
```
✅ Validation passed! Strategy file is ready to use.
```

### Step 3: Submit

- Submit your `.rb` file to the `strategies/` folder
- Deadline: Friday 5pm (as per CLAUDE.md)

## For Tournament Organizers

### Quick Tournament (Recommended)

Run a tournament with all submitted strategies:

```bash
bin/play --tournament --rounds 6 --reports
```

This will:
- ✅ Automatically load ALL `.rb` files from `strategies/`
- ✅ Run 6 rounds (equal to number of players for fair pairing)
- ✅ Generate HTML reports for each round
- ✅ Show final winner

### Interactive Tournament (For Team Meetings)

```bash
bin/play --tournament --interactive --rounds 6 --reports
```

After each round, it pauses:
```
Round 1 complete. Press Enter to continue, 'q' to quit, or 'r' for report:
```

This allows the team to:
- Discuss surprising outcomes
- Review the HTML report together
- Analyze strategy decisions

### Advanced Options

**Specific Players Only:**
```bash
bin/play --players strategies/alice_strategy.rb,strategies/bob_strategy.rb --rounds 4 --reports
```

**More Rounds:**
```bash
bin/play --tournament --rounds 10 --reports
```

**Batch Mode (No HTML, Faster):**
```bash
bin/play --tournament --rounds 6
```

## Example Strategies

Three example user strategies are included in `strategies/`:

1. **AliceStrategy** - Cautious Follower
   - Starts conservative
   - Adjusts based on partner behavior
   - Prefers stable partners

2. **BobStrategy** - Opportunist
   - Aggressive when pond is healthy
   - Conservative when depleted
   - Chooses high-scoring partners

3. **CarolStrategy** - Grudge Holder
   - Remembers betrayers forever
   - Retaliates against greedy partners
   - Avoids known betrayers

## Tournament Day Workflow

### Monday
```bash
# Share the template and examples
cat strategies/alice_strategy.rb
```

### During the Week
Players write and test strategies:
```bash
bin/validate strategies/my_strategy.rb
bin/play --players strategies/my_strategy.rb,lib/strategy/examples/random_strategy.rb --rounds 2
```

### Friday 5pm
Collect all strategy files in `strategies/` folder

### Team Meeting
```bash
# Run the tournament
bin/play --tournament --interactive --rounds 6 --reports

# After each round:
# 1. Discuss the pairings
# 2. Check who cooperated/betrayed
# 3. Open the HTML report
# 4. Review "Strategy Thoughts" section
# 5. Press Enter to continue
```

## What the HTML Reports Show

Open `reports/round_N.html` to see:

### 📊 Round Summary
- Number of pairings
- Mutual first choices count

### 🤝 Pairings
- Turn-by-turn fish catches
- Success/overfishing indicators
- Pond state changes
- Final scores per pairing

### 🏆 Leaderboard
- Current rankings with medals
- Total fish count

### 📈 Strategy Insights
- **Cooperation Rate**: % of successful turns
- **Pond Depletion Rate**: % of ponds that collapsed
- **Most Greedy**: Player with highest average catch
- **Most Conservative**: Player with lowest average catch

### 💭 Strategy Thoughts ⭐
This is the most valuable section for discussion!

Shows each player's complete thinking process:
- "Pond has 100 fish"
- "Partner is trustworthy, cooperating: 8 fish"
- "AliceStrategy BETRAYED! Retaliating: 30 fish"
- "Choosing stable partners"

Perfect for:
- Understanding why strategies made certain decisions
- Debugging your own strategy
- Learning game theory concepts
- Post-tournament analysis

## Tips for Success

1. **Test Early**: Don't wait until Friday to test your strategy
2. **Use log_thought**: Make your thinking visible in reports
3. **Handle Edge Cases**: What if pond has only 5 fish? What if only 2 players total?
4. **Study Examples**: The 3 example user strategies show different approaches
5. **Think Long-term**: Short-term greed may cost you partnerships later

## Troubleshooting

**"No strategy files found"**
```bash
# Make sure files are in strategies/ folder
ls strategies/

# Should see: alice_strategy.rb, bob_strategy.rb, etc.
```

**"No strategy class found"**
- Make sure your class inherits from `BaseStrategy`
- Check that class name matches file name pattern

**Validation fails**
```bash
bin/validate strategies/my_strategy.rb
# Read the error messages carefully
# Common issues: missing methods, wrong return types
```

**Game crashes**
- Check for divide-by-zero in choose_partners
- Make sure you return exactly 2 different partner names
- Handle empty history arrays

## Have Fun! 🎉

Remember: There's no single "optimal" strategy. Success depends on:
- Predicting opponents
- Building trust
- Reputation management
- Balancing short-term vs long-term goals

May the best strategy win! 🏆
