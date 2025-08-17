-- 🚀 Simple Auto Hop (Paginated + Retry + Debounce)
-- เงื่อนไข: เมื่อคน >= TARGET_FULL จะเริ่มนับถอยหลัง WAIT_BEFORE_HOP วินาทีแล้ว Hop
-- จากนั้นจะหาเซิร์ฟที่มีผู้เล่นระหว่าง MIN_PLAYERS..MAX_PLAYERS (ไม่ซ้ำเซิร์ฟเดิม)

local Players          = game:GetService("Players")
local HttpService      = game:GetService("HttpService")
local TeleportService  = game:GetService("TeleportService")
local StarterGui       = game:GetService("StarterGui")

local player      = Players.LocalPlayer
local placeId     = game.PlaceId
local currentJob  = game.JobId

-- ===== ปรับค่าตรงนี้ได้ =====
local AUTO_HOP          = true
local TARGET_FULL       = 5            -- ครบกี่คนถึงจะเริ่มจับเวลา
local WAIT_BEFORE_HOP   = 20           -- รอเวลาก่อน hop (วินาที)
local MIN_PLAYERS       = 1            -- เซิร์ฟขั้นต่ำ
local MAX_PLAYERS       = 3            -- เซิร์ฟสูงสุดที่ต้องการ
local PAGE_LIMIT        = 15           -- ไล่หาได้สูงสุดกี่หน้า (กันลูปยาว)
local RETRY_PER_PAGE    = 3            -- รีทรายต่อหนึ่งหน้า
local RETRY_DELAY       = 1.5          -- หน่วงระหว่างรีทราย
local SCAN_INTERVAL     = 5            -- วนตรวจทุกกี่วินาที
-- ============================

local isHopping     = false
local timeWhenFull  = nil
local visited       = {}               -- จำ jobId ที่เพิ่งเข้า/เจอ

-- helper: system message
local function sysmsg(txt, rgb)
    pcall(function()
        StarterGui:SetCore("ChatMakeSystemMessage", {
            Text = txt;
            Color = rgb or Color3.fromRGB(200, 200, 255);
        })
    end)
end

print("🚀 Simple Auto Hop | >= "..TARGET_FULL.." คน -> รอ "..WAIT_BEFORE_HOP.." วิ -> Hop")
sysmsg("🚀 Simple Auto Hop เริ่มทำงาน", Color3.fromRGB(120,255,120))

-- ========== ดึงรายการเซิร์ฟ (มี pagination) ==========
local function fetchServers(cursor)
    local base = "https://games.roblox.com/v1/games/"..placeId.."/servers/Public?sortOrder=Asc&limit=100"
    local url = cursor and (base.."&cursor="..HttpService:UrlEncode(cursor)) or base

    -- พยายามหลายรอบต่อหน้า
    for attempt = 1, RETRY_PER_PAGE do
        local ok, resp = pcall(function()
            return game:HttpGet(url, true)
        end)
        if ok and resp then
            local ok2, data = pcall(function()
                return HttpService:JSONDecode(resp)
            end)
            if ok2 and data and data.data then
                return data
            end
        end
        task.wait(RETRY_DELAY)
    end
    return nil
end

-- ========== คัดเซิร์ฟคนน้อยจากหลายหน้า ==========
local function findLowPlayerServer()
    print("🔍 เริ่มหาเซิร์ฟคนน้อย (", MIN_PLAYERS, "-", MAX_PLAYERS, "คน )")
    local cursor, pages = nil, 0
    local best = nil

    while pages < PAGE_LIMIT do
        pages += 1
        local data = fetchServers(cursor)
        if not data then
            print(("❌ หน้า %d ดึงข้อมูลไม่สำเร็จ"):format(pages))
            if pages >= PAGE_LIMIT then break end
            cursor = data and data.nextPageCursor or cursor
            continue
        end

        -- ไล่เช็คทุกเซิร์ฟในหน้านี้
        for _, srv in ipairs(data.data) do
            local id        = srv.id
            local playing   = tonumber(srv.playing) or 0
            local maxPlr    = tonumber(srv.maxPlayers) or 0

            -- เงื่อนไข: ไม่ใช่เซิร์ฟเราเอง, จำนวนคนตามช่วง, และยังไม่เคยเข้า/ทำเครื่องหมายไว้
            if id ~= currentJob
               and playing >= MIN_PLAYERS and playing <= MAX_PLAYERS
               and not visited[id] then

                -- เลือกตัวที่ "คนน้อยที่สุด" เป็นอันดับแรก
                if (not best) or (playing < best.playing) then
                    best = { id = id, playing = playing, maxPlayers = maxPlr }
                end
            end
        end

        -- ถ้าเจอแล้ว ก็พอได้
        if best then
            print(("🎯 เจอแล้ว: %d/%d คน (page %d)"):format(best.playing, best.maxPlayers, pages))
            return best.id
        end

        -- เตรียมไปหน้าถัดไป (ถ้ามี)
        cursor = data.nextPageCursor
        if not cursor then break end
        task.wait(0.25)
    end

    print("❌ หาไม่เจอใน ", pages, " หน้า")
    return nil
