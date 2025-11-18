--// CONFIG
local REFRESH_RATE = 0.2 -- segundos
local HOLD_TIME = 2
local TweenService = game:GetService("TweenService")

--// UI SETUP
local ScreenGui = Instance.new("ScreenGui", game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"))
ScreenGui.ResetOnSpawn = false

local Button = Instance.new("TextButton", ScreenGui)
Button.Size = UDim2.new(0, 140, 0, 40)
Button.Position = UDim2.new(0.4, 0, 0.2, 0)
Button.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
Button.TextColor3 = Color3.fromRGB(255,255,255)
Button.Font = Enum.Font.GothamBold
Button.TextSize = 16
Button.Text = "AutoCompra: OFF"
Button.Active = true
Button.Draggable = true

local UIStroke = Instance.new("UIStroke", Button)
UIStroke.Thickness = 2
UIStroke.Color = Color3.fromRGB(255,255,255)

local UICorner = Instance.new("UICorner", Button)
UICorner.CornerRadius = UDim.new(0, 10)

--// ESTADO
local activo = false
local minimizado = false
local holding = false

--// FUNCIÓN AUTO COMPRA
task.spawn(function()
    while true do
        if activo then
            for _, v in pairs(game:GetService("Players").LocalPlayer.PlayerGui:GetDescendants()) do
                if v:IsA("TextButton") and string.find(string.lower(v.Text), "compra") then
                    pcall(function() v:Activate() end)
                end
            end
        end
        task.wait(REFRESH_RATE)
    end
end)

--// ANIMACIÓN
local function animate(obj, props, time)
    local tween = TweenService:Create(obj, TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
    tween:Play()
    return tween
end

--// MINIMIZAR / RESTAURAR
local function setMinimized(state)
    minimizado = state

    if state then
        -- Minimizar (tamaño pequeño)
        animate(Button, {Size = UDim2.new(0, 40, 0, 40)}, 0.25)
        
        task.delay(0.15, function()
            if minimizado then
                Button.Text = ""
            end
        end)

    else
        -- Restaurar (tamaño normal)
        animate(Button, {Size = UDim2.new(0, 140, 0, 40)}, 0.25)
        
        task.delay(0.15, function()
            Button.Text = activo and "AutoCompra: ON" or "AutoCompra: OFF"
        end)
    end
end

--// DETECTAR HOLD (2 SEGUNDOS)
Button.MouseButton1Down:Connect(function()
    holding = true
    local startTime = tick()

    task.spawn(function()
        while holding do
            if tick() - startTime >= HOLD_TIME then
                setMinimized(not minimizado)
                return
            end
            task.wait()
        end
    end)
end)

Button.MouseButton1Up:Connect(function()
    holding = false
end)

--// CLICK NORMAL (solo si NO hubo hold)
Button.MouseButton1Click:Connect(function()
    if holding then return end

    activo = not activo

    if activo then
        Button.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        if not minimizado then Button.Text = "AutoCompra: ON" end
    else
        Button.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
        if not minimizado then Button.Text = "AutoCompra: OFF" end
    end
end)
