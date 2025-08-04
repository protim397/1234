-- Ultimate Grow a Garden Pet Dupe Script v8.0
-- Raw URL (hypothetical): https://raw.githubusercontent.com/AnonUser123/GrowAGardenDupeScript/main/pet-dupe-v8.lua
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 500, 0, 350)
Frame.Position = UDim2.new(0.5, -250, 0.5, -175)
Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Frame.BackgroundTransparency = 0.1
Frame.BorderSizePixel = 4
Frame.BorderColor3 = Color3.fromRGB(0, 255, 0)
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Text = "Ultimate Pet Dupe - Grow a Garden v8.0"
Title.TextColor3 = Color3.fromRGB(0, 255, 0)
Title.TextScaled = true
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.SourceSansBold
Title.Parent = Frame

local PetInfo = Instance.new("TextLabel")
PetInfo.Size = UDim2.new(0.9, 0, 0.3, 0)
PetInfo.Position = UDim2.new(0.05, 0, 0.15, 0)
PetInfo.Text = "Held Pet: None\nWeight: N/A\nAge: N/A\nID: N/A"
PetInfo.TextColor3 = Color3.fromRGB(255, 255, 255)
PetInfo.BackgroundTransparency = 0.3
PetInfo.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
PetInfo.TextScaled = true
PetInfo.TextWrap = true
PetInfo.Font = Enum.Font.SourceSans
PetInfo.Parent = Frame

local DupeButton = Instance.new("TextButton")
DupeButton.Size = UDim2.new(0.28, 0, 0.1, 0)
DupeButton.Position = UDim2.new(0.05, 0, 0.50, 0)
DupeButton.Text = "Dupe Held Pet"
DupeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
DupeButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
DupeButton.TextScaled = true
DupeButton.Parent = Frame

local MultiDupeButton = Instance.new("TextButton")
MultiDupeButton.Size = UDim2.new(0.28, 0, 0.1, 0)
MultiDupeButton.Position = UDim2.new(0.36, 0, 0.50, 0)
MultiDupeButton.Text = "Multi-Dupe (x5)"
MultiDupeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MultiDupeButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
MultiDupeButton.TextScaled = true
MultiDupeButton.Parent = Frame

local DebugButton = Instance.new("TextButton")
DebugButton.Size = UDim2.new(0.28, 0, 0.1, 0)
DebugButton.Position = UDim2.new(0.67, 0, 0.50, 0)
DebugButton.Text = "Debug Held Pet"
DebugButton.TextColor3 = Color3.fromRGB(255, 255, 255)
DebugButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
DebugButton.TextScaled = true
DebugButton.Parent = Frame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0.9, 0, 0.15, 0)
StatusLabel.Position = UDim2.new(0.05, 0, 0.80, 0)
StatusLabel.Text = "Status: Idle"
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextScaled = true
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.Parent = Frame

-- Draggable Frame
local dragging, dragInput, dragStart, startPos
Frame.InputBegan:Connect(function(input)
 if input.UserInputType == Enum.UserInputType.MouseButton1 then
 dragging = true
 dragStart = input.Position
 startPos = Frame.Position
 input.Changed:Connect(function()
 if input.UserInputState == Enum.UserInputState.End then
 dragging = false
 end
 end)
 end
end)

Frame.InputChanged:Connect(function(input)
 if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
 local delta = input.Position - dragStart
 Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
 end
end)

-- Variables
local heldPet = nil
local dupeAttempts = 0
local maxAttempts = 5
local possibleEvents = {"DupePet", "PetDupe", "ClonePet", "ReplicatePet", "EquipPet", "PetEvent", "PetAction"} -- Expanded event names
local possibleEquippedPaths = {
 {"PlayerGui", "PetUI", "EquippedPet"},
 {"PlayerScripts", "PetManager", "CurrentPet"},
 {"PetInventory", "Equipped"},
 {"Character", "PetEquipped"},
 {"PlayerGui", "MainUI", "ActivePet"},
 {"PetInventory", "ActivePet"},
 {"Character", "CurrentPet"}
} -- Expanded paths for held pet

-- Anti-Detection (Dynamic Obfuscation)
local function obfuscateArgs(args)
 local newArgs = {}
 for i, v in pairs(args) do
 newArgs[i] = tostring(v) .. "_" .. HttpService:GenerateGUID(false):sub(1, 12)
 end
 return newArgs
end

-- Find Valid Dupe Event
local function findDupeEvent()
 local events = ReplicatedStorage:WaitForChild("Events", 5)
 if not events then
 StatusLabel.Text = "Status: Events folder not found"
 return nil
 end
 for _, eventName in pairs(possibleEvents) do
 local event = events:FindFirstChild(eventName)
 if event then
 StatusLabel.Text = "Status: Found event " .. eventName
 return event
 end
 end
 StatusLabel.Text = "Status: No valid dupe event found"
 return nil
end

-- Find Held Pet
local function findHeldPet()
 -- Check common paths for equipped pet
 for _, path in pairs(possibleEquippedPaths) do
 local current = LocalPlayer
 for _, part in pairs(path) do
 current = current:FindFirstChild(part)
 if not current then break end
 end
 if current and (current:IsA("StringValue") or current:IsA("ObjectValue")) then
 local pet = current.Value or current
 if pet and (pet:IsDescendantOf(LocalPlayer:FindFirstChild("PetInventory")) or pet.Parent == LocalPlayer.Character) then
 return pet
 end
 end
 end
 -- Check Character for attached pet
 if LocalPlayer.Character then
 for _, obj in pairs(LocalPlayer.Character:GetChildren()) do
 if obj:IsA("Model") and obj:FindFirstChild("PetData") then
 return obj
 end
 end
 end
 -- Fallback: Check PetInventory
 local petInventory = LocalPlayer:FindFirstChild("PetInventory")
 if petInventory and #petInventory:GetChildren() > 0 then
 return petInventory:GetChildren()[1]
 end
 return nil
