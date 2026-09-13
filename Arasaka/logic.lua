local player = game:GetService("Players").LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Network = ReplicatedStorage:WaitForChild("Network")
local workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local vim = game:GetService("VirtualInputManager")

getgenv().Arasaka_IsRunning = true

local VoidUI = getgenv().VoidUI
if not VoidUI then
    warn("[Arasaka] VoidUI not loaded")
    return
end

do
    local colorKeys = {
        "Accent", "AccentGlow", "Background", "BackgroundElevated", "Surface",
        "SurfaceHover", "Border", "Text", "TextDim", "TextMuted", "Success",
        "Warning", "Danger", "Scrollbar"
    }
    for _, theme in pairs(VoidUI.Themes) do
        for _, key in ipairs(colorKeys) do
            local v = theme[key]
            if type(v) == "string" and v:sub(1, 1) == "#" then
                theme[key] = Color3.fromHex(v)
            end
        end
    end

    VoidUI.Themes.Arasaka = {
        Name = "Arasaka",
        Accent             = Color3.fromRGB(230, 55, 70),
        AccentGlow         = Color3.fromRGB(255, 111, 124),
        Background         = Color3.fromRGB(10, 10, 13),
        BackgroundElevated = Color3.fromRGB(18, 18, 23),
        Surface            = Color3.fromRGB(26, 26, 32),
        SurfaceHover       = Color3.fromRGB(35, 35, 41),
        Border             = Color3.fromRGB(44, 44, 52),
        Text               = Color3.fromRGB(241, 241, 244),
        TextDim            = Color3.fromRGB(144, 144, 153),
        TextMuted          = Color3.fromRGB(90, 90, 99),
        Success            = Color3.fromRGB(63, 185, 80),
        Warning            = Color3.fromRGB(210, 153, 34),
        Danger             = Color3.fromRGB(230, 55, 70),
        Scrollbar          = Color3.fromRGB(44, 44, 52),
        Radius             = 10,
        RadiusSmall        = 6,
        RadiusLarge        = 14,
        HeaderHeight       = 50,
        SidebarWidth       = 200,
        WindowWidth        = 640,
        WindowHeight       = 460
    }
end

local UI = VoidUI.new({
    Name = "Arasaka",
    Theme = "Arasaka"
})

local Window = UI:CreateWindow({
    Title = "Arasaka Corp",
    Icon = "Home",
    Size = UDim2.fromOffset(640, 460),
    Position = UDim2.fromScale(0.5, 0.5)
})

local SaveModule
pcall(function()
    SaveModule = require(ReplicatedStorage:WaitForChild("Library"):WaitForChild("Client"):WaitForChild("Save"))
end)

local FetchSaveEvent = Instance.new("BindableEvent")
local LiveSaveData = nil

FetchSaveEvent.Event:Connect(function()
    pcall(function() LiveSaveData = SaveModule.Get() end)
end)

local configFileName = "Arasaka_Config.json"
local hideKeyEnum = Enum.KeyCode.K

local Toggles = {
    Farm = false, FastFarm = false, InfPetSpeed = false, Orbs = false,
    Rank = false, Hatch = false, HatchBest = false, HideEgg = false,
    BuyZone = false, TpArea = false, GoldBest = false, GoldAll = false,
    RainBest = false, RainAll = false, BuySlot = false, BuyEggSlot = false,
    AutoBundleEnchant = false, AutoBundlePotion = false, AutoBundleFruit = false,
    AutoBundleFlag = false, Ultimate = false, AutoFarmArea = false,
    KaitunMode = false, AutoClaimMail = false, AntiAFK = true
}

local RankConfig = {
    Comet = true, Jar = true, Pinata = true, Lucky = true, Flag = true,
    Fruit = true, Potion = true, Area = true, UpPotion = true, UpEnchant = true,
    Hatch = true, Gold = true, Rainbow = true, Legendary = true
}

local WHConfig = {
    Url = "", PingID = "", TargetRank = 0, HasSentRank = false, PingEnabled = false
}

local SavedEnchants = {}

getgenv().uiScaleValue = 1.0
getgenv().MinRankArea = 5
getgenv().TargetEquipSlots = 99
getgenv().TargetEggSlots = 99
getgenv().TargetUltimate = getgenv().TargetUltimate or "Ground Pound"
getgenv().AutoTapMode = getgenv().AutoTapMode or "Closest"
getgenv().LegendaryEggOffset = getgenv().LegendaryEggOffset or 1
getgenv().FastFarmSpeedMs = getgenv().FastFarmSpeedMs or 300
getgenv().FastFarmTargets = getgenv().FastFarmTargets or 10
getgenv().FarmRadius = getgenv().FarmRadius or 150

local function SaveConfig()
    if writefile then
        local dataToSave = {
            Toggles = Toggles, RankConfig = RankConfig, SavedEnchants = SavedEnchants,
            WHConfig = WHConfig, HideKey = hideKeyEnum.Name, UIScale = getgenv().uiScaleValue,
            MinRankArea = getgenv().MinRankArea, TargetEquipSlots = getgenv().TargetEquipSlots,
            TargetEggSlots = getgenv().TargetEggSlots, TargetUltimate = getgenv().TargetUltimate,
            AutoTapMode = getgenv().AutoTapMode, FastFarmSpeedMs = getgenv().FastFarmSpeedMs,
            FastFarmTargets = getgenv().FastFarmTargets, FarmRadius = getgenv().FarmRadius,
            LegendaryEggOffset = getgenv().LegendaryEggOffset
        }
        pcall(function()
            writefile(configFileName, HttpService:JSONEncode(dataToSave))
        end)
    end
end

local function LoadConfig()
    if isfile and isfile(configFileName) then
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile(configFileName))
        end)
        if success and type(data) == "table" then
            if data.Toggles then for k, v in pairs(data.Toggles) do Toggles[k] = v end end
            if data.RankConfig then for k, v in pairs(data.RankConfig) do RankConfig[k] = v end end
            if data.SavedEnchants then for k, v in pairs(data.SavedEnchants) do SavedEnchants[tonumber(k)] = v end end
            if data.WHConfig then for k, v in pairs(data.WHConfig) do WHConfig[k] = v end end
            if data.UIScale ~= nil then getgenv().uiScaleValue = data.UIScale end
            if data.MinRankArea ~= nil then getgenv().MinRankArea = data.MinRankArea end
            if data.TargetEquipSlots ~= nil then getgenv().TargetEquipSlots = math.min(99, tonumber(data.TargetEquipSlots) or 99) end
            if data.TargetEggSlots ~= nil then getgenv().TargetEggSlots = math.min(99, tonumber(data.TargetEggSlots) or 99) end
            if data.TargetUltimate ~= nil then getgenv().TargetUltimate = data.TargetUltimate end
            if data.AutoTapMode ~= nil then getgenv().AutoTapMode = data.AutoTapMode end
            if data.FastFarmSpeedMs ~= nil then getgenv().FastFarmSpeedMs = data.FastFarmSpeedMs end
            if data.FastFarmTargets ~= nil then getgenv().FastFarmTargets = data.FastFarmTargets end
            if data.FarmRadius ~= nil then getgenv().FarmRadius = data.FarmRadius end
            if data.LegendaryEggOffset ~= nil then getgenv().LegendaryEggOffset = data.LegendaryEggOffset end
            if data.HideKey then pcall(function() hideKeyEnum = Enum.KeyCode[data.HideKey] end) end
        end
    end
end

LoadConfig()

if not getgenv().Arasaka_AntiAFK_Setup then
    getgenv().Arasaka_AntiAFK_Setup = true
    pcall(function()
        player.Idled:Connect(function()
            if Toggles.AntiAFK and getgenv().Arasaka_IsRunning then
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
                VirtualUser:Button2Down(Vector2.new(0, 0))
                task.wait(0.1)
                VirtualUser:Button2Up(Vector2.new(0, 0))
            end
        end)
    end)
    task.spawn(function()
        while task.wait(60) do
            if not getgenv().Arasaka_IsRunning then break end
            if Toggles.AntiAFK then
                pcall(function()
                    vim:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                    task.wait(0.1)
                    vim:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                    local char = player.Character
                    if char then
                        local h = char:FindFirstChildOfClass("Humanoid")
                        if h then h.Jump = true end
                    end
                end)
            end
        end
    end)
end

local RankCmds, PlayerPet
pcall(function() RankCmds = require(ReplicatedStorage:WaitForChild("Library"):WaitForChild("Client"):WaitForChild("RankCmds")) end)
pcall(function() PlayerPet = require(ReplicatedStorage:WaitForChild("Library"):WaitForChild("Client"):WaitForChild("PlayerPet")) end)

if PlayerPet and type(PlayerPet.CalculateSpeedMultiplier) == "function" and not getgenv().PetSpeedHooked then
    getgenv().PetSpeedHooked = true
    local originalCalc = PlayerPet.CalculateSpeedMultiplier
    PlayerPet.CalculateSpeedMultiplier = function(self, ...)
        if Toggles.InfPetSpeed and getgenv().Arasaka_IsRunning then return 75 end
        return originalCalc(self, ...)
    end
end

local function checkSuperComputer()
    local hasSC = false
    if SaveModule then
        pcall(function()
            local sd = SaveModule.Get()
            if sd and ((sd.Rebirths and sd.Rebirths >= 4) or (sd.UnlockedZones and (sd.UnlockedZones["74 | Tech City"] or sd.UnlockedZones["100 | Void"]))) then
                hasSC = true
            end
        end)
    end
    return hasSC
end

local HAS_SUPER_COMPUTER = checkSuperComputer()

local ZoneDict, ZoneNameByNum = {}, {}
pcall(function()
    local zDir = ReplicatedStorage:FindFirstChild("__DIRECTORY") and ReplicatedStorage.__DIRECTORY:FindFirstChild("Zones")
    if zDir then
        for _, mod in ipairs(zDir:GetDescendants()) do
            if mod:IsA("ModuleScript") then
                local numStr = string.match(mod.Name, "^(%d+)")
                local clean = string.match(mod.Name, "%d+%s*|%s*(.+)")
                if numStr and clean then
                    local num = tonumber(numStr)
                    ZoneDict[clean] = num
                    ZoneDict[mod.Name] = num
                    ZoneNameByNum[num] = clean
                end
            end
        end
    end
end)

local function getCurrentWorldBounds()
    local pId = game.PlaceId
    if pId == 8737899170 then return 1, 99
    elseif pId == 16498369169 then return 100, 199
    elseif pId == 17503543197 then return 200, 239
    elseif pId == 140403681187145 or pId == 17720827393 then return 240, 999 end
    return 1, 999
end

local function parseZoneNumber(zName, pId)
    local num = tonumber(string.match(zName, "^(%d+)"))
    if num then return num end
    local ln = string.lower(zName)
    if string.find(ln, "shop") or string.find(ln, "spawn") then
        if pId == 16498369169 then return 100
        elseif pId == 17503543197 then return 200
        elseif pId == 140403681187145 or pId == 17720827393 then return 240
        else return 1 end
    end
    return ZoneDict[zName]
end

local CachedZones = nil
local function getAllZoneInstances()
    if CachedZones then return CachedZones end
    local zones = {}
    for _, mn in ipairs({ "Map", "Map2", "Map3", "Map4" }) do
        local m = workspace:FindFirstChild(mn)
        if m then
            for _, z in ipairs(m:GetChildren()) do
                if not string.find(string.lower(z.Name), "vip") then
                    table.insert(zones, z)
                end
            end
        end
    end
    CachedZones = zones
    return zones
