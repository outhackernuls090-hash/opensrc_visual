local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local PacketRemote
local success, err = pcall(function()
    PacketRemote = ReplicatedStorage:WaitForChild("SharedModules", 10):WaitForChild("Packet", 10):WaitForChild("RemoteEvent", 10)
end)
if not success or not PacketRemote then
    warn("PacketRemote not found, some features may be disabled")
    PacketRemote = nil
end

local Inventory
for i = 1, 30 do
    Inventory = Player:FindFirstChild("Inventory")
    if Inventory then break end
    task.wait(1)
end
if not Inventory then
    warn("Inventory not found, auto-sell features disabled")
end

local SeedList = {"Carrot", "Strawberry", "Blueberry", "Tulip", "Tomato", "Apple", "Bamboo", "Corn", "Cactus", "Pineapple", "Mushroom", "Green Bean", "Banana", "Grape", "Coconut", "Mango", "Dragon Fruit", "Acorn", "Cherry", "Sunflower", "Venus Fly Trap", "Pomegranate", "Poison Apple", "Moon Bloom", "Dragon's Breath", "Ghost Pepper", "Poison Ivy", "Baby Cactus", "Glow Mushroom", "Romanesco", "Horned Melon"}
local GearList = {"Common Watering Can", "Common Sprinkler", "Sign", "Lantern", "Wheelbarrow", "Uncommon Sprinkler", "Rare Sprinkler", "Legendary Sprinkler", "Super Sprinkler", "Trowel", "Speed Mushroom", "Jump Mushroom", "Gnome", "Shrink Mushroom", "Supersize Mushroom", "Invisibility Mushroom", "Teleporter", "Super Watering Can", "Basic Pot", "Flashbang"}
local FruitList = {"Carrot", "Strawberry", "Blueberry", "Tulip", "Tomato", "Apple", "Bamboo", "Corn", "Cactus", "Pineapple", "Mushroom", "Green Bean", "Banana", "Grape", "Coconut", "Mango", "Dragon Fruit", "Acorn", "Cherry", "Sunflower", "Venus Fly Trap", "Pomegranate", "Poison Apple", "Moon Bloom", "Dragon's Breath", "Ghost Pepper", "Poison Ivy", "Baby Cactus", "Glow Mushroom", "Romanesco", "Horned Melon"}

local EternalDarkness = {
    Name = "Eternal Darkness",
    Accent = Color3.fromHex("#0a0a0f"),
    Background = Color3.fromHex("#060608"),
    Text = Color3.fromHex("#e8e8f0"),
    TextDark = Color3.fromHex("#8a8a9e"),
    ElementBackground = Color3.fromHex("#0f0f14"),
    ElementBackgroundHover = Color3.fromHex("#16161e"),
    ElementStroke = Color3.fromHex("#1e1e28"),
    Primary = Color3.fromHex("#7c3aed"),
    PrimaryHover = Color3.fromHex("#8b5cf6"),
    Success = Color3.fromHex("#10b981"),
    Warning = Color3.fromHex("#f59e0b"),
    Danger = Color3.fromHex("#ef4444"),
    Info = Color3.fromHex("#3b82f6"),
    PanelBackground = Color3.fromHex("#0c0c12"),
    TabBackground = Color3.fromHex("#0a0a0f"),
    TabBackgroundActive = Color3.fromHex("#16161e"),
    ToggleEnabled = Color3.fromHex("#7c3aed"),
    ToggleDisabled = Color3.fromHex("#2a2a35"),
    SliderBar = Color3.fromHex("#1e1e28"),
    SliderFill = Color3.fromHex("#7c3aed"),
    DropdownBackground = Color3.fromHex("#0f0f14"),
    DropdownHover = Color3.fromHex("#1a1a24"),
    NotificationBackground = Color3.fromHex("#0c0c12"),
    NotificationSuccess = Color3.fromHex("#10b981"),
    NotificationError = Color3.fromHex("#ef4444"),
    NotificationWarning = Color3.fromHex("#f59e0b"),
    NotificationInfo = Color3.fromHex("#3b82f6"),
    Shadow = Color3.fromHex("#000000"),
    Border = Color3.fromHex("#1e1e28"),
    Placeholder = Color3.fromHex("#5a5a6e"),
    ScrollBar = Color3.fromHex("#2a2a35"),
    ScrollBarHover = Color3.fromHex("#3a3a4e"),
}

