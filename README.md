# ImmortalWrt Build - JDCloud RE-CP-03

为京东云百里 (JDCloud RE-CP-03) 构建 ImmortalWrt 固件
## 设备信息

| 参数 | 规格 |
|------|------|
| SoC | MediaTek MT7986A (Filogic 830, 4x Cortex-A53) |
| RAM | 1GB DDR4 |
| Flash | 128GB eMMC |
| 以太网 | 4x 1GbE + 1x 2.5GbE (RTL8221B) |
| Target | mediatek/filogic |
| Profile | jdcloud_re-cp-03 |

## 目录结构

```
openwrt-AX6000/
├── .github/workflows/
│   └── build-openwrt.yml          # GitHub Actions 工作流
├── scripts/
│   └── build-local.sh             # 本地构建脚本
├── configs/
│   └── jdcloud-recp03.seed        # 设备 seed 配置（核心！）
├── custom-packages/               # 自定义包目录
│   └── README.md
├── files/                         # 自定义文件（直接拷贝到固件）
│   └── etc/uci-defaults/
│       └── 99-custom-init         # 首次启动初始化脚本
├── feeds.conf.default             # 自定义 feeds 源
├── diy-part1.sh                   # 预处理脚本（feeds 之后，defconfig 之前）
└── diy-part2.sh                   # 后处理脚本（defconfig 之后，make 之前）
```

## 快速开始

### 方式一：GitHub Actions 构建

1. Fork 本仓库到你的 GitHub 账号
2. 进入 Actions 页面，选择 "Build ImmortalWrt for JDCloud RE-CP-03"
3. 点击 "Run workflow"，选择参数：
   - `openwrt_tag`: 版本分支，默认 `openwrt-24.10`
   - `upload_firmware`: 是否上传到 Release
   - `ssh`: 开启 SSH 调试（可选）
4. 等待构建完成（约 2-3 小时）
5. 在 Artifacts 或 Releases 中下载固件

### 方式二：本地构建

**环境要求**：Ubuntu 20.04+ (原生或 WSL2)，推荐 16GB+ 内存，50GB+ 磁盘

```bash
# 克隆本仓库
git clone https://github.com/YOUR_USERNAME/openwrt-AX6000.git
cd openwrt-AX6000

# 安装依赖 + 开始构建
bash scripts/build-local.sh

# 带菜单配置
bash scripts/build-local.sh --menuconfig

# 清理后重新构建
bash scripts/build-local.sh --clean

# 指定版本
bash scripts/build-local.sh --tag v24.10.0
```

构建完成后固件位于：
```
openwrt/bin/targets/mediatek/filogic/
```

## 自定义配置

### 修改软件包

编辑 `configs/jdcloud-recp03.seed`，格式为 `CONFIG_PACKAGE_xxx=y` 或 `CONFIG_PACKAGE_xxx=n`。

快速查看所有可用包：
```bash
cd openwrt && make menuconfig
```

### 添加自定义包

1. 将你的包（含 Makefile）放入 `custom-packages/` 目录
2. 或者在 `diy-part1.sh` 中添加 `git clone` 命令

### 修改默认配置

编辑 `files/etc/uci-defaults/99-custom-init`，该脚本在首次启动时自动执行。

### 添加第三方 feeds

编辑 `feeds.conf.default`，取消注释你需要的源。

## 刷机方法

1. 下载官方迁移固件：`openwrt-mediatek-mt7986-jdcloud_re-cp-03-vendor-migration.bin`
2. 通过原厂固件 Web 页面或第三方UBOOT刷入迁移固件
3. 再通过 ImmortalWrt 的 sysupgrade 页面刷入编译的固件

默认 IP：`192.168.1.1`（如已修改见 UCI defaults）

## 常见问题

**Q: 构建要多久？**
A: 首次构建约 2-4 小时（取决于 CPU 性能），增量构建约 15-30 分钟。

**Q: Actions 构建超时怎么办？**
A: GitHub Actions 限制 6 小时，正常 ImmortalWrt 构建约 2-3 小时，足够。

**Q: 如何减少固件体积？**
A: 在 seed 文件中用 `=n` 禁用不需要的包，或移除 Docker 相关配置。

**Q: 无线不工作？**
A: 确认 `kmod-mt7986-firmware` 和 `wpad-openssl` 已启用。RE-CP-03 的无线是 SoC 内置的。

## License

MIT
