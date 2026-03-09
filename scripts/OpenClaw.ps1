# OpenClaw Gateway 智能启动脚本
# 功能：自动判断状态，智能执行启动/重启/检查

param(
    [switch]$ForceRestart = $false,  # 强制重启
    [switch]$NoTimeout = $false      # 不自动关闭
)

$env:OPENCLAW_STATE_DIR = Join-Path $PSScriptRoot "..\.openclaw"
$env:OPENCLAW_CONFIG_PATH = Join-Path $env:OPENCLAW_STATE_DIR "openclaw.json"
$logDir = Join-Path $env:OPENCLAW_STATE_DIR "logs"
$logFile = Join-Path $logDir "gateway-$(Get-Date -Format 'yyyy-MM-dd-HH-mm-ss').log"

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
Write-Host "OpenClaw Gateway 智能启动" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 检查当前状态
$port = Get-NetTCPConnection -LocalPort 18789 -ErrorAction SilentlyContinue

if ($port -and -not $ForceRestart) {
    # Gateway 已在运行
    $process = Get-Process -Id $port.OwningProcess -ErrorAction SilentlyContinue
    $memory = [math]::Round($process.WorkingSet64 / 1MB, 1)
    
    Write-Log "✅ Gateway 已在运行" "Green"
    Write-Host ""
    Write-Host "端口:    18789 (监听中)" -ForegroundColor Green
    Write-Host "PID:     $($port.OwningProcess)" -ForegroundColor Gray
    Write-Host "内存:    ${memory} MB" -ForegroundColor Gray
    
    # 健康检查
    if (Test-Gateway) {
        Write-Host "健康:    正常" -ForegroundColor Green
    } else {
        Write-Host "健康:    异常" -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "Gateway 运行正常！" -ForegroundColor Green
    Write-Host ""
    
    # 询问是否重启
    Write-Host "是否重启 Gateway？(Y/N)" -ForegroundColor Yellow
    $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    
    if ($key.Character -eq 'Y' -or $key.Character -eq 'y') {
        Write-Host ""
        Write-Host "正在重启..." -ForegroundColor Cyan
        $ForceRestart = $true
    } else {
        Write-Host ""
        Write-Host "已取消" -ForegroundColor Gray
        
        if (-not $NoTimeout) {
            Write-Host "窗口将在 11 分钟后自动关闭，或按任意键立即关闭..." -ForegroundColor DarkGray
            $timeout = 660
            $start = Get-Date
            while (((Get-Date) - $start).TotalSeconds -lt $timeout) {
                if ([Console]::KeyAvailable) {
                    [Console]::ReadKey($true) | Out-Null
                    exit 0
                }
                Start-Sleep -Milliseconds 100
            }
        }
        exit 0
    }
}

# 如果需要重启或未运行
if ($ForceRestart -or -not $port) {
    # 停止现有进程
    if ($port) {
        Write-Log "正在停止 Gateway..." "Yellow"
        
        $allNodeProcesses = Get-Process -Name node -ErrorAction SilentlyContinue
        $gatewayProcesses = $allNodeProcesses | Where-Object { 
            $_.CommandLine -like '*openclaw*' -and $_.CommandLine -like '*gateway*' 
        }
        
        if ($gatewayProcesses) {
            $gatewayProcesses | ForEach-Object {
                try {
                    Stop-Process -Id $_.Id -Force -ErrorAction Stop
                    Write-Log "✅ 已停止 PID $($_.Id)" "Green"
                } catch {
                    Write-Log "⚠️ 无法停止 PID $($_.Id)" "Yellow"
                }
            }
            Start-Sleep -Seconds 2
        }
        
        # 再次检查端口
        $portAgain = Get-NetTCPConnection -LocalPort 18789 -ErrorAction SilentlyContinue
        if ($portAgain) {
            $forceKill = Get-Process -Id $portAgain.OwningProcess -ErrorAction SilentlyContinue
            if ($forceKill) {
                try {
                    Stop-Process -Id $forceKill.Id -Force -ErrorAction Stop
                    Write-Log "✅ 已强制停止进程 $($forceKill.Id)" "Green"
                    Start-Sleep -Seconds 2
                } catch {
                    Write-Log "❌ 无法强制停止: $($_.Exception.Message)" "Red"
                }
            }
        }
    }
    
    # 启动新进程
    Write-Host ""
    Write-Log "正在启动 Gateway..." "Yellow"
    
    $nodeExe = "C:\Users\z\.trae-cn\binaries\node\versions\22.18.0\node.exe"
    $openclawMjs = "C:\Users\z\.trae-cn\binaries\node\versions\22.18.0\node_modules\openclaw\openclaw.mjs"
    
    if (-not (Test-Path $nodeExe)) {
        Write-Log "❌ Node.exe 不存在" "Red"
        Write-Host ""
        Write-Host "按任意键关闭..." -ForegroundColor DarkGray
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        exit 1
    }
    
    if (-not (Test-Path $openclawMjs)) {
        Write-Log "❌ OpenClaw 不存在" "Red"
        Write-Host ""
        Write-Host "按任意键关闭..." -ForegroundColor DarkGray
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        exit 1
    }
    
    try {
        $process = Start-Process -FilePath $nodeExe -ArgumentList $openclawMjs, "gateway" -WindowStyle Hidden -PassThru -ErrorAction Stop
        Write-Log "✅ Gateway 进程已启动 (PID: $($process.Id))" "Green"
    } catch {
        Write-Log "❌ 启动失败: $($_.Exception.Message)" "Red"
        Write-Host ""
        Write-Host "按任意键关闭..." -ForegroundColor DarkGray
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        exit 1
    }
    
    # 等待启动
    Write-Host ""
    Write-Log "等待启动..." "Yellow"
    
    $maxWait = 30
    $waited = 0
    $success = $false
    
    while ($waited -lt $maxWait) {
        Start-Sleep -Seconds 1
        $waited++
        
        $portNew = Get-NetTCPConnection -LocalPort 18789 -ErrorAction SilentlyContinue
        if ($portNew) {
            $success = $true
            break
        }
        
        Write-Host "." -NoNewline -ForegroundColor Gray
    }
    
    Write-Host ""
    
    if ($success) {
        Write-Log "✅ Gateway 启动成功！(耗时: ${waited}秒)" "Green"
        
        # 健康检查
        Start-Sleep -Seconds 2
        if (Test-Gateway) {
            Write-Log "✅ 健康检查通过" "Green"
        } else {
            Write-Log "⚠️ 健康检查失败" "Yellow"
        }
    } else {
        Write-Log "❌ Gateway 启动失败" "Red"
    }
}

# 最终状态
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "当前状态" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$portFinal = Get-NetTCPConnection -LocalPort 18789 -ErrorAction SilentlyContinue
if ($portFinal) {
    $process = Get-Process -Id $portFinal.OwningProcess -ErrorAction SilentlyContinue
    $memory = [math]::Round($process.WorkingSet64 / 1MB, 1)
    
    Write-Host "端口:    18789 (监听中)" -ForegroundColor Green
    Write-Host "PID:     $($portFinal.OwningProcess)" -ForegroundColor Gray
    Write-Host "内存:    ${memory} MB" -ForegroundColor Gray
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

# 窗口停留
if (-not $NoTimeout) {
    Write-Host "窗口将在 11 分钟后自动关闭，或按任意键立即关闭..." -ForegroundColor DarkGray
    $timeout = 660
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
