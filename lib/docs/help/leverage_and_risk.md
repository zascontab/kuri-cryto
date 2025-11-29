# Leverage and Risk Management Guide

## Understanding Leverage

Leverage allows you to control a larger position than your actual capital. It's a double-edged sword that amplifies both gains and losses.

### The Leverage Formula

```
Position Size = Capital × Leverage

Example:
Capital: $1,000
Leverage: 10x
Position Size: $10,000
```

---

## How Leverage Works

### Example: 10x Leverage

**Scenario 1: Price Goes Up 5%**
```
Your capital: $1,000
Position size: $10,000 (10x leverage)
Price increase: 5%
Position value: $10,500
Your profit: $500 (50% return on your $1,000)
```

**Scenario 2: Price Goes Down 5%**
```
Your capital: $1,000
Position size: $10,000 (10x leverage)
Price decrease: 5%
Position value: $9,500
Your loss: $500 (50% loss on your $1,000)
```

**Scenario 3: Price Goes Down 10%**
```
Your capital: $1,000
Position size: $10,000 (10x leverage)
Price decrease: 10%
Position value: $9,000
Your loss: $1,000 (100% loss - LIQUIDATED)
```

---

## Liquidation Explained

### What is Liquidation?

Liquidation occurs when your losses approach your margin (capital). The exchange automatically closes your position to prevent you from owing money.

### Liquidation Price Calculation

```
Long Position:
Liquidation Price = Entry Price × (1 - 1/Leverage)

Short Position:
Liquidation Price = Entry Price × (1 + 1/Leverage)

Examples:
Entry: $50,000
Leverage: 10x
Long liquidation: $50,000 × (1 - 0.1) = $45,000
Short liquidation: $50,000 × (1 + 0.1) = $55,000
```

### Liquidation Distance by Leverage

| Leverage | Liquidation Distance | Safe? |
|----------|---------------------|-------|
| 2x | 50% move | ✅ Very Safe |
| 5x | 20% move | ✅ Safe |
| 10x | 10% move | ⚠️ Moderate |
| 20x | 5% move | ⚠️ Risky |
| 50x | 2% move | ❌ Very Risky |
| 100x | 1% move | ❌ Extremely Risky |

---

## Risk Management Principles

### 1. The 1% Rule

**Never risk more than 1-2% of your capital on a single trade.**

```
Account size: $10,000
Risk per trade: 1% = $100
Stop-loss: 5% from entry

Position size calculation:
$100 / 0.05 = $2,000 position size

With 10x leverage:
Capital needed: $200
Remaining capital: $9,800 (safe)
```

### 2. Position Sizing

**Formula:**
```
Position Size = (Account Size × Risk %) / Stop-Loss %

Example:
Account: $5,000
Risk: 2% = $100
Stop-loss: 4%
Position: $100 / 0.04 = $2,500
```

### 3. Stop-Loss Orders

**Always use stop-loss orders. Always.**

Types of Stop-Loss:
```
1. Fixed Percentage
   - Set at 2-5% from entry
   - Simple and effective
   
2. Technical Levels
   - Below support (long)
   - Above resistance (short)
   - More strategic
   
3. ATR-Based
   - Based on volatility
   - Adapts to market conditions
```

---

## Leverage Guidelines by Experience

### Beginners (0-6 months)
**Maximum Leverage: 2x**

```
Why?
- Learn without catastrophic losses
- Understand leverage mechanics
- Build confidence slowly
- Develop risk management habits

Recommended:
- Start with 1x (spot)
- Try 2x after 3 months
- Paper trade higher leverage
- Focus on learning, not profits
```

### Intermediate (6-18 months)
**Maximum Leverage: 5x**

```
Why?
- Balance risk and reward
- Still relatively safe
- Room for mistakes
- Develop advanced skills

Recommended:
- Use 2-3x regularly
- Occasional 5x for high-conviction trades
- Always use stop-losses
- Track all trades
```

### Advanced (18+ months)
**Maximum Leverage: 10-20x**

```
Why?
- Experienced risk management
- Understand market dynamics
- Can handle volatility
- Professional approach

Recommended:
- Use 5-10x for most trades
- Rarely go above 20x
- Tight stop-losses
- Active monitoring
```

### Professional Traders
**Maximum Leverage: 20-50x**

```
Why?
- Years of experience
- Proven track record
- Advanced strategies
- Full-time focus

Recommended:
- Use 10-20x typically
- 50x only for scalping
- Never 100x (gambling)
- Sophisticated risk management
```

---

## Common Leverage Mistakes

### Mistake 1: Using Maximum Leverage
❌ **Wrong:**
```
"The exchange offers 100x, so I'll use it!"
Result: Liquidated on 1% move
```

✅ **Right:**
```
"I'll use 5x leverage with proper stop-loss"
Result: Controlled risk, room for volatility
```

### Mistake 2: No Stop-Loss
❌ **Wrong:**
```
"I'll just watch the position and close manually"
Result: Emotional decisions, bigger losses
```

✅ **Right:**
```
"Stop-loss at 5% below entry, set before opening"
Result: Automatic risk control, no emotions
```

### Mistake 3: Overleveraging Account
❌ **Wrong:**
```
Account: $1,000
Position: $50,000 (50x leverage)
Using: 100% of account
Result: One bad trade = account wiped
```

✅ **Right:**
```
Account: $1,000
Position: $5,000 (5x leverage)
Using: 20% of account ($200)
Result: Can survive multiple losses
```

### Mistake 4: Ignoring Funding Rates
❌ **Wrong:**
```
"I'll hold this 50x futures position for weeks"
Result: Funding rates eat into profits
```

