# 🔋 MacBook 电池智能监控系统

一个智能的 macOS 电池监控工具，帮助延长电池寿命，避免过度充电和过度放电。

## ✨ 主要特性

- 🔌 **智能充电保护**：充电达到指定电量（默认75%）时自动休眠
- ⚡ **低电量保护**：电量过低（默认25%）时自动休眠保护电池
- 🔔 **智能提醒机制**：前3次强制休眠，之后仅发送通知提醒
- 🔄 **自动重置计数**：电量回到正常范围后自动重置休眠次数
- 📊 **详细日志记录**：记录每次休眠的详细信息
- 💤 **唤醒提醒**：电脑唤醒后显示休眠原因和统计信息
- 🚀 **开机自启动**：通过 launchd 服务实现系统启动时自动运行

## 📋 系统要求

- macOS 系统（支持 Intel 和 Apple Silicon）
- 需要管理员权限（用于休眠操作）

## 🚀 快速安装

### 方法一：使用安装脚本（推荐）

```bash
# 1. 下载项目
git clone https://github.com/yourusername/battery-monitor.git
cd battery-monitor

# 2. 运行安装脚本
chmod +x install.sh
./install.sh
```

### 方法二：手动安装

```bash
# 1. 复制脚本到目标位置
mkdir -p ~/battery_monitor
cp battery_monitor.sh ~/battery_monitor/
chmod +x ~/battery_monitor/battery_monitor.sh

# 2. 复制 plist 文件
cp com.user.battery.monitor.plist ~/Library/LaunchAgents/

# 3. 修改 plist 文件中的用户名（替换 YOUR_USERNAME）
sed -i '' "s/YOUR_USERNAME/$USER/g" ~/Library/LaunchAgents/com.user.battery.monitor.plist

# 4. 加载服务
launchctl load ~/Library/LaunchAgents/com.user.battery.monitor.plist
```

## ⚙️ 自定义配置

### 修改电量阈值

编辑 `~/battery_monitor/battery_monitor.sh` 文件：

```bash
HIGH_PERCENTAGE=${1:-75}  # 高电量阈值（默认75%）
LOW_PERCENTAGE=${2:-25}   # 低电量阈值（默认25%）
CHECK_INTERVAL=30         # 检查间隔（秒）
MAX_SLEEP_TIMES=3         # 最大强制休眠次数
```

或者在手动运行时指定参数：

```bash
./battery_monitor.sh 80 20  # 高电量阈值80%，低电量阈值20%
```

### 修改最大休眠次数

如果你想改为休眠5次后才只提醒，修改脚本中的：

```bash
MAX_SLEEP_TIMES=5  # 改为你想要的次数
```

## 📖 工作原理

### 休眠机制

1. **充电场景**（电量 ≥ 75%）：
   - 第1-3次：强制休眠 + 通知"电脑即将休眠（第X次）"
   - 第4次起：仅通知"建议拔掉充电器"，不再强制休眠
   - 当电量降到75%以下时，计数器自动重置

2. **低电量场景**（电量 ≤ 25%）：
   - 第1-3次：强制休眠保护电池 + 通知
   - 第4次起：仅通知"建议连接充电器"
   - 当电量充到25%以上时，计数器自动重置

### 唤醒提醒

电脑从休眠唤醒后，会显示弹窗提醒，包含：
- 休眠时间
- 休眠原因（充电完成/低电量保护）
- 休眠时的电量
- 当前已休眠次数
- 是否已达到最大次数的提示

## 🛠️ 服务管理命令

### 查看服务状态
```bash
launchctl list | grep battery
```

### 停止服务
```bash
launchctl unload ~/Library/LaunchAgents/com.user.battery.monitor.plist
```

### 启动服务
```bash
launchctl load ~/Library/LaunchAgents/com.user.battery.monitor.plist
```

### 重启服务（应用配置更改）
```bash
launchctl unload ~/Library/LaunchAgents/com.user.battery.monitor.plist
launchctl load ~/Library/LaunchAgents/com.user.battery.monitor.plist
```

### 查看日志
```bash
# 实时查看日志
tail -f ~/battery_monitor/battery_monitor.log

# 查看错误日志
tail -f ~/battery_monitor/battery_monitor.error.log
```

