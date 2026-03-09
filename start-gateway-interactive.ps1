# OpenClaw Gateway 交互式启动脚本
# 功能：启动 + 检查状态 + 显示窗口（11分钟后自动关闭）

param(
    [switch]$NoTimeout = $false  # 加上此参数则窗口不会自动关闭
)

$env:OPENCLAW_STATE_DIR = Join-Path $PSScriptRoot "..\.openclaw"
$env:OPENCLAW_CONFIG_PATH = Join-Path $env:OPENCLAW_STATE_DIR "openclaw.json"
$logDir = Join-Path $env:OPENCLAW_STATE_DIR "logs"
$logFile = Join-Path $logDir "startup-$(Get-Date -Format 'yyyy-MM-dd-HH-mm-ss').log"

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

function Test-Gateway {
    try {
        $response = Invoke-WebRequest -Uri "http://127.0.0.1:18789/health" -TimeoutSec 2 -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "OpenClaw Gateway 启动脚本" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 1. 检查当前状态
Write-Log "1️⃣ 检查当前状态..." "Yellow"

$port18789 = Get-NetTCPConnection -LocalPort 18789 -ErrorAction SilentlyContinue
if ($port18789) {
    $process = Get-Process -Id $port18789.OwningProcess -ErrorAction SilentlyContinue
    Write-Log "✅ Gateway 已在运行 (PID: $($port18789.OwningProcess))" "Green"
    Write-Log "端口: 18789" "Gray"
    
    # 检查健康状态
    if (Test-Gateway) {
        Write-Log "健康状态: 正常" "Green"
    } else {
        Write-Log "健康状态: 异常（端口开放但健康检查失败）" "Yellow"
    }
    
    Write-Host ""
    Write-Host "Gateway 已在运行，无需重启。" -ForegroundColor Green
    Write-Host ""
    
    if (-not $NoTimeout) {
        Write-Host "窗口将在 11 分钟后自动关闭，或按任意键立即关闭..." -ForegroundColor DarkGray
        $timeout = 660  # 11分钟 = 660秒
        $start = Get-Date
        while (((Get-Date) - $start).TotalSeconds -lt $timeout) {
            if ([Console]::KeyAvailable) {
                [Console]::ReadKey($true) | Out-Null
                Write-Host ""
                Write-Host "窗口已关闭。" -ForegroundColor Gray
                exit 0
            }
            Start-Sleep -Milliseconds 100
        }
    } else {
        Write-Host "按任意键关闭窗口..." -ForegroundColor DarkGray
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
    exit 0
} else {
    Write-Log "端口 18789 空闲，准备启动..." "Gray"
}

# 2. 停止可能存在的僵尸进程
Write-Host ""
Write-Log "2️⃣ 清理僵尸进程..." "Yellow"

$nodeProcesses = Get-Process -Name node -ErrorAction SilentlyContinue | Where-Object {
    $_.CommandLine -like '*openclaw*' -and $_.CommandLine -like '*gateway*'
}

if ($nodeProcesses) {
    Write-Log "找到 $($nodeProcesses.Count) 个僵尸进程" "Gray"
    $nodeProcesses | ForEach-Object {
        try {
            Stop-Process -Id $_.Id -Force -ErrorAction Stop
            Write-Log "✅ 已停止 PID $($_.Id)" "Green"
        } catch {
            Write-Log "⚠️ 无法停止 PID $($_.Id)" "Yellow"
        }
    }
    Start-Sleep -Seconds 2
} else {
    Write-Log "没有僵尸进程" "Gray"
}

# 3. 启动 Gateway
Write-Host ""
Write-Log "3️⃣ 启动 Gateway..." "Yellow"

$nodeExe = "C:\Users\z\.trae-cn\binaries\node\versions\22.18.0\node.exe"
$openclawMjs = "C:\Users\z\.trae-cn\binaries\node\versions\22.18.0\node_modules\openclaw\openclaw.mjs"

if (-not (Test-Path $nodeExe)) {
    Write-Log "❌ Node.exe 不存在: $nodeExe" "Red"
    Write-Host ""
    Write-Host "按任意键关闭..." -ForegroundColor DarkGray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

if (-not (Test-Path $openclawMjs)) {
    Write-Log "❌ OpenClaw 不存在: $openclawMjs" "Red"
    Write-Host ""
    Write-Host "按任意键关闭..." -ForegroundColor DarkGray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

try {
    # 后台启动（不显示窗口）
    $process = Start-Process -FilePath $nodeExe -ArgumentList $openclawMjs, "gateway" -WindowStyle Hidden -PassThru -ErrorAction Stop
    Write-Log "✅ Gateway 进程已启动 (PID: $($process.Id))" "Green"
} catch {
    Write-Log "❌ 启动失败: $($_.Exception.Message)" "Red"
    Write-Host ""
    Write-Host "按任意键关闭..." -ForegroundColor DarkGray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

# 4. 等待启动并验证
Write-Host ""
Write-Log "4️⃣ 等待启动..." "Yellow"

$maxWait = 30  # 最多等待30秒
$waited = 0
$success = $false

while ($waited -lt $maxWait) {
    Start-Sleep -Seconds 1
    $waited++
    
    $port = Get-NetTCPConnection -LocalPort 18789 -ErrorAction SilentlyContinue
    if ($port) {
        $success = $true
        break
    }
    
    Write-Host "." -NoNewline -ForegroundColor Gray
}

Write-Host ""

if ($success) {
    Write-Log "✅ Gateway 启动成功！(耗时: ${waited}秒)" "Green"
    
    # 再次检查健康状态
    Start-Sleep -Seconds 2
    if (Test-Gateway) {
        Write-Log "✅ 健康检查通过" "Green"
    } else {
        Write-Log "⚠️ 健康检查失败（端口开放但服务未就绪）" "Yellow"
    }
} else {
    Write-Log "❌ Gateway 启动失败（等待${maxWait}秒后端口未监听）" "Red"
}

# 5. 最终状态
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "启动完成" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$port = Get-NetTCPConnection -LocalPort 18789 -ErrorAction SilentlyContinue
if ($port) {
    $process = Get-Process -Id $port.OwningProcess -ErrorAction SilentlyContinue
    Write-Host "端口:    18789 (监听中)" -ForegroundColor Green
    Write-Host "PID:     $($port.OwningProcess)" -ForegroundColor Gray
    Write-Host "内存:    $([math]::Round($process.WorkingSet64 / 1MB, 1)) MB" -ForegroundColor Gray
    Write-Host "日志:    $logFile" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Gateway 运行正常！" -ForegroundColor Green
} else {
    Write-Host "端口:    18789 (未监听)" -ForegroundColor Red
    Write-Host "状态:    启动失败" -ForegroundColor Red
    Write-Host ""
    Write-Host "请检查日志: $logFile" -ForegroundColor Yellow
}

Write-Host ""

# 6. 窗口停留
if (-not $NoTimeout) {
    Write-Host "窗口将在 11 分钟后自动关闭，或按任意键立即关闭..." -ForegroundColor DarkGray
    $timeout = 660  # 11分钟 = 660秒
    $start = Get-Date
    while (((Get-Date) - $start).TotalSeconds -lt $timeout) {
        if ([Console]::KeyAvailable) {
            [Console]::ReadKey($true) | Out-Null
            Write-Host ""
            Write-Host "窗口已关闭。" -ForegroundColor Gray
            exit 0
        }
        Start-Sleep -Milliseconds 100
    }
    Write-Host ""
    Write-Host "11 分钟已到，窗口自动关闭。" -ForegroundColor Gray
} else {
    Write-Host "按任意键关闭窗口..." -ForegroundColor DarkGray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
