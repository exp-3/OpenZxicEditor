#!/bin/sh
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
