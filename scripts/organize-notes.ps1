# 笔记梳理脚本
# 扫描未梳理的笔记并创建梳理版本

$vaultPath = "D:\Program Files\Obsidian\zwm\zwm"
$progressFile = "D:\AI编程\openclaw\scripts\organize-progress.json"
$skipDirs = @(".obsidian", ".trae", ".git", ".qoder", "node_modules")
$skipFiles = @("AGENTS.md", "SOUL.md", "USER.md", "IDENTITY.md", "TOOLS.md", "HEARTBEAT.md", "BOOTSTRAP.md", "MEMORY.md", "KNOWLEDGE.md")

# 初始化进度
if (!(Test-Path $progressFile)) {
    $progress = @{
        startTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        processed = 0
        total = 0
        lastReport = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        files = @()
    }
    $progress | ConvertTo-Json | Out-File $progressFile
}

# 扫描未梳理的文件
$allFiles = Get-ChildItem $vaultPath -Recurse -Filter "*.md" -ErrorAction SilentlyContinue | 
    Where-Object { 
        $dir = $_.DirectoryName.Replace($vaultPath, "")
        $name = $_.Name
        $dir -notmatch "\.obsidian|\.trae|\.git|\.qoder|node_modules" -and
        $name -notmatch "已梳理" -and
        $name -notin $skipFiles
    }

$progress = Get-Content $progressFile | ConvertFrom-Json
$progress.total = $allFiles.Count

Write-Host "发现 $($allFiles.Count) 条未梳理笔记"
Write-Host "开始梳理..."

$progress | ConvertTo-Json | Out-File $progressFile
