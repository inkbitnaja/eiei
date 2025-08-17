-- 🧠 Smart Auto Server Hop - อัปเดตล่าสุด 2025
-- แก้ไขโดยใช้ API ตัวใหม่ (apis.roblox.com) และปรับปรุงประสิทธิภาพ
-- ไม่เข้าเซิร์ฟ 1/5 คน (มักเป็น Private Server)

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local currentJobId = game.JobId
local placeId = game.PlaceId

-- ------------------[ การตั้งค่า ]------------------
local isAutoHop = true
local maxPlayersBeforeHop = 4 -- ⭐ เมื่อคนมากกว่า 4 จะเริ่มนับเวลา
local waitTimeBeforeHop = 10  -- 🕐 รอ 10 วินาที ก่อน Hop (เมื่อมี 4+ คน)
-- ------------------------------------------------

-- ตัวแปรควบคุมภายใน
local isHopping = false
local timeWhenExceeded = nil
local isWaitingToHop = false

-- ฟังก์ชันสำหรับส่งข้อความแจ้งเตือนในเกม
local function showSystemMessage(text, color)
    pcall(function()
        StarterGui:SetCore("ChatMakeSystemMessage", {
            Text = text,
            Color = color or Color3.fromRGB(0, 255, 100)
        })
    end)
end

print("🧠 === Smart Auto Server Hop (Updated 2025) ===")
print("📍 Place ID:", placeId)
print("👥 ผู้เล่นปัจจุบัน:", #Players:GetPlayers(), "คน")
print("🎯 หาเซิร์ฟ 2-3 คน (ไม่เอาเซิร์ฟเต็ม 5/5 คน)")
print("⏰ รอ", waitTimeBeforeHop, "วินาที ก่อน Hop เมื่อคนเกิน", maxPlayersBeforeHop, "คน")
print("🚀 Hop ทันทีเมื่อเซิร์ฟเต็ม 5 คน!")

showSystemMessage("🧠 Smart Auto Hop พร้อม - เต็ม 5 คน = Hop ทันที!", Color3.fromRGB(0, 255, 100))

-- ------------------[ สร้าง GUI ]------------------
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "SmartHopGUI"
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 210)
mainFrame.Position = UDim2.new(0, 20, 0, 120)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BackgroundTransparency = 0.2
mainFrame.BorderSizePixel = 1
mainFrame.BorderColor3 = Color3.fromRGB(80, 80, 80)
mainFrame.Draggable = true
mainFrame.Active = true
mainFrame.Parent = screenGui

local mainButton = Instance.new("TextButton", mainFrame)
mainButton.Size = UDim2.new(1, 0, 0, 50)
mainButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
mainButton.Text = "✅ Smart Hop: ON"
mainButton.TextColor3 = Color3.new(1, 1, 1)
mainButton.TextSize = 18
mainButton.Font = Enum.Font.SourceSansBold

local hopButton = Instance.new("TextButton", mainFrame)
hopButton.Size = UDim2.new(1, 0, 0, 35)
hopButton.Position = UDim2.new(0, 0, 0, 55)
hopButton.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
hopButton.Text = "🚀 Hop ทันที"
hopButton.TextColor3 = Color3.new(1, 1, 1)
hopButton.TextSize = 16
hopButton.Font = Enum.Font.SourceSans

local statusLabel = Instance.new("TextLabel", mainFrame)
statusLabel.Size = UDim2.new(1, -10, 0, 20)
statusLabel.Position = UDim2.new(0, 5, 0, 95)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Smart Hop เปิด"
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.TextSize = 14
statusLabel.Font = Enum.Font.SourceSans
statusLabel.TextXAlignment = Enum.TextXAlignment.Left

local serverInfo = Instance.new("TextLabel", mainFrame)
serverInfo.Size = UDim2.new(1, -10, 0, 20)
serverInfo.Position = UDim2.new(0, 5, 0, 120)
serverInfo.BackgroundTransparency = 1
serverInfo.Text = "กำลังตรวจสอบ..."
serverInfo.TextColor3 = Color3.fromRGB(150, 150, 150)
serverInfo.TextSize = 12
serverInfo.Font = Enum.Font.SourceSans
serverInfo.TextXAlignment = Enum.TextXAlignment.Left

