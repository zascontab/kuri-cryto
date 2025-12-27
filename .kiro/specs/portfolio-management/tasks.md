# Implementation Plan - Portfolio Management System

## Overview

This plan implements a comprehensive portfolio management system with multi-exchange support, analytics, and rebalancing features.

---

## Phase 1: Core Data Models

- [x] 1. Create Portfolio model
  - Create `lib/models/portfolio.dart`
  - Add Portfolio class with id, totalValue, change24h, totalPnl, assets, lastUpdated
  - Implement fromJson() and toJson()
  - Add computed properties: totalAssets, profitableAssets, losingAssets
  - _Requirements: 1.1, 1.2, 1.3_

- [x] 2. Create Asset model
  - Create `lib/models/asset.dart`
  - Add Asset class with symbol, quantity, currentPrice, value, allocation, exchange
  - Implement fromJson() and toJson()
  - Add computed properties: pnl, pnlPercent, isProfit
  - _Requirements: 2.1, 2.2, 2.3_

- [x] 3. Create PerformanceData model
  - Create `lib/models/performance_data.dart`
  - Add PerformanceData class with historical values, roi, bestPerformer, worstPerformer
  - Implement fromJson() and toJson()
  - Add methods for calculating metrics
  - _Requirements: 4.1, 4.2, 4.3, 4.4_

- [x] 4. Create RiskAssessment model
  - Create `lib/models/risk_assessment.dart`
  - Add RiskAssessment class with riskScore, volatility, concentration, leverageExposure
  - Implement fromJson() and toJson()
  - Add computed property: riskLevel (low/medium/high)
  - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_

- [x] 5. Create RebalancingPlan model
  - Create `lib/models/rebalancing_plan.dart`
  - Add RebalancingPlan class with trades, estimatedCost, expectedAllocation
  - Add Trade class with action, symbol, quantity, estimatedPrice
  - Implement fromJson() and toJson()
  - _Requirements: 7.1, 7.2, 7.3_

---

## Phase 2: Service Layer

- [x] 6. Create PortfolioService
  - [x] 6.1 Implement getPortfolio() method
    - Make API call to portfolio endpoint
    - Parse response into Portfolio model
    - Handle errors appropriately
    - _Requirements: 1.1, 1.4_
  
  - [x] 6.2 Implement getAssets() method
    - Fetch all assets from portfolio
    - Sort by value descending
    - Calculate allocations
    - _Requirements: 2.1, 2.2, 2.3, 2.4_
  
  - [x] 6.3 Implement getPerformance() method
    - Accept TimePeriod parameter (1D, 1W, 1M, 3M, 1Y, ALL)
    - Fetch historical data
    - Calculate performance metrics
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5_
  
  - [x] 6.4 Implement assessRisk() method
    - Calculate risk score based on volatility, concentration, leverage
    - Return RiskAssessment model
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_
  
  - [x] 6.5 Implement generateRebalancingPlan() method
    - Accept target allocations map
    - Calculate required trades
    - Estimate costs including fees
    - Return RebalancingPlan model
    - _Requirements: 7.1, 7.2, 7.3_

- [x] 7. Create ExchangeAggregator service
  - [x] 7.1 Implement Binance adapter
    - Fetch balances from Binance
    - Convert to standard Asset format
    - Handle API errors
    - _Requirements: 3.1, 3.2_
  
  - [x] 7.2 Implement Bybit adapter
    - Fetch balances from Bybit
    - Convert to standard Asset format
    - Handle API errors
    - _Requirements: 3.1, 3.2_
  
  - [x] 7.3 Implement aggregation logic
    - Combine balances from all exchanges
    - Handle duplicate assets
    - Calculate total values
    - _Requirements: 3.3, 3.4, 3.5_

- [x] 8. Create TransactionService
  - Implement getTransactions() method
  - Support filtering by type, asset, date range
  - Implement pagination (50 per page)
  - Support CSV export
  - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5_

---

## Phase 3: Provider Layer

