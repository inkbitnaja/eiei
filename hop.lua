-- 🧠 Smart Auto Server Hop - Hop ทันทีเมื่อเซิร์ฟเต็ม 5 คน
-- ไม่เข้าเซิร์ฟ 1/5 คน (มักเป็น Private Server)

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local currentJobId = game.JobId
local placeId = game.PlaceId

-- ตัวแปรควบคุม
local isAutoHop = true
local isHopping = false
local maxPlayersBeforeHop = 4 -- ⭐ เมื่อคนเกิน 4 จะเริ่มนับเวลา
local waitTimeBeforeHop = 10 -- 🕐 รอ 10 วินาที ก่อน Hop
local playerCountCheckInterval = 5 -- ตรวจสอบทุก 5 วินาที

-- ตัวแปรสำหรับนับเวลา
local timeWhenExceeded = nil -- เวลาที่คนเกินกำหนดครั้งแรก
local isWaitingToHop = false -- กำลังรอเวลาก่อน Hop

print("🧠 === Smart Auto Server Hop ===")
print("📍 Place ID:", placeId)
print("👥 ผู้เล่นปัจจุบัน:", #Players:GetPlayers(), "คน")
print("⚙️ เกมนี้ MaxPlayers = 5 คน")
print("🎯 หาเซิร์ฟ 2-3 คน (ไม่เอาเซิร์ฟเต็ม 5/5 คน)")
print("⏰ รอสูงสุด", waitTimeBeforeHop, "วินาที ก่อน Hop เมื่อคนเกิน", maxPlayersBeforeHop, "คน")
print("🚀 Hop ทันทีเมื่อเซิร์ฟเต็ม 5 คน!")

-- ส่งข้อความแจ้งใน Chat
pcall(function()
    StarterGui:SetCore("ChatMakeSystemMessage", {
        Text = "🧠 Smart Auto Hop พร้อม - Hop ทันทีเมื่อเต็ม 5 คน!";
        Color = Color3.fromRGB(0, 255, 100);
    })
end)

-- สร้าง GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SmartHopGUI"
screenGui.ResetOnSpawn = false

-- ลองใส่ GUI
pcall(function()
    screenGui.Parent = player:WaitForChild("PlayerGui")
end)

if not screenGui.Parent then
    pcall(function()
        screenGui.Parent = game:GetService("CoreGui")
    end)
end

-- ปุ่มหลัก
local mainButton = Instance.new("TextButton")
mainButton.Size = UDim2.new(0, 220, 0, 50)
mainButton.Position = UDim2.new(0, 20, 0, 120)
mainButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0) -- เริ่มเป็น ON
mainButton.BorderSizePixel = 2
mainButton.BorderColor3 = Color3.fromRGB(100, 100, 100)
mainButton.Text = "✅ Smart Hop: ON"
mainButton.TextColor3 = Color3.new(1, 1, 1)
mainButton.TextSize = 18
mainButton.Font = Enum.Font.SourceSansBold
mainButton.Active = true
mainButton.Draggable = true
mainButton.Parent = screenGui

-- ปุ่ม Hop ทันที
local hopButton = Instance.new("TextButton")
hopButton.Size = UDim2.new(0, 220, 0, 35)
hopButton.Position = UDim2.new(0, 20, 0, 175)
hopButton.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
hopButton.BorderSizePixel = 1
hopButton.Text = "🚀 Hop ทันที"
hopButton.TextColor3 = Color3.new(1, 1, 1)
hopButton.TextSize = 16
hopButton.Font = Enum.Font.SourceSans
hopButton.Parent = screenGui

-- แสดงสถานะ
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0, 220, 0, 25)
statusLabel.Position = UDim2.new(0, 20, 0, 215)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Smart Hop เปิด"
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.TextSize = 14
statusLabel.Font = Enum.Font.SourceSans
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = screenGui

-- ข้อมูลเซิร์ฟเวอร์
local serverInfo = Instance.new("TextLabel")
serverInfo.Size = UDim2.new(0, 220, 0, 20)
serverInfo.Position = UDim2.new(0, 20, 0, 240)
serverInfo.BackgroundTransparency = 1
serverInfo.Text = "กำลังตรวจสอบ..."
serverInfo.TextColor3 = Color3.fromRGB(150, 150, 150)
serverInfo.TextSize = 12
serverInfo.Font = Enum.Font.SourceSans
serverInfo.TextXAlignment = Enum.TextXAlignment.Left
serverInfo.Parent = screenGui

