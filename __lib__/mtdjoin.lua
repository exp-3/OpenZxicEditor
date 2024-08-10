-- OpenZxicEditor
-- 版权所有 (C) 2024 ufiTech & OpenZxicEditor Developers. 
-- 
-- 本程序是自由软件：您可以基于自由软件基金会发布的GNU Affero通用公共许可证的条款下重新分发和/或修改它，或者本许可证第三版或者（由您选择）任何后续版本。    
-- 分发本程序是希望它能派上用场，但没有任何担保，甚至也没有对其适销性或特定目的适用性的默示担保。更多细节请参见“GNU Affero通用公共许可证”。    
-- 您应该已收到本程序随附的GNU Affero通用公共许可证的副本。如未收到，请参见：http://www.gnu.org/licenses/ 。
--
--
print("ufiStudio ZXIC MTD合并工具")
print("版权所有 (C) 2024 ufiTech Developers. 保留所有权利。")
print("=====================================")

local json = require("__lib__.json")
local file_path
-- 获取输入文件路径
local args = {...}
if #args > 0 then
    file_path = args[1]
    if string.sub(file_path, -1) ~= "/" then
        file_path = file_path .. "/"
    end
else
    file_path = "MTDs/"
end
-- 检测工程文件夹是否存在
local f1 = io.open(file_path .. "/partitions.json", "r")
local f2 = io.open(file_path .. "/mtd0", "r")
if f1 or f2 then
    pcall(function()
        f1:close()
    end)
    pcall(function()
        f2:close()
    end)
else
    print("无法识别工程文件夹，请检查：", file_path)
    os.exit()
end

local file_out = file_path .. "full_new.bin"

local fill = require("__lib__.fillend")

-- 检测json文件是否存在
local f = io.open(file_path .. "partitions.json", "rb")
if f then -- 新版mtd分区文件格式
    f:close()
    print("检测到新版mtd集合格式")
    print("=====================================")

    -- 读取分区表
    local partition_data = {}
    local jf = io.open(file_path .. "partitions.json", "r")
    if jf then
        local json_str = jf:read("*a")
        partition_data = json.decode(json_str)
        jf:close()
    end
    -- 删除可能存在的旧文件
    os.remove(file_out)
    -- 遍历分区表，连接各分区
    for i, part in ipairs(partition_data) do
        -- 找到对应文件
        local src = file_path .. part.file .. "_new"
        -- 检测重打包文件是否存在
        local f = io.open(src, "rb")
        if f then
            f:close()
        else
            src = file_path .. part.file
        end
        -- 检查分区文件的大小是否正确
        local f = io.open(src, "rb")
        if f then
            local size = f:seek("end")
            f:close()
            if size < part.size then
                print("分区文件" .. src .. "太小，自动填充0xFF")
                fill(src, part.size)
            elseif size > part.size then
                print("检测到严重错误：")
                print("分区文件" .. src .. "太大，请检查")
                os.exit()
            end
        else
            print("检测到严重错误：")
            print("找不到分区" .. part.name .. "的相应文件，请检查")
            os.exit()
        end
        -- 连接分区
        if part.start % 1024 == 0 then -- 以KB为单位加速拷贝
            local seek = part.start / 1024
            os.execute(string.format("dd if=\"%s\" of=\"%s\" bs=1024 seek=%d conv=notrunc 2>/dev/null", src, file_out,
                seek))
        else -- 地址未对齐，需要逐个字节拷贝
            os.execute(string.format("dd if=\"%s\" of=\"%s\" bs=1 seek=%d conv=notrunc 2>/dev/null", src, file_out,
                part.start))
        end
        print("已导入分区：" .. src)
    end

else -- 旧版mtd分区文件格式
    file_out = file_path .. "merged-mtd.bin"
    print("检测到旧版mtd文件格式")
    print("=====================================")

    -- 创建新文件
    os.remove(file_out)
    os.remove("tmp")
    local f = io.open("tmp", "wb")
    f:close()
    -- 将mtd文件逐个连接
    local i = 0
    while true do
        local src = file_path .. "mtd" .. i
        src = src:gsub("\\", "/")
        local f = io.open(src, "rb")
        if not f then
            print("检测到" .. src .. "不存在，结束导入")
            break
        else
            f:close()
        end
        os.execute(string.format("cat \"%s\" >> \"%s\"", src, "tmp"))
        print("已导入分区：" .. src)
        i = i + 1
    end
    os.rename("tmp", file_out)
    os.remove("tmp")

end

print("=====================================")
print("导入完成")
print(" ")

