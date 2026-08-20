-- Check if lp_key was set before loading
local user_key = _G.lp_key or lp_key or ""

if user_key == "" then
    game:GetService("Players").LocalPlayer:Kick("Invalid or missing key!")
    return
end

-- Use the captured key
lp_key = user_key

-- OPTIMIZED LOADER - With timeout protection
local f = "12125701348483376783"
local c = http and http.request or request

-- Error handler - Won't freeze
local function showError(msg)
    pcall(function()
        game:GetService("Players").LocalPlayer:Kick(msg)
        local prompt = game:GetService("CoreGui"):FindFirstChild("RobloxPromptGui")
        if prompt then
            local errorPrompt = prompt:FindFirstChild("promptOverlay"):FindFirstChild("ErrorPrompt")
            if errorPrompt then
                errorPrompt.TitleFrame.ErrorTitle.Text = "LuaProt"
                errorPrompt.MessageArea.ErrorFrame.ErrorMessage.Text = msg
            end
        end
    end)
end

-- Get node with timeout
local nodeSuccess, nodeResponse = pcall(c, {
    Url = "https://eu-1.luaprot.net/api/v1/nodes/get",
    Timeout = 3  -- 3 second timeout
})

local nodes = {"eu-1", "as-1", "us-1"}

if nodeSuccess and nodeResponse and nodeResponse.StatusCode == 200 then
    pcall(function()
        local data = game:GetService("HttpService"):JSONDecode(nodeResponse.Body)
        if data and data.success and data.node then
            for i, n in ipairs(nodes) do
                if n == data.node then
                    table.insert(nodes, 1, table.remove(nodes, i))
                    break
                end
            end
        end
    end)
end

-- Try to load with timeout
local loaded = false
local b = nil

for attempt = 1, 3 do  -- Only 3 attempts, not 5
    if loaded then break end
    
    for _, node in ipairs(nodes) do
        if loaded then break end
        
        local startTime = os.clock()
        local response = nil
        
        -- Spawn with timeout
        local thread = task.spawn(function()
            response = pcall(c, {
                Url = "https://" .. node .. ".luaprot.net/api/v2/loader/get?key=" .. lp_key .. "&scriptId=" .. f,
                Timeout = 5  -- 5 second timeout per request
            })
        end)
        
        -- Wait for response with timeout
        local waitTime = 0
        while waitTime < 6 and response == nil do
            task.wait(0.1)
            waitTime = waitTime + 0.1
        end
        
        if response and response[1] then
            local res = response[2]
            if res and (res.StatusCode == 200 or res.StatusCode == 201) then
                LP_NODE = node
                b = loadstring(res.Body)
                if b then
                    loaded = true
                    break
                end
            end
        end
    end
end

if loaded and b then
    pcall(b, LP_NODE)
else
    showError("Failed to load script. Please try again later!")
end
