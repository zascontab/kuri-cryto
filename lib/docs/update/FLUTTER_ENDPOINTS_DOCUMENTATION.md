# 📱 MATP Flutter API Documentation

**Versión**: 1.0.0  
**Fecha**: 14 de Diciembre, 2025  
**Para**: Equipo de Desarrollo Flutter  

## 🎯 **Resumen Ejecutivo**

Esta documentación proporciona todos los endpoints necesarios para integrar la aplicación Flutter con el sistema MATP (Multi-Asset Trading Platform). Todos los endpoints están protegidos por Kong Gateway con autenticación JWT y control de acceso por niveles progresivos.

## 🔐 **Autenticación y Configuración Base**

### **Base URL**
```
Production: http://localhost:10000  (Kong Gateway)
Development: http://localhost:8200  (Direct API)
```

### **Headers Requeridos**
```http
Authorization: Bearer <jwt_token>
Content-Type: application/json
X-Tenant-ID: <tenant_id>  (Automático via Kong Gateway)
X-Company-ID: <company_id>  (Automático via Kong Gateway)
X-User-Level: <user_level>  (Automático via Kong Gateway)
```

### **Niveles de Acceso Kong Gateway**
| Nivel | Plan | Descripción | API Calls/min |
|-------|------|-------------|---------------|
| **1** | Basic | Datos básicos, indicadores limitados | 100 |
| **2** | Standard | Señales, backtesting, alertas | 500 |
| **3** | Premium | Trading real, gestión de riesgo | 2000 |
| **4** | Enterprise | Acceso admin, operaciones masivas | Ilimitado |

---

## 📊 **1. TECHNICAL INDICATORS (Nivel 1+)**

### **1.1 Obtener Indicadores Disponibles**
```http
GET /api/v1/indicators
```

**Respuesta:**
```json
{
  "success": true,
  "data": {
    "indicators": [
      "sma", "ema", "rsi", "macd", "bollinger_bands",
      "atr", "adx", "obv", "mfi", "stochastic", 
      "williams_r", "cci", "roc"
    ],
    "count": 13
  },
  "meta": {
    "timestamp": "2025-01-01T00:00:00Z",
    "user_id": "user_123",
    "tenant_id": "tenant_456"
  }
}
```

### **1.2 Calcular Indicadores**
```http
POST /api/v1/indicators/calculate
```

**Request Body:**
```json
{
  "symbol": "BTC-USDT",
  "timeframe": "1h",
  "indicator": "rsi",
  "params": {
    "period": 14
  }
}
```

**Respuesta:**
```json
{
  "success": true,
  "data": {
    "symbol": "BTC-USDT",
    "indicator": "rsi",
    "values": [50.5, 51.2, 49.8, 52.1, 50.9],
    "timestamp": "2025-01-01T00:00:00Z"
  },
  "meta": {
    "timestamp": "2025-01-01T00:00:00Z",
    "user_id": "user_123",
    "tenant_id": "tenant_456"
  }
}
```

### **1.3 Obtener Datos OHLCV**
```http
GET /api/v1/indicators/ohlcv?symbol=BTC-USDT&timeframe=1h&limit=100
```

**Respuesta:**
```json
{
  "success": true,
  "data": {
    "symbol": "BTC-USDT",
    "timeframe": "1h",
    "ohlcv": [
      {
        "timestamp": "2025-01-01T00:00:00Z",
        "open": 50000.0,
        "high": 51000.0,
        "low": 49500.0,
        "close": 50500.0,
        "volume": 1000.0
      }
    ],
    "count": 1
  },
  "meta": {
    "timestamp": "2025-01-01T00:00:00Z",
    "user_id": "user_123",
    "tenant_id": "tenant_456"
  }
}
```

---

## 🎯 **2. SIGNAL GENERATION (Nivel 2+)**

### **2.1 Obtener Señales de Trading**
```http
GET /api/v1/signals
```

**Respuesta:**
```json
{
  "success": true,
  "data": {
    "signals": [
      {
        "id": "signal_1",
        "symbol": "BTC-USDT",
        "direction": "BUY",
        "strength": 0.85,
        "price": 50000.0,
        "timestamp": "2025-01-01T00:00:00Z"
      }
    ],
    "count": 1
  },
  "meta": {
    "timestamp": "2025-01-01T00:00:00Z",
    "user_id": "user_123",
    "tenant_id": "tenant_456"
  }
}
```

### **2.2 Generar Nueva Señal**
```http
POST /api/v1/signals/generate
```