- [x] 9. Create PortfolioProvider
  - [x] 9.1 Add portfolio state management
    - Add Portfolio? portfolio state variable
    - Add bool isLoading state variable
    - Add String? error state variable
    - _Requirements: 1.1_
  
  - [x] 9.2 Implement loadPortfolio() method
    - Call portfolioService.getPortfolio()
    - Update state with result or error
    - Notify listeners
    - _Requirements: 1.1, 1.4, 1.5_
  
  - [x] 9.3 Implement auto-refresh
    - Set up timer for 30-second refresh
    - Call loadPortfolio() automatically
    - Handle errors gracefully
    - _Requirements: 1.5_
  
  - [x] 9.4 Add computed getters
    - totalValue getter
    - change24h getter
    - totalPnl getter
    - _Requirements: 1.1, 1.2, 1.3_

- [x] 10. Create AnalyticsProvider
  - Add PerformanceData state
  - Implement loadPerformance(TimePeriod) method
  - Add computed getters for metrics
  - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5_

- [x] 11. Create RebalancingProvider
  - Add RebalancingPlan state
  - Implement generatePlan(targets) method
  - Implement executePlan() method
  - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5_

---

## Phase 4: UI Implementation

- [x] 12. Create PortfolioOverviewScreen
  - Create `lib/screens/portfolio_overview_screen.dart`
  - Display total portfolio value with 24h change
  - Display total PnL
  - Show asset list with allocations
  - Add pull-to-refresh
  - Handle loading and error states
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 2.1, 2.2, 2.3, 2.4, 2.5_

- [x] 13. Create AllocationChartWidget
  - Create `lib/widgets/allocation_chart.dart`
  - Implement pie chart using fl_chart package
  - Show allocation by asset
  - Show allocation by market type
  - Add tap interaction to highlight assets
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_

- [x] 14. Create PerformanceScreen
  - Create `lib/screens/performance_screen.dart`
  - Display time period selector (1D, 1W, 1M, 3M, 1Y, ALL)
  - Render performance chart
  - Display ROI percentage
  - Show best and worst performers
  - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5_

- [x] 15. Create RiskAssessmentWidget
  - Create `lib/widgets/risk_assessment.dart`
  - Display risk score with color coding
  - Show risk level badge (Low/Medium/High)
  - Display contributing factors
  - Show warning when risk > 70
  - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_

- [x] 16. Create RebalancingScreen
  - Create `lib/screens/rebalancing_screen.dart`
  - Allow user to set target allocations
  - Display current vs target allocations
  - Show required trades
  - Display estimated costs
  - Add "Execute Rebalancing" button
  - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5_

- [x] 17. Create TransactionHistoryScreen
  - Create `lib/screens/transaction_history_screen.dart`
  - Display transaction list with pagination
  - Add filters for type, asset, date range
  - Implement search functionality
  - Add CSV export button
  - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5_

- [x] 18. Create ComparisonScreen
  - Create `lib/screens/portfolio_comparison_screen.dart`
  - Display benchmark selector (BTC, ETH, Custom)
  - Render comparative performance chart
  - Show relative performance metrics
  - Highlight outperformance/underperformance
  - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5_

---

## Phase 5: Notifications

- [x] 19. Implement notification system
  - [x] 19.1 Create NotificationService
    - Implement local notification support
    - Add notification scheduling
    - Handle notification taps
    - _Requirements: 10.1, 10.2, 10.3, 10.4, 10.5_
  
  - [x] 19.2 Implement portfolio alerts
    - Monitor portfolio value changes
    - Check allocation deviations
    - Check risk score thresholds
    - Send notifications when thresholds exceeded
    - _Requirements: 10.1, 10.2, 10.3_
  
  - [x] 19.3 Create notification settings screen
    - Allow user to configure thresholds
    - Enable/disable specific alerts
    - Test notification delivery
    - _Requirements: 10.4_

---

## Phase 6: Testing

- [ ] 20. Write unit tests
  - Test Portfolio model calculations
  - Test Asset model computed properties
  - Test PerformanceData metrics
  - Test RiskAssessment scoring
  - Test RebalancingPlan generation
  - _Requirements: All_

- [ ] 21. Write integration tests
  - Test multi-exchange aggregation
  - Test portfolio refresh flow
  - Test rebalancing execution
  - _Requirements: All_

---

## Notes

- Each task builds on previous tasks
- Multi-exchange support is core feature
- Real-time updates every 30 seconds
- Estimated time: 4-5 days for complete implementation
