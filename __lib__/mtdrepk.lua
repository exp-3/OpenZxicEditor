-- OpenZxicEditor
-- 版权所有 (C) 2024 ufiTech & OpenZxicEditor Developers. 
-- 
-- 本程序是自由软件：您可以基于自由软件基金会发布的GNU Affero通用公共许可证的条款下重新分发和/或修改它，或者本许可证第三版或者（由您选择）任何后续版本。    
-- 分发本程序是希望它能派上用场，但没有任何担保，甚至也没有对其适销性或特定目的适用性的默示担保。更多细节请参见“GNU Affero通用公共许可证”。    
-- 您应该已收到本程序随附的GNU Affero通用公共许可证的副本。如未收到，请参见：http://www.gnu.org/licenses/ 。
--
--
print("ufiStudio ZXIC MTD打包工具")
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
if f1 then
    pcall(function()
        f1:close()
    end)
else
    print("无法识别工程文件夹，请检查：", file_path)
    os.exit()
end

local log = function(msg)
    -- 初始化日志函数
end
local log_path = "__lib__/logs/"
local els = io.open("__lib__/--enable-log", "r")
if els then -- 检测是否存在--enable-log文件
    els:close()
    print("\r\n日志输出已启用。\r\n")
    os.execute("mkdir -p " .. log_path) -- 创建日志文件夹
    local log_file = string.format("%s%s_repk.log", log_path, os.time())
    log = function(msg)
        local f = io.open(log_file, "a")
        f:write(msg .. "\r\n")
        f:close()
    end
end

log(os.date("%Y-%m-%d %H:%M:%S") .. "\t开始...\r\n")

local printr = print
local function echo(msg)
    log("\r\n" .. msg .. "\r\n")
    printr(msg)
end
local print = echo

local function exec(cmd)
    local f = io.popen(cmd)
    local s = f:read("*a")
    f:close()
    return s
end

local fill = require("__lib__.fillend")

local function repack(mtd, type, erase, size)
    -- 删除可能存在的旧文件
    os.remove(mtd .. "_new")
    -- 打包
    log("=====================================")
    if type == "squashfs" then -- squashfs
        log("获取原文件参数信息：")
        log(exec(string.format("unsquashfs -s \"%s\"", mtd)))
        local cmd, comp, block, filter, dict
        -- 获取压缩方法
        cmd = string.format("unsquashfs -s \"%s\" | grep Compression", mtd)
        comp = exec(cmd)
        comp = comp:match("Compression (%w+)") or "xz"
        -- 获取块大小
        cmd = string.format("unsquashfs -s \"%s\" | grep Block", mtd)
        block = exec(cmd)
        block = block:match("Block size (%d+)") or "262144"
        -- 获取过滤器
        cmd = string.format("unsquashfs -s \"%s\" | grep \"Filters selected\"", mtd)
        filter = exec(cmd)
        filter = filter:match(".*ilters selected. (%w+)") or "armthumb"
        -- 获取字典大小
        cmd = string.format("unsquashfs -s \"%s\" | grep \"Dictionary size\"", mtd)
        dict = exec(cmd)
        dict = dict:match(".*ictionary size.? (%d+)") or block
        -- 测试结果输出
        log("压缩方式：" .. comp .. "，块大小：" .. block .. "，过滤器：" .. filter ..
                "，字典大小：" .. dict)
        cmd = string.format(
            "mksquashfs \"%s\" \"%s\" -comp %s -noappend -b %s -no-xattrs -always-use-fragments -all-root -Xbcj %s -Xdict-size %s",
            mtd .. "_unpacked", mtd .. "_new", comp, block, filter, dict)
        log(exec(cmd .. " 2>&1"))
        print("已打包squashfs分区：" .. mtd)
    elseif type == "jffs2" then -- jffs2
        local cmd = string.format("mkfs.jffs2 -d \"%s\" -o \"%s\" -X lzo --pagesize=0x800 --eraseblock=%s -l -n -q -v",
            mtd .. "_unpacked", mtd .. "_new", erase)
        log(exec(cmd .. " 2>err.tmp"))
        -- 读取错误输出内容
        local f = io.open("err.tmp", "r")
        local err = f:read("*a")
        f:close()
        os.remove("err.tmp")
        if err:find("error!") or err:find("error ") then -- 检测是否有错误
            print("错误：打包jffs2分区" .. mtd .. "时似乎出现了一些问题\n" .. err)
        end
        log(err)
        print("已打包jffs2分区：" .. mtd)
    else -- 其他
        print("已跳过" .. type .. "分区：" .. mtd)
    end
    -- 检查大小并填充
    local f = io.open(mtd .. "_new", "rb")
    if f then
        local new_size = f:seek("end")
        f:close()
        log("打包后大小：" .. new_size .. "，分区大小：" .. size)
        if new_size > size then
            print("错误：打包后文件大小超出分区大小！")
            print("分区最大尺寸：" .. size .. "，打包后大小：" .. new_size)
            print("请重新调整需要打包的文件，减小体积以避免尺寸过大")
            os.remove(mtd .. "_new")
            os.exit()
        end
        if new_size < size then
            log("填充空字节：" .. (size - new_size))
            fill(mtd .. "_new", size)
        end
    end
end

printr("开始打包...")

-- 读取分区表
local partition_data = {}
local jf = io.open(file_path .. "partitions.json", "r")
if jf then
    local json_str = jf:read("*a")
    partition_data = json.decode(json_str)
    jf:close()
end

-- 遍历分区表，打包各分区
for i, partition in ipairs(partition_data) do
    -- 找到对应文件
    local target_file = file_path .. partition.file
    -- 检测文件夹是否存在
    local f = exec("ls -d \"" .. target_file:gsub("\\", "/") .. "_unpacked\" 2>/dev/null")
    f = f:match("(.+)%s*$")
    if f then
        repack(target_file, partition.fst, partition.ebs, partition.size)
    else
        log("=====================================")
        print("已跳过分区：" .. target_file .. "，未找到解包文件夹")
    end
end

print("=====================================")
print("打包完成")
log(os.date("%Y-%m-%d %H:%M:%S") .. "\t结束。\r\n")
print(" ")
