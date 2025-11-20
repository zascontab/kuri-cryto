# Trading MCP Server - API Documentation

**Version:** 1.1.0  
**Last Updated:** 2025-11-16  
**Base URL (API Gateway):** `http://192.168.100.145:9090` ⭐ **RECOMMENDED**  
**Base URL (REST - Direct):** `http://192.168.100.145:8081/api/v1`  
**Base URL (MCP - Direct):** `http://192.168.100.145:10600`  
**Base URL (MCP via Gateway):** `http://192.168.100.145:9090/api/mcp`

---

## Table of Contents

1. [Overview](#overview)
2. [Authentication](#authentication)
3. [REST API Endpoints](#rest-api-endpoints)
4. [MCP Tools (AI Agent Interface)](#mcp-tools-ai-agent-interface)
5. [WebSocket API](#websocket-api)
6. [New Endpoints (Planned)](#new-endpoints-planned)
7. [Data Models](#data-models)
8. [Error Handling](#error-handling)

---

## Overview

El Trading MCP Server expone dos tipos de APIs:

1. **REST API** - Para aplicaciones tradicionales (Flutter, web apps)
2. **MCP Tools** - Para AI agents (Claude, GPT, etc.)

Ambas APIs comparten la misma lógica de negocio pero tienen diferentes interfaces.

### 🚀 API Gateway (Recommended)

**Endpoint único para Flutter:** `http://192.168.100.145:9090`

El API Gateway unifica todos los servicios en un solo puerto, simplificando la integración:

- **Puerto único:** 9090 (evita conflictos con Docker en 8080)
- **CORS habilitado:** Configurado para aplicaciones móviles
- **Proxy inteligente:** Enruta automáticamente a los servicios correctos
- **Logging centralizado:** Todos los requests en un solo lugar

#### Rutas del Gateway

| Ruta | Destino | Descripción |
|------|---------|-------------|
| `/health` | Gateway | Health check del gateway |
| `/api/gateway/info` | Gateway | Información del gateway |
| `/api/mcp/*` | MCP Server (10600) | Herramientas de trading MCP |
| `/api/scalping/*` | Scalping API (8081) | API de scalping |
| `/` | MCP Server (10600) | Root MCP endpoint |

#### Ejemplo de Uso (Flutter)

```dart
// Configuración simple - un solo endpoint
final String apiGatewayUrl = 'http://192.168.100.145:9090';

// Scalping API
final scalpingHealth = await dio.get('$apiGatewayUrl/api/scalping/api/v1/scalping/health');

// MCP Tools
final mcpTools = await dio.get('$apiGatewayUrl/api/mcp/tools');
```

---

## Authentication

### Current Implementation
- **No authentication required** (development mode)
- API keys en variables de entorno para exchanges

### Planned (Phase 3)
- JWT tokens para REST API
- API key authentication para MCP
- Rate limiting por usuario


---

## REST API Endpoints

### Base URL

**Via Gateway (Recommended):** `http://192.168.100.145:9090/api/scalping/api/v1/scalping`  
**Direct:** `http://192.168.100.145:8081/api/v1/scalping`

---

### 1. System Status & Health

#### GET `/status`
Get current system status

**Response:**
```json
{
  "success": true,
  "data": {
    "running": true,
    "uptime": "2h30m15s",
    "pairs_count": 3,
    "active_strategies": 5,
    "health_status": "healthy",
    "errors": []
  }
}
```

#### GET `/metrics`
Get system metrics

**Response:**
```json
{
  "success": true,
  "data": {
    "total_trades": 145,
    "win_rate": 62.5,
    "total_pnl": 125.50,
    "daily_pnl": 15.25,
    "avg_latency_ms": 45,
    "active_positions": 2
  }
}
```

#### GET `/health`
Health check endpoint

**Response:**
```json
{
  "success": true,
  "data": {
    "status": "healthy",
    "running": true,
    "uptime": "2h30m15s",
    "errors": [],
    "timestamp": "2025-11-16T10:30:00Z"
  }
}
```

---

### 2. Position Management

#### GET `/positions`
Get all open positions

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "pos_123",
      "symbol": "DOGE-USDT",
      "side": "long",
      "entry_price": 0.08500,
      "current_price": 0.08650,
      "size": 1000,
      "leverage": 2,
      "unrealized_pnl": 15.00,
      "stop_loss": 0.08350,
      "take_profit": 0.08750,
      "open_time": "2025-11-16T10:00:00Z",
      "strategy": "rsi_scalping"
    }
  ],
  "count": 1
}
```

#### GET `/positions/history`
Get position history

**Query Parameters:**
- `limit` (optional): Number of records (default: 100)
- `from` (optional): Start date (ISO 8601)
- `to` (optional): End date (ISO 8601)

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "pos_122",
      "symbol": "BTC-USDT",
      "side": "short",
      "entry_price": 43500.00,
      "exit_price": 43200.00,
      "size": 0.1,
      "realized_pnl": 30.00,
      "open_time": "2025-11-16T09:00:00Z",
      "close_time": "2025-11-16T09:15:00Z",
      "close_reason": "take_profit"
    }
  ],
  "count": 1
}
```

---

### 3. Strategy Management

#### GET `/strategies`
Get all strategies

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "name": "rsi_scalping",
      "active": true,
      "weight": 0.25,
      "performance": {
        "total_trades": 50,
        "win_rate": 65.0,
        "total_pnl": 45.50,
        "sharpe_ratio": 1.8
      }
    }
  ],
  "count": 5
}
```

#### GET `/strategies/:name`
Get specific strategy details

**Response:**
```json
{
  "success": true,
  "data": {
    "name": "rsi_scalping",
    "active": true,
    "weight": 0.25,
    "performance": {
      "total_trades": 50,
      "win_rate": 65.0,
      "total_pnl": 45.50,
      "avg_win": 2.50,
      "avg_loss": -1.20,
      "sharpe_ratio": 1.8,
      "max_drawdown": -5.5
    }
  }
}
```

#### POST `/strategies/:name/start`
Start a strategy

**Response:**
```json
{
  "success": true,
  "message": "Strategy started successfully"
}
```

#### POST `/strategies/:name/stop`
Stop a strategy

**Response:**
```json
{
  "success": true,
  "message": "Strategy stopped successfully"
}
```

#### PUT `/strategies/:name/config`
Update strategy configuration

**Request Body:**
```json
{
  "rsi_period": 14,
  "rsi_oversold": 30,
  "rsi_overbought": 70,
  "take_profit_pct": 0.8,
  "stop_loss_pct": 0.4
}
```

**Response:**
```json
{
  "success": true,
  "message": "Strategy configuration updated successfully"
}
```

#### GET `/strategies/:name/performance`
Get strategy performance metrics

**Response:**
```json
{
  "success": true,
  "data": {
    "total_trades": 50,
    "win_rate": 65.0,
    "total_pnl": 45.50,
    "avg_win": 2.50,
    "avg_loss": -1.20,
    "sharpe_ratio": 1.8,
    "max_drawdown": -5.5,
    "profit_factor": 2.1
  }
}
```

---

### 4. Risk Management

#### GET `/risk/limits`
Get current risk limits

**Response:**
```json
{
  "success": true,
  "data": {
    "parameters": {
      "max_position_size_usd": 50.0,
      "max_total_exposure_usd": 100.0,
      "stop_loss_percent": 0.5,
      "take_profit_percent": 1.0,
      "max_daily_loss_usd": 20.0,
      "max_consecutive_losses": 3
    },
    "can_trade": true,
    "limit_reason": "",
    "current_exposure": 35.50,
    "daily_pnl": 5.25,
    "consecutive_losses": 0
  }
}
```

#### PUT `/risk/limits`
Update risk limits

**Request Body:**
```json
{
  "max_position_size_usd": 50.0,
  "max_total_exposure_usd": 100.0,
  "stop_loss_percent": 0.5,
  "take_profit_percent": 1.0,
  "max_daily_loss_usd": 20.0,
  "max_consecutive_losses": 3
}
```

**Response:**
```json
{
  "success": true,
  "message": "Risk parameters updated successfully"
}
```

#### GET `/risk/exposure`
Get current exposure

**Response:**
```json
{
  "success": true,
  "data": {
    "current_exposure": 35.50,
    "max_exposure": 100.0,
    "exposure_percent": 35.5,
    "available_exposure": 64.50
  }
}
```

---

### 5. Execution & Performance

#### GET `/execution/latency`
Get latency statistics

**Response:**
```json
{
  "success": true,
  "data": {
    "avg_latency_ms": 45,
    "p50_latency_ms": 40,
    "p95_latency_ms": 75,
    "p99_latency_ms": 120,
    "max_latency_ms": 250
  }
}
```

#### GET `/execution/history`
Get execution history

**Query Parameters:**
- `limit` (optional): Number of records (default: 50)

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "order_id": "ord_123",
      "symbol": "DOGE-USDT",
      "side": "buy",
      "type": "market",
      "size": 1000,
      "price": 0.08500,
      "status": "filled",
      "latency_ms": 45,
      "timestamp": "2025-11-16T10:00:00Z"
    }
  ],
  "count": 1
}
```

---

### 6. Engine Control

#### POST `/start`
Start the scalping engine

**Response:**
```json
{
  "success": true,
  "message": "Scalping engine started successfully"
}
```

#### POST `/stop`
Stop the scalping engine

**Response:**
```json
{
  "success": true,
  "message": "Scalping engine stopped successfully"
}
```

#### POST `/pairs/add`
Add a trading pair

**Request Body:**
```json
{
  "exchange": "kucoin",
  "pair": "DOGE-USDT"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Pair added successfully"
}
```

#### POST `/pairs/remove`
Remove a trading pair

**Request Body:**
```json
{
  "exchange": "kucoin",
  "pair": "DOGE-USDT"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Pair removed successfully"
}
```


---

## MCP Tools (AI Agent Interface)

MCP Tools are callable functions for AI agents. They use JSON-RPC 2.0 protocol.

### Market Data Tools

#### `get_ticker`
Get current ticker data

**Parameters:**
```json
{
  "exchange": "kucoin",
  "pair": "BTC-USDT"
}
```

**Returns:**
```json
{
  "exchange": "kucoin",
  "pair": "BTC-USDT",
  "last": 43500.00,
  "bid": 43495.00,
  "ask": 43505.00,
  "volume": 1234.56,
  "timestamp": "2025-11-16T10:00:00Z"
}
```

#### `get_orderbook`
Get order book

**Parameters:**
```json
{
  "exchange": "kucoin",
  "pair": "BTC-USDT",
  "depth": 20
}
```

#### `get_candles`
Get historical candles

**Parameters:**
```json
{
  "exchange": "kucoin",
  "pair": "BTC-USDT",
  "interval": "1m",
  "limit": 100
}
```

#### `get_trades`
Get recent trades

**Parameters:**
```json
{
  "exchange": "kucoin",
  "pair": "BTC-USDT",
  "limit": 50
}
```

#### `get_24h_stats`
Get 24-hour statistics

**Parameters:**
```json
{
  "exchange": "kucoin",
  "pair": "BTC-USDT"
}
```

#### `get_markets`
Get all available markets

**Parameters:**
```json
{
  "exchange": "kucoin"
}
```

#### `get_exchange_info`
Get exchange information

**Parameters:**
```json
{
  "exchange": "kucoin"
}
```

#### `get_funding_rate`
Get futures funding rate

**Parameters:**
```json
{
  "exchange": "kucoin",
  "pair": "BTC-USDT"
}
```

#### `get_open_interest`
Get futures open interest

**Parameters:**
```json
{
  "exchange": "kucoin",
  "pair": "BTC-USDT"
}
```

#### `get_liquidations`
Get recent liquidations

**Parameters:**
```json
{
  "exchange": "kucoin",
  "pair": "BTC-USDT",
  "limit": 50
}
```

---

### Technical Analysis Tools

#### `calculate_rsi`
Calculate RSI indicator

**Parameters:**
```json
{
  "exchange": "kucoin",
  "pair": "BTC-USDT",
  "interval": "1m",
  "period": 14,
  "limit": 100
}
```

**Returns:**
```json
{
  "rsi": 65.5,
  "values": [60.2, 62.1, 65.5],
  "signal": "neutral",
  "timestamp": "2025-11-16T10:00:00Z"
}
```

#### `calculate_macd`
Calculate MACD indicator

**Parameters:**
```json
{
  "exchange": "kucoin",
  "pair": "BTC-USDT",
  "interval": "1m",
  "fast_period": 12,
  "slow_period": 26,
  "signal_period": 9,
  "limit": 100
}
```

#### `calculate_bollinger`
Calculate Bollinger Bands

**Parameters:**
```json
{
  "exchange": "kucoin",
  "pair": "BTC-USDT",
  "interval": "1m",
  "period": 20,
  "std_dev": 2,
  "limit": 100
}
```

#### `calculate_ema`
Calculate Exponential Moving Average

**Parameters:**
```json
{
  "exchange": "kucoin",
  "pair": "BTC-USDT",
  "interval": "1m",
  "period": 20,
  "limit": 100
}
```

#### `calculate_sma`
Calculate Simple Moving Average

**Parameters:**
```json
{
  "exchange": "kucoin",
  "pair": "BTC-USDT",
  "interval": "1m",
  "period": 20,
  "limit": 100
}
```

#### `calculate_atr`
Calculate Average True Range

**Parameters:**
```json
{
  "exchange": "kucoin",
  "pair": "BTC-USDT",
  "interval": "1m",
  "period": 14,
  "limit": 100
}
```

#### `calculate_stochastic`
Calculate Stochastic Oscillator

**Parameters:**
```json
{
  "exchange": "kucoin",
  "pair": "BTC-USDT",
  "interval": "1m",
  "k_period": 14,
  "d_period": 3,
  "limit": 100
}
```

#### `detect_patterns`
Detect candlestick patterns

**Parameters:**
```json
{
  "exchange": "kucoin",
  "pair": "BTC-USDT",
  "interval": "1m",
  "limit": 100
}
```

#### `generate_signals`
Generate trading signals

**Parameters:**
```json
{
  "exchange": "kucoin",
  "pair": "BTC-USDT",
  "interval": "1m",
  "strategies": ["rsi", "macd", "bollinger"]
}
```

---

### Order Management Tools

#### `submit_order`
Submit a new order

**Parameters:**
```json
{
  "exchange": "kucoin",
  "pair": "BTC-USDT",
  "side": "buy",
  "type": "limit",
  "amount": 0.001,
  "price": 43000.00
}
```

#### `submit_market_order`
Submit a market order

**Parameters:**
```json
{
  "exchange": "kucoin",
  "pair": "BTC-USDT",
  "side": "buy",
  "amount": 0.001
}
```

#### `submit_limit_order`
Submit a limit order

**Parameters:**
```json
{
  "exchange": "kucoin",
  "pair": "BTC-USDT",
  "side": "buy",
  "amount": 0.001,
  "price": 43000.00
}
```

#### `submit_stop_order`
Submit a stop order

**Parameters:**
```json
{
  "exchange": "kucoin",
  "pair": "BTC-USDT",
  "side": "sell",
  "amount": 0.001,
  "stop_price": 42000.00
}
```

#### `cancel_order`
Cancel an order

**Parameters:**
```json
{
  "exchange": "kucoin",
  "order_id": "ord_123"
}
```

#### `cancel_all_orders`
Cancel all orders

**Parameters:**
```json
{
  "exchange": "kucoin",
  "pair": "BTC-USDT"
}
```

#### `get_order_status`
Get order status

**Parameters:**
```json
{
  "exchange": "kucoin",
  "order_id": "ord_123"
}
```

#### `get_open_orders`
Get all open orders

**Parameters:**
```json
{
  "exchange": "kucoin",
  "pair": "BTC-USDT"
}
```

#### `get_order_history`
Get order history

**Parameters:**
```json
{
  "exchange": "kucoin",
  "pair": "BTC-USDT",
  "limit": 100
}
```

---

### Portfolio Management Tools

#### `get_portfolio`
Get portfolio summary

**Parameters:**
```json
{
  "exchange": "kucoin"
}
```

**Returns:**
```json
{
  "total_value_usd": 1250.50,
  "available_balance": 500.00,
  "in_orders": 750.50,
  "assets": [
    {
      "currency": "BTC",
      "balance": 0.025,
      "available": 0.020,
      "in_orders": 0.005,
      "value_usd": 1087.50
    }
  ]
}
```

#### `get_balance`
Get account balance

**Parameters:**
```json
{
  "exchange": "kucoin",
  "currency": "USDT"
}
```

#### `get_positions`
Get open positions

**Parameters:**
```json
{
  "exchange": "kucoin"
}
```

#### `get_pnl`
Get profit and loss

**Parameters:**
```json
{
  "exchange": "kucoin",
  "period": "daily"
}
```

#### `get_trade_history`
Get trade history

**Parameters:**
```json
{
  "exchange": "kucoin",
  "pair": "BTC-USDT",
  "limit": 100
}
```

---

### Risk Management Tools

#### `check_risk_limits`
Check if trade is within risk limits

**Parameters:**
```json
{
  "exchange": "kucoin",
  "pair": "BTC-USDT",
  "side": "buy",
  "amount": 0.001,
  "price": 43000.00
}
```

**Returns:**
```json
{
  "allowed": true,
  "reason": "",
  "max_size": 0.002,
  "warnings": []
}
```

#### `calculate_position_size`
Calculate optimal position size

**Parameters:**
```json
{
  "exchange": "kucoin",
  "pair": "BTC-USDT",
  "risk_percent": 1.0,
  "stop_loss_percent": 2.0
}
```

#### `calculate_stop_loss`
Calculate stop loss price

**Parameters:**
```json
{
  "exchange": "kucoin",
  "pair": "BTC-USDT",
  "entry_price": 43000.00,
  "side": "buy",
  "atr_multiplier": 2.0
}
```

#### `calculate_take_profit`
Calculate take profit price

**Parameters:**
```json
{
  "exchange": "kucoin",
  "pair": "BTC-USDT",
  "entry_price": 43000.00,
  "side": "buy",
  "risk_reward_ratio": 2.0
}
```

#### `get_exposure`
Get current exposure

**Parameters:**
```json
{
  "exchange": "kucoin"
}
```

---

### Scalping Tools

#### `analyze_opportunity`
Analyze scalping opportunity

**Parameters:**
```json
{
  "exchange": "kucoin",
  "pair": "DOGE-USDT",
  "timeframes": ["1m", "3m", "5m"]
}
```

**Returns:**
```json
{
  "signal": "long",
  "confidence": 0.85,
  "entry_price": 0.08500,
  "stop_loss": 0.08350,
  "take_profit": 0.08750,
  "indicators": {
    "rsi_7": 28.5,
    "rsi_14": 35.2,
    "macd_histogram": 0.00015,
    "bollinger_position": "lower"
  }
}
```

#### `get_signals`
Get current trading signals

**Parameters:**
```json
{
  "exchange": "kucoin",
  "pairs": ["DOGE-USDT", "BTC-USDT"]
}
```

#### `execute_trade`
Execute a scalping trade

**Parameters:**
```json
{
  "exchange": "kucoin",
  "pair": "DOGE-USDT",
  "side": "buy",
  "amount": 1000,
  "stop_loss_pct": 0.4,
  "take_profit_pct": 0.8
}
```

#### `start_bot`
Start scalping bot

**Parameters:**
```json
{
  "exchange": "kucoin",
  "pairs": ["DOGE-USDT"],
  "strategies": ["rsi_scalping", "macd_scalping"]
}
```

#### `bot_status`
Get bot status

**Parameters:**
```json
{}
```

#### `stop_bot`
Stop scalping bot

**Parameters:**
```json
{}
```

#### `get_futures_positions`
Get futures positions

**Parameters:**
```json
{
  "exchange": "kucoin"
}
```

#### `close_futures_position`
Close a futures position

**Parameters:**
```json
{
  "exchange": "kucoin",
  "symbol": "DOGE-USDT",
  "position_id": "pos_123"
}
```


---

## New Endpoints (Planned)

Estos endpoints se agregarán durante la implementación de las funciones avanzadas.

### Phase 0: Critical Safety (Week 1-2)

#### POST `/api/v1/risk/sentinel/state`
Get Risk Sentinel state

**Response:**
```json
{
  "success": true,
  "data": {
    "current_drawdown_daily": 2.5,
    "current_drawdown_weekly": 5.0,
    "current_drawdown_monthly": 8.5,
    "total_exposure": 45.50,
    "exposure_by_symbol": {
      "DOGE-USDT": 25.00,
      "BTC-USDT": 20.50
    },
    "consecutive_losses": 1,
    "risk_mode": "Normal",
    "kill_switch_active": false,
    "last_update": "2025-11-16T10:30:00Z"
  }
}
```

#### POST `/api/v1/risk/sentinel/kill-switch`
Activate kill switch

**Request Body:**
```json
{
  "reason": "Manual activation - high volatility"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Kill switch activated",
  "timestamp": "2025-11-16T10:30:00Z"
}
```

#### DELETE `/api/v1/risk/sentinel/kill-switch`
Deactivate kill switch

**Response:**
```json
{
  "success": true,
  "message": "Kill switch deactivated",
  "timestamp": "2025-11-16T10:30:00Z"
}
```

#### GET `/api/v1/positions/manager/state`
Get Position Manager state

**Response:**
```json
{
  "success": true,
  "data": {
    "open_positions": 2,
    "total_exposure": 45.50,
    "positions": [
      {
        "id": "pos_123",
        "symbol": "DOGE-USDT",
        "side": "long",
        "entry_price": 0.08500,
        "current_price": 0.08650,
        "size": 1000,
        "leverage": 2,
        "stop_loss": 0.08350,
        "take_profit": 0.08750,
        "unrealized_pnl": 15.00,
        "status": "open"
      }
    ]
  }
}
```

#### PUT `/api/v1/positions/:id/sltp`
Update position SL/TP

**Request Body:**
```json
{
  "stop_loss": 0.08400,
  "take_profit": 0.08800
}
```

**Response:**
```json
{
  "success": true,
  "message": "SL/TP updated successfully"
}
```

#### POST `/api/v1/positions/:id/breakeven`
Move SL to breakeven

**Response:**
```json
{
  "success": true,
  "message": "Stop loss moved to breakeven",
  "new_stop_loss": 0.08500
}
```

#### POST `/api/v1/positions/:id/trailing-stop`
Enable trailing stop

**Request Body:**
```json
{
  "distance_percent": 0.2
}
```

**Response:**
```json
{
  "success": true,
  "message": "Trailing stop enabled"
}
```

---

### Phase 1: Scalping Foundation (Week 3-4)

#### POST `/api/v1/analysis/multi-timeframe`
Analyze multiple timeframes

**Request Body:**
```json
{
  "exchange": "kucoin",
  "symbol": "DOGE-USDT",
  "timeframes": ["1m", "3m", "5m", "15m"]
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "symbol": "DOGE-USDT",
    "timestamp": "2025-11-16T10:30:00Z",
    "timeframes": {
      "1m": {
        "rsi": 28.5,
        "macd": {
          "macd": 0.00015,
          "signal": 0.00012,
          "histogram": 0.00003
        },
        "bollinger": {
          "upper": 0.08750,
          "middle": 0.08500,
          "lower": 0.08250
        },
        "trend": "up",
        "signal": "long",
        "strength": 0.85
      }
    },
    "consensus": {
      "direction": "long",
      "strength": 0.82,
      "confidence": 0.88,
      "confirming_timeframes": ["1m", "3m", "5m"],
      "conflicting_timeframes": []
    }
  }
}
```

#### POST `/api/v1/backtest/run`
Run backtest

**Request Body:**
```json
{
  "exchange": "kucoin",
  "symbol": "DOGE-USDT",
  "strategy": "rsi_macd_bollinger",
  "start_date": "2025-08-01",
  "end_date": "2025-11-01",
  "initial_capital": 100.0,
  "config": {
    "rsi_period": 14,
    "take_profit_pct": 0.8,
    "stop_loss_pct": 0.4
  }
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "total_trades": 145,
    "winning_trades": 92,
    "losing_trades": 53,
    "win_rate": 63.4,
    "total_pnl": 125.50,
    "avg_win": 2.50,
    "avg_loss": -1.20,
    "profit_factor": 2.08,
    "sharpe_ratio": 1.85,
    "max_drawdown": -8.5,
    "max_drawdown_pct": -8.5,
    "trades": []
  }
}
```

#### GET `/api/v1/backtest/results/:id`
Get backtest results

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "bt_123",
    "status": "completed",
    "metrics": {},
    "trades": [],
    "equity_curve": []
  }
}
```

---

### Phase 2: HFT Optimization (Week 5-6)

#### GET `/api/v1/execution/queue`
Get order queue status

**Response:**
```json
{
  "success": true,
  "data": {
    "pending_orders": 3,
    "processing_orders": 1,
    "completed_orders": 145,
    "failed_orders": 2,
    "queue": [
      {
        "order_id": "ord_124",
        "symbol": "DOGE-USDT",
        "side": "buy",
        "status": "pending",
        "priority": 1,
        "created_at": "2025-11-16T10:30:00Z"
      }
    ]
  }
}
```

#### GET `/api/v1/execution/performance`
Get execution performance metrics

**Response:**
```json
{
  "success": true,
  "data": {
    "avg_latency_ms": 45,
    "p50_latency_ms": 40,
    "p95_latency_ms": 75,
    "p99_latency_ms": 120,
    "avg_slippage_pct": 0.05,
    "fill_rate": 98.5,
    "order_errors": 2,
    "total_orders": 145
  }
}
```

#### POST `/api/v1/monitoring/metrics/export`
Export metrics

**Request Body:**
```json
{
  "format": "json",
  "period": "daily",
  "metrics": ["pnl", "win_rate", "latency"]
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "period": "2025-11-16",
    "metrics": {
      "pnl": 15.25,
      "win_rate": 62.5,
      "avg_latency_ms": 45
    }
  }
}
```

---

### Phase 3: Scaling & Production (Week 7-8)

#### GET `/api/v1/pairs/correlation`
Get pair correlation matrix

**Response:**
```json
{
  "success": true,
  "data": {
    "matrix": {
      "BTC-USDT": {
        "ETH-USDT": 0.85,
        "DOGE-USDT": 0.65
      },
      "ETH-USDT": {
        "BTC-USDT": 0.85,
        "DOGE-USDT": 0.70
      }
    },
    "timestamp": "2025-11-16T10:30:00Z"
  }
}
```

#### POST `/api/v1/optimization/run`
Run parameter optimization

**Request Body:**
```json
{
  "strategy": "rsi_scalping",
  "symbol": "DOGE-USDT",
  "parameters": {
    "rsi_period": [7, 14, 21],
    "rsi_oversold": [20, 25, 30],
    "rsi_overbought": [70, 75, 80]
  },
  "optimization_method": "grid_search",
  "objective": "sharpe_ratio"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "optimization_id": "opt_123",
    "status": "running",
    "estimated_time": "5m"
  }
}
```

#### GET `/api/v1/optimization/results/:id`
Get optimization results

**Response:**
```json
{
  "success": true,
  "data": {
    "optimization_id": "opt_123",
    "status": "completed",
    "best_parameters": {
      "rsi_period": 14,
      "rsi_oversold": 25,
      "rsi_overbought": 75
    },
    "best_score": 2.15,
    "all_results": []
  }
}
```

#### POST `/api/v1/alerts/configure`
Configure alerts

**Request Body:**
```json
{
  "type": "telegram",
  "config": {
    "bot_token": "xxx",
    "chat_id": "xxx"
  },
  "rules": [
    {
      "trigger": "daily_drawdown",
      "threshold": 5.0,
      "severity": "critical"
    }
  ]
}
```

**Response:**
```json
{
  "success": true,
  "message": "Alerts configured successfully"
}
```

#### GET `/api/v1/alerts/history`
Get alert history

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "alert_123",
      "type": "daily_drawdown",
      "severity": "warning",
      "message": "Daily drawdown approaching limit: 4.5%",
      "timestamp": "2025-11-16T10:00:00Z",
      "acknowledged": false
    }
  ],
  "count": 1
}
```

