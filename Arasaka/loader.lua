getgenv().KeyPassed = true
getgenv().Arasaka = {
    Version = "2.0.0",
    UI = {},
    Logic = {},
    Webhook = {}
}

local VOIDUI_URL = "https://raw.githubusercontent.com/outhackernuls090-hash/VoidUI/refs/heads/main/VoidUI.lua"
local BASE_URL = ""
local CACHE_BUST = "?t=" .. tostring(math.floor(tick()))

local function fetchRemote(path)
    local ok, source = pcall(function()
        return game:HttpGet(BASE_URL .. path .. CACHE_BUST)
    end)
    if not ok or not source then
        warn("[Arasaka] fetch failed: " .. path)
        return false
    end
    local chunk, parseErr = loadstring(source)
    if not chunk then
        warn("[Arasaka] parse error in " .. path .. ": " .. tostring(parseErr))
        return false
    end
    local ok2, runErr = pcall(chunk)
    if not ok2 then
        warn("[Arasaka] runtime error in " .. path .. ": " .. tostring(runErr))
        return false
    end
    return true
end

task.spawn(function()
    local ok, voidSource = pcall(function()
        return game:HttpGet(VOIDUI_URL .. CACHE_BUST)
    end)
    if ok and voidSource then
        local chunk = loadstring(voidSource)
        if chunk then
            local success, result = pcall(chunk)
            if success and type(result) == "table" then
                getgenv().VoidUI = result
            end
        end
    end

    fetchRemote("webhook.lua")

    local waited = 0
    repeat
        task.wait(0.1)
        waited += 0.1
    until (getgenv().Arasaka.Webhook and getgenv().Arasaka.Webhook.Send) or waited > 10

    fetchRemote("logic.lua")
end)