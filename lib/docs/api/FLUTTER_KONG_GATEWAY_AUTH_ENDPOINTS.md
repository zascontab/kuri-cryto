# 📱 Flutter Kong Gateway - Auth & Delivery Endpoints

**Version:** 2.0 - REAL ENDPOINTS
**Date:** 2025-10-02
**Status:** ✅ PRODUCTION READY
**Kong Gateway:** `http://localhost:10000`

---

## 📋 Table of Contents

1. [Authentication Flow](#authentication-flow)
2. [Auth Service Endpoints](#auth-service-endpoints)
3. [Delivery Service Endpoints](#delivery-service-endpoints)
4. [Required Headers](#required-headers)
5. [Progressive Authentication Levels](#progressive-authentication-levels)
6. [Error Handling](#error-handling)

---

## 🔐 Authentication Flow

### Complete User Journey

```
1. Registration (Level 1 - Basic)
   ↓
2. Phone/Email Verification
   ↓
3. Login → Receive JWT Token
   ↓
4. Profile Completion (Level 2 - Enhanced)
   ↓
5. KYC Submission (Level 3 - Financial)
   ↓
6. Enterprise Verification (Level 4 - Enterprise)
```

---

## 🔑 Auth Service Endpoints

**Base URL:** `http://localhost:10000/api/v1`

### 1. Registration Endpoints

#### 1.1 Register with Phone
```http
POST /auth/register/phone
Content-Type: application/json

{
  "phone_number": "+593983606090",
  "accept_terms": true,
  "accept_privacy": true
}
```

**Response:**
```json
{
  "success": true,
  "session_id": "uuid-session-id",
  "expires_in": 300,
  "message": "OTP sent to +593983606090"
}
```

#### 1.2 Verify Phone Registration
```http
POST /auth/register/phone/verify
Content-Type: application/json

{
  "session_id": "uuid-from-previous-step",
  "otp_code": "123456",
  "phone_number": "+593983606090"
}
```

**Response:**
```json
{
  "success": true,
  "user": {
    "id": "user-uuid",
    "phone_number": "+593983606090",
    "level": 1,
    "tenant_id": "tenant-uuid",
    "company_id": "company-uuid"
  },
  "tokens": {
    "access_token": "eyJhbGci...",
    "refresh_token": "eyJhbGci...",
    "expires_in": 900
  }
}
```

#### 1.3 Register with Email
```http
POST /auth/register/email
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "SecurePassword123!",
  "first_name": "John",
  "accept_terms": true,
  "accept_privacy": true
}
```

#### 1.4 Register with Social (OAuth)
```http
POST /auth/register/social
Content-Type: application/json

{
  "provider": "google",
  "id_token": "google-id-token",
  "accept_terms": true,
  "accept_privacy": true
}
```

---

### 2. Login Endpoints

#### 2.1 Login with Phone
```http
POST /auth/login/phone
Content-Type: application/json

{
  "phone_number": "+593983606090"
}
```

**Response:**
```json
{
  "success": true,
  "session_id": "uuid-session-id",
  "expires_in": 300,
  "message": "OTP sent to +593983606090"
}
```

#### 2.2 Verify Phone Login
```http
POST /auth/login/phone/verify
Content-Type: application/json

{
  "session_id": "uuid-from-previous-step",
  "otp_code": "123456",
  "phone_number": "+593983606090"
}
```

**Response:**
```json
{
  "success": true,
  "user": {
    "id": "user-uuid",
    "phone_number": "+593983606090",
    "email": "user@example.com",
    "first_name": "John",
    "last_name": "Doe",
    "level": 2,
    "profile_progress": 0.75,
    "tenant_id": "tenant-uuid",
    "company_id": "company-uuid"
  },
  "tokens": {
    "access_token": "eyJhbGci...",
    "refresh_token": "eyJhbGci...",
    "expires_in": 900
  }
}
```

#### 2.3 Login with Email
```http
POST /auth/login/email
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "SecurePassword123!"
}
```

#### 2.4 Login with Social (OAuth)
```http
POST /auth/login/social
Content-Type: application/json

{
  "provider": "google",
  "id_token": "google-id-token"
}
```

---

### 3. OAuth Endpoints

#### 3.1 Get OAuth Authorization URL
```http
GET /auth/oauth/{provider}/authorize?tenant_id=tenant-uuid
```

**Providers:** `google`, `tiktok`

**Response:**
```json
{
  "authorization_url": "https://accounts.google.com/o/oauth2/v2/auth?client_id=...",
  "state": "secure-random-state",
  "provider": "google"
}
```

#### 3.2 OAuth Native Authentication (Flutter)
```http
POST /auth/oauth/{provider}/native
Content-Type: application/json

{
  "id_token": "google-or-tiktok-id-token",
  "access_token": "optional-access-token",
  "tenant_id": "tenant-uuid"
}
```

**Response:**
```json
{
  "success": true,
  "user": {
    "id": "user-uuid",
    "email": "user@gmail.com",
    "first_name": "John",
    "level": 1,
    "tenant_id": "tenant-uuid"
  },
  "tokens": {
    "access_token": "eyJhbGci...",
    "refresh_token": "eyJhbGci...",
    "expires_in": 900
  },
  "is_new_user": true
}
```

#### 3.3 OAuth Callback (Web)
```http
GET /auth/callback/{provider}?code=auth-code&state=state-value
```

---

### 4. Token Management

#### 4.1 Refresh Access Token
```http
POST /auth/refresh
Content-Type: application/json

{
  "refresh_token": "eyJhbGci..."
}
```

**Response:**
```json
{
  "access_token": "new-eyJhbGci...",
  "refresh_token": "new-refresh-token",
  "expires_in": 900
}
```

#### 4.2 Logout
```http
POST /auth/logout
Authorization: Bearer {access_token}
```

**Response:**
```json
{
  "success": true,
  "message": "Logged out successfully"
}
```

---

### 5. Profile Management

#### 5.1 Get User Profile
```http
GET /auth/profile
Authorization: Bearer {access_token}
X-Tenant-ID: {tenant_id}
```

**Response:**
```json
{
  "id": "user-uuid",
  "tenant_id": "tenant-uuid",
  "company_id": "company-uuid",
  "phone_number": "+593983606090",
  "email": "user@example.com",
  "first_name": "John",
  "last_name": "Doe",
  "level": 2,
  "profile_progress": 0.75,
  "company_name": "Mi Empresa",
  "industry": "Technology",
  "kyc_status": "pending",
  "is_verified": true,
  "created_at": "2025-10-01T10:00:00Z",
  "updated_at": "2025-10-02T15:30:00Z"
}
```

#### 5.2 Update Profile (Progressive Auth)
```http
PUT /auth/profile
Authorization: Bearer {access_token}
X-Tenant-ID: {tenant_id}
Content-Type: application/json

{
  "first_name": "Juan",
  "last_name": "Pérez",
  "email": "juan@empresa.com",
  "company_name": "Mi Empresa SA",
  "industry": "Technology",
  "address": "Av. 6 de Diciembre, Quito",
  "tax_identification": "1234567890001"
}
```

**Response:**
```json
{
  "success": true,
  "user": {
    "id": "user-uuid",
    "first_name": "Juan",
    "last_name": "Pérez",
    "email": "juan@empresa.com",
    "company_name": "Mi Empresa SA",
    "level": 2,
    "profile_progress": 0.85,
    "tenant_id": "tenant-uuid",
    "company_id": "company-uuid"
  },
  "level_upgraded": false,
  "next_level_requirements": ["government_id", "income_source", "occupation"]
}
```

**⚡ Important:** This endpoint automatically syncs with Tenant and Company services. No additional calls needed.

#### 5.3 Update Financial Profile
```http
PUT /auth/profile/financial
Authorization: Bearer {access_token}
X-Tenant-ID: {tenant_id}
Content-Type: application/json

{
  "full_legal_name": "Juan Carlos Pérez Mendoza",
  "government_id": "1234567890",
  "tax_id": "1234567890001",
  "income_source": "employment",
  "monthly_income": 3000,
  "occupation": "Software Engineer",
  "address": "Av. 6 de Diciembre N34-234, Quito"
}
```

#### 5.4 Data Integrity Diagnostics
```http
GET /auth/profile/diagnose
Authorization: Bearer {access_token}
X-Tenant-ID: {tenant_id}
```

**Response:**
```json
{
  "user_id": "user-uuid",
  "issues": [],
  "status": "healthy",
  "checks": {
    "tenant_sync": true,
    "company_sync": true,
    "level_consistency": true
  }
}
```

---

### 6. Social Connections Management

#### 6.1 Link Social Account
```http
POST /auth/profile/link-social
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "provider": "google",
  "id_token": "google-id-token"
}
```

#### 6.2 Unlink Social Account
```http
DELETE /auth/profile/unlink-social/{provider}
Authorization: Bearer {access_token}
```

#### 6.3 Get Social Connections
```http
GET /auth/profile/social-connections
Authorization: Bearer {access_token}
```

**Response:**
```json
{
  "connections": [
    {
      "provider": "google",
      "email": "user@gmail.com",
      "is_primary": true,
      "connected_at": "2025-10-01T10:00:00Z"
    }
  ]
}
```

---

### 7. Progressive Authentication

#### 7.1 Get Profile Completion
```http
GET /auth/progressive/profile-completion
Authorization: Bearer {access_token}
X-Tenant-ID: {tenant_id}
```

**Response:**
```json
{
  "current_level": 2,
  "profile_progress": 0.75,
  "completion_percentage": 75,
  "missing_fields": ["government_id", "income_source", "occupation"],
  "completed_fields": ["first_name", "last_name", "email", "phone_number", "company_name"],
  "next_level": 3,
  "can_upgrade": false
}
```

#### 7.2 Get Available Upgrades
```http
GET /auth/progressive/available-upgrades
Authorization: Bearer {access_token}
X-Tenant-ID: {tenant_id}
```

**Response:**
```json
{
  "current_level": 2,
  "available_upgrades": [
    {
      "target_level": 3,
      "level_name": "Financial",
      "can_upgrade": false,
      "missing_requirements": ["government_id", "income_source", "occupation"],
      "estimated_time": "5-10 minutes",
      "benefits": ["Higher transaction limits", "Access to credit"]
    }
  ]
}
```

#### 7.3 Get Upgrade Progress
```http
GET /auth/progressive/upgrade-progress
Authorization: Bearer {access_token}
X-Tenant-ID: {tenant_id}
```

**Response:**
```json
{
  "current_level": 2,
  "target_level": 3,
  "progress_percentage": 60,
  "completed_steps": ["personal_info", "business_info"],
  "pending_steps": ["financial_info", "kyc_documents"],
  "estimated_completion": "2025-10-03T10:00:00Z"
}
```

#### 7.4 Check Compliance
```http
POST /auth/progressive/check-compliance
Authorization: Bearer {access_token}
X-Tenant-ID: {tenant_id}
Content-Type: application/json

{
  "action": "transfer",
  "amount": 5000,
  "currency": "USD"
}
```

**Response:**
```json
{
  "allowed": true,
  "reason": "User level sufficient",
  "required_level": 3,
  "current_level": 3
}
```

#### 7.5 Initiate Upgrade
```http
POST /auth/progressive/upgrade/initiate
Authorization: Bearer {access_token}
X-Tenant-ID: {tenant_id}
Content-Type: application/json

{
  "target_level": 3
}
```

**Response:**
```json
{
  "session_id": "upgrade-session-uuid",
  "target_level": 3,
  "required_steps": ["financial_info", "kyc_documents"],
  "expires_at": "2025-10-02T20:00:00Z"
}
```

#### 7.6 Get Upgrade Session
```http
GET /auth/progressive/upgrade/{sessionId}
Authorization: Bearer {access_token}
X-Tenant-ID: {tenant_id}
```

#### 7.7 Get Upgrade Session Status
```http
GET /auth/progressive/upgrade/{sessionId}/status
Authorization: Bearer {access_token}
X-Tenant-ID: {tenant_id}
```

**Response:**
```json
{
  "session_id": "upgrade-session-uuid",
  "status": "in_progress",
  "target_level": 3,
  "current_step": "kyc_documents",
  "progress_percentage": 75,
  "expires_at": "2025-10-02T20:00:00Z"
}
```

#### 7.8 Process Upgrade Step
```http
POST /auth/progressive/upgrade/{sessionId}/step
Authorization: Bearer {access_token}
X-Tenant-ID: {tenant_id}
Content-Type: application/json

{
  "step": "financial_info",
  "data": {
    "income_source": "employment",
    "monthly_income": 3000,
    "occupation": "Software Engineer"
  }
}
```

#### 7.9 Cancel Upgrade
```http
POST /auth/progressive/upgrade/{sessionId}/cancel
Authorization: Bearer {access_token}
X-Tenant-ID: {tenant_id}
```

#### 7.10 Get Upgrade Prompts
```http
GET /auth/progressive/prompts
Authorization: Bearer {access_token}
X-Tenant-ID: {tenant_id}
```

**Response:**
```json
{
  "prompts": [
    {
      "type": "level_upgrade",
      "message": "Complete your profile to unlock higher limits",
      "target_level": 3,
      "priority": "high"
    }
  ]
}
```

#### 7.11 Get Progressive Limits
```http
GET /auth/progressive/limits
Authorization: Bearer {access_token}
X-Tenant-ID: {tenant_id}
```

**Response:**
```json
{
  "current_level": 2,
  "limits": {
    "max_transaction_amount": 500,
    "daily_limit": 1000,
    "monthly_limit": 5000,
    "requires_mfa": false
  }
}
```

#### 7.12 Get Unlocked Features
```http
GET /auth/progressive/features/unlocked
Authorization: Bearer {access_token}
X-Tenant-ID: {tenant_id}
```

**Response:**
```json
{
  "current_level": 2,
  "unlocked_features": [
    "basic_transfers",
    "marketplace_access",
    "taxi_rides"
  ],
  "locked_features": [
    "international_transfers",
    "credit_products",
    "investment_products"
  ]
}
```

#### 7.13 Upgrade User Level
```http
PUT /auth/profile/upgrade-level
Authorization: Bearer {access_token}
X-Tenant-ID: {tenant_id}
Content-Type: application/json

{
  "target_level": 3
}
```

---

### 8. KYC Endpoints

#### 8.1 Upload KYC Document
```http
POST /auth/kyc/upload-document
Authorization: Bearer {access_token}
X-Tenant-ID: {tenant_id}
Content-Type: multipart/form-data

document_type: government_id
document_file: [binary file data]
```

#### 8.2 Verify KYC Document
```http
POST /auth/kyc/verify-document
Authorization: Bearer {access_token}
X-Tenant-ID: {tenant_id}
Content-Type: application/json

{
  "document_id": "doc-uuid"
}
```

#### 8.3 Verify Identity
```http
POST /auth/kyc/verify-identity
Authorization: Bearer {access_token}
X-Tenant-ID: {tenant_id}
Content-Type: application/json

{
  "full_legal_name": "Juan Carlos Pérez",
  "government_id": "1234567890",
  "date_of_birth": "1990-05-15"
}
```

#### 8.4 Get Verification Status
```http
GET /auth/kyc/verification-status/{verificationId}
Authorization: Bearer {access_token}
X-Tenant-ID: {tenant_id}
```

**Response:**
```json
{
  "verification_id": "verification-uuid",
  "status": "approved",
  "verified_at": "2025-10-02T12:00:00Z",
  "kyc_level": "enhanced"
}
```

#### 8.5 Perform AML Check
```http
POST /auth/kyc/aml-check
Authorization: Bearer {access_token}
X-Tenant-ID: {tenant_id}
Content-Type: application/json

{
  "full_name": "Juan Pérez",
  "government_id": "1234567890"
}
```

#### 8.6 Get User Risk Score
```http
GET /auth/kyc/risk-score
Authorization: Bearer {access_token}
X-Tenant-ID: {tenant_id}
```

**Response:**
```json
{
  "risk_score": "low",
  "score_value": 25,
  "last_updated": "2025-10-02T10:00:00Z",
  "factors": ["verified_identity", "clean_aml_check"]
}
```

---

### 9. KYC Progressive Routes (Temp Session)

#### 9.1 Get KYC Temp Session Information
```http
GET /auth/progressive/kyc/temp-session/information
Authorization: Bearer {access_token}
X-Tenant-ID: {tenant_id}
```

#### 9.2 Create KYC Temp Session
```http
POST /auth/progressive/kyc/temp-session/create
Authorization: Bearer {access_token}
X-Tenant-ID: {tenant_id}
```

**Response:**
```json
{
  "session_id": "kyc-session-uuid",
  "expires_at": "2025-10-02T18:00:00Z",
  "required_fields": ["full_legal_name", "government_id", "address"]
}
```

#### 9.3 Update KYC Session Fields
```http
PUT /auth/progressive/kyc/temp-session/fields
Authorization: Bearer {access_token}
X-Tenant-ID: {tenant_id}
Content-Type: application/json

{
  "session_id": "kyc-session-uuid",
  "full_legal_name": "Juan Carlos Pérez",
  "government_id": "1234567890",
  "address": "Av. 6 de Diciembre, Quito"
}
```

#### 9.4 Upload KYC Session Document
```http
POST /auth/progressive/kyc/temp-session/upload
Authorization: Bearer {access_token}
X-Tenant-ID: {tenant_id}
Content-Type: multipart/form-data

session_id: kyc-session-uuid
document_type: government_id
document_file: [binary file data]
```

#### 9.5 Get KYC Session Status
```http
GET /auth/progressive/kyc/temp-session/{sessionId}/status
Authorization: Bearer {access_token}
X-Tenant-ID: {tenant_id}
```

#### 9.6 Submit KYC for Processing
```http
POST /auth/progressive/kyc/temp-session/submit
Authorization: Bearer {access_token}
X-Tenant-ID: {tenant_id}
Content-Type: application/json

{
  "session_id": "kyc-session-uuid"
}
```

**Response:**
```json
{
  "success": true,
  "verification_id": "verification-uuid",
  "status": "pending",
  "estimated_completion": "2025-10-03T10:00:00Z"
}
```

---

### 10. Financial Progressive Routes (Level 3→4)

#### 10.1 Get Financial Temp Session Information
```http
GET /auth/progressive/financial/temp-session/information
Authorization: Bearer {access_token}
X-Tenant-ID: {tenant_id}
```

#### 10.2 Get Financial Available Fields
```http
GET /auth/progressive/financial/temp-session/fields
Authorization: Bearer {access_token}
X-Tenant-ID: {tenant_id}
```

**Response:**
```json
{
  "available_fields": [
    "source_of_funds",
    "estimated_monthly_volume",
    "max_transaction_amount",
    "beneficial_ownership",
    "regulatory_licenses"
  ]
}
```

#### 10.3 Submit Financial for Processing
```http
POST /auth/progressive/financial/temp-session/submit
Authorization: Bearer {access_token}
X-Tenant-ID: {tenant_id}
Content-Type: application/json

{
  "source_of_funds": "business",
  "estimated_monthly_volume": 50000,
  "max_transaction_amount": 10000,
  "beneficial_ownership": "Juan Pérez (100%)"
}
```

#### 10.4 Get Financial Session Status
```http
GET /auth/progressive/financial/temp-session/{sessionId}/status
Authorization: Bearer {access_token}
X-Tenant-ID: {tenant_id}
```

#### 10.5 Cancel Financial Session
```http
POST /auth/progressive/financial/temp-session/cancel
Authorization: Bearer {access_token}
X-Tenant-ID: {tenant_id}
Content-Type: application/json

{
  "session_id": "financial-session-uuid"
}
```

---

## 🚚 Delivery Service Endpoints

**Base URL:** `http://localhost:10000/api/v1`

### 1. Taxi Ride Operations

#### 1.1 Create Taxi Ride
```http
POST /taxi-rides
Authorization: Bearer {access_token}
X-Tenant-ID: {tenant_id}
X-Company-ID: {company_id}
Content-Type: application/json

{
  "ride_type": "standard",
  "passenger_name": "Juan Pérez",
  "passenger_phone": "+593983606090",
  "passenger_email": "juan@example.com",
  "passenger_count": 1,
  "pickup_address": "Av. 6 de Diciembre, Quito",
  "pickup_latitude": -0.1807,
  "pickup_longitude": -78.4678,
  "pickup_instructions": "Frente al edificio azul",
  "dropoff_address": "Av. República, Quito",
  "dropoff_latitude": -0.2000,
  "dropoff_longitude": -78.4850,
  "dropoff_instructions": "Entrada principal",
  "estimated_fare": 8.50,
  "special_requests": "Aire acondicionado",
  "has_luggage": false,
  "luggage_count": 0,
  "accessibility_needs": []
}
```

**Response:**
```json
{
  "id": "ride-uuid",
  "ride_number": "TAXI-20251002-001",
  "status": "REQUESTED",
  "ride_type": "standard",
  "passenger": {
    "name": "Juan Pérez",
    "phone": "+593983606090",
    "email": "juan@example.com",
    "count": 1
  },
  "pickup": {
    "address": "Av. 6 de Diciembre, Quito",
    "latitude": -0.1807,
    "longitude": -78.4678,
    "instructions": "Frente al edificio azul"
  },
  "dropoff": {
    "address": "Av. República, Quito",
    "latitude": -0.2000,
    "longitude": -78.4850,
    "instructions": "Entrada principal"
  },
  "fare": {
    "base_fare": 7.00,
    "total_amount": 8.50,
    "currency": "USD",
    "payment_status": "PENDING"
  },
  "timestamps": {
    "requested_at": "2025-10-02T15:30:00Z"
  },
  "tracking_code": "TAXI-20251002-001"
}
```

#### 1.2 Get Taxi Ride
```http
GET /taxi-rides/{id}
Authorization: Bearer {access_token}
X-Tenant-ID: {tenant_id}
```

#### 1.3 List Taxi Rides
```http
GET /taxi-rides?limit=20&offset=0&status=REQUESTED
Authorization: Bearer {access_token}
X-Tenant-ID: {tenant_id}
```

**Response:**
```json
{
  "rides": [],
  "total": 0,
  "page": 1,
  "page_size": 20,
  "total_pages": 0
}
```

#### 1.4 Update Taxi Ride Status
```http
PATCH /taxi-rides/{id}/status
Authorization: Bearer {access_token}
X-Tenant-ID: {tenant_id}
Content-Type: application/json

{
  "status": "DRIVER_ASSIGNED",
  "notes": "Driver Carlos assigned"
}
```

---

### 2. Driver Operations

#### 2.1 Get Available Drivers
```http
GET /taxi-rides/drivers/available?latitude=-0.1807&longitude=-78.4678&radius_km=5&max_results=10
Authorization: Bearer {access_token}
X-Tenant-ID: {tenant_id}
```

**Response:**
```json
{
  "drivers": [
    {
      "driver": {
        "id": "driver-uuid",
        "name": "Carlos Rodriguez",
        "phone": "+593987654321",
        "rating": 4.8,
        "total_rides": 1247
      },
      "vehicle": {
        "type": "sedan",
        "license_plate": "ABC-1234"
      },
      "current_location": {
        "latitude": -0.1810,
        "longitude": -78.4680,
        "address": "Nearby location"
      },
      "distance_km": 0.5,
      "estimated_arrival_min": 3,
      "status": "available"
    }
  ],
  "total": 1,
  "radius_km": 5,
  "location": {
    "latitude": -0.1807,
    "longitude": -78.4678
  }
}
```

#### 2.2 Assign Driver
```http
POST /taxi-rides/{id}/assign-driver
Authorization: Bearer {access_token}
X-Tenant-ID: {tenant_id}
Content-Type: application/json

{
  "driver_id": "driver-uuid",
  "assignment_type": "automatic",
  "estimated_arrival": "2025-10-02T15:35:00Z"
}
```

#### 2.3 Update Driver Location
```http
PUT /drivers/{driver_id}/location
Authorization: Bearer {access_token}
X-Tenant-ID: {tenant_id}
Content-Type: application/json

{
  "latitude": -0.1807,
  "longitude": -78.4678,
  "heading": 90,
  "speed": 25
}
```

**Response:**
```json
{
  "driver_id": "driver-uuid",
  "location": {
    "latitude": -0.1807,
    "longitude": -78.4678,
    "timestamp": "2025-10-02T15:30:00Z"
  },
  "status": "updated",
  "updated_at": "2025-10-02T15:30:00Z"
}
```

#### 2.4 Get Driver Status
```http
GET /drivers/{driver_id}/status
Authorization: Bearer {access_token}
X-Tenant-ID: {tenant_id}
```

**Response:**
```json
{
  "driver_id": "driver-uuid",
  "status": "online",
  "is_available": true,
  "current_location": {
    "latitude": -0.1807,
    "longitude": -78.4678,
    "address": "Quito Centro, Ecuador",
    "timestamp": "2025-10-02T15:28:00Z"
  },
  "last_seen": "2025-10-02T15:29:30Z",
  "active_ride_id": null,
  "updated_at": "2025-10-02T15:30:00Z"
}
```

#### 2.5 Update Driver Status
```http
PUT /drivers/{driver_id}/status
Authorization: Bearer {access_token}
X-Tenant-ID: {tenant_id}
Content-Type: application/json

{
  "status": "online",
  "reason": "Starting shift"
}
```

---

### 3. Pricing Operations

#### 3.1 Estimate Pricing
```http
POST /taxi-rides/pricing/estimate
Authorization: Bearer {access_token}
X-Tenant-ID: {tenant_id}
Content-Type: application/json

{
  "origin": {
    "latitude": -0.1807,
    "longitude": -78.4678
  },
  "destination": {
    "latitude": -0.2000,
    "longitude": -78.4850
  },
  "ride_type": "standard",
  "requested_time": "2025-10-02T16:00:00Z"
}
```

**Response:**
```json
{
  "base_fare": 2.50,
  "distance_fare": 4.80,
  "time_fare": 1.20,
  "surge_multiplier": 1.2,
  "surge_reason": "Moderate demand",
  "subtotal": 8.50,
  "surge_amount": 1.02,
  "total_estimated": 9.52,
  "currency": "USD",
  "breakdown": {
    "base_rate": 2.50,
    "per_km_rate": 0.80,
    "per_minute_rate": 0.15,
    "distance_km": 6.0,
    "duration_minutes": 8
  },
  "valid_for_minutes": 5,
  "estimate_id": "estimate-uuid",
  "timestamp": "2025-10-02T15:30:00Z"
}
```

#### 3.2 Get Surge Zones
```http
GET /taxi-rides/pricing/surge-zones
Authorization: Bearer {access_token}
X-Tenant-ID: {tenant_id}
```

**Response:**
```json
{
  "surge_zones": [
    {
      "zone_id": "quito_centro",
      "name": "Centro Histórico",
      "surge_multiplier": 1.5,
      "reason": "High demand",
      "polygon": [
        {"latitude": -0.215, "longitude": -78.515},
        {"latitude": -0.215, "longitude": -78.495},
        {"latitude": -0.205, "longitude": -78.495},
        {"latitude": -0.205, "longitude": -78.515}
      ],
      "updated_at": "2025-10-02T15:20:00Z"
    }
  ],
  "updated_at": "2025-10-02T15:30:00Z"
}
```

---

### 4. Booking Operations

#### 4.1 Request Ride
```http
POST /taxi-rides/booking/request
Authorization: Bearer {access_token}
X-Tenant-ID: {tenant_id}
Content-Type: application/json

{
  "ride_id": "ride-uuid",
  "preferred_driver_id": "driver-uuid",
  "max_wait_time": 10
}
```

**Response:**
```json
{
  "booking_id": "booking-uuid",
  "status": "searching",
  "estimated_wait_time": 5,
  "search_timeout": 120,
  "message": "Buscando conductor disponible...",
  "created_at": "2025-10-02T15:30:00Z",
  "expires_at": "2025-10-02T15:32:00Z"
}
```

#### 4.2 Get Booking Status
```http
GET /taxi-rides/booking/{booking_id}/status
Authorization: Bearer {access_token}
X-Tenant-ID: {tenant_id}
```

**Response:**
```json
{
  "booking_id": "booking-uuid",
  "status": "driver_found",
  "estimated_wait_time": 3,
  "driver_info": {
    "id": "driver-uuid",
    "name": "Carlos Rodriguez",
    "phone": "+593987654321",
    "rating": 4.8,
    "total_rides": 1247,
    "photo": "https://example.com/driver_photo.jpg"
  },
  "vehicle_info": {
    "make": "Toyota",
    "model": "Corolla",
    "year": 2020,
    "color": "Blanco",
    "license_plate": "ABC-1234",
    "type": "sedan"
  },
  "estimated_arrival": "2025-10-02T15:33:00Z",
  "message": "Conductor asignado, en camino a la ubicación",
  "updated_at": "2025-10-02T15:30:00Z"
}
```

---

## 🔑 Required Headers

### All Authenticated Requests

```http
Authorization: Bearer {access_token}
X-Tenant-ID: {tenant_id}
X-Company-ID: {company_id}
Content-Type: application/json
```

### Header Descriptions

| Header | Required | Description |
|--------|----------|-------------|
| `Authorization` | Yes | Bearer token from login/register |
| `X-Tenant-ID` | Yes | Tenant UUID from user profile |
| `X-Company-ID` | Yes* | Company UUID from user profile |
| `Content-Type` | POST/PUT | Always `application/json` |

*Required for delivery operations, optional for auth operations

---

## 📊 Progressive Authentication Levels

### Level 1: Basic (Friction-Free)
- **Duration:** 30 seconds
- **Required:** Phone/Email verification
- **Limits:** $100/transaction, $500/month
- **Features:** Marketplace browsing, basic transfers

### Level 2: Enhanced (Profile Completion)
- **Duration:** 2 minutes
- **Required:** Name, DOB, country, company info
- **Limits:** $500/transaction, $5,000/month
- **Features:** Taxi rides, food delivery, product purchases

### Level 3: Financial (Full KYC)
- **Duration:** 5-10 minutes
- **Required:** Government ID, tax ID, income source, address
- **Limits:** $5,000/transaction, $50,000/month
- **Features:** International transfers, credit products

### Level 4: Enterprise (Enhanced Due Diligence)
- **Duration:** 1-2 business days
- **Required:** Beneficial ownership, regulatory licenses, AML check
- **Limits:** Unlimited (case by case)
- **Features:** Investment products, B2B services, white-label

---

## ⚠️ Error Handling

### Standard Error Response Format

```json
{
  "error": "ERROR_CODE",
  "message": "Human-readable error message",
  "code": "400",
  "details": {
    "field": "specific_field",
    "reason": "validation_failed"
  },
  "timestamp": "2025-10-02T15:30:00Z"
}
```

### Common Error Codes

| HTTP Status | Error Code | Description |
|-------------|-----------|-------------|
| 400 | `INVALID_REQUEST` | Malformed request body |
| 401 | `UNAUTHORIZED` | Invalid or expired token |
| 403 | `FORBIDDEN` | Insufficient permissions |
| 404 | `NOT_FOUND` | Resource not found |
| 409 | `CONFLICT` | Duplicate resource |
| 422 | `VALIDATION_ERROR` | Field validation failed |
| 429 | `RATE_LIMIT_EXCEEDED` | Too many requests |
| 500 | `INTERNAL_ERROR` | Server error |

### Progressive Auth Specific Errors

| Error Code | Description |
|-----------|-------------|
| `INSUFFICIENT_LEVEL` | User level too low for operation |
| `KYC_REQUIRED` | KYC verification required |
| `PROFILE_INCOMPLETE` | Missing required profile fields |
| `UPGRADE_IN_PROGRESS` | Cannot start new upgrade session |
| `SESSION_EXPIRED` | Upgrade session expired |

---

## 📝 Notes for Flutter Team

### 1. Token Management
- Store `access_token` securely (Flutter Secure Storage)
- Refresh token automatically before expiration
- Handle 401 errors by refreshing token or forcing re-login

### 2. Multi-tenant Context
- Store `tenant_id` and `company_id` from login response
- Include in all subsequent requests
- These IDs are crucial for data isolation

### 3. Progressive Auth UX
- Check `profile_progress` on app startup
- Show upgrade prompts based on `GET /auth/progressive/prompts` response
- Guide users through level upgrades with clear benefits

### 4. Real-time Updates
- Implement WebSocket for taxi ride tracking
- Poll `/taxi-rides/booking/{id}/status` every 5 seconds during driver search
- Use Server-Sent Events for delivery status updates

### 5. Error Handling
- Always check `success` field in responses
- Display `message` field to users
- Log `details` for debugging

### 6. Tenant/Company Sync (⚡ Important)
- `PUT /auth/profile` automatically syncs with Tenant and Company services
- No additional calls needed after profile update
- Backend logs will show: `✅ Tenant and company profile synchronized`

### 7. Endpoint Routing via Kong
- All endpoints route through Kong Gateway (port 10000)
- Internal services (auth: 10100, delivery: 10203) not directly accessible
- Kong handles rate limiting, authentication preprocessing, and request transformations

---

**Document Created:** 2025-10-02
**Last Updated:** 2025-10-02
**Version:** 2.0 - REAL ENDPOINTS
**Status:** ✅ PRODUCTION READY
**Contrasted With:** auth_handler.go, taxi_handler.go (actual implementation)