#### POST `/api/v1/alerts/:id/acknowledge`
Acknowledge alert

**Response:**
```json
{
  "success": true,
  "message": "Alert acknowledged"
}
```

---

### MCP Tools (New)

#### `get_risk_state`
Get Risk Sentinel state

**Parameters:**
```json
{}
```

**Returns:**
```json
{
  "current_drawdown_daily": 2.5,
  "risk_mode": "Normal",
  "kill_switch_active": false,
  "can_trade": true
}
```

#### `activate_kill_switch`
Activate kill switch

**Parameters:**
```json
{
  "reason": "Manual activation"
}
```

#### `update_sltp`
Update position SL/TP

**Parameters:**
```json
{
  "position_id": "pos_123",
  "stop_loss": 0.08400,
  "take_profit": 0.08800
}
```

#### `analyze_multi_timeframe`
Analyze multiple timeframes

**Parameters:**
```json
{
  "exchange": "kucoin",
  "symbol": "DOGE-USDT",
  "timeframes": ["1m", "3m", "5m", "15m"]
}
```

#### `run_backtest`
Run strategy backtest

**Parameters:**
```json
{
  "exchange": "kucoin",
  "symbol": "DOGE-USDT",
  "strategy": "rsi_macd_bollinger",
  "start_date": "2025-08-01",
  "end_date": "2025-11-01"
}
```

