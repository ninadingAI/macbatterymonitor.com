# 📤 分享指南

这份指南帮助你将电池监控工具分享给其他人使用。

## 🌟 方法一：通过 GitHub 分享（推荐）

这是最专业和便捷的方式，其他人可以直接克隆和安装。

### 步骤 1: 初始化 Git 仓库

```bash
cd ~/code/battery

# 初始化 git（如果还没有）
git init

# 添加所有文件
git add .

# 创建首次提交
git commit -m "Initial commit: MacBook 电池智能监控系统 v2.0

功能特性:
- 智能充电保护（默认75%）
- 低电量保护（默认25%）
- 前3次强制休眠，之后仅提醒
- 自动重置计数器
- 开机自启动"
```

### 步骤 2: 创建 GitHub 仓库

1. 访问 https://github.com/new
2. 仓库名称建议：`battery-monitor` 或 `macos-battery-monitor`
3. 描述示例：`🔋 智能 MacBook 电池监控工具 - 延长电池寿命，避免过度充放电`
4. 选择 Public（公开）
5. 不要勾选 "Add a README file"（我们已经有了）
6. 点击 "Create repository"

### 步骤 3: 推送代码到 GitHub

```bash
# 添加远程仓库（替换 YOUR_USERNAME 为你的 GitHub 用户名）
git remote add origin https://github.com/YOUR_USERNAME/battery-monitor.git

# 推送代码
git branch -M main
git push -u origin main
```

### 步骤 4: 告诉朋友如何安装

分享这个链接给你的朋友：
```
https://github.com/YOUR_USERNAME/battery-monitor
```

他们只需要运行：
```bash
git clone https://github.com/YOUR_USERNAME/battery-monitor.git
cd battery-monitor
chmod +x install.sh
./install.sh
```

## 📦 方法二：打包文件分享

适合不熟悉 Git 的朋友。

### 创建压缩包

```bash
cd ~/code
tar -czf battery-monitor.tar.gz \
    --exclude='*.log' \
    --exclude='.git' \
    --exclude='.DS_Store' \
    battery/

# 文件会生成在 ~/code/battery-monitor.tar.gz
```

### 朋友如何使用

1. 将 `battery-monitor.tar.gz` 文件发送给朋友（通过微信、邮件等）

2. 朋友收到后解压：
```bash
tar -xzf battery-monitor.tar.gz
cd battery
chmod +x install.sh
./install.sh
```

## 💾 方法三：通过网盘分享

### 上传到网盘

1. 创建压缩包（见方法二）
2. 上传到百度网盘/阿里云盘/Google Drive 等
3. 生成分享链接

### 创建说明文档

在网盘分享时附上说明：

```
MacBook 电池智能监控工具 v2.0

🎯 功能：
• 充电达到75%自动休眠（可自定义）
• 电量低于25%自动休眠保护电池
• 前3次强制休眠，之后仅提醒
• 电量恢复正常自动重置计数

📥 安装方法：
1. 下载并解压文件
2. 打开终端，cd 到解压目录
3. 运行：chmod +x install.sh && ./install.sh

💻 系统要求：macOS 10.13+

📖 详细文档：见 README.md
```

## 🎨 方法四：制作 Release 发布

如果你的项目在 GitHub 上，可以创建正式发布版本。

### 在 GitHub 上创建 Release

1. 进入你的 GitHub 仓库页面
2. 点击右侧 "Releases" → "Create a new release"
3. 标签版本：`v2.0`
4. 发布标题：`v2.0 - 智能休眠计数机制`
5. 发布说明：

```markdown
## ✨ 新功能

- 🔢 智能休眠计数机制：前3次强制休眠，之后仅提醒
- 🔄 自动重置计数器：电量回到正常范围自动重置
- 📊 增强的统计信息：显示已休眠次数
- 💬 改进的通知提示

## 🐛 修复

- 修复反复强制休眠的问题
- 优化唤醒提醒逻辑

## 📥 快速安装

\`\`\`bash
git clone https://github.com/YOUR_USERNAME/battery-monitor.git
cd battery-monitor
chmod +x install.sh
./install.sh
\`\`\`

## 📖 完整文档

查看 [README.md](https://github.com/YOUR_USERNAME/battery-monitor/blob/main/README.md)
```

6. 上传 `battery-monitor.tar.gz` 作为附件
7. 点击 "Publish release"

## 📱 方法五：社交媒体分享

### 分享到技术社区

适合分享的平台：
- GitHub（开源社区）
- V2EX（创意工作者社区）
- 少数派（效率工具分享）
- 知乎（技术分享）
- 掘金（开发者社区）

### 分享文案模板

```
🔋 分享一个自己写的 MacBook 电池保护工具

MacOS 用户都知道，长期保持 100% 充电或让电量耗尽都会损害电池寿命。
所以我做了这个小工具，自动监控电池并智能提醒。

⚡ 主要功能：
• 充电到 75% 自动提醒（前3次会休眠）
• 电量低于 25% 自动保护（前3次休眠）
• 智能计数，不会无限打断你的工作
• 开机自启动，无感运行

🎁 完全开源，一键安装：
[GitHub 链接]

适合经常插着电源工作的朋友们 👨‍💻
```

## 🤝 如何接受其他人的贡献

如果你的项目在 GitHub 上，别人可能会提出改进建议。

### 在 README 中添加贡献指南

在 README.md 末尾已经包含了：

```markdown
## 👨‍💻 贡献

欢迎提交 Issue 和 Pull Request！
```

### 回应 Issues 和 Pull Requests

- 及时回复问题和建议
- 测试别人提交的代码
- 合并有价值的改进

## 📊 推广小技巧

1. **写一篇详细的博客**
   - 介绍为什么做这个工具
   - 技术实现的思路
   - 使用效果展示

2. **录制演示视频**
   - 展示安装过程
   - 演示功能效果
   - 上传到 YouTube/B站

3. **添加徽章**
   在 README 开头添加：
   ```markdown
   ![GitHub stars](https://img.shields.io/github/stars/YOUR_USERNAME/battery-monitor)
   ![License](https://img.shields.io/badge/license-MIT-blue.svg)
   ![Platform](https://img.shields.io/badge/platform-macOS-lightgrey.svg)
   ```

4. **标注关键词**
   在项目描述中使用：
   - macOS, battery, monitor, health
   - 电池, 监控, MacBook, 健康

## ❓ 常见问题

### Q: 我的项目更新了，如何让已安装的用户更新？

A: 用户只需要：
```bash
cd battery-monitor
git pull
./install.sh
```

### Q: 如何处理不同版本？

A: 使用 Git 标签：
```bash
git tag -a v2.0 -m "Version 2.0: 智能计数机制"
git push origin v2.0
```

### Q: 朋友说安装失败怎么办？

A: 让他们查看错误日志：
```bash
cat ~/battery_monitor/battery_monitor.error.log
```

然后根据错误信息排查问题。

---

希望这份指南能帮助你顺利分享你的作品！🎉
```

