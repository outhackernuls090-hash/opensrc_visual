local message = require(game.ReplicatedStorage.Library.Client.Message)
local Directory = require(game:GetService("ReplicatedStorage").Library.Directory)
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local tweenService = game:GetService("TweenService")

local isActive = false
local activeButton

local function changePetAttributes()
    local from, to = "Cat", "Huge Cat"
    if Directory.Pets[from] and Directory.Pets[to] then
        for i, v in pairs(Directory.Pets[from]) do
            Directory.Pets[from][i] = nil
        end
        for i, v in pairs(Directory.Pets[to]) do
            Directory.Pets[from][i] = v
        end
    end
end

local gui = Instance.new("ScreenGui")
gui.Name = "EternalDarknessHub"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 260, 0, 160)
mainFrame.Position = UDim2.new(0.5, -130, 0.5, -80)
mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 26)
mainFrame.BackgroundTransparency = 0.05
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = gui

local corners = Instance.new("UICorner")
corners.CornerRadius = UDim.new(0, 14)
corners.Parent = mainFrame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(22, 33, 62)
stroke.Thickness = 1.5
stroke.Parent = mainFrame

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 15, 35)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 8, 20))
}
gradient.Rotation = 45
gradient.Parent = mainFrame

local glowStroke = Instance.new("UIStroke")
glowStroke.Color = Color3.fromRGB(83, 52, 131)
glowStroke.Thickness = 0.5
glowStroke.Transparency = 0.7
glowStroke.Parent = mainFrame

local logoContainer = Instance.new("Frame")
logoContainer.Size = UDim2.new(0, 40, 0, 40)
logoContainer.Position = UDim2.new(0.5, -20, 0, 12)
logoContainer.BackgroundTransparency = 1
logoContainer.Parent = mainFrame

local logoLeft = Instance.new("Frame")
logoLeft.Size = UDim2.new(0, 18, 0, 18)
logoLeft.Position = UDim2.new(0.5, -18, 0.5, -9)
logoLeft.BackgroundColor3 = Color3.fromRGB(83, 52, 131)
logoLeft.BorderSizePixel = 0
logoLeft.Parent = logoContainer

local leftCorner = Instance.new("UICorner")
leftCorner.CornerRadius = UDim.new(1, 0)
leftCorner.Parent = logoLeft

local logoRight = Instance.new("Frame")
logoRight.Size = UDim2.new(0, 18, 0, 18)
logoRight.Position = UDim2.new(0.5, 0, 0.5, -9)
logoRight.BackgroundColor3 = Color3.fromRGB(15, 52, 96)
logoRight.BorderSizePixel = 0
logoRight.Parent = logoContainer

local rightCorner = Instance.new("UICorner")
rightCorner.CornerRadius = UDim.new(1, 0)
rightCorner.Parent = logoRight

local logoCenter = Instance.new("Frame")
logoCenter.Size = UDim2.new(0, 8, 0, 8)
logoCenter.Position = UDim2.new(0.5, -4, 0.5, -4)
logoCenter.BackgroundColor3 = Color3.fromRGB(139, 0, 0)
logoCenter.BorderSizePixel = 0
logoCenter.Parent = logoContainer

local centerCorner = Instance.new("UICorner")
centerCorner.CornerRadius = UDim.new(1, 0)
centerCorner.Parent = logoCenter

local title = Instance.new("TextLabel")
title.Text = "ETERNAL DARKNESS"
title.Size = UDim2.new(1, 0, 0, 22)
title.Position = UDim2.new(0, 0, 0, 55)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = Color3.fromRGB(200, 200, 220)
title.Parent = mainFrame

local subtitle = Instance.new("TextLabel")
subtitle.Text = "HUB"
subtitle.Size = UDim2.new(1, 0, 0, 14)
subtitle.Position = UDim2.new(0, 0, 0, 76)
subtitle.BackgroundTransparency = 1
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 11
subtitle.TextColor3 = Color3.fromRGB(83, 52, 131)
subtitle.Parent = mainFrame

local actionButton = Instance.new("TextButton")
actionButton.Name = "ActionButton"
actionButton.Size = UDim2.new(0, 180, 0, 32)
actionButton.Position = UDim2.new(0.5, -90, 0, 100)
actionButton.Text = "ACTIVATE"
actionButton.Font = Enum.Font.GothamBold
actionButton.TextSize = 13
actionButton.TextColor3 = Color3.fromRGB(220, 220, 235)
actionButton.BackgroundColor3 = Color3.fromRGB(22, 33, 62)
actionButton.Parent = mainFrame
activeButton = actionButton

