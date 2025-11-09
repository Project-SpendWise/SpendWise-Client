# Backend Download Endpoint Requirements for Mobile Apps

## Issue
Mobile apps (Flutter/React Native) require specific handling for file downloads to work properly. The "Connection closed while receiving data" error typically occurs when:

1. The server closes the connection before all data is sent
2. The response doesn't have proper headers for streaming
3. The server doesn't support chunked transfer encoding
4. Content-Length header is missing or incorrect

## Required Backend Implementation

### 1. HTTP Headers

The download endpoint **MUST** return these headers:

```
Content-Type: <file_mime_type>
Content-Length: <file_size_in_bytes>
Content-Disposition: attachment; filename="original_filename.ext"
Accept-Ranges: bytes
```

**Important:**
- `Content-Length` is **critical** - mobile clients need this to know how much data to expect
- `Content-Disposition` helps the client know the original filename
- `Accept-Ranges` enables range requests (optional but recommended)
- **DO NOT send `Connection: close`** - This will cause the connection to close prematurely
  - Use `Connection: keep-alive` or omit the header entirely (defaults to keep-alive)
  - **CRITICAL:** If you see both `Connection: keep-alive` and `Connection: close` in headers, remove the `close` one

### 2. Response Format

**DO NOT wrap the file in JSON.** Return the raw binary file data directly.

**❌ WRONG:**
```json
{
  "success": true,
  "data": {
    "file": "base64_encoded_data_here"
  }
}
```

**✅ CORRECT:**
Return the file bytes directly as the response body with proper Content-Type header.

### 3. Streaming Support

For large files (>1MB), the backend should:
- Support HTTP streaming (chunked transfer encoding)
- Not buffer the entire file in memory
- Send data in chunks as it reads from disk

### 4. Connection Management

- **Keep the connection open** until all data is sent
- **Don't close the connection prematurely**
- Set appropriate **timeout values** (at least 60 seconds for large files)
- Handle **keep-alive** properly

### 5. Example Backend Implementation

#### Node.js/Express Example:
```javascript
app.get('/api/files/:fileId/download', authenticateToken, async (req, res) => {
  try {
    const fileId = req.params.fileId;
    const file = await getFileFromDatabase(fileId);
    
    // Verify ownership
    if (file.user_id !== req.user.id) {
      return res.status(403).json({ error: { message: 'Forbidden', statusCode: 403 } });
    }
    
    const filePath = path.join(uploadsDir, file.file_path, file.stored_filename);
    
    // Check if file exists
    if (!fs.existsSync(filePath)) {
      return res.status(404).json({ error: { message: 'File not found', statusCode: 404 } });
    }
    
    const stats = fs.statSync(filePath);
    const fileSize = stats.size;
    
    // CRITICAL: Set headers BEFORE sending file
    // DO NOT use res.json() or any JSON response for success
    res.setHeader('Content-Type', file.mime_type);
    res.setHeader('Content-Length', fileSize.toString()); // MUST be string
    res.setHeader('Content-Disposition', `attachment; filename="${file.original_filename}"`);
    res.setHeader('Accept-Ranges', 'bytes');
    res.setHeader('Cache-Control', 'no-cache');
    
    // IMPORTANT: Don't use chunked encoding for downloads
    // Remove Transfer-Encoding header if present
    res.removeHeader('Transfer-Encoding');
    
    // Stream the file
    const fileStream = fs.createReadStream(filePath);
    
    // Handle stream errors
    fileStream.on('error', (err) => {
      if (!res.headersSent) {
        res.status(500).json({ error: { message: 'Error reading file', statusCode: 500 } });
      } else {
        // Headers already sent, can't send JSON error
        res.end();
      }
    });
    
    // Pipe file to response
    fileStream.pipe(res);
    
    // Ensure connection stays open
    fileStream.on('end', () => {
      // File stream ended, response should close automatically
    });
    
  } catch (error) {
    if (!res.headersSent) {
      res.status(500).json({ error: { message: error.message, statusCode: 500 } });
    }
  }
});
```