end

local function getZoneInstanceByNumber(zNum)
    local fallback = nil
    for _, z in ipairs(getAllZoneInstances()) do
        if parseZoneNumber(z.Name, game.PlaceId) == zNum then
            if string.match(z.Name, "^(%d+)") then return z else fallback = z end
        end
    end
    return fallback
end

local function getZoneName(num)
    local pId = game.PlaceId
    if pId == 8737899170 and num == 1 then return "Spawn"
    elseif pId == 16498369169 and num == 100 then return "Tech Spawn"
    elseif pId == 17503543197 and num == 200 then return "Void Spawn"
    elseif (pId == 140403681187145 or pId == 17720827393) and num == 240 then return "Fantasy Spawn" end
    return ZoneNameByNum[num]
end

local function getHighestUnlockedZoneNumAndInst()
    local maxNum = -1
    local minZ, maxZ = getCurrentWorldBounds()
    local tm = player.PlayerGui:FindFirstChild("TeleportMap")
    if tm then
        for _, d in ipairs(tm:GetDescendants()) do
            if d.Name == "textHolder" then
                local tl, nl = d:FindFirstChild("Title"), d:FindFirstChild("Number")
                if tl and nl and tl:IsA("TextLabel") and nl:IsA("TextLabel") and tl.Text ~= "???" and tl.Text ~= "Locked" then
                    local nm = string.match(nl.Text, "%d+")
                    if nm then
                        local n = tonumber(nm)
                        if n and n >= minZ and n <= maxZ and n > maxNum then maxNum = n end
                    end
                end
            end
        end
    end
    if maxNum == -1 and SaveModule then
        pcall(function()
            local d = SaveModule.Get()
            if d and d.UnlockedZones then
                for zn, _ in pairs(d.UnlockedZones) do
                    local n = parseZoneNumber(zn, game.PlaceId)
                    if n and n >= minZ and n <= maxZ and n > maxNum then maxNum = n end
                end
            end
        end)
    end
    return maxNum, getZoneInstanceByNumber(maxNum)
end

local function isAreaUnlocked(req)
    if HAS_SUPER_COMPUTER then return true end
    local m, _ = getHighestUnlockedZoneNumAndInst()
    return m >= req
end

getgenv().EggNameToNumber = {}
getgenv().EggNumberToName = {}

local function getEggDataList()
    local edl = {}
    local pId = game.PlaceId
    local eDir = ReplicatedStorage:FindFirstChild("__DIRECTORY") and ReplicatedStorage.__DIRECTORY:FindFirstChild("Eggs")
    if eDir then
        for _, mod in ipairs(eDir:GetDescendants()) do
            if mod:IsA("ModuleScript") then
                local s, d = pcall(require, mod)
                if s and type(d) == "table" and d.eggNumber then
                    local eNum = d.eggNumber
                    local iv = true
                    if pId == 8737899170 and eNum > 112 then iv = false
                    elseif pId == 16498369169 and (eNum <= 112 or eNum >= 213) then iv = false
                    elseif pId == 17503543197 and (eNum < 213 or eNum >= 240) then iv = false
                    elseif (pId == 140403681187145 or pId == 17720827393) and eNum < 240 then iv = false end
                    if iv then
                        local cn = string.match(mod.Name, "|%s*(.+)") or mod.Name
                        getgenv().EggNameToNumber[cn] = eNum
                        getgenv().EggNumberToName[eNum] = cn
                        table.insert(edl, { name = cn, num = eNum, zoneNum = d.zoneNumber or eNum })
                    end
                end
            end
        end
    end
    table.sort(edl, function(a, b) return a.num < b.num end)
    return edl
end

local GLOBAL_EGG_DATA = getEggDataList()

local function getEnchantDataList()
    local l, m = {}, {}
    local eDir = ReplicatedStorage:FindFirstChild("__DIRECTORY") and ReplicatedStorage.__DIRECTORY:FindFirstChild("Enchants")
    if eDir then
        for _, mod in ipairs(eDir:GetDescendants()) do
            if mod:IsA("ModuleScript") then
                local cn = string.match(mod.Name, "|%s*(.+)") or mod.Name
                if not m[cn] then m[cn] = true; table.insert(l, cn) end
            end
        end
    end
    table.sort(l)
    return l
end

local GLOBAL_ENCHANT_LIST = getEnchantDataList()

local function getUltimateList()
    local l = {}
    local uDir = ReplicatedStorage:FindFirstChild("__DIRECTORY") and ReplicatedStorage.__DIRECTORY:FindFirstChild("Ultimates")
    if uDir then
        for _, mod in ipairs(uDir:GetChildren()) do
            if mod:IsA("ModuleScript") then
                table.insert(l, string.match(mod.Name, "|%s*(.+)") or mod.Name)
            end
        end
    end
    table.sort(l)
    if #l == 0 then
        l = { "Pet Surge", "Ground Pound", "Black Hole", "Tornado", "Tsunami", "Lightning Storm", "Hidden Treasure", "Nightmare", "TNT Shower", "UFO" }
    end
    return l
end

local GLOBAL_ULTIMATE_LIST = getUltimateList()

local function getPetsFromEgg(eggName)
    local pets = {}
    local eggsDir = ReplicatedStorage:FindFirstChild("__DIRECTORY") and ReplicatedStorage.__DIRECTORY:FindFirstChild("Eggs")
    if eggsDir and eggName then
        for _, mod in ipairs(eggsDir:GetDescendants()) do
            local cleanName = string.match(mod.Name, "|%s*(.+)") or mod.Name
            if cleanName == eggName then
                local s, d = pcall(require, mod)
                if s and type(d) == "table" then
                    local target = d.pets or d.Pets or d.drops or d.Drops or d.items or d.Items or d.rewards
                    if target and type(target) == "table" then
                        for _, p in pairs(target) do
                            if type(p) == "table" and (p[1] or p.id or p.name) then
                                pets[tostring(p[1] or p.id or p.name)] = true
                            elseif type(p) == "string" then
                                pets[p] = true
                            end
                        end
                    end
                end
                break
            end
        end
    end
    return pets
end

local function getOrderedConsumablePotionUID(targetTier)
    local orderList = { "Coins", "Damage", "Diamonds", "Lucky Eggs", "Treasure Hunter" }
    if SaveModule then
        local success, data = pcall(function() return SaveModule.Get() end)
        if success and data and data.Inventory and data.Inventory.Potion then
            for _, name in ipairs(orderList) do
                local fallbackUid, fallbackTier = nil, 999
                for uid, item in pairs(data.Inventory.Potion) do
                    if tostring(item.id) == name then
                        local tier, amount = tonumber(item.tn) or 1, tonumber(item._am) or 1
                        if targetTier then
                            if tier == tonumber(targetTier) and amount >= 1 then return uid, name end
                        else
                            if tier < fallbackTier and amount >= 1 then
                                fallbackTier = tier
                                fallbackUid = uid
                            end
                        end
                    end
                end
                if not targetTier and fallbackUid then return fallbackUid, name end
            end
        end
    end
    return nil, nil
end

local function getLiveUID(iName, tNum, cat, minAmt)
    if SaveModule then
        local s, d = pcall(SaveModule.Get)
        if s and d and d.Inventory and d.Inventory[cat] then
            for u, dt in pairs(d.Inventory[cat]) do
                if tostring(dt.id) == iName and (tonumber(dt.tn) or 1) == tonumber(tNum) and (tonumber(dt._am) or 1) >= (minAmt or 1) then
                    return u
                end
            end
        end
    end
    return nil
end

local function getMiscItemUID(iName, avoidShiny)
    if SaveModule then
        local s, d = pcall(SaveModule.Get)
        if s and d and d.Inventory then
            for _, c in ipairs({ "Misc", "Lootbox", "Consumable", "Fruit" }) do
                if d.Inventory[c] then
                    for u, dt in pairs(d.Inventory[c]) do
                        if tostring(dt.id) == iName then
                            if not (avoidShiny and dt.sh) then return u end
                        end
                    end
                end
            end
        end
    end
    return nil
end

local function getValidBreakZone(zoneInstance)
    local interact = zoneInstance:FindFirstChild("INTERACT")
    if interact then
        local spawnFolder = interact:FindFirstChild("BREAKABLE_SPAWNS")
        if spawnFolder then
            local main = spawnFolder:FindFirstChild("Main")
            if main then return main end
        end
    end
    return nil
end

local function getZonePosition(zInst)
    if not zInst then return Vector3.new(0, 0, 0) end
    if zInst:IsA("Model") or zInst:IsA("BasePart") then return zInst:GetPivot().Position end
    local i = zInst:FindFirstChild("INTERACT")
    if i then
        local sf = i:FindFirstChild("BREAKABLE_SPAWNS")
        if sf and sf:FindFirstChild("Main") then return sf.Main:GetPivot().Position end
    end
    local p = zInst:FindFirstChild("PERSISTENT")
    if p then
        local fp = p:FindFirstChildWhichIsA("BasePart", true)
        if fp then return fp.Position end
    end
    local ap = zInst:FindFirstChildWhichIsA("BasePart", true)
    if ap then return ap.Position end
    return Vector3.new(0, 0, 0)
end

local function getCurrentAreaNumber()
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return 0 end
    local ray = workspace:Raycast(hrp.Position, Vector3.new(0, -100, 0), (function()
        local p = RaycastParams.new()
        p.FilterDescendantsInstances = { player.Character, workspace:FindFirstChild("__THINGS") }
        p.FilterType = Enum.RaycastFilterType.Exclude
        return p
    end)())
    if ray and ray.Instance then
        local c = ray.Instance
        while c and c ~= workspace do
            if c.Parent and string.match(string.lower(c.Parent.Name), "map") then
                local n = parseZoneNumber(c.Name, game.PlaceId)
                if n then return n end
            end
            c = c.Parent
        end
    end
    local md, an = math.huge, 0
    for _, z in ipairs(getAllZoneInstances()) do
        local pos = getZonePosition(z)
        if pos ~= Vector3.new(0, 0, 0) then
            local dist = (hrp.Position - pos).Magnitude
            if dist < md then md = dist; an = parseZoneNumber(z.Name, game.PlaceId) or 0 end
        end
    end
    return an
end

local function getPlayerRank()
    local r = 1
    pcall(function()
        if SaveModule then
            local d = SaveModule.Get()
            if d and d.Rank then r = d.Rank end
        end
    end)
    return r
end

local function getMaxHatchAmount()
    local a = 1
    pcall(function()
        if SaveModule then
            local d = SaveModule.Get()
            if d then
                a = d.EggHatchCount or (d.EggSlotsPurchased or 0) + 1
            end
        end
    end)
    return a
end

local function getBestEggNameForPlayer()
    local mZ, _ = getHighestUnlockedZoneNumAndInst()
    if mZ == 100 then
        for i = #GLOBAL_EGG_DATA, 1, -1 do
            if GLOBAL_EGG_DATA[i].num == 113 then return GLOBAL_EGG_DATA[i].name end
        end
    end
    local bN, mE = nil, 0
    for _, e in ipairs(GLOBAL_EGG_DATA) do
        if e.zoneNum <= mZ and e.num > mE then mE = e.num; bN = e.name end
    end
    return bN
end

