# 测试Claude代理服务器

$body = @{
    model = "claude-3-5-sonnet-20241022"
    max_tokens = 100
    messages = @(
        @{
            role = "user"
            content = "Hello, how are you?"
        }
    )
} | ConvertTo-Json -Depth 3

Write-Host "Testing Claude Proxy Server..." -ForegroundColor Yellow
Write-Host "URL: http://127.0.0.1:15721/v1/messages" -ForegroundColor Cyan
Write-Host "Body: $body" -ForegroundColor Gray
Write-Host ""

try {
    $response = Invoke-RestMethod -Uri "http://127.0.0.1:15721/v1/messages" -Method Post -Body $body -ContentType "application/json" -Headers @{"x-api-key" = "test"}
    Write-Host "Response:" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 5
} catch {
    Write-Host "Error:" -ForegroundColor Red
    Write-Host $_.Exception.Message
    Write-Host $_.Exception.Response.StatusCode
}