-- แสดงการตั้งค่า
local settingsLabel = Instance.new("TextLabel")
settingsLabel.Size = UDim2.new(0, 220, 0, 20)
settingsLabel.Position = UDim2.new(0, 20, 0, 260)
settingsLabel.BackgroundTransparency = 1
settingsLabel.Text = "⚙️ หาเซิร์ฟ 2-3 คน | เต็ม 5 คน = Hop ทันที"
settingsLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
settingsLabel.TextSize = 12
settingsLabel.Font = Enum.Font.SourceSansBold
settingsLabel.TextXAlignment = Enum.TextXAlignment.Left
settingsLabel.Parent = screenGui

-- ตัวนับเวลา
local timerLabel = Instance.new("TextLabel")
timerLabel.Size = UDim2.new(0, 220, 0, 20)
timerLabel.Position = UDim2.new(0, 20, 0, 280)
timerLabel.BackgroundTransparency = 1
timerLabel.Text = ""
timerLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
timerLabel.TextSize = 14
timerLabel.Font = Enum.Font.SourceSansBold
timerLabel.TextXAlignment = Enum.TextXAlignment.Left
timerLabel.Parent = screenGui

-- ฟังก์ชันตรวจสอบและเริ่มนับเวลา หรือ Hop ทันทีถ้าเต็ม
local function checkPlayerCountAndStartTimer()
    local currentPlayers = #Players:GetPlayers()
    
    if isAutoHop and not isHopping then
        -- 🚀 ถ้าเต็ม 5 คน = Hop ทันที!
        if currentPlayers >= 5 then
            print("🚀 เซิร์ฟเต็ม 5 คน - เริ่ม Hop ทันที!")
            
            pcall(function()
                StarterGui:SetCore("ChatMakeSystemMessage", {
                    Text = "🚀 เซิร์ฟเต็ม 5 คน - เริ่ม Hop ทันที!";
                    Color = Color3.fromRGB(255, 50, 50);
                })
            end)
            
            -- เรียกใช้ task.spawn เพื่อให้ทำงานแยกจาก loop หลัก
            task.spawn(function()
                executeAutoHop()
            end)
            
        -- ⏰ ถ้าคนเกิน maxPlayersBeforeHop (4 คน) แต่ยังไม่เต็ม 5 - เริ่มนับเวลา
        elseif currentPlayers > maxPlayersBeforeHop then
            if not isWaitingToHop then
                timeWhenExceeded = tick()
                isWaitingToHop = true
                print("⏰ คนในเซิร์ฟเกิน " .. maxPlayersBeforeHop .. " คน - เริ่มนับเวลา " .. waitTimeBeforeHop .. " วินาที")
                
                pcall(function()
                    StarterGui:SetCore("ChatMakeSystemMessage", {
                        Text = "⏰ คนเกิน " .. maxPlayersBeforeHop .. " คน - เริ่มนับเวลา " .. waitTimeBeforeHop .. " วินาที";
                        Color = Color3.fromRGB(255, 200, 0);
                    })
                end)
            end
        end
    end
end