local function stealthTeleport(zInst)
    local c = player.Character or player.CharacterAdded:Wait()
    local hrp = c:WaitForChild("HumanoidRootPart", 5)
    if not hrp or not zInst then return false end
    local p = zInst:FindFirstChild("PERSISTENT")
    if not p then return false end
    local tp = p:FindFirstChild("Teleport") or p:FindFirstChildWhichIsA("BasePart", true)
    if not tp then return false end
    local tCF = tp:IsA("Model") and tp:GetPivot() or tp.CFrame
    hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    hrp.CFrame = tCF * CFrame.new(0, 15, 0)
    local bT = nil
    local t = tick()
    repeat
        task.wait(0.1)
        local i = zInst:FindFirstChild("INTERACT")
        if i then
            local sf = i:FindFirstChild("BREAKABLE_SPAWNS")
            if sf then bT = sf:FindFirstChild("Main") end
        end
    until bT or (tick() - t > 3.5)
    if not bT then return false end
    pcall(function() Network.Pets_UnequipAll:FireServer() end)
    task.wait(0.1)
    pcall(function() Network.Pets_Restore:FireServer() end)
    hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    hrp.CFrame = bT:IsA("Model") and bT:GetPivot() * CFrame.new(0, 5, 0) or bT.CFrame * CFrame.new(0, 5, 0)
    return true
end

local function forceTeleportToBestZone()
    local mN, bI = getHighestUnlockedZoneNumAndInst()
    if bI and stealthTeleport(bI) then return true end
    local zN = getZoneName(mN)
    if zN then
        pcall(function() Network.Teleports_RequestTeleport:InvokeServer(zN) end)
        task.wait(1.5)
        local rI = getZoneInstanceByNumber(mN)
        if rI then return stealthTeleport(rI) end
        return true
    end
    return false
end

local function teleportToZoneNum(zNum)
    local inst = getZoneInstanceByNumber(zNum)
    if inst and stealthTeleport(inst) then return true end
    local zN = getZoneName(zNum)
    if zN then
        pcall(function() Network.Teleports_RequestTeleport:InvokeServer(zN) end)
        task.wait(1.5)
        local rI = getZoneInstanceByNumber(zNum)
        if rI then return stealthTeleport(rI) end
        return true
    end
    return false
end

local function teleportToEgg(eName)
    local n = getgenv().EggNameToNumber[eName]
    if not n then return end
    local cN = tostring(n) .. " - Egg Capsule"
    local t = workspace:FindFirstChild("__THINGS")
    if not t then return end
    local pId, cap = game.PlaceId, nil
    if pId == 17503543197 then
        local ef = t:FindFirstChild("Eggs")
        if ef then cap = ef:FindFirstChild(cN, true) end
    end
    if not cap then
        local ze = t:FindFirstChild("ZoneEggs")
        if ze then cap = ze:FindFirstChild(cN, true) end
    end
    if not cap then
        local ef = t:FindFirstChild("Eggs")
        if ef then cap = ef:FindFirstChild(cN, true) end
    end
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if cap and hrp then
        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        hrp.CFrame = cap:GetPivot() * CFrame.new(0, 4, 6)
    end
end

local function safeMachineFire(mTab, rName, uid, amt)
    local r = Network:FindFirstChild(rName)
    if not r then return end
    local el = Network:FindFirstChild("EventLog_Once")
    local pId = game.PlaceId
    local uSC = HAS_SUPER_COMPUTER and (pId == 16498369169 or pId == 17503543197 or pId == 140403681187145 or pId == 17720827393)
    if el then
        pcall(function() el:FireServer("OpenTab", uSC and "SuperMachine" or mTab) end)
        task.wait(0.1)
    end
    pcall(function() r:InvokeServer(uid, amt) end)
    if el then
        task.wait(0.1)
        pcall(function() el:FireServer("CloseTab", uSC and "SuperMachine" or mTab) end)
    end
end

local function performMachineAction(act, zNum, mName)
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local pId = game.PlaceId
    local uSC = HAS_SUPER_COMPUTER and (pId == 16498369169 or pId == 17503543197 or pId == 140403681187145 or pId == 17720827393)
    if uSC then
        if pId == 16498369169 then zNum = 100
        elseif pId == 17503543197 then zNum = 200
        elseif pId == 140403681187145 or pId == 17720827393 then zNum = 240 end
        mName = "SuperMachine"
    end
    getgenv().IsMachineActionActive = true
    local o = hrp.CFrame
    teleportToZoneNum(zNum)
    task.wait(0.5)
    local appr = Network:FindFirstChild("Machines: Mark Approached")
    if appr and mName then pcall(function() appr:FireServer(mName) end) end
    pcall(act)
    task.wait(0.3)
    hrp.CFrame = o
    getgenv().IsMachineActionActive = false
end

local function getBulkUpgradableItems(category, requiredCrafts, targetTierNum)
    local results = {}
    local orderList = category == "Potion" and { "Coins", "Damage", "Diamonds", "Lucky Eggs", "Treasure Hunter", "Speed" }
        or { "Treasure Hunter", "Tap Power", "Strong Pets", "Speed", "Magnet", "Lucky Eggs", "Diamonds", "Criticals", "Coins" }
    local craftsRemaining = requiredCrafts
    if SaveModule then
        local success, data = pcall(function() return SaveModule.Get() end)
        if success and data and data.Inventory and data.Inventory[category] then
            if targetTierNum then
                local targetInputTier = targetTierNum - 1
                for _, name in ipairs(orderList) do
                    for uid, item in pairs(data.Inventory[category]) do
                        if tostring(item.id) == name and (tonumber(item.tn) or 1) == targetInputTier then
                            local amount = tonumber(item._am) or 1
                            local possibleCrafts = math.floor(amount / 5)
                            if possibleCrafts > 0 then
                                local craftsToTake = math.min(possibleCrafts, craftsRemaining)
                                table.insert(results, { uid = uid, name = name, crafts = craftsToTake })
                                craftsRemaining = craftsRemaining - craftsToTake
                                if craftsRemaining <= 0 then return results end
                            end
                        end
                    end
                end
            else
                for currentSearchTier = 1, 7 do
                    for _, name in ipairs(orderList) do
                        for uid, item in pairs(data.Inventory[category]) do
                            if tostring(item.id) == name and (tonumber(item.tn) or 1) == currentSearchTier then
                                local isMax = false
                                if category == "Potion" and name == "Speed" and currentSearchTier >= 3 then isMax = true end
                                if category == "Enchant" and name == "Magnet" and currentSearchTier >= 3 then isMax = true end
                                if category == "Enchant" and name == "Speed" and currentSearchTier >= 5 then isMax = true end
                                if currentSearchTier >= 8 then isMax = true end
                                if not isMax then
                                    local amount = tonumber(item._am) or 1
                                    local possibleCrafts = math.floor(amount / 5)
                                    if possibleCrafts > 0 then
                                        local craftsToTake = math.min(possibleCrafts, craftsRemaining)
                                        table.insert(results, { uid = uid, name = name, crafts = craftsToTake })
                                        craftsRemaining = craftsRemaining - craftsToTake
                                        if craftsRemaining <= 0 then return results end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return results
end

task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            for _, g in ipairs(player.PlayerGui:GetChildren()) do
                if g:IsA("ScreenGui") and g.Enabled then
                    local n = string.lower(g.Name)
                    if string.find(n, "rankup") or string.find(n, "masteryperk") or string.find(n, "levelup") or string.find(n, "newperk") then
                        local cam = workspace.CurrentCamera
                        if cam then
                            local cx = cam.ViewportSize.X * 0.5
                            local cy = cam.ViewportSize.Y * 0.5
                            for i = 1, 3 do
                                pcall(function() VirtualUser:ClickButton1(Vector2.new(cx, cy)) end)
                                pcall(function() vim:SendMouseButtonEvent(cx, cy, 0, true, game, 1) end)
                                task.wait(0.1)
                                pcall(function() vim:SendMouseButtonEvent(cx, cy, 0, false, game, 1) end)
                                task.wait(0.1)
                            end
                        end
                    end
                end
            end
        end)
    end
end)

local function GetActiveRankQuests()
    local quests = {}
    local goalsSide = player.PlayerGui:FindFirstChild("GoalsSide")
    local holder = goalsSide and goalsSide:FindFirstChild("QuestsHolder", true)
    if holder then
        for _, item in pairs(holder:GetChildren()) do
            local titleLbl = item:FindFirstChild("Title", true) or item:FindFirstChild("Desc", true)
            if titleLbl and titleLbl.Text ~= "" then
                local text = string.lower(titleLbl.Text)
                if not string.find(text, "rankup ready") then
                    local questFullText = ""
                    for _, desc in ipairs(item:GetDescendants()) do
                        if desc:IsA("TextLabel") and desc.Text ~= "" then
                            questFullText = questFullText .. " " .. string.lower(desc.Text)
                        end
                    end
                    local prog = 0
                    local maxNum = 1
                    local slash = string.char(47)
                    local pattern = "(%d+)%s*" .. slash .. "%s*(%d+)"
                    local pMatch, mMatch = string.match(questFullText, pattern)
                    if pMatch and mMatch then
                        prog = tonumber(pMatch)
                        maxNum = tonumber(mMatch)
                    else
                        local n = string.match(text, "(%d+)")
                        maxNum = n and tonumber(n) or 1
                    end
                    local remaining = math.max(1, maxNum - prog)
                    table.insert(quests, { txt = text, remaining = remaining, raw = titleLbl.Text, ignored = false, prog = prog })
                end
            end
        end
    end
    return quests
end

local function getEquippedEnchants_Live()
    local equipped = {}
    if LiveSaveData and LiveSaveData.EquippedEnchants then
        for slotStr, uid in pairs(LiveSaveData.EquippedEnchants) do
            local slotNum = tonumber(string.match(slotStr, "%d+"))
            if slotNum then
                local eName, eTier, isTls = "Unknown", 1, false
                if LiveSaveData.Inventory and LiveSaveData.Inventory.Enchant and LiveSaveData.Inventory.Enchant[uid] then
                    eName = tostring(LiveSaveData.Inventory.Enchant[uid].id)
                    local tierRaw = tonumber(LiveSaveData.Inventory.Enchant[uid].tn)
                    if tierRaw then eTier = tierRaw else eTier = 99; isTls = true end
                end
                equipped[slotNum] = { name = eName, tier = eTier, uid = uid, isTierless = isTls }
            end
        end
    end
    return equipped
end

local function getEquippedEnchants()
    local equipped = {}
    pcall(function()
        local data = SaveModule.Get()
        if data and data.EquippedEnchants then
            for slotStr, uid in pairs(data.EquippedEnchants) do
                local slotNum = tonumber(string.match(slotStr, "%d+"))
                if slotNum then
                    local eName, eTier, isTls = "Unknown", 1, false
                    if data.Inventory and data.Inventory.Enchant and data.Inventory.Enchant[uid] then
                        eName = tostring(data.Inventory.Enchant[uid].id)
                        local tierRaw = tonumber(data.Inventory.Enchant[uid].tn)
                        if tierRaw then eTier = tierRaw else eTier = 99; isTls = true end
                    end
                    equipped[slotNum] = { name = eName, tier = eTier, uid = uid, isTierless = isTls }
                end
            end
        end
    end)
    return equipped
end

