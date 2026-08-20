-- SAFE LOADER - No JSON parsing errors
local key = _G.lp_key or lp_key or ""

if key == "" then
    game:GetService("Players").LocalPlayer:Kick("No key provided!")
    return
end

-- Simple function to get script
local function loadScript()
    local url = "https://eu-1.luaprot.net/api/v2/loader/get?key=" .. key .. "&scriptId=12125701348483376783"
    
    local success, result = pcall(function()
        return game:HttpGet(url)
    end)
    
    if success and result and result ~= "" then
        -- Check if it's valid Lua (not JSON)
        local func = loadstring(result)
        if func then
            return func
        else
            -- If loadstring fails, it might be an error message
            return nil, "Invalid script response"
        end
    else
        return nil, "Connection failed: " .. tostring(result)
    end
end

-- Try to load
local func, err = loadScript()

if func then
    -- Execute the protected script
    pcall(func, "eu-1")
else
    -- Show error without freezing
    pcall(function()
        local player = game:GetService("Players").LocalPlayer
        if player then
            player:Kick("Failed to load script: " .. (err or "Unknown error"))
        end
    end)
end
