# Design Document

## Overview

This design document outlines the integration of the updated MATP (Multi-Asset Trading Platform) backend systems into the existing Flutter application. The integration encompasses two primary systems:

1. **MATP REST API with Kong Gateway** - Provides comprehensive trading, AI analysis, and user management functionality with JWT authentication and progressive access levels
2. **MCP (Model Context Protocol) System** - Offers 29 verified tools for technical analysis, backtesting, and risk management using JSON-RPC 2.0 protocol

The design maintains backward compatibility with existing functionality while adding new capabilities for advanced trading, AI-powered analysis, and autonomous trading features.

## Architecture

### High-Level Architecture

```
Flutter Application
├── Authentication Layer (JWT + Kong Gateway)
├── API Client Layer
│   ├── MATP REST Client (Kong Gateway)
│   └── MCP JSON-RPC Client
├── Service Layer
│   ├── Enhanced Trading Service
│   ├── AI Analysis Service
│   ├── MCP Tools Service
│   └── Autonomous Bot Service
├── Provider Layer (Riverpod)
│   ├── Authentication Provider
│   ├── Trading Data Provider
│   ├── AI Analysis Provider
│   └── Bot Control Provider
└── UI Layer
    ├── Enhanced Trading Screens
    ├── AI Analysis Dashboard
    └── Bot Control Interface
```

### System Integration Points

1. **Kong Gateway Integration** (Port 10000)
   - JWT authentication with automatic token refresh
   - Progressive access levels (1-4)
   - Rate limiting and error handling

2. **MCP Server Integration** (Port 9090 → 10600)
   - JSON-RPC 2.0 protocol implementation
   - 29 verified tools for technical analysis
   - Direct tool execution with result parsing

3. **Existing System Compatibility**
   - Maintains current API client patterns
   - Preserves existing service interfaces
   - Backward-compatible data models

## Components and Interfaces

### 1. Enhanced API Client Layer

#### MATP REST Client
```dart
class MATPApiClient extends ApiClient {
  String? _jwtToken;
  String? _refreshToken;
  int _userLevel = 1;
  
  // Kong Gateway configuration
  void configureKongGateway();
  
  // JWT token management
  Future<void> authenticate(String phone, String otpCode);
  Future<void> refreshToken();
  void setUserLevel(int level);
  
  // Enhanced error handling
  void handleRateLimiting(int retryAfter);
  void handleProgressiveAccess(int requiredLevel);
}
```

#### MCP JSON-RPC Client
```dart
class MCPClient {
  int _requestId = 1;
  
  // JSON-RPC 2.0 implementation
  Future<Map<String, dynamic>> callTool(String toolName, Map<String, dynamic> arguments);
  
  // Request formatting
  Map<String, dynamic> formatJsonRpcRequest(String method, Map<String, dynamic> params);
  
  // Response parsing
  dynamic parseJsonRpcResponse(Map<String, dynamic> response);
  
  // Error handling
  void handleJsonRpcError(Map<String, dynamic> error);
}
```

### 2. Enhanced Service Layer

#### Enhanced Trading Service
```dart
class EnhancedTradingService {
  final MATPApiClient _matpClient;
  final MCPClient _mcpClient;
  
  // Position management via MATP
  Future<List<Position>> getPositions();
  Future<Position> createPosition(CreatePositionRequest request);
  Future<void> closePosition(String positionId);
  
  // Technical analysis via MCP
  Future<double> calculateRSI(String exchange, String pair, int period);
  Future<BollingerBands> calculateBollingerBands(String exchange, String pair);
  Future<MACD> calculateMACD(String exchange, String pair);
  
  // Risk management
  Future<RiskAssessment> assessRisk(RiskAssessmentRequest request);
  Future<PositionSize> calculatePositionSize(PositionSizeRequest request);
}
```

#### AI Analysis Service
```dart
class AIAnalysisService {
  final MATPApiClient _matpClient;
  
  // Comprehensive AI analysis
  Future<CompleteAnalysis> getCompleteAnalysis(AnalysisRequest request);
  
  // LLM analysis
  Future<LLMAnalysis> getLLMAnalysis(LLMAnalysisRequest request);
  
  // Sentiment analysis
  Future<SentimentAnalysis> getSentimentAnalysis(String symbol, int hours);
  
  // Cost tracking
  Future<AICosts> getAICosts(String period, String? provider);
  
  // Strategy performance
  Future<StrategyPerformance> getStrategyPerformance(String timeframe, String? symbol);
}
```

