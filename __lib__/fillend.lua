-- OpenZxicEditor
-- 版权所有 (C) 2024-2025 MiFi~Lab & OpenZxicEditor Developers. 
-- 
-- 本程序是自由软件：您可以基于自由软件基金会发布的GNU Affero通用公共许可证的条款下重新分发和/或修改它，或者本许可证第三版或者（由您选择）任何后续版本。
-- 分发本程序是希望它能派上用场，但没有任何担保，甚至也没有对其适销性或特定目的适用性的默示担保。更多细节请参见“GNU Affero通用公共许可证”。
-- 您应该已收到本程序随附的GNU Affero通用公共许可证的副本。如未收到，请参见：http://www.gnu.org/licenses/ 。
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