**Request Body:**
```json
{
  "symbol": "BTC-USDT",
  "timeframe": "1h",
  "strategy": "RSI_MACD"
}
```

**Respuesta:**
```json
{
  "success": true,
  "data": {
    "id": "signal_new",
    "symbol": "BTC-USDT",
    "direction": "BUY",
    "strength": 0.75,
    "price": 50000.0,
    "timestamp": "2025-01-01T00:00:00Z"
  },
  "meta": {
    "timestamp": "2025-01-01T00:00:00Z",
    "user_id": "user_123",
    "tenant_id": "tenant_456"
  }
}
```

### **2.3 Analizar Señales**
```http
POST /api/v1/signals/analysis
```

**Respuesta:**
```json
{
  "success": true,
  "data": {
    "total_signals": 10,
    "bullish_signals": 6,
    "bearish_signals": 4,
    "avg_strength": 0.72,
    "recommendation": "BULLISH",
    "confidence": "HIGH"
  },
  "meta": {
    "timestamp": "2025-01-01T00:00:00Z",
    "user_id": "user_123",
    "tenant_id": "tenant_456"
  }
}
```

---

## 🧪 **3. BACKTESTING (Nivel 2+)**

### **3.1 Ejecutar Backtest**
```http
POST /api/v1/backtesting/run
```

**Request Body:**
```json
{
  "symbol": "BTC-USDT",
  "strategy": "RSI_MACD",
  "start_date": "2024-01-01",
  "end_date": "2024-12-31",
  "capital": 10000.0
}
```

**Respuesta:**
```json
{
  "success": true,
  "data": {
    "backtest_id": "bt_123",
    "status": "RUNNING",
    "estimated_time": "5 minutes",
    "progress": 0
  },
  "meta": {
    "timestamp": "2025-01-01T00:00:00Z",
    "user_id": "user_123",
    "tenant_id": "tenant_456"
  }
}
```

### **3.2 Obtener Resultados de Backtest**
```http
GET /api/v1/backtesting/results
```

**Respuesta:**
```json
{
  "success": true,
  "data": {
    "results": [
      {
        "backtest_id": "bt_123",
        "symbol": "BTC-USDT",
        "strategy": "RSI_MACD",
        "total_return": 15.5,
        "max_drawdown": -5.2,
        "win_rate": 65.0,
        "profit_factor": 1.8,
        "sharpe_ratio": 1.2,
        "total_trades": 150
      }
    ],
    "count": 1
  },
  "meta": {
    "timestamp": "2025-01-01T00:00:00Z",
    "user_id": "user_123",
    "tenant_id": "tenant_456"
  }
}
```

---

## 💼 **4. POSITION MANAGEMENT (Nivel 3+)**

### **4.1 Obtener Posiciones**
```http
GET /api/v1/positions
```

**Respuesta:**
```json
{
  "success": true,
  "data": {
    "positions": [
      {
        "id": "pos_1",
        "symbol": "BTC-USDT",
        "side": "LONG",
        "size": 0.1,
        "entry": 50000.0,
        "current": 50500.0,
        "pnl": 50.0,
        "pnl_pct": 1.0
      }
    ],
    "count": 1
  },
  "meta": {
    "timestamp": "2025-01-01T00:00:00Z",
    "user_id": "user_123",
    "tenant_id": "tenant_456"
  }
}
```

### **4.2 Crear Posición**
```http
POST /api/v1/positions
```

**Request Body:**
```json
{
  "symbol": "BTC-USDT",
  "side": "LONG",
  "size": 0.1,
  "price": 50000.0,
  "stop_loss": 49000.0,
  "take_profit": 52000.0
}
```

**Respuesta:**
```json
{
  "success": true,
  "data": {
    "id": "pos_new",
    "symbol": "BTC-USDT",
    "side": "LONG",
    "size": 0.1,
    "status": "PENDING",
    "timestamp": "2025-01-01T00:00:00Z"
  },
  "meta": {
    "timestamp": "2025-01-01T00:00:00Z",
    "user_id": "user_123",
    "tenant_id": "tenant_456"
  }
}
```

### **4.3 Actualizar Posición**
```http
PUT /api/v1/positions/{id}
```

**Request Body:**
```json
{
  "stop_loss": 48000.0,
  "take_profit": 53000.0
}
```

### **4.4 Cerrar Posición**
```http
POST /api/v1/positions/{id}/close
```

**Respuesta:**
```json
{
  "success": true,
  "data": {
    "id": "pos_1",
    "status": "CLOSED"
  },
  "meta": {
    "timestamp": "2025-01-01T00:00:00Z",
    "user_id": "user_123",
    "tenant_id": "tenant_456"
  }
}
```

