#!/bin/sh
echo
echo ===== 获取高权限...
sudo echo 提权成功!
cd ../
echo
echo ===== 更新软件源...
sudo apt update
sudo apt upgrade -y
echo
echo ===== 安装解释器...
sudo apt install -y lua5.4 python3 python3-pip pipx
echo
echo ===== 安装依赖项...
sudo apt install -y coreutils curl squashfs-tools mtd-utils
pipx install jefferson
echo
echo ===== 设置可执行...
sudo chmod +x *-mtd
sudo chmod +x *-image
echo
echo ===== 环境配置完成!
read -p "按ENTER键退出..." any_key
exit
