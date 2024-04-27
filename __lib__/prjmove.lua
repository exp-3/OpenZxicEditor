-- ufiStudio ZXIC 工程目录整理组件
-- 版权所有 (C) 2024 ufiTech Developers. 保留所有权利.
--
-- 读取MTDs/name.txt
local f = io.open("MTDs/name.txt", "r")
local name = f:read("*all")
f:close()
-- 将MTDs/重命名为name
os.rename("MTDs", string.format("z.%d_%s", math.floor(os.time() / 10) - 100000000, name:gsub(" ", ".")))