#### Python/FastAPI Example:
```python
from fastapi import Response, HTTPException
from fastapi.responses import FileResponse
import os
import aiofiles

@app.get("/api/files/{file_id}/download")
async def download_file(file_id: str, current_user: User = Depends(get_current_user)):
    file = await get_file_from_db(file_id)
    
    # Verify ownership
    if file.user_id != current_user.id:
        raise HTTPException(status_code=403, detail="Forbidden")
    
    file_path = os.path.join(uploads_dir, file.file_path, file.stored_filename)
    
    if not os.path.exists(file_path):
        raise HTTPException(status_code=404, detail="File not found")
    
    # Get file size
    file_size = os.path.getsize(file_path)
    
    # Use FileResponse which handles streaming automatically
    response = FileResponse(
        path=file_path,
        media_type=file.mime_type,
        filename=file.original_filename,
        headers={
            "Content-Disposition": f'attachment; filename="{file.original_filename}"',
            "Accept-Ranges": "bytes",
            "Connection": "keep-alive",  # CRITICAL: Ensure keep-alive
            # FastAPI FileResponse should set Content-Length automatically
        }
    )
    return response
```

#### Alternative: Manual Streaming (if FileResponse doesn't work):
```python
from fastapi import Response
from fastapi.responses import StreamingResponse
import aiofiles

@app.get("/api/files/{file_id}/download")
async def download_file(file_id: str, current_user: User = Depends(get_current_user)):
    file = await get_file_from_db(file_id)
    
    if file.user_id != current_user.id:
        raise HTTPException(status_code=403, detail="Forbidden")
    
    file_path = os.path.join(uploads_dir, file.file_path, file.stored_filename)
    
    if not os.path.exists(file_path):
        raise HTTPException(status_code=404, detail="File not found")
    
    file_size = os.path.getsize(file_path)
    
    async def generate():
        async with aiofiles.open(file_path, 'rb') as f:
            while True:
                chunk = await f.read(8192)  # 8KB chunks
                if not chunk:
                    break
                yield chunk
    
    return StreamingResponse(
        generate(),
        media_type=file.mime_type,
        headers={
            "Content-Length": str(file_size),
            "Content-Disposition": f'attachment; filename="{file.original_filename}"',
            "Accept-Ranges": "bytes",
            "Connection": "keep-alive",  # CRITICAL: Ensure keep-alive
        }
    )
```

### 6. Testing with cURL

Test your endpoint with:
```bash
curl -X GET http://localhost:5000/api/files/<file_id>/download \
  -H "Authorization: Bearer <token>" \
  -v \
  -o test_file.pdf
```

Check the response headers:
- Look for `Content-Length: <number>`
- Look for `Content-Type: application/pdf` (or appropriate type)
- Look for `Content-Disposition: attachment; filename="..."`

### 7. Common Issues and Fixes

#### Issue: Connection closes prematurely
**Fix:** Ensure `Content-Length` header is set correctly and matches actual file size

#### Issue: Timeout errors
**Fix:** Increase server timeout settings for download endpoints

#### Issue: Memory issues with large files
**Fix:** Use streaming instead of loading entire file into memory

#### Issue: CORS issues (if applicable)
**Fix:** Add proper CORS headers:
```
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: GET
Access-Control-Allow-Headers: Authorization, Content-Type
```

### 8. Recommended Backend Settings

- **Timeout:** At least 60 seconds for file downloads
- **Max file size:** 10MB (as per your API docs)
- **Buffer size:** 64KB chunks for streaming
- **Connection:** Keep-alive enabled
- **Compression:** Disable for binary files (PDF, images, etc.)

### 9. Mobile-Specific Considerations

1. **Network interruptions:** Mobile networks can be unstable
   - Consider implementing resume capability (Range requests)
   - Handle partial downloads gracefully

2. **Background downloads:** For large files, consider background download support

3. **Progress tracking:** If possible, support Range requests for progress tracking:
   ```
   Range: bytes=0-1023
   ```

### 10. Troubleshooting "Connection Closed" Error

If you're still getting "Connection closed while receiving data" errors:

#### Check 1: Verify Headers with cURL
```bash
curl -v -X GET http://localhost:5000/api/files/<file_id>/download \
  -H "Authorization: Bearer <token>" \
  --output test_file.pdf
```