WindUI:AddTheme(EternalDarkness)
WindUI:SetTheme("Eternal Darkness")

local Window = WindUI:CreateWindow({
    Title = "Eternal Hub",
    Icon = "infinity",
    Author = "Eternal Darkness Corp.",
    Folder = "EternalHub",
    Size = UDim2.fromOffset(620, 460),
    MinSize = Vector2.new(520, 360),
    MaxSize = Vector2.new(900, 600),
    Transparent = true,
    Resizable = true,
    Acrylic = false,
    ScrollBarEnabled = true,
    SideBarWidth = 200,
    ToggleKey = Enum.KeyCode.RightShift,
    Topbar = { Height = 52, ButtonsType = "Default" },
    OpenButton = {
        Enabled = true,
        Icon = "infinity",
        Title = "Eternal Hub",
        Position = UDim2.new(0, 20, 0, 20),
        Draggable = true,
        OnlyMobile = false,
        CornerRadius = UDim.new(1, 0),
        StrokeThickness = 2,
        Scale = 1,
        Color = ColorSequence.new(Color3.fromHex("#7c3aed"), Color3.fromHex("#3b82f6")),
    },
})

local Threads = {}
local States = {}
local NoclipConnection

local function KillThread(name)
    if Threads[name] then
        task.cancel(Threads[name])
        Threads[name] = nil
    end
end

