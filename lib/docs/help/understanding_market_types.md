# Understanding Market Types

## Introduction

Market types represent different trading instruments available in cryptocurrency markets. Each type has unique characteristics, risk profiles, and use cases. This guide will help you understand the differences and choose the right market type for your trading strategy.

## The Four Market Types

### 💰 Spot Trading

**What is it?**
Spot trading is the most straightforward form of cryptocurrency trading. When you buy Bitcoin on the spot market, you actually own the Bitcoin and can transfer it to your wallet.

**Key Characteristics:**
- **No Leverage**: You can only trade with the funds you have (1x leverage)
- **Ownership**: You own the actual cryptocurrency
- **No Expiration**: Hold your assets as long as you want
- **No Liquidation Risk**: Your position cannot be forcibly closed
- **Simplicity**: Easy to understand and execute

**Best For:**
- Beginners learning to trade
- Long-term investors (HODLers)
- Building a diversified portfolio
- Dollar-cost averaging strategies

**Example:**
```
You have $1,000
You buy Bitcoin at $50,000
You receive 0.02 BTC
If Bitcoin goes to $60,000, your 0.02 BTC is worth $1,200 (20% profit)
If Bitcoin drops to $40,000, your 0.02 BTC is worth $800 (20% loss)
```

---

### 📈 Futures Trading

**What is it?**
Futures trading involves contracts that derive their value from an underlying cryptocurrency. You don't own the actual asset but rather a contract that tracks its price.

**Key Characteristics:**
- **High Leverage**: Up to 100x leverage available
- **Bidirectional Trading**: Profit from both rising (long) and falling (short) prices
- **Funding Rate**: Periodic payments between long and short positions (every 8 hours)
- **Liquidation Risk**: Your position can be automatically closed if losses exceed margin
- **No Ownership**: You don't own the underlying cryptocurrency

**Best For:**
- Experienced traders
- Short-term speculation
- Hedging spot positions
- Taking advantage of high volatility
- Professional day trading

**Example:**
```
You have $1,000
You open a long position with 10x leverage on Bitcoin at $50,000
Your position size: $10,000 (controlling 0.2 BTC)

If Bitcoin goes to $55,000 (+10%):
Your profit: $1,000 (100% return on your $1,000)

If Bitcoin drops to $45,000 (-10%):
Your loss: $1,000 (100% loss, position liquidated)
```

**Important Concepts:**

**Funding Rate:**
- Paid/received every 8 hours
- Positive rate: Longs pay shorts (bullish market)
- Negative rate: Shorts pay longs (bearish market)
- Typically ranges from -0.1% to +0.1%

**Liquidation:**
- Occurs when your losses approach your margin
- Liquidation price depends on leverage used
- Higher leverage = closer liquidation price
- Always use stop-loss orders to manage risk

---

### ⚡ Margin Trading

**What is it?**
Margin trading allows you to borrow funds from the exchange to increase your trading position. It's like leveraged spot trading.

**Key Characteristics:**
- **Moderate Leverage**: Up to 10x leverage
- **Borrowed Funds**: You borrow from the exchange
- **Interest Charges**: Pay interest on borrowed amount
- **Ownership**: You own the actual cryptocurrency
- **Margin Calls**: Must maintain minimum margin ratio

**Best For:**
- Intermediate traders
- Amplifying spot trading positions
- Short to medium-term trading
- Swing trading strategies

**Example:**
```
You have $1,000
You borrow $4,000 (5x leverage)
Total buying power: $5,000
You buy Bitcoin at $50,000 (0.1 BTC)

Interest: ~0.02% per day on $4,000 borrowed

If Bitcoin goes to $55,000 (+10%):
Position value: $5,500
Repay loan: $4,000
Your equity: $1,500 (50% profit minus interest)

If Bitcoin drops to $45,000 (-10%):
Position value: $4,500
Repay loan: $4,000
Your equity: $500 (50% loss plus interest)
```

**Important Concepts:**

**Margin Ratio:**
- Equity / Total Position Value
- Must maintain above minimum (typically 10-20%)
- Falls below minimum = margin call

**Interest Costs:**
- Charged daily on borrowed amount
- Varies by cryptocurrency
- Can eat into profits on longer holds

---

### 🎯 Options Trading

**What is it?**
Options give you the right (but not the obligation) to buy or sell a cryptocurrency at a specific price before a certain date.