---

## ⚠️ **5. RISK MANAGEMENT (Nivel 3+)**

### **5.1 Evaluar Riesgo**
```http
POST /api/v1/risk/assessment
```

**Request Body:**
```json
{
  "symbol": "BTC-USDT",
  "position_size": 0.1,
  "account_balance": 10000.0
}
```

**Respuesta:**
```json
{
  "success": true,
  "data": {
    "risk_score": 0.65,
    "risk_level": "MEDIUM",
    "max_position": 1000.0,
    "recommended_size": 0.05,
    "warnings": []
  },
  "meta": {
    "timestamp": "2025-01-01T00:00:00Z",
    "user_id": "user_123",
    "tenant_id": "tenant_456"
  }
}
```

### **5.2 Obtener Límites de Riesgo**
```http
GET /api/v1/risk/limits
```

**Respuesta:**
```json
{
  "success": true,
  "data": {
    "max_daily_loss": 1000.0,
    "max_position_size": 5000.0,
    "max_leverage": 10.0,
    "stop_loss_required": true
  },
  "meta": {
    "timestamp": "2025-01-01T00:00:00Z",
    "user_id": "user_123",
    "tenant_id": "tenant_456"
  }
}
```

### **5.3 Actualizar Límites de Riesgo**
```http
PUT /api/v1/risk/limits
```

**Request Body:**
```json
{
  "max_daily_loss": 1500.0,
  "max_position_size": 6000.0,
  "max_leverage": 8.0
}
```

---

## 👥 **6. ADMIN OPERATIONS (Nivel 4+)**

### **6.1 Obtener Usuarios**
```http
GET /api/v1/admin/users
```

### **6.2 Crear Usuario**
```http
POST /api/v1/admin/users
```

### **6.3 Actualizar Usuario**
```http
PUT /api/v1/admin/users/{id}
```

### **6.4 Eliminar Usuario**
```http
DELETE /api/v1/admin/users/{id}
```

### **6.5 Obtener Analytics**
```http
GET /api/v1/admin/analytics
```

**Respuesta:**
```json
{
  "success": true,
  "data": {
    "total_users": 1250,
    "active_users": 890,
    "total_trades": 15420,
    "total_volume": 2500000.0,
    "avg_profit": 12.5,
    "top_symbols": ["BTC-USDT", "ETH-USDT", "DOGE-USDT"]
  },
  "meta": {
    "timestamp": "2025-01-01T00:00:00Z",
    "user_id": "user_123",
    "tenant_id": "tenant_456"
  }
}
```

### **6.6 Obtener Estado del Sistema**
```http
GET /api/v1/admin/system/health
```

**Respuesta:**
```json
{
  "success": true,
  "data": {
    "status": "HEALTHY",
    "uptime": "99.9%",
    "response_time": "45ms",
    "active_sessions": 234,
    "memory_usage": "65%",
    "cpu_usage": "32%",
    "gct_connected": true,
    "indicators_ok": true
  },
  "meta": {
    "timestamp": "2025-01-01T00:00:00Z",
    "user_id": "user_123",
    "tenant_id": "tenant_456"
  }
}
```

---

## 🤖 **7. AI TRADING AUTÓNOMO (Nivel 2+)**

### **7.1 Análisis Completo con IA**
```http
POST /api/v1/ai/complete-analysis
```

**Request Body:**
```json
{
  "symbol": "BTC-USDT",
  "exchange": "kucoin",
  "timeframes": ["5m", "15m"],
  "include_llm": true,
  "include_sentiment": true,
  "include_costs": true,
  "include_performance": true,
  "trade_size_usd": 100.0,
  "language": "es"
}
```

**Respuesta:**
```json
{
  "symbol": "BTC-USDT",
  "exchange": "kucoin",
  "timestamp": "2025-01-01T00:00:00Z",
  "formatted_analysis": {
    "system_status": "Sistema operativo - Todos los componentes funcionando",
    "market_analysis": "BTC-USDT: $50,000 - RSI 15m: 65 (neutral), Tendencia: alcista",
    "position_analysis": "Sin posiciones activas",
    "ai_analysis": "IA recomienda: COMPRAR con 75% confianza",
    "risk_assessment": "Riesgo: MEDIO - Gestión de capital adecuada",
    "recommendations": "Considerar entrada larga con stop loss en $49,000"
  },
  "raw_data": {
    "market_data": { /* datos técnicos completos */ },
    "llm_analysis": { /* análisis de IA */ },
    "sentiment_analysis": { /* análisis de sentimiento */ }
  },
  "summary": {
    "overall_signal": "BULLISH",
    "confidence": 0.75,
    "risk_level": "MEDIUM"
  }
}
```

