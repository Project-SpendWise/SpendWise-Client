# Backend Data Format Requirements

This document specifies the exact data format the backend must return for the frontend to display data correctly.

## Response Format

All API responses must follow this format:
```json
{
  "success": true,
  "data": { ... }
}
```

The `ApiService` automatically extracts the `data` field, so services receive only the `data` object.

## Transaction Endpoint: `GET /transactions`

### Request
- Query params: `statementId` (optional), `startDate`, `endDate`, `category`, `account`, `limit`, `offset`

### Response Format
```json
{
  "success": true,
  "data": {
    "transactions": [
      {
        "id": "string",
        "date": "2024-01-15T10:30:00Z",  // ISO 8601 format
        "description": "string",
        "amount": 123.45,  // number
        "type": "income" | "expense",  // REQUIRED: must be "income" or "expense"
        "category": "Gıda" | "Ulaşım" | "Alışveriş" | "Faturalar" | "Eğlence" | "Sağlık" | "Eğitim" | "Diğer" | null,  // REQUIRED for expenses
        "account": "string" | null
      }
    ],
    "total": 100,  // total number of transactions
    "limit": 50,
    "offset": 0
  }
}
```

### Critical Requirements

1. **`type` field is REQUIRED** and must be exactly `"income"` or `"expense"` (lowercase)
2. **`category` field is REQUIRED for expense transactions** - cannot be null for expenses
3. **`date` must be valid ISO 8601 format** - frontend will crash if invalid
4. **`amount` must be a number** (integer or float)

### Example Valid Transaction
```json
{
  "id": "txn_123",
  "date": "2024-01-15T10:30:00Z",
  "description": "Grocery shopping",
  "amount": 150.75,
  "type": "expense",
  "category": "Gıda",
  "account": "Main Account"
}
```

### Why Data Might Not Show

If transactions are loaded but categories/widgets are empty, check:

1. **Are transactions marked as `type: "expense"`?** - Only expenses are counted in categories
2. **Do expense transactions have a `category` field?** - Categories are calculated from expense transactions with categories
3. **Are category names matching?** - Frontend supports any category name, but default categories are: "Gıda", "Ulaşım", "Alışveriş", "Faturalar", "Eğitim", "Eğlence", "Sağlık", "Diğer"
4. **Is `amount` > 0?** - Zero amounts are filtered out

## Transaction Summary Endpoint: `GET /transactions/summary`

### Response Format
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

## Analytics Endpoints

All analytics endpoints support `statementId` query parameter to filter by statement.

### Category Breakdown: `GET /analytics/categories`

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
    }
  ]
}
```

### Monthly Trends: `GET /analytics/monthly-trends`

```json
{
  "success": true,
  "data": [
    {
      "month": "2024-01-01T00:00:00Z",
      "income": 5000.00,
      "expenses": 3000.00,
      "savings": 2000.00
    }
  ]
}
```

## Testing Checklist

To verify backend is returning data correctly:

1. **Check console logs** - Frontend logs:
   - `"Loading transactions for statementId: ..."`
   - `"Loaded X transactions"`
   - `"Transactions with categories: X"`

2. **Verify transaction format**:
   - ✅ `type` is "income" or "expense"
   - ✅ Expense transactions have `category`
   - ✅ `date` is valid ISO 8601
   - ✅ `amount` is a number > 0

3. **Test with empty data**:
   - Backend should return `{ "success": true, "data": { "transactions": [] } }`
   - Frontend will show empty states (no red box errors)

## Common Issues

### Issue: Transactions load but categories are empty
**Cause**: Transactions don't have `type: "expense"` or `category` field is null
**Solution**: Ensure all expense transactions have a `category` field

### Issue: Red box error in charts
**Cause**: `horizontalInterval` is zero (fixed in frontend, but backend should return valid data)
**Solution**: Backend should return transactions with valid amounts > 0

### Issue: "No data" messages everywhere
**Cause**: Backend returns empty transactions array or transactions without categories
**Solution**: 
1. Verify file was processed successfully (`status: "processed"`)
2. Verify transactions were created for that statement
3. Verify transactions have `type` and `category` fields
