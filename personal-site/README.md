# 个人主页

一个简洁、现代的个人主页模板，适合自媒体创作者、知识管理爱好者使用。

## 预览

访问 `https://你的用户名.github.io` 查看效果

## 快速开始

### 1. Fork 这个仓库

点击右上角 Fork 按钮

### 2. 修改内容

编辑 `index.html`，修改以下内容：

```html
<!-- 修改名字 -->
<h1>你的名字</h1>

<!-- 修改简介 -->
<p class="bio">你的简介</p>

<!-- 修改标签 -->
<span class="tag">你的标签</span>

<!-- 修改链接 -->
<a href="你的链接" class="link">...</a>

<!-- 修改项目 -->
<div class="project">
    <h3>项目名称</h3>
    <p>项目描述</p>
</div>
```

### 3. 启用 GitHub Pages

1. 进入仓库 Settings
2. 找到 Pages 选项
3. Source 选择 `main` 分支
4. 保存后等待部署

### 4. 访问你的网站

网址：`https://你的用户名.github.io`

## 自定义

### 更换头像

将头像图片放入仓库，修改：

```html
<div class="avatar">
    <img src="你的头像.png" alt="头像" width="120" height="120">
</div>
```

### 更换主题色

修改 CSS 中的渐变色：

```css
background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
```

### 添加更多社交链接

在 `.links` 区域添加：

```html
<a href="链接地址" class="link">
    <span class="link-icon">图标</span>
    <span>名称</span>
</a>
```

## 技术栈

- HTML5
- CSS3
- 纯静态，无需后端
- 响应式设计

## License

MIT License