### 手动测试运行
```bash
cd ~/battery_monitor
./battery_monitor.sh
```

## 🔍 查看休眠统计

```bash
# 查看当前休眠计数器
cat ~/.battery_sleep_counter

# 查看最后一次休眠信息
cat ~/.battery_monitor_log

# 手动重置计数器
rm ~/.battery_sleep_counter
```

## 📁 文件说明

- `battery_monitor.sh` - 主监控脚本
- `com.user.battery.monitor.plist` - launchd 服务配置文件
- `install.sh` - 自动安装脚本
- `uninstall.sh` - 卸载脚本
- `README.md` - 本说明文档

### 运行时生成的文件

- `~/battery_monitor/battery_monitor.log` - 运行日志
- `~/battery_monitor/battery_monitor.error.log` - 错误日志
- `~/.battery_monitor_log` - 最后一次休眠记录
- `~/.battery_sleep_counter` - 休眠次数计数器
- `~/.battery_wakeup_message` - 唤醒提醒消息（临时）
- `~/.battery_show_wakeup.sh` - 唤醒提醒脚本（临时）

## 🗑️ 卸载

### 使用卸载脚本（推荐）

```bash
chmod +x uninstall.sh
./uninstall.sh
```

### 手动卸载

```bash
# 1. 停止并移除服务
launchctl unload ~/Library/LaunchAgents/com.user.battery.monitor.plist
rm ~/Library/LaunchAgents/com.user.battery.monitor.plist

# 2. 删除脚本和日志文件
rm -rf ~/battery_monitor

# 3. 删除临时文件
rm -f ~/.battery_monitor_log
rm -f ~/.battery_sleep_counter
rm -f ~/.battery_wakeup_message
rm -f ~/.battery_show_wakeup.sh
```

## ❓ 常见问题

### Q: 为什么会反复强制休眠？
A: 旧版本会一直强制休眠。新版本实现了智能计数：前3次强制休眠，之后只提醒不休眠。

### Q: 如何修改休眠次数？
A: 编辑 `battery_monitor.sh` 文件中的 `MAX_SLEEP_TIMES` 变量。

### Q: 服务没有自动启动怎么办？
A: 检查 plist 文件是否正确放置在 `~/Library/LaunchAgents/` 目录，并确保用户名已正确替换。

### Q: 如何暂时禁用服务？
A: 运行 `launchctl unload ~/Library/LaunchAgents/com.user.battery.monitor.plist`

### Q: 电脑唤醒后没有显示提醒？
A: 检查 `~/.battery_show_wakeup.sh` 文件是否存在和可执行。

### Q: 如何重置休眠计数器？
A: 删除计数器文件：`rm ~/.battery_sleep_counter`

## 🤝 分享给其他人

### 通过 GitHub 分享

1. 创建 GitHub 仓库
2. 推送代码：
```bash
git init
git add .
git commit -m "Initial commit: Battery monitor for macOS"
git branch -M main
git remote add origin https://github.com/yourusername/battery-monitor.git
git push -u origin main
```

3. 其他人就可以通过以下方式安装：
```bash
git clone https://github.com/yourusername/battery-monitor.git
cd battery-monitor
chmod +x install.sh
./install.sh
```

### 直接分享文件

将整个 `battery` 文件夹打包发送给朋友：

```bash
cd ~/code
tar -czf battery-monitor.tar.gz battery/
# 将 battery-monitor.tar.gz 文件发送给朋友
```

朋友收到后解压并安装：

```bash
tar -xzf battery-monitor.tar.gz
cd battery
chmod +x install.sh
./install.sh
```

## 📝 更新日志

### v2.0 (最新)
- ✨ 新增智能休眠计数机制
- ✨ 前3次强制休眠，之后仅提醒
- ✨ 自动重置计数器
- ✨ 增强的唤醒提醒信息
- 🐛 修复反复强制休眠的问题

### v1.0
- 🎉 首次发布
- 基本的电量监控和休眠功能

## 📄 许可证

MIT License - 随意使用和修改

## 👨‍💻 贡献

欢迎提交 Issue 和 Pull Request！

---

如果这个工具对你有帮助，请给个 ⭐ Star！
