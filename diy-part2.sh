#!/bin/bash
# ============================================================
# diy-part2.sh - make defconfig 之后、make 之前执行
# 用途：微调 .config、移除不需要的包、修复已知问题
# ============================================================

set -e

OPENWRT_DIR="${OPENWRT_DIR:-openwrt}"

echo "============================================"
echo " DIY Part 2: Post-config tweaks"
echo "============================================"

cd "$OPENWRT_DIR"

# ---------- 1. 确保目标设备正确 ----------
# RE-CP-03 使用 mediatek/filogic，profile 是 jdcloud_re-cp-03
echo "[*] Target: $(grep CONFIG_TARGET .config | head -5)"

# ---------- 2. 移除不需要的包（减少固件体积）----------
# 取消注释并修改来移除特定包
# sed -i 's/CONFIG_PACKAGE_luci-app-ssr-plus=y/# CONFIG_PACKAGE_luci-app-ssr-plus is not set/g' .config
# sed -i 's/CONFIG_PACKAGE_luci-app-passwall=y/# CONFIG_PACKAGE_luci-app-passwall is not set/g' .config

# ---------- 3. 调整内核参数 ----------
# RE-CP-03 有 1GB 内存，可以适当增大 conntrack
# sed -i 's/CONFIG_NF_CONNTRACK_HSIZE=16384/CONFIG_NF_CONNTRACK_HSIZE=32768/g' .config

# ---------- 4. 自定义固件版本标识 ----------
VER_TAG="$(date +%Y%m%d)-JDCloud-RE-CP-03"
# sed -i "s/CONFIG_VERSION_DIST=.*/CONFIG_VERSION_DIST=\"ImmortalWrt-$VER_TAG\"/g" .config
# sed -i 's/CONFIG_VERSION_CODE=.*/CONFIG_VERSION_CODE="'$VER_TAG'"/g' .config

# ---------- 5. 强制刷新 defconfig ----------
make defconfig

echo "[+] Config summary:"
grep -c '=y' .config | xargs -I{} echo "[*] Total packages enabled: {}"
echo "[+] DIY Part 2 done."