-- ฟังก์ชัน Hop เมื่อครบเวลา
local function executeAutoHop()
    if isHopping then 
        print("⚠️ กำลัง Hop อยู่แล้ว")
        return 
    end
    
    local currentPlayers = #Players:GetPlayers()
    
    print("🚀 เริ่มกระบวนการ Auto Hop")
    
    if currentPlayers >= 5 then
        print("🚀 สาเหตุ: เซิร์ฟเต็ม 5 คน - เริ่ม Auto Hop ทันที")
        statusLabel.Text = "เซิร์ฟเต็ม - กำลัง Hop ทันที"
        
        pcall(function()
            StarterGui:SetCore("ChatMakeSystemMessage", {
                Text = "🚀 กำลัง Hop หาเซิร์ฟคนน้อย (2-3 คน) - เซิร์ฟเต็ม!";
                Color = Color3.fromRGB(255, 50, 50);
            })
        end)
    else
        print("🚀 สาเหตุ: ครบเวลาแล้ว - เริ่ม Auto Hop")
        statusLabel.Text = "ครบเวลาแล้ว - กำลัง Hop"
        
        pcall(function()
            StarterGui:SetCore("ChatMakeSystemMessage", {
                Text = "🚀 กำลัง Hop หาเซิร์ฟคนน้อย (2-3 คน) - ครบเวลา!";
                Color = Color3.fromRGB(255, 100, 100);
            })
        end)
    end
    
    isHopping = true
    isWaitingToHop = false
    timeWhenExceeded = nil
    timerLabel.Text = "🚀 กำลัง Hop..."
    hopButton.Text = "⏳ กำลัง Hop..."
    
    -- ใช้ task.spawn เพื่อไม่ให้บล็อค loop หลัก
    task.spawn(function()
        print("🔍 เริ่มค้นหาเซิร์ฟเวอร์...")
        local serverId = findGoodServer()
        
        if serverId then
            print("✅ พบเซิร์ฟเวอร์เป้าหมาย - เริ่ม Teleport")
            local success = safeTeleport(serverId)
            
            if not success then
                print("❌ Teleport ล้มเหลว")
                task.wait(3)
                statusLabel.Text = "Hop ล้มเหลว - ลองใหม่"
                timerLabel.Text = ""
                isHopping = false
                hopButton.Text = "🚀 Hop ทันที"
            end
        else
            print("❌ ไม่พบเซิร์ฟเวอร์เหมาะสม")
            statusLabel.Text = "ไม่พบเซิร์ฟเหมาะสม"
            timerLabel.Text = ""
            task.wait(30) -- รอ 30 วินาทีก่อนลองใหม่
            isHopping = false
            hopButton.Text = "🚀 Hop ทันที"
        end
    end)
end

-- ฟังก์ชันหาเซิร์ฟเวอร์ที่ดี (หาเฉพาะ 2-3 คน)
local function findGoodServer()
    print("🔍 กำลังหาเซิร์ฟเวอร์ 2-3 คน...")
    statusLabel.Text = "กำลังค้นหาเซิร์ฟ 2-3 คน"
    
    local servers = {}
    local cursor = ""
    local totalChecked = 0
    
    -- ดึงข้อมูลเซิร์ฟเวอร์
    for page = 1, 10 do
        local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"
        if cursor ~= "" then
            url = url .. "&cursor=" .. cursor
        end
        
        local success, response = pcall(function()
            return game:HttpGet(url)
        end)
        
        if success then
            local data = HttpService:JSONDecode(response)
            
            if data and data.data then
                for _, server in pairs(data.data) do
                    totalChecked = totalChecked + 1
                    
                    -- 🎯 กรองเซิร์ฟเวอร์ หาเฉพาะ 2-3 คน
                    if server.id ~= currentJobId and 
                       server.playing and server.maxPlayers and
                       server.playing >= 2 and -- อย่างน้อย 2 คน
                       server.playing <= 3 and -- ไม่เกิน 3 คน
                       server.maxPlayers == 5 and -- MaxPlayers ต้องเป็น 5
                       server.playing < server.maxPlayers and -- ไม่เอาเซิร์ฟเต็ม
                       server.id and string.len(server.id) > 10 then -- Server ID ถูกต้อง
                        
                        table.insert(servers, {
                            id = server.id,
                            players = server.playing,
                            maxPlayers = server.maxPlayers,
                            ping = server.ping or 999
                        })
                    end
                end
                
                cursor = data.nextPageCursor or ""
                serverInfo.Text = "ตรวจสอบแล้ว: " .. totalChecked .. " เซิร์ฟ"
            end
        else
            print("❌ ไม่สามารถเชื่อมต่อ API")
            break
        end
        
        if not cursor or cursor == "" then break end
        task.wait(0.2)
    end
    
    if #servers == 0 then
        print("❌ ไม่พบเซิร์ฟเวอร์ 2-3 คน")
        statusLabel.Text = "ไม่พบเซิร์ฟ 2-3 คน"
        serverInfo.Text = "ลองใหม่ในอีกสักครู่"
        return nil
    end
    
    -- เรียงลำดับตามจำนวนผู้เล่นและ ping
    table.sort(servers, function(a, b)
        if a.players == b.players then
            return a.ping < b.ping
        end
        return a.players < b.players
    end)
    
    local bestServer = servers[1]
    print("✅ พบเซิร์ฟเวอร์ " .. bestServer.players .. " คน:")
    print("   👥 ผู้เล่น:", bestServer.players .. "/" .. bestServer.maxPlayers)
    print("   📶 Ping:", bestServer.ping .. "ms")
    print("   🆔 Server ID:", bestServer.id)
    
    statusLabel.Text = "พบเซิร์ฟ " .. bestServer.players .. "/" .. bestServer.maxPlayers .. " คน"
    serverInfo.Text = "Ping: " .. bestServer.ping .. "ms | กำลัง Teleport..."
    
    return bestServer.id
