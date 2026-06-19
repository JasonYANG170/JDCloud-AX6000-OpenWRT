# 自定义包目录
#
# 将你的自定义 luci 应用 / ipk 包放在此目录下
# diy-part1.sh 会自动将此目录内容复制到 openwrt/package/custom/
#
# 目录结构示例：
#
# custom-packages/
# ├── luci-app-myplugin/
# │   ├── Makefile
# │   ├── htdocs/
# │   └── ...
# └── my-tool/
#     ├── Makefile
#     └── ...
#
# 每个子目录必须包含一个合法的 OpenWrt Makefile
#
# 常用第三方 luci 应用（可直接 git clone 到这里）：
#
#   # 高级设置
#   git clone https://github.com/sirpdboy/luci-app-advanced.git
#
#   # 网络唤醒增强
#   git clone https://github.com/sirpdboy/luci-app-netdata.git
#
#   # 定时任务
#   git clone https://github.com/sirpdboy/luci-app-cron.git
#
#   # 系统高级设置
#   git clone https://github.com/sirpdboy/luci-app-lucky.git
#
# 也可以直接下载 .ipk 文件，但推荐用 Makefile 方式编译
