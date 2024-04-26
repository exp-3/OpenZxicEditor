print("ufiStudio ZXIC MTD解包工具")
print("版权所有 (C) 2024 ufiTech Developers. 保留所有权利。")
print("=====================================")

local json = require("__lib__.json")
local file_path = "MTDs/"

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
local jffs2_symlink_warning = ""
local function unpack(mtd, type)
    log("=====================================")
    if type == "squashfs" then -- squashfs
        local cmd = string.format("unsquashfs -d %s %s", mtd .. "_unpacked", mtd)
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
        local cmd = string.format("jefferson %s -d %s", mtd, file_path .. "tmp" .. mtd)
        local o = exec(cmd .. " 2>&1")
        if o:find("symlink") then -- 出现软连接错误
            print("已跳过jffs2分区：" .. mtd)
            jffs2_symlink_warning = jffs2_symlink_warning .. mtd .. "\r\n"
            os.execute("rm -rf " .. file_path .. "tmp" .. mtd) -- 删除解包文件夹
        else
            log(o)
            -- os.rename(file_path .. "tmp/fs_1", mtd .. "_unpacked") -- 重命名解包文件夹
            -- os.execute("rm -rf " .. file_path .. "tmp" .. mtd) -- 删除临时文件夹
            print("已解包jffs2分区：" .. mtd)
        end
    else -- 其他
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
    unpack(target_file, partition.fst)
end

if jffs2_symlink_warning ~= "" then
    print("=====================================")
    print("请注意：以下jffs2分区中包含软连接：")
    print(jffs2_symlink_warning)
    print("暂不支持在Windows系统中处理此问题，故已自动跳过解包")
    print("jffs2在设备内部是可读写的，因此建议开adb后直接编辑")
    print("如有能力，也可以使用Linux系统直接挂载分区进行修改")
end

print("=====================================")
print("解包完成")
print("=====================================")
print(" ")
