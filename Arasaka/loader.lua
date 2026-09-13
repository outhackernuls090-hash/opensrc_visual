getgenv().KeyPassed = true
getgenv().Arasaka = {
    Version = "2.0.0",
    UI = {},
    Logic = {},
    Webhook = {}
}

local VOIDUI_URL = "https://raw.githubusercontent.com/outhackernuls090-hash/VoidUI/refs/heads/main/VoidUI.lua"
local BASE_URL = "https://raw.githubusercontent.com/outhackernuls090-hash/opensrc_visual/refs/heads/main/Arasaka/"
local CACHE_BUST = "?t=" .. tostring(math.floor(tick()))

local PREAMBLE = table.concat({
    "if not Font or type(Font.fromEnum) ~= \"function\" then",
    "    Font = Font or {}",
    "    Font.fromEnum = function(e) return e end",
    "end",
    "local __safeFromHex = function(v)",
    "    if type(v) == \"string\" then",
    "        local ok, r = pcall(Color3.fromHex, v)",
    "        if ok then return r end",
    "        return Color3.new(0, 0, 0)",
    "    end",
    "    if type(v) == \"userdata\" or type(v) == \"table\" then",
    "        return v",
    "    end",
    "    return Color3.new(0, 0, 0)",
    "end",
    ""
}, "\n")

local function patchVoidUI(source)
    source = string.gsub(source, "Color3%.fromHex", "__safeFromHex")
    return PREAMBLE .. source
end

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

    if ok and type(voidSource) == "string" then
        local patched = patchVoidUI(voidSource)
        local chunk, parseErr = loadstring(patched)
        if chunk then
            local success, result = xpcall(chunk, debug.traceback)
            if success and type(result) == "table" then
                getgenv().VoidUI = result
                print("[Arasaka] VoidUI loaded")
            else
                warn("[Arasaka] VoidUI runtime error:\n" .. tostring(result))
            end
        else
            warn("[Arasaka] VoidUI parse error: " .. tostring(parseErr))
        end
    else
        warn("[Arasaka] VoidUI fetch failed")
    end

    fetchRemote("webhook.lua")

    local waited = 0
    repeat
        task.wait(0.1)
        waited += 0.1
    until (getgenv().Arasaka.Webhook and getgenv().Arasaka.Webhook.Send) or waited > 10

    fetchRemote("logic.lua")
end)
