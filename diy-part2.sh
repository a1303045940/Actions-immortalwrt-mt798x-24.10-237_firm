#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

# Modify default IP
#sed -i 's/192.168.1.1/192.168.50.5/g' package/base-files/files/bin/config_generate

# Modify default theme
#sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# Modify hostname
#sed -i 's/OpenWrt/P3TERX-Router/g' package/base-files/files/bin/config_generate
# Git稀疏克隆，只克隆指定目录到本地

function git_sparse_clone() {
  branch="$1" repourl="$2" && shift 2
  git clone --depth=1 -b $branch --single-branch --filter=blob:none --sparse $repourl
  repodir=$(echo $repourl | awk -F '/' '{print $(NF)}')
  cd $repodir && git sparse-checkout set $@
  mv -f $@ ../package
  cd .. && rm -rf $repodir
}

# theme
rm -rf feeds/luci/themes/luci-theme-argon
git clone https://github.com/jerrykuku/luci-theme-argon.git package/luci-theme-argon
git clone https://github.com/jerrykuku/luci-app-argon-config.git package/luci-app-argon-config

# passwall
rm -rf feeds/packages/net/{xray-core,v2ray-geodata,sing-box,chinadns-ng,dns2socks,hysteria,ipt2socks,microsocks,naiveproxy,shadowsocks-libev,shadowsocks-rust,shadowsocksr-libev,simple-obfs,tcping,trojan-plus,tuic-client,v2ray-plugin,xray-plugin,geoview,shadow-tls}
git clone https://github.com/xiaorouji/openwrt-passwall-packages package/passwall-packages

rm -rf feeds/luci/applications/luci-app-passwall
git clone https://github.com/xiaorouji/openwrt-passwall package/passwall-luci
# git clone https://github.com/xiaorouji/openwrt-passwall2 package/passwall2-luci

# ssr-plus
# rm -rf package/helloworld
# git clone --depth=1 https://github.com/fw876/helloworld.git package/helloworldd
# git -C package/helloworld pull

# mosdns
rm -rf feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b 25.x feeds/packages/lang/golang
rm -rf feeds/packages/net/mosdns
git clone https://github.com/sbwml/luci-app-mosdns -b v5 package/mosdns

# tailscale
sed -i '/\/etc\/init\.d\/tailscale/d;/\/etc\/config\/tailscale/d;' feeds/packages/net/tailscale/Makefile
git clone https://github.com/asvow/luci-app-tailscale package/luci-app-tailscale


# iStore
git_sparse_clone main https://github.com/linkease/istore-ui app-store-ui
git_sparse_clone main https://github.com/linkease/istore luci

# easytier
git clone -b optional-easytier-web --single-branch https://github.com/icyray/luci-app-easytier package/luci-app-easytier
sed -i 's/util.pcdata/xml.pcdata/g' package/luci-app-easytier/luci-app-easytier/luasrc/model/cbi/easytier.lua

# defconfig
# cp -f ../.config .config
# cp -f defconfig/mt7981-ax3000.config .config
sed -i 's|IMG_PREFIX:=|IMG_PREFIX:=$(shell TZ="Asia/Shanghai" date +"%Y%m%d")-24.10-6.6-|' include/image.mk

#cp "$GITHUB_WORKSPACE/r30b1/mt7981b-clt-r30b1.dts" target/linux/mediatek/dts/mt7981b-clt-r30b1.dts

cp -f "$GITHUB_WORKSPACE/dts/filogic.mk" "target/linux/mediatek/image/filogic.mk"
cp -f "$GITHUB_WORKSPACE/dts/mt7981b-ph-hy3000-emmc.dts" "target/linux/mediatek/dts/mt7981b-ph-hy3000-emmc.dts"
cp -f "$GITHUB_WORKSPACE/dts/mt7981b-bt-r320-emmc.dts" "target/linux/mediatek/dts/mt7981b-bt-r320-emmc.dts"
cp -f "$GITHUB_WORKSPACE/dts/mt7981b-sl-3000-emmc.dts" "target/linux/mediatek/dts/mt7981b-sl-3000-emmc.dts"
cp -f "$GITHUB_WORKSPACE/dts/02_network" "target/linux/mediatek/filogic/base-files/etc/board.d/02_network"

cp -f "$GITHUB_WORKSPACE/dts/01_leds" "target/linux/mediatek/filogic/base-files/etc/board.d/01_leds"
cp -f "$GITHUB_WORKSPACE/dts/npc/rc.local" "package/base-files/files/etc/rc.local"
chmod +x package/base-files/files/etc/rc.local
cp -f "$GITHUB_WORKSPACE/dts/npc/npc.conf" "package/base-files/files/etc/npc.conf"
chmod +x package/base-files/files/etc/npc.conf

echo "PH-HY3000和BT-R320 dts文件替换成功"