local buttonCorners = Instance.new("UICorner")
buttonCorners.CornerRadius = UDim.new(0, 8)
buttonCorners.Parent = actionButton

local buttonStroke = Instance.new("UIStroke")
buttonStroke.Color = Color3.fromRGB(83, 52, 131)
buttonStroke.Thickness = 1
buttonStroke.Parent = actionButton

actionButton.MouseEnter:Connect(function()
    tweenService:Create(actionButton, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(30, 45, 80)
    }):Play()
end)

actionButton.MouseLeave:Connect(function()
    local targetColor = isActive and Color3.fromRGB(139, 0, 0) or Color3.fromRGB(22, 33, 62)
    tweenService:Create(actionButton, TweenInfo.new(0.2), {
        BackgroundColor3 = targetColor
    }):Play()
end)

actionButton.MouseButton1Down:Connect(function()
    tweenService:Create(actionButton, TweenInfo.new(0.1), {
        Size = UDim2.new(0, 174, 0, 30),
        Position = UDim2.new(0.5, -87, 0, 101)
    }):Play()
end)

actionButton.MouseButton1Up:Connect(function()
    tweenService:Create(actionButton, TweenInfo.new(0.1), {
        Size = UDim2.new(0, 180, 0, 32),
        Position = UDim2.new(0.5, -90, 0, 100)
    }):Play()
end)

local statusDot = Instance.new("Frame")
statusDot.Size = UDim2.new(0, 6, 0, 6)
statusDot.Position = UDim2.new(1, -18, 0, 10)
statusDot.BackgroundColor3 = Color3.fromRGB(83, 52, 131)
statusDot.BackgroundTransparency = 0.3
statusDot.Parent = mainFrame

local dotCorners = Instance.new("UICorner")
dotCorners.CornerRadius = UDim.new(1, 0)
dotCorners.Parent = statusDot

local function updateDotColor()
    local dotColor = isActive and Color3.fromRGB(50, 255, 100) or Color3.fromRGB(83, 52, 131)
    tweenService:Create(statusDot, TweenInfo.new(0.3), {
        BackgroundColor3 = dotColor
    }):Play()
end

local versionLabel = Instance.new("TextLabel")
versionLabel.Text = "v7.0"
versionLabel.Size = UDim2.new(0, 40, 0, 14)
versionLabel.Position = UDim2.new(0, 8, 1, -18)
versionLabel.BackgroundTransparency = 1
versionLabel.Font = Enum.Font.Gotham
versionLabel.TextSize = 9
versionLabel.TextColor3 = Color3.fromRGB(60, 60, 80)
versionLabel.Parent = mainFrame

local bottomLine = Instance.new("Frame")
bottomLine.Size = UDim2.new(1, -20, 0, 1)
bottomLine.Position = UDim2.new(0, 10, 1, -4)
bottomLine.BackgroundColor3 = Color3.fromRGB(22, 33, 62)
bottomLine.BackgroundTransparency = 0.5
bottomLine.BorderSizePixel = 0
bottomLine.Parent = mainFrame

actionButton.MouseButton1Click:Connect(function()
    if not isActive then
        local confirmed = message.Confirm("Are you sure you want to activate Huge Hunter?", {
            title = "Confirm Activation",
            timedLock = 2
        })
        if confirmed then
            isActive = true
            actionButton.Text = "DEACTIVATE"
            actionButton.BackgroundColor3 = Color3.fromRGB(139, 0, 0)
            updateDotColor()
            message.StandardSuccess()
            changePetAttributes()
        else
            message.Error("Activation cancelled!")
        end
    else
        local confirmed = message.Confirm("Are you sure you want to deactivate Huge Hunter?", {
            title = "Confirm Deactivation",
            timedLock = 2
        })
        if confirmed then
            isActive = false
            actionButton.Text = "ACTIVATE"
            actionButton.BackgroundColor3 = Color3.fromRGB(22, 33, 62)
            updateDotColor()
            message.Error("Huge hunter deactivated!")
        else
            message.Error("Deactivation cancelled!")
        end
    end
end)

local function pulseAnimation()
    while task.wait(1.5) do
        if not isActive then
            local pulseTween = tweenService:Create(actionButton, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                BackgroundColor3 = Color3.fromRGB(35, 50, 90)
            })
            pulseTween:Play()
            pulseTween.Completed:Wait()
            local returnTween = tweenService:Create(actionButton, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                BackgroundColor3 = Color3.fromRGB(22, 33, 62)
            })
            returnTween:Play()
            returnTween.Completed:Wait()
        else
            task.wait(0.5)
        end
    end
end

coroutine.wrap(pulseAnimation)()

updateDotColor()