### **7.2 Análisis LLM (Gemini/GPT)**
```http
POST /api/v1/ai/llm-analysis
```

**Request Body:**
```json
{
  "symbol": "BTC-USDT",
  "timeframes": ["5m", "15m"],
  "use_gemini": true,
  "trade_size_usd": 100.0
}
```

**Respuesta:**
```json
{
  "symbol": "BTC-USDT",
  "analysis": {
    "recommendation": "BUY",
    "confidence": 0.85,
    "reasoning": [
      "RSI showing oversold conditions",
      "Volume increasing on breakout",
      "Support level holding strong"
    ],
    "entry_price": 50000.0,
    "stop_loss": 49000.0,
    "take_profit": 52000.0,
    "risk_reward_ratio": 2.0
  },
  "provider": "gemini-2.5-flash",
  "cost": 0.002,
  "timestamp": "2025-01-01T00:00:00Z"
}
```

### **7.3 Análisis de Sentimiento**
```http
POST /api/v1/ai/sentiment-analysis
```

**Request Body:**
```json
{
  "symbol": "BTC-USDT",
  "hours": 24,
  "sources": ["cryptopanic", "twitter", "reddit"],
  "use_cache": true
}
```

**Respuesta:**
```json
{
  "symbol": "BTC-USDT",
  "sentiment": {
    "overall": 0.65,
    "confidence": 0.8,
    "trend": "bullish",
    "breakdown": {
      "news": 0.7,
      "twitter": 0.6,
      "reddit": 0.65
    }
  },
  "interpretation": {
    "signal": "bullish",
    "strength": "moderate",
    "recommendation": "Consider long positions with proper risk management"
  },
  "data_counts": {
    "news_articles": 45,
    "tweets": 1200,
    "reddit_posts": 89
  }
}
```

### **7.4 Control del Bot Autónomo**

#### **Iniciar Bot**
```http
POST /api/v1/ai-bot/start
```

#### **Detener Bot**
```http
POST /api/v1/ai-bot/stop
```

#### **Pausar Bot**
```http
POST /api/v1/ai-bot/pause
```

#### **Reanudar Bot**
```http
POST /api/v1/ai-bot/resume
```

#### **Parada de Emergencia**
```http
POST /api/v1/ai-bot/emergency-stop
```

**Respuesta típica:**
```json
{
  "success": true,
  "message": "Trading bot started successfully",
  "status": {
    "state": "running",
    "positions": 2,
    "pnl_today": 125.50,
    "trades_today": 8
  }
}
```

### **7.5 Estado del Bot Autónomo**
```http
GET /api/v1/ai-bot/status
```

**Respuesta:**
```json
{
  "success": true,
  "data": {
    "status": "running",
    "autonomous_mode": true,
    "positions": {
      "active": 2,
      "total_value": 1500.0,
      "unrealized_pnl": 75.25
    },
    "performance": {
      "trades_today": 8,
      "win_rate": 75.0,
      "pnl_today": 125.50,
      "pnl_week": 450.75
    },
    "risk": {
      "daily_loss_limit": 500.0,
      "current_loss": 0.0,
      "max_positions": 5,
      "leverage_used": 2.5
    },
    "last_action": {
      "type": "BUY",
      "symbol": "BTC-USDT",
      "timestamp": "2025-01-01T00:00:00Z"
    }
  }
}
```

### **7.6 Habilitar Modo Autónomo**
```http
POST /api/v1/ai-bot/autonomous/enable
```

**Request Body:**
```json
{
  "enabled": true,
  "max_positions": 3,
  "daily_loss_limit": 500.0,
  "symbols": ["BTC-USDT", "ETH-USDT"],
  "strategies": ["rsi_macd", "bollinger_bands"],
  "risk_level": "medium"
}
```

### **7.7 Estado del Modo Autónomo**
```http
GET /api/v1/ai-bot/autonomous/status
```

**Respuesta:**
```json
{
  "success": true,
  "data": {
    "autonomous_enabled": true,
    "config": {
      "max_positions": 3,
      "daily_loss_limit": 500.0,
      "symbols": ["BTC-USDT", "ETH-USDT"],
      "risk_level": "medium"
    },
    "current_state": {
      "active_positions": 2,
      "daily_pnl": 125.50,
      "trades_executed": 8,
      "last_decision": "2025-01-01T00:00:00Z"
    }
  }
}
```

