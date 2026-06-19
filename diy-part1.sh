#!/bin/bash
# ============================================================
# diy-part1.sh - feeds 安装之后、make defconfig 之前执行
# 用途：添加自定义包、修改 feeds、注入第三方 luci 应用
# ============================================================

set -e

OPENWRT_DIR="${OPENWRT_DIR:-openwrt}"
CUSTOM_PKG_DIR="$GITHUB_WORKSPACE/custom-packages"

echo "============================================"
echo " DIY Part 1: Pre-config customization"
echo "============================================"

# ---------- 1. 复制自定义包到 package 目录 ----------
if [ -d "$CUSTOM_PKG_DIR" ] && [ "$(ls -A $CUSTOM_PKG_DIR 2>/dev/null)" ]; then
    echo "[*] Copying custom packages..."
    mkdir -p "$OPENWRT_DIR/package/custom"
    cp -rf "$CUSTOM_PKG_DIR"/* "$OPENWRT_DIR/package/custom/"
    echo "[+] Custom packages copied."
else
    echo "[!] No custom packages found in $CUSTOM_PKG_DIR, skipping."
fi

# ---------- 2. 自定义默认 IP（取消注释修改 LAN IP）----------
# sed -i 's/192.168.1.1/192.168.68.1/g' "$OPENWRT_DIR/package/base-files/files/bin/config_generate"

# ---------- 3. 自定义主机名 ----------
# sed -i "s/hostname='OpenWrt'/hostname='JDCloud-RE-CP-03'/g" "$OPENWRT_DIR/package/base-files/files/bin/config_generate"

# ---------- 4. 修改默认 NTP 服务器（国内）----------
# sed -i 's/0.openwrt.pool.ntp.org/ntp.aliyun.com/g' "$OPENWRT_DIR/package/base-files/files/bin/config_generate"
# sed -i 's/1.openwrt.pool.ntp.org/cn.ntp.org.cn/g' "$OPENWRT_DIR/package/base-files/files/bin/config_generate"

# ---------- 5. 添加额外 luci 应用 ----------
# 示例：从 GitHub 克隆 luci-app
# git clone --depth 1 https://github.com/sirpdboy/luci-app-advanced.git "$OPENWRT_DIR/package/custom/luci-app-advanced"

echo "[+] DIY Part 1 done."
