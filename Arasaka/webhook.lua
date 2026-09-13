local HttpService = game:GetService("HttpService")
local request = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request

local Webhook = {}

local COLOR_INFO = 0x2B6CFF
local COLOR_SUCCESS = 0x2ECC71
local COLOR_WARN = 0xE5A50A
local COLOR_ERROR = 0xE74C3C

local function post(url, payload)
    if not request or not url or url == "" then
        return false
    end
    local ok = pcall(function()
        request({
            Url = url,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode(payload)
        })
    end)
    return ok
end

function Webhook.Send(url, pingId, title, description, fields, level)
    if not url or url == "" then return false end
    local color = COLOR_INFO
    if level == "success" then color = COLOR_SUCCESS
    elseif level == "warn" then color = COLOR_WARN
    elseif level == "error" then color = COLOR_ERROR end

    local content = ""
    if pingId and pingId ~= "" then
        content = "<@" .. tostring(pingId) .. ">"
    end

    local embed = {
        title = title or "Arasaka",
        description = description or "",
        color = color,
        fields = fields or {},
        footer = { text = "Arasaka Corp | " .. os.date("%H:%M:%S") }
    }

    return post(url, {
        content = content,
        embeds = { embed },
        allowed_mentions = { parse = { "users", "roles" } }
    })
end

function Webhook.RankUp(url, pingId, playerName, rank, level)
    return Webhook.Send(url, pingId, "Rank Up", playerName .. " reached rank " .. tostring(rank), {
        { name = "Player", value = playerName, inline = true },
        { name = "Rank", value = tostring(rank), inline = true },
        { name = "Level", value = tostring(level or "unknown"), inline = true }
    }, "success")
end

function Webhook.Test(url)
    return Webhook.Send(url, nil, "Arasaka Test", "Webhook connection successful.", {
        { name = "Status", value = "Online", inline = true }
    }, "info")
end

getgenv().Arasaka = getgenv().Arasaka or {}
getgenv().Arasaka.Webhook = Webhook

return Webhook