end

-- ฟังก์ชัน Teleport ที่ปรับปรุง
local function safeTeleport(serverId)
    print("🚀 เริ่ม Teleport...")
    statusLabel.Text = "กำลัง Teleport..."
    
    if not serverId or serverId == "" or string.len(serverId) < 10 then
        print("❌ Server ID ไม่ถูกต้อง:", serverId)
        statusLabel.Text = "Server ID ผิดพลาด"
        return false
    end
    
    -- ลอง Teleport แบบต่างๆ
    local teleportMethods = {
        function()
            print("📡 ลอง Teleport วิธีที่ 1...")
            TeleportService:TeleportToPlaceInstance(placeId, serverId, player)
        end,
        function()
            print("📡 ลอง Teleport วิธีที่ 2...")
            TeleportService:Teleport(placeId, player)
        end
    }
    
    for i, method in ipairs(teleportMethods) do
        local success, error = pcall(method)
        if success then
            print("✅ Teleport สำเร็จด้วยวิธีที่", i, "- รอการเชื่อมต่อ...")
            
            -- รอ 10 วินาที ถ้ายังไม่ออกจากเกม ถือว่าล้มเหลว
            local startTime = tick()
            while tick() - startTime < 10 do
                task.wait(0.5)
                if not player.Parent then -- ถ้าผู้เล่นออกจากเกมแล้ว
                    return true
                end
            end
            
            print("⚠️ Teleport ไม่สำเร็จ - ไม่ออกจากเกม")
        else
            print("❌ วิธีที่", i, "ล้มเหลว:", error)
        end
        
        if i < #teleportMethods then
            task.wait(1)
        end
    end
    
    print("❌ Teleport ล้มเหลวทุกวิธี")
    statusLabel.Text = "Teleport ล้มเหลว"
    return false
end

-- Event ปุ่มหลัก
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
        if isWaitingToHop then
            timeWhenExceeded = nil
            isWaitingToHop = false
            timerLabel.Text = ""
        end
        
        print("⏹️ Smart Hop ปิดแล้ว")
    end
end)

-- Event ปุ่ม Hop ทันที
hopButton.MouseButton1Click:Connect(function()
    if isHopping then
        print("⚠️ กำลัง Hop อยู่ รอสักครู่")
        return
    end
    
    isHopping = true
    hopButton.Text = "⏳ กำลัง Hop..."
    hopButton.BackgroundColor3 = Color3.fromRGB(100, 100, 0)
    
    task.spawn(function()
        local serverId = findGoodServer()
        if serverId then
            local success = safeTeleport(serverId)
            if not success then
                task.wait(3)
                statusLabel.Text = "พร้อมลองใหม่"
                serverInfo.Text = "พร้อมใช้งาน"
            end
        end
        
        task.wait(2)
        isHopping = false
        hopButton.Text = "🚀 Hop ทันที"
        hopButton.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
    end)
end)

