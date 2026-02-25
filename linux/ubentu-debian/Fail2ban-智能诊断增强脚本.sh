#!/bin/bash

# ====================================================
# Fail2ban 智能诊断增强脚本 (全自动纠错版)
# 适用：Ubuntu/Debian 及其各种精简版、轻量版镜像
# 功能：5次错误封48小时，惯犯封1周，自动修复环境缺失
# ====================================================

# 1. 权限与环境预检
echo ">>> [1/6] 正在检查系统环境..."
if [ "$EUID" -ne 0 ]; then 
  echo "错误：请使用 sudo 或 root 用户运行此脚本！"
  exit 1
fi

# 2. 智能安装依赖
echo ">>> [2/6] 正在安装/更新必要组件..."
apt update -qq
# 安装 fail2ban 和用于读取系统日志的 python 插件
apt install fail2ban python3-systemd -y -qq

# 3. 自动修正“轻量版系统”常见坑点
echo ">>> [3/6] 正在执行自动诊断与修复..."

# 检查 1: 确保 fail2ban 日志文件存在（防止 recidive 监狱崩溃）
if [ ! -f /var/log/fail2ban.log ]; then
    touch /var/log/fail2ban.log
    echo "  - 已创建缺失的 fail2ban.log"
fi

# 检查 2: 诊断 SSH 日志来源
# 如果系统没有 auth.log，我们将强制使用 systemd 后端
BACKEND_TYPE="auto"
if [ ! -f /var/log/auth.log ]; then
    echo "  - 检测到系统无 auth.log，将自动启用 systemd 模式"
    BACKEND_TYPE="systemd"
fi

# 4. 写入增强型配置
echo ">>> [4/6] 正在写入安全策略配置..."
cat <<EOF > /etc/fail2ban/jail.local
[DEFAULT]
# 全局默认禁闭：48小时
bantime = 48h
findtime = 10m
maxretry = 5
# 自动选择最合适的后端(systemd 或 polling)
backend = $BACKEND_TYPE

[sshd]
enabled = true
port    = 22
filter  = sshd

[recidive]
enabled  = true
logpath  = /var/log/fail2ban.log
interval = 1d
# 惯犯封禁 1 周
bantime  = 1w
findtime = 1d
maxretry = 5
EOF

# 5. 暴力清理与强制启动
echo ">>> [5/6] 正在清理旧残留并启动服务..."
systemctl stop fail2ban >/dev/null 2>&1
rm -f /var/run/fail2ban/fail2ban.sock # 强力移除可能的锁死文件
systemctl daemon-reload
systemctl enable fail2ban -q
systemctl start fail2ban

# 6. 最终检测与结果反馈
echo ">>> [6/6] 部署完成，正在进行最终健康检查..."
sleep 3

# 检查进程是否存在
if systemctl is-active --quiet fail2ban; then
    echo "==============================================="
    echo "✅ 成功：Fail2ban 已在当前机器上成功部署！"
    echo "🛡️  防护状态：已开启 sshd (48h) 和 recidive (1w)"
    echo "-----------------------------------------------"
    fail2ban-client status
    echo "==============================================="
else
    echo "❌ 失败：Fail2ban 启动异常，请检查 journalctl -u fail2ban 报错信息。"
fi
