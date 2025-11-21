file_path = "MTDs/"
from .utils import call
import json
from jefferson.jffs2 import extract_jffs2
from pathlib import Path


def unpack(mtd, type_, image_name):
    print("=====================================")
    if type_ == "squashfs":
        call(["unsquashfs", "-d", f"{mtd}_unpacked", mtd])
        print(f"已解包squashfs分区：{mtd}")
    elif type_ == 'jffs2':
        file = Path(mtd)
        dest = Path(f"{file_path}/{image_name}_unpacked")
        extract_jffs2(file, dest, verbose=False)
        print("已解包jffs2分区：", mtd)
    else:
        print("已忽略", type_, "分区：", mtd)


def main():
    print("开始解包...")
    with open(file_path + "/" + "partitions.json", 'r', encoding='utf-8') as f:
        partitions = json.load(f)
    for part in partitions:
        target_file = f"{file_path}/{part['file']}"
        unpack(target_file, part['fst'], part['file'])
