print("ufiStudio ZXIC MTD解包工具")
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
        -- 检测是否存在--enable-jffs2文件
        local ejs = io.open("__lib__/--enable-jffs2", "r")
        if not ejs then
            print("已忽略jffs2分区：" .. mtd)
            return
        end
        ejs:close()
        -- 解包
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
