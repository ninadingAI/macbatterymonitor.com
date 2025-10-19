#!/bin/bash

# 电池监控脚本 - 在电池充电达到指定百分比或低电量时自动让电脑休眠
# 使用方法: ./battery_monitor.sh [高电量阈值] [低电量阈值]

HIGH_PERCENTAGE=${1:-75}
LOW_PERCENTAGE=${2:-25}
CHECK_INTERVAL=30  # 检查间隔（秒）
LOG_FILE="$HOME/.battery_monitor_log"
COUNTER_FILE="$HOME/.battery_sleep_counter"  # 休眠次数计数器文件
MAX_SLEEP_TIMES=3  # 最大强制休眠次数

# 获取休眠次数的函数
get_sleep_count() {
    local reason=$1
    if [[ -f "$COUNTER_FILE" ]]; then
        local stored_reason=$(grep "REASON:" "$COUNTER_FILE" | cut -d: -f2)
        local stored_count=$(grep "COUNT:" "$COUNTER_FILE" | cut -d: -f2)
        
        # 如果原因相同，返回计数；否则返回0（说明场景已改变）
        if [[ "$stored_reason" == "$reason" ]]; then
            echo "${stored_count:-0}"
        else
            echo "0"
        fi
    else
        echo "0"
    fi
}

# 更新休眠次数的函数
update_sleep_count() {
    local reason=$1
    local count=$2
    echo "REASON:$reason" > "$COUNTER_FILE"
    echo "COUNT:$count" >> "$COUNTER_FILE"
    echo "LAST_UPDATE:$(date '+%Y-%m-%d %H:%M:%S')" >> "$COUNTER_FILE"
}

# 重置休眠次数的函数
reset_sleep_count() {
    if [[ -f "$COUNTER_FILE" ]]; then
        rm "$COUNTER_FILE"
    fi
}

echo "开始监控电池电量..."
echo "充电目标电量: ${HIGH_PERCENTAGE}%"
echo "低电量保护: ${LOW_PERCENTAGE}%"
echo "检查间隔: ${CHECK_INTERVAL}秒"
echo "最大强制休眠次数: ${MAX_SLEEP_TIMES}次"
echo "按 Ctrl+C 停止监控"
echo ""