#### `optimize_parameters`
Optimize strategy parameters

**Parameters:**
```json
{
  "strategy": "rsi_scalping",
  "symbol": "DOGE-USDT",
  "parameters": {
    "rsi_period": [7, 14, 21]
  }
}
```


---

## WebSocket API

### Connection

**URL:** `ws://localhost:8081/ws`

**Protocol:** WebSocket

### Subscribe to Events

**Message:**
```json
{
  "action": "subscribe",
  "channels": ["positions", "trades", "metrics", "alerts"]
}
```

### Events

#### Position Update
```json
{
  "type": "position_update",
  "data": {
    "id": "pos_123",
    "symbol": "DOGE-USDT",
    "unrealized_pnl": 15.50,
    "current_price": 0.08650
  },
  "timestamp": "2025-11-16T10:30:00Z"
}
```

#### Trade Executed
```json
{
  "type": "trade_executed",
  "data": {
    "order_id": "ord_123",
    "symbol": "DOGE-USDT",
    "side": "buy",
    "price": 0.08500,
    "size": 1000,
    "status": "filled"
  },
  "timestamp": "2025-11-16T10:30:00Z"
}
```

#### Metrics Update
```json
{
  "type": "metrics_update",
  "data": {
    "total_pnl": 125.50,
    "daily_pnl": 15.25,
    "win_rate": 62.5,
    "active_positions": 2
  },
  "timestamp": "2025-11-16T10:30:00Z"
}
```

