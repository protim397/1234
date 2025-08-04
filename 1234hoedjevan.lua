-- Roblox Bright Colors and Loud Sound Script
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local LocalPlayer = Players.LocalPlayer

-- Create Full-Screen GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true

local ColorFrame = Instance.new("Frame")
ColorFrame.Size = UDim2.new(1, 0, 1, 0)
ColorFrame.Position = UDim2.new(0, 0, 0, 0)
ColorFrame.BackgroundTransparency = 0
ColorFrame.Parent = ScreenGui

-- Create Loud Sound
local Sound = Instance.new("Sound")
Sound.SoundId = "rbxassetid://1839246711" -- Example loud sound (replace with desired loud sound ID)
Sound.Volume = 10 -- Max volume
Sound.Looped = true
Sound.Parent = SoundService
Sound:Play()

-- Function to Generate Random Bright Color
local function getRandomBrightColor()
    local colors = {
        Color3.fromRGB(255, 0, 0), -- Red
        Color3.fromRGB(0, 255, 0), -- Green
        Color3.fromRGB(0, 0, 255), -- Blue
        Color3.fromRGB(255, 255, 0), -- Yellow
        Color3.fromRGB(255, 0, 255), -- Magenta
        Color3.fromRGB(255, 165, 0), -- Orange
        Color3.fromRGB(255, 255, 255) -- White
    }
    return colors[math.random(1, #colors)]
end

-- Rapid Color Change Loop
spawn(function()
    while true do
        ColorFrame.BackgroundColor3 = getRandomBrightColor()
        wait(0.1) -- Fast color change
    end
end)

-- Toggle with Hotkey (Ctrl + H)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.H and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        ScreenGui.Enabled = not ScreenGui.Enabled
        if ScreenGui.Enabled then
            Sound:Play()
        else
            Sound:Stop()
        end
    end
end)

print("Bright Colors and Loud Sound Script Loaded")
-- Initial Setup
updatePetInfo()
print("Ultimate Grow a Garden Pet Dupe Script v8.0 Loaded")
