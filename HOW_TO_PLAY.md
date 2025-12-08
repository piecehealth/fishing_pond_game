# 🎮 How to Play - Quick Answer

## For Real Tournament Play

### Players Submit Strategies

1. **Write your strategy** in `strategies/your_name_strategy.rb`
2. **Validate** it: `bin/validate strategies/your_name_strategy.rb`
3. **Submit** by Friday 5pm

### Tournament Organizer Runs

```bash
bin/play --tournament --rounds 6 --reports
```

**That's it!** ✅

This automatically:
- Loads ALL strategies from `strategies/` folder
- Runs the tournament
- Generates HTML reports
- Shows winner

## What Happens

```
🔍 Loading strategies from strategies/ directory...
  ✓ AliceStrategy
  ✓ BobStrategy  
  ✓ CarolStrategy
  ✓ DaveStrategy
  ✓ EveStrategy
  ✓ FrankStrategy
📊 Loaded 6 strategies

🎣 Fishing Pond Game
============================================================
Players: AliceStrategy, BobStrategy, CarolStrategy...
Rounds: 6
Mode: Batch
============================================================

[Game plays automatically]

🏆 Winner: AliceStrategy!
```

## View Results

```bash
open reports/round_1.html
```

## Current Example Strategies

Three examples already in `strategies/`:
- `alice_strategy.rb` - Cautious Follower
- `bob_strategy.rb` - Opportunist  
- `carol_strategy.rb` - Grudge Holder

You can test with these:
```bash
bin/play --tournament --rounds 3 --reports
```

## More Options

**Interactive Mode** (pause after each round):
```bash
bin/play --tournament --interactive --rounds 6 --reports
```

**Test Your Strategy** against examples:
```bash
bin/play --players strategies/my_strategy.rb,lib/strategy/examples/greedy_strategy.rb --rounds 2 --reports
```

## Summary

**To answer your original question:**

> "玩家提交strategy到strategies/下面，然后直接bin/play就可以了嘛？"

Almost! The command is:

```bash
bin/play --tournament --rounds 6 --reports
```

The `--tournament` flag tells it to load ALL strategies from `strategies/` folder.

---

**See Also:**
- `TOURNAMENT_GUIDE.md` - Complete tournament workflow
- `QUICKSTART.md` - All game modes and options
- `README.md` - Full documentation