#### Autonomous Bot Service
```dart
class AutonomousBotService {
  final MATPApiClient _matpClient;
  
  // Bot control
  Future<BotStatus> startBot();
  Future<BotStatus> stopBot();
  Future<BotStatus> pauseBot();
  Future<BotStatus> emergencyStop();
  
  // Bot configuration
  Future<BotConfig> getBotConfig();
  Future<void> updateBotConfig(BotConfig config);
  
  // Autonomous mode
  Future<void> enableAutonomousMode(AutonomousConfig config);
  Future<AutonomousStatus> getAutonomousStatus();
  
  // Performance monitoring
  Future<BotPerformance> getBotPerformance();
}
```

#### MCP Tools Service
```dart
class MCPToolsService {
  final MCPClient _mcpClient;
  
  // Market data tools
  Future<List<Candle>> getCandles(String exchange, String pair, String interval, int limit);
  Future<List<Market>> getMarkets(String exchange, String? marketType);
  
  // Technical indicators
  Future<double> calculateRSI(String exchange, String pair, int period);
  Future<BollingerBands> calculateBollingerBands(String exchange, String pair, int period, double stdDev);
  Future<MACD> calculateMACD(String exchange, String pair);
  
  // Backtesting tools
  Future<BacktestResult> runBacktest(BacktestRequest request);
  Future<OptimizationResult> optimizeParameters(OptimizationRequest request);
  Future<StrategyComparison> compareStrategies(List<String> strategies);
  
  // Account management
  Future<AccountInfo> getAccountInfo(String exchange);
  Future<Balance> getBalance(String exchange, String currency);
  Future<Portfolio> getPortfolio();
  
  // Risk management
  Future<PositionSize> calculatePositionSize(PositionSizeRequest request);
  Future<RiskState> getRiskState();
  Future<Exposure> getExposure(String? exchange);
}
```

### 3. Enhanced Provider Layer

#### Authentication Provider
```dart
class AuthenticationProvider extends StateNotifier<AuthState> {
  // JWT authentication
  Future<void> authenticateWithPhone(String phone, String otpCode);
  Future<void> refreshToken();
  void logout();
  
  // User level management
  void updateUserLevel(int level);
  bool hasAccessLevel(int requiredLevel);
  
  // Progressive upgrade
  Future<void> initiateUpgrade(int targetLevel);
}
```

#### Enhanced Trading Provider
```dart
class EnhancedTradingProvider extends StateNotifier<TradingState> {
  // Position management
  Future<void> loadPositions();
  Future<void> createPosition(CreatePositionRequest request);
  Future<void> closePosition(String positionId);
  
  // Technical indicators
  Future<void> loadTechnicalIndicators(String symbol);
  Future<void> refreshIndicators();
  
  // Real-time updates
  void subscribeToPositionUpdates();
  void subscribeToMarketData();
}
```

#### AI Analysis Provider
```dart
class AIAnalysisProvider extends StateNotifier<AIAnalysisState> {
  // Analysis management
  Future<void> requestCompleteAnalysis(String symbol);
  Future<void> requestSentimentAnalysis(String symbol);
  Future<void> requestLLMAnalysis(LLMAnalysisRequest request);
  
  // Cost monitoring
  Future<void> loadAICosts();
  void monitorCostLimits();
  
  // Performance tracking
  Future<void> loadStrategyPerformance();
}
```

#### Bot Control Provider
```dart
class BotControlProvider extends StateNotifier<BotState> {
  // Bot control
  Future<void> startBot();
  Future<void> stopBot();
  Future<void> pauseBot();
  Future<void> emergencyStop();
  
  // Configuration management
  Future<void> loadBotConfig();
  Future<void> updateBotConfig(BotConfig config);
  
  // Autonomous mode
  Future<void> enableAutonomousMode(AutonomousConfig config);
  Future<void> disableAutonomousMode();
  
  // Performance monitoring
  Future<void> loadBotPerformance();
  void subscribeToPerformanceUpdates();
}
```

