-- 🚀 Simple Auto Hop - เรียบง่าย ไม่ซับซ้อน
-- แค่ Hop หาเซิร์ฟคนน้อย เมื่อครบ 5 คน

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local currentJobId = game.JobId
local placeId = game.PlaceId

-- ตัวแปรง่ายๆ
local autoHop = true
local isHopping = false
local waitTime = 20 -- รอ 20 วินาที
local timeWhenFull = nil

print("🚀 === Simple Auto Hop ===")
print("⚙️ ครบ 5 คน = รอ 20 วิ แล้ว Hop หาเซิร์ฟคนน้อย")

-- แจ้งเตือน
pcall(function()
    StarterGui:SetCore("ChatMakeSystemMessage", {
        Text = "🚀 Simple Auto Hop เริ่มทำงาน!";
        Color = Color3.fromRGB(100, 255, 100);
    })
end)

-- ฟังก์ชันหาเซิร์ฟคนน้อย (แก้ API)
local function findLowPlayerServer()
    print("🔍 กำลังหาเซิร์ฟคนน้อย...")
    
    -- ลองหลาย API URL
    local apiUrls = {
        "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=50",
        "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Desc&limit=30",
        "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?limit=25"
    }
    
    for i, url in ipairs(apiUrls) do
        print("📡 ลอง API วิธีที่", i, "...")
        
        local success, response = pcall(function()
            return game:HttpGet(url, true) -- เพิ่ม true สำหรับบาง Executor
        end)
        
        if success and response then
            local parseSuccess, data = pcall(function()
                return HttpService:JSONDecode(response)
            end)
            
            if parseSuccess and data and data.data then
                print("✅ API วิธีที่", i, "ได้ผล - เจอ", #data.data, "เซิร์ฟ")
                
                local goodServers = {}
                
                for _, server in pairs(data.data) do
                    if server.id ~= currentJobId and 
                       server.playing and server.maxPlayers and
                       server.playing >= 1 and server.playing <= 3 and
                       server.maxPlayers == 5 then
                        
                        table.insert(goodServers, {
                            id = server.id,
                            players = server.playing,
                            ping = server.ping or 999
                        })
                        
                        print("✅ เจอเซิร์ฟ:", server.playing, "คน")
                    end
                end
                
                if #goodServers > 0 then
                    -- เรียงจากคนน้อยสุด
                    table.sort(goodServers, function(a, b)
                        if a.players == b.players then
                            return a.ping < b.ping
                        end
                        return a.players < b.players
                    end)
                    
                    local bestServer = goodServers[1]
                    print("🎯 เลือกเซิร์ฟ:", bestServer.players, "คน, Ping:", bestServer.ping, "ms")
                    
                    return bestServer.id
                else
                    print("❌ API วิธีที่", i, "ไม่เจอเซิร์ฟที่เหมาะสม")
                end
            else
                print("❌ API วิธีที่", i, "ข้อมูลไม่ถูกต้อง")
            end
        else
            print("❌ API วิธีที่", i, "เชื่อมต่อไม่ได้:", response or "ไม่มีข้อมูล")
        end
        
        task.wait(1) -- รอระหว่างลอง API
    end
    
    print("❌ ทุก API ไม่ได้ผล - จะ Random Teleport")
    return nil
end

-- ฟังก์ชัน Hop (ปรับปรุง)
local function doHop()
    if isHopping then
        print("⚠️ กำลัง Hop อยู่")
        return
    end
    
    isHopping = true
    print("🚀 เริ่ม Hop...")
    
    pcall(function()
        StarterGui:SetCore("ChatMakeSystemMessage", {
            Text = "🚀 กำลัง Hop หาเซิร์ฟคนน้อย...";
            Color = Color3.fromRGB(255, 200, 0);
        })
    end)
    
    -- หาเซิร์ฟคนน้อยก่อน
    local serverId = findLowPlayerServer()
    
    if serverId then
        -- ลองหลายวิธี Teleport
        local teleportMethods = {
            function()
                print("📡 ลอง TeleportToPlaceInstance...")
                TeleportService:TeleportToPlaceInstance(placeId, serverId, player)
                return true
            end,
            function()
                print("📡 ลอง Teleport ธรรมดา...")
                TeleportService:Teleport(placeId, player)
                return true
            end
        }
        
        for i, method in ipairs(teleportMethods) do
            local success = pcall(method)
            if success then
                print("✅ Teleport วิธีที่", i, "สำเร็จ")
                
                pcall(function()
                    StarterGui:SetCore("ChatMakeSystemMessage", {
                        Text = "✅ Hop สำเร็จ - ไปเซิร์ฟคนน้อยแล้ว!";
                        Color = Color3.fromRGB(0, 255, 100);
                    })
                end)
                
                return
            else
                print("❌ Teleport วิธีที่", i, "ล้มเหลว")
                task.wait(1)
            end
        end
    end
    
    -- ถ้าทุกอย่างไม่ได้ ลอง Random Teleport
    print("🎲 ลอง Random Teleport สุดท้าย...")
    local success = pcall(function()
        TeleportService:Teleport(placeId, player)
    end)
    
    if success then
        print("✅ Random Teleport สำเร็จ")
        
        pcall(function()
            StarterGui:SetCore("ChatMakeSystemMessage", {
                Text = "✅ Random Hop สำเร็จ!";
                Color = Color3.fromRGB(0, 255, 100);
            })
        end)
    else
        print("❌ Hop ล้มเหลวทุกวิธี")
        
        pcall(function()
            StarterGui:SetCore("ChatMakeSystemMessage", {
                Text = "❌ Hop ล้มเหลว - ลองใหม่ใน 30 วิ";
                Color = Color3.fromRGB(255, 100, 100);
            })
        end)
        
        task.wait(30) -- รอ 30 วินาทีก่อนรีเซ็ต
        isHopping = false
    end
end

-- Loop หลัก
task.spawn(function()
    while true do
        task.wait(5) -- ตรวจสอบทุก 5 วินาที
        
        local currentPlayers = #Players:GetPlayers()
        
        if autoHop and not isHopping then
            if currentPlayers >= 5 then
                -- เริ่มนับเวลาถ้ายังไม่เริ่ม
                if not timeWhenFull then
                    timeWhenFull = tick()
                    print("⏰ เซิร์ฟครบ 5 คน - เริ่มนับเวลา 20 วินาที")
                    
                    pcall(function()
                        StarterGui:SetCore("ChatMakeSystemMessage", {
                            Text = "⏰ เซิร์ฟครบ 5 คน - รอ 20 วินาที แล้ว Hop!";
                            Color = Color3.fromRGB(255, 200, 0);
                        })
                    end)
                else
                    -- ตรวจสอบว่าครบเวลาหรือยัง
                    local elapsed = tick() - timeWhenFull
                    local timeLeft = waitTime - elapsed
                    
                    if timeLeft <= 0 then
                        print("🚀 ครบ 20 วินาทีแล้ว - เริ่ม Hop!")
                        doHop()
                        timeWhenFull = nil -- รีเซ็ต
                    else
                        print("⏳ รอ Hop อีก", math.ceil(timeLeft), "วินาที")
                    end
                end
            else
                -- ถ้าคนลดลงจาก 5 รีเซ็ตเวลา (ถ้าต้องการ)
                if timeWhenFull then
                    timeWhenFull = nil
                    print("✅ คนลดลงแล้ว - ยกเลิกการนับเวลา")
                end
            end
        end
    end
end)

-- แสดงข้อมูลผู้เล่น
Players.PlayerAdded:Connect(function(newPlayer)
    local newCount = #Players:GetPlayers()
    print("➕ " .. newPlayer.Name .. " เข้าเกม (รวม " .. newCount .. " คน)")
    
    if newCount == 5 and autoHop then
        pcall(function()
            StarterGui:SetCore("ChatMakeSystemMessage", {
                Text = "⚠️ เซิร์ฟครบ 5 คนแล้ว!";
                Color = Color3.fromRGB(255, 150, 0);
            })
        end)
    end
end)

Players.PlayerRemoving:Connect(function(leftPlayer)
    task.wait(0.5)
    local newCount = #Players:GetPlayers()
    print("➖ " .. leftPlayer.Name .. " ออกเกม (เหลือ " .. newCount .. " คน)")
end)

-- คำสั่งง่ายๆ
player.Chatted:Connect(function(message)
    local msg = message:lower()
    
    if msg == "/hop" then
        doHop()
        
    elseif msg == "/auto" then
        autoHop = not autoHop
        print(autoHop and "✅ Auto Hop เปิด" or "❌ Auto Hop ปิด")
        
        pcall(function()
            StarterGui:SetCore("ChatMakeSystemMessage", {
                Text = autoHop and "✅ Auto Hop เปิด" or "❌ Auto Hop ปิด";
                Color = autoHop and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 100, 100);
            })
        end)
        
        if not autoHop then
            timeWhenFull = nil
        end
        
    elseif msg == "/info" then
        local currentPlayers = #Players:GetPlayers()
        local status = autoHop and "ON" or "OFF"
        local waitStatus = timeWhenFull and " (กำลังนับเวลา)" or ""
        
        pcall(function()
            StarterGui:SetCore("ChatMakeSystemMessage", {
                Text = "🚀 เซิร์ฟ: " .. currentPlayers .. "/5 คน | Auto: " .. status .. waitStatus;
                Color = Color3.fromRGB(100, 200, 255);
            })
        end)
        
    elseif msg == "/stop" then
        timeWhenFull = nil
        isHopping = false
        print("⏹️ หยุดการทำงานทั้งหมด")
        
        pcall(function()
            StarterGui:SetCore("ChatMakeSystemMessage", {
                Text = "⏹️ หยุดการทำงานแล้ว";
                Color = Color3.fromRGB(255, 200, 100);
            })
        end)
        
    elseif msg == "/help" then
        pcall(function()
            StarterGui:SetCore("ChatMakeSystemMessage", {
                Text = "🚀 คำสั่ง: /hop /auto /info /stop /help";
                Color = Color3.fromRGB(150, 200, 255);
            })
        end)
    end
end)

print("🚀 === Simple Auto Hop พร้อมใช้งาน ===")
print("💬 คำสั่ง: /hop /auto /info /stop /help")
print("⚙️ Auto Hop:", autoHop and "ON" or "OFF")

-- แจ้งโหลดเสร็จ
task.wait(1)
pcall(function()
    StarterGui:SetCore("ChatMakeSystemMessage", {
        Text = "🚀 Simple Auto Hop พร้อม - พิมพ์ /help ดูคำสั่ง!";
        Color = Color3.fromRGB(100, 255, 100);
    })
end)
