#!/bin/bash

# 🔋 MacBook 电池监控工具 - 完整版本
# 作者: ninadingAI
# GitHub: https://github.com/ninadingAI/macbatterymonitor.com
# 网站: https://ninadingAI.github.io/macbatterymonitor.com

set -e  # 遇到错误立即退出

# 配置参数
HIGH_PERCENTAGE=${1:-75}    # 高电量阈值（默认75%）
LOW_PERCENTAGE=${2:-25}     # 低电量阈值（默认25%）
CHECK_INTERVAL=30           # 检查间隔（秒）
MAX_SLEEP_TIMES=3          # 最大强制休眠次数
LOG_FILE="$HOME/.battery_monitor_log"
COUNTER_FILE="$HOME/.battery_sleep_counter"
ERROR_LOG="$HOME/.battery_monitor_error.log"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

log_error() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - ERROR: $1" >> "$ERROR_LOG"
}

# 发送通知
send_notification() {
    local title="$1"
    local message="$2"
    local sound="$3"
    
    osascript -e "display notification \"$message\" second title \"$title\" sound name \"$sound\""
}

# 获取电池信息
get_battery_info() {
    local battery_info=$(pmset -g batt)
    local battery_percentage=$(echo "$battery_info" | grep -o '[0-9]*%' | head -1 | sed 's/%//')
    local battery_status=$(echo "$battery_info" | grep -o 'charging\|discharging\|charged\|AC' | head -1)
    
    echo "$battery_percentage $battery_status"
}

# 读取睡眠计数器
read_sleep_counter() {
    if [[ -f "$COUNTER_FILE" ]]; then
        cat "$COUNTER_FILE"
    else
        echo "0"
    fi
}

# 写入睡眠计数器
write_sleep_counter() {
    echo "$1" > "$COUNTER_FILE"
}

# 强制休眠
force_sleep() {
    local reason="$1"
    local attempt="$2"
    
    log_message "强制休眠 - 原因: $reason, 尝试次数: $attempt"
    
    # 发送通知
    send_notification "电池监控" "Mac即将休眠（第${attempt}次）- $reason" "Glass"
    
    # 等待2秒让用户看到通知
    sleep 2
    
    # 强制休眠
    sudo pmset sleepnow
}

# 显示提醒
show_reminder() {
    local message="$1"
    
    log_message "显示提醒: $message"
    send_notification "电池监控" "$message" "Ping"
}

# 检查电池状态
check_battery() {
    local battery_info=($(get_battery_info))
    local percentage=${battery_info[0]}
    local status=${battery_info[1]}
    
    if [[ -z "$percentage" ]]; then
        log_error "无法获取电池信息"
        return 1
    fi
    
    local sleep_count=$(read_sleep_counter)
    
    # 检查高电量（充电时）
    if [[ "$status" == "charging" ]] && [[ "$percentage" -ge "$HIGH_PERCENTAGE" ]]; then
        if [[ "$sleep_count" -lt "$MAX_SLEEP_TIMES" ]]; then
            local new_count=$((sleep_count + 1))
            write_sleep_counter "$new_count"
            force_sleep "充电完成 ($percentage%)" "$new_count"
        else
            show_reminder "建议拔掉充电器，电池已充至 $percentage%"
        fi
        return 0
    fi
    
    # 检查低电量（放电时）
    if [[ "$status" == "discharging" ]] && [[ "$percentage" -le "$LOW_PERCENTAGE" ]]; then
        if [[ "$sleep_count" -lt "$MAX_SLEEP_TIMES" ]]; then
            local new_count=$((sleep_count + 1))
            write_sleep_counter "$new_count"
            force_sleep "低电量保护 ($percentage%)" "$new_count"
        else
            show_reminder "建议连接充电器，电量仅剩 $percentage%"
        fi
        return 0
    fi
    
    # 重置计数器（电量在正常范围内）
    if [[ "$percentage" -lt "$HIGH_PERCENTAGE" ]] && [[ "$percentage" -gt "$LOW_PERCENTAGE" ]]; then
        if [[ "$sleep_count" -gt 0 ]]; then
            write_sleep_counter "0"
            log_message "电池回到正常范围 ($percentage%)，重置睡眠计数器"
        fi
    fi
    
    return 0
}

# 主循环
main_loop() {
    log_message "开始监控电池电量..."
    log_message "配置 - 高电量阈值: ${HIGH_PERCENTAGE}%, 低电量阈值: ${LOW_PERCENTAGE}%, 最大休眠次数: ${MAX_SLEEP_TIMES}"
    
    while true; do
        if check_battery; then
            sleep "$CHECK_INTERVAL"
        else
            log_error "电池检查失败，等待 ${CHECK_INTERVAL} 秒后重试"
            sleep "$CHECK_INTERVAL"
        fi
    done
}

# 显示帮助信息
show_help() {
    echo "🔋 MacBook 电池监控工具"
    echo ""
    echo "用法: $0 [高电量阈值] [低电量阈值]"
    echo ""
    echo "参数:"
    echo "  高电量阈值    充电时达到此百分比会触发保护 (默认: 75)"
    echo "  低电量阈值    放电时低于此百分比会触发保护 (默认: 25)"
    echo ""
    echo "示例:"
    echo "  $0           # 使用默认设置 (75% 和 25%)"
    echo "  $0 80 20     # 高电量阈值 80%，低电量阈值 20%"
    echo ""
    echo "功能:"
    echo "  • 自动监控电池电量"
    echo "  • 智能休眠保护机制"
    echo "  • 详细的日志记录"
    echo "  • 原生 macOS 通知"
    echo ""
    echo "按 Ctrl+C 停止监控"
}

# 处理命令行参数
case "${1:-}" in
    -h|--help|help)
        show_help
        exit 0
        ;;
esac

# 检查系统要求
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ 错误: 此工具仅支持 macOS 系统"
    exit 1
fi

# 检查管理员权限
if ! sudo -n true 2>/dev/null; then
    echo "⚠️  需要管理员权限来执行休眠操作"
    echo "请确保您有管理员权限，或者安装时将脚本配置为系统服务"
fi

# 创建日志文件
touch "$LOG_FILE" "$ERROR_LOG"

# 显示启动信息
echo "🔋 MacBook 电池监控工具启动中..."
echo "📊 配置信息:"
echo "   • 高电量阈值: ${HIGH_PERCENTAGE}%"
echo "   • 低电量阈值: ${LOW_PERCENTAGE}%"
echo "   • 检查间隔: ${CHECK_INTERVAL}秒"
echo "   • 最大休眠次数: ${MAX_SLEEP_TIMES}次"
echo "   • 日志文件: $LOG_FILE"
echo ""
echo "💡 提示: 按 Ctrl+C 停止监控"
echo ""

# 启动主循环
main_loop