## Data Models

### Authentication Models
```dart
class AuthState {
  final bool isAuthenticated;
  final String? jwtToken;
  final String? refreshToken;
  final int userLevel;
  final DateTime? tokenExpiry;
  final UserInfo? userInfo;
}

class UserInfo {
  final String id;
  final String phone;
  final int level;
  final String tenantId;
  final String companyId;
  final List<String> featuresEnabled;
  final Map<String, int> limits;
}
```

### Enhanced Trading Models
```dart
class Position {
  final String id;
  final String symbol;
  final String side;
  final double size;
  final double entryPrice;
  final double currentPrice;
  final double unrealizedPnl;
  final double pnlPercent;
  final DateTime createdAt;
  final DateTime? updatedAt;
}

class TechnicalIndicators {
  final double? rsi;
  final BollingerBands? bollingerBands;
  final MACD? macd;
  final DateTime timestamp;
  final String symbol;
  final String timeframe;
}

class BollingerBands {
  final double upper;
  final double middle;
  final double lower;
  final double bandwidth;
  final double percentB;
}

class MACD {
  final double macd;
  final double signal;
  final double histogram;
  final String trend;
}
```

### AI Analysis Models
```dart
class CompleteAnalysis {
  final String symbol;
  final String exchange;
  final DateTime timestamp;
  final FormattedAnalysis formattedAnalysis;
  final Map<String, dynamic> rawData;
  final AnalysisSummary summary;
}

class FormattedAnalysis {
  final String systemStatus;
  final String marketAnalysis;
  final String positionAnalysis;
  final String aiAnalysis;
  final String riskAssessment;
  final String recommendations;
}

class LLMAnalysis {
  final String action;
  final double confidence;
  final List<String> reasoning;
  final double entryPrice;
  final double stopLoss;
  final double takeProfit;
  final String provider;
  final double cost;
}

class SentimentAnalysis {
  final String symbol;
  final SentimentData sentiment;
  final SentimentInterpretation interpretation;
  final Map<String, int> dataCounts;
}
```

### Bot Control Models
```dart
class BotState {
  final BotStatus status;
  final BotConfig config;
  final BotPerformance? performance;
  final AutonomousStatus? autonomousStatus;
  final List<BotAction> recentActions;
}

class BotStatus {
  final String state;
  final bool autonomousMode;
  final PositionSummary positions;
  final PerformanceSummary performance;
  final RiskSummary risk;
  final BotAction? lastAction;
}

class BotConfig {
  final bool dryRun;
  final bool autoExecute;
  final int maxPositions;
  final double positionSizeUsd;
  final double stopLossPercent;
  final double takeProfitPercent;
  final List<String> symbols;
  final List<String> timeframes;
  final List<String> strategies;
  final RiskManagementConfig riskManagement;
}
```

### MCP Tool Models
```dart
class BacktestResult {
  final double roi;
  final double sharpeRatio;
  final double maxDrawdown;
  final int totalTrades;
  final double winRate;
  final double profitFactor;
  final List<Trade> trades;
}

class OptimizationResult {
  final String optimizationId;
  final String status;
  final Map<String, dynamic> bestParameters;
  final Map<String, dynamic> performanceMetrics;
  final List<OptimizationStep> steps;
}

class StrategyComparison {
  final String comparisonId;
  final List<String> strategies;
  final List<Map<String, dynamic>> results;
  final Map<String, dynamic> summary;
  final ComparisonMetrics metrics;
}
```

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property Reflection

After reviewing all properties identified in the prework analysis, I've identified several areas where properties can be consolidated to eliminate redundancy:

1. **Authentication Properties (1.1-1.5)** - These are distinct and each provides unique validation value
2. **MCP Client Properties (2.1-2.5)** - These are distinct protocol-level validations
3. **Technical Indicator Properties (3.1-3.5)** - These can be partially consolidated
4. **AI Analysis Properties (4.1-4.5)** - These are distinct functional validations
5. **Position Management Properties (5.1-5.5)** - These are distinct trading validations
6. **Bot Control Properties (6.1-6.5)** - These are distinct autonomous trading validations
7. **Backtesting Properties (7.1-7.5)** - These are distinct analysis validations
8. **Error Handling Properties (8.1-8.5)** - These are distinct resilience validations
9. **Performance Properties (9.1-9.5)** - These are distinct optimization validations
10. **Compatibility Properties (10.1-10.5)** - These are distinct backward compatibility validations