local function getEnchantMasteryLvl()
    local lvl = nil
    pcall(function()
        local masteryUI = player.PlayerGui:FindFirstChild("Main") and player.PlayerGui.Main:FindFirstChild("Mastery")
        if masteryUI then
            local enchantsFrame = masteryUI:FindFirstChild("Container", true) and masteryUI.Container:FindFirstChild("ItemsFrame") and masteryUI.Container.ItemsFrame:FindFirstChild("Enchants")
            if enchantsFrame and enchantsFrame:FindFirstChild("LevelTitle") then
                lvl = tonumber(string.match(enchantsFrame.LevelTitle.Text, "%d+"))
            end
        end
    end)
    return lvl
end

local targetEggName = nil
local lastRankClaim, lastItemUse = 0, 0
local globalIgnoredQuests = {}
local rankFruitList = { "Rainbow Fruit", "Watermelon", "Pineapple", "Orange", "Banana", "Apple" }
local currentRankFruitIndex = 1
local lastRankFruitProgress = -1
local ROMAN_MAP = { i = 1, ii = 2, iii = 3, iv = 4, v = 5, vi = 6, vii = 7, viii = 8, ix = 9, x = 10 }

UI:Notify({ Title = "Arasaka", Description = "Loaded successfully.", Type = "Success" })

local FarmTab = Window:CreateTab({ Title = "Farm", Icon = "Sword" })
local HatchTab = Window:CreateTab({ Title = "Hatch", Icon = "Egg" })
local EnchantTab = Window:CreateTab({ Title = "Enchants", Icon = "Book" })
local InventoryTab = Window:CreateTab({ Title = "Inventory", Icon = "Package" })
local WorldTab = Window:CreateTab({ Title = "World", Icon = "Globe" })
local WebhookTab = Window:CreateTab({ Title = "Webhook", Icon = "Link" })
local ConfigTab = Window:CreateTab({ Title = "Config", Icon = "Settings" })

FarmTab:CreateSection({ Title = "Main Farm" })

FarmTab:CreateButton({
    Title = "Teleport to Best Area",
    Callback = function() task.spawn(forceTeleportToBestZone) end
})

FarmTab:CreateToggle({
    Title = "Auto Farm + Buy Area",
    Default = Toggles.AutoFarmArea,
    Callback = function(v)
        Toggles.AutoFarmArea = v
        if v then task.spawn(forceTeleportToBestZone) end
        SaveConfig()
    end
})

FarmTab:CreateToggle({
    Title = "Fast Farm (Bulk + Multi-Tap)",
    Default = Toggles.FastFarm,
    Callback = function(v) Toggles.FastFarm = v; SaveConfig() end
})

FarmTab:CreateToggle({
    Title = "Infinite Pet Speed",
    Default = Toggles.InfPetSpeed,
    Callback = function(v) Toggles.InfPetSpeed = v; SaveConfig() end
})

FarmTab:CreateToggle({
    Title = "Auto Rank Quests",
    Default = Toggles.Rank,
    Callback = function(v) Toggles.Rank = v; SaveConfig() end
})

FarmTab:CreateSection({ Title = "Rank Quest Config" })

local rankKeys = {
    { "Comet/Meteor", "Comet" }, { "Coin Jars", "Jar" }, { "Pinatas", "Pinata" },
    { "Lucky Blocks", "Lucky" }, { "Flags", "Flag" }, { "Fruits", "Fruit" },
    { "Drink Potions", "Potion" }, { "Unlock Area", "Area" }, { "Up Potions", "UpPotion" },
    { "Up Enchants", "UpEnchant" }, { "Hatch Eggs", "Hatch" }, { "Gold Pets", "Gold" },
    { "Rainbow Pets", "Rainbow" }, { "Legendary Pets", "Legendary" }
}

for _, v in ipairs(rankKeys) do
    FarmTab:CreateToggle({
        Title = v[1],
        Default = RankConfig[v[2]],
        Callback = function(val) RankConfig[v[2]] = val; SaveConfig() end
    })
end

FarmTab:CreateSlider({
    Title = "Legendary Egg Offset",
    Min = 1, Max = 2, Default = getgenv().LegendaryEggOffset,
    Callback = function(v) getgenv().LegendaryEggOffset = v; SaveConfig() end
})

FarmTab:CreateToggle({
    Title = "Kaitun Rank",
    Default = Toggles.KaitunMode,
    Callback = function(v) Toggles.KaitunMode = v; SaveConfig() end
})

HatchTab:CreateSection({ Title = "Auto Hatch" })

HatchTab:CreateToggle({
    Title = "Auto Hatch Best Egg",
    Default = Toggles.HatchBest,
    Callback = function(v)
        Toggles.HatchBest = v
        if v then task.spawn(forceTeleportToBestZone) end
        SaveConfig()
    end
})

HatchTab:CreateToggle({
    Title = "Hide Egg UI & Animation",
    Default = Toggles.HideEgg,
    Callback = function(v) Toggles.HideEgg = v; SaveConfig() end
})

HatchTab:CreateButton({
    Title = "Stop Target Egg",
    Callback = function()
        targetEggName = nil
        Toggles.HatchBest = false
        SaveConfig()
    end
})

HatchTab:CreateSection({ Title = "Egg List" })

local eggOptions = {}
for _, e in ipairs(GLOBAL_EGG_DATA) do
    table.insert(eggOptions, string.format("[%d] %s", e.num, e.name))
end

HatchTab:CreateDropdown({
    Title = "Target Egg",
    Options = eggOptions,
    Default = nil,
    Callback = function(selected)
        if not selected then return end
        local eggName = string.match(selected, "%[%d+%]%s*(.+)")
        if not eggName then return end
        targetEggName = eggName
        Toggles.HatchBest = false
        SaveConfig()
        task.spawn(function()
            getgenv().IsMachineActionActive = true
            teleportToEgg(eggName)
            task.wait(0.6)
            pcall(function()
                Network:FindFirstChild("Eggs_RequestPurchase"):InvokeServer(eggName, getMaxHatchAmount())
            end)
            task.wait(0.2)
            getgenv().IsMachineActionActive = false
        end)
    end
})

EnchantTab:CreateSection({ Title = "Enchant Slots" })

local selectedEnchantSlot = 1

EnchantTab:CreateSlider({
    Title = "Target Slot",
    Min = 1, Max = 9, Default = 1,
    Callback = function(v) selectedEnchantSlot = v end
})

EnchantTab:CreateButton({
    Title = "Unequip Target Slot",
    Callback = function()
        SavedEnchants[selectedEnchantSlot] = nil
        SaveConfig()
        pcall(function() Network.Enchants_ClearSlot:FireServer(selectedEnchantSlot) end)
    end
})

EnchantTab:CreateSection({ Title = "Enchant List" })

EnchantTab:CreateDropdown({
    Title = "Select Enchant",
    Options = GLOBAL_ENCHANT_LIST,
    Default = nil,
    Callback = function(selected)
        if selected then
            SavedEnchants[selectedEnchantSlot] = selected
            SaveConfig()
        end
    end
})

InventoryTab:CreateSection({ Title = "Auto Bundles" })

InventoryTab:CreateToggle({
    Title = "Auto Bundle Enchants",
    Default = Toggles.AutoBundleEnchant,
    Callback = function(v) Toggles.AutoBundleEnchant = v; SaveConfig() end
})

InventoryTab:CreateToggle({
    Title = "Auto Bundle Potions",
    Default = Toggles.AutoBundlePotion,
    Callback = function(v) Toggles.AutoBundlePotion = v; SaveConfig() end
})

InventoryTab:CreateToggle({
    Title = "Auto Bundle Fruits",
    Default = Toggles.AutoBundleFruit,
    Callback = function(v) Toggles.AutoBundleFruit = v; SaveConfig() end
})

InventoryTab:CreateToggle({
    Title = "Auto Bundle Flags",
    Default = Toggles.AutoBundleFlag,
    Callback = function(v) Toggles.AutoBundleFlag = v; SaveConfig() end
})

InventoryTab:CreateSection({ Title = "Upgrade Potions" })

for _, pType in ipairs({ "Coins", "Damage", "Diamonds", "Lucky Eggs", "Treasure Hunter" }) do
    for t = 1, 6 do
        InventoryTab:CreateButton({
            Title = "Upgrade " .. pType .. " T" .. t,
            Callback = function()
                local uid = getLiveUID(pType, t, "Potion", 5)
                if uid then
                    pcall(function() Network.UpgradePotionsMachine_Activate:InvokeServer(uid, 1) end)
                end
            end
        })
    end
end

InventoryTab:CreateSection({ Title = "Upgrade Enchants" })

for _, eType in ipairs({ "Coins", "Criticals", "Diamonds", "Lucky Eggs", "Magnet", "Speed", "Strong Pets", "Tap Power", "Treasure Hunter" }) do
    for t = 1, 7 do
        InventoryTab:CreateButton({
            Title = "Upgrade " .. eType .. " T" .. t,
            Callback = function()
                local uid = getLiveUID(eType, t, "Enchant", 5)
                if uid then
                    pcall(function() Network.UpgradeEnchantsMachine_Activate:InvokeServer(uid, 1) end)
                end
            end
        })
    end
end

InventoryTab:CreateSection({ Title = "Drink Potions" })

for _, pType in ipairs({ "Coins", "Damage", "Diamonds", "Lucky Eggs", "Treasure Hunter" }) do
    for t = 1, 8 do
        InventoryTab:CreateButton({
            Title = "Drink " .. pType .. " T" .. t,
            Callback = function()
                local uid = getLiveUID(pType, t, "Potion", 1)
                if uid then
                    pcall(function() Network["Potions: Consume"]:FireServer(uid, 1) end)
                end
            end
        })
    end
end

WorldTab:CreateSection({ Title = "World Teleports" })

WorldTab:CreateButton({
    Title = "Jump to Spawn World (W1)",
    Callback = function() pcall(function() Network.World1Teleport:InvokeServer() end) end
})

WorldTab:CreateButton({
    Title = "Jump to Tech World (W2)",
    Callback = function() pcall(function() Network.World2Teleport:InvokeServer() end) end
})

WorldTab:CreateButton({
    Title = "Jump to Void World (W3)",
    Callback = function() pcall(function() Network.World3Teleport:InvokeServer() end) end
})

WorldTab:CreateSection({ Title = "Machines & Mailbox" })

WorldTab:CreateToggle({
    Title = "Auto Claim Mail Gift",
    Default = Toggles.AutoClaimMail,
    Callback = function(v) Toggles.AutoClaimMail = v; SaveConfig() end
})

WorldTab:CreateToggle({
    Title = "Auto Gold Pet (Current Egg)",
    Default = Toggles.GoldBest,
    Callback = function(v) Toggles.GoldBest = v; SaveConfig() end
})

WorldTab:CreateToggle({
    Title = "Auto Gold Pet (All)",
    Default = Toggles.GoldAll,
    Callback = function(v) Toggles.GoldAll = v; SaveConfig() end
})

WorldTab:CreateToggle({
    Title = "Auto Rainbow Pet (Current Egg)",
    Default = Toggles.RainBest,
    Callback = function(v) Toggles.RainBest = v; SaveConfig() end
})

WorldTab:CreateToggle({
    Title = "Auto Rainbow Pet (All)",
    Default = Toggles.RainAll,
    Callback = function(v) Toggles.RainAll = v; SaveConfig() end
})

WebhookTab:CreateSection({ Title = "Discord Webhook" })

WebhookTab:CreateTextbox({
    Title = "Webhook URL",
    Default = WHConfig.Url,
    Placeholder = "https://discord.com/api/webhooks/...",
    Callback = function(v) WHConfig.Url = v; SaveConfig() end
})

