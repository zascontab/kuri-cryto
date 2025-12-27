# Implementation Plan - API Integration Update

## Overview

Este plan implementa la actualización de la integración de APIs en 4 fases, manteniendo compatibilidad hacia atrás y permitiendo rollback en cualquier momento.

---

## Phase 1: New Data Models

- [x] 1. Create ComprehensiveAnalysis model and related classes
  - Create `lib/models/comprehensive_analysis.dart` with ComprehensiveAnalysis class
  - Create PriceData class with all price fields (last, bid, ask, volume, high24h, low24h, change24h, changePercent24h)
  - Create TechnicalIndicators class with timeframe and indicator data (RSI, MACD, Bollinger Bands, EMA, Volume)
  - Create RSIData, MACDData, BollingerBandsData, EMAData, VolumeData classes
  - Create Scenario class with type, probability, description, conditions, targetPrice, stopLoss
  - Create Recommendation class with action, confidence, entry, stopLoss, takeProfit, reasoning, risks
  - Implement fromJson() for all classes with null safety and default values
  - Implement toJson() for all classes
  - Add computed properties (e.g., isStrongBuy, isBullish, etc.)
  - _Requirements: 1.2, 1.3, 1.4, 8.1, 8.2, 8.3, 8.4, 8.5_

- [x] 2. Enhance AiBotConfig model
  - Update `lib/models/ai_bot_config.dart` to include all new fields
  - Add maxConsecutiveErrors field (int)
  - Add maxOpenPositions field (int)
  - Add validation methods: isValidConfidenceThreshold(), isValidLeverage()
  - Implement copyWith() method for immutable updates
  - Update fromJson() to handle all new fields with defaults
  - Update toJson() to include all fields
  - _Requirements: 2.1, 2.3, 2.4, 6.1, 6.2_

- [x] 3. Enhance AiBotStatus model
  - Update `lib/models/ai_bot_status.dart` to include all new fields
  - Add paused field (bool)
  - Add emergencyStop field (bool)
  - Add startedAt field (DateTime?)
  - Add lastAnalysisAt field (DateTime?)
  - Add uptimeSeconds field (int)
  - Add analysisCount, executionCount, errorCount, consecutiveErrors fields (int)
  - Add dailyLoss field (double)
  - Add dailyTrades field (int)
  - Add openPositions field (int)
  - Add computed properties: uptime (Duration), isHealthy (bool), hasReachedDailyLimit (bool)
  - Update fromJson() to parse all new fields
  - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5_

- [x] 4. Enhance FuturesPosition model
  - Update `lib/models/futures_position.dart` to include mark price
  - Ensure currentPrice field represents mark price
  - Add realizedPnl field if not present
  - Add marginMode field (String: 'ISOLATED' or 'CROSS')
  - Add updatedAt field (DateTime)
  - Add computed property: totalPnl (unrealizedPnl + realizedPnl)
  - Add computed property: isNearLiquidation (bool) - alerts if within 10% of liquidation
  - Update fromJson() to parse all fields correctly
  - _Requirements: 5.1, 5.2, 5.4_

- [x] 5. Export new models
  - Add all new models to `lib/models/models.dart` export file
  - Ensure proper imports and no circular dependencies
  - _Requirements: 8.1_

---

## Phase 2: Service Layer Updates

- [x] 6. Update AiBotService with new methods
  - [x] 6.1 Add getComprehensiveAnalysis() method
    - Implement POST request to `${ApiConfig.comprehensiveAnalysisUrl}`
    - Send symbol and exchange in request body
    - Parse response into ComprehensiveAnalysis model
    - Handle errors with descriptive messages
    - _Requirements: 1.1, 1.2, 9.1_
  
  - [x] 6.2 Add getConfig() method
    - Implement GET request to `${ApiConfig.aiBotConfigUrl}`
    - Parse response into AiBotConfig model
    - Handle errors appropriately
    - _Requirements: 2.1, 9.2_
  
  - [x] 6.3 Add updateConfig() method
    - Implement POST request to `${ApiConfig.aiBotConfigUrl}`
    - Accept Map<String, dynamic> updates parameter
    - Extract config from response['config']
    - Parse into AiBotConfig model
    - Handle "bot is running" error specifically
    - _Requirements: 2.2, 2.3, 2.4, 2.5, 9.2_
  
  - [x] 6.4 Add helper methods for common config updates
    - Implement enableDryRunMode() - sets dry_run: true, auto_execute: false
    - Implement enableLiveMode() - sets dry_run: false, auto_execute: true
    - Implement updateConfidenceThreshold(double) - validates 0.5-1.0 range
    - Implement updateTradeSize(double) - validates positive value
    - Implement updateLeverage(int) - validates 1-100 range
    - Implement updateTradingPair(String)
    - Implement updateSafetyLimits() with optional parameters
    - _Requirements: 2.3, 9.2_
  
  - [x] 6.5 Update getStatus() to use enhanced model
    - Ensure it returns AiBotStatus with all new fields
    - Parse all new fields from response
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5_

