# Frontend-Backend Integration Summary

This document explains how the frontend is connected to the backend API based on the `FRONTEND_INTEGRATION_GUIDE.md`.

## Architecture Overview

```
Frontend (Flutter/Dart)
    ↓
Services Layer (lib/data/services/)
    ↓
API Service (lib/data/services/api_service.dart)
    ↓
Backend API (http://localhost:5000/api)
```

## Response Format Handling

The backend returns responses in this format:
```json
{
  "success": true,
  "data": { ... }
}
```

All services automatically extract the `data` field from responses. The `ApiService._handleResponse()` method:
1. Checks for `success: false` and throws `ApiError` if found
2. Extracts `data` field from successful responses
3. Handles error responses: `{ "success": false, "error": { "message": "...", "code": "...", "statusCode": ... } }`

## Service Layer Structure

### 1. ApiService (`lib/data/services/api_service.dart`)
- **Purpose**: Base HTTP client that handles all API communication
- **Features**:
  - Automatic response format parsing (`success`/`data` extraction)
  - Error handling with `ApiError` exceptions
  - Authentication token management
  - Support for GET, POST, PUT, DELETE, and multipart uploads

### 2. AuthService (`lib/data/services/auth_service.dart`)
- **Endpoints**:
  - `POST /auth/register` - User registration
  - `POST /auth/login` - User login
  - `GET /auth/me` - Get current user
  - `PUT /auth/me` - Update profile
  - `POST /auth/change-password` - Change password
  - `POST /auth/refresh` - Refresh token
  - `POST /auth/logout` - Logout

### 3. UploadService (`lib/data/services/upload_service.dart`)
- **Endpoints**:
  - `POST /statements/upload` - Upload statement file
  - `GET /statements` - List all statements
  - `GET /statements/{id}` - Get statement details
  - `POST /statements/{id}/delete` - Delete statement

**Key Features**:
- Handles file upload with multipart/form-data
- Returns statement with `status: "processing"` initially
- Frontend polls for status until `status: "processed"`

### 4. TransactionService (`lib/data/services/transaction_service.dart`)
- **Endpoints**:
  - `GET /transactions` - Get transactions (supports `statementId` filter)
  - `GET /transactions/summary` - Get transaction summary (supports `statementId` filter)

**File Selection Support**:
- All methods accept optional `statementId` parameter
- When provided, returns only transactions for that statement
- When omitted, returns all user transactions

### 5. AnalyticsService (`lib/data/services/analytics_service.dart`)
- **Endpoints** (all support `statementId` filter):
  - `GET /analytics/categories` - Category breakdown
  - `GET /analytics/trends` - Spending trends
  - `GET /analytics/insights` - Financial insights
  - `GET /analytics/monthly-trends` - Monthly trends
  - `GET /analytics/category-trends` - Category trends over time
  - `GET /analytics/weekly-patterns` - Weekly patterns
  - `GET /analytics/year-over-year` - Year-over-year comparison
  - `GET /analytics/forecast` - Spending forecast

### 6. BudgetService (`lib/data/services/budget_service.dart`)
- **Endpoints**:
  - `GET /budgets` - List budgets
  - `POST /budgets` - Create/update budget
  - `GET /budgets/compare` - Budget vs actual (supports `statementId` filter)
  - `DELETE /budgets/{id}` - Delete budget

## Provider Layer

### AuthProvider (`lib/providers/auth_provider.dart`)
- Manages authentication state
- Stores tokens in SharedPreferences
- Automatically refreshes expired tokens
- Provides `isAuthenticated` state

### UploadProvider (`lib/providers/upload_provider.dart`)
- Manages statement upload state
- Handles upload progress
- Polls for processing status
- Loads statements from backend on initialization

### TransactionProvider (`lib/providers/transaction_provider.dart`)
- Manages transaction list state
- Provides computed values (totalIncome, totalExpenses, savings)
- Handles transaction filtering

### BudgetProvider (`lib/providers/budget_provider.dart`)
- Manages budget list state
- Provides budget comparison calculations

## Data Initialization

### AppInitializer (`lib/core/utils/app_initializer.dart`)
- Called when app starts (in `HomeScreen.initState()`)
- Loads initial data from backend:
  1. Transactions via `TransactionService.getTransactions()`
  2. Budgets via `BudgetService.getBudgets()`
- Only runs if user is authenticated

## File Selection Feature

The file selection feature allows users to view data for a specific uploaded statement:

1. **User uploads file** → `UploadService.uploadStatement()`
   - Returns statement with `status: "processing"`
   
2. **Backend processes file** (fake analyzer generates mock data)
   - Status changes to `"processed"` when done
   
3. **User selects statement** → Store `statementId` in app state
   
4. **All API calls include `statementId`**:
   ```dart
   // Get transactions for selected file
   transactionService.getTransactions(statementId: selectedStatementId);
   
   // Get analytics for selected file
   analyticsService.getCategoryBreakdown(statementId: selectedStatementId);
   ```

