#!/bin/bash

# OpenZxicEditor
# 版权所有 (C) 2024 MiFi~Lab & OpenZxicEditor Developers.

# 本程序是自由软件：您可以基于自由软件基金会发布的GNU Affero通用公共许可证的条款下重新分发和/或修改它，或者本许可证第三版或者（由您选择）任何后续版本。
# 分发本程序是希望它能派上用场，但没有任何担保，甚至也没有对其适销性或特定目的适用性的默示担保。更多细节请参见“GNU Affero通用公共许可证”。
# 您应该已收到本程序随附的GNU Affero通用公共许可证的副本。如未收到，请参见：http://www.gnu.org/licenses/ 。

get_script_dir() {
    local script_path="$0"
    if [ "${script_path:0:1}" != "/" ]; then
        script_path="$(command -v readlink >/dev/null 2>&1 && { readlink -f "$script_path" || :; } || { realpath "$script_path" || :; } || echo "$PWD/$script_path")"
    fi
    local script_dir="$(dirname "$script_path")"
    echo "$script_dir"
}
cd "$(get_script_dir)"
echo

echo ===== 获取根权限...
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
pipx reinstall jefferson
pipx install jefferson
echo

echo ===== 设置可执行...
sudo chmod +x *-mtd
sudo chmod +x *-image
echo

echo ===== 环境配置完成!
read -p "按ENTER键退出..." any_key
clear
exit
