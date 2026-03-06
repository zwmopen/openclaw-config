# OpenClaw Gateway 安全重启脚本
# 功能：清理所有进程 + 检查端口 + 启动新进程 + 日志记录

param(
    [switch]$Force = $false
)

$env:OPENCLAW_STATE_DIR = Join-Path $PSScriptRoot "..\.openclaw"
$env:OPENCLAW_CONFIG_PATH = Join-Path $env:OPENCLAW_STATE_DIR "openclaw.json"
$logDir = Join-Path $env:OPENCLAW_STATE_DIR "logs"
$logFile = Join-Path $logDir "restart-$(Get-Date -Format 'yyyy-MM-dd-HH-mm-ss').log"

# 创建日志目录
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

function Write-Log {
    param([string]$message, [string]$color = "White")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] $message"
    Write-Host $logMessage -ForegroundColor $color
    Add-Content -Path $logFile -Value $logMessage
}

Write-Log "========================================" "Cyan"
Write-Log "OpenClaw Gateway 安全重启脚本" "Cyan"
Write-Log "========================================" "Cyan"
Write-Log ""

# 1. 检查当前状态
Write-Log "1️⃣ 检查当前状态..." "Yellow"

$port18789 = Get-NetTCPConnection -LocalPort 18789 -ErrorAction SilentlyContinue
$allNodeProcesses = Get-Process -Name node -ErrorAction SilentlyContinue

if ($port18789) {
    $process = Get-Process -Id $port18789.OwningProcess -ErrorAction SilentlyContinue
    Write-Log "端口 18789 被占用 (PID: $($port18789.OwningProcess), 进程: $($process.ProcessName))" "Green"
} else {
    Write-Log "端口 18789 空闲" "DarkGray"
}

Write-Log "找到 $($allNodeProcesses.Count) 个 Node 进程" "Gray"

# 2. 停止所有 Gateway 进程
Write-Log ""
Write-Log "2️⃣ 停止所有 Gateway 进程..." "Yellow"

$gatewayProcesses = $allNodeProcesses | Where-Object { 
    $_.CommandLine -like '*openclaw*' -and $_.CommandLine -like '*gateway*' 
}

if ($gatewayProcesses) {
    Write-Log "找到 $($gatewayProcesses.Count) 个 Gateway 进程" "Gray"
    
    $gatewayProcesses | ForEach-Object {
        $pid = $_.Id
        $mem = [math]::Round($_.WorkingSet64 / 1MB, 1)
        
        try {
            Stop-Process -Id $pid -Force -ErrorAction Stop
            Write-Log "✅ 已停止 PID $pid (内存: ${mem}MB)" "Green"
        } catch {
            Write-Log "❌ 无法停止 PID $pid: $($_.Exception.Message)" "Red"
        }
    }
    
    Start-Sleep -Seconds 2
} else {
    Write-Log "没有找到 Gateway 进程" "DarkGray"
}

# 3. 再次检查端口
Write-Log ""
Write-Log "3️⃣ 再次检查端口..." "Yellow"

$port18789Again = Get-NetTCPConnection -LocalPort 18789 -ErrorAction SilentlyContinue
if ($port18789Again) {
    Write-Log "⚠️ 端口 18789 仍被占用！" "Yellow"
    $forceKill = Get-Process -Id $port18789Again.OwningProcess -ErrorAction SilentlyContinue
    if ($forceKill) {
        try {
            Stop-Process -Id $forceKill.Id -Force -ErrorAction Stop
            Write-Log "✅ 强制停止进程 $($forceKill.Id)" "Green"
            Start-Sleep -Seconds 2
        } catch {
            Write-Log "❌ 无法强制停止: $($_.Exception.Message)" "Red"
        }
    }
} else {
    Write-Log "✅ 端口 18789 已释放" "Green"
}

# 4. 启动新的 Gateway
Write-Log ""
Write-Log "4️⃣ 启动新的 Gateway..." "Yellow"

$nodeExe = "C:\Users\z\.trae-cn\binaries\node\versions\22.18.0\node.exe"
$openclawMjs = "C:\Users\z\.trae-cn\binaries\node\versions\22.18.0\node_modules\openclaw\openclaw.mjs"

if (Test-Path $nodeExe) {
    try {
        $process = Start-Process -FilePath $nodeExe -ArgumentList $openclawMjs, "gateway" -WindowStyle Hidden -PassThru -ErrorAction Stop
        Write-Log "✅ Gateway 已启动 (PID: $($process.Id))" "Green"
        Write-Log "端口: 18789" "Gray"
    } catch {
        Write-Log "❌ 启动失败: $($_.Exception.Message)" "Red"
    }
} else {
    Write-Log "❌ Node.exe 不存在: $nodeExe" "Red"
}

# 5. 验证启动
Write-Log ""
Write-Log "5️⃣ 验证启动..." "Yellow"

Start-Sleep -Seconds 3

$port18789Final = Get-NetTCPConnection -LocalPort 18789 -ErrorAction SilentlyContinue
if ($port18789Final) {
    $process = Get-Process -Id $port18789Final.OwningProcess -ErrorAction SilentlyContinue
    Write-Log "✅ Gateway 运行正常 (PID: $($port18789Final.OwningProcess))" "Green"
} else {
    Write-Log "❌ Gateway 启动失败，端口 18789 未监听" "Red"
}

Write-Log ""
Write-Log "========================================" "Cyan"
Write-Log "重启完成！日志已保存到：" "Cyan"
Write-Log $logFile "Gray"
Write-Log "========================================" "Cyan"