5. **When no `statementId` provided**:
   - Returns data for ALL user's transactions (across all statements)

## Error Handling

All errors are thrown as `ApiError` exceptions:
```dart
class ApiError {
  final String message;
  final int? statusCode;
  final String? errorCode; // Backend uses "code" field
}
```

Error format from backend:
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

## Configuration

### API Base URL
Located in `lib/core/constants/api_constants.dart`:
```dart
static const String baseUrl = 'http://localhost:5000/api';
```

**To change the backend URL:**
1. Update `baseUrl` in `api_constants.dart`
2. For development: `http://localhost:5000/api`
3. For production: Update to your production URL

## Authentication Flow

1. **User logs in** → `AuthService.login()`
   - Returns `access_token` and `refresh_token`
   - Stored in SharedPreferences via `AuthProvider`

2. **All API calls** → Include token in header:
   ```
   Authorization: Bearer <access_token>
   ```

3. **Token expires** → `AuthProvider` automatically refreshes using `refresh_token`

4. **User logs out** → `AuthService.logout()` clears tokens

## File Upload Flow

1. **User selects file** → `FilePickerButton` widget
2. **File uploaded** → `UploadProvider.uploadFile()`
   - Shows upload progress
   - Calls `UploadService.uploadStatement()`
   - Returns statement with `status: "processing"`

3. **Polling for status** → `UploadProvider._pollForProcessingStatus()`
   - Polls `GET /statements/{id}` every 1 second
   - Stops when `status: "processed"`

4. **Load transactions** → After processing, transactions are loaded for that statement

## Testing the Integration

### 1. Start Backend
```bash
# Make sure backend is running on http://localhost:5000
```

### 2. Update Base URL (if needed)
```dart
// lib/core/constants/api_constants.dart
static const String baseUrl = 'http://YOUR_IP:5000/api';
```

### 3. Run Frontend
```bash
flutter run
```

### 4. Test Flow
1. Register/Login user
2. Upload a statement file
3. Wait for processing (status changes to "processed")
4. View transactions and analytics
5. Test file selection (if implemented in UI)

## Common Issues & Solutions

### Issue: "Network error" or connection refused
**Solution**: 
- Check backend is running
- Verify base URL in `api_constants.dart`
- Check firewall/network settings

### Issue: "Unauthorized" errors
**Solution**:
- Check if token is being set: `apiService.setAuthToken(token)`
- Verify token is valid (not expired)
- Check `AuthProvider` is storing tokens correctly

### Issue: Response format errors
**Solution**:
- Verify backend returns `{ "success": true, "data": {...} }` format
- Check `ApiService._handleResponse()` is extracting `data` correctly

### Issue: Statement status stuck on "processing"
**Solution**:
- Check backend is actually processing files
- Verify fake analyzer is working
- Check polling logic in `UploadProvider`

## Next Steps

1. **Implement File Selection UI**:
   - Add dropdown/selector to choose statement
   - Store `selectedStatementId` in state
   - Pass `statementId` to all service calls

2. **Add Error UI**:
   - Show error messages from `ApiError`
   - Handle network errors gracefully
   - Add retry mechanisms

3. **Add Loading States**:
   - Show loading indicators during API calls
   - Disable buttons during operations

4. **Add Refresh Functionality**:
   - Pull-to-refresh on screens
   - Manual refresh buttons

## File Structure

```
lib/
├── core/
│   ├── constants/
│   │   └── api_constants.dart          # API endpoints & base URL
│   └── utils/
│       └── app_initializer.dart        # Data initialization
├── data/
│   ├── models/                         # Data models
│   ├── services/
│   │   ├── api_service.dart            # Base HTTP client
│   │   ├── auth_service.dart           # Authentication
│   │   ├── upload_service.dart         # Statement upload
│   │   ├── transaction_service.dart    # Transactions
│   │   ├── analytics_service.dart      # Analytics
│   │   └── budget_service.dart         # Budgets
│   └── mock/                           # Mock data (for testing)
└── providers/
    ├── auth_provider.dart              # Auth state
    ├── upload_provider.dart            # Upload state
    ├── transaction_provider.dart       # Transaction state
    └── budget_provider.dart            # Budget state
```

## Summary

The frontend is now fully integrated with the backend API:
- ✅ All services configured to use backend (not mock data)
- ✅ Response format handling (`success`/`data` extraction)
- ✅ Error handling with proper error codes
- ✅ Authentication token management
- ✅ File upload with status polling
- ✅ File selection support via `statementId` parameter
- ✅ All analytics endpoints implemented
- ✅ Budget management endpoints implemented

The integration follows the structure defined in `FRONTEND_INTEGRATION_GUIDE.md` and is ready for testing with the backend.


