# Bug Fixes: File Upload and Edit Profile

## Issues Fixed

### 1. File Upload Not Working

**Problem**: File upload was failing due to incorrect response parsing.

**Root Cause**: 
- The `ApiService._handleResponse()` method already extracts the `data` field from backend responses
- Backend returns: `{ "success": true, "data": { "id": "...", "fileName": "...", ... } }`
- After `ApiService` extraction, the response is the statement object directly
- But `UploadService.uploadStatement()` was looking for `response['statement']` which doesn't exist

**Fix Applied**:
- Updated `UploadService.uploadStatement()` to parse the response directly
- Added fallback parsing for backward compatibility
- Added better error messages for debugging
- Added `setAuthToken()` method to `UploadService` to ensure token is always current
- Updated `UploadProvider.uploadFile()` to refresh token before upload

**Files Modified**:
- `lib/data/services/upload_service.dart`
- `lib/providers/upload_provider.dart`

### 2. Edit Profile Not Working

**Problem**: Updating user profile was failing due to incorrect response parsing.

**Root Cause**:
- The `ApiService.put()` method already extracts the `data` field from backend responses
- Backend returns: `{ "success": true, "data": { "user": {...} } }`
- After `ApiService` extraction, the response is `{ "user": {...} }`
- But `AuthService.updateProfile()` was looking for `json['data']['user']` which doesn't exist

**Fix Applied**:
- Updated `AuthService.updateProfile()` to parse `json['user']` directly
- Also fixed `AuthService.getCurrentUser()` which had the same issue
- Added fallback parsing for backward compatibility

**Files Modified**:
- `lib/data/services/auth_service.dart`

### 3. Token Management Improvements

**Problem**: Auth token might not be current when making requests.

**Fix Applied**:
- Added `setAuthToken()` method to `UploadService` to update token on the underlying `ApiService`
- Updated `UploadProvider.uploadFile()` to refresh token before upload
- Token refresh callback already handles automatic token refresh on 401 errors

**Files Modified**:
- `lib/data/services/upload_service.dart`
- `lib/providers/upload_provider.dart`

## Technical Details

### Response Format Handling

The backend returns responses in this format:
```json
{
  "success": true,
  "data": { ... }
}
```

The `ApiService._handleResponse()` method:
1. Checks for `success: false` and throws `ApiError` if found
2. Extracts the `data` field from successful responses
3. Returns the `data` object directly

So when services receive the response, they get the `data` object, not the full response with `success` and `data` fields.

### File Upload Response

**Backend Response**:
```json
{
  "success": true,
  "data": {
    "id": "stmt_123456",
    "fileName": "bank_statement.pdf",
    "uploadDate": "2024-11-22T14:00:00Z",
    "status": "processing",
    ...
  }
}
```

**After ApiService Extraction**:
```json
{
  "id": "stmt_123456",
  "fileName": "bank_statement.pdf",
  "uploadDate": "2024-11-22T14:00:00Z",
  "status": "processing",
  ...
}
```

### Edit Profile Response

**Backend Response**:
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "user_123",
      "email": "user@example.com",
      "username": "johndoe",
      ...
    }
  }
}
```

**After ApiService Extraction**:
```json
{
  "user": {
    "id": "user_123",
    "email": "user@example.com",
    "username": "johndoe",
    ...
  }
}
```

## Testing Checklist

### File Upload
- [ ] Select a file (PDF, Excel, CSV)
- [ ] Upload should show progress (0-90%)
- [ ] After upload, should show "processing" status (90%)
- [ ] Should poll for status until "processed"
- [ ] Should show success message
- [ ] Statement should appear in the list
- [ ] Transactions should load after processing

### Edit Profile
- [ ] Open profile screen
- [ ] Click "Edit Profile" button
- [ ] Update username, first name, or last name
- [ ] Click "Save"
- [ ] Should show success message
- [ ] Profile should update in the UI
- [ ] Changes should persist after app restart

### Error Handling
- [ ] Test with invalid file (too large, wrong type)
- [ ] Test with network error
- [ ] Test with expired token (should auto-refresh)
- [ ] Test with invalid credentials for profile update
- [ ] Error messages should be user-friendly

## Code Changes Summary

### `lib/data/services/upload_service.dart`
1. Fixed response parsing in `uploadStatement()` - now parses response directly
2. Added `setAuthToken()` method to update token on ApiService
3. Added better error handling with fallback parsing

### `lib/data/services/auth_service.dart`
1. Fixed response parsing in `updateProfile()` - now parses `json['user']` directly
2. Fixed response parsing in `getCurrentUser()` - now parses `json['user']` directly
3. Added fallback parsing for backward compatibility

### `lib/providers/upload_provider.dart`
1. Updated to pass `Ref` to `UploadNotifier` for accessing auth state
2. Added token update before upload to ensure token is current
3. Token refresh callback already handles automatic token refresh

### `lib/data/services/api_service.dart`
1. Added comment clarifying that Content-Type should not be set manually for multipart requests
2. The http package automatically sets Content-Type with boundary

## Next Steps

1. Test file upload with a real backend
2. Test edit profile with a real backend
3. Monitor error logs for any remaining issues
4. Verify token refresh works correctly
5. Test with different file types and sizes

## Notes

- All changes maintain backward compatibility
- Error messages are more descriptive for debugging
- Token management is more robust
- Response parsing now correctly handles the backend's response format