WebhookTab:CreateTextbox({
    Title = "Ping User ID",
    Default = WHConfig.PingID,
    Placeholder = "123456789",
    Callback = function(v) WHConfig.PingID = v; SaveConfig() end
})

WebhookTab:CreateTextbox({
    Title = "Rank Ping Target",
    Default = tostring(WHConfig.TargetRank),
    Placeholder = "0",
    Callback = function(v) WHConfig.TargetRank = tonumber(v) or 0; SaveConfig() end
})

WebhookTab:CreateToggle({
    Title = "Enable Rank Ping",
    Default = WHConfig.PingEnabled,
    Callback = function(v) WHConfig.PingEnabled = v; SaveConfig() end
})

WebhookTab:CreateButton({
    Title = "Test Webhook",
    Callback = function()
        if getgenv().Arasaka.Webhook then
            getgenv().Arasaka.Webhook.Test(WHConfig.Url)
        end
    end
})

ConfigTab:CreateSection({ Title = "Automation" })

ConfigTab:CreateToggle({
    Title = "Auto Buy Zones",
    Default = Toggles.BuyZone,
    Callback = function(v) Toggles.BuyZone = v; SaveConfig() end
})

ConfigTab:CreateToggle({
    Title = "Auto Collect Orbs",
    Default = Toggles.Orbs,
    Callback = function(v) Toggles.Orbs = v; SaveConfig() end
})

ConfigTab:CreateToggle({
    Title = "Auto Buy Pet Slots",
    Default = Toggles.BuySlot,
    Callback = function(v) Toggles.BuySlot = v; SaveConfig() end
})

ConfigTab:CreateSlider({
    Title = "Target Pet Slots",
    Min = 1, Max = 99, Default = getgenv().TargetEquipSlots,
    Callback = function(v) getgenv().TargetEquipSlots = v; SaveConfig() end
})

ConfigTab:CreateToggle({
    Title = "Auto Buy Egg Slots",
    Default = Toggles.BuyEggSlot,
    Callback = function(v) Toggles.BuyEggSlot = v; SaveConfig() end
})

ConfigTab:CreateSlider({
    Title = "Target Egg Slots",
    Min = 1, Max = 99, Default = getgenv().TargetEggSlots,
    Callback = function(v) getgenv().TargetEggSlots = v; SaveConfig() end
})

ConfigTab:CreateToggle({
    Title = "Auto Use Ultimate",
    Default = Toggles.Ultimate,
    Callback = function(v) Toggles.Ultimate = v; SaveConfig() end
})

ConfigTab:CreateSection({ Title = "Ultimate Selection" })

ConfigTab:CreateDropdown({
    Title = "Select Ultimate",
    Options = GLOBAL_ULTIMATE_LIST,
    Default = getgenv().TargetUltimate,
    Callback = function(v) getgenv().TargetUltimate = v; SaveConfig() end
})

ConfigTab:CreateToggle({
    Title = "Anti AFK",
    Default = Toggles.AntiAFK,
    Callback = function(v) Toggles.AntiAFK = v; SaveConfig() end
})

ConfigTab:CreateButton({
    Title = "Destroy Script",
    Callback = function()
        getgenv().Arasaka_IsRunning = false
        Window:Close()
    end
})

task.spawn(function()
    while task.wait(5) do
        if not getgenv().Arasaka_IsRunning then break end
        if getgenv().IsDoingSpecificQuest then continue end
        pcall(function()
            local s, d = pcall(function() return SaveModule.Get() end)
            if not s or not d or not d.Inventory or not d.Inventory.Pet then return end
            local pId = game.PlaceId
            local uSC = HAS_SUPER_COMPUTER and (pId == 16498369169 or pId == 17503543197 or pId == 140403681187145 or pId == 17720827393)
            if (Toggles.GoldBest or Toggles.GoldAll) and isAreaUnlocked(31) then
                local be = getBestEggNameForPlayer()
                local vP = be and getPetsFromEgg(be) or {}
                local nP = {}
                for u, petData in pairs(d.Inventory.Pet) do
                    if not petData.l and not petData.locked and not petData.lk and (tonumber(petData.pt) or 0) == 0 then
                        local isTarget = false
                        if Toggles.GoldAll then isTarget = true
                        elseif Toggles.GoldBest then
                            local id = tostring(petData.id)
                            for vp, _ in pairs(vP) do
                                if id == vp or string.find(id, vp) or string.find(vp, id) then isTarget = true; break end
                            end
                        end
                        if isTarget then
                            local cr = math.floor((tonumber(petData._am) or 1) / 10)
                            if cr > 0 then table.insert(nP, { uid = u, crafts = cr }) end
                        end
                    end
                end
                if #nP > 0 then
                    getgenv().IsDoingSpecificQuest = true
                    if uSC then
                        for _, rq in ipairs(nP) do safeMachineFire("GoldMachine", "GoldMachine_Activate", rq.uid, rq.crafts); task.wait(0.2) end
                    else
                        performMachineAction(function()
                            for _, rq in ipairs(nP) do safeMachineFire("GoldMachine", "GoldMachine_Activate", rq.uid, rq.crafts); task.wait(0.2) end
                        end, 31, "GoldMachine")
                    end
                    getgenv().IsDoingSpecificQuest = false
                    task.wait(1)
                end
            end
            if (Toggles.RainBest or Toggles.RainAll) and isAreaUnlocked(41) then
                local be = getBestEggNameForPlayer()
                local vP = be and getPetsFromEgg(be) or {}
                local gP = {}
                for u, petData in pairs(d.Inventory.Pet) do
                    if not petData.l and not petData.locked and not petData.lk and (tonumber(petData.pt) or 0) == 1 then
                        local isTarget = false
                        if Toggles.RainAll then isTarget = true
                        elseif Toggles.RainBest then
                            local id = tostring(petData.id)
                            for vp, _ in pairs(vP) do
                                if id == vp or string.find(id, vp) or string.find(vp, id) then isTarget = true; break end
                            end
                        end
                        if isTarget then
                            local cr = math.floor((tonumber(petData._am) or 1) / 10)
                            if cr > 0 then table.insert(gP, { uid = u, crafts = cr }) end
                        end
                    end
                end
                if #gP > 0 then
                    getgenv().IsDoingSpecificQuest = true
                    if uSC then
                        for _, rq in ipairs(gP) do safeMachineFire("RainbowMachine", "RainbowMachine_Activate", rq.uid, rq.crafts); task.wait(0.2) end
                    else
                        performMachineAction(function()
                            for _, rq in ipairs(gP) do safeMachineFire("RainbowMachine", "RainbowMachine_Activate", rq.uid, rq.crafts); task.wait(0.2) end
                        end, 41, "RainbowMachine")
                    end
                    getgenv().IsDoingSpecificQuest = false
                    task.wait(1)
                end
            end
        end)
    end
end)

local function KaitunClicker()
    pcall(function()
        local center = Window.Main.AbsolutePosition + (Window.Main.AbsoluteSize * 0.5)
        vim:SendMouseButtonEvent(center.X, center.Y, 0, true, game, 1)
        task.wait(0.05)
        vim:SendMouseButtonEvent(center.X, center.Y, 0, false, game, 1)
    end)
end

