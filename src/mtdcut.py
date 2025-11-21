import json
import os


def main(input_file):
    partition_table_offset = 0x2000
    erase_block = 0x8000
    partition_table_magic = b"vHY1WF7520"
    partitions = []
    output_mtd_dir = "MTDs"
    os.makedirs(output_mtd_dir, exist_ok=True)
    with open(input_file, "rb") as f:
        f.seek(partition_table_offset)
        if f.read(len(partition_table_magic)) != partition_table_magic:
            print("Partition table magic mismatch")
            return 1
        f.seek(partition_table_offset)
        f.read(32)
        i = 0
        while True:
            part_data = f.read(40)
            if b"\x64\x64\x72\x00\x00\x00\x00\x00" in part_data:
                break
            name = part_data[0:16].strip(b"\0").decode('utf-8')
            hwt = part_data[16:32].strip(b"\0").decode('utf-8')
            start = int.from_bytes(part_data[32:36], 'little')
            size = int.from_bytes(part_data[36:40], 'little')
            nps = 0
            if name == "zloader":
                erase_block = size
            part_info = {"size": size, "ebs": erase_block, "start": start, "file": f"{i}.{name}", "hwt":hwt, "nps":nps, "name":name, "index":i}
            partitions.append(part_info)
            i += 1
    for i, part in enumerate(partitions):
        start = part["start"]
        size = part["size"]
        output_file = output_mtd_dir + "/" + part["file"]
        print("Splitting to file: " + output_file)
        with open(output_file, "wb") as f_out, open(input_file, "rb") as f_in:
            f_in.seek(start)
            f_out.write(f_in.read(size))
        with open(output_file, "rb") as f:
            fs_type = f.read(4)
            if not fs_type:
                fst = 'empty'
                print("发现空分区：" , part['name'] , "，文件可能已损坏")
            elif fs_type in [b"sqsh", b'hsqs']:
                fst = "squashfs"
            elif fs_type.startswith(b"\x85\x19"):
                fst = "jffs2"
            elif fs_type == b"UBI#":
                fst = "ubifs"
            elif part["name"] in ["zloader", "uboot", "uboot-mirr"]:
                fst = "raw"
            partitions[i]["fst"] = fst
    print("全部分区切分完成")
    print("=====================================")
    with open(output_mtd_dir + "/partitions.json", "w", encoding='utf-8') as f:
        json.dump(partitions, f, ensure_ascii=False, indent=4)
    with open(output_mtd_dir + "/name.txt", "w", encoding='utf-8') as f:
        name = os.path.basename(input_file)
        if "." in name:
            name = os.path.splitext(name)[0]
        f.write(name)
        return None


if __name__ == "__main__":
    main(input("File path:"))