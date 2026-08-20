-- НАСТРОЙКИ
local ToggleKey = Enum.KeyCode.C -- Клавиша для телепортации к следующему игроку (английская C)
local TeleportOffset = Vector3.new(0, 3, -4) -- Смещение при ТП (чтобы не застрять внутри игрока)

-- СЕРВИСЫ ROBLOX
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local targetPlayerIndex = 1 -- Индекс для отслеживания текущей цели

-- Функция для получения списка всех живых игроков (исключая себя)
local function getValidTargets()
    local targets = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            
            -- Проверяем, что персонаж существует, у него есть RootPart и он жив
            if hrp and hum and hum.Health > 0 then
                table.insert(targets, player)
            end
        end
    end
    return targets
end

-- ОБРАБОТКА НАЖАТИЯ НА КЛАВИШУ C
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end -- Игнорируем нажатия, если открыт чат

    if input.KeyCode == ToggleKey then
        local myChar = LocalPlayer.Character
        local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        
        if not myHRP then return end
        
        -- Получаем актуальный список живых игроков
        local validTargets = getValidTargets()
        
        if #validTargets == 0 then
            print("[Xeno] Нет доступных игроков для телепортации.")
            return
        end
        
        -- Корректируем индекс, если список игроков изменился или мы дошли до конца
        if targetPlayerIndex > #validTargets then
            targetPlayerIndex = 1
        end
        
        -- Выбираем цель
        local targetPlayer = validTargets[targetPlayerIndex]
        local targetChar = targetPlayer.Character
        local targetHRP = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
        
        if targetHRP then
            -- Телепортируем нашего персонажа к цели с заданным смещением
            myHRP.CFrame = targetHRP.CFrame * CFrame.new(TeleportOffset)
            
            -- Плавно разворачиваем камеру в сторону игрока, чтобы не потерять ориентацию
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetHRP.Position)
            
            print("[Xeno] Телепорт к игроку: " .. targetPlayer.Name .. " (" .. targetPlayerIndex .. "/" .. #validTargets .. ")")
            
            -- Сдвигаем индекс на следующего игрока для будущего нажатия
            targetPlayerIndex = targetPlayerIndex + 1
            if targetPlayerIndex > #validTargets then
                targetPlayerIndex = 1 -- Возвращаемся в начало списка
            end
        else
            -- Если выбранный игрок резко вышел или погиб в этот миг, пробуем снова со следующим
            targetPlayerIndex = targetPlayerIndex + 1
        end
    end
end)

print("[Xeno] Скрипт циклического ТП по игрокам запущен. Нажимайте C.")

