#!/usr/bin/env python3
# pylint: disable=line-too-long
# Copyright (C) 2022-2025 The CWHelper-SOURCE Project
#
# Licensed under the GNU AFFERO GENERAL PUBLIC LICENSE, Version 3.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      https://www.gnu.org/licenses/agpl-3.0.en.html#license-text
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
import os
from .utils import fill, call
import re
import json


def repack(mtd, type_, erase, size):
    if os.path.exists(mtd + "_new"):
        os.remove(mtd + "_new")
    print("=====================================")
    if type_ == "squashfs":
        print("获取原文件参数信息：")
        _, info = call(["unsquashfs", "-s", mtd], out=1, return_output=True)
        comp = 'xz'
        block = '262144'
        filter_ = 'armthumb'
        dict_size = block
        for i in info:
            if re.match("Compression (\\w+)", i):
                comp = re.match("Compression (\\w+)", i).group(1)
            if re.match("Block size (\\d+)", i):
                block = re.match("Block size (\\d+)", "Block size 262144").group(1)
            if re.match(".*ilters selected. (\\w+)", i):
                filter_ = re.match(".*ilters selected. (\\w+)", i).group(1)
            if re.match(".*ictionary size.? (\\d+)", i):
                dict_size = re.match(".*ictionary size.? (\\d+)", i).group(1)
        print("压缩方式：", comp, "，块大小：", block, "，过滤器：", filter_,
              "，字典大小：", dict_size)
        call(['mksquashfs',
              mtd + "_unpacked",
              mtd + "_new",
              '-comp', comp, '-noappend', '-b', block, '-no-xattrs', '-always-use-fragments', '-all-root', '-Xbcj',
              filter_, '-Xdict-size', dict_size])
        print("已打包squashfs分区：", mtd)
    elif type_ == "jffs2":
        ret, output = call(['mkfs.jffs2', '-d', mtd + "_unpacked", '-o', mtd + "_new", '-X', 'lzo', '--pagesize=0x1000',
                            f'--eraseblock={erase}', '-l', '-n', '-q', '-v'], out=1, return_output=True)
        if ret:
            print("错误：打包jffs2分区", mtd, "时似乎出现了一些问题\n", "\n".join(output))
        print("已打包jffs2分区：", mtd)
    else:
        print("已跳过", type_, "分区：", mtd)
    if os.path.exists(mtd + "_new"):
        new_size = os.path.getsize(mtd + "_new")
        print("打包后大小", new_size, "，分区大小：", size)
        if new_size > size:
            print("错误：打包后文件大小超出分区大小！")
            print("分区最大尺寸：", size, "，打包后大小：", new_size)
            print("请重新调整需要打包的文件，减小体积以避免尺寸过大")
            os.remove(mtd + "_new")
            return 1
        if new_size < size:
            print("填充空字节：", size - new_size)
            fill(mtd + "_new", size)
    return None


def main(file_path=None):
    if file_path is None:
        file_path = "MTDs/"
    if not os.path.exists(file_path + "/partitions.json"):
        print("无法识别工程文件夹，请检查：", file_path)
        return 1
    print("开始打包...")
    with open(file_path + "/partitions.json", 'r', encoding='utf-8') as f:
        partitions = json.load(f)
    for partition in partitions:
        target_file = file_path + "/" + partition["file"]
        if os.path.isdir(target_file + "_unpacked"):
            repack(target_file, partition['fst'], partition["ebs"], partition['size'])
        else:
            print("已跳过分区：", target_file, "，未找到解包文件夹")
    print("=====================================")
    print("打包完成")
    return None