end

-- ========== ทำการ Hop ==========
local function doHop()
    if isHopping then
        print("⚠️ กำลัง Hop อยู่")
        return
    end
    isHopping = true
    sysmsg("⏩ กำลัง Hop หาเซิร์ฟคนน้อย...", Color3.fromRGB(255,215,120))

    local target = findLowPlayerServer()
    if target then
        visited[target] = true -- กันวนกลับ
        print("➡️ TeleportToPlaceInstance ->", target)
        local ok = pcall(function()
            TeleportService:TeleportToPlaceInstance(placeId, target, player)
        end)
        if ok then return end
        print("❌ TeleportToPlaceInstance ล้มเหลว ลองแบบปกติ")
    end

    -- Fallback: Random ไปก่อน
    local ok2 = pcall(function()
        TeleportService:Teleport(placeId, player)
    end)
    if not ok2 then
        sysmsg("❌ Hop ล้มเหลวทั้งหมด จะลองใหม่ใน 30 วิ", Color3.fromRGB(255,120,120))
        task.wait(30)
    end
    isHopping = false
end

-- ========== วงวนหลัก ==========
task.spawn(function()
    while true do
        task.wait(SCAN_INTERVAL)
        if not AUTO_HOP or isHopping then continue end

        local cnt = #Players:GetPlayers()
        if cnt >= TARGET_FULL then
            if not timeWhenFull then
                timeWhenFull = tick()
                sysmsg(("⏰ ครบ %d คน - จะ Hop ใน %d วิ"):format(TARGET_FULL, WAIT_BEFORE_HOP), Color3.fromRGB(255,200,120))
            else
                local left = math.max(0, WAIT_BEFORE_HOP - (tick() - timeWhenFull))
                print("⏳ รอ Hop อีก", math.ceil(left), "วิ")
                if left <= 0 then
                    timeWhenFull = nil
                    doHop()
                end
            end
        else
            -- คนลดลง รีเซ็ตการจับเวลา
            if timeWhenFull then
                timeWhenFull = nil
                print("✅ คนลดลงต่ำกว่าเป้าหมาย ยกเลิกการนับเวลา")
            end
        end
    end
end)

-- ========== บันทึก log เข้า/ออก ==========
Players.PlayerAdded:Connect(function(plr)
    print(("➕ %s เข้ามา (รวม %d คน)"):format(plr.Name, #Players:GetPlayers()))
end)
Players.PlayerRemoving:Connect(function(plr)
    task.wait(0.5)
    print(("➖ %s ออก (เหลือ %d คน)"):format(plr.Name, #Players:GetPlayers()))
end)

-- ========== คำสั่งแชท ==========
player.Chatted:Connect(function(msg)
    msg = msg:lower()
    if msg == "/hop" then
        doHop()
    elseif msg == "/auto" then
        AUTO_HOP = not AUTO_HOP
        timeWhenFull = nil
        sysmsg(AUTO_HOP and "✅ Auto Hop: ON" or "❌ Auto Hop: OFF",
            AUTO_HOP and Color3.fromRGB(0,255,120) or Color3.fromRGB(255,120,120))
    elseif msg == "/info" then
        local cnt = #Players:GetPlayers()
        sysmsg(("ℹ️ Players: %d | Target:%d | Auto:%s"):format(cnt, TARGET_FULL, AUTO_HOP and "ON" or "OFF"))
    elseif msg == "/stop" then
        AUTO_HOP = false
        isHopping, timeWhenFull = false, nil
        sysmsg("⏹️ หยุดการทำงานแล้ว", Color3.fromRGB(255,200,120))
    elseif msg == "/help" then
        sysmsg("คำสั่ง: /hop /auto /info /stop /help")
    end
end)

sysmsg("✅ Simple Auto Hop พร้อมใช้งาน (พิมพ์ /help)")