-- Loop หลักที่ตรวจสอบทุกอย่าง
task.spawn(function()
    while true do
        task.wait(playerCountCheckInterval) -- ตรวจสอบทุก 5 วินาที
        
        local currentPlayers = #Players:GetPlayers()
        
        -- อัพเดตข้อมูลเซิร์ฟเวอร์ พร้อมแสดงสถานะ
        if not isHopping then
            local statusText = "เซิร์ฟปัจจุบัน: " .. currentPlayers .. " คน"
            if currentPlayers >= 5 then
                statusText = statusText .. " 🔴 (เต็มแล้ว!)"
            elseif isWaitingToHop then
                statusText = statusText .. " 🔥 (กำลังนับเวลา)"
            end
            serverInfo.Text = statusText
            
            -- เปลี่ยนสีตามสถานะ
            if currentPlayers >= 5 then
                serverInfo.TextColor3 = Color3.fromRGB(255, 50, 50) -- แดงเข้ม (เต็ม)
            elseif isWaitingToHop then
                serverInfo.TextColor3 = Color3.fromRGB(255, 150, 0) -- ส้ม (กำลังนับเวลา)
            elseif currentPlayers > maxPlayersBeforeHop then
                serverInfo.TextColor3 = Color3.fromRGB(255, 100, 100) -- แดง
            elseif currentPlayers > maxPlayersBeforeHop - 2 then
                serverInfo.TextColor3 = Color3.fromRGB(255, 200, 0) -- เหลือง
            else
                serverInfo.TextColor3 = Color3.fromRGB(100, 255, 100) -- เขียว
            end
        end
        
        -- ตรวจสอบและเริ่มนับเวลา หรือ Hop ทันที
        checkPlayerCountAndStartTimer()
        
        -- ตรวจสอบว่าครบเวลาหรือยัง
        if isWaitingToHop and timeWhenExceeded then
            local timeElapsed = tick() - timeWhenExceeded
            local timeLeft = waitTimeBeforeHop - timeElapsed
            
            if timeLeft <= 0 then
                print("⏰ ครบเวลา " .. waitTimeBeforeHop .. " วินาทีแล้ว - เริ่ม Auto Hop")
                task.spawn(function()
                    executeAutoHop()
                end)
            else
                timerLabel.Text = "⏰ Hop ใน " .. math.ceil(timeLeft) .. " วินาที"
            end
        end
    end
end)

-- แสดงข้อมูลผู้เล่นเข้า-ออก
Players.PlayerAdded:Connect(function(newPlayer)
    local newCount = #Players:GetPlayers()
    print("➕ " .. newPlayer.Name .. " เข้าเกม (รวม " .. newCount .. " คน)")
    
    -- ตรวจสอบทันทีเมื่อมีคนเข้า - อาจ Hop ทันทีถ้าเต็ม!
    task.wait(0.5)
    if newCount >= 5 and isAutoHop and not isHopping then
        print("🚀 ตรวจพบเซิร์ฟเต็ม 5 คนจากคนเข้าใหม่!")
        task.spawn(function()
            checkPlayerCountAndStartTimer()
        end)
    else
        checkPlayerCountAndStartTimer()
    end
end)

Players.PlayerRemoving:Connect(function(leftPlayer)
    task.wait(0.1)
    local newCount = #Players:GetPlayers()
    print("➖ " .. leftPlayer.Name .. " ออกเกม (เหลือ " .. newCount .. " คน)")
end)

-- คำสั่งใน Chat
player.Chatted:Connect(function(message)
    local msg = message:lower()
    
    if msg == "/hop" then
        mainButton.MouseButton1Click:Fire()
        
    elseif msg == "/hopnow" then
        if not isHopping then
            hopButton.MouseButton1Click:Fire()
        end
        
    elseif msg == "/info" then
        local currentPlayers = #Players:GetPlayers()
        local waitStatus = ""
        if currentPlayers >= 5 then
            waitStatus = " (เต็มแล้ว!)"
        elseif isWaitingToHop then
            waitStatus = " (กำลังนับเวลา)"
        end
        
        pcall(function()
            StarterGui:SetCore("ChatMakeSystemMessage", {
                Text = "🌱 เซิร์ฟ: " .. currentPlayers .. " คน | Smart Hop: " .. (isAutoHop and "ON" or "OFF") .. waitStatus;
                Color = Color3.fromRGB(100, 200, 255);
            })
        end)
        
    elseif msg == "/cancel" then
        if isWaitingToHop then
            timeWhenExceeded = nil
            isWaitingToHop = false
            timerLabel.Text = ""
            pcall(function()
                StarterGui:SetCore("ChatMakeSystemMessage", {
                    Text = "⏹️ ยกเลิกการนับเวลาแล้ว";
                    Color = Color3.fromRGB(255, 200, 100);
                })
            end)
        end
        
    elseif msg == "/help" then
        pcall(function()
            StarterGui:SetCore("ChatMakeSystemMessage", {
                Text = "🧠 คำสั่ง: /hop /hopnow /info /cancel /help";
                Color = Color3.fromRGB(255, 200, 100);
            })
        end)
    end
end)

print("🧠 === Smart Auto Hop พร้อมใช้งาน ===")

-- แจ้งโหลดเสร็จ
task.wait(1)
pcall(function()
    StarterGui:SetCore("ChatMakeSystemMessage", {
        Text = "🧠 Smart Auto Hop พร้อม - เต็ม 5 คน = Hop ทันที!";
        Color = Color3.fromRGB(255, 215, 0);
    })
end)