- [x] 7. Update FuturesService with new methods
  - [x] 7.1 Add getMarkPrice() method
    - Implement JSON-RPC call to 'get_mark_price' tool
    - Send exchange and symbol in arguments
    - Extract mark_price from result
    - Return as double
    - Handle errors appropriately
    - _Requirements: 3.1, 5.1, 9.3_
  
  - [x] 7.2 Add getIndexPrice() method
    - Implement JSON-RPC call to 'get_index_price' tool
    - Send exchange and symbol in arguments
    - Extract index_price from result
    - Return as double
    - Handle errors appropriately
    - _Requirements: 3.2, 9.4_
  
  - [x] 7.3 Ensure getPositions() uses enhanced model
    - Verify it parses all new fields including mark price
    - Ensure FuturesPosition model is used correctly
    - _Requirements: 5.1, 5.2_

- [x] 8. Enhance MCPService error handling
  - [x] 8.1 Update callTool() error handling
    - Check for JSON-RPC error in response.data['error']
    - Extract error.message, error.code, error.data
    - Throw ApiException with extracted information
    - _Requirements: 4.1, 4.2, 9.5_
  
  - [x] 8.2 Improve _handleError() method
    - Add specific handling for JSON-RPC error format
    - Add helpful hints for common errors (timeout, connection)
    - Include server IP and port in connection error messages
    - Map error codes to user-friendly messages
    - _Requirements: 4.3, 4.4, 4.5_
  
  - [x] 8.3 Add error message mapping
    - Create ErrorMessages class with userFriendly map
    - Add getFriendlyMessage() static method
    - Map all common error codes to Spanish messages
    - _Requirements: 4.2, 4.5_

- [x] 9. Update ApiConfig with new endpoints
  - Add comprehensiveAnalysisUrl constant
  - Add aiBotConfigUrl constant
  - Add validateConfiguration() static method
  - Verify all URLs are correctly formatted
  - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_

---

## Phase 3: Provider Layer Updates

- [x] 10. Update AiBotProvider
  - [x] 10.1 Add comprehensive analysis state
    - Add ComprehensiveAnalysis? comprehensiveAnalysis state variable
    - Add bool isLoadingAnalysis state variable
    - Add String? analysisError state variable
    - _Requirements: 1.2_
  
  - [x] 10.2 Add loadComprehensiveAnalysis() method
    - Call aiBotService.getComprehensiveAnalysis()
    - Update state with result or error
    - Notify listeners
    - _Requirements: 1.1, 1.2_
  
  - [x] 10.3 Add config management methods
    - Add AiBotConfig? config state variable
    - Add loadConfig() method
    - Add updateConfig() method with validation
    - Add helper methods: enableDryRun(), enableLive(), updateThreshold(), etc.
    - Handle "bot is running" error with user-friendly message
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_
  
  - [x] 10.4 Enhance status monitoring
    - Ensure status uses enhanced AiBotStatus model
    - Add computed getters for UI: isHealthy, hasReachedLimits, uptimeFormatted
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5_

- [x] 11. Update FuturesProvider
  - [x] 11.1 Add mark price tracking
    - Add Map<String, double> markPrices state variable
    - Add loadMarkPrice(String symbol) method
    - Add loadMarkPricesForPositions() method
    - _Requirements: 5.1, 5.2_
  
  - [x] 11.2 Add liquidation alerts
    - Add method to check if positions are near liquidation
    - Add List<String> liquidationAlerts state variable
    - Update when positions are loaded
    - _Requirements: 5.2_
  
  - [x] 11.3 Enhance position management
    - Ensure positions use enhanced FuturesPosition model
    - Add computed getters: totalPnl, profitablePositions, losingPositions
    - _Requirements: 5.1, 5.4_

---

## Phase 4: UI Updates

- [x] 12. Create ComprehensiveAnalysisScreen
  - Create `lib/screens/comprehensive_analysis_screen.dart`
  - Display price data section with current price, bid, ask, volume, 24h change
  - Display technical indicators section with tabs for each timeframe
  - Display scenarios section with bullish/bearish/neutral probabilities
  - Display recommendation section with action, confidence, entry/exit points
  - Add refresh button to reload analysis
  - Handle loading and error states
  - Use ComprehensiveAnalysisProvider
  - _Requirements: 1.2, 1.3, 1.4_

- [x] 13. Create or update AiBotConfigScreen
  - Create `lib/screens/ai_bot_config_screen.dart` if not exists
  - Display current configuration with all fields
  - Add toggle for dry run / live mode
  - Add slider for confidence threshold (0.5 - 1.0)
  - Add input for trade size USD
  - Add input for leverage (1-100)
  - Add input for max daily loss
  - Add input for max daily trades
  - Add save button that calls updateConfig()
  - Show warning if bot is running
  - Add "Stop bot and update" button if bot is running
  - Handle validation errors with user-friendly messages
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_