Look for these in the verbose output:
- `Content-Length: <number>` - MUST be present
- `Transfer-Encoding: chunked` - Should NOT be present (or Content-Length should override it)
- Connection should stay open until file is complete

#### Check 2: Common Backend Issues

**Issue: Connection header conflict (CRITICAL)**
```python
# ❌ WRONG - Sending both keep-alive and close
response.headers['Connection'] = 'keep-alive'
response.headers['Connection'] = 'close'  # This overwrites but some frameworks add both!

# ✅ CORRECT - Only use keep-alive or omit entirely
response.headers['Connection'] = 'keep-alive'
# OR simply don't set it (defaults to keep-alive in most frameworks)
```

**Python/Flask specific:**
```python
# ❌ WRONG - Flask might add Connection: close automatically
return send_file(file_path, as_attachment=True)

# ✅ CORRECT - Explicitly set keep-alive
response = send_file(file_path, as_attachment=True)
response.headers['Connection'] = 'keep-alive'
return response
```

**Issue: Content-Length not set**
```javascript
// ❌ WRONG - Missing Content-Length
res.setHeader('Content-Type', file.mime_type);
fs.createReadStream(filePath).pipe(res);

// ✅ CORRECT - Set Content-Length
const stats = fs.statSync(filePath);
res.setHeader('Content-Length', stats.size.toString());
res.setHeader('Content-Type', file.mime_type);
fs.createReadStream(filePath).pipe(res);
```

**Issue: Chunked encoding interfering**
```javascript
// ❌ WRONG - Express might add chunked encoding
res.setHeader('Content-Type', file.mime_type);
res.setHeader('Content-Length', fileSize);
// Missing: res.removeHeader('Transfer-Encoding');

// ✅ CORRECT - Explicitly remove chunked encoding
res.setHeader('Content-Type', file.mime_type);
res.setHeader('Content-Length', fileSize.toString());
res.removeHeader('Transfer-Encoding'); // Important!
fs.createReadStream(filePath).pipe(res);
```

**Issue: Response being closed prematurely**
```javascript
// ❌ WRONG - Don't call res.end() manually
fileStream.pipe(res);
res.end(); // This closes connection too early!

// ✅ CORRECT - Let pipe handle it
fileStream.pipe(res);
// Don't call res.end() - pipe() handles it
```

#### Check 3: Server Timeout Settings

Ensure your server has appropriate timeouts:
- **Node.js/Express:** Default timeout is usually 2 minutes, which should be enough
- **Python/FastAPI:** Check uvicorn/gunicorn timeout settings
- **Nginx (if used):** Check `proxy_read_timeout` and `proxy_send_timeout`

#### Check 4: Network/Proxy Issues

If behind a proxy or load balancer:
- Check proxy timeout settings
- Ensure proxy doesn't buffer the response
- Verify proxy passes through `Content-Length` header

### 11. Verification Checklist

Before deploying, verify:
- [ ] `Content-Length` header is present and correct
- [ ] `Content-Type` matches the file type
- [ ] `Content-Disposition` includes filename
- [ ] File is returned as binary, not JSON-wrapped
- [ ] Connection stays open until file is fully sent
- [ ] **`Connection: keep-alive` is set (or header is omitted)**
- [ ] **`Connection: close` is NOT present**
- [ ] Works with files up to 10MB
- [ ] Proper error responses (404, 403) are JSON format
- [ ] Success responses (200) are binary file data
- [ ] `Transfer-Encoding: chunked` is NOT present (or Content-Length overrides it)
- [ ] Server timeout is at least 60 seconds

## Quick Test

Use this to verify your endpoint works:

```bash
# Should return binary data
curl -X GET http://localhost:5000/api/files/<file_id>/download \
  -H "Authorization: Bearer <token>" \
  -v 2>&1 | grep -i "content-type\|content-length\|content-disposition"
```

Expected output should show:
- `Content-Type: application/pdf` (or appropriate)
- `Content-Length: <number>`
- `Content-Disposition: attachment; filename="..."`

