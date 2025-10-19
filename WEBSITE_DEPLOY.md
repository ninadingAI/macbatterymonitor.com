# 🌐 网站部署指南

您的电池监控工具现在有了一个漂亮的展示网站！本指南将帮您部署到 GitHub Pages（完全免费）。

## 📁 网站文件说明

```
docs/
├── index.html    # 主页（单页应用）
└── .nojekyll     # 告诉 GitHub Pages 不使用 Jekyll
```

## 🚀 部署步骤

### 方式一：GitHub Pages 自动部署（推荐）

#### 1. 推送代码到 GitHub

```bash
cd /Users/nina/code/battery

# 如果还没初始化 git
git init

# 添加所有文件
git add .
git commit -m "Add project website"

# 推送到 GitHub（替换 YOUR_USERNAME）
git remote add origin https://github.com/YOUR_USERNAME/battery-monitor.git
git branch -M main
git push -u origin main
```

#### 2. 启用 GitHub Pages

1. 进入 GitHub 仓库页面
2. 点击 `Settings`（设置）
3. 在左侧菜单找到 `Pages`
4. 在 "Source" 下选择：
   - **Source**: `Deploy from a branch`
   - **Branch**: `main`
   - **Folder**: `/` (根目录)
5. 点击 `Save`

#### 3. 等待部署完成

- GitHub 会自动构建和部署（通常 1-2 分钟）
- 部署完成后会显示网站地址：`https://YOUR_USERNAME.github.io/battery-monitor/`

#### 4. 访问您的网站

```
https://YOUR_USERNAME.github.io/battery-monitor/
```

### 方式二：使用自定义域名（可选）

如果您有自己的域名：

#### 1. 创建 CNAME 文件

```bash
echo "yourdomain.com" > docs/CNAME
git add docs/CNAME
git commit -m "Add custom domain"
git push
```

#### 2. 配置 DNS

在您的域名提供商处添加 DNS 记录：

**使用 A 记录（推荐）：**
```
Type: A
Host: @
Value: 185.199.108.153
       185.199.109.153
       185.199.110.153
       185.199.111.153
```

**使用 CNAME 记录：**
```
Type: CNAME
Host: www
Value: YOUR_USERNAME.github.io
```

#### 3. 在 GitHub Settings 中配置

1. 进入仓库的 `Settings` → `Pages`
2. 在 "Custom domain" 输入您的域名
3. 勾选 "Enforce HTTPS"
4. 等待 DNS 检查通过（可能需要几分钟到几小时）

## ✏️ 自定义网站内容

### 更新 GitHub 链接（重要！）

**必须**在部署前替换所有的 `YOUR_USERNAME`：

```bash
cd /Users/nina/code/battery

# 替换为你的 GitHub 用户名（例如：octocat）
sed -i '' 's/YOUR_USERNAME/你的GitHub用户名/g' docs/index.html

# 验证替换结果
grep -n "YOUR_USERNAME" docs/index.html

# 如果没有输出，说明替换成功
# 提交更改
git add docs/index.html
git commit -m "Update GitHub username in website"
git push
```

**替换的位置包括：**
- Canonical URL
- Open Graph URLs
- GitHub 链接
- Download 链接

### 修改网站内容

网站是单文件应用，所有内容都在 `docs/index.html` 中：

```bash
# 编辑网站
open -a "Visual Studio Code" docs/index.html
# 或使用任何文本编辑器

# 提交更改
git add docs/index.html
git commit -m "Update website content"
git push
```

常见自定义位置：
- **标题和副标题**：在 `<header>` 标签内
- **功能介绍**：在 `.feature-card` 部分
- **安装说明**：在 `.install-section` 部分
- **FAQ**：在底部的 `<details>` 标签内

### 添加 Google Analytics（可选）

在 `</head>` 之前添加：

```html
<!-- Google Analytics -->
<script async src="https://www.googletagmanager.com/gtag/js?id=GA_MEASUREMENT_ID"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'GA_MEASUREMENT_ID');
</script>
```

## 🎨 网站功能说明

### 已实现的功能

✅ **响应式设计** - 手机、平板、电脑完美适配  
✅ **一键复制代码** - 所有代码块都有复制按钮  
✅ **配置生成器** - 可视化配置电量阈值  
✅ **动画效果** - 流畅的页面动画  
✅ **FAQ 折叠面板** - 常见问题解答  
✅ **服务管理命令** - 完整的命令参考  
✅ **深色代码块** - 模拟终端效果  

### 交互功能

1. **滑块配置**：
   - 调整高电量阈值（60-95%）
   - 调整低电量阈值（10-40%）
   - 调整最大休眠次数（1-10次）
   - 实时生成安装命令

2. **一键复制**：
   - 点击任何代码块的 "Copy" 按钮
   - 自动复制到剪贴板
   - 显示 "Copied!" 确认

3. **FAQ 展开**：
   - 点击问题标题展开/折叠
   - 查看详细答案

## 📊 网站分析

### 查看访问数据

使用 GitHub 提供的 Insights：

1. 进入仓库页面
2. 点击 `Insights`
3. 查看 `Traffic` - 访问量统计

### 添加 Star 徽章

在 README.md 中添加（网站自动显示）：

```markdown
![GitHub stars](https://img.shields.io/github/stars/YOUR_USERNAME/battery-monitor?style=social)
![GitHub forks](https://img.shields.io/github/forks/YOUR_USERNAME/battery-monitor?style=social)
```