- [x] 14. Enhance AiBotControlScreen
  - Update `lib/screens/ai_bot_control_screen.dart` to show enhanced status
  - Display uptime, analysis count, execution count
  - Display error count with warning if > 0
  - Display daily loss and daily trades with progress bars
  - Show "Healthy" or "Warning" badge based on status
  - Add pause/resume buttons
  - Add emergency stop button with confirmation dialog
  - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5_

- [x] 15. Enhance PositionsScreen
  - Update `lib/screens/positions_screen.dart` to show mark price
  - Display liquidation price with warning if near liquidation
  - Add badge/indicator for positions near liquidation (red alert)
  - Show total PnL (realized + unrealized)
  - Add "Close All" button
  - Add "Close Losing" and "Close Profitable" buttons
  - Improve position card UI with better PnL visualization
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_

- [x] 16. Update error handling in UI
  - Update all screens to use ErrorMessages.getFriendlyMessage()
  - Show user-friendly error messages in SnackBars
  - Add retry buttons for network errors
  - Show specific hints for common errors
  - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5_

---

## Phase 5: Testing and Validation

- [x] 17. Write unit tests for models
  - [x] 17.1 Test ComprehensiveAnalysis model
    - Test fromJson with complete data
    - Test fromJson with missing optional fields
    - Test fromJson with invalid types (should handle gracefully)
    - Test computed properties
    - Test toJson
    - _Requirements: 10.1_
  
  - [x] 17.2 Test enhanced AiBotConfig model
    - Test validation methods
    - Test copyWith
    - Test fromJson with all fields
    - Test fromJson with missing fields (should use defaults)
    - _Requirements: 10.2_
  
  - [x] 17.3 Test enhanced AiBotStatus model
    - Test computed properties (uptime, isHealthy, hasReachedDailyLimit)
    - Test fromJson with all fields
    - _Requirements: 10.2_
  
  - [x] 17.4 Test enhanced FuturesPosition model
    - Test computed properties (totalPnl, isNearLiquidation)
    - Test fromJson
    - _Requirements: 10.2_

- [x] 18. Write unit tests for services
  - [x] 18.1 Test AiBotService new methods
    - Mock Dio responses
    - Test getComprehensiveAnalysis() success
    - Test getComprehensiveAnalysis() error
    - Test getConfig() success
    - Test updateConfig() success
    - Test updateConfig() with bot running error
    - Test helper methods (enableDryRun, etc.)
    - _Requirements: 10.2_
  
  - [x] 18.2 Test FuturesService new methods
    - Test getMarkPrice() success
    - Test getMarkPrice() error
    - Test getIndexPrice() success
    - Test getIndexPrice() error
    - _Requirements: 10.2_
  
  - [x] 18.3 Test MCPService error handling
    - Test JSON-RPC error extraction
    - Test network error messages
    - Test timeout error messages
    - Test connection error messages
    - _Requirements: 10.2_

- [ ] 19. Write integration tests
  - [ ] 19.1 Test comprehensive analysis flow
    - Test full flow from service call to model parsing
    - Test with real API (if available) or mock server
    - _Requirements: 10.3_
  
  - [ ] 19.2 Test dynamic config flow
    - Test get config → update config → verify changes
    - Test validation errors
    - Test bot running error
    - _Requirements: 10.3_
  
  - [ ] 19.3 Test new MCP tools
    - Test mark price call
    - Test index price call
    - Test error scenarios
    - _Requirements: 10.3_

- [ ] 20. Manual testing and validation
  - Test comprehensive analysis screen with real data
  - Test config screen with various inputs
  - Test position screen with near-liquidation positions
  - Test error messages are user-friendly
  - Verify all URLs point to correct endpoints
  - Test on different network conditions
  - _Requirements: 10.4, 10.5_

---

## Phase 6: Documentation and Cleanup

- [ ] 21. Update documentation
  - Update API integration guide with new endpoints
  - Document new models with examples
  - Document error handling improvements
  - Add migration guide for developers
  - Update README with new features
  - _Requirements: All_

- [ ] 22. Code cleanup
  - Remove any debug print statements
  - Ensure consistent code formatting
  - Add missing dartdoc comments
  - Remove unused imports
  - Run dart analyze and fix warnings
  - _Requirements: All_

---

## Notes

- Each task builds on previous tasks
- All tasks are required for a comprehensive implementation
- All tasks reference specific requirements from requirements.md
- Estimated time: 3-4 days for complete implementation including testing
- Can be done incrementally without breaking existing functionality
- Testing ensures robustness and prevents regressions