#### Alert Triggered
```json
{
  "type": "alert",
  "data": {
    "severity": "warning",
    "message": "Daily drawdown approaching limit: 4.5%",
    "trigger": "daily_drawdown",
    "value": 4.5
  },
  "timestamp": "2025-11-16T10:30:00Z"
}
```

#### Kill Switch Activated
```json
{
  "type": "kill_switch",
  "data": {
    "active": true,
    "reason": "Daily drawdown limit exceeded",
    "timestamp": "2025-11-16T10:30:00Z"
  }
}
```

---

## Data Models

### Position
```typescript
interface Position {
  id: string;
  symbol: string;
  side: "long" | "short";
  entry_price: number;
  current_price: number;
  size: number;
  leverage: number;
  stop_loss: number;
  take_profit: number;
  unrealized_pnl: number;
  realized_pnl: number;
  open_time: string; // ISO 8601
  close_time?: string; // ISO 8601
  strategy: string;
  status: "open" | "closing" | "closed";
}
```

### Trade
```typescript
interface Trade {
  id: string;
  order_id: string;
  symbol: string;
  side: "buy" | "sell";
  type: "market" | "limit" | "stop";
  price: number;
  size: number;
  status: "pending" | "filled" | "cancelled" | "failed";
  latency_ms: number;
  timestamp: string; // ISO 8601
}
```

