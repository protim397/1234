-- Grow a Garden Dupe Script v1.0
-- Raw URL (hypothetical): https://raw.githubusercontent.com/AnonUser123/GrowAGardenDupeScript/main/dupe-v1.lua
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
Frame.Size = UDim2.new(0, 400, 0, 300)
Frame.Position = UDim2.new(0.5, -200, 0.5, -150)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Frame.BackgroundTransparency = 0.1
Frame.BorderSizePixel = 3
Frame.BorderColor3 = Color3.fromRGB(0, 255, 0)
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "Grow a Garden Dupe v1.0"
Title.TextColor3 = Color3.fromRGB(0, 255, 0)
Title.TextScaled = true
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.SourceSansBold
Title.Parent = Frame

local ItemInfo = Instance.new("TextLabel")
ItemInfo.Size = UDim2.new(0.9, 0, 0.35, 0)
ItemInfo.Position = UDim2.new(0.05, 0, 0.15, 0)
ItemInfo.Text = "Held Item/Pet: None\nType: N/A\nID: N/A"
ItemInfo.TextColor3 = Color3.fromRGB(255, 255, 255)
ItemInfo.BackgroundTransparency = 0.3
ItemInfo.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ItemInfo.TextScaled = true
ItemInfo.TextWrap = true
ItemInfo.Font = Enum.Font.SourceSans
ItemInfo.Parent = Frame

local DupeButton = Instance.new("TextButton")
DupeButton.Size = UDim2.new(0.3, 0, 0.1, 0)
DupeButton.Position = UDim2.new(0.05, 0, 0.55, 0)
DupeButton.Text = "Dupe Held"
DupeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
DupeButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
DupeButton.TextScaled = true
DupeButton.Parent = Frame

local MultiDupeButton = Instance.new("TextButton")
MultiDupeButton.Size = UDim2.new(0.3, 0, 0.1, 0)
MultiDupeButton.Position = UDim2.new(0.35, 0, 0.55, 0)
MultiDupeButton.Text = "Multi-Dupe (x3)"
MultiDupeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MultiDupeButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
MultiDupeButton.TextScaled = true
MultiDupeButton.Parent = Frame

local DebugButton = Instance.new("TextButton")
DebugButton.Size = UDim2.new(0.3, 0, 0.1, 0)
DebugButton.Position = UDim2.new(0.65, 0, 0.55, 0)
DebugButton.Text = "Debug Held"
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
local heldItem = nil
local heldItemType = nil
local dupeAttempts = 0
local maxAttempts = 3
local possibleEvents = {
    "DupePet", "PetDupe", "ClonePet", "ReplicatePet", "EquipPet", "PetEvent", "PetAction",
    "DupeItem", "ItemDupe", "CloneItem", "ReplicateItem", "EquipItem", "ItemEvent", "Action"
}
local possibleEquippedPaths = {
    {"PlayerGui", "PetUI", "EquippedPet"},
    {"PlayerScripts", "PetManager", "CurrentPet"},
    {"PetInventory", "Equipped"},
    {"Character", "PetEquipped"},
    {"PlayerGui", "MainUI", "ActivePet"},
    {"PetInventory", "ActivePet"},
    {"Character", "CurrentPet"},
    {"PlayerGui", "InventoryUI", "EquippedItem"},
    {"PlayerScripts", "ItemManager", "CurrentItem"},
    {"Inventory", "Equipped"},
    {"Character", "HeldItem"},
    {"Character", "ActiveItem"}
}

-- Anti-Detection (Obfuscation)
local function obfuscateArgs(args)
    local newArgs = {}
    for i, v in pairs(args) do
        newArgs[i] = tostring(v) .. "_" .. HttpService:GenerateGUID(false):sub(1, 10)
    end
    return newArgs
end

-- Find Valid Dupe Event
local function findDupeEvent(itemType)
    local events = ReplicatedStorage:WaitForChild("Events", 3)
    if not events then
        StatusLabel.Text = "Status: Events folder not found"
        return nil
    end
    local eventPrefixes = itemType == "Pet" and {"DupePet", "PetDupe", "ClonePet", "ReplicatePet", "EquipPet", "PetEvent", "PetAction"} or
                         {"DupeItem", "ItemDupe", "CloneItem", "ReplicateItem", "EquipItem", "ItemEvent", "Action"}
    for _, eventName in pairs(eventPrefixes) do
        local event = events:FindFirstChild(eventName)
        if event then
            StatusLabel.Text = "Status: Found event " .. eventName
            return event
        end
    end
    for _, eventName in pairs(possibleEvents) do
        local event = events:FindFirstChild(eventName)
        if event then
            StatusLabel.Text = "Status: Found fallback event " .. eventName
            return event
        end
    end
    StatusLabel.Text = "Status: No valid dupe event found"
    return nil
end

