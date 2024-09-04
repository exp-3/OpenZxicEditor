-- OpenZxicEditor
-- 版权所有 (C) 2024 MiFi~Lab & OpenZxicEditor Developers. 
-- 
-- 本程序是自由软件：您可以基于自由软件基金会发布的GNU Affero通用公共许可证的条款下重新分发和/或修改它，或者本许可证第三版或者（由您选择）任何后续版本。    
-- 分发本程序是希望它能派上用场，但没有任何担保，甚至也没有对其适销性或特定目的适用性的默示担保。更多细节请参见“GNU Affero通用公共许可证”。    
-- 您应该已收到本程序随附的GNU Affero通用公共许可证的副本。如未收到，请参见：http://www.gnu.org/licenses/ 。
--
--
print("ufiStudio ZXIC MTD解包工具")
print("版权所有 (C) 2024 MiFi~Lab Developers. 保留所有权利。")
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

local log = function(msg)
    -- 初始化日志函数
end
local log_path = "__lib__/logs/"
local els = io.open("__lib__/--enable-log", "r")
if els then -- 检测是否存在--enable-log文件
    els:close()
    print("\r\n日志输出已启用。\r\n")
    os.execute("mkdir -p " .. log_path) -- 创建日志文件夹
    local log_file = string.format("%s%s_unpk.log", log_path, os.time())
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

local function unpack(mtd, type, imageName)
    log("=====================================")
    if type == "squashfs" then -- squashfs
        local cmd = string.format("unsquashfs -d \"%s\" \"%s\"", mtd .. "_unpacked", mtd)
        log(exec(cmd))
        print("已解包squashfs分区：" .. mtd)
    elseif type == "jffs2" then -- jffs2
        -- 解包jffs2
        local cmd = string.format("jefferson \"%s\" -d \"%s\"", mtd, file_path .. "/" .. imageName .. "_unpacked")
        local o = exec(cmd .. " 2>&1")
        log(o)
        print("已解包jffs2分区：" .. mtd)
    else -- 其他类型
        print("已忽略" .. type .. "分区：" .. mtd)
    end
end

print("开始解包...")

-- 读取分区表信息
local partition_data = {}
local jf = io.open(file_path .. "partitions.json", "r")
if jf then
    local json_str = jf:read("*a")
    partition_data = json.decode(json_str)
    jf:close()
end

-- 遍历分区表，解包各分区
for i, partition in ipairs(partition_data) do
    local target_file = file_path .. partition.file
    unpack(target_file, partition.fst, partition.file)
end

print("=====================================")
print("解包完成")
print("=====================================")
print(" ")
