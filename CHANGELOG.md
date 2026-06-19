# Changelog

## 1.0.0

### Added
- GitHub Actions 自动构建工作流
- 本地构建脚本 `scripts/build-local.sh`
- 设备 seed 配置 `configs/jdcloud-recp03.seed`
  - Argon 主题 + 配置
  - Docker 管理 (luci-app-dockerman)
  - 文件共享 (luci-app-samba4)
  - 磁盘管理 (luci-app-diskman)
  - 网络流量监控 (luci-app-nlbwmon)
  - 终端 (luci-app-ttyd)
  - DDNS、UPnP、网络唤醒、ZeroTier
- 文件系统支持：ext4、exFAT、NTFS3
- 无线驱动：MT7986A 固件 + wpad-openssl
- 自定义包目录 `custom-packages/`
- 首次启动初始化脚本 `files/etc/uci-defaults/99-custom-init`
- 自定义 feeds 配置 `feeds.conf.default`
- 构建前后处理脚本 `diy-part1.sh` / `diy-part2.sh`

### Notes
- 基于 ImmortalWrt openwrt-24.10 分支
- 默认禁用：IPv6、ssr-plus、passwall、openclash
- 自动清理 Actions 旧运行记录（保留 30 天 / 最新 5 次）