## 🔧 本地测试网站

在推送前本地预览：

```bash
cd /Users/nina/code/battery/docs

# 方法1：Python 自带服务器
python3 -m http.server 8000

# 方法2：使用 PHP（如果安装了）
php -S localhost:8000

# 然后在浏览器打开：
# http://localhost:8000
```

## 🐛 常见问题

### Q: 网站显示 404

**A:** 检查以下几点：
1. 确保 `docs` 文件夹已推送到 GitHub
2. GitHub Pages 设置中选择了 `/docs` 文件夹
3. 等待 1-2 分钟让 GitHub 完成部署
4. 检查仓库是否为 Public（私有仓库需要 Pro 账号）

### Q: 修改后网站没更新

**A:** 可能的原因：
1. 浏览器缓存 - 按 `Cmd+Shift+R` 强制刷新
2. GitHub Pages 缓存 - 等待几分钟
3. 没有正确推送 - 运行 `git push` 确认

### Q: 自定义域名不工作

**A:** 检查：
1. DNS 记录已正确配置（使用 dig/nslookup 检查）
2. CNAME 文件内容正确
3. 等待 DNS 传播（最多 48 小时）
4. 在 GitHub Settings 中看到绿色勾号

### Q: 网站样式错乱

**A:** 可能是：
1. HTML 文件损坏 - 检查语法
2. 浏览器兼容性 - 尝试其他浏览器
3. 清除浏览器缓存

## 📱 分享您的网站

### 社交媒体分享

**微博/Twitter：**
```
🔋 刚做了个 MacBook 电池监控工具，可以自动管理电池健康！
前3次会自动休眠，之后只提醒，不再打断工作。

🌐 在线体验：https://YOUR_USERNAME.github.io/battery-monitor/
⭐ GitHub：https://github.com/YOUR_USERNAME/battery-monitor

#macOS #开源 #效率工具
```

**知乎/技术社区：**
```markdown
# MacBook 电池智能监控工具

我开发了一个工具来自动管理 MacBook 电池健康，解决了长期插电过度充电的问题。

**核心功能：**
- 充电到 75% 自动提醒（前3次会休眠）
- 电量低于 25% 自动保护
- 智能计数，不会无限打断工作

**在线体验和下载：**
👉 https://YOUR_USERNAME.github.io/battery-monitor/

完全开源，欢迎使用和反馈！
```

### 二维码生成

使用在线工具生成网站二维码：
- https://www.qrcode-monkey.com/
- 输入网站地址
- 下载二维码图片
- 可以打印或分享给朋友

### 加入 Awesome 列表

搜索相关的 awesome 列表并提交 PR：
- awesome-macos
- awesome-mac
- awesome-shell

## 🎯 下一步优化

### 可选增强功能

1. **添加演示视频**
   - 录制使用演示
   - 上传到 YouTube/B站
   - 嵌入网站

2. **添加截图**
   ```html
   <img src="screenshot.png" alt="Screenshot" style="max-width: 100%; border-radius: 12px;">
   ```

3. **多语言支持**
   - 创建 `index_en.html`（英文版）
   - 添加语言切换按钮

4. **用户反馈**
   - 集成 GitHub Discussions
   - 添加评论区（使用 utterances）

5. **统计数据**
   - 显示 Star 数量
   - 显示 Fork 数量
   - 使用 shields.io 徽章

## 📝 更新日志

记录网站的重要更新：

```bash
# 在 commit 时使用有意义的消息
git commit -m "Website: Add configuration generator"
git commit -m "Website: Update FAQ section"
git commit -m "Website: Improve mobile responsiveness"
```

---

## ✅ 部署检查清单

### 基础部署

- [ ] 代码已推送到 GitHub
- [ ] GitHub Pages 已启用（设置为 /docs 目录）
- [ ] 网站可以访问（https://YOUR_USERNAME.github.io/battery-monitor/）
- [ ] 所有链接已更新（替换 YOUR_USERNAME）
- [ ] 一键复制功能正常工作
- [ ] 配置生成器功能正常
- [ ] 手机端浏览正常
- [ ] 在 README.md 中添加网站链接

### SEO 优化检查

- [ ] **Canonical URL** - 已更新为正确的域名
- [ ] **Meta Description** - 准确描述（155字符以内）
- [ ] **H1 标签** - 页面只有一个 H1
- [ ] **H2 标签** - 每个主要部分都有 H2
- [ ] **Open Graph** - Facebook 分享卡片正确显示
- [ ] **Twitter Card** - Twitter 分享卡片正确显示
- [ ] **Structured Data** - Schema.org 标记已添加
- [ ] **Alt Text** - 所有图标都有 aria-label
- [ ] **Mobile-Friendly** - Google 移动端友好测试通过
- [ ] **Page Speed** - 加载速度优化（使用 CDN）

### 使用以下工具验证

1. **Google Search Console**
   ```
   https://search.google.com/search-console
   ```
   - 提交网站地图
   - 检查索引状态

2. **Google Mobile-Friendly Test**
   ```
   https://search.google.com/test/mobile-friendly
   ```

3. **PageSpeed Insights**
   ```
   https://pagespeed.web.dev/
   ```

4. **Meta Tags Validator**
   ```
   https://metatags.io/
   ```

5. **Schema Markup Validator**
   ```
   https://validator.schema.org/
   ```

---

🎉 **恭喜！您的项目网站已经上线了！**

有任何问题欢迎在 GitHub Issues 中提出。