### Strategy
```typescript
interface Strategy {
  name: string;
  active: boolean;
  weight: number;
  performance: StrategyPerformance;
  config: Record<string, any>;
}

interface StrategyPerformance {
  total_trades: number;
  winning_trades: number;
  losing_trades: number;
  win_rate: number;
  total_pnl: number;
  avg_win: number;
  avg_loss: number;
  sharpe_ratio: number;
  max_drawdown: number;
  profit_factor: number;
}
```

### RiskParameters
```typescript
interface RiskParameters {
  max_position_size_usd: number;
  max_total_exposure_usd: number;
  stop_loss_percent: number;
  take_profit_percent: number;
  max_daily_loss_usd: number;
  max_consecutive_losses: number;
  volatility_multiplier: number;
  kelly_fraction: number;
  risk_free_rate: number;
  confidence_threshold: number;
}
```

### RiskState
```typescript
interface RiskState {
  current_drawdown_daily: number;
  current_drawdown_weekly: number;
  current_drawdown_monthly: number;
  total_exposure: number;
  exposure_by_symbol: Record<string, number>;
  consecutive_losses: number;
  risk_mode: "Conservative" | "Normal" | "Aggressive" | "ControlledCrazy";
  kill_switch_active: boolean;
  last_update: string; // ISO 8601
}
```