### **7.8 Configuración del Bot**
```http
GET /api/v1/ai-bot/config
PUT /api/v1/ai-bot/config
```

**GET Respuesta:**
```json
{
  "success": true,
  "data": {
    "dry_run": false,
    "auto_execute": true,
    "max_positions": 5,
    "position_size_usd": 100.0,
    "stop_loss_percent": 2.0,
    "take_profit_percent": 4.0,
    "symbols": ["BTC-USDT", "ETH-USDT"],
    "timeframes": ["5m", "15m"],
    "strategies": ["rsi_macd", "bollinger_bands"],
    "risk_management": {
      "daily_loss_limit": 500.0,
      "max_drawdown": 10.0,
      "position_sizing": "fixed"
    }
  }
}
```

**PUT Request Body:**
```json
{
  "max_positions": 3,
  "position_size_usd": 150.0,
  "stop_loss_percent": 1.5,
  "symbols": ["BTC-USDT", "ETH-USDT", "DOGE-USDT"]
}
```

### **7.9 Rendimiento de Estrategias**
```http
GET /api/v1/ai/strategy-performance?timeframe=30d&symbol=BTC-USDT
```

**Respuesta:**
```json
{
  "timeframe": {
    "from": "2024-12-01T00:00:00Z",
    "to": "2025-01-01T00:00:00Z",
    "duration": "720h0m0s"
  },
  "performance": {
    "overall_stats": {
      "total_executions": 150,
      "stop_loss_count": 45,
      "take_profit_count": 105,
      "success_rate": 70.0,
      "total_pnl": 1250.75,
      "average_pnl": 8.34
    },
    "strategy_breakdown": {
      "strategies": {
        "rsi_macd": {
          "total_executions": 80,
          "success_rate": 75.0,
          "total_pnl": 750.25
        },
        "bollinger_bands": {
          "total_executions": 70,
          "success_rate": 64.3,
          "total_pnl": 500.50
        }
      }
    }
  }
}
```

### **7.10 Seguimiento de Costos de IA**
```http
GET /api/v1/ai/costs?period=7d&provider=openai
```

**Respuesta:**
```json
{
  "period": {
    "from": "2024-12-25T00:00:00Z",
    "to": "2025-01-01T00:00:00Z"
  },
  "costs": {
    "budget_status": {
      "openai": {
        "daily_limit": 5.0,
        "current_cost": 2.35,
        "remaining_budget": 2.65,
        "used_percent": 47.0,
        "call_count": 145
      }
    },
    "summary": {
      "today": {
        "total_cost": 2.35,
        "total_calls": 145
      },
      "period": {
        "total_cost": 12.80,
        "total_calls": 890
      }
    },
    "alerts": []
  }
}
```

### **7.11 Configuración de IA**
```http
GET /api/v1/ai/config
PUT /api/v1/ai/config
```

**GET Respuesta:**
```json
{
  "ai_config": {
    "enabled": true,
    "llm": {
      "enabled": true,
      "provider": "openai",
      "model": "gpt-4",
      "max_calls_per_day": 1000,
      "temperature": 0.7
    },
    "sentiment": {
      "enabled": true,
      "cache_ttl_minutes": 30,
      "sources": {
        "cryptopanic": { "enabled": true },
        "twitter": { "enabled": false }
      }
    }
  },
  "status": {
    "llm_analyzer_available": true,
    "sentiment_analyzer_available": true
  }
}
```

---

## 📋 **8. INFORMACIÓN DE PLAN**

### **8.1 Obtener Información del Plan del Usuario**
```http
GET /api/v1/plan/info
```

**Respuesta:**
```json
{
  "success": true,
  "data": {
    "current_level": 2,
    "plan_name": "Standard Plan",
    "features_enabled": [
      "signals_generation",
      "backtesting",
      "alerts_notifications",
      "ai_analysis",
      "sentiment_analysis"
    ],
    "ai_features": {
      "llm_analysis": true,
      "sentiment_analysis": true,
      "autonomous_trading": false,
      "strategy_performance": true,
      "cost_tracking": true
    },
    "limits": {
      "api_calls_per_minute": 500,
      "max_backtests": 10,
      "max_positions": 5,
      "ai_calls_per_day": 100,
      "autonomous_positions": 0
    },
    "usage": {
      "api_calls_today": 1250,
      "backtests_this_month": 3,
      "active_positions": 2,
      "ai_calls_today": 25,
      "autonomous_trades": 0
    }
  },
  "meta": {
    "timestamp": "2025-01-01T00:00:00Z",
    "user_id": "user_123",
    "tenant_id": "tenant_456"
  }
}
```

