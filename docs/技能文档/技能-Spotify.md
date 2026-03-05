---
name: spotify-player
description: "通过spogo（首选）或spotify_player进行终端Spotify播放/搜索。"
---

# Spotify技能

使用 `spogo` **（首选）** 进行Spotify播放/搜索。如需要可回退到 `spotify_player`。

## 要求

- Spotify Premium账户
- 安装 `spogo` 或 `spotify_player`

## spogo设置

```bash
# 导入cookie
spogo auth import --browser chrome
```

## 常用命令

### spogo（首选）

```bash
# 搜索
spogo search track "歌曲名"

# 播放控制
spogo play
spogo pause
spogo next
spogo prev

# 设备
spogo device list
spogo device set "<名称|id>"

# 状态
spogo status
```

### spotify_player（备选）

```bash
# 搜索
spotify_player search "查询"

# 播放控制
spotify_player playback play
spotify_player playback pause
spotify_player playback next
spotify_player playback previous

# 连接设备
spotify_player connect

# 喜欢歌曲
spotify_player like
```

## 注意事项

- 配置文件夹：`~/.config/spotify-player`（如 `app.toml`）
- Spotify Connect集成需要在配置中设置用户 `client_id`
- TUI快捷键可通过应用中的 `?` 查看

---

*触发词：Spotify、播放音乐、音乐*