✅ **Right:**
```
"High leverage for quick trades only"
"Check funding rates before holding overnight"
Result: Minimize funding costs
```

---

## Risk Management Strategies

### Strategy 1: The Pyramid Approach

```
Start small, add to winners:

Entry 1: $1,000 (2x leverage)
Price moves up 5%
Entry 2: $1,000 more (2x leverage)
Price moves up 5%
Entry 3: $1,000 more (2x leverage)

Benefits:
- Average up on winners
- Controlled risk increase
- Psychological advantage
```

### Strategy 2: The Scaling Out

```
Take profits gradually:

Position: $10,000
Target 1 (+5%): Close 33% = $3,333
Target 2 (+10%): Close 33% = $3,333
Target 3 (+15%): Close 34% = $3,334

Benefits:
- Lock in profits
- Reduce risk
- Stay in winning trades
```

### Strategy 3: The Risk-Reward Ratio

```
Minimum 1:2 risk-reward ratio:

Risk: $100 (stop-loss)
Reward: $200 (take-profit)
Ratio: 1:2

Win rate needed: 34%
(Even with 66% losses, you profit)

Better: 1:3 ratio
Win rate needed: 26%
```

---

## Calculating Your Risk

### Daily Risk Limit

```
Account: $10,000
Daily risk limit: 5% = $500

Trade 1: Risk $100 (1%)
Trade 2: Risk $100 (1%)
Trade 3: Risk $100 (1%)
Trade 4: Risk $100 (1%)
Trade 5: Risk $100 (1%)

Stop trading after $500 loss
Come back tomorrow
```

### Weekly Risk Limit

```
Account: $10,000
Weekly risk limit: 10% = $1,000

Monday: -$200
Tuesday: +$300
Wednesday: -$400
Thursday: -$500 (hit limit)
Friday: NO TRADING

Reset next week
```

---

## Leverage by Market Type

### Spot Trading
```
Leverage: 1x (no leverage)
Risk: Low
Liquidation: None
Best for: Everyone
```

### Margin Trading
```
Leverage: 1-10x
Risk: Medium
Liquidation: Yes
Best for: Intermediate+
Recommended: 2-5x
```

### Futures Trading
```
Leverage: 1-100x
Risk: High
Liquidation: Yes
Best for: Advanced+
Recommended: 5-20x
Never: 100x
```

### Options Trading
```
Leverage: Implicit (via premium)
Risk: Limited (buyer) / High (seller)
Liquidation: No (buyer) / Yes (seller)
Best for: Advanced+
```

---

## Real-World Examples

### Example 1: Conservative Trader

```
Profile:
- Account: $5,000
- Experience: Intermediate
- Risk tolerance: Low

Strategy:
- Market type: Margin
- Leverage: 3x
- Position size: $1,000 (20% of account)
- Stop-loss: 5%
- Risk per trade: $50 (1%)

Result:
- Safe approach
- Room for 100 losing trades
- Sustainable long-term
```

### Example 2: Aggressive Trader

```
Profile:
- Account: $20,000
- Experience: Advanced
- Risk tolerance: High

Strategy:
- Market type: Futures
- Leverage: 10x
- Position size: $5,000 (25% of account)
- Stop-loss: 2%
- Risk per trade: $500 (2.5%)

Result:
- Higher risk, higher reward
- Room for 40 losing trades
- Requires active management
```

### Example 3: Professional Trader

```
Profile:
- Account: $100,000
- Experience: Professional
- Risk tolerance: Calculated

Strategy:
- Market type: Mixed
- Leverage: 5-20x (varies)
- Position size: $10,000 (10% per trade)
- Stop-loss: 1-3% (tight)
- Risk per trade: $1,000 (1%)

Result:
- Professional approach
- Multiple strategies
- Sophisticated risk management
- Full-time focus
```

---

## Emergency Procedures

### When Things Go Wrong

**Step 1: Stop Trading**
```
- Close all positions
- Take a break
- Don't revenge trade
- Review what happened
```

**Step 2: Assess Damage**
```
- Calculate total loss
- Review each trade
- Identify mistakes
- Document lessons
```

**Step 3: Adjust Strategy**
```
- Reduce position sizes
- Lower leverage
- Tighten stop-losses
- Paper trade for a week
```

**Step 4: Restart Carefully**
```
- Start with smallest positions
- Use lowest leverage
- Rebuild confidence
- Track everything
```

---

## Risk Management Checklist

Before Every Trade:
```
☐ Position size calculated (1-2% risk)
☐ Stop-loss level determined
☐ Take-profit targets set
☐ Leverage appropriate for experience
☐ Account has room for loss
☐ Not trading emotionally
☐ Market conditions understood
☐ Funding rates checked (futures)
☐ Liquidation price acceptable
☐ Exit plan documented
```

---

## Key Takeaways

1. **Leverage amplifies everything** - gains and losses
2. **Lower leverage = safer trading**
3. **Always use stop-losses**
4. **Risk 1-2% per trade maximum**
5. **Position size matters more than leverage**
6. **Know your liquidation price**
7. **Have daily/weekly risk limits**
8. **Start small, scale gradually**
9. **Never use maximum leverage**
10. **Risk management > profit seeking**

---

## Remember

> "The goal is not to make money quickly. The goal is to not lose money, and let profits accumulate over time."

> "Professional traders focus on risk management. Amateur traders focus on profits."

> "You can always make more money. You can't recover from a liquidated account."

---

## Additional Resources

- [Understanding Market Types](./understanding_market_types.md)
- [Choosing the Right Market Type](./choosing_market_type.md)
- Risk Calculator (in-app)
- Position Size Calculator (in-app)

---

*Last Updated: November 2025*
*Version: 1.0*
