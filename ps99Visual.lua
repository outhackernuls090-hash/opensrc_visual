local message = require(game.ReplicatedStorage.Library.Client.Message)
local Directory = require(game:GetService("ReplicatedStorage").Library.Directory)
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local Pets = require(game:GetService("ReplicatedStorage").Library.Directory.Pets)
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
gui.Name = "HannScripts"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 200, 0, 70)
mainFrame.Position = UDim2.new(0.5, -100, 0.5, -35)
mainFrame.BackgroundColor3 = Color3.fromRGB(255, 200, 220) 
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = gui


local corners = Instance.new("UICorner")
corners.CornerRadius = UDim.new(0, 12)
corners.Parent = mainFrame


local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255, 150, 200) 
stroke.Thickness = 1.5
stroke.Parent = mainFrame


local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 220, 235)), 
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 180, 210)) 
}
gradient.Rotation = 45
gradient.Parent = mainFrame


local title = Instance.new("TextLabel")
title.Text = "Hann Scripts"
title.Size = UDim2.new(1, 0, 0, 25)
title.Position = UDim2.new(0, 0, 0, 5)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextColor3 = Color3.fromRGB(180, 50, 120) 
title.Parent = mainFrame


local actionButton = Instance.new("TextButton")
actionButton.Name = "ActionButton"
actionButton.Size = UDim2.new(0, 160, 0, 30)
actionButton.Position = UDim2.new(0.5, -80, 0, 35)
actionButton.Text = "Activate"
actionButton.Font = Enum.Font.GothamBold
actionButton.TextSize = 14
actionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
actionButton.BackgroundColor3 = Color3.fromRGB(255, 120, 180) 
actionButton.Parent = mainFrame
activeButton = actionButton


local buttonCorners = Instance.new("UICorner")
buttonCorners.CornerRadius = UDim.new(0, 8)
buttonCorners.Parent = actionButton


local buttonStroke = Instance.new("UIStroke")
buttonStroke.Color = Color3.fromRGB(255, 80, 140) 
buttonStroke.Thickness = 1
buttonStroke.Parent = actionButton


actionButton.MouseEnter:Connect(function()
    tweenService:Create(actionButton, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(255, 140, 200) 
    }):Play()
end)

actionButton.MouseLeave:Connect(function()
    local targetColor = isActive and Color3.fromRGB(255, 80, 160) or Color3.fromRGB(255, 120, 180)
    tweenService:Create(actionButton, TweenInfo.new(0.2), {
        BackgroundColor3 = targetColor
    }):Play()
end)


actionButton.MouseButton1Down:Connect(function()
    tweenService:Create(actionButton, TweenInfo.new(0.1), {
        Size = UDim2.new(0, 154, 0, 28),
        Position = UDim2.new(0.5, -77, 0, 36)
    }):Play()
end)

actionButton.MouseButton1Up:Connect(function()
    tweenService:Create(actionButton, TweenInfo.new(0.1), {
        Size = UDim2.new(0, 160, 0, 30),
        Position = UDim2.new(0.5, -80, 0, 35)
    }):Play()
end)


local statusDot = Instance.new("Frame")
statusDot.Size = UDim2.new(0, 6, 0, 6)
statusDot.Position = UDim2.new(1, -15, 0, 8)
statusDot.BackgroundColor3 = Color3.fromRGB(255, 80, 140) 
statusDot.BackgroundTransparency = 0.3
statusDot.Parent = mainFrame

local dotCorners = Instance.new("UICorner")
dotCorners.CornerRadius = UDim.new(1, 0)
dotCorners.Parent = statusDot


local function updateDotColor()
    local dotColor = isActive and Color3.fromRGB(50, 255, 100) or Color3.fromRGB(255, 80, 140) 
    tweenService:Create(statusDot, TweenInfo.new(0.3), {
        BackgroundColor3 = dotColor
    }):Play()
end


actionButton.MouseButton1Click:Connect(function()
    if not isActive then
        
        local confirmed = message.Confirm("Are you sure you want to activate Huge Hunter?", {
            title = "Confirm Activation",
            timedLock = 2
        })
        
        if confirmed then
            isActive = true
            actionButton.Text = "Deactivate"
            actionButton.BackgroundColor3 = Color3.fromRGB(255, 80, 160) 
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
            actionButton.Text = "Activate"
            actionButton.BackgroundColor3 = Color3.fromRGB(255, 120, 180) 
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
                BackgroundColor3 = Color3.fromRGB(255, 160, 210)
            })
            pulseTween:Play()
            
            
            pulseTween.Completed:Wait()
            
            
            local returnTween = tweenService:Create(actionButton, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                BackgroundColor3 = Color3.fromRGB(255, 120, 180)
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