### Metrics
```typescript
interface Metrics {
  total_trades: number;
  winning_trades: number;
  losing_trades: number;
  win_rate: number;
  total_pnl: number;
  daily_pnl: number;
  weekly_pnl: number;
  monthly_pnl: number;
  avg_win: number;
  avg_loss: number;
  profit_factor: number;
  sharpe_ratio: number;
  max_drawdown: number;
  active_positions: number;
  avg_latency_ms: number;
  avg_slippage_pct: number;
}
```

### Alert
```typescript
interface Alert {
  id: string;
  type: string;
  severity: "info" | "warning" | "critical";
  message: string;
  trigger: string;
  value?: number;
  timestamp: string; // ISO 8601
  acknowledged: boolean;
}
```

---

## Error Handling

### Error Response Format

All errors follow this format:

```json
{
  "success": false,
  "error": "Error message",
  "code": "ERROR_CODE",
  "details": {}
}
```

### HTTP Status Codes

- `200 OK` - Request successful
- `400 Bad Request` - Invalid request parameters
- `401 Unauthorized` - Authentication required
- `403 Forbidden` - Insufficient permissions
- `404 Not Found` - Resource not found
- `429 Too Many Requests` - Rate limit exceeded
- `500 Internal Server Error` - Server error
- `503 Service Unavailable` - Service temporarily unavailable