**Consolidations Made:**
- Properties 3.3 and 9.4 both deal with automatic refresh - consolidated into Property 3.3
- Properties 8.1 and 8.3 both deal with retry logic - kept separate as they handle different scenarios
- Properties 9.2 and 9.5 both deal with serving cached data - consolidated into Property 9.2

### Authentication and Configuration Properties

**Property 1: MATP Client Configuration**
*For any* Flutter app initialization, the MATP API client should be configured with the correct Kong Gateway base URL and default headers
**Validates: Requirements 1.1**

**Property 2: JWT Authentication Flow**
*For any* valid phone number and OTP code, the authentication service should obtain JWT tokens and configure automatic header injection
**Validates: Requirements 1.2**

**Property 3: Authorization Header Injection**
*For any* API call made through the MATP client, the request should automatically include Authorization headers with valid JWT tokens
**Validates: Requirements 1.3**

**Property 4: Automatic Token Refresh**
*For any* expired JWT token, the system should automatically refresh the token without user intervention
**Validates: Requirements 1.4**

**Property 5: Rate Limit Handling**
*For any* 429 response from the API, the system should handle the rate limit gracefully and inform the user appropriately
**Validates: Requirements 1.5**

### MCP Protocol Properties

**Property 6: MCP Client Configuration**
*For any* Flutter app initialization, the MCP client should be configured with JSON-RPC 2.0 protocol and correct gateway URL
**Validates: Requirements 2.1**

**Property 7: JSON-RPC Request Formatting**
*For any* MCP tool call, the request should be formatted according to JSON-RPC 2.0 specification with proper method, params, and id fields
**Validates: Requirements 2.2**

**Property 8: JSON-RPC Response Parsing**
*For any* valid JSON-RPC response, the system should correctly parse the response and extract tool results
**Validates: Requirements 2.3**

**Property 9: MCP Error Handling**
*For any* JSON-RPC error response, the system should handle the error appropriately and provide meaningful feedback
**Validates: Requirements 2.4**

**Property 10: MCP Timeout Handling**
*For any* MCP tool call that times out, the system should implement proper timeout handling with user feedback
**Validates: Requirements 2.5**

### Technical Analysis Properties

**Property 11: Technical Indicator Calculation**
*For any* request for technical indicators (RSI, MACD, Bollinger Bands), the system should call the appropriate MCP tools and return calculated values
**Validates: Requirements 3.1**

**Property 12: Indicator Display Formatting**
*For any* completed indicator calculation, the system should display results in an intuitive and consistent format
**Validates: Requirements 3.2**

**Property 13: Automatic Indicator Refresh**
*For any* market data update or stale data detection, the system should refresh indicators automatically based on configured intervals
**Validates: Requirements 3.3, 9.4**

**Property 14: Indicator Error Handling**
*For any* failed indicator calculation, the system should display appropriate error messages without crashing
**Validates: Requirements 3.4**

**Property 15: Multi-Timeframe Indicator Support**
*For any* selection of multiple timeframes, the system should calculate indicators for each timeframe independently
**Validates: Requirements 3.5**

### AI Analysis Properties

**Property 16: AI Analysis Execution**
*For any* AI analysis request, the system should call the appropriate MATP AI endpoints and return complete market analysis
**Validates: Requirements 4.1**

**Property 17: AI Analysis Display**
*For any* completed AI analysis, the system should display formatted analysis with clear recommendations
**Validates: Requirements 4.2**

**Property 18: Sentiment Analysis Retrieval**
*For any* sentiment analysis request, the system should retrieve and display market sentiment data from multiple sources
**Validates: Requirements 4.3**

**Property 19: LLM Analysis Execution**
*For any* LLM analysis request, the system should call LLM endpoints and display reasoning with confidence scores
**Validates: Requirements 4.4**