local settingsLabel = Instance.new("TextLabel", mainFrame)
settingsLabel.Size = UDim2.new(1, -10, 0, 30)
settingsLabel.Position = UDim2.new(0, 5, 0, 140)
settingsLabel.BackgroundTransparency = 1
settingsLabel.Text = "⚙️ หาเซิร์ฟ 2-3 คน | 5 คน = Hop ทันที"
settingsLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
settingsLabel.TextSize = 12
settingsLabel.Font = Enum.Font.SourceSansBold
settingsLabel.TextXAlignment = Enum.TextXAlignment.Left
settingsLabel.TextWrapped = true

local timerLabel = Instance.new("TextLabel", mainFrame)
timerLabel.Size = UDim2.new(1, -10, 0, 20)
timerLabel.Position = UDim2.new(0, 5, 0, 175)
timerLabel.BackgroundTransparency = 1
timerLabel.Text = ""
timerLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
timerLabel.TextSize = 14
timerLabel.Font = Enum.Font.SourceSansBold
timerLabel.TextXAlignment = Enum.TextXAlignment.Left

-- ------------------[ ฟังก์ชันหลัก ]------------------

-- ฟังก์ชันหาเซิร์ฟเวอร์ (แก้ไขใหม่)
local function findGoodServer()
    print("🔍 กำลังหาเซิร์ฟเวอร์ 2-3 คน...")
    statusLabel.Text = "กำลังค้นหาเซิร์ฟ 2-3 คน"
    
    local servers = {}
    local cursor = ""
    local attempts = 0
    
    repeat
        local url = string.format("https://apis.roblox.com/games/v1/games/%d/servers/Public?sortOrder=2&limit=100&cursor=%s", placeId, cursor)
        
        local success, response = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(url))
        end)
        
        if success and response and response.data then
            for _, server in ipairs(response.data) do
                -- 🎯 กรองเซิร์ฟเวอร์ หาเฉพาะ 2-3 คน
                if server.id ~= currentJobId and server.playing >= 2 and server.playing <= 3 and server.maxPlayers == 5 then
                    table.insert(servers, {
                        id = server.id,
                        players = server.playing,
                        ping = server.ping or 999
                    })
                end
            end
            cursor = response.nextPageCursor or ""
        else
            print("❌ ไม่สามารถเชื่อมต่อ API หรือข้อมูลผิดพลาด")
            break
        end
        
        attempts = attempts + 1
        task.wait(0.3) -- หน่วงเวลาเล็กน้อยเพื่อไม่ให้ API request ถี่เกินไป
    until not cursor or #servers > 10 or attempts > 5 -- หาจนเจอ 10 เซิร์ฟ หรือครบ 5 หน้า
    
    if #servers == 0 then
        print("❌ ไม่พบเซิร์ฟเวอร์ 2-3 คน")
        statusLabel.Text = "ไม่พบเซิร์ฟ 2-3 คน"
        return nil
    end
    
    -- เรียงลำดับตาม Ping (น้อยที่สุด)
    table.sort(servers, function(a, b)
        return a.ping < b.ping
    end)
    
    local bestServer = servers[1]
    print(string.format("✅ พบเซิร์ฟดีที่สุด: %d คน | Ping: %dms", bestServer.players, bestServer.ping))
    statusLabel.Text = string.format("พบเซิร์ฟ %d/5 คน", bestServer.players)
    serverInfo.Text = string.format("Ping: %dms | กำลัง Teleport...", bestServer.ping)
    
    return bestServer.id
end

-- ฟังก์ชัน Teleport
local function safeTeleport(serverId)
    if not serverId then return false end
    
    print("🚀 เริ่ม Teleport ไปยัง:", serverId)
    statusLabel.Text = "กำลัง Teleport..."
    
    local success, err = pcall(function()
        TeleportService:TeleportToPlaceInstance(placeId, serverId, player)
    end)
    
    if not success then
        print("❌ Teleport ล้มเหลว:", err)
        statusLabel.Text = "Teleport ล้มเหลว"
        return false
    end
    
    return true
end

-- ฟังก์ชันเริ่มกระบวนการ Hop
local function executeHop(reason)
    if isHopping then return end
    isHopping = true
    isWaitingToHop = false
    timeWhenExceeded = nil
    
    print("🚀 เริ่มกระบวนการ Auto Hop. สาเหตุ:", reason)
    showSystemMessage("🚀 Hop หาเซิร์ฟ 2-3 คน (" .. reason .. ")", Color3.fromRGB(255, 100, 100))
    
    timerLabel.Text = "🚀 กำลัง Hop..."
    hopButton.Text = "⏳ กำลัง Hop..."
    statusLabel.Text = "กำลัง Hop: " .. reason

    task.spawn(function()
        local serverId = findGoodServer()
        if serverId then
            if not safeTeleport(serverId) then
                task.wait(3)
                statusLabel.Text = "Hop ล้มเหลว, ลองใหม่"
            end
        else
            task.wait(5)
            statusLabel.Text = "ไม่พบเซิร์ฟ, รอสักครู่"
        end
        
        -- รีเซ็ตสถานะหลังพยายาม Hop
        task.wait(2)
        isHopping = false
        hopButton.Text = "🚀 Hop ทันที"
        timerLabel.Text = ""
    end)
