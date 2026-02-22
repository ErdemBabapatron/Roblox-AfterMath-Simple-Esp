local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local Camera = workspace.CurrentCamera
local Entities = workspace:WaitForChild("game_assets"):WaitForChild("Entities")

local ESPs = {}
local toggled = true


UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        toggled = not toggled
    end
end)

local function WorldToScreen(position)
    local screenPoint, onScreen = Camera:WorldToViewportPoint(position)
    return Vector2.new(screenPoint.X, screenPoint.Y), onScreen
end

local function createESP(model)
    if ESPs[model] or model == LocalPlayer.Character then return end
    
    local HRP = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso")
    if not HRP then return end
    
    local box = Drawing.new("Square")
    box.Size = Vector2.new(0, 0)
    box.Position = Vector2.new(0, 0)
    box.Color = Color3.fromRGB(255, 0, 0)  
    box.Thickness = 2
    box.Filled = false
    box.Transparency = 1
    box.Visible = false
    
    local nameTag = Drawing.new("Text")
    nameTag.Size = 16
    nameTag.Center = true
    nameTag.Outline = true
    nameTag.Font = 2  
    nameTag.Color = Color3.fromRGB(255, 255, 255)
    nameTag.Text = model.Name:gsub("%[", ""):gsub("%]", "")  
    nameTag.Visible = false
    
    ESPs[model] = {box = box, name = nameTag, HRP = HRP}
end

local function removeESP(model)
    if ESPs[model] then
        ESPs[model].box:Remove()
        ESPs[model].name:Remove()
        ESPs[model] = nil
    end
end

local function updateESP()
    if not toggled then
        for _, esp in pairs(ESPs) do
            esp.box.Visible = false
            esp.name.Visible = false
        end
        return
    end
    
    for model, esp in pairs(ESPs) do
        if esp.HRP and esp.HRP.Parent and model.Parent then
            local pos, onScreen = WorldToScreen(esp.HRP.Position)
            
            if onScreen then
                
                local headPos = model:FindFirstChild("Head")
                local topPoint = Camera:WorldToViewportPoint(esp.HRP.Position + Vector3.new(0, 4, 0))
                local bottomPoint = Camera:WorldToViewportPoint(esp.HRP.Position - Vector3.new(0, 5, 0))
                local height = math.abs(topPoint.Y - bottomPoint.Y)
                local width = height / 2.2
                
                esp.box.Size = Vector2.new(width, height)
                esp.box.Position = Vector2.new(pos.X - width / 2, pos.Y - height / 2)
                esp.box.Visible = true
                
                esp.name.Position = Vector2.new(pos.X, pos.Y - height / 2 - 20)
                local humanoid = model:FindFirstChildOfClass("Humanoid")
                local dist = ""
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    dist = string.format(" [%.0fm]", (LocalPlayer.Character.HumanoidRootPart.Position - esp.HRP.Position).Magnitude)
                end
                esp.name.Text = (humanoid and string.format("%d/%d", humanoid.Health, humanoid.MaxHealth) or "") .. dist
                esp.name.Visible = true
            else
                esp.box.Visible = false
                esp.name.Visible = false
            end
        else
            removeESP(model)
        end
    end
end


local function scan()
    for _, obj in ipairs(Entities:GetDescendants()) do
        if obj:IsA("Model") then
            createESP(obj)
        end
    end
end

scan()


Entities.DescendantAdded:Connect(function(obj)
    if obj:IsA("Model") then
        task.wait(0.1)  
        createESP(obj)
    end
end)


RunService.RenderStepped:Connect(updateESP)

print("AfterMath Simple Esp Is loaded Ins to oppen and close")
