# OpenClaw Control Panel Server v2.0
param([int]$Port = 38789)

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$htmlFile = Join-Path $scriptPath "openclaw-panel-v2.html"
$baseDir = Split-Path -Parent $scriptPath
$configFile = Join-Path $baseDir ".openclaw\openclaw.json"
$stateFile = Join-Path $scriptPath ".panel-state.json"

function Get-OpenClawProcess {
    return Get-Process -Name "node" -ErrorAction SilentlyContinue | 
           Where-Object { $_.CommandLine -like "*openclaw*" -or $_.CommandLine -like "*gateway*" }
}

function Get-Config {
    if (Test-Path $configFile) {
        $content = Get-Content $configFile -Raw -Encoding UTF8
        $config = $content | ConvertFrom-Json
        return $config
    }
    return @{}
}

function Get-State {
    if (Test-Path $stateFile) {
        return Get-Content $stateFile -Raw -Encoding UTF8 | ConvertFrom-Json
    }
    return @{ startCount = 0; startTime = $null; msgCount = 0; tokenUsed = 0 }
}

function Save-State {
    param($State)
    $State | ConvertTo-Json -Depth 10 | Set-Content $stateFile -Encoding UTF8
}

function Send-Json {
    param($Context, $Data, $Status = 200)
    $json = $Data | ConvertTo-Json -Depth 10
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($json)
    $Context.Response.ContentType = "application/json; charset=utf-8"
    $Context.Response.StatusCode = $Status
    $Context.Response.OutputStream.Write($bytes, 0, $bytes.Length)
    $Context.Response.Close()
}

function Send-Html {
    param($Context, $FilePath)
    if (Test-Path $FilePath) {
        $content = Get-Content $FilePath -Raw -Encoding UTF8
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($content)
        $Context.Response.ContentType = "text/html; charset=utf-8"
        $Context.Response.StatusCode = 200
        $Context.Response.OutputStream.Write($bytes, 0, $bytes.Length)
    } else {
        $Context.Response.StatusCode = 404
    }
    $Context.Response.Close()
}

Write-Host "========================================"
Write-Host "  OpenClaw Panel Server v2.0 Started"
Write-Host "========================================"
Write-Host "URL: http://localhost:$Port"
Write-Host "Press Ctrl+C to stop"

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$Port/")
$listener.Start()

while ($listener.IsListening) {
    try {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response
        $path = $request.Url.AbsolutePath
        
        Write-Host "[$($request.HttpMethod)] $path"
        
        if ($path -eq "/") {
            Send-Html $context $htmlFile
        }
        elseif ($path -eq "/api/status") {
            $config = Get-Config
            $process = Get-OpenClawProcess
            $state = Get-State
            
            $data = @{
                running = ($null -ne $process)
                version = "2026.2.21-2"
                bindMode = $config.gateway.bind
                workspace = $config.agents.defaults.workspace
                startCount = $state.startCount
                startTime = $state.startTime
                currentModel = $config.agents.defaults.model.primary
                msgCount = $state.msgCount
                tokenUsed = $state.tokenUsed
                activeChannels = @(@{name="Feishu"; status="Connected"; enabled=$config.channels.feishu.enabled})
            }
            
            Send-Json $context $data
        }
        elseif ($path -eq "/api/ai/chat") {
            try {
                $body = $request.InputStream
                $body.Position = 0
                $reader = New-Object System.IO.StreamReader($body)
                $jsonBody = $reader.ReadToEnd() | ConvertFrom-Json
                $message = $jsonBody.message
                $model = $jsonBody.model
                
                $responseText = "我是OpenClaw AI助手，收到了你的消息：'$message'"
                
                Send-Json $context @{reply = $responseText}
            } catch {
                Write-Host "AI Chat Error: $_"
                Send-Json $context @{reply = "抱歉，处理你的请求时出现错误。"}
            }
        }
        else {
            $response.StatusCode = 404
            $response.Close()
        }
    } catch {
        Write-Host "Error: $_"
    }
}

$listener.Stop()