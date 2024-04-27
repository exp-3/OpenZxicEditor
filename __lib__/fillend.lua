-- ufiStudio ZXIC 文件填充组件
-- 版权所有 (C) 2024 ufiTech Developers. 保留所有权利.
--
-- 填充函数
local function fill(filePath, desiredSize, fillChar)
    if not fillChar then
        fillChar = 0xFF
    end
    -- 打开文件
    local file = io.open(filePath, "r+b") -- 读写模式，二进制模式
    if not file then
        -- 如果文件不存在，创建一个新文件
        file = io.open(filePath, "w+b")
    end
    -- 检查文件当前大小
    local currentSize = file:seek("end")
    -- 计算需要填充的字节大小
    local bytesToFill = desiredSize - currentSize
    -- 如果需要填充
    if bytesToFill > 0 then
        -- 生成一个包含0xFF的字符串
        local fillChar = string.char(fillChar)
        local fillString = fillChar:rep(16) -- 每次填充字节数量
        -- 循环填充直到达到期望大小
        while bytesToFill > 0 do
            local chunkSize = math.min(bytesToFill, 16)
            file:write(fillString:sub(1, chunkSize))
            bytesToFill = bytesToFill - chunkSize
        end
    end
    -- 关闭文件
    file:close()
end

return fill