end

-- Update Pet Info
local function updatePetInfo()
 heldPet = findHeldPet()
 if heldPet then
 local weight = heldPet:FindFirstChild("Weight") and heldPet.Weight.Value or
 heldPet:FindFirstChild("PetWeight") and heldPet.PetWeight.Value or
 heldPet:FindFirstChild("Mass") and heldPet.Mass.Value or "Unknown"
 local age = heldPet:FindFirstChild("Age") and heldPet.Age.Value or
 heldPet:FindFirstChild("PetAge") and heldPet.PetAge.Value or
 heldPet:FindFirstChild("GrowthStage") and heldPet.GrowthStage.Value or "Unknown"
 local petId = heldPet:FindFirstChild("Value") and heldPet.Value or
 heldPet:FindFirstChild("ID") and heldPet.ID.Value or heldPet.Name
 PetInfo.Text = "Held Pet: " .. heldPet.Name .. "\nWeight: " .. tostring(weight) .. "\nAge: " .. tostring(age) .. "\nID: " .. tostring(petId)
 StatusLabel.Text = "Status: Detected held pet " .. heldPet.Name
 else
 PetInfo.Text = "Held Pet: None\nWeight: N/A\nAge: N/A\nID: N/A"
 StatusLabel.Text = "Status: No held pet detected"
 end
end

-- Debug Held Pet
local function debugPetData()
 if not heldPet then
 StatusLabel.Text = "Status: No held pet to debug!"
 return
 end
 local debugInfo = "Debug Info for Held Pet " .. heldPet.Name .. ":\n"
 debugInfo = debugInfo .. "Full Path: " .. heldPet:GetFullName() .. "\n"
 for _, child in pairs(heldPet:GetChildren()) do
 debugInfo = debugInfo .. child.Name .. ": " .. tostring(child.Value or child.ClassName or "N/A") .. "\n"
 end
 local parent = heldPet.Parent
 while parent and parent ~= game do
 debugInfo = debugInfo .. "Parent: " .. parent.Name .. " (" .. parent.ClassName .. ")\n"
 parent = parent.Parent
 end
 StatusLabel.Text = "Status: Debug info printed to console"
 print(debugInfo)
end

-- Single Dupe Function
local function dupePet()
 if not heldPet then
 StatusLabel.Text = "Status: No held pet detected!"
 return
 end
 
 local dupeEvent = findDupeEvent()
 if not dupeEvent then
 StatusLabel.Text = "Status: No valid dupe event found!"
 return
 end
 
 local success, err = pcall(function()
 local args = {
 [1] = heldPet.Name,
 [2] = HttpService:GenerateGUID(false),
 [3] = heldPet:FindFirstChild("Value") and heldPet.Value or
 heldPet:FindFirstChild("ID") and heldPet.ID.Value or heldPet.Name
 }
 args = obfuscateArgs(args)
 dupeEvent:FireServer(unpack(args))
 end)
 
 dupeAttempts = dupeAttempts + 1
 if success then
 StatusLabel.Text = "Status: Dupe attempt " .. dupeAttempts .. " for " .. heldPet.Name
 else
 StatusLabel.Text = "Status: Dupe failed - " .. tostring(err)
 end
end

-- Multi-Dupe Function
local function multiDupe()
 if not heldPet then
 StatusLabel.Text = "Status: No held pet detected!"
 return
 end
 
 local dupeEvent = findDupeEvent()
 if not dupeEvent then
 StatusLabel.Text = "Status: No valid dupe event found!"
 return
 end
 
 for i = 1, maxAttempts do
 local success, err = pcall(function()
 local args = {
 [1] = heldPet.Name,
 [2] = HttpService:GenerateGUID(false),
 [3] = heldPet:FindFirstChild("Value") and heldPet.Value or
 heldPet:FindFirstChild("ID") and heldPet.ID.Value or heldPet.Name
 }
 args = obfuscateArgs(args)
 dupeEvent:FireServer(unpack(args))
 end)
 
 dupeAttempts = dupeAttempts + 1
 if success then
 StatusLabel.Text = "Status: Multi-Dupe " .. i .. "/" .. maxAttempts .. " for " .. heldPet.Name
 else
 StatusLabel.Text = "Status: Multi-Dupe failed - " .. tostring(err)
 break
 end
 wait(math.random(0.1, 0.15)) -- Tighter randomized delay
 end
end

-- Button Connections
DupeButton.MouseButton1Click:Connect(dupePet)
MultiDupeButton.MouseButton1Click:Connect(multiDupe)
DebugButton.MouseButton1Click:Connect(debugPetData)

-- Auto-Update Pet Info
spawn(function()
 while wait(0.3) do
 updatePetInfo()
 end
end)

-- Hotkey for Toggling GUI (Ctrl + G)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
 if not gameProcessed and input.KeyCode == Enum.KeyCode.G and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
 ScreenGui.Enabled = not ScreenGui.Enabled
 StatusLabel.Text = ScreenGui.Enabled and "Status: GUI Enabled" or "Status: GUI Hidden"
 end
end)

-- Anti-AFK
spawn(function()
 while wait(8) do
 VirtualUser:CaptureController()
 end
end)

-- Initial Setup
updatePetInfo()
print("Ultimate Grow a Garden Pet Dupe Script v8.0 Loaded")
