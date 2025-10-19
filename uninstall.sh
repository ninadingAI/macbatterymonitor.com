#!/bin/bash

# 电池监控系统卸载脚本
# 完全移除电池监控服务和相关文件

set -e  # 遇到错误立即退出

echo "=========================================="
echo "🗑️  MacBook 电池监控系统 - 卸载向导"
echo "=========================================="
echo ""

# 定义路径
INSTALL_DIR="$HOME/battery_monitor"
PLIST_FILE="$HOME/Library/LaunchAgents/com.user.battery.monitor.plist"
LOG_FILE="$HOME/.battery_monitor_log"
COUNTER_FILE="$HOME/.battery_sleep_counter"
WAKEUP_MSG="$HOME/.battery_wakeup_message"
WAKEUP_SCRIPT="$HOME/.battery_show_wakeup.sh"

echo "⚠️  即将卸载电池监控系统"
echo ""
echo "将删除以下内容："
echo "   - 服务配置: $PLIST_FILE"
echo "   - 安装目录: $INSTALL_DIR"
echo "   - 运行日志: $LOG_FILE"
echo "   - 计数器文件: $COUNTER_FILE"
echo "   - 临时文件: 唤醒提醒相关文件"
echo ""
read -p "确定要继续吗？(y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ 卸载已取消"
    exit 0
fi

echo ""
echo "开始卸载..."
echo ""

# 1. 停止并移除 launchd 服务
if [[ -f "$PLIST_FILE" ]]; then
    echo "🛑 停止服务..."
    launchctl unload "$PLIST_FILE" 2>/dev/null || true
    
    echo "🗑️  删除服务配置..."
    rm "$PLIST_FILE"
    echo "   ✓ 已删除: $PLIST_FILE"
else
    echo "⚠️  服务配置文件不存在，跳过"
fi

# 2. 删除安装目录
if [[ -d "$INSTALL_DIR" ]]; then
    echo "🗑️  删除安装目录..."
    rm -rf "$INSTALL_DIR"
    echo "   ✓ 已删除: $INSTALL_DIR"
else
    echo "⚠️  安装目录不存在，跳过"
fi

# 3. 删除运行时生成的文件
echo "🗑️  删除运行时文件..."

if [[ -f "$LOG_FILE" ]]; then
    rm "$LOG_FILE"
    echo "   ✓ 已删除: $LOG_FILE"
fi

if [[ -f "$COUNTER_FILE" ]]; then
    rm "$COUNTER_FILE"
    echo "   ✓ 已删除: $COUNTER_FILE"
fi

if [[ -f "$WAKEUP_MSG" ]]; then
    rm "$WAKEUP_MSG"
    echo "   ✓ 已删除: $WAKEUP_MSG"
fi

if [[ -f "$WAKEUP_SCRIPT" ]]; then
    rm "$WAKEUP_SCRIPT"
    echo "   ✓ 已删除: $WAKEUP_SCRIPT"
fi

# 4. 验证服务是否已完全停止
echo ""
echo "🔍 验证卸载状态..."
if launchctl list | grep -q "com.user.battery.monitor"; then
    echo "⚠️  警告: 服务仍在运行，尝试强制停止..."
    launchctl remove com.user.battery.monitor 2>/dev/null || true
else
    echo "   ✓ 服务已完全停止"
fi

echo ""
echo "=========================================="
echo "✅ 卸载完成！"
echo "=========================================="
echo ""
echo "电池监控系统已完全移除。"
echo ""
echo "如果需要重新安装，运行: ./install.sh"
echo ""