### Error Codes

#### General Errors
- `INVALID_REQUEST` - Invalid request format
- `MISSING_PARAMETER` - Required parameter missing
- `INVALID_PARAMETER` - Parameter value invalid

#### Trading Errors
- `INSUFFICIENT_BALANCE` - Not enough balance
- `POSITION_NOT_FOUND` - Position does not exist
- `ORDER_FAILED` - Order execution failed
- `MARKET_CLOSED` - Market is closed

#### Risk Errors
- `RISK_LIMIT_EXCEEDED` - Risk limit exceeded
- `KILL_SWITCH_ACTIVE` - Kill switch is active
- `MAX_POSITIONS_REACHED` - Maximum positions reached
- `EXPOSURE_LIMIT_EXCEEDED` - Exposure limit exceeded

#### System Errors
- `ENGINE_NOT_RUNNING` - Scalping engine not running
- `STRATEGY_NOT_FOUND` - Strategy does not exist
- `EXCHANGE_ERROR` - Exchange API error
- `INTERNAL_ERROR` - Internal server error

### Example Error Responses

#### Risk Limit Exceeded
```json
{
  "success": false,
  "error": "Daily drawdown limit exceeded: 5.5%",
  "code": "RISK_LIMIT_EXCEEDED",
  "details": {
    "current_drawdown": 5.5,
    "max_drawdown": 5.0
  }
}
```

