---
name: github
description: "通过 `gh` CLI进行GitHub操作：issue、PR、CI运行、代码审查、API查询。用于：(1) 检查PR状态或CI，(2) 创建/评论issue，(3) 列出/过滤PR或issue，(4) 查看运行日志。不适用于：需要手动浏览器流程的复杂Web UI交互（用浏览器工具）、跨多个仓库的批量操作（用gh api脚本）、或gh auth未配置时。"
---

# GitHub技能

使用 `gh` CLI与GitHub仓库、issue、PR和CI交互。

## 使用场景

✅ **使用这个技能：**

- 检查PR状态、审查或合并准备情况
- 查看CI/工作流运行状态和日志
- 创建、关闭或评论issue
- 创建或合并拉取请求
- 查询GitHub API获取仓库数据
- 列出仓库、发布或协作者

❌ **不使用这个技能：**

- 本地git操作（commit、push、pull、branch）→ 直接用 `git`
- 非GitHub仓库（GitLab、Bitbucket、自托管）→ 用其他CLI
- 克隆仓库 → 用 `git clone`
- 审查实际代码更改 → 用 `coding-agent` 技能
- 复杂的多文件差异 → 用 `coding-agent` 或直接读取文件

## 设置

```bash
# 认证（一次性）
gh auth login

# 验证
gh auth status
```

## 常用命令

### 拉取请求

```bash
# 列出PR
gh pr list --repo owner/repo

# 检查CI状态
gh pr checks 55 --repo owner/repo

# 查看PR详情
gh pr view 55 --repo owner/repo

# 创建PR
gh pr create --title "feat: 添加功能" --body "描述..."

# 合并PR
gh pr merge 55 --squash --repo owner/repo
```

### Issue

```bash
# 列出issue
gh issue list --repo owner/repo --state open

# 创建issue
gh issue create --title "Bug: 某某问题" --body "详情..."

# 关闭issue
gh issue close 42 --repo owner/repo
```

### CI/工作流运行

```bash
# 列出最近运行
gh run list --repo owner/repo --limit 10

# 查看特定运行
gh run view <run-id> --repo owner/repo

# 仅查看失败步骤日志
gh run view <run-id> --repo owner/repo --log-failed

# 重新运行失败作业
gh run rerun <run-id> --failed --repo owner/repo
```

### API查询

```bash
# 获取PR特定字段
gh api repos/owner/repo/pulls/55 --jq '.title, .state, .user.login'

# 列出所有标签
gh api repos/owner/repo/labels --jq '.[].name'

# 获取仓库统计
gh api repos/owner/repo --jq '{stars: .stargazers_count, forks: .forks_count}'
```

## JSON输出

大多数命令支持 `--json` 获取结构化输出，配合 `--jq` 过滤：

```bash
gh issue list --repo owner/repo --json number,title --jq '.[] | "\(.number): \(.title)"'
gh pr list --json number,title,state,mergeable --jq '.[] | select(.mergeable == "MERGEABLE")'
```

## 注意事项

- 不在git目录时始终指定 `--repo owner/repo`
- 直接使用URL：`gh pr view https://github.com/owner/repo/pull/55`
- 有速率限制；重复查询使用 `gh api --cache 1h`

---

*触发词：GitHub、PR、issue、CI、仓库*