task.spawn(function()
    while task.wait(0.5) do
        if not getgenv().Arasaka_IsRunning then break end
        if Toggles.KaitunMode then
            pcall(function()
                for _, gui in ipairs(player.PlayerGui:GetChildren()) do
                    if gui:IsA("ScreenGui") and gui.Enabled then
                        local isS = false
                        for _, d in ipairs(gui:GetDescendants()) do
                            if d:IsA("TextLabel") and string.find(string.lower(d.Text), "pick 2 pets") then isS = true; break end
                        end
                        if isS then
                            local pB, oB = {}, nil
                            for _, d in ipairs(gui:GetDescendants()) do
                                if d:IsA("GuiButton") and d.Visible and d.AbsoluteSize.X > 30 then
                                    local isO = false
                                    if d:IsA("TextButton") and string.find(string.lower(d.Text), "ok") then isO = true end
                                    for _, c in ipairs(d:GetDescendants()) do
                                        if c:IsA("TextLabel") and string.find(string.lower(c.Text), "ok") then isO = true; break end
                                    end
                                    if isO then oB = d
                                    else
                                        local isC = false
                                        if d:IsA("TextButton") and (string.lower(d.Text) == "x" or string.find(string.lower(d.Text), "close")) then isC = true end
                                        if not isC then table.insert(pB, d) end
                                    end
                                end
                            end
                            table.sort(pB, function(a, b) return a.AbsolutePosition.X < b.AbsolutePosition.X end)
                            if #pB >= 2 then for i = 1, 2 do KaitunClicker(); task.wait(0.3) end end
                            if oB then task.wait(0.5); KaitunClicker() end
                            break
                        end
                    end
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(1) do
        if not getgenv().Arasaka_IsRunning then break end
        if (Toggles.BuyZone or Toggles.AutoFarmArea) and not getgenv().IsMachineActionActive and not Toggles.HatchBest and not targetEggName and not getgenv().IsDoingSpecificQuest then
            local cM, _ = getHighestUnlockedZoneNumAndInst()
            if cM then
                for _, z in ipairs(getAllZoneInstances()) do
                    local n = tonumber(string.match(z.Name, "^(%d+)"))
                    if n == cM + 1 then
                        local cl = string.match(z.Name, "%d+%s*|%s*(.+)") or z.Name
                        if cl then
                            pcall(function() Network:FindFirstChild("Zones_RequestPurchase"):InvokeServer(cl) end)
                            task.wait(0.5)
                            local nM, _ = getHighestUnlockedZoneNumAndInst()
                            if nM > cM then forceTeleportToBestZone() end
                        end
                        break
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if not getgenv().Arasaka_IsRunning then break end
        if (Toggles.AutoFarmArea or Toggles.Rank or Toggles.TpArea) and not getgenv().IsMachineActionActive and not Toggles.HatchBest and not targetEggName and not getgenv().IsDoingSpecificQuest and not getgenv().DoingLegendaryQuest then
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            local _, bI = getHighestUnlockedZoneNumAndInst()
            if hrp and bI then
                local zP = getZonePosition(bI)
                local bZone = getValidBreakZone(bI)
                local maxDist = 300
                if Toggles.AutoFarmArea then
                    maxDist = 50
                    if bZone then
                        if bZone:IsA("BasePart") then
                            maxDist = (math.max(bZone.Size.X, bZone.Size.Z) / 2) + 15
                        elseif bZone:IsA("Model") then
                            local ext = bZone:GetExtentsSize()
                            maxDist = (math.max(ext.X, ext.Z) / 2) + 15
                        end
                    end
                    if maxDist < 40 then maxDist = 40 end
                end
                if zP and (hrp.Position - zP).Magnitude > maxDist then
                    forceTeleportToBestZone()
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(2) do
        if not getgenv().Arasaka_IsRunning then break end
        if Toggles.Ultimate and getgenv().TargetUltimate and not getgenv().IsMachineActionActive then
            pcall(function() Network:FindFirstChild("Ultimates: Activate"):InvokeServer(getgenv().TargetUltimate) end)
        end
        if Toggles.AutoBundleEnchant then pcall(function() Network:FindFirstChild("GiftBag_Open"):InvokeServer("Enchant Bundle", 100) end) end
        if Toggles.AutoBundlePotion then pcall(function() Network:FindFirstChild("GiftBag_Open"):InvokeServer("Potion Bundle", 100) end) end
        if Toggles.AutoBundleFruit then pcall(function() Network:FindFirstChild("GiftBag_Open"):InvokeServer("Fruit Bundle", 100) end) end
        if Toggles.AutoBundleFlag then pcall(function() Network:FindFirstChild("GiftBag_Open"):InvokeServer("Flag Bundle", 100) end) end
    end
end)

local cachedBreakables = {}
local lastCacheTime = 0

task.spawn(function()
    while true do
        local delayTime = (getgenv().FastFarmSpeedMs or 300) * 0.001
        task.wait(delayTime)
        if not getgenv().Arasaka_IsRunning then break end
        if (Toggles.AutoFarmArea or Toggles.FastFarm) and not getgenv().IsMachineActionActive then
            pcall(function()
                local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                local bf = workspace:FindFirstChild("__THINGS") and workspace.__THINGS:FindFirstChild("Breakables")
                if not bf then return end
                local mP = hrp.Position
                local r = getgenv().FarmRadius or 150
                if tick() - lastCacheTime > 1.5 then
                    cachedBreakables = {}
                    for _, b in ipairs(bf:GetChildren()) do
                        pcall(function()
                            local dist = (mP - b:GetPivot().Position).Magnitude
                            if dist <= r then table.insert(cachedBreakables, { n = b, d = dist }) end
                        end)
                    end
                    lastCacheTime = tick()
                end
                local vt = {}
                for _, i in ipairs(cachedBreakables) do
                    if i.n and i.n.Parent then table.insert(vt, i) end
                end
                if #vt > 0 then
                    if Toggles.FastFarm then
                        local euids = {}
                        pcall(function()
                            if PlayerPet and type(PlayerPet.GetAll) == "function" then
                                for u, dt in pairs(PlayerPet.GetAll()) do
                                    if dt.owner == player then table.insert(euids, tostring(u)) end
                                end
                            end
                        end)
                        if #euids > 0 then
                            local pl = {}
                            local bI = 1
                            for _, u in ipairs(euids) do
                                pl[u] = vt[bI].n.Name
                                bI = bI + 1
                                if bI > #vt then bI = 1 end
                            end
                            pcall(function() Network:FindFirstChild("Breakables_JoinPetBulk"):FireServer(pl) end)
                        end
                        local mT = getgenv().FastFarmTargets or 10
                        local tH = 0
                        local dr = Network:FindFirstChild("Breakables_PlayerDealDamage")
                        if dr then
                            for _, bD in ipairs(vt) do
                                if tH >= mT then break end
                                tH = tH + 1
                                task.spawn(function() pcall(function() dr:FireServer(bD.n.Name) end) end)
                            end
                        end
                    else
                        table.sort(vt, function(a, b) return a.d < b.d end)
                        local tN = (getgenv().AutoTapMode == "Random") and vt[math.random(1, #vt)].n or vt[1].n
                        if tN and tN.Name then
                            pcall(function() Network:FindFirstChild("Breakables_PlayerDealDamage"):FireServer(tN.Name) end)
                        end
                    end
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(0.2) do
        if not getgenv().Arasaka_IsRunning then break end
        if (Toggles.Orbs or Toggles.AutoFarmArea) and not getgenv().IsMachineActionActive then
            pcall(function()
                local orbs = workspace:FindFirstChild("__THINGS") and workspace.__THINGS:FindFirstChild("Orbs")
                if orbs and #orbs:GetChildren() > 0 then
                    local ids = {}
                    for _, o in ipairs(orbs:GetChildren()) do table.insert(ids, tonumber(o.Name)) end
                    pcall(function() Network:FindFirstChild("Orbs: Collect"):FireServer(ids) end)
                    for _, o in ipairs(orbs:GetChildren()) do pcall(function() o:Destroy() end) end
                end
            end)
        end
    end
end)

task.spawn(function()
    getgenv().SlotFailCounts = getgenv().SlotFailCounts or { Pet = 0, Egg = 0 }
    getgenv().SlotLastFailTime = getgenv().SlotLastFailTime or { Pet = 0, Egg = 0 }
    getgenv().LastRank_Slot = getgenv().LastRank_Slot or getPlayerRank()
    while task.wait(3) do
        if not getgenv().Arasaka_IsRunning then break end
        local cR = getPlayerRank()
        if cR > getgenv().LastRank_Slot then
            getgenv().SlotFailCounts.Pet = 0
            getgenv().SlotFailCounts.Egg = 0
            getgenv().LastRank_Slot = cR
        end
        if Toggles.BuySlot then
            pcall(function()
                if getgenv().SlotFailCounts.Pet >= 3 and tick() - getgenv().SlotLastFailTime.Pet < 300 then return end
                local cP, pP = 4, 0
                if SaveModule then
                    local d = SaveModule.Get()
                    if d then
                        cP = d.MaxPetsEquipped or 4
                        pP = d.PetSlotsPurchased or d.PetsSlotsPurchased or d.PetEquipsPurchased or d.EquipSlotsPurchased or 0
                    end
                end
                if pP == 0 and cP > 4 then pP = cP - 4 end
                if cP < getgenv().TargetEquipSlots then
                    local tU = pP + 1
                    local preP = pP
                    pcall(function() Network:FindFirstChild("EquipSlotsMachine_RequestPurchase"):InvokeServer(tU) end)
                    pcall(function() Network:FindFirstChild("PetSlotsMachine_RequestPurchase"):InvokeServer(tU) end)
                    pcall(function() Network:FindFirstChild("PetsSlotsMachine_RequestPurchase"):InvokeServer(tU) end)
                    task.wait(1.5)
                    local pPo = preP
                    pcall(function()
                        local d = SaveModule.Get()
                        pPo = d.PetSlotsPurchased or d.PetsSlotsPurchased or d.PetEquipsPurchased or preP
                    end)
                    if pPo == preP then
                        getgenv().SlotFailCounts.Pet = getgenv().SlotFailCounts.Pet + 1
                        getgenv().SlotLastFailTime.Pet = tick()
                    else
                        getgenv().SlotFailCounts.Pet = 0
                    end
                end
            end)
        end
        if Toggles.BuyEggSlot then
            pcall(function()
                if getgenv().SlotFailCounts.Egg >= 3 and tick() - getgenv().SlotLastFailTime.Egg < 300 then return end
                local cE, pE = 1, 0
                if SaveModule then
                    local d = SaveModule.Get()
                    if d then
                        cE = d.EggHatchCount or 1
                        pE = d.EggSlotsPurchased or d.HatchSlotsPurchased or 0
                    end
                end
                if pE == 0 and cE > 1 then pE = cE - 1 end
                if cE < getgenv().TargetEggSlots then
                    local allowed = 0
                    pcall(function()
                        if RankCmds and RankCmds.GetEggSlotsBeforeRank then
                            allowed = RankCmds.GetEggSlotsBeforeRank(cR)
                        end
                        local rD = require(ReplicatedStorage.Library.Directory.Ranks)[cR]
                        if rD and rD.UnlockableEggSlots then allowed = allowed + rD.UnlockableEggSlots end
                    end)
                    if not (allowed > 0 and pE < allowed or true) then return end
                    local tU = pE + 1
                    local preP = pE
                    local eReq = Network:FindFirstChild("EggHatchSlotsMachine_RequestPurchase")
                    if eReq then
                        if HAS_SUPER_COMPUTER and (game.PlaceId == 16498369169 or game.PlaceId == 17503543197 or game.PlaceId == 140403681187145 or game.PlaceId == 17720827393) then
                            pcall(function() eReq:InvokeServer(tU) end)
                        else
                            performMachineAction(function() pcall(function() eReq:InvokeServer(tU) end) end, 8, "EggHatchSlotsMachine")
                        end
                    end
                    task.wait(1.5)
                    local pPo = preP
                    pcall(function()
                        local d = SaveModule.Get()
                        pPo = d.EggSlotsPurchased or d.HatchSlotsPurchased or preP
                    end)
                    if pPo == preP then
                        getgenv().SlotFailCounts.Egg = getgenv().SlotFailCounts.Egg + 1
                        getgenv().SlotLastFailTime.Egg = tick()
                    else
                        getgenv().SlotFailCounts.Egg = 0
                    end
                end
            end)
        end
    end
end)

local isHatching = false

task.spawn(function()
    while task.wait(0.1) do
        if not getgenv().Arasaka_IsRunning then break end
        if not isHatching then
            local tEgg = (Toggles.HatchBest and getBestEggNameForPlayer()) or targetEggName
            if tEgg then
                isHatching = true
                if Toggles.HatchBest then
                    local cZ = getCurrentAreaNumber()
                    local bZ = getHighestUnlockedZoneNumAndInst()
                    if cZ ~= bZ then
                        getgenv().IsMachineActionActive = true
                        forceTeleportToBestZone()
                        task.wait(0.5)
                        getgenv().IsMachineActionActive = false
                    end
                else
                    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                    local n = getgenv().EggNameToNumber[tEgg]
                    local cN = n and (tostring(n) .. " - Egg Capsule") or ""
                    local cap = nil
                    local t = workspace:FindFirstChild("__THINGS")
                    if t then
                        local pId = game.PlaceId
                        if pId == 17503543197 then cap = t:FindFirstChild("Eggs") and t.Eggs:FindFirstChild(cN, true) end
                        if not cap then cap = t:FindFirstChild("ZoneEggs") and t.ZoneEggs:FindFirstChild(cN, true) end
                        if not cap then cap = t:FindFirstChild("Eggs") and t.Eggs:FindFirstChild(cN, true) end
                    end
                    if hrp and cap and (hrp.Position - cap:GetPivot().Position).Magnitude > 50 then
                        getgenv().IsMachineActionActive = true
                        teleportToEgg(tEgg)
                        task.wait(0.5)
                        getgenv().IsMachineActionActive = false
                    end
                end
                task.spawn(function()
                    local bm = getMaxHatchAmount()
                    pcall(function() Network:FindFirstChild("Eggs_RequestPurchase"):InvokeServer(tEgg, bm) end)
                end)
                isHatching = false
            end
        end
    end
end)

task.spawn(function()
    local function SnipeMail()
        pcall(function() Network:FindFirstChild("Machines: Mark Approached"):FireServer("MailboxMachine") end)
        task.wait(0.2)
        local cAll = Network:FindFirstChild("Mailbox: Claim All")
        if cAll then
            local s, err = pcall(function() return cAll:InvokeServer() end)
            if err == "You must wait 30 seconds before using the mailbox!" then
                task.wait(31)
                if Toggles.AutoClaimMail and getgenv().Arasaka_IsRunning then return SnipeMail() end
            end
        end
    end
    while task.wait(2) do
        if not getgenv().Arasaka_IsRunning then break end
        if Toggles.AutoClaimMail then
            SnipeMail()
            task.wait(60)
        end
    end
end)

task.spawn(function()
    while task.wait(1) do
        if not getgenv().Arasaka_IsRunning then break end
        if Toggles.Rank and isAreaUnlocked(41) then
            pcall(function()
                if tick() - lastRankClaim >= 15 then
                    lastRankClaim = tick()
                    task.spawn(function()
                        local e = Network:FindFirstChild("Ranks_ClaimReward")
                        if e then
                            for i = 1, 99 do
                                pcall(function() e:FireServer(i) end)
                                task.wait(0.02)
                            end
                        end
                    end)
                end
                local qs = GetActiveRankQuests()
                local tq = nil
                local function skip(raw)
                    if raw then globalIgnoredQuests[raw] = tick() + 60 end
                end
                for _, q in ipairs(qs) do
                    if not (globalIgnoredQuests[q.raw] and tick() < globalIgnoredQuests[q.raw]) then
                        local text = q.txt
                        local matched = false
                        if RankConfig.Legendary and string.find(text, "legendary") then
                            getgenv().DoingLegendaryQuest = true
                            local be = getBestEggNameForPlayer()
                            if be then
                                local tE = be
                                local bI = 0
                                for i, e in ipairs(GLOBAL_EGG_DATA) do
                                    if e.name == be then bI = i; break end
                                end
                                local off = getgenv().LegendaryEggOffset or 1
                                tE = (bI > off) and GLOBAL_EGG_DATA[bI - off].name or GLOBAL_EGG_DATA[1].name
                                local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                                local n = getgenv().EggNameToNumber[tE]
                                local cN = n and (tostring(n) .. " - Egg Capsule") or ""
                                local cap = nil
                                local t = workspace:FindFirstChild("__THINGS")
                                if t then
                                    local pId = game.PlaceId
                                    if pId == 17503543197 then cap = t:FindFirstChild("Eggs") and t.Eggs:FindFirstChild(cN, true) end
                                    if not cap then cap = t:FindFirstChild("ZoneEggs") and t.ZoneEggs:FindFirstChild(cN, true) end
                                    if not cap then cap = t:FindFirstChild("Eggs") and t.Eggs:FindFirstChild(cN, true) end
                                end
                                if hrp and cap and (hrp.Position - cap:GetPivot().Position).Magnitude > 50 then
                                    getgenv().IsMachineActionActive = true
                                    teleportToEgg(tE)
                                    task.wait(0.5)
                                    getgenv().IsMachineActionActive = false
                                end
                                task.spawn(function() pcall(function() Network:FindFirstChild("Eggs_RequestPurchase"):InvokeServer(tE, getMaxHatchAmount()) end) end)
                                task.wait(0.1)
                            else
                                skip(q.raw)
                            end
                            matched = true
                        elseif RankConfig.Hatch and string.find(text, "hatch") and not string.find(text, "legendary") then
                            local be = getBestEggNameForPlayer()
                            if be then
                                if getCurrentAreaNumber() ~= getHighestUnlockedZoneNumAndInst() and not getgenv().DoingLegendaryQuest then
                                    getgenv().IsMachineActionActive = true
                                    forceTeleportToBestZone()
                                    task.wait(0.5)
                                    getgenv().IsMachineActionActive = false
                                end
                                task.spawn(function() pcall(function() Network:FindFirstChild("Eggs_RequestPurchase"):InvokeServer(be, getMaxHatchAmount()) end) end)
                                task.wait(0.1)
                            else
                                skip(q.raw)
                            end
                            matched = true
                        elseif RankConfig.Potion and (string.find(text, "drink") or string.find(text, "use")) and string.find(text, "potion") then
                            if tick() - lastItemUse >= 1.25 then
                                local tNum = tonumber(string.match(text, "tier%s+([ivx%d]+)")) or ROMAN_MAP[string.match(text, "tier%s+([ivx%d]+)")] or 1
                                local u = getOrderedConsumablePotionUID(tNum)
                                if u then
                                    for i = 1, q.remaining do
                                        pcall(function() Network:FindFirstChild("Potions: Consume"):FireServer(u, 1) end)
                                        task.wait(0.1)
                                    end
                                    lastItemUse = tick()
                                    skip(q.raw)
                                else
                                    skip(q.raw)
                                end
                            end
                            matched = true
                        elseif RankConfig.Area and (string.find(text, "unlock") or string.find(text, "reach")) and string.find(text, "area") then
                            local ca = getCurrentAreaNumber()
                            for _, z in ipairs(getAllZoneInstances()) do
                                if tonumber(string.match(z.Name, "^(%d+)")) == ca + 1 then
                                    local cl = string.match(z.Name, "%d+%s*|%s*(.+)") or z.Name
                                    if cl then
                                        pcall(function() Network:FindFirstChild("Zones_RequestPurchase"):InvokeServer(cl) end)
                                        task.wait(0.5)
                                        forceTeleportToBestZone()
                                    end
                                    break
                                end
                            end
                            matched = true
                        elseif RankConfig.UpPotion and ((string.find(text, "potion") and string.find(text, "upgrade")) or (string.find(text, "collect") and string.find(text, "potion"))) and isAreaUnlocked(13) then
                            local r = getBulkUpgradableItems("Potion", q.remaining, tonumber(string.match(text, "tier%s+([ivx%d]+)")) or ROMAN_MAP[string.match(text, "tier%s+([ivx%d]+)")])
                            if r and #r > 0 then
                                getgenv().IsDoingSpecificQuest = true
                                if HAS_SUPER_COMPUTER and (game.PlaceId == 16498369169 or game.PlaceId == 17503543197 or game.PlaceId == 140403681187145 or game.PlaceId == 17720827393) then
                                    for _, rq in ipairs(r) do safeMachineFire("UpgradePotionsMachine", "UpgradePotionsMachine_Activate", rq.uid, rq.crafts); task.wait(0.2) end
                                else
                                    performMachineAction(function()
                                        for _, rq in ipairs(r) do safeMachineFire("UpgradePotionsMachine", "UpgradePotionsMachine_Activate", rq.uid, rq.crafts); task.wait(0.2) end
                                    end, 13, "UpgradePotionsMachine")
                                end
                                getgenv().IsDoingSpecificQuest = false
                                skip(q.raw)
                            else
                                skip(q.raw)
                            end
                            matched = true
                        elseif RankConfig.UpEnchant and ((string.find(text, "enchant") and string.find(text, "upgrade")) or (string.find(text, "collect") and string.find(text, "enchant"))) and isAreaUnlocked(16) then
                            local r = getBulkUpgradableItems("Enchant", q.remaining, tonumber(string.match(text, "tier%s+([ivx%d]+)")) or ROMAN_MAP[string.match(text, "tier%s+([ivx%d]+)")])
                            if r and #r > 0 then
                                getgenv().IsDoingSpecificQuest = true
                                if HAS_SUPER_COMPUTER and (game.PlaceId == 16498369169 or game.PlaceId == 17503543197 or game.PlaceId == 140403681187145 or game.PlaceId == 17720827393) then
                                    for _, rq in ipairs(r) do safeMachineFire("UpgradeEnchantsMachine", "UpgradeEnchantsMachine_Activate", rq.uid, rq.crafts); task.wait(0.2) end
                                else
                                    performMachineAction(function()
                                        for _, rq in ipairs(r) do safeMachineFire("UpgradeEnchantsMachine", "UpgradeEnchantsMachine_Activate", rq.uid, rq.crafts); task.wait(0.2) end
                                    end, 16, "UpgradeEnchantsMachine")
                                end
                                getgenv().IsDoingSpecificQuest = false
                                skip(q.raw)
                            else
                                skip(q.raw)
                            end
                            matched = true
                        elseif RankConfig.Gold and string.find(text, "golden") and isAreaUnlocked(31) then
                            local be = getBestEggNameForPlayer()
                            local vP = be and getPetsFromEgg(be) or {}
                            local nP, tC = {}, 0
                            if SaveModule then
                                pcall(function()
                                    for u, d in pairs(SaveModule.Get().Inventory.Pet) do
                                        if not d.l and not d.locked and not d.lk and (tonumber(d.pt) or 0) == 0 then
                                            local id = tostring(d.id)
                                            local iM = false
                                            for vp, _ in pairs(vP) do
                                                if id == vp or string.find(id, vp) or string.find(vp, id) then iM = true; break end
                                            end
                                            if iM then
                                                local cr = math.floor((tonumber(d._am) or 1) / 10)
                                                if cr > 0 then table.insert(nP, { uid = u, crafts = cr }); tC = tC + cr end
                                            end
                                        end
                                    end
                                end)
                            end
                            if tC > 0 then
                                local cQ, cR = {}, q.remaining
                                table.sort(nP, function(a, b) return a.crafts > b.crafts end)
                                for _, it in ipairs(nP) do
                                    if cR > 0 then
                                        local tc = math.min(it.crafts, cR)
                                        table.insert(cQ, { uid = it.uid, amt = tc })
                                        cR = cR - tc
                                    end
                                end
                                if #cQ > 0 then
                                    getgenv().IsDoingSpecificQuest = true
                                    if HAS_SUPER_COMPUTER and (game.PlaceId == 16498369169 or game.PlaceId == 17503543197 or game.PlaceId == 140403681187145 or game.PlaceId == 17720827393) then
                                        for _, rq in ipairs(cQ) do safeMachineFire("GoldMachine", "GoldMachine_Activate", rq.uid, rq.amt); task.wait(0.2) end
                                    else
                                        performMachineAction(function()
                                            for _, rq in ipairs(cQ) do safeMachineFire("GoldMachine", "GoldMachine_Activate", rq.uid, rq.amt); task.wait(0.2) end
                                        end, 31, "GoldMachine")
                                    end
                                    getgenv().IsDoingSpecificQuest = false
                                end
                            end
                            if tC < q.remaining and be then
                                if getCurrentAreaNumber() ~= getHighestUnlockedZoneNumAndInst() then
                                    getgenv().IsMachineActionActive = true
                                    forceTeleportToBestZone()
                                    task.wait(0.5)
                                    getgenv().IsMachineActionActive = false
                                end
                                task.spawn(function() pcall(function() Network:FindFirstChild("Eggs_RequestPurchase"):InvokeServer(be, getMaxHatchAmount()) end) end)
                                task.wait(0.1)
                            end
                            matched = true
                        elseif RankConfig.Rainbow and string.find(text, "rainbow") and isAreaUnlocked(41) then
                            local be = getBestEggNameForPlayer()
                            local vP = be and getPetsFromEgg(be) or {}
                            local nP, gP, tC, tR = {}, {}, 0, 0
                            if SaveModule then
                                pcall(function()
                                    for u, d in pairs(SaveModule.Get().Inventory.Pet) do
                                        if not d.l and not d.locked and not d.lk then
                                            local pt = tonumber(d.pt) or 0
                                            if pt == 0 or pt == 1 then
                                                local id = tostring(d.id)
                                                local iM = false
                                                for vp, _ in pairs(vP) do
                                                    if id == vp or string.find(id, vp) or string.find(vp, id) then iM = true; break end
                                                end
                                                if iM then
                                                    local cr = math.floor((tonumber(d._am) or 1) / 10)
                                                    if cr > 0 then
                                                        if pt == 0 then table.insert(nP, { uid = u, crafts = cr }); tC = tC + cr
                                                        elseif pt == 1 then table.insert(gP, { uid = u, crafts = cr }); tR = tR + cr end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end)
                            end
                            local uSC = HAS_SUPER_COMPUTER and (game.PlaceId == 16498369169 or game.PlaceId == 17503543197 or game.PlaceId == 140403681187145 or game.PlaceId == 17720827393)
                            if tR > 0 then
                                local cQ, cR = {}, q.remaining
                                table.sort(gP, function(a, b) return a.crafts > b.crafts end)
                                for _, it in ipairs(gP) do
                                    if cR > 0 then
                                        local tc = math.min(it.crafts, cR)
                                        table.insert(cQ, { uid = it.uid, amt = tc })
                                        cR = cR - tc
                                    end
                                end
                                if #cQ > 0 then
                                    getgenv().IsDoingSpecificQuest = true
                                    if uSC then
                                        for _, rq in ipairs(cQ) do safeMachineFire("RainbowMachine", "RainbowMachine_Activate", rq.uid, rq.amt); task.wait(0.2) end
                                    else
                                        performMachineAction(function()
                                            for _, rq in ipairs(cQ) do safeMachineFire("RainbowMachine", "RainbowMachine_Activate", rq.uid, rq.amt); task.wait(0.2) end
                                        end, 41, "RainbowMachine")
                                    end
                                    getgenv().IsDoingSpecificQuest = false
                                end
                            end
                            if tR < q.remaining then
                                if tC > 0 then
                                    local mG = (q.remaining - tR) * 10
                                    local cQ, cR = {}, mG
                                    table.sort(nP, function(a, b) return a.crafts > b.crafts end)
                                    for _, it in ipairs(nP) do
                                        if cR > 0 then
                                            local tc = math.min(it.crafts, cR)
                                            table.insert(cQ, { uid = it.uid, amt = tc })
                                            cR = cR - tc
                                        end
                                    end
                                    if #cQ > 0 then
                                        getgenv().IsDoingSpecificQuest = true
                                        if uSC then
                                            for _, rq in ipairs(cQ) do safeMachineFire("GoldMachine", "GoldMachine_Activate", rq.uid, rq.amt); task.wait(0.2) end
                                        else
                                            performMachineAction(function()
                                                for _, rq in ipairs(cQ) do safeMachineFire("GoldMachine", "GoldMachine_Activate", rq.uid, rq.amt); task.wait(0.2) end
                                            end, 31, "GoldMachine")
                                        end
                                        getgenv().IsDoingSpecificQuest = false
                                    end
                                end
                                if (tR * 10 + tC) < (q.remaining * 10) and be then
                                    if getCurrentAreaNumber() ~= getHighestUnlockedZoneNumAndInst() then
                                        getgenv().IsMachineActionActive = true
                                        forceTeleportToBestZone()
                                        task.wait(0.5)
                                        getgenv().IsMachineActionActive = false
                                    end
                                    task.spawn(function() pcall(function() Network:FindFirstChild("Eggs_RequestPurchase"):InvokeServer(be, getMaxHatchAmount()) end) end)
                                    task.wait(0.1)
                                end
                            end
                            matched = true
                        elseif RankConfig.Flag and string.find(text, "flag") then
                            if tick() - lastItemUse >= 1.25 then
                                local fL = { "Fortune Flag", "Strength Flag", "Magnet Flag", "Coins Flag", "Hasty Flag", "Diamonds Flag", "Rainbow Flag", "Shiny Flag" }
                                local fn = false
                                for _, f in ipairs(fL) do
                                    local u = getMiscItemUID(f, false)
                                    if u then
                                        pcall(function() Network:FindFirstChild("FlexibleFlags_Consume"):InvokeServer(f, u) end)
                                        lastItemUse = tick()
                                        fn = true
                                        break
                                    end
                                end
                                if not fn then skip(q.raw) end
                            end
                            matched = true
                        elseif RankConfig.Fruit and string.find(text, "fruit") then
                            if tick() - lastItemUse >= 1.25 then
                                if lastRankFruitProgress ~= -1 and q.prog == lastRankFruitProgress then
                                    currentRankFruitIndex = currentRankFruitIndex + 1
                                    if currentRankFruitIndex > #rankFruitList then currentRankFruitIndex = 1 end
                                end
                                local fU = rankFruitList[currentRankFruitIndex]
                                local u = getMiscItemUID(fU, false) or getMiscItemUID(fU == "Rainbow Fruit" and "Rainbow" or fU:gsub(" ", ""), false)
                                if u then
                                    pcall(function() Network:FindFirstChild("Fruits: Consume"):FireServer(u, 1) end)
                                    lastItemUse = tick()
                                    lastRankFruitProgress = q.prog
                                else
                                    skip(q.raw)
                                end
                            end
                            matched = true
                        elseif RankConfig.Comet and string.find(text, "comet") then
                            if tick() - lastItemUse >= 1.25 then
                                local u = getMiscItemUID("Comet", false)
                                if u then
                                    for i = 1, q.remaining do
                                        pcall(function() Network:FindFirstChild("Comet_Spawn"):InvokeServer(u) end)
                                        task.wait(0.1)
                                    end
                                    lastItemUse = tick()
                                else
                                    skip(q.raw)
                                end
                            end
                            matched = true
                        elseif RankConfig.Jar and string.find(text, "coin") and string.find(text, "jar") then
                            if tick() - lastItemUse >= 1.25 then
                                local u = nil
                                for _, i in ipairs({ "Basic Coin Jar", "CoinJar", "Coin Jar", "Jar" }) do
                                    u = getMiscItemUID(i, false)
                                    if u then break end
                                end
                                if u then
                                    pcall(function() Network:FindFirstChild("CoinJar_Spawn"):InvokeServer(u) end)
                                    lastItemUse = tick()
                                else
                                    skip(q.raw)
                                end
                            end
                            matched = true
                        elseif RankConfig.Pinata and string.find(text, "pinata") then
                            if tick() - lastItemUse >= 1.25 then
                                local u = nil
                                for _, i in ipairs({ "Mini Pinata", "MiniPinata" }) do
                                    u = getMiscItemUID(i, false)
                                    if u then break end
                                end
                                if u then
                                    pcall(function() Network:FindFirstChild("MiniPinata_Consume"):InvokeServer(u) end)
                                    lastItemUse = tick()
                                else
                                    skip(q.raw)
                                end
                            end
                            matched = true
                        elseif RankConfig.Lucky and string.find(text, "lucky") and string.find(text, "block") then
                            if tick() - lastItemUse >= 1.25 then
                                local u = nil
                                for _, i in ipairs({ "Mini Lucky Block", "MiniLuckyBlock" }) do
                                    u = getMiscItemUID(i, false)
                                    if u then break end
                                end
                                if u then
                                    pcall(function() Network:FindFirstChild("MiniLuckyBlock_Consume"):InvokeServer(u) end)
                                    lastItemUse = tick()
                                else
                                    skip(q.raw)
                                end
                            end
                            matched = true
                        end
                        if matched then
                            tq = q
                            break
                        end
                    end
                end
                if not tq and getgenv().DoingLegendaryQuest then
                    getgenv().DoingLegendaryQuest = false
                    getgenv().IsMachineActionActive = true
                    forceTeleportToBestZone()
                    task.wait(0.5)
                    getgenv().IsMachineActionActive = false
                end
            end)
        end
    end
end)

local originalEggFuncs = {}

local function hookEggAnimations()
    if type(getgc) ~= "function" then return end
    pcall(function()
        for _, v in pairs(getgc(true)) do
            if type(v) == "table" then
                if rawget(v, "PlayEggAnimation") or rawget(v, "OpenEgg") or rawget(v, "PlayHatch") or rawget(v, "ShowEgg") then
                    originalEggFuncs.PlayEggAnimation = originalEggFuncs.PlayEggAnimation or rawget(v, "PlayEggAnimation")
                    originalEggFuncs.OpenEgg = originalEggFuncs.OpenEgg or rawget(v, "OpenEgg")
                    originalEggFuncs.PlayHatch = originalEggFuncs.PlayHatch or rawget(v, "PlayHatch")
                    originalEggFuncs.ShowEgg = originalEggFuncs.ShowEgg or rawget(v, "ShowEgg")
                    if type(rawget(v, "PlayEggAnimation")) == "function" then
                        rawset(v, "PlayEggAnimation", function(...)
                            if Toggles.HideEgg then return end
                            return originalEggFuncs.PlayEggAnimation(...)
                        end)
                    end
                    if type(rawget(v, "OpenEgg")) == "function" then
                        rawset(v, "OpenEgg", function(...)
                            if Toggles.HideEgg then return end
                            return originalEggFuncs.OpenEgg(...)
                        end)
                    end
                    if type(rawget(v, "PlayHatch")) == "function" then
                        rawset(v, "PlayHatch", function(...)
                            if Toggles.HideEgg then return end
                            return originalEggFuncs.PlayHatch(...)
                        end)
                    end
                    if type(rawget(v, "ShowEgg")) == "function" then
                        rawset(v, "ShowEgg", function(...)
                            if Toggles.HideEgg then return end
                            return originalEggFuncs.ShowEgg(...)
                        end)
                    end
                end
            end
        end
    end)
end

task.spawn(hookEggAnimations)

task.spawn(function()
    while task.wait(0.05) do
        if not getgenv().Arasaka_IsRunning then break end
        if Toggles.HideEgg then
            pcall(function()
                local cam = workspace.CurrentCamera
                local char = player.Character
                if cam and char and char:FindFirstChild("Humanoid") then
                    if cam.CameraType == Enum.CameraType.Scriptable then
                        cam.CameraType = Enum.CameraType.Custom
                        cam.CameraSubject = char.Humanoid
                    end
                end
                for _, n in ipairs({ "EggOpenAnimation", "EggHatch", "HatchUI" }) do
                    local g = player.PlayerGui:FindFirstChild(n)
                    if g then
                        if g:IsA("ScreenGui") then g.Enabled = false end
                        for _, c in ipairs(g:GetChildren()) do
                            if c:IsA("GuiObject") then
                                c.Position = UDim2.new(9999, 0, 9999, 0)
                                c.Visible = false
                            end
                        end
                    end
                end
                for _, uN in ipairs({ "Main", "MainUI", "HUD", "Bottom", "Right", "Left" }) do
                    local mG = player.PlayerGui:FindFirstChild(uN)
                    if mG and mG:IsA("ScreenGui") and not mG.Enabled then
                        mG.Enabled = true
                    end
                end
            end)
        else
            pcall(function()
                for _, n in ipairs({ "EggOpenAnimation", "EggHatch", "HatchUI" }) do
                    local g = player.PlayerGui:FindFirstChild(n)
                    if g then
                        for _, c in ipairs(g:GetChildren()) do
                            if c:IsA("GuiObject") and c.Position == UDim2.new(9999, 0, 9999, 0) then
                                c.Position = UDim2.new(0.5, 0, 0.5, 0)
                                c.Visible = true
                            end
                        end
                    end
                end
            end)
        end
    end
end)

task.spawn(function()
    local wRUV = false
    while task.wait(1) do
        if not getgenv().Arasaka_IsRunning then break end
        local iRUV = false
        pcall(function()
            for _, g in ipairs(player.PlayerGui:GetChildren()) do
                if g:IsA("ScreenGui") and g.Enabled and string.find(string.lower(g.Name), "rankup") then
                    iRUV = true
                    break
                end
            end
        end)
        if iRUV and not wRUV then
            if WHConfig.PingEnabled and WHConfig.Url ~= "" and WHConfig.TargetRank > 0 and not WHConfig.HasSentRank then
                task.wait(1)
                local cR = getPlayerRank()
                if cR >= WHConfig.TargetRank then
                    WHConfig.HasSentRank = true
                    if getgenv().Arasaka.Webhook then
                        pcall(function()
                            getgenv().Arasaka.Webhook.RankUp(WHConfig.Url, WHConfig.PingID, player.Name, cR, nil)
                        end)
                    end
                end
            end
        end
        wRUV = iRUV
    end
end)