**Key Characteristics:**
- **Limited Risk**: Maximum loss is the premium paid
- **Expiration Date**: Options expire worthless if not exercised
- **Call Options**: Right to buy at strike price
- **Put Options**: Right to sell at strike price
- **Greeks**: Delta, Gamma, Theta, Vega for risk management

**Best For:**
- Advanced traders
- Hedging portfolio risk
- Generating income (covered calls)
- Speculating with limited downside
- Complex trading strategies

**Example - Call Option:**
```
Bitcoin is at $50,000
You buy a call option:
- Strike price: $55,000
- Expiration: 30 days
- Premium: $500

Scenario 1: Bitcoin goes to $60,000
- Exercise option, buy at $55,000
- Sell at $60,000
- Profit: $5,000 - $500 = $4,500

Scenario 2: Bitcoin stays at $50,000
- Option expires worthless
- Loss: $500 (premium paid)
```

**Important Concepts:**

**The Greeks:**
- **Delta**: Rate of change in option price vs underlying price
- **Gamma**: Rate of change in delta
- **Theta**: Time decay (how much value lost per day)
- **Vega**: Sensitivity to volatility changes

**Time Decay:**
- Options lose value as expiration approaches
- Accelerates in final weeks
- Important to consider when holding options

---

## Comparison Table

| Feature | Spot | Futures | Margin | Options |
|---------|------|---------|--------|---------|
| **Max Leverage** | 1x | 100x | 10x | 1x |
| **Complexity** | Simple | Advanced | Intermediate | Advanced |
| **Risk Level** | Low | High | Medium | Medium |
| **Own Asset** | ✅ Yes | ❌ No | ✅ Yes | ❌ No |
| **Liquidation Risk** | ❌ No | ✅ Yes | ✅ Yes | ❌ No |
| **Funding Rate** | ❌ No | ✅ Yes | ❌ No | ❌ No |
| **Short Selling** | ❌ No | ✅ Yes | ✅ Yes | ✅ Yes |
| **Expiration** | ❌ No | ❌ No | ❌ No | ✅ Yes |
| **Interest Charges** | ❌ No | ❌ No | ✅ Yes | ❌ No |

---

## Choosing the Right Market Type

### For Beginners
**Start with Spot Trading**
- Learn market dynamics without leverage risk
- Build confidence with real ownership
- Practice technical analysis
- Develop risk management skills

### For Intermediate Traders
**Consider Margin Trading**
- Amplify your spot trading strategies
- Moderate leverage for better risk/reward
- Learn about borrowed funds management
- Transition to more advanced trading

### For Advanced Traders
**Explore Futures and Options**
- Futures for high-leverage speculation
- Options for hedging and income generation
- Complex strategies for various market conditions
- Professional risk management required

---

## Risk Management Tips

### General Rules
1. **Never risk more than you can afford to lose**
2. **Start with small positions**
3. **Always use stop-loss orders**
4. **Understand liquidation prices**
5. **Monitor positions actively**

### Leverage Guidelines
- **Beginners**: 1-2x maximum
- **Intermediate**: 2-5x maximum
- **Advanced**: 5-20x (rarely higher)
- **Professional**: Up to 100x (extreme risk)

### Position Sizing
```
Risk per trade = Account size × Risk percentage
Position size = Risk per trade / Stop-loss distance

Example:
Account: $10,000
Risk per trade: 2% = $200
Stop-loss: 5% from entry
Position size: $200 / 0.05 = $4,000
```

---

## Common Mistakes to Avoid

### 1. Over-Leveraging
❌ Using maximum leverage available
✅ Start with low leverage and increase gradually

### 2. No Stop-Loss
❌ Hoping losses will reverse
✅ Always set stop-loss before entering

### 3. Ignoring Funding Rates
❌ Holding futures positions without checking rates
✅ Monitor funding rates, especially for long holds

### 4. Emotional Trading
❌ Revenge trading after losses
✅ Stick to your trading plan

### 5. Not Understanding the Product
❌ Trading complex instruments without education
✅ Learn thoroughly before risking real money

---

## Conclusion

Each market type serves different purposes and suits different trading styles. Start with spot trading to build fundamentals, then gradually explore other market types as you gain experience. Always prioritize risk management and never trade with money you can't afford to lose.

Remember: **The best market type is the one that matches your experience level, risk tolerance, and trading goals.**

---

## Additional Resources

- [Leverage and Risk Management Guide](./leverage_and_risk.md)
- [Choosing the Right Market Type Guide](./choosing_market_type.md)
- Interactive Tutorial (in-app)
- Market Types Demo Screen (in-app)

---

*Last Updated: November 2025*
*Version: 1.0*