local function SetNoclip(enabled)
    if NoclipConnection then
        NoclipConnection:Disconnect()
        NoclipConnection = nil
    end
    if enabled then
        NoclipConnection = RunService.Stepped:Connect(function()
            if Player.Character then
                for _, part in pairs(Player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end
end

local LastPacketTime = 0
local PacketCooldown = 0.15

local function SendPacket(data)
    if not PacketRemote then
        return false, "PacketRemote not available"
    end
    
    local currentTime = tick()
    if currentTime - LastPacketTime < PacketCooldown then
        task.wait(PacketCooldown - (currentTime - LastPacketTime))
    end
    
    local success, err = pcall(function()
        if type(data) ~= "string" then
            error("Invalid packet data type")
        end
        PacketRemote:FireServer(buffer.fromstring(data))
    end)
    
    LastPacketTime = tick()
    return success, err
end

local function GetCharacter()
    if not Player.Character then
        Player.CharacterAdded:Wait()
    end
    Character = Player.Character
    if not Character then return nil, nil, nil end
    
    local hum = Character:FindFirstChild("Humanoid")
    local hrp = Character:FindFirstChild("HumanoidRootPart")
    
    if hum then Humanoid = hum end
    if hrp then HumanoidRootPart = hrp end
    
    return Character, hum, hrp
end

local function Notify(title, content, icon, duration)
    WindUI:Notify({
        Title = title,
        Content = content,
        Icon = icon or "info",
        Duration = duration or 4,
    })
end

local MainTab = Window:Tab({ Title = "Main", Icon = "home" })
local FarmingTab = Window:Tab({ Title = "Farming", Icon = "wheat" })
local AutoBuyTab = Window:Tab({ Title = "Auto Buy", Icon = "shopping-cart" })
local MiscTab = Window:Tab({ Title = "Misc", Icon = "settings" })
local StatsTab = Window:Tab({ Title = "Stats", Icon = "bar-chart" })

MainTab:Section({ Title = "Movement", Icon = "move" })

MainTab:Toggle({
    Title = "Speed Hack",
    Desc = "Modify your walk speed",
    Icon = "zap",
    Value = false,
    Flag = "SpeedHack",
    Callback = function(state)
        States.SpeedHack = state
        if state then
            Threads.SpeedHack = task.spawn(function()
                while States.SpeedHack do
                    local char, hum = GetCharacter()
                    if hum and hum.Parent then
                        hum.WalkSpeed = States.SpeedValue or 32
                    end
                    task.wait(0.1)
                end
            end)
        else
            KillThread("SpeedHack")
            local char, hum = GetCharacter()
            if hum then hum.WalkSpeed = 16 end
        end
    end,
})

MainTab:Slider({
    Title = "Speed Value",
    Icon = "gauge",
    Value = { Min = 16, Max = 120, Default = 32 },
    Step = 1,
    Flag = "SpeedValue",
    Callback = function(value)
        States.SpeedValue = value
    end,
})

MainTab:Toggle({
    Title = "Jump Power",
    Desc = "Modify your jump height",
    Icon = "arrow-up",
    Value = false,
    Flag = "JumpPower",
    Callback = function(state)
        States.JumpPower = state
        if state then
            Threads.JumpPower = task.spawn(function()
                while States.JumpPower do
                    local char, hum = GetCharacter()
                    if hum and hum.Parent then
                        hum.JumpPower = States.JumpValue or 75
                    end
                    task.wait(0.1)
                end
            end)
        else
            KillThread("JumpPower")
            local char, hum = GetCharacter()
            if hum then hum.JumpPower = 50 end
        end
    end,
})

MainTab:Slider({
    Title = "Jump Value",
    Icon = "arrow-up-circle",
    Value = { Min = 50, Max = 200, Default = 75 },
    Step = 1,
    Flag = "JumpValue",
    Callback = function(value)
        States.JumpValue = value
    end,
})

MainTab:Toggle({
    Title = "Infinite Jump",
    Desc = "Jump infinitely in the air",
    Icon = "cloud-lightning",
    Value = false,
    Flag = "InfiniteJump",
    Callback = function(state)
        States.InfiniteJump = state
        if state then
            Threads.InfiniteJump = task.spawn(function()
                while States.InfiniteJump do
                    if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.Space) then
                        local char, hum = GetCharacter()
                        if hum and hum.Parent then
                            hum:ChangeState(Enum.HumanoidStateType.Jumping)
                        end
                    end
                    task.wait(0.05)
                end
            end)
        else
            KillThread("InfiniteJump")
        end
    end,
})

MainTab:Toggle({
    Title = "Noclip",
    Desc = "Walk through walls",
    Icon = "ghost",
    Value = false,
    Flag = "Noclip",
    Callback = function(state)
        SetNoclip(state)
        if state then
            Notify("Noclip Enabled", "You can now walk through walls", "ghost")
        end
    end,
})

MainTab:Toggle({
    Title = "Anti AFK",
    Desc = "Prevents being kicked for inactivity",
    Icon = "shield",
    Value = false,
    Flag = "AntiAFK",
    Callback = function(state)
        States.AntiAFK = state
        if state then
            Threads.AntiAFK = task.spawn(function()
                while States.AntiAFK do
                    VirtualInputManager:SendMouseMoveEvent(0, 0, game)
                    task.wait(60)
                end
            end)
        else
            KillThread("AntiAFK")
        end
    end,
})

MainTab:Section({ Title = "Teleport", Icon = "map-pin" })

MainTab:Button({
    Title = "Teleport to Shop",
    Desc = "Instant teleport to the seed shop",
    Icon = "store",
    Callback = function()
        local char, hum, hrp = GetCharacter()
        if hrp then
            local shop = Workspace:FindFirstChild("Shop") or Workspace:FindFirstChild("Store")
            if shop then
                hrp.CFrame = shop:GetPivot() + Vector3.new(0, 5, 0)
                Notify("Teleported", "Arrived at the shop", "map-pin")
            else
                hrp.CFrame = CFrame.new(0, 50, 0)
                Notify("Teleported", "Arrived at spawn area", "map-pin")
            end
        end
    end,
})

MainTab:Button({
    Title = "Teleport to Gardens",
    Desc = "Instant teleport to your garden plots",
    Icon = "flower-2",
    Callback = function()
        local char, hum, hrp = GetCharacter()
        if hrp then
            local gardens = Workspace:FindFirstChild("Gardens")
            if gardens and gardens:GetChildren()[1] then
                hrp.CFrame = gardens:GetChildren()[1]:GetPivot() + Vector3.new(0, 5, 0)
                Notify("Teleported", "Arrived at gardens", "map-pin")
            else
                Notify("Error", "No gardens found", "x")
            end
        end
    end,
})

MainTab:Button({
    Title = "Teleport to Sell Point",
    Desc = "Instant teleport to sell your fruits",
    Icon = "coins",
    Callback = function()
        local char, hum, hrp = GetCharacter()
        if hrp then
            local sell = Workspace:FindFirstChild("Sell") or Workspace:FindFirstChild("SellPoint")
            if sell then
                hrp.CFrame = sell:GetPivot() + Vector3.new(0, 5, 0)
                Notify("Teleported", "Arrived at sell point", "map-pin")
            else
                hrp.CFrame = CFrame.new(50, 50, 50)
                Notify("Teleported", "Arrived at default sell area", "map-pin")
            end
        end
    end,
})

FarmingTab:Section({ Title = "Auto Harvest", Icon = "scissors" })

FarmingTab:Toggle({
    Title = "Auto Harvest",
    Desc = "Automatically harvests all ready crops",
    Icon = "wheat",
    Value = false,
    Flag = "AutoHarvest",
    Callback = function(state)
        States.AutoHarvest = state
        if state then
            SetNoclip(true)
            Threads.AutoHarvest = task.spawn(function()
                while States.AutoHarvest do
                    local gardens = Workspace:FindFirstChild("Gardens")
                    if gardens then
                        for _, plot in pairs(gardens:GetChildren()) do
                            if not States.AutoHarvest then break end
                            for _, descendant in pairs(plot:GetDescendants()) do
                                if descendant.Name == "HarvestPart" and descendant:IsA("BasePart") then
                                    local char, hum, hrp = GetCharacter()
                                    if hrp and hrp.Parent then
                                        if (hrp.Position - descendant.Position).Magnitude > 5 then
                                            local tween = TweenService:Create(hrp, TweenInfo.new(0.08, Enum.EasingStyle.Linear), {CFrame = descendant.CFrame})
                                            tween:Play()
                                            tween.Completed:Wait()
                                        end
                                        task.wait(math.random(3, 8) / 100)
                                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                                        task.wait(0.05)
                                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                                        task.wait(math.random(5, 10) / 100)
                                    end
                                end
                            end
                        end
                    end
                    task.wait(0.1)
                end
            end)
        else
            KillThread("AutoHarvest")
            if not States.AutoPlant then
                SetNoclip(false)
            end
        end
    end,
})

FarmingTab:Toggle({
    Title = "Auto Plant",
    Desc = "Automatically plants seeds in empty plots",
    Icon = "sprout",
    Value = false,
    Flag = "AutoPlant",
    Callback = function(state)
        States.AutoPlant = state
        if state then
            SetNoclip(true)
            Threads.AutoPlant = task.spawn(function()
                while States.AutoPlant do
                    local gardens = Workspace:FindFirstChild("Gardens")
                    if gardens then
                        for _, plot in pairs(gardens:GetChildren()) do
                            if not States.AutoPlant then break end
                            for _, descendant in pairs(plot:GetDescendants()) do
                                if descendant.Name == "PlantPart" or descendant.Name == "Soil" then
                                    if descendant:IsA("BasePart") then
                                        local char, hum, hrp = GetCharacter()
                                        if hrp and hrp.Parent then
                                            if (hrp.Position - descendant.Position).Magnitude > 5 then
                                                local tween = TweenService:Create(hrp, TweenInfo.new(0.08, Enum.EasingStyle.Linear), {CFrame = descendant.CFrame})
                                                tween:Play()
                                                tween.Completed:Wait()
                                            end
                                            task.wait(math.random(3, 8) / 100)
                                            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                                            task.wait(0.05)
                                            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                                            task.wait(math.random(5, 10) / 100)
                                        end
                                    end
                                end
                            end
                        end
                    end
                    task.wait(0.2)
                end
            end)
        else
            KillThread("AutoPlant")
            if not States.AutoHarvest then
                SetNoclip(false)
            end
        end
    end,
})

FarmingTab:Toggle({
    Title = "Auto Water",
    Desc = "Automatically waters all plants",
    Icon = "droplets",
    Value = false,
    Flag = "AutoWater",
    Callback = function(state)
        States.AutoWater = state
        if state then
            Threads.AutoWater = task.spawn(function()
                while States.AutoWater do
                    local gardens = Workspace:FindFirstChild("Gardens")
                    if gardens then
                        for _, plot in pairs(gardens:GetChildren()) do
                            if not States.AutoWater then break end
                            for _, descendant in pairs(plot:GetDescendants()) do
                                if descendant.Name == "WaterPart" or descendant.Name == "Plant" then
                                    if descendant:IsA("BasePart") then
                                        local char, hum, hrp = GetCharacter()
                                        if hrp and hrp.Parent then
                                            if (hrp.Position - descendant.Position).Magnitude > 5 then
                                                local tween = TweenService:Create(hrp, TweenInfo.new(0.08, Enum.EasingStyle.Linear), {CFrame = descendant.CFrame})
                                                tween:Play()
                                                tween.Completed:Wait()
                                            end
                                            task.wait(math.random(3, 8) / 100)
                                            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                                            task.wait(0.05)
                                            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                                            task.wait(math.random(5, 10) / 100)
                                        end
                                    end
                                end
                            end
                        end
                    end
                    task.wait(0.3)
                end
            end)
        else
            KillThread("AutoWater")
        end
    end,
})

FarmingTab:Toggle({
    Title = "Auto Fertilize",
    Desc = "Automatically fertilizes all plants",
    Icon = "flask-conical",
    Value = false,
    Flag = "AutoFertilize",
    Callback = function(state)
        States.AutoFertilize = state
        if state then
            Threads.AutoFertilize = task.spawn(function()
                while States.AutoFertilize do
                    local gardens = Workspace:FindFirstChild("Gardens")
                    if gardens then
                        for _, plot in pairs(gardens:GetChildren()) do
                            if not States.AutoFertilize then break end
                            for _, descendant in pairs(plot:GetDescendants()) do
                                if descendant.Name == "FertilizePart" or descendant.Name == "FertilizerSpot" then
                                    if descendant:IsA("BasePart") then
                                        local char, hum, hrp = GetCharacter()
                                        if hrp and hrp.Parent then
                                            if (hrp.Position - descendant.Position).Magnitude > 5 then
                                                local tween = TweenService:Create(hrp, TweenInfo.new(0.08, Enum.EasingStyle.Linear), {CFrame = descendant.CFrame})
                                                tween:Play()
                                                tween.Completed:Wait()
                                            end
                                            task.wait(math.random(3, 8) / 100)
                                            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                                            task.wait(0.05)
                                            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                                            task.wait(math.random(5, 10) / 100)
                                        end
                                    end
                                end
                            end
                        end
                    end
                    task.wait(0.3)
                end
            end)
        else
            KillThread("AutoFertilize")
        end
    end,
})

FarmingTab:Section({ Title = "Smart Farming", Icon = "brain" })

FarmingTab:Toggle({
    Title = "Smart Farm Loop",
    Desc = "Auto harvest, plant, water, and fertilize in sequence",
    Icon = "repeat",
    Value = false,
    Flag = "SmartFarm",
    Callback = function(state)
        States.SmartFarm = state
        if state then
            SetNoclip(true)
            Threads.SmartFarm = task.spawn(function()
                while States.SmartFarm do
                    local gardens = Workspace:FindFirstChild("Gardens")
                    if gardens then
                        for _, plot in pairs(gardens:GetChildren()) do
                            if not States.SmartFarm then break end

                            for _, descendant in pairs(plot:GetDescendants()) do
                                if descendant.Name == "HarvestPart" and descendant:IsA("BasePart") then
                                    local char, hum, hrp = GetCharacter()
                                    if hrp and hrp.Parent then
                                        local tween = TweenService:Create(hrp, TweenInfo.new(0.08, Enum.EasingStyle.Linear), {CFrame = descendant.CFrame})
                                        tween:Play()
                                        tween.Completed:Wait()
                                        task.wait(math.random(3, 8) / 100)
                                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                                        task.wait(0.05)
                                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                                        task.wait(0.1)
                                    end
                                end
                            end

                            for _, descendant in pairs(plot:GetDescendants()) do
                                if descendant.Name == "PlantPart" or descendant.Name == "Soil" then
                                    if descendant:IsA("BasePart") then
                                        local char, hum, hrp = GetCharacter()
                                        if hrp and hrp.Parent then
                                            local tween = TweenService:Create(hrp, TweenInfo.new(0.08, Enum.EasingStyle.Linear), {CFrame = descendant.CFrame})
                                            tween:Play()
                                            tween.Completed:Wait()
                                            task.wait(math.random(3, 8) / 100)
                                            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                                            task.wait(0.05)
                                            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                                            task.wait(0.1)
                                        end
                                    end
                                end
                            end

                            for _, descendant in pairs(plot:GetDescendants()) do
                                if descendant.Name == "WaterPart" or descendant.Name == "Plant" then
                                    if descendant:IsA("BasePart") then
                                        local char, hum, hrp = GetCharacter()
                                        if hrp and hrp.Parent then
                                            local tween = TweenService:Create(hrp, TweenInfo.new(0.08, Enum.EasingStyle.Linear), {CFrame = descendant.CFrame})
                                            tween:Play()
                                            tween.Completed:Wait()
                                            task.wait(math.random(3, 8) / 100)
                                            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                                            task.wait(0.05)
                                            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                                            task.wait(0.1)
                                        end
                                    end
                                end
                            end
                        end
                    end
                    task.wait(0.5)
                end
            end)
        else
            KillThread("SmartFarm")
            SetNoclip(false)
        end
    end,
})

FarmingTab:Slider({
    Title = "Farm Delay",
    Desc = "Delay between farm actions (ms)",
    Icon = "clock",
    Value = { Min = 50, Max = 1000, Default = 100 },
    Step = 10,
    Flag = "FarmDelay",
    Callback = function(value)
        States.FarmDelay = value / 1000
    end,
})

AutoBuyTab:Section({ Title = "Seeds", Icon = "package" })

AutoBuyTab:Toggle({
    Title = "Auto Buy All Seeds",
    Desc = "Automatically purchases every seed type",
    Icon = "shopping-bag",
    Value = false,
    Flag = "AutoBuySeeds",
    Callback = function(state)
        States.AutoBuySeeds = state
        if state then
            Threads.AutoBuySeeds = task.spawn(function()
                while States.AutoBuySeeds do
                    for _, name in pairs(SeedList) do
                        if not States.AutoBuySeeds then break end
                        local success, err = SendPacket("g\000" .. string.char(#name) .. name)
                        if not success then
                            warn("Packet failed: " .. tostring(err))
                            task.wait(1)
                        end
                        task.wait(0.2)
                    end
                    task.wait(1)
                end
            end)
        else
            KillThread("AutoBuySeeds")
        end
    end,
})

AutoBuyTab:Dropdown({
    Title = "Select Seed to Buy",
    Desc = "Choose specific seed to auto-buy",
    Icon = "list",
    Values = SeedList,
    Value = SeedList[1],
    Multi = false,
    Flag = "SelectedSeed",
})

AutoBuyTab:Toggle({
    Title = "Auto Buy Selected Seed",
    Desc = "Buys only the selected seed type",
    Icon = "target",
    Value = false,
    Flag = "AutoBuySelectedSeed",
    Callback = function(state)
        States.AutoBuySelectedSeed = state
        if state then
            Threads.AutoBuySelectedSeed = task.spawn(function()
                while States.AutoBuySelectedSeed do
                    local selected = States.SelectedSeed or SeedList[1]
                    local success, err = SendPacket("g\000" .. string.char(#selected) .. selected)
                    if not success then
                        warn("Packet failed: " .. tostring(err))
                        task.wait(1)
                    end
                    task.wait(0.3)
                end
            end)
        else
            KillThread("AutoBuySelectedSeed")
        end
    end,
})

AutoBuyTab:Section({ Title = "Gear", Icon = "wrench" })

AutoBuyTab:Toggle({
    Title = "Auto Buy All Gear",
    Desc = "Automatically purchases every gear type",
    Icon = "tool",
    Value = false,
    Flag = "AutoBuyGear",
    Callback = function(state)
        States.AutoBuyGear = state
        if state then
            Threads.AutoBuyGear = task.spawn(function()
                while States.AutoBuyGear do
                    for _, name in pairs(GearList) do
                        if not States.AutoBuyGear then break end
                        local success, err = SendPacket("g\000" .. string.char(#name) .. name)
                        if not success then
                            warn("Packet failed: " .. tostring(err))
                            task.wait(1)
                        end
                        task.wait(0.2)
                    end
                    task.wait(1)
                end
            end)
        else
            KillThread("AutoBuyGear")
        end
    end,
})

AutoBuyTab:Dropdown({
    Title = "Select Gear to Buy",
    Desc = "Choose specific gear to auto-buy",
    Icon = "list",
    Values = GearList,
    Value = GearList[1],
    Multi = false,
    Flag = "SelectedGear",
})

AutoBuyTab:Toggle({
    Title = "Auto Buy Selected Gear",
    Desc = "Buys only the selected gear type",
    Icon = "target",
    Value = false,
    Flag = "AutoBuySelectedGear",
    Callback = function(state)
        States.AutoBuySelectedGear = state
        if state then
            Threads.AutoBuySelectedGear = task.spawn(function()
                while States.AutoBuySelectedGear do
                    local selected = States.SelectedGear or GearList[1]
                    local success, err = SendPacket("g\000" .. string.char(#selected) .. selected)
                    if not success then
                        warn("Packet failed: " .. tostring(err))
                        task.wait(1)
                    end
                    task.wait(0.3)
                end
            end)
        else
            KillThread("AutoBuySelectedGear")
        end
    end,
})

AutoBuyTab:Section({ Title = "Selling", Icon = "banknote" })

AutoBuyTab:Toggle({
    Title = "Auto Sell Fruits",
    Desc = "Automatically sells all fruits in inventory",
    Icon = "coins",
    Value = false,
    Flag = "AutoSell",
    Callback = function(state)
        States.AutoSell = state
        if state then
            Threads.AutoSell = task.spawn(function()
                while States.AutoSell do
                    if Inventory and #Inventory:GetChildren() > 0 then
                        local success, err = SendPacket("\153\000\024")
                        if not success then
                            warn("Sell packet failed: " .. tostring(err))
                        end
                    end
                    task.wait(1)
                end
            end)
        else
            KillThread("AutoSell")
        end
    end,
})

AutoBuyTab:Toggle({
    Title = "Auto Sell Specific Fruit",
    Desc = "Sells only selected fruit type",
    Icon = "filter",
    Value = false,
    Flag = "AutoSellSpecific",
})

AutoBuyTab:Dropdown({
    Title = "Fruit to Sell",
    Values = FruitList,
    Value = FruitList[1],
    Multi = false,
    Flag = "SellFruitType",
})

MiscTab:Section({ Title = "Server", Icon = "server" })

MiscTab:Button({
    Title = "Rejoin Server",
    Desc = "Rejoin the current server",
    Icon = "refresh-cw",
    Callback = function()
        local TeleportService = game:GetService("TeleportService")
        TeleportService:Teleport(game.PlaceId, Player)
    end,
})

MiscTab:Button({
    Title = "Server Hop",
    Desc = "Join a different server",
    Icon = "shuffle",
    Callback = function()
        local HttpService = game:GetService("HttpService")
        local TeleportService = game:GetService("TeleportService")
        local success, result = pcall(function()
            return game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
        end)
        if success then
            local servers = HttpService:JSONDecode(result)
            for _, server in pairs(servers.data) do
                if server.playing < server.maxPlayers and server.id ~= game.JobId then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, Player)
                    break
                end
            end
        else
            Notify("Error", "Failed to get server list", "x")
        end
    end,
})

MiscTab:Button({
    Title = "Lowest Player Server",
    Desc = "Join server with fewest players",
    Icon = "users",
    Callback = function()
        local HttpService = game:GetService("HttpService")
        local TeleportService = game:GetService("TeleportService")
        local success, result = pcall(function()
            return game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
        end)
        if success then
            local servers = HttpService:JSONDecode(result)
            local lowest = nil
            for _, server in pairs(servers.data) do
                if server.id ~= game.JobId then
                    if not lowest or server.playing < lowest.playing then
                        lowest = server
                    end
                end
            end
            if lowest then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, lowest.id, Player)
            end
        else
            Notify("Error", "Failed to get server list", "x")
        end
    end,
})

MiscTab:Section({ Title = "Visuals", Icon = "eye" })

MiscTab:Toggle({
    Title = "ESP Players",
    Desc = "See all players through walls",
    Icon = "crosshair",
    Value = false,
    Flag = "ESPPlayers",
    Callback = function(state)
        States.ESPPlayers = state
        if state then
            Threads.ESPPlayers = task.spawn(function()
                while States.ESPPlayers do
                    for _, plr in pairs(Players:GetPlayers()) do
                        if plr ~= Player and plr.Character then
                            local head = plr.Character:FindFirstChild("Head")
                            if head and not head:FindFirstChild("ESPHighlight") then
                                local highlight = Instance.new("Highlight")
                                highlight.Name = "ESPHighlight"
                                highlight.FillColor = Color3.fromRGB(124, 58, 237)
                                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                                highlight.FillTransparency = 0.5
                                highlight.OutlineTransparency = 0
                                highlight.Parent = head
                            end
                        end
                    end
                    task.wait(1)
                end
            end)
        else
            KillThread("ESPPlayers")
            for _, plr in pairs(Players:GetPlayers()) do
                if plr.Character and plr.Character:FindFirstChild("Head") then
                    local esp = plr.Character.Head:FindFirstChild("ESPHighlight")
                    if esp then esp:Destroy() end
                end
            end
        end
    end,
})

MiscTab:Toggle({
    Title = "Full Bright",
    Desc = "Maximize lighting visibility",
    Icon = "sun",
    Value = false,
    Flag = "FullBright",
    Callback = function(state)
        local Lighting = game:GetService("Lighting")
        if state then
            States.OriginalBrightness = Lighting.Brightness
            States.OriginalClockTime = Lighting.ClockTime
            States.OriginalFog = Lighting.FogEnd
            Lighting.Brightness = 10
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
        else
            Lighting.Brightness = States.OriginalBrightness or 1
            Lighting.ClockTime = States.OriginalClockTime or 14
            Lighting.FogEnd = States.OriginalFog or 1000
            Lighting.GlobalShadows = true
        end
    end,
})

MiscTab:Toggle({
    Title = "Remove Fog",
    Desc = "Clear all fog from the game",
    Icon = "cloud-off",
    Value = false,
    Flag = "RemoveFog",
    Callback = function(state)
        local Lighting = game:GetService("Lighting")
        if state then
            States.OriginalFog = Lighting.FogEnd
            Lighting.FogEnd = 100000
        else
            Lighting.FogEnd = States.OriginalFog or 1000
        end
    end,
})

MiscTab:Section({ Title = "Utility", Icon = "hammer" })

MiscTab:Button({
    Title = "Reset Character",
    Desc = "Respawn your character",
    Icon = "rotate-ccw",
    Callback = function()
        local char = Player.Character
        if char then
            char:BreakJoints()
        end
    end,
})

MiscTab:Button({
    Title = "Destroy GUI",
    Desc = "Close Eternal Hub completely",
    Icon = "trash-2",
    Callback = function()
        for name, thread in pairs(Threads) do
            if thread then task.cancel(thread) end
        end
        if NoclipConnection then NoclipConnection:Disconnect() end
        Window:Destroy()
    end,
})

StatsTab:Section({ Title = "Information", Icon = "info" })

local StatsLabel = StatsTab:Paragraph({
    Title = "Loading stats...",
    Desc = "",
})

Threads.StatsUpdater = task.spawn(function()
    while true do
        local char, hum = GetCharacter()
        local inventoryCount = Inventory and #Inventory:GetChildren() or 0
        local gardenCount = 0
        local gardens = Workspace:FindFirstChild("Gardens")
        if gardens then
            gardenCount = #gardens:GetChildren()
        end

        local statsText = string.format(
            "Player: %s\nHealth: %d/%d\nWalk Speed: %d\nJump Power: %d\nInventory Items: %d\nGarden Plots: %d\nServer Players: %d/%d",
            Player.DisplayName,
            hum and hum.Parent and math.floor(hum.Health) or 0,
            hum and hum.Parent and math.floor(hum.MaxHealth) or 0,
            hum and hum.Parent and math.floor(hum.WalkSpeed) or 0,
            hum and hum.Parent and math.floor(hum.JumpPower) or 0,
            inventoryCount,
            gardenCount,
            #Players:GetPlayers(),
            Players.MaxPlayers
        )

        StatsLabel:SetTitle("Player Stats")
        StatsLabel:SetDesc(statsText)

        task.wait(1)
    end
end)

StatsTab:Section({ Title = "Inventory", Icon = "backpack" })

StatsTab:Button({
    Title = "Refresh Inventory",
    Desc = "Update inventory display",
    Icon = "refresh-cw",
    Callback = function()
        local items = {}
        if Inventory then
            for _, item in pairs(Inventory:GetChildren()) do
                table.insert(items, item.Name)
            end
        end
        if #items > 0 then
            Notify("Inventory", table.concat(items, ", "), "backpack")
        else
            Notify("Inventory", "Your inventory is empty", "backpack")
        end
    end,
})

StatsTab:Button({
    Title = "Clear Inventory Display",
    Desc = "Clear any inventory highlights",
    Icon = "x",
    Callback = function()
        Notify("Inventory", "Display cleared", "check")
    end,
})

Player.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = Character:WaitForChild("Humanoid")
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

    if States.SpeedHack then
        Humanoid.WalkSpeed = States.SpeedValue or 32
    end
    if States.JumpPower then
        Humanoid.JumpPower = States.JumpValue or 75
    end
end)

task.delay(2, function()
    Notify("Eternal Hub", "Loaded successfully! Press RightShift to toggle.", "infinity", 5)
end)