while true; do
    # 获取当前电池电量百分比
    CURRENT_BATTERY=$(pmset -g batt | grep -o '[0-9]\+%' | head -n 1 | sed 's/%//')
    
    # 检查是否正在充电
    CHARGING_STATUS=$(pmset -g batt | grep -o "charging\|discharging\|charged")
    
    # 获取当前时间
    CURRENT_TIME=$(date "+%Y-%m-%d %H:%M:%S")
    
    echo "[$CURRENT_TIME] 当前电量: ${CURRENT_BATTERY}%, 状态: $CHARGING_STATUS"
    
    SHOULD_SLEEP=false
    SLEEP_REASON=""
    
    # 检查是否需要重置计数器（电量回到正常范围）
    if [[ "$CHARGING_STATUS" == "charging" && "$CURRENT_BATTERY" -lt "$HIGH_PERCENTAGE" ]]; then
        # 充电中但电量低于阈值，重置高电量计数器
        if [[ -f "$COUNTER_FILE" ]]; then
            local stored_reason=$(grep "REASON:" "$COUNTER_FILE" | cut -d: -f2)
            if [[ "$stored_reason" == "HIGH_BATTERY" ]]; then
                reset_sleep_count
                echo "✅ 电量低于${HIGH_PERCENTAGE}%，已重置高电量休眠计数器"
            fi
        fi
    elif [[ "$CHARGING_STATUS" == "discharging" && "$CURRENT_BATTERY" -gt "$LOW_PERCENTAGE" ]]; then
        # 放电中但电量高于阈值，重置低电量计数器
        if [[ -f "$COUNTER_FILE" ]]; then
            local stored_reason=$(grep "REASON:" "$COUNTER_FILE" | cut -d: -f2)
            if [[ "$stored_reason" == "LOW_BATTERY" ]]; then
                reset_sleep_count
                echo "✅ 电量高于${LOW_PERCENTAGE}%，已重置低电量休眠计数器"
            fi
        fi
    fi
    
    # 检查充电时高电量情况
    if [[ "$CHARGING_STATUS" == "charging" && "$CURRENT_BATTERY" -ge "$HIGH_PERCENTAGE" ]]; then
        SHOULD_SLEEP=true
        SLEEP_REASON="HIGH_BATTERY"
        
        # 获取当前休眠次数
        SLEEP_COUNT=$(get_sleep_count "$SLEEP_REASON")
        
        echo ""
        echo "🔋 电池已充电至 ${CURRENT_BATTERY}%，达到目标电量 ${HIGH_PERCENTAGE}%"
        echo "📊 已休眠次数: ${SLEEP_COUNT}/${MAX_SLEEP_TIMES}"
        
        if [[ "$SLEEP_COUNT" -lt "$MAX_SLEEP_TIMES" ]]; then
            echo "💤 正在让电脑进入休眠模式...（第 $((SLEEP_COUNT + 1)) 次）"
            # 发送系统通知
            osascript -e "display notification \"电池已充至${CURRENT_BATTERY}%，电脑即将休眠（第$((SLEEP_COUNT + 1))次）\" with title \"电池监控 - 充电完成\" sound name \"Glass\""
        else
            echo "🔔 已达到最大休眠次数，仅发送提醒（不强制休眠）"
            SHOULD_SLEEP=false
            # 发送提醒通知
            osascript -e "display notification \"电池已充至${CURRENT_BATTERY}%，建议拔掉充电器\" with title \"电池监控 - 充电完成提醒\" sound name \"Glass\""
        fi
    fi
    
    # 检查放电时低电量情况
    if [[ "$CHARGING_STATUS" == "discharging" && "$CURRENT_BATTERY" -le "$LOW_PERCENTAGE" ]]; then
        SHOULD_SLEEP=true
        SLEEP_REASON="LOW_BATTERY"
        
        # 获取当前休眠次数
        SLEEP_COUNT=$(get_sleep_count "$SLEEP_REASON")
        
        echo ""
        echo "⚠️  电池电量已降至 ${CURRENT_BATTERY}%，低于保护阈值 ${LOW_PERCENTAGE}%"
        echo "📊 已休眠次数: ${SLEEP_COUNT}/${MAX_SLEEP_TIMES}"
        
        if [[ "$SLEEP_COUNT" -lt "$MAX_SLEEP_TIMES" ]]; then
            echo "💤 正在让电脑进入休眠模式以保护电池...（第 $((SLEEP_COUNT + 1)) 次）"
            # 发送系统通知
            osascript -e "display notification \"电量仅剩${CURRENT_BATTERY}%，电脑即将休眠保护电池（第$((SLEEP_COUNT + 1))次）\" with title \"电池监控 - 低电量保护\" sound name \"Basso\""
        else
            echo "🔔 已达到最大休眠次数，仅发送提醒（不强制休眠）"
            SHOULD_SLEEP=false
            # 发送提醒通知
            osascript -e "display notification \"电量仅剩${CURRENT_BATTERY}%，建议连接充电器\" with title \"电池监控 - 低电量提醒\" sound name \"Basso\""
        fi
    fi
    
    # 如果需要休眠，执行休眠逻辑
    if [[ "$SHOULD_SLEEP" == true ]]; then
        # 更新休眠次数计数器
        SLEEP_COUNT=$(get_sleep_count "$SLEEP_REASON")
        NEW_COUNT=$((SLEEP_COUNT + 1))
        update_sleep_count "$SLEEP_REASON" "$NEW_COUNT"
        
        # 记录休眠信息到日志文件
        echo "SLEEP_TIME:$(date '+%Y-%m-%d %H:%M:%S')" > "$LOG_FILE"
        echo "BATTERY_LEVEL:${CURRENT_BATTERY}" >> "$LOG_FILE"
        echo "HIGH_THRESHOLD:${HIGH_PERCENTAGE}" >> "$LOG_FILE"
        echo "LOW_THRESHOLD:${LOW_PERCENTAGE}" >> "$LOG_FILE"
        echo "SLEEP_REASON:${SLEEP_REASON}" >> "$LOG_FILE"
        echo "CHARGING_STATUS:${CHARGING_STATUS}" >> "$LOG_FILE"
        echo "SLEEP_COUNT:${NEW_COUNT}" >> "$LOG_FILE"
        
        # 创建简单的提醒文件，包含休眠信息
        echo "💤 电脑已从休眠中唤醒！" > "$HOME/.battery_wakeup_message"
        echo "" >> "$HOME/.battery_wakeup_message"
        echo "📅 休眠时间: $(date '+%Y-%m-%d %H:%M:%S')" >> "$HOME/.battery_wakeup_message"
        if [[ "$SLEEP_REASON" == "HIGH_BATTERY" ]]; then
            echo "🔋 休眠原因: 充电完成 (达到${HIGH_PERCENTAGE}%)" >> "$HOME/.battery_wakeup_message"
        else
            echo "⚠️ 休眠原因: 低电量保护 (低于${LOW_PERCENTAGE}%)" >> "$HOME/.battery_wakeup_message"
        fi
        echo "🔋 休眠时电量: ${CURRENT_BATTERY}%" >> "$HOME/.battery_wakeup_message"
        echo "📊 充电状态: $CHARGING_STATUS" >> "$HOME/.battery_wakeup_message"
        echo "🔢 已休眠次数: ${NEW_COUNT}/${MAX_SLEEP_TIMES}" >> "$HOME/.battery_wakeup_message"
        if [[ "$NEW_COUNT" -ge "$MAX_SLEEP_TIMES" ]]; then
            echo "" >> "$HOME/.battery_wakeup_message"
            echo "⚠️ 提示: 已达到最大休眠次数，后续将仅提醒不强制休眠" >> "$HOME/.battery_wakeup_message"
        fi
        
        # 创建简单的提醒脚本，在用户登录后运行
        echo '#!/bin/bash' > "$HOME/.battery_show_wakeup.sh"
        echo 'if [[ -f "$HOME/.battery_wakeup_message" ]]; then' >> "$HOME/.battery_show_wakeup.sh"
        echo '  sleep 3  # 等待系统完全启动' >> "$HOME/.battery_show_wakeup.sh"
        echo '  MESSAGE=$(cat "$HOME/.battery_wakeup_message")' >> "$HOME/.battery_show_wakeup.sh"
        echo '  osascript -e "display dialog \"$MESSAGE\" with title \"电池监控提醒\" buttons {\"知道了\"} default button \"知道了\""' >> "$HOME/.battery_show_wakeup.sh"
        echo '  rm "$HOME/.battery_wakeup_message"' >> "$HOME/.battery_show_wakeup.sh"
        echo '  rm "$HOME/.battery_show_wakeup.sh"' >> "$HOME/.battery_show_wakeup.sh"
        echo 'fi' >> "$HOME/.battery_show_wakeup.sh"
        chmod +x "$HOME/.battery_show_wakeup.sh"
        
        # 等待3秒后休眠
        sleep 3
        pmset sleepnow
        break
    fi
    
    # 等待指定时间后再次检查
    sleep $CHECK_INTERVAL
done