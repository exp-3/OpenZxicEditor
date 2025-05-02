#!/bin/bash

# OpenZxicEditor
# 版权所有 (C) 2024 MiFi~Lab & OpenZxicEditor Developers.

# 本程序是自由软件：您可以基于自由软件基金会发布的GNU Affero通用公共许可证的条款下重新分发和/或修改它，或者本许可证第三版或者（由您选择）任何后续版本。
# 分发本程序是希望它能派上用场，但没有任何担保，甚至也没有对其适销性或特定目的适用性的默示担保。更多细节请参见“GNU Affero通用公共许可证”。
# 您应该已收到本程序随附的GNU Affero通用公共许可证的副本。如未收到，请参见：http://www.gnu.org/licenses/ 。

echo ===== 检查路径...
if [ -f ./installers/install_apt.sh ]; then
    echo 很好，无需切换目录。
elif [ -f ./install_apt.sh ]; then
    cd ../
    echo 已经找到了项目路径并成功切换。
else
    # 不知道运行在什么鬼地方，退出安装
    echo "当前运行路径错误！请在OpenZxicEditor的所在目录下运行此安装脚本！"
    exit 1
fi
echo

echo ===== 提升权限...
sudo echo 已成功获取ROOT权限!
echo

echo ===== 刷新仓库...
sudo apt update
sudo apt upgrade -y
echo

echo ===== 准备环境...
sudo apt install -y lua5.4 python3 python3-pip pipx
sudo apt autoclean
echo

echo ===== 安装依赖...
sudo apt install -y coreutils curl squashfs-tools mtd-utils
pipx reinstall jefferson
pipx install jefferson
pipx ensurepath
echo

echo ===== 设置属性...
sudo chmod +x diffindo
echo

echo ===== 安装完成!
read -p "按ENTER键退出..." any_key
clear
exit
