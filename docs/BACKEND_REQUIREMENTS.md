# Backend API Requirements - Complete Specification

This document provides a complete specification of what the backend must implement for the SpendWise frontend application to function correctly.

## Table of Contents

1. [Response Format](#response-format)
2. [Authentication Endpoints](#authentication-endpoints)
3. [Statement/File Upload Endpoints](#statementfile-upload-endpoints)
4. [Transaction Endpoints](#transaction-endpoints)
5. [Analytics Endpoints](#analytics-endpoints)
6. [Budget Endpoints](#budget-endpoints)
7. [Profile Management Endpoints](#profile-management-endpoints)
8. [Error Handling](#error-handling)
9. [Critical Data Requirements](#critical-data-requirements)
10. [Testing Checklist](#testing-checklist)

---

## Response Format

**ALL API responses MUST follow this format:**

```json
{
  "success": true,
  "data": { ... }
}
```

**For errors:**
```json
{
  "success": false,
  "error": {
    "message": "Error description",
    "code": "ERROR_CODE",
    "statusCode": 400
  }
}
```

**Important:** The frontend's `ApiService` automatically extracts the `data` field from successful responses. Services receive only the `data` object, not the full response.

---

## Authentication Endpoints

### 1. POST `/api/auth/register`

**Request:**
```json
{
  "email": "user@example.com",
  "password": "password123",
  "name": "John Doe"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "user_123",
      "email": "user@example.com",
      "name": "John Doe",
      "createdAt": "2024-01-15T10:30:00Z"
    },
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

### 2. POST `/api/auth/login`

**Request:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response:** (Same as register)

### 3. GET `/api/auth/me`

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response:**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "user_123",
      "email": "user@example.com",
      "name": "John Doe",
      "createdAt": "2024-01-15T10:30:00Z"
    }
  }
}
```

### 4. PUT `/api/auth/me`

**Headers:**
```
Authorization: Bearer <access_token>
```

**Request:**
```json
{
  "name": "John Updated",
  "email": "newemail@example.com"
}
```

**Response:** (Same as GET /auth/me)

### 5. POST `/api/auth/change-password`

**Headers:**
```
Authorization: Bearer <access_token>
```

**Request:**
```json
{
  "currentPassword": "oldpassword",
  "newPassword": "newpassword123"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "message": "Password changed successfully"
  }
}
```

### 6. POST `/api/auth/refresh`

**Request:**
```json
{
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

### 7. POST `/api/auth/logout`

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response:**
```json
{
  "success": true,
  "data": {
    "message": "Logged out successfully"
  }
}
```

---

## Statement/File Upload Endpoints

### 1. POST `/api/statements/upload`

**Headers:**
```
Authorization: Bearer <access_token>
Content-Type: multipart/form-data
```

**Request (multipart/form-data):**
- `file`: File (PDF, image, etc.)
- `profileName`: (optional) string - Name for this statement/profile
- `profileDescription`: (optional) string - Description
- `accountType`: (optional) string - e.g., "Checking", "Savings"
- `bankName`: (optional) string - Bank name
- `color`: (optional) string - Hex color code
- `icon`: (optional) string - Icon identifier

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "stmt_123",
    "fileName": "statement.pdf",
    "filePath": "/uploads/statement.pdf",
    "uploadDate": "2024-01-15T10:30:00Z",
    "status": "processing",
    "transactionCount": 0,
    "statementPeriodStart": null,
    "statementPeriodEnd": null,
    "isProcessed": false,
    "profileName": "Main Account",
    "profileDescription": "Primary checking account",
    "accountType": "Checking",
    "bankName": "Example Bank",
    "color": "#FF5733",
    "icon": "account_balance",
    "isDefault": false
  }
}
```

**Important:** 
- Initially returns `status: "processing"`
- Backend should simulate processing (2-3 seconds delay)
- After processing, status should change to `"processed"`
- Backend should generate mock transactions for the statement

### 2. GET `/api/statements`

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response:**
```json
{
  "success": true,
  "data": {
    "statements": [
      {
        "id": "stmt_123",
        "fileName": "statement.pdf",
        "uploadDate": "2024-01-15T10:30:00Z",
        "status": "processed",
        "transactionCount": 50,
        "statementPeriodStart": "2024-01-01T00:00:00Z",
        "statementPeriodEnd": "2024-01-31T23:59:59Z",
        "isProcessed": true,
        "profileName": "Main Account",
        "profileDescription": "Primary checking account",
        "accountType": "Checking",
        "bankName": "Example Bank",
        "color": "#FF5733",
        "icon": "account_balance",
        "isDefault": true
      }
    ]
  }
}
```

### 3. GET `/api/statements/{id}`

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response:** (Same format as single statement object from list)

### 4. POST `/api/statements/{id}/delete`

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response:**
```json
{
  "success": true,
  "data": {
    "message": "Statement deleted successfully"
  }
}
```

### 5. PUT `/api/statements/{id}/profile`

**Headers:**
```
Authorization: Bearer <access_token>
```

**Request:**
```json
{
  "profileName": "Updated Name",
  "profileDescription": "Updated description",
  "accountType": "Savings",
  "bankName": "New Bank",
  "color": "#33FF57",
  "icon": "savings"
}
```

**Response:** (Updated statement object)

### 6. POST `/api/statements/{id}/set-default`

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response:**
```json
{
  "success": true,
  "data": {
    "message": "Default statement updated"
  }
}
```

---

## Transaction Endpoints

### 1. GET `/api/transactions`

**Headers:**
```
Authorization: Bearer <access_token>
```

**Query Parameters:**
- `statementId` (optional): Filter by statement ID
- `startDate` (optional): ISO 8601 date string
- `endDate` (optional): ISO 8601 date string
- `category` (optional): Category name
- `account` (optional): Account name
- `limit` (optional): Number of results
- `offset` (optional): Pagination offset

**Response:**
```json
{
  "success": true,
  "data": {
    "transactions": [
      {
        "id": "txn_123",
        "date": "2024-01-15T10:30:00Z",
        "description": "Grocery shopping at supermarket",
        "amount": 150.75,
        "type": "expense",
        "category": "Gıda",
        "account": "Main Account"
      },
      {
        "id": "txn_124",
        "date": "2024-01-14T09:00:00Z",
        "description": "Salary deposit",
        "amount": 5000.00,
        "type": "income",
        "category": null,
        "account": "Main Account"
      }
    ],
    "total": 100,
    "limit": 50,
    "offset": 0
  }
}
```

**CRITICAL REQUIREMENTS:**
1. **`type` field MUST be exactly `"income"` or `"expense"`** (lowercase, required)
2. **`category` field is REQUIRED for expense transactions** - cannot be null for expenses
3. **`date` MUST be valid ISO 8601 format** - frontend will crash if invalid
4. **`amount` MUST be a number** (integer or float) and should be > 0
5. **Valid category names:** "Gıda", "Ulaşım", "Alışveriş", "Faturalar", "Eğlence", "Sağlık", "Eğitim", "Diğer" (or any custom category)

### 2. GET `/api/transactions/summary`

**Headers:**
```
Authorization: Bearer <access_token>
```

**Query Parameters:**
- `statementId` (optional): Filter by statement ID
- `startDate` (optional): ISO 8601 date string
- `endDate` (optional): ISO 8601 date string

**Response:**
```json
{
  "success": true,
  "data": {
    "totalIncome": 5000.00,
    "totalExpenses": 3000.00,
    "savings": 2000.00,
    "transactionCount": 50,
    "period": {
      "start": "2024-01-01T00:00:00Z",
      "end": "2024-01-31T23:59:59Z"
    }
  }
}
```

---

## Analytics Endpoints

All analytics endpoints support `statementId` query parameter to filter by statement.

### 1. GET `/api/analytics/categories`

**Query Parameters:**
- `statementId` (optional): Filter by statement ID
- `startDate` (optional): ISO 8601 date string
- `endDate` (optional): ISO 8601 date string

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "category": "Gıda",
      "totalAmount": 1500.00,
      "percentage": 35.5,
      "transactionCount": 25
    },
    {
      "category": "Ulaşım",
      "totalAmount": 800.00,
      "percentage": 18.9,
      "transactionCount": 15
    },
    {
      "category": "Alışveriş",
      "totalAmount": 600.00,
      "percentage": 14.2,
      "transactionCount": 12
    }
  ]
}
```

### 2. GET `/api/analytics/trends`

**Query Parameters:**
- `statementId` (optional)
- `startDate` (optional)
- `endDate` (optional)
- `period` (optional): "daily" | "weekly" | "monthly"

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "date": "2024-01-15T00:00:00Z",
      "income": 500.00,
      "expenses": 300.00,
      "savings": 200.00
    },
    {
      "date": "2024-01-16T00:00:00Z",
      "income": 0.00,
      "expenses": 150.00,
      "savings": -150.00
    }
  ]
}
```

### 3. GET `/api/analytics/insights`

**Query Parameters:**
- `statementId` (optional)

**Response:**
```json
{
  "success": true,
  "data": {
    "savingsRate": 20.5,
    "topSpendingCategory": "Gıda",
    "averageDailySpending": 100.00,
    "biggestExpense": 500.00,
    "recommendations": [
      "Your spending on Gıda is 35% higher than average",
      "Consider setting a budget for Ulaşım category"
    ]
  }
}
```

### 4. GET `/api/analytics/monthly-trends`

**Query Parameters:**
- `statementId` (optional)

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "month": "2024-01-01T00:00:00Z",
      "income": 5000.00,
      "expenses": 3000.00,
      "savings": 2000.00
    },
    {
      "month": "2024-02-01T00:00:00Z",
      "income": 5200.00,
      "expenses": 2800.00,
      "savings": 2400.00
    }
  ]
}
```

### 5. GET `/api/analytics/category-trends`

**Query Parameters:**
- `statementId` (optional)

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "category": "Gıda",
      "color": "#FF5733",
      "monthlyData": [
        {
          "month": "2024-01-01T00:00:00Z",
          "amount": 1500.00
        },
        {
          "month": "2024-02-01T00:00:00Z",
          "amount": 1600.00
        }
      ]
    }
  ]
}
```

### 6. GET `/api/analytics/weekly-patterns`

**Query Parameters:**
- `statementId` (optional)

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "dayOfWeek": 1,
      "averageSpending": 120.50,
      "transactionCount": 15
    },
    {
      "dayOfWeek": 2,
      "averageSpending": 95.30,
      "transactionCount": 12
    }
  ]
}
```

**Note:** `dayOfWeek` is 1-7 (1 = Monday, 7 = Sunday)

### 7. GET `/api/analytics/year-over-year`

**Query Parameters:**
- `statementId` (optional)

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "month": "2024-01-01T00:00:00Z",
      "currentYear": 3000.00,
      "previousYear": 2800.00,
      "changePercent": 7.14
    }
  ]
}
```

### 8. GET `/api/analytics/forecast`

**Query Parameters:**
- `statementId` (optional)

**Response:**
```json
{
  "success": true,
  "data": {
    "predictedExpenses": 3200.00,
    "predictedIncome": 5000.00,
    "predictedSavings": 1800.00,
    "confidence": 85.5,
    "basedOnMonths": 6
  }
}
```

---

## Budget Endpoints

### 1. GET `/api/budgets`

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response:**
```json
{
  "success": true,
  "data": {
    "budgets": [
      {
        "id": "budget_123",
        "categoryId": "food",
        "categoryName": "Gıda",
        "amount": 2000.00,
        "period": "monthly",
        "startDate": "2024-01-01T00:00:00Z",
        "endDate": "2024-01-31T23:59:59Z",
        "createdAt": "2024-01-01T00:00:00Z"
      }
    ]
  }
}
```

### 2. POST `/api/budgets`

**Headers:**
```
Authorization: Bearer <access_token>
```

**Request:**
```json
{
  "categoryId": "food",
  "amount": 2000.00,
  "period": "monthly",
  "startDate": "2024-01-01T00:00:00Z",
  "endDate": "2024-01-31T23:59:59Z"
}
```

**Response:** (Created budget object)

### 3. GET `/api/budgets/compare`

**Headers:**
```
Authorization: Bearer <access_token>
```

**Query Parameters:**
- `statementId` (optional): Filter by statement ID

**Response:**
```json
{
  "success": true,
  "data": {
    "comparisons": [
      {
        "budget": {
          "id": "budget_123",
          "categoryId": "food",
          "categoryName": "Gıda",
          "amount": 2000.00
        },
        "actualSpending": 1800.00,
        "remaining": 200.00,
        "percentageUsed": 90.0,
        "isOverBudget": false
      }
    ]
  }
}
```

### 4. DELETE `/api/budgets/{id}`

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response:**
```json
{
  "success": true,
  "data": {
    "message": "Budget deleted successfully"
  }
}
```

---

## Profile Management Endpoints

These endpoints are already covered in the Statement endpoints section:
- `PUT /api/statements/{id}/profile` - Update profile metadata
- `POST /api/statements/{id}/set-default` - Set default statement

---

## Error Handling

### Error Response Format

```json
{
  "success": false,
  "error": {
    "message": "Error description",
    "code": "ERROR_CODE",
    "statusCode": 400
  }
}
```

### Common Error Codes

- `TOKEN_EXPIRED` - Access token has expired (statusCode: 401)
- `UNAUTHORIZED` - Invalid or missing token (statusCode: 401)
- `NOT_FOUND` - Resource not found (statusCode: 404)
- `VALIDATION_ERROR` - Request validation failed (statusCode: 400)
- `SERVER_ERROR` - Internal server error (statusCode: 500)

### Token Expiration Handling

When a request returns `TOKEN_EXPIRED` (401), the frontend will:
1. Automatically call `/api/auth/refresh` with the refresh token
2. Retry the original request with the new access token
3. If refresh fails, user is logged out

---

## Critical Data Requirements

### Transaction Data Requirements

**MUST HAVE:**
1. ✅ `type`: Exactly `"income"` or `"expense"` (lowercase)
2. ✅ `category`: Required for ALL expense transactions (cannot be null)
3. ✅ `date`: Valid ISO 8601 format (e.g., "2024-01-15T10:30:00Z")
4. ✅ `amount`: Number > 0
5. ✅ `description`: String (can be empty but should exist)

**Why This Matters:**
- If `type` is missing or wrong → Categories won't show
- If `category` is null for expenses → Categories won't show
- If `date` is invalid → Frontend will crash
- If `amount` is 0 or negative → May cause chart errors

### Statement Processing Requirements

**When a file is uploaded:**
1. Return statement with `status: "processing"`
2. Simulate processing delay (2-3 seconds)
3. Generate mock transactions for the statement
4. Update statement `status: "processed"`
5. Set `transactionCount` to number of generated transactions
6. Set `statementPeriodStart` and `statementPeriodEnd` dates

**Generated Transactions Should:**
- Have `type: "expense"` or `type: "income"`
- Have `category` field for all expenses
- Have valid dates within the statement period
- Have amounts > 0
- Have realistic descriptions

### Empty Data Handling

**When no data exists:**
- Return empty arrays: `{ "success": true, "data": { "transactions": [] } }`
- Don't return null or missing fields
- Frontend handles empty states gracefully

---

## Testing Checklist

### 1. Authentication
- [ ] Register new user
- [ ] Login with credentials
- [ ] Get current user info
- [ ] Update user profile
- [ ] Change password
- [ ] Refresh token
- [ ] Logout

### 2. File Upload
- [ ] Upload statement file
- [ ] Verify status starts as "processing"
- [ ] Verify status changes to "processed" after delay
- [ ] Verify transactions are generated
- [ ] List all statements
- [ ] Get statement details
- [ ] Update statement profile
- [ ] Set default statement
- [ ] Delete statement

### 3. Transactions
- [ ] Get all transactions
- [ ] Get transactions filtered by statementId
- [ ] Get transactions with date filters
- [ ] Get transactions with category filter
- [ ] Verify transactions have `type` field
- [ ] Verify expense transactions have `category` field
- [ ] Get transaction summary
- [ ] Get summary filtered by statementId

### 4. Analytics
- [ ] Get category breakdown
- [ ] Get spending trends
- [ ] Get financial insights
- [ ] Get monthly trends
- [ ] Get category trends
- [ ] Get weekly patterns
- [ ] Get year-over-year comparison
- [ ] Get spending forecast
- [ ] Test all analytics with statementId filter

### 5. Budgets
- [ ] List budgets
- [ ] Create budget
- [ ] Get budget comparison
- [ ] Delete budget

### 6. Data Validation
- [ ] Verify all transactions have `type: "income"` or `"expense"`
- [ ] Verify all expense transactions have `category`
- [ ] Verify all dates are valid ISO 8601 format
- [ ] Verify all amounts are numbers > 0
- [ ] Test with empty data (should return empty arrays)

### 7. Error Handling
- [ ] Test with invalid token (should return 401)
- [ ] Test with expired token (should return TOKEN_EXPIRED)
- [ ] Test with invalid request (should return validation error)
- [ ] Test with missing resource (should return 404)

---

## Common Issues & Solutions

### Issue: Transactions load but categories are empty

**Cause:** 
- Transactions don't have `type: "expense"`
- Expense transactions missing `category` field

**Solution:**
- Ensure ALL transactions have `type` field
- Ensure ALL expense transactions have `category` field
- Verify category names match expected format

### Issue: Charts show red box errors

**Cause:**
- `horizontalInterval` calculation results in zero
- Transactions have zero amounts

**Solution:**
- Ensure transactions have amounts > 0
- Frontend handles this, but backend should provide valid data

### Issue: "No data" messages everywhere

**Cause:**
- Backend returns empty transactions array
- Transactions don't have required fields

**Solution:**
1. Verify file was processed (`status: "processed"`)
2. Verify transactions were created for statement
3. Verify transactions have `type` and `category` fields
4. Check console logs for transaction count

### Issue: Date parsing errors

**Cause:**
- Invalid date format in transactions

**Solution:**
- Ensure all dates are ISO 8601 format: "2024-01-15T10:30:00Z"
- Use UTC timezone
- Include time component

---

## Implementation Notes

### Mock Data Generation

For MVP, the backend should generate realistic mock data:

1. **Transaction Distribution:**
   - 70% expenses, 30% income
   - Expenses distributed across categories
   - Dates spanning last 12 months

2. **Category Distribution:**
   - Gıda: 30-40%
   - Ulaşım: 15-20%
   - Alışveriş: 10-15%
   - Faturalar: 10-15%
   - Eğlence: 5-10%
   - Sağlık: 5-10%
   - Eğitim: 3-5%
   - Diğer: 5-10%

3. **Amount Ranges:**
   - Expenses: 10-500 TRY
   - Income: 1000-10000 TRY
   - Monthly variations (higher in December, etc.)

### Statement Processing Flow

```
1. User uploads file
   ↓
2. Backend receives file
   ↓
3. Return statement with status: "processing"
   ↓
4. Simulate processing (2-3 seconds)
   ↓
5. Generate mock transactions
   ↓
6. Update statement status: "processed"
   ↓
7. Frontend polls until status is "processed"
   ↓
8. Frontend loads transactions for statement
```

---

## Summary

The backend must:

1. ✅ Return all responses in `{ "success": true, "data": {...} }` format
2. ✅ Implement all endpoints listed above
3. ✅ Ensure transactions have `type` and `category` fields
4. ✅ Use valid ISO 8601 date formats
5. ✅ Handle authentication with JWT tokens
6. ✅ Support `statementId` filtering for all relevant endpoints
7. ✅ Generate mock transactions when files are processed
8. ✅ Return empty arrays when no data exists (not null)
9. ✅ Handle errors with proper error codes
10. ✅ Support token refresh for expired tokens

**Most Critical:** Transactions MUST have `type: "expense"` or `"income"` and expense transactions MUST have a `category` field, otherwise the frontend will show empty categories and widgets.
