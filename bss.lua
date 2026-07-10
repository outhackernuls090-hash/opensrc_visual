--[[
    Void Scripts Loader - Small Loading Screen
    Place this in a LocalScript inside StarterGui (or StarterPlayerScripts)
--]]

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

----------------------------------------------------------------
-- Background Blur (subtle, not covering the whole screen visually)
----------------------------------------------------------------
local blur = Instance.new("BlurEffect")
blur.Name = "VoidLoaderBlur"
blur.Size = 0
blur.Parent = Lighting

TweenService:Create(blur, TweenInfo.new(0.6, Enum.EasingStyle.Quad), {Size = 12}):Play()

----------------------------------------------------------------
-- ScreenGui
----------------------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "VoidLoadingScreen"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 999
screenGui.Parent = player:WaitForChild("PlayerGui")

----------------------------------------------------------------
-- Main small frame (centered, NOT full screen)
----------------------------------------------------------------
local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Position = UDim2.new(0.5, 0, 0.5, 0)
frame.Size = UDim2.new(0, 340, 0, 160)
frame.BackgroundColor3 = Color3.fromRGB(15, 8, 25)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 0
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 16)
corner.Parent = frame

-- Neon purple glowing stroke
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(170, 0, 255)
stroke.Thickness = 2
stroke.Transparency = 0.1
stroke.Parent = frame

-- Subtle gradient for depth
local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 0, 60)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 5, 15)),
})
gradient.Rotation = 90
gradient.Parent = frame

----------------------------------------------------------------
-- Title text: "Void Scripts loader for (playername)"
----------------------------------------------------------------
local title = Instance.new("TextLabel")
title.Name = "Title"
title.BackgroundTransparency = 1
title.Position = UDim2.new(0, 10, 0, 20)
title.Size = UDim2.new(1, -20, 0, 40)
title.Font = Enum.Font.GothamBold
title.Text = "Void Scripts loader for " .. player.Name
title.TextColor3 = Color3.fromRGB(191, 62, 255)
title.TextScaled = true
title.TextWrapped = true
title.Parent = frame

-- Neon glow behind the title text
local titleStroke = Instance.new("UIStroke")
titleStroke.Color = Color3.fromRGB(120, 0, 200)
titleStroke.Thickness = 1.2
titleStroke.Transparency = 0.3
titleStroke.Parent = title

----------------------------------------------------------------
-- Subtitle / status text (appears after a delay)
----------------------------------------------------------------
local subtitle = Instance.new("TextLabel")
subtitle.Name = "Subtitle"
subtitle.BackgroundTransparency = 1
subtitle.Position = UDim2.new(0, 10, 0, 70)
subtitle.Size = UDim2.new(1, -20, 0, 30)
subtitle.Font = Enum.Font.Gotham
subtitle.Text = "Loading..."
subtitle.TextColor3 = Color3.fromRGB(200, 170, 255)
subtitle.TextTransparency = 1 -- hidden at first
subtitle.TextScaled = true
subtitle.TextWrapped = true
subtitle.Parent = frame

----------------------------------------------------------------
-- Simple animated loading bar
----------------------------------------------------------------
local barBg = Instance.new("Frame")
barBg.Name = "BarBackground"
barBg.Position = UDim2.new(0, 20, 0, 115)
barBg.Size = UDim2.new(1, -40, 0, 8)
barBg.BackgroundColor3 = Color3.fromRGB(30, 15, 40)
barBg.BorderSizePixel = 0
barBg.Parent = frame

local barCorner = Instance.new("UICorner")
barCorner.CornerRadius = UDim.new(1, 0)
barCorner.Parent = barBg

local barFill = Instance.new("Frame")
barFill.Name = "BarFill"
barFill.Size = UDim2.new(0, 0, 1, 0)
barFill.BackgroundColor3 = Color3.fromRGB(170, 0, 255)
barFill.BorderSizePixel = 0
barFill.Parent = barBg

local barFillCorner = Instance.new("UICorner")
barFillCorner.CornerRadius = UDim.new(1, 0)
barFillCorner.Parent = barFill

local barGradient = Instance.new("UIGradient")
barGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 0, 200)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(220, 120, 255)),
})
barGradient.Parent = barFill

-- Looping "indeterminate" bar animation (since real load time is unknown)
task.spawn(function()
    while screenGui.Parent do
        TweenService:Create(barFill, TweenInfo.new(1.2, Enum.EasingStyle.Sine), {Size = UDim2.new(0.85, 0, 1, 0)}):Play()
        task.wait(1.2)
        TweenService:Create(barFill, TweenInfo.new(1.2, Enum.EasingStyle.Sine), {Size = UDim2.new(0.1, 0, 1, 0)}):Play()
        task.wait(1.2)
    end
end)

----------------------------------------------------------------
-- After a few seconds, switch subtitle to the "please wait" message
----------------------------------------------------------------
task.spawn(function()
    task.wait(4) -- "a few seconds"
    subtitle.Text = "Please wait, this can take up to 5 minutes to load."
    TweenService:Create(subtitle, TweenInfo.new(0.8), {TextTransparency = 0}):Play()
end)

----------------------------------------------------------------
-- Helper: call this from elsewhere in your code once loading is done
----------------------------------------------------------------
local VoidLoader = {}

function VoidLoader.Finish()
    TweenService:Create(blur, TweenInfo.new(0.6), {Size = 0}):Play()
    TweenService:Create(frame, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
    TweenService:Create(stroke, TweenInfo.new(0.5), {Transparency = 1}):Play()
    TweenService:Create(title, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
    TweenService:Create(titleStroke, TweenInfo.new(0.5), {Transparency = 1}):Play()
    TweenService:Create(subtitle, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
    task.wait(0.6)
    blur:Destroy()
    screenGui:Destroy()
end

return VoidLoader
