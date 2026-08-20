-- SAFE LOADER - With HWID Support
local key = _G.lp_key or lp_key or ""

if key == "" then
    game:GetService("Players").LocalPlayer:Kick("No key provided!")
    return
end

-- Get HWID
local function getHWID()
    local success, result = pcall(function()
        return game:GetService("RbxAnalyticsService"):GetClientId()
    end)
    if success and result then
        return result
    end
    return ""
end

local hwid = getHWID()

-- Simple function to get script with HWID
local function loadScript()
    local url = "https://eu-1.luaprot.net/api/v2/loader/get?key=" .. key .. "&scriptId=12125701348483376783&hwid=" .. hwid
    
    local success, result = pcall(function()
        return game:HttpGet(url)
    end)

    if success and result and result ~= "" then
        local func = loadstring(result)
        if func then
            return func
        else
            return nil, "Invalid script response"
        end
    else
        return nil, "Connection failed: " .. tostring(result)
    end
end

-- Try to load
local func, err = loadScript()

if func then
    pcall(func, "eu-1")
else
    pcall(function()
        local player = game:GetService("Players").LocalPlayer
        if player then
            player:Kick("Failed to load script: " .. (err or "Unknown error"))
        end
    end)
end