end

-- ------------------[ Event Listeners ]------------------

mainButton.MouseButton1Click:Connect(function()
    isAutoHop = not isAutoHop
    if isAutoHop then
        mainButton.Text = "✅ Smart Hop: ON"
        mainButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        statusLabel.Text = "Smart Hop เปิด"
        print("✅ Smart Hop เปิดใช้งาน")
    else
        mainButton.Text = "🔘 Smart Hop: OFF"
        mainButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        statusLabel.Text = "Smart Hop ปิด"
        -- ยกเลิกการนับเวลาถ้าปิด
        isWaitingToHop = false
        timeWhenExceeded = nil
        timerLabel.Text = ""
        print("⏹️ Smart Hop ปิดแล้ว")
    end
end)

hopButton.MouseButton1Click:Connect(function()
    executeHop("กดปุ่ม")
end)

Players.PlayerAdded:Connect(function(newPlayer)
    task.wait(0.5) -- รอให้จำนวนผู้เล่นอัปเดตแน่นอน
    print(string.format("➕ %s เข้ามา (รวม %d คน)", newPlayer.Name, #Players:GetPlayers()))
end)

Players.PlayerRemoving:Connect(function(leftPlayer)
    task.wait(0.1)
    local newCount = #Players:GetPlayers()
    print(string.format("➖ %s ออกไป (เหลือ %d คน)", leftPlayer.Name, newCount))
    -- ถ้ายกเลิกการนับเวลาเพราะคนน้อยลง
    if isWaitingToHop and newCount <= maxPlayersBeforeHop then
        isWaitingToHop = false
        timeWhenExceeded = nil
        timerLabel.Text = ""
        showSystemMessage("👍 คนน้อยลง, ยกเลิกการนับเวลา Hop", Color3.fromRGB(150, 255, 150))
    end
end)

-- ------------------[ Loop หลัก ]------------------
task.spawn(function()
    while task.wait(2) do
        if not isAutoHop or isHopping then continue end

        local currentPlayers = #Players:GetPlayers()
        
        -- อัปเดต GUI แสดงข้อมูล
        if not isWaitingToHop then
            serverInfo.Text = string.format("เซิร์ฟปัจจุบัน: %d/5 คน", currentPlayers)
            if currentPlayers >= 5 then
                serverInfo.TextColor3 = Color3.fromRGB(255, 50, 50) -- แดง
            elseif currentPlayers > maxPlayersBeforeHop then
                serverInfo.TextColor3 = Color3.fromRGB(255, 150, 0) -- ส้ม
            else
                serverInfo.TextColor3 = Color3.fromRGB(100, 255, 100) -- เขียว
            end
        end

        -- 1. Hop ทันทีถ้าเต็ม
        if currentPlayers >= 5 then
            executeHop("เซิร์ฟเต็ม")
            continue
        end

        -- 2. เริ่มนับเวลาถอยหลังถ้าคนเกินกำหนด
        if currentPlayers > maxPlayersBeforeHop then
            if not isWaitingToHop then
                isWaitingToHop = true
                timeWhenExceeded = tick()
                showSystemMessage(string.format("⏰ คนเกิน %d, เริ่มนับเวลา %ds", maxPlayersBeforeHop, waitTimeBeforeHop), Color3.fromRGB(255, 200, 0))
            end
        else
            -- หยุดนับถ้าคนน้อยลง
            if isWaitingToHop then
                isWaitingToHop = false
                timeWhenExceeded = nil
                timerLabel.Text = ""
            end
        end

        -- 3. ตรวจสอบการนับเวลา
        if isWaitingToHop and timeWhenExceeded then
            local timeElapsed = tick() - timeWhenExceeded
            local timeLeft = waitTimeBeforeHop - timeElapsed
            
            if timeLeft <= 0 then
                executeHop("ครบเวลาที่กำหนด")
            else
                timerLabel.Text = string.format("⏰ Hop ใน %d วินาที", math.ceil(timeLeft))
            end
        end
    end
end)

print("🧠 === Smart Auto Hop พร้อมใช้งาน ===")