---

## 🔐 **8. AUTENTICACIÓN KONG GATEWAY**

### **8.1 Endpoints de Autenticación (Usar Kong Gateway)**

**Base URL para Auth**: `http://localhost:10000`

#### **Login con Teléfono**
```http
POST /auth/login/phone
```

**Request Body:**
```json
{
  "phone": "+1234567890",
  "country_code": "US"
}
```

#### **Verificar Login**
```http
POST /auth/login/phone/verify
```

**Request Body:**
```json
{
  "phone": "+1234567890",
  "otp_code": "123456"
}
```

**Respuesta:**
```json
{
  "success": true,
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expires_in": 3600,
    "user": {
      "id": "user_123",
      "phone": "+1234567890",
      "level": 2,
      "tenant_id": "tenant_456",
      "company_id": "company_789"
    }
  }
}
```

#### **Refresh Token**
```http
POST /auth/refresh
```

**Request Body:**
```json
{
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

#### **Obtener Perfil**
```http
GET /auth/profile
Authorization: Bearer <access_token>
```

#### **Upgrade Progresivo**
```http
POST /auth/progressive/upgrade/initiate
```

**Request Body:**
```json
{
  "target_level": 3,
  "upgrade_type": "financial"
}
```

---

## 🚨 **9. MANEJO DE ERRORES**

### **Estructura de Error Estándar**
```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Descripción del error",
    "details": {
      "field": "Información adicional"
    }
  },
  "meta": {
    "timestamp": "2025-01-01T00:00:00Z",
    "request_id": "req_123"
  }
}
```

### **Códigos de Error Comunes**

| Código | HTTP Status | Descripción |
|--------|-------------|-------------|
| `INVALID_REQUEST` | 400 | Request malformado |
| `UNAUTHORIZED` | 401 | Token inválido o expirado |
| `FORBIDDEN` | 403 | Nivel de acceso insuficiente |
| `NOT_FOUND` | 404 | Recurso no encontrado |
| `RATE_LIMIT_EXCEEDED` | 429 | Límite de API excedido |
| `INTERNAL_ERROR` | 500 | Error interno del servidor |

### **Ejemplo de Error de Rate Limiting**
```json
{
  "success": false,
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "API rate limit exceeded for your plan level",
    "details": {
      "current_level": 1,
      "limit_per_minute": 100,
      "requests_made": 101,
      "reset_time": "2025-01-01T00:01:00Z"
    }
  }
}
```

---

## 📱 **10. IMPLEMENTACIÓN EN FLUTTER**

### **10.1 Configuración del Cliente HTTP**

```dart
import 'package:dio/dio.dart';

class MATAPIClient {
  static const String baseUrl = 'http://localhost:10000';
  late Dio _dio;
  String? _accessToken;

  MATAPIClient() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    // Interceptor para agregar token automáticamente
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_accessToken != null) {
          options.headers['Authorization'] = 'Bearer $_accessToken';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          // Token expirado, renovar automáticamente
          _refreshToken();
        }
        handler.next(error);
      },
    ));
  }

  void setAccessToken(String token) {
    _accessToken = token;
  }

  Future<void> _refreshToken() async {
    // Implementar lógica de refresh token
  }
}
```

### **10.2 Modelos de Datos**

```dart
class Signal {
  final String id;
  final String symbol;
  final String direction;
  final double strength;
  final double price;
  final DateTime timestamp;

  Signal({
    required this.id,
    required this.symbol,
    required this.direction,
    required this.strength,
    required this.price,
    required this.timestamp,
  });

