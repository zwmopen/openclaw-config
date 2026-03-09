# 重命名脚本 - 按工作流编号

$basePath = "D:\Program Files\Obsidian\zwm\.zwm\02-ZWM 2.0 内容生产系统\01-内容生产"

# 当前文件夹结构（存在编号冲突）：
# 00-口述采集
# 01-深化产出
# 01-选题管理（冲突）
# 02-待发布
# 02-选题研究（冲突）
# 03-内容素材库
# 03-已发布（冲突）
# 04-方法论沉淀
# 05-工具与资源
# 06-数据追踪
# 08-待发送小红书

# 工作流重命名方案：
# 01-素材采集（原00-口述采集）
# 02-内容素材库（原03-内容素材库）
# 03-选题管理（原01-选题管理）
# 04-选题研究（原02-选题研究）
# 05-内容创作（原01-深化产出）
# 06-待发布（原02-待发布，合并08-待发送小红书）
# 07-已发布（原03-已发布）
# 08-数据追踪（原06-数据追踪）
# 09-方法论沉淀（原04-方法论沉淀）
# 10-工具与资源（原05-工具与资源）

Write-Output "开始重命名..."

# 第一步：重命名到临时名称（避免冲突）
Rename-Item -Path "$basePath\00-口述采集" -NewName "temp-01-素材采集" -ErrorAction SilentlyContinue
Rename-Item -Path "$basePath\03-内容素材库" -NewName "temp-02-内容素材库" -ErrorAction SilentlyContinue
Rename-Item -Path "$basePath\01-选题管理" -NewName "temp-03-选题管理" -ErrorAction SilentlyContinue
Rename-Item -Path "$basePath\02-选题研究" -NewName "temp-04-选题研究" -ErrorAction SilentlyContinue
Rename-Item -Path "$basePath\01-深化产出" -NewName "temp-05-内容创作" -ErrorAction SilentlyContinue
Rename-Item -Path "$basePath\02-待发布" -NewName "temp-06-待发布" -ErrorAction SilentlyContinue
Rename-Item -Path "$basePath\03-已发布" -NewName "temp-07-已发布" -ErrorAction SilentlyContinue
Rename-Item -Path "$basePath\06-数据追踪" -NewName "temp-08-数据追踪" -ErrorAction SilentlyContinue
Rename-Item -Path "$basePath\04-方法论沉淀" -NewName "temp-09-方法论沉淀" -ErrorAction SilentlyContinue
Rename-Item -Path "$basePath\05-工具与资源" -NewName "temp-10-工具与资源" -ErrorAction SilentlyContinue

Write-Output "第一步完成：重命名到临时名称"

# 第二步：重命名到最终名称
Rename-Item -Path "$basePath\temp-01-素材采集" -NewName "01-素材采集" -ErrorAction SilentlyContinue
Rename-Item -Path "$basePath\temp-02-内容素材库" -NewName "02-内容素材库" -ErrorAction SilentlyContinue
Rename-Item -Path "$basePath\temp-03-选题管理" -NewName "03-选题管理" -ErrorAction SilentlyContinue
Rename-Item -Path "$basePath\temp-04-选题研究" -NewName "04-选题研究" -ErrorAction SilentlyContinue
Rename-Item -Path "$basePath\temp-05-内容创作" -NewName "05-内容创作" -ErrorAction SilentlyContinue
Rename-Item -Path "$basePath\temp-06-待发布" -NewName "06-待发布" -ErrorAction SilentlyContinue
Rename-Item -Path "$basePath\temp-07-已发布" -NewName "07-已发布" -ErrorAction SilentlyContinue
Rename-Item -Path "$basePath\temp-08-数据追踪" -NewName "08-数据追踪" -ErrorAction SilentlyContinue
Rename-Item -Path "$basePath\temp-09-方法论沉淀" -NewName "09-方法论沉淀" -ErrorAction SilentlyContinue
Rename-Item -Path "$basePath\temp-10-工具与资源" -NewName "10-工具与资源" -ErrorAction SilentlyContinue

Write-Output "第二步完成：重命名到最终名称"

# 处理 08-待发送小红书（合并到 06-待发布）
$source = "$basePath\08-待发送小红书"
$dest = "$basePath\06-待发布"
if (Test-Path $source) {
    # 移动内容
    Get-ChildItem $source -Recurse | ForEach-Object {
        $destPath = $_.FullName.Replace($source, $dest)
        $destDir = Split-Path $destPath -Parent
        if (-not (Test-Path $destDir)) {
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        }
        Move-Item $_.FullName $destPath -Force
    }
    # 删除空文件夹
    Remove-Item $source -Force -Recurse -ErrorAction SilentlyContinue
    Write-Output "已合并 08-待发送小红书 到 06-待发布"
}

Write-Output "重命名完成！"

# 显示新结构
Get-ChildItem $basePath -Directory | Select-Object Name | Sort-Object Name
