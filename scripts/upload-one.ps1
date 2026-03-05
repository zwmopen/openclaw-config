param([string]$Token, [string]$File, [string]$Path, [string]$Message)

$content = [Convert]::ToBase64String([IO.File]::ReadAllBytes($File))
$apiUrl = "https://api.github.com/repos/zwmopen/openclaw-config/contents/$Path"

# Get SHA
$sha = $null
try {
    $response = Invoke-RestMethod -Uri $apiUrl -Headers @{Authorization="token $Token"} -ErrorAction SilentlyContinue
    $sha = $response.sha
} catch {}

$body = @{
    message = $Message
    content = $content
    branch = "main"
}
if ($sha) { $body.sha = $sha }

Invoke-RestMethod -Uri $apiUrl -Method PUT -Headers @{Authorization="token $Token"; "Content-Type"="application/json"} -Body ($body | ConvertTo-Json) | Out-Null
Write-Host "OK: $Path"
