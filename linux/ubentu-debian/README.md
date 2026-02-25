## Fail2ban 智能诊断增强脚本 (全自动纠错版)

这是一个专为 **Ubuntu / Debian**（包括各类精简版、轻量版镜像）设计的 Fail2ban 一键部署脚本。它解决了轻量化系统中常见的日志缺失、后端无法启动等痛点，并内置了更严格的安全封禁策略。

### 🌟 核心特性

* **智能环境兼容**：自动识别 `systemd` 或 `auth.log` 日志来源，修复轻量版系统无法启动 Fail2ban 的常见坑点。
* **增强型封禁策略**：
* **常规防护**：5 次登录失败，直接封禁 **48 小时**。
* **惯犯防护**（Recidive）：24 小时内多次被封禁的 IP，自动封禁 **1 周**。


* **全自动部署**：一键完成依赖安装、环境诊断、配置写入及服务强力启动。

### 🚀 一键安装

在终端执行以下命令即可完成部署：

```bash
wget -O f2b_auto.sh "https://raw.githubusercontent.com/0x1233333/my-computer-script/refs/heads/main/linux/ubentu-debian/Fail2ban-%E6%99%BA%E8%83%BD%E8%AF%8A%E6%96%AD%E5%A2%9E%E5%BC%BA%E8%84%9A%E6%9C%AC.sh" && chmod +x f2b_auto.sh && ./f2b_auto.sh

```

---

