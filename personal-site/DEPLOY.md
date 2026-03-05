# 个人主页部署指南

## 方法一：GitHub Pages（推荐）

### 步骤 1：创建 GitHub 仓库

1. 登录 GitHub
2. 点击右上角 `+` → `New repository`
3. 仓库名填：`你的用户名.github.io`
4. 勾选 `Add a README file`
5. 点击 `Create repository`

### 步骤 2：上传文件

1. 点击 `Add file` → `Upload files`
2. 拖入 `index.html` 和 `README.md`
3. 点击 `Commit changes`

### 步骤 3：启用 GitHub Pages

1. 进入仓库 `Settings`
2. 左侧找到 `Pages`
3. Source 选择 `Deploy from a branch`
4. Branch 选择 `main`，文件夹选择 `/ (root)`
5. 点击 `Save`

### 步骤 4：访问网站

等 1-2 分钟，访问：
```
https://你的用户名.github.io
```

---

## 方法二：Vercel（更快）

### 步骤 1：注册 Vercel

访问 https://vercel.com
用 GitHub 登录

### 步骤 2：导入仓库

1. 点击 `New Project`
2. 选择你的 GitHub 仓库
3. 点击 `Deploy`

### 步骤 3：访问网站

自动获得域名：
```
https://你的项目名.vercel.app
```

---

## 方法三：Netlify

### 步骤 1：注册 Netlify

访问 https://netlify.com
用 GitHub 登录

### 步骤 2：拖拽部署

1. 点击 `Add new site` → `Deploy manually`
2. 拖入 `index.html` 文件夹
3. 自动部署完成

### 步骤 3：访问网站

自动获得域名：
```
https://随机名.netlify.app
```

---

## 自定义域名

### GitHub Pages

1. 在仓库根目录创建 `CNAME` 文件
2. 内容填你的域名：`example.com`
3. 在域名 DNS 添加 CNAME 记录指向 `你的用户名.github.io`

### Vercel / Netlify

在项目设置中添加自定义域名，按提示配置 DNS

---

## 更新网站

修改 `index.html` 后：

1. Git 提交并推送
2. GitHub Pages 自动部署（1-2 分钟）
3. Vercel/Netlify 自动部署（几秒）

---

## 常见问题

### Q: 网站没更新？

清除浏览器缓存，或加 `?t=123` 访问

### Q: 中文乱码？

确保 `index.html` 开头有：
```html
<meta charset="UTF-8">
```

### Q: 样式不生效？

检查 CSS 是否正确，清除缓存重试