  factory Signal.fromJson(Map<String, dynamic> json) {
    return Signal(
      id: json['id'],
      symbol: json['symbol'],
      direction: json['direction'],
      strength: json['strength'].toDouble(),
      price: json['price'].toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class Position {
  final String id;
  final String symbol;
  final String side;
  final double size;
  final double entry;
  final double current;
  final double pnl;
  final double pnlPct;

  Position({
    required this.id,
    required this.symbol,
    required this.side,
    required this.size,
    required this.entry,
    required this.current,
    required this.pnl,
    required this.pnlPct,
  });

  factory Position.fromJson(Map<String, dynamic> json) {
    return Position(
      id: json['id'],
      symbol: json['symbol'],
      side: json['side'],
      size: json['size'].toDouble(),
      entry: json['entry'].toDouble(),
      current: json['current'].toDouble(),
      pnl: json['pnl'].toDouble(),
      pnlPct: json['pnl_pct'].toDouble(),
    );
  }
}
```

### **10.3 Servicios de API**

```dart
class TradingService {
  final MATAPIClient _client;

  TradingService(this._client);

  Future<List<Signal>> getSignals() async {
    try {
      final response = await _client._dio.get('/api/v1/signals');
      final List<dynamic> signalsJson = response.data['data']['signals'];
      return signalsJson.map((json) => Signal.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load signals: $e');
    }
  }

  Future<List<Position>> getPositions() async {
    try {
      final response = await _client._dio.get('/api/v1/positions');
      final List<dynamic> positionsJson = response.data['data']['positions'];
      return positionsJson.map((json) => Position.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load positions: $e');
    }
  }

  Future<Signal> generateSignal({
    required String symbol,
    required String timeframe,
    String? strategy,
  }) async {
    try {
      final response = await _client._dio.post('/api/v1/signals/generate', data: {
        'symbol': symbol,
        'timeframe': timeframe,
        'strategy': strategy,
      });
      return Signal.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to generate signal: $e');
    }
  }
}

// Servicio específico para IA Autónoma
class AITradingService {
  final MATAPIClient _client;

  AITradingService(this._client);

  // Análisis completo con IA
  Future<Map<String, dynamic>> getCompleteAnalysis({
    required String symbol,
    String exchange = 'kucoin',
    List<String> timeframes = const ['5m', '15m'],
    bool includeLLM = true,
    bool includeSentiment = true,
    double tradeSizeUSD = 100.0,
    String language = 'es',
  }) async {
    try {
      final response = await _client._dio.post('/api/v1/ai/complete-analysis', data: {
        'symbol': symbol,
        'exchange': exchange,
        'timeframes': timeframes,
        'include_llm': includeLLM,
        'include_sentiment': includeSentiment,
        'trade_size_usd': tradeSizeUSD,
        'language': language,
      });
      return response.data;
    } catch (e) {
      throw Exception('Failed to get AI analysis: $e');
    }
  }

  // Control del bot autónomo
  Future<Map<String, dynamic>> startBot() async {
    try {
      final response = await _client._dio.post('/api/v1/ai-bot/start');
      return response.data;
    } catch (e) {
      throw Exception('Failed to start bot: $e');
    }
  }

  Future<Map<String, dynamic>> stopBot() async {
    try {
      final response = await _client._dio.post('/api/v1/ai-bot/stop');
      return response.data;
    } catch (e) {
      throw Exception('Failed to stop bot: $e');
    }
  }

  Future<Map<String, dynamic>> getBotStatus() async {
    try {
      final response = await _client._dio.get('/api/v1/ai-bot/status');
      return response.data;
    } catch (e) {
      throw Exception('Failed to get bot status: $e');
    }
  }

  // Habilitar modo autónomo
  Future<Map<String, dynamic>> enableAutonomousMode({
    required bool enabled,
    int maxPositions = 3,
    double dailyLossLimit = 500.0,
    List<String> symbols = const ['BTC-USDT', 'ETH-USDT'],
    String riskLevel = 'medium',
  }) async {
    try {
      final response = await _client._dio.post('/api/v1/ai-bot/autonomous/enable', data: {
        'enabled': enabled,
        'max_positions': maxPositions,
        'daily_loss_limit': dailyLossLimit,
        'symbols': symbols,
        'risk_level': riskLevel,
      });
      return response.data;
    } catch (e) {
      throw Exception('Failed to enable autonomous mode: $e');
    }
  }

  // Análisis de sentimiento
  Future<Map<String, dynamic>> getSentimentAnalysis({
    required String symbol,
    int hours = 24,
    bool useCache = true,
  }) async {
    try {
      final response = await _client._dio.post('/api/v1/ai/sentiment-analysis', data: {
        'symbol': symbol,
        'hours': hours,
        'use_cache': useCache,
      });
      return response.data;
    } catch (e) {
      throw Exception('Failed to get sentiment analysis: $e');
    }
  }

  // Rendimiento de estrategias
  Future<Map<String, dynamic>> getStrategyPerformance({
    String timeframe = '30d',
    String? symbol,
  }) async {
    try {
      final queryParams = <String, dynamic>{'timeframe': timeframe};
      if (symbol != null) queryParams['symbol'] = symbol;
      
      final response = await _client._dio.get('/api/v1/ai/strategy-performance', 
        queryParameters: queryParams);
      return response.data;
    } catch (e) {
      throw Exception('Failed to get strategy performance: $e');
    }
  }

  // Costos de IA
  Future<Map<String, dynamic>> getAICosts({
    String period = '7d',
    String? provider,
  }) async {
    try {
      final queryParams = <String, dynamic>{'period': period};
      if (provider != null) queryParams['provider'] = provider;
      
      final response = await _client._dio.get('/api/v1/ai/costs', 
        queryParameters: queryParams);
      return response.data;
    } catch (e) {
      throw Exception('Failed to get AI costs: $e');
    }
  }
}
```

---

## 🔄 **11. FLUJO DE AUTENTICACIÓN RECOMENDADO**

### **11.1 Flujo Completo**

1. **Login Inicial**
   ```dart
   // 1. Solicitar OTP
   await authService.requestOTP('+1234567890');
   
   // 2. Verificar OTP
   final authResult = await authService.verifyOTP('+1234567890', '123456');
   
   // 3. Guardar tokens
   await secureStorage.write(key: 'access_token', value: authResult.accessToken);
   await secureStorage.write(key: 'refresh_token', value: authResult.refreshToken);
   
   // 4. Configurar cliente API
   apiClient.setAccessToken(authResult.accessToken);
   ```

2. **Verificación de Nivel de Acceso**
   ```dart
   final planInfo = await apiClient.getPlanInfo();
   if (planInfo.currentLevel < 2) {
     // Mostrar upgrade prompt para señales
     showUpgradeDialog();
   }
   ```

3. **Manejo de Rate Limiting**
   ```dart
   try {
     final signals = await tradingService.getSignals();
   } catch (e) {
     if (e is DioError && e.response?.statusCode == 429) {
       // Mostrar mensaje de límite excedido
       showRateLimitDialog();
     }
   }
   ```

---

## 📞 **12. SOPORTE Y CONTACTO**

### **Equipo de Backend**
- **Slack**: #matp-backend-support
- **Email**: backend-team@company.com

### **Documentación Adicional**
- **Kong Gateway**: `configs/kong/kong-optimized.yml`
- **Límites de Nivel**: `configs/trading/kong_level_limits.yml`
- **Código Fuente**: `internal/handlers/trading_handlers.go`

### **Entorno de Testing**
- **Kong Gateway**: http://localhost:10000
- **API Directa**: http://localhost:8200
- **Swagger UI**: http://localhost:9090/swagger (Próximamente)

---

## ✅ **13. CHECKLIST DE IMPLEMENTACIÓN**

### **Fase 1: Autenticación**
- [ ] Implementar cliente Kong Gateway
- [ ] Configurar interceptores JWT
- [ ] Manejar refresh tokens
- [ ] Implementar logout

### **Fase 2: Funcionalidades Básicas (Nivel 1)**
- [ ] Obtener indicadores disponibles
- [ ] Calcular indicadores técnicos
- [ ] Mostrar datos OHLCV
- [ ] Implementar gráficos básicos

### **Fase 3: Funcionalidades Avanzadas (Nivel 2+)**
- [ ] Obtener y mostrar señales
- [ ] Generar nuevas señales
- [ ] Ejecutar backtests
- [ ] Mostrar resultados de backtesting

### **Fase 4: IA y Análisis Autónomo (Nivel 2+)**
- [ ] Análisis completo con IA
- [ ] Análisis LLM (Gemini/GPT)
- [ ] Análisis de sentimiento
- [ ] Rendimiento de estrategias
- [ ] Seguimiento de costos de IA
- [ ] Configuración de IA

### **Fase 5: Trading Autónomo (Nivel 3+)**
- [ ] Control del bot (start/stop/pause)
- [ ] Estado del bot en tiempo real
- [ ] Configuración del bot
- [ ] Modo autónomo (enable/disable)
- [ ] Parada de emergencia
- [ ] Monitoreo de performance

### **Fase 6: Trading Real (Nivel 3+)**
- [ ] Gestión de posiciones
- [ ] Evaluación de riesgo
- [ ] Crear/cerrar posiciones
- [ ] Monitoreo en tiempo real

### **Fase 7: Administración (Nivel 4+)**
- [ ] Panel de administración
- [ ] Analytics del sistema
- [ ] Gestión de usuarios
- [ ] Monitoreo de salud

---

**🎯 Esta documentación está lista para uso inmediato por el equipo de Flutter. Todos los endpoints están implementados y funcionando con Kong Gateway.**