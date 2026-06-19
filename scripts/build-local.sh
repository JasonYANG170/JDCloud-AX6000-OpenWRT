#!/bin/bash
# ============================================================
# build-local.sh - 本地构建 ImmortalWrt for JDCloud RE-CP-03
#
# 用法：
#   ./scripts/build-local.sh                  # 默认构建
#   ./scripts/build-local.sh --clean          # 清理后重新构建
#   ./scripts/build-local.sh --menuconfig     # 打开菜单配置
#   ./scripts/build-local.sh --tag v24.10.0   # 指定版本 tag
# ============================================================

set -e

# ---------- 配置区 ----------
REPO_URL="https://github.com/immortalwrt/immortalwrt.git"
REPO_BRANCH="openwrt-24.10"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
OPENWRT_DIR="$PROJECT_DIR/openwrt"
CONFIG_FILE="$PROJECT_DIR/configs/jdcloud-recp03.seed"
JOBS=$(nproc 2>/dev/null || echo 4)

# ---------- 参数解析 ----------
CLEAN=false
MENUCONFIG=false
TAG=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --clean)       CLEAN=true; shift ;;
        --menuconfig)  MENUCONFIG=true; shift ;;
        --tag)         TAG="$2"; shift 2 ;;
        --help|-h)
            echo "Usage: $0 [--clean] [--menuconfig] [--tag <branch_or_tag>]"
            exit 0
            ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

BRANCH="${TAG:-$REPO_BRANCH}"

# ---------- 检查系统依赖 ----------
check_deps() {
    echo "[*] Checking build dependencies..."
    local missing=()
    for cmd in git make gcc g++ python3; do
        command -v $cmd >/dev/null 2>&1 || missing+=("$cmd")
    done
    if [ ${#missing[@]} -gt 0 ]; then
        echo "[!] Missing dependencies: ${missing[*]}"
        echo "[!] Run: sudo apt-get install build-essential git python3"
        exit 1
    fi
    echo "[+] Dependencies OK."
}

# ---------- 检查/安装 Ubuntu 依赖 ----------
install_deps_ubuntu() {
    if [ -f /etc/debian_version ]; then
        echo "[*] Installing Ubuntu/Debian build dependencies..."
        sudo apt-get update
        sudo apt-get install -y ack antlr3 asciidoc autoconf automake autopoint \
            binutils bison build-essential bzip2 ccache clang cmake cpio curl \
            device-tree-compiler ecj fastjar flex gawk gettext gcc-multilib \
            g++-multilib git gnutls-dev gperf haveged help2man intltool jq \
            lib32gcc-s1 libc6-dev-i386 libfuse-dev libglib2.0-dev libgmp3-dev \
            libltdl-dev libmpc-dev libmpfr-dev libncurses5-dev libncursesw5-dev \
            libpython3-dev libreadline-dev libssl-dev libtool llvm lrzsz msmtp \
            nano ninja-build p7zip p7zip-full patch pkgconf python3 python3-pip \
            python3-ply python3-pyelftools python3-setuptools qemu-utils rsync \
            scons squashfs-tools subversion swig texinfo uglifyjs unzip vim wget \
            xmlto xxd zlib1g-dev 2>/dev/null
        echo "[+] Ubuntu deps installed."
    else
        echo "[!] Non-Debian system detected. Please install dependencies manually."
        echo "    See: https://openwrt.org/docs/guide-developer/toolchain/install-buildsystem"
    fi
}

# ---------- 克隆源码 ----------
clone_source() {
    if [ -d "$OPENWRT_DIR/.git" ]; then
        echo "[*] Source already exists at $OPENWRT_DIR"
        echo "[*] Current branch: $(cd $OPENWRT_DIR && git branch --show-current)"
        return
    fi
    echo "[*] Cloning ImmortalWrt ($BRANCH)..."
    rm -rf "$OPENWRT_DIR"
    git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$OPENWRT_DIR"
    echo "[+] Source cloned."
}

# ---------- 主流程 ----------
main() {
    echo "============================================"
    echo "  ImmortalWrt Build - JDCloud RE-CP-03"
    echo "  Branch: $BRANCH"
    echo "  Jobs:   $JOBS"
    echo "============================================"

    # 清理
    if [ "$CLEAN" = true ]; then
        echo "[*] Cleaning build directory..."
        rm -rf "$OPENWRT_DIR"
        echo "[+] Cleaned."
    fi

    # 依赖检查
    check_deps

    # 克隆源码
    clone_source

    # 复制自定义 feeds
    if [ -f "$PROJECT_DIR/feeds.conf.default" ]; then
        cp "$PROJECT_DIR/feeds.conf.default" "$OPENWRT_DIR/feeds.conf.default"
        echo "[+] Custom feeds.conf.default applied."
    fi

    # 更新 feeds
    echo "[*] Updating feeds..."
    cd "$OPENWRT_DIR"
    ./scripts/feeds update -a
    ./scripts/feeds install -a
    echo "[+] Feeds updated and installed."

    # DIY Part 1
    if [ -f "$PROJECT_DIR/diy-part1.sh" ]; then
        echo "[*] Running diy-part1.sh..."
        chmod +x "$PROJECT_DIR/diy-part1.sh"
        cd "$PROJECT_DIR"
        OPENWRT_DIR="$OPENWRT_DIR" GITHUB_WORKSPACE="$PROJECT_DIR" bash ./diy-part1.sh
        cd "$OPENWRT_DIR"
    fi

    # 复制 seed config
    if [ -f "$CONFIG_FILE" ]; then
        cp "$CONFIG_FILE" "$OPENWRT_DIR/.config"
        echo "[+] Seed config applied: $CONFIG_FILE"
    else
        echo "[!] No config file found at $CONFIG_FILE"
        echo "[!] Generating default config..."
    fi

    # 菜单配置（可选）
    if [ "$MENUCONFIG" = true ]; then
        echo "[*] Opening menuconfig..."
        make menuconfig
        echo "[+] Config saved."
    fi

    # defconfig
    make defconfig

    # DIY Part 2
    if [ -f "$PROJECT_DIR/diy-part2.sh" ]; then
        echo "[*] Running diy-part2.sh..."
        chmod +x "$PROJECT_DIR/diy-part2.sh"
        cd "$PROJECT_DIR"
        OPENWRT_DIR="$OPENWRT_DIR" GITHUB_WORKSPACE="$PROJECT_DIR" bash ./diy-part2.sh
        cd "$OPENWRT_DIR"
    fi

    # 下载源码包
    echo "[*] Downloading source packages..."
    make download -j"$JOBS"

    # 编译
    echo "[*] Starting compile with $JOBS threads..."
    echo "[*] This will take a LONG time (30-120 min depending on hardware)..."
    echo "============================================"
    make -j"$JOBS" || make -j1 V=s

    # 完成
    echo "============================================"
    echo "  Build Complete!"
    echo "============================================"
    echo ""
    echo "  Firmware files:"
    ls -lh "$OPENWRT_DIR/bin/targets/"*/*/*.bin 2>/dev/null || echo "  (check bin/targets/ for output)"
    echo ""
    echo "  Output directory:"
    echo "  $OPENWRT_DIR/bin/targets/mediatek/filogic/"
    echo ""
}

main "$@"