**Property 20: AI Cost Monitoring**
*For any* AI operation that would exceed cost limits, the system should warn users about budget constraints before execution
**Validates: Requirements 4.5**

### Position Management Properties

**Property 21: Position Retrieval and Display**
*For any* request to view positions, the system should retrieve current positions from MATP and display them accurately
**Validates: Requirements 5.1**

**Property 22: Position Creation Validation**
*For any* position creation request, the system should validate all parameters and submit orders via MATP with proper error handling
**Validates: Requirements 5.2**

**Property 23: Real-Time Position Updates**
*For any* position update that occurs, the system should reflect changes in the UI immediately
**Validates: Requirements 5.3**

**Property 24: Risk Limit Enforcement**
*For any* position creation that would exceed risk limits, the system should prevent the creation and warn the user
**Validates: Requirements 5.4**

**Property 25: Position Closing Updates**
*For any* position that is closed, the system should update the UI immediately and display the final PnL
**Validates: Requirements 5.5**

### Autonomous Bot Properties

**Property 26: Autonomous Mode Configuration**
*For any* request to enable autonomous mode, the system should configure bot parameters via MATP endpoints with proper validation
**Validates: Requirements 6.1**

**Property 27: Bot Status Display**
*For any* running bot, the system should display real-time status and performance metrics accurately
**Validates: Requirements 6.2**

**Property 28: Bot Action Logging**
*For any* bot action taken, the system should log and display trading decisions with timestamps and reasoning
**Validates: Requirements 6.3**

**Property 29: Emergency Stop Execution**
*For any* emergency stop trigger, the system should immediately halt all bot operations and confirm the stop
**Validates: Requirements 6.4**

**Property 30: Bot Performance Analytics**
*For any* bot performance review request, the system should display comprehensive statistics and analytics
**Validates: Requirements 6.5**

### Backtesting Properties

**Property 31: Backtest Execution**
*For any* backtest initiation, the system should call MCP backtest tools with specified parameters and return results
**Validates: Requirements 7.1**

**Property 32: Backtest Results Display**
*For any* completed backtest, the system should display comprehensive results including ROI, Sharpe ratio, and other key metrics
**Validates: Requirements 7.2**

**Property 33: Strategy Optimization**
*For any* strategy optimization request, the system should run parameter optimization via MCP tools and return optimal parameters
**Validates: Requirements 7.3**

**Property 34: Strategy Comparison**
*For any* request to compare multiple strategies, the system should display comparative analysis results with clear metrics
**Validates: Requirements 7.4**

**Property 35: Backtest Result Persistence**
*For any* backtest result that is saved, the system should persist the results and make them available for future reference
**Validates: Requirements 7.5**

### Error Handling and Resilience Properties

**Property 36: Network Error Retry Logic**
*For any* network error, the system should implement exponential backoff retry logic with appropriate limits
**Validates: Requirements 8.1**

**Property 37: Authentication Failure Handling**
*For any* authentication failure, the system should redirect users to the login flow and clear invalid tokens
**Validates: Requirements 8.2**

**Property 38: Rate Limit Queue Management**
*For any* API rate limit hit, the system should queue requests and retry after the reset time
**Validates: Requirements 8.3**

**Property 39: MCP Fallback Mechanisms**
*For any* MCP tool failure, the system should provide fallback mechanisms or serve cached data when available
**Validates: Requirements 8.4**

**Property 40: Critical Error Logging**
*For any* critical error, the system should log the error for debugging while maintaining user experience
**Validates: Requirements 8.5**

### Performance and Caching Properties

**Property 41: Intelligent Caching Implementation**
*For any* market data request, the system should implement intelligent caching with appropriate TTL values
**Validates: Requirements 9.1**

**Property 42: Cache-First Data Serving**
*For any* request where cached data exists or offline mode is detected, the system should serve cached data while refreshing in background with appropriate indicators
**Validates: Requirements 9.2, 9.5**

**Property 43: Request Deduplication**
*For any* multiple similar requests made within a short timeframe, the system should deduplicate requests to avoid redundant API calls
**Validates: Requirements 9.3**

### Backward Compatibility Properties

**Property 44: Service Interface Compatibility**
*For any* new service integration, the system should maintain existing service interfaces and not break current functionality
**Validates: Requirements 10.1**

**Property 45: Data Model Backward Compatibility**
*For any* data model update, the system should provide backward compatibility adapters for existing data structures
**Validates: Requirements 10.2**

**Property 46: API Endpoint Compatibility**
*For any* new endpoint addition, the system should not break existing API calls and maintain response format compatibility
**Validates: Requirements 10.3**

**Property 47: UI Workflow Preservation**
*For any* UI component update, the system should preserve existing user workflows and navigation patterns
**Validates: Requirements 10.4**

**Property 48: Configuration Migration**
*For any* configuration change, the system should migrate existing settings appropriately without data loss
**Validates: Requirements 10.5**

## Error Handling

### Error Hierarchy
```dart
abstract class IntegrationException implements Exception {
  final String message;
  final String? code;
  final Map<String, dynamic>? details;
  
  const IntegrationException(this.message, {this.code, this.details});
}

class MATPApiException extends IntegrationException {
  final int? statusCode;
  final String? retryAfter;
  
  const MATPApiException(String message, {
    this.statusCode,
    this.retryAfter,
    String? code,
    Map<String, dynamic>? details,
  }) : super(message, code: code, details: details);
}

class MCPException extends IntegrationException {
  final int? rpcErrorCode;
  final String? rpcErrorData;
  
  const MCPException(String message, {
    this.rpcErrorCode,
    this.rpcErrorData,
    String? code,
    Map<String, dynamic>? details,
  }) : super(message, code: code, details: details);
}

class AuthenticationException extends IntegrationException {
  final bool tokenExpired;
  final bool refreshFailed;
  
  const AuthenticationException(String message, {
    this.tokenExpired = false,
    this.refreshFailed = false,
    String? code,
    Map<String, dynamic>? details,
  }) : super(message, code: code, details: details);
}
```

### Error Handling Strategies

1. **Network Errors**: Exponential backoff with jitter
2. **Authentication Errors**: Automatic token refresh, fallback to login
3. **Rate Limiting**: Request queuing with retry after reset time
4. **MCP Tool Errors**: Fallback to cached data or alternative tools
5. **Validation Errors**: User-friendly messages with correction suggestions

### Fallback Mechanisms

1. **Cached Data Serving**: When APIs are unavailable
2. **Degraded Functionality**: Core features remain available
3. **Offline Mode**: Essential data accessible without network
4. **Alternative Endpoints**: Failover between MATP and MCP when possible

## Testing Strategy

### Unit Testing Approach

Unit tests will focus on:
- Individual service method functionality
- Data model serialization/deserialization
- Error handling for specific scenarios
- Authentication flow components
- MCP tool call formatting and parsing

### Property-Based Testing Approach

Property-based tests will verify universal properties using **fast_check** for Dart/Flutter. Each property-based test will run a minimum of 100 iterations to ensure comprehensive coverage.

**Property-Based Testing Requirements:**
- Use fast_check library for Dart property-based testing
- Configure each test to run minimum 100 iterations
- Tag each test with format: `**Feature: backend-integration-update, Property {number}: {property_text}**`
- Each correctness property must be implemented by a single property-based test
- Focus on universal behaviors that should hold across all valid inputs

**Test Categories:**
1. **Authentication Properties**: JWT token handling, refresh logic, header injection
2. **MCP Protocol Properties**: JSON-RPC formatting, response parsing, error handling
3. **API Integration Properties**: Request/response cycles, error recovery, caching
4. **Data Consistency Properties**: Model transformations, backward compatibility
5. **Performance Properties**: Caching behavior, request deduplication, timeout handling

### Integration Testing

Integration tests will cover:
- End-to-end authentication flows
- Complete trading workflows
- AI analysis request/response cycles
- Bot control operations
- Cross-service data consistency

### Testing Tools and Frameworks

- **Unit Tests**: Flutter test framework with mockito for mocking
- **Property-Based Tests**: fast_check for Dart
- **Integration Tests**: Flutter integration test framework
- **API Testing**: Dio interceptors for request/response validation
- **Mock Services**: JSON-RPC mock server for MCP testing

The testing strategy ensures both specific functionality (unit tests) and general correctness (property tests) are thoroughly validated, providing comprehensive coverage for the integration.