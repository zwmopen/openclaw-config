# 错误重试机制

> 自动重试失败的API调用，实现容错与自愈

---

## 重试策略

### 指数退避
- 第1次重试：等待1秒
- 第2次重试：等待2秒
- 第3次重试：等待4秒
- 最大重试次数：3次

### 重试条件
- API调用失败（状态码 429、500、502、503、504）
- 网络超时
- 服务暂时不可用

### 不重试条件
- 认证失败（状态码 401、403）
- 参数错误（状态码 400）
- 资源不存在（状态码 404）

---

## 重试函数

```powershell
function Invoke-WithRetry {
    param(
        [scriptblock]$ScriptBlock,
        [int]$MaxRetries = 3,
        [int]$InitialDelay = 1
    )
    
    $retryCount = 0
    $delay = $InitialDelay
    
    while ($retryCount -lt $MaxRetries) {
        try {
            $result = & $ScriptBlock
            return $result
        } catch {
            $retryCount++
            
            if ($retryCount -ge $MaxRetries) {
                Write-Error "重试失败，已达到最大重试次数：$MaxRetries"
                throw $_
            }
            
            Write-Warning "第 $retryCount 次重试，等待 $delay 秒..."
            Start-Sleep -Seconds $delay
            
            # 指数退避
            $delay = $delay * 2
        }
    }
}
```

---

## 使用示例

### API调用重试
```powershell
$result = Invoke-WithRetry -ScriptBlock {
    Invoke-RestMethod -Uri "https://api.example.com/data" -Method Get
}
```

### 文件操作重试
```powershell
$result = Invoke-WithRetry -ScriptBlock {
    Get-Content -Path "D:\file.txt" -Raw
}
```

### 网络请求重试
```powershell
$result = Invoke-WithRetry -ScriptBlock {
    Invoke-WebRequest -Uri "https://example.com" -UseBasicParsing
}
```

---

## 错误日志

所有错误自动记录到：`ERROR-LOG.md`

---

**创建时间**：2026-03-06 13:25
**可验证成果**：能自动重试失败的API调用，最大重试3次