#### Insufficient Balance
```json
{
  "success": false,
  "error": "Insufficient balance for trade",
  "code": "INSUFFICIENT_BALANCE",
  "details": {
    "required": 100.0,
    "available": 50.0
  }
}
```

#### Kill Switch Active
```json
{
  "success": false,
  "error": "Trading is disabled - kill switch active",
  "code": "KILL_SWITCH_ACTIVE",
  "details": {
    "reason": "Daily drawdown limit exceeded",
    "activated_at": "2025-11-16T10:00:00Z"
  }
}
```

---

## Rate Limiting

### Current Limits (Development)
- No rate limiting

### Planned Limits (Production)
- REST API: 100 requests/minute per IP
- WebSocket: 50 messages/second per connection
- MCP Tools: 1000 calls/hour per API key

### Rate Limit Headers
```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1700140800
```

---

## Authentication (Planned)

### JWT Authentication

#### Login
```http
POST /api/v1/auth/login
Content-Type: application/json

{
  "username": "trader1",
  "password": "secure_password"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expires_at": "2025-11-17T10:00:00Z"
  }
}
```

#### Using Token
```http
GET /api/v1/scalping/status
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### API Key Authentication (MCP)

```json
{
  "api_key": "tmcp_1234567890abcdef",
  "api_secret": "secret_key_here"
}
```

---

## Changelog

### Version 1.0.0 (Current)
- Initial REST API for scalping dashboard
- MCP tools for market data, technical analysis, orders, portfolio, risk
- WebSocket support for real-time updates
- Basic scalping engine with 5 strategies

### Version 1.1.0 (Planned - Phase 0)
- Risk Sentinel endpoints
- Position Manager endpoints
- Auto SL/TP management
- Kill switch controls

### Version 1.2.0 (Planned - Phase 1)
- Multi-timeframe analysis
- Backtesting API
- Enhanced signal generation
- Paper trading mode

### Version 1.3.0 (Planned - Phase 2)
- HFT order management
- Execution performance metrics
- Latency optimization
- Advanced monitoring

### Version 1.4.0 (Planned - Phase 3)
- Multi-pair correlation
- Parameter optimization
- Alert system (Telegram, Email)
- Production monitoring

---

## Support & Contact

**Documentation:** https://github.com/rantipay/trading-mcp/docs  
**Issues:** https://github.com/rantipay/trading-mcp/issues  
**Discord:** [Coming soon]

---

**Last Updated:** 2025-11-16  
**API Version:** 1.0.0  
**Status:** Active Development
