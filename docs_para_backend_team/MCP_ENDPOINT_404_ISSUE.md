# 🚨 Backend Issue: MCP Tools Endpoint Missing

## 📋 Issue Summary
**Date:** December 15, 2025  
**Priority:** HIGH  
**Component:** MCP Server / API Gateway  
**Status:** BLOCKING - Prevents accessing futures positions and MCP tools  

## 🔍 Problem Description
The Flutter app is unable to access MCP (Model Context Protocol) tools, specifically when trying to fetch futures positions. The endpoint returns 404 "page not found".

## 📊 Error Details

### Request Being Made
```http
POST http://192.168.1.6:9090/api/mcp/tools/execute
Content-Type: application/json

{
  "jsonrpc": "2.0",
  "method": "tools/call",
  "params": {
    "name": "get_futures_positions",
    "arguments": {
      "exchange": "kucoin",
      "market_type": "futures"
    }
  },
  "id": 1765812095225
}
```

### Response Received
```http
HTTP/1.1 404 Not Found
Content-Type: text/plain; charset=utf-8
Content-Length: 19

404 page not found
```

## 🔧 Investigation Results

### ✅ Working Services
- **API Gateway (Port 9090):** ✅ Working
  - `GET /api/scalping/api/v1/scalping/status` → 200 OK
  - `GET /api/scalping/api/v1/scalping/metrics` → 200 OK

- **MCP Server (Port 10600):** ✅ Running
  - `GET /health` → 200 OK

### ❌ Missing/Broken Services
- **MCP Tools Endpoint:** ❌ Not Found
  - `POST /api/mcp/tools/execute` → 404 Not Found
  - `POST /tools/execute` → 404 Not Found

## 🎯 Expected Behavior
The MCP tools endpoint should accept JSON-RPC 2.0 requests and execute trading tools like:
- `get_futures_positions`
- `get_ticker`
- `calculate_rsi`
- And other MCP tools

## 🛠️ Required Backend Fixes

### Option 1: Configure Gateway Routing (Recommended)
Add MCP routing to the API Gateway (port 9090):

```nginx
# Example Nginx configuration
location /api/mcp/ {
    proxy_pass http://localhost:10600/;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
}
```

### Option 2: Add MCP Endpoint to MCP Server
Ensure the MCP Server (port 10600) has the correct endpoint:

```
POST /tools/execute
Content-Type: application/json

{
  "jsonrpc": "2.0",
  "method": "tools/call",
  "params": {
    "name": "TOOL_NAME",
    "arguments": {...}
  },
  "id": REQUEST_ID
}
```

### Option 3: Update Gateway Configuration
If using a different routing setup, ensure the gateway forwards:
- `POST /api/mcp/tools/execute` → `POST http://mcp-server:10600/tools/execute`

## 📋 Testing Checklist

### Backend Team Should Verify:
- [ ] MCP Server is running on port 10600
- [ ] MCP Server responds to `/health` endpoint
- [ ] MCP Server has `/tools/execute` endpoint
- [ ] Gateway routes `/api/mcp/*` to MCP Server
- [ ] JSON-RPC 2.0 format is supported
- [ ] CORS headers are configured correctly

### Test Commands:
```bash
# Test MCP Server health
curl http://localhost:10600/health

# Test MCP tools endpoint directly
curl -X POST http://localhost:10600/tools/execute \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "tools/call",
    "params": {
      "name": "get_health",
      "arguments": {}
    },
    "id": 1
  }'

# Test via Gateway
curl -X POST http://localhost:9090/api/mcp/tools/execute \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "tools/call",
    "params": {
      "name": "get_futures_positions",
      "arguments": {
        "exchange": "kucoin",
        "market_type": "futures"
      }
    },
    "id": 1
  }'
```

## 🔄 Temporary Workaround
Frontend team can temporarily use direct MCP Server connection:
```dart
// Change from:
static String get mcpToolsUrl => '$gatewayBaseUrl/api/mcp/tools/execute';

// To:
static String get mcpToolsUrl => '$mcpDirectUrl/tools/execute';
```

## 📞 Contact Information
**Frontend Team:** Ready to test once backend fixes are deployed  
**Issue Reporter:** Kiro AI Assistant  
**Next Steps:** Backend team to implement one of the three options above  

## 🕐 Timeline
**Reported:** December 15, 2025, 15:21 GMT  
**Expected Fix:** ASAP (blocking feature development)  
**Testing:** Frontend team will verify once deployed  

---
**Note:** This issue is blocking the futures positions feature and all MCP tool functionality in the mobile app.