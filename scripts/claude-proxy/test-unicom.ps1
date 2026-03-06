# 测试联通元景API直接调用

$body = @{
    model = "glm-5"
    max_tokens = 100
    messages = @(
        @{
            role = "user"
            content = "Hello, how are you?"
        }
    )
} | ConvertTo-Json -Depth 3

Write-Host "Testing Unicom API directly..." -ForegroundColor Yellow
Write-Host "URL: https://maas-api.ai-yuanjing.com/openapi/compatible-mode/v1/chat/completions" -ForegroundColor Cyan
Write-Host "Body: $body" -ForegroundColor Gray
Write-Host ""

try {
    $response = Invoke-RestMethod -Uri "https://maas-api.ai-yuanjing.com/openapi/compatible-mode/v1/chat/completions" -Method Post -Body $body -ContentType "application/json" -Headers @{"Authorization" = "Bearer sk-33b2451706fb4098850b14a9dfbb5827"}
    Write-Host "Response:" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 5
} catch {
    Write-Host "Error:" -ForegroundColor Red
    Write-Host $_.Exception.Message
    Write-Host $_.Exception.Response.StatusCode
}
