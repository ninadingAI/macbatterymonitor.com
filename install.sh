#!/bin/bash

# 🔋 MacBook 电池监控工具 - 自动安装脚本
# 作者: ninadingAI
# GitHub: https://github.com/ninadingAI/macbatterymonitor.com

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}🔋 MacBook 电池监控工具安装程序${NC}"
    echo -e "${BLUE}================================${NC}"
    echo
}

# 检查系统要求
check_requirements() {
    print_message "检查系统要求..."
    
    # 检查是否为 macOS
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_error "此工具仅支持 macOS 系统"
        exit 1
    fi
    
    # 检查是否有管理员权限（通过尝试创建系统目录）
    if ! sudo -n true 2>/dev/null; then
        print_warning "需要管理员权限来配置系统服务"
        print_message "安装过程中会要求输入密码"
    fi
    
    print_message "✅ 系统检查通过"
}

# 创建必要的目录
create_directories() {
    print_message "创建安装目录..."
    
    # 创建主目录
    mkdir -p ~/battery_monitor
    
    # 创建 LaunchAgents 目录（如果不存在）
    mkdir -p ~/Library/LaunchAgents
    
    print_message "✅ 目录创建完成"
}

# 复制文件
copy_files() {
    print_message "复制程序文件..."
    
    # 复制主脚本
    if [[ -f "battery_monitor.sh" ]]; then
        cp battery_monitor.sh ~/battery_monitor/
        chmod +x ~/battery_monitor/battery_monitor.sh
        print_message "✅ 主脚本已复制"
    else
        print_error "找不到 battery_monitor.sh 文件"
        exit 1
    fi
    
    # 复制 plist 文件
    if [[ -f "com.user.battery.monitor.plist" ]]; then
        cp com.user.battery.monitor.plist ~/Library/LaunchAgents/
        print_message "✅ 服务配置文件已复制"
    else
        print_error "找不到 com.user.battery.monitor.plist 文件"
        exit 1
    fi
    
    print_message "✅ 文件复制完成"
}

# 配置服务
configure_service() {
    print_message "配置系统服务..."
    
    # 获取当前用户名
    CURRENT_USER=$(whoami)
    
    # 替换 plist 文件中的用户名占位符
    sed -i '' "s/YOUR_USERNAME/$CURRENT_USER/g" ~/Library/LaunchAgents/com.user.battery.monitor.plist
    
    print_message "✅ 服务配置完成（用户: $CURRENT_USER）"
}

# 启动服务
start_service() {
    print_message "启动电池监控服务..."
    
    # 先尝试卸载可能存在的旧服务
    launchctl unload ~/Library/LaunchAgents/com.user.battery.monitor.plist 2>/dev/null || true
    
    # 加载新服务
    launchctl load ~/Library/LaunchAgents/com.user.battery.monitor.plist
    
    # 等待一下让服务启动
    sleep 2
    
    # 检查服务状态
    if launchctl list | grep -q "com.user.battery.monitor"; then
        print_message "✅ 服务启动成功"
    else
        print_warning "服务可能未正确启动，请手动检查"
    fi
}

# 创建日志文件
create_log_files() {
    print_message "初始化日志文件..."
    
    # 创建日志文件
    touch ~/battery_monitor/battery_monitor.log
    touch ~/battery_monitor/battery_monitor.error.log
    
    print_message "✅ 日志文件已创建"
}

# 显示安装结果
show_installation_result() {
    echo
    echo -e "${GREEN}🎉 安装完成！${NC}"
    echo
    echo -e "${BLUE}📋 安装信息：${NC}"
    echo "   • 程序目录: ~/battery_monitor/"
    echo "   • 配置文件: ~/Library/LaunchAgents/com.user.battery.monitor.plist"
    echo "   • 日志文件: ~/battery_monitor/battery_monitor.log"
    echo
    echo -e "${BLUE}🔧 常用命令：${NC}"
    echo "   • 查看服务状态: launchctl list | grep battery"
    echo "   • 停止服务: launchctl unload ~/Library/LaunchAgents/com.user.battery.monitor.plist"
    echo "   • 启动服务: launchctl load ~/Library/LaunchAgents/com.user.battery.monitor.plist"
    echo "   • 查看日志: tail -f ~/battery_monitor/battery_monitor.log"
    echo "   • 卸载工具: ./uninstall.sh"
    echo
    echo -e "${BLUE}⚙️ 默认配置：${NC}"
    echo "   • 高电量阈值: 75%"
    echo "   • 低电量阈值: 25%"
    echo "   • 最大休眠次数: 3次"
    echo "   • 检查间隔: 30秒"
    echo
    echo -e "${YELLOW}💡 提示：${NC}"
    echo "   • 工具会在后台自动运行"
    echo "   • 开机时会自动启动"
    echo "   • 可以通过修改 ~/battery_monitor/battery_monitor.sh 来自定义配置"
    echo
    echo -e "${BLUE}🌐 更多信息：${NC}"
    echo "   • 项目主页: https://ninadingAI.github.io/macbatterymonitor.com/"
    echo "   • GitHub: https://github.com/ninadingAI/macbatterymonitor.com"
    echo
}

# 主安装流程
main() {
    print_header
    
    check_requirements
    create_directories
    copy_files
    configure_service
    create_log_files
    start_service
    show_installation_result
    
    print_message "安装脚本执行完成！"
}

# 运行主函数
main "$@"