-- Find Held Item or Pet
local function findHeldItem()
    -- Check common paths
    for _, path in pairs(possibleEquippedPaths) do
        local current = LocalPlayer
        for _, part in pairs(path) do
            current = current:FindFirstChild(part)
            if not current then break end
        end
        if current and (current:IsA("StringValue") or current:IsA("ObjectValue")) then
            local item = current.Value or current
            if item and (item:IsDescendantOf(LocalPlayer:FindFirstChild("PetInventory")) or
                         item:IsDescendantOf(LocalPlayer:FindFirstChild("Inventory")) or
                         item.Parent == LocalPlayer.Character) then
                return item, item:IsDescendantOf(LocalPlayer:FindFirstChild("PetInventory")) and "Pet" or "Item"
            end
        end
    end
    -- Check Character for attached item/pet
    if LocalPlayer.Character then
        for _, obj in pairs(LocalPlayer.Character:GetChildren()) do
            if (obj:IsA("Model") or obj:IsA("Tool")) and (obj:FindFirstChild("PetData") or obj:FindFirstChild("ItemData")) then
                return obj, obj:FindFirstChild("PetData") and "Pet" or "Item"
            end
        end
    end
    -- Fallback: Check PetInventory or Inventory
    local petInventory = LocalPlayer:FindFirstChild("PetInventory")
    if petInventory and #petInventory:GetChildren() > 0 then
        return petInventory:GetChildren()[1], "Pet"
    end
    local inventory = LocalPlayer:FindFirstChild("Inventory")
    if inventory and #inventory:GetChildren() > 0 then
        return inventory:GetChildren()[1], "Item"
    end
    return nil, nil
end

-- Update Item Info
local function updateItemInfo()
    heldItem, heldItemType = findHeldItem()
    if heldItem then
        local itemId = heldItem:FindFirstChild("Value") and heldItem.Value or
                       heldItem:FindFirstChild("ID") and heldItem.ID.Value or heldItem.Name
        ItemInfo.Text = "Held Item/Pet: " .. heldItem.Name .. "\nType: " .. (heldItemType or "Unknown") .. "\nID: " .. tostring(itemId)
        StatusLabel.Text = "Status: Detected held " .. (heldItemType or "item") .. " " .. heldItem.Name
    else
        ItemInfo.Text = "Held Item/Pet: None\nType: N/A\nID: N/A"
        StatusLabel.Text = "Status: No held item or pet detected"
    end
end

-- Debug Held Item
local function debugItemData()
    if not heldItem then
        StatusLabel.Text = "Status: No held item or pet to debug!"
        return
    end
    local debugInfo = "Debug Info for Held " .. (heldItemType or "Item") .. " " .. heldItem.Name .. ":\n"
    debugInfo = debugInfo .. "Full Path: " .. heldItem:GetFullName() .. "\n"
    debugInfo = debugInfo .. "Type: " .. (heldItemType or "Unknown") .. "\n"
    for _, child in pairs(heldItem:GetChildren()) do
        debugInfo = debugInfo .. child.Name .. ": " .. tostring(child.Value or child.ClassName or "N/A") .. "\n"
    end
    local parent = heldItem.Parent
    while parent and parent ~= game do
        debugInfo = debugInfo .. "Parent: " .. parent.Name .. " (" .. parent.ClassName .. ")\n"
        parent = parent.Parent
    end
    StatusLabel.Text = "Status: Debug info printed to console"
    print(debugInfo)
end

-- Single Dupe Function
local function dupeItem()
    if not heldItem then
        StatusLabel.Text = "Status: No held item or pet detected!"
        return
    end
    
    local dupeEvent = findDupeEvent(heldItemType)
    if not dupeEvent then
        StatusLabel.Text = "Status: No valid dupe event found!"
        return
    end
    
    local success, err = pcall(function()
        local args = {
            [1] = heldItem.Name,
            [2] = HttpService:GenerateGUID(false),
            [3] = heldItem:FindFirstChild("Value") and heldItem.Value or
                  heldItem:FindFirstChild("ID") and heldItem.ID.Value or heldItem.Name
        }
        args = obfuscateArgs(args)
        dupeEvent:FireServer(unpack(args))
    end)
    
    dupeAttempts = dupeAttempts + 1
    if success then
        StatusLabel.Text = "Status: Dupe attempt " .. dupeAttempts .. " for " .. heldItem.Name
    else
        StatusLabel.Text = "Status: Dupe failed - " .. tostring(err)
    end
end

-- Multi-Dupe Function
local function multiDupe()
    if not heldItem then
        StatusLabel.Text = "Status: No held item or pet detected!"
        return
    end
    
    local dupeEvent = findDupeEvent(heldItemType)
    if not dupeEvent then
        StatusLabel.Text = "Status: No valid dupe event found!"
        return
    end
    
    for i = 1, maxAttempts do
        local success, err = pcall(function()
            local args = {
                [1] = heldItem.Name,
                [2] = HttpService:GenerateGUID(false),
                [3] = heldItem:FindFirstChild("Value") and heldItem.Value or
                      heldItem:FindFirstChild("ID") and heldItem.ID.Value or heldItem.Name
            }
            args = obfuscateArgs(args)
            dupeEvent:FireServer(unpack(args))
        end)
        
        dupeAttempts = dupeAttempts + 1
        if success then
            StatusLabel.Text = "Status: Multi-Dupe " .. i .. "/" .. maxAttempts .. " for " .. heldItem.Name
        else
            StatusLabel.Text = "Status: Multi-Dupe failed - " .. tostring(err)
            break
        end
        wait(math.random(0.1, 0.15))
    end
end

-- Button Connections
DupeButton.MouseButton1Click:Connect(dupeItem)
MultiDupeButton.MouseButton1Click:Connect(multiDupe)
DebugButton.MouseButton1Click:Connect(debugItemData)

-- Auto-Update Item Info
spawn(function()
    while wait(0.2) do
        updateItemInfo()
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
    while wait(5) do
        VirtualUser:CaptureController()
    end
end)

-- Initial Setup
updateItemInfo()
print("Grow a Garden Dupe Script v1.0 Loaded")
