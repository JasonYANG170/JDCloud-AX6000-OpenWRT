#!/bin/bash
# upload-toolchains.sh - 上传工具链和根文件系统到 GitHub Release
#
# 用法:
#   ./scripts/upload-toolchains.sh                    # 默认路径
#   ./scripts/upload-toolchains.sh /path/to/longan    # 自定义路径
#
# 前提: 已安装 gh CLI 且已登录 (gh auth login)

set -e

REPO="JasonYANG170/Mini-LinuxPC-Pro"
RELEASE_TAG="toolchains"
RELEASE_NAME="Build Toolchains & Rootfs"
SDK_DIR="${1:-/d/BaiduNetdiskDownload/DS-H618/系统源码/Ubuntu22.04 SDK/longan-h618}"
TOOLCHAIN_DIR="$SDK_DIR/build/toolchain"
ROOTFILE_DIR="$SDK_DIR/rootfile"

echo "============================================"
echo "  Upload Toolchains & Rootfs to GitHub Release"
echo "============================================"
echo "  Repo: $REPO"
echo "  SDK: $SDK_DIR"
echo ""

# 检查 gh CLI
if ! command -v gh &> /dev/null; then
    echo "[!] gh CLI not found. Install: https://cli.github.com/"
    exit 1
fi

# 创建或获取 Release
echo "[*] Checking release '$RELEASE_TAG'..."
if gh release view "$RELEASE_TAG" --repo "$REPO" &>/dev/null; then
    echo "[+] Release exists."
else
    echo "[*] Creating release..."
    gh release create "$RELEASE_TAG" --repo "$REPO" \
        --title "$RELEASE_NAME" \
        --notes "Build toolchains and rootfs for Longan H618 SDK. Downloaded by CI." \
        --prerelease
fi

# 上传工具链
echo ""
echo "[*] Uploading toolchain files..."
for f in "$TOOLCHAIN_DIR"/*.tar.xz "$TOOLCHAIN_DIR"/*.tar.bz2; do
    if [ -f "$f" ] && [ $(stat -c%s "$f") -gt 1000 ]; then
        filename=$(basename "$f")
        size=$(du -h "$f" | cut -f1)
        echo "  $filename ($size)"
        gh release upload "$RELEASE_TAG" "$f" --repo "$REPO" --clobber
    fi
done

# 上传根文件系统
echo ""
echo "[*] Uploading rootfs files..."
for f in "$ROOTFILE_DIR"/*.tar.gz "$ROOTFILE_DIR"/*.tar; do
    if [ -f "$f" ] && [ $(stat -c%s "$f") -gt 1000 ]; then
        filename=$(basename "$f")
        size=$(du -h "$f" | cut -f1)
        echo "  $filename ($size)"
        gh release upload "$RELEASE_TAG" "$f" --repo "$REPO" --clobber
    fi
done

echo ""
echo "[+] Done!"
echo "    https://github.com/$REPO/releases/tag/$RELEASE_TAG"
echo ""
echo "Files uploaded:"
gh release view "$RELEASE_TAG" --repo "$REPO" --json assets -q '.assets[] | "  \(.name) (\(.size / 1048576 | floor)MB)"'
