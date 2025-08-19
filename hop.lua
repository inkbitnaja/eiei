-- 🚀 Precise Low-Player Join (2–3 players) | API + Blind Hop Fallback
-- คุณสมบัติ:
-- 1) ค้นหาเซิร์ฟ 2–3 คนด้วย API (มี pagination + backoff กัน 429)
-- 2) ถ้า API ล้มเหลว: โหมด Blind Hop สุ่มเทเลฯ ต่อเนื่องจนเจอ 2–3 คน (พกสถานะด้วย TeleportData)
-- 3) กันวนกลับเซิร์ฟเดิมช่วงสั้น ๆ, จำกัดความถี่, คำสั่งควบคุมพร้อมใช้

local Players          = game:GetService("Players")
local HttpService      = game:GetService("HttpService")
local TeleportService  = game:GetService("TeleportService")
local StarterGui       = game:GetService("StarterGui")

local player     = Players.LocalPlayer
local placeId    = game.PlaceId
local myJobId    = game.JobId

-- ===== ปรับค่าได้ =====
local AUTO_HOP            = true      -- ครบ 5 คน -> เริ่มจับเวลา -> หาเซิร์ฟ 2–3
local TARGET_FULL         = 5
local WAIT_BEFORE_HOP     = 200        -- วินาที

local MIN_PLAYERS         = 2         -- เป้าหมายต่ำสุด
local MAX_PLAYERS         = 3         -- เป้าหมายสูงสุด

-- API Search
local MAX_PAGES           = 12        -- ไล่หน้าไม่เกินเท่านี้
local API_LIMIT           = 100       -- limit ต่อหน้า (Roblox API รองรับ 10/25/50/100)
local API_BACKOFF_START   = 1.2       -- หน่วงเริ่มต้นเมื่อโดน 429/ล้มเหลว
local API_BACKOFF_MAX     = 6         -- หน่วงสูงสุด
local API_JITTER          = 0.35      -- สุ่มขยับเวลาเล็กน้อย ลดโอกาสชน 429
local PAGE_DELAY          = 0.25      -- เวลาหน่วงระหว่างหน้า

-- Blind Hop (สุ่มจนเจอ)
local BLIND_MAX_ATTEMPTS  = 28        -- เทเลพอร์ตสุ่มสูงสุดกี่ครั้งต่อรอบ
local BLIND_COOLDOWN      = 5.5       -- หน่วงระหว่างแต่ละรอบสุ่ม (กันสแปม)
local REVISIT_TTL         = 120       -- ระยะเวลาจำเซิร์ฟเดิม (วินาที)
-- =======================

local isHopping     = false
local timeWhenFull  = nil

-- บันทึก jobId ที่เพิ่งไปมา: {id -> expireAt}
local visited = {}

local function now() return os.time() end

local function sysmsg(txt, rgb)
    pcall(function()
        StarterGui:SetCore("ChatMakeSystemMessage", {
            Text = txt;
            Color = rgb or Color3.fromRGB(200, 220, 255);
        })
    end)
end

local function pruneVisited()
    local t = now()
    for id, exp in pairs(visited) do
        if exp <= t then visited[id] = nil end
    end
end

print(("🚀 Precise Low-Player Join | เป้าหมาย %d–%d คน"):format(MIN_PLAYERS, MAX_PLAYERS))
sysmsg("✅ เริ่มทำงาน (พิมพ์ /help เพื่อดูคำสั่ง)", Color3.fromRGB(120,255,120))

-- ===== อ่าน TeleportData เพื่อสานต่อ Blind Hop เมื่อโหลดเข้ามาเซิร์ฟใหม่ =====
task.defer(function()
    local join = player:GetJoinData()
    local td = join and join.TeleportData
    if td and td.mode == "acquire_lowpop" then
        local attempts = tonumber(td.attempts) or 0
        local maxA     = tonumber(td.maxAttempts) or BLIND_MAX_ATTEMPTS
        local minP     = tonumber(td.minP) or MIN_PLAYERS
        local maxP     = tonumber(td.maxP) or MAX_PLAYERS

        task.delay(0.5, function()
            local cnt = #Players:GetPlayers()
            if cnt >= minP and cnt <= maxP then
                sysmsg(("✅ พบเซิร์ฟ %d คน — หยุดไล่หา"):format(cnt), Color3.fromRGB(0,255,120))
                return
            end
            if attempts >= maxA then
                sysmsg("⚠️ เกินจำนวนครั้งที่กำหนด หยุด Blind Hop", Color3.fromRGB(255,200,120))
                return
            end
            sysmsg(("🔁 Blind Hop ต่อ (รอบ %d/%d) — คนปัจจุบัน %d"):format(attempts+1, maxA, cnt), Color3.fromRGB(255,215,120))
            task.wait(BLIND_COOLDOWN)
            local data = {
                mode = "acquire_lowpop",
                attempts = attempts + 1,
                maxAttempts = maxA,
                minP = minP, maxP = maxP,
            }
            TeleportService:Teleport(placeId, player, data)
        end)
    end
end)

-- ===== ดึงหน้าจาก API พร้อม backoff กัน 429 =====
local function fetchPage(cursor, backoff)
    local base = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=%d"):format(placeId, API_LIMIT)
    local url = cursor and (base .. "&cursor=" .. HttpService:UrlEncode(cursor)) or base

    local ok, resp = pcall(function()
        return game:HttpGet(url, true)
    end)

    if not ok or not resp or resp == "" then
        task.wait(math.min(backoff, API_BACKOFF_MAX) + math.random() * API_JITTER)
        return nil, backoff * 1.6
    end

    local ok2, data = pcall(function() return HttpService:JSONDecode(resp) end)
    if not ok2 or not data or not data.data then
        task.wait(math.min(backoff, API_BACKOFF_MAX) + math.random() * API_JITTER)
        return nil, backoff * 1.6
    end
    return data, API_BACKOFF_START
end

-- ===== หาเซิร์ฟ 2–3 คนด้วย API (pagination) =====
local function findLowPlayersViaAPI()
    pruneVisited()
    local cursor, pages, backoff = nil, 0, API_BACKOFF_START
    local best = nil

    while pages < MAX_PAGES do
        pages += 1
        local data; data, backoff = fetchPage(cursor, backoff)
        if not data then
            if pages >= MAX_PAGES then break end
            task.wait(PAGE_DELAY)
            continue
        end

        for _, srv in ipairs(data.data) do
            local id        = srv.id
            local playing   = tonumber(srv.playing) or 0
            if  id ~= myJobId
            and playing >= MIN_PLAYERS and playing <= MAX_PLAYERS
            and not visited[id] then
                if (not best) or (playing < best.playing) then
                    best = {id = id, playing = playing}
                end
            end
        end

        if best then
            return best.id
        end

        cursor = data.nextPageCursor
        if not cursor then break end
        task.wait(PAGE_DELAY + math.random() * API_JITTER)
    end
    return nil
end

-- ===== Blind Hop: สุ่มจนกว่าจะเจอ 2–3 คน (พกสถานะด้วย TeleportData) =====
local function blindHopUntilMatched()
    local data = {
        mode = "acquire_lowpop",
        attempts = 0,
        maxAttempts = BLIND_MAX_ATTEMPTS,
        minP = MIN_PLAYERS, maxP = MAX_PLAYERS,
    }
    sysmsg("🎲 เข้าสู่โหมด Blind Hop จนกว่าจะเจอ 2–3 คน", Color3.fromRGB(255,215,120))
    TeleportService:Teleport(placeId, player, data)
end

-- ===== ทำการ Hop =====
local function doHop()
    if isHopping then return end
    isHopping = true
    sysmsg("⏩ กำลังหาเซิร์ฟ 2–3 คน...", Color3.fromRGB(255,215,120))

    -- 1) ลองหาผ่าน API ก่อน
    local target = findLowPlayersViaAPI()
    if target then
        visited[target] = now() + REVISIT_TTL
        local ok = pcall(function()
            TeleportService:TeleportToPlaceInstance(placeId, target, player)
        end)
        if ok then return end
        -- ถ้าล้มเหลว -> ไปแผน 2
    else
        print("API หาไม่เจอ/ถูกบล็อก -> ใช้ Blind Hop")
    end

    -- 2) Blind Hop จนกว่าจะเจอ
    blindHopUntilMatched()
    isHopping = false
end

-- ===== Loop หลัก: ครบ 5 คน -> รอ 20 วิ -> Hop =====
task.spawn(function()
    while true do
        task.wait(5)
        if not AUTO_HOP or isHopping then continue end

        local c = #Players:GetPlayers()
        if c >= TARGET_FULL then
            if not timeWhenFull then
                timeWhenFull = tick()
                sysmsg(("⏰ ครบ %d คน — จะ Hop ใน %d วิ"):format(TARGET_FULL, WAIT_BEFORE_HOP), Color3.fromRGB(255,200,120))
            else
                local left = WAIT_BEFORE_HOP - (tick() - timeWhenFull)
                if left <= 0 then
                    timeWhenFull = nil
                    doHop()
                end
            end
        else
            timeWhenFull = nil
        end
    end
end)

-- ===== Log เข้า/ออก =====
Players.PlayerAdded:Connect(function(plr)
    print(("➕ %s เข้ามา (รวม %d)"):format(plr.Name, #Players:GetPlayers()))
end)
Players.PlayerRemoving:Connect(function(plr)
    task.wait(0.4)
    print(("➖ %s ออก (เหลือ %d)"):format(plr.Name, #Players:GetPlayers()))
end)

-- ===== คำสั่ง =====
player.Chatted:Connect(function(msg)
    msg = msg:lower()
    if msg == "/go" then
        doHop()
    elseif msg == "/auto" then
        AUTO_HOP = not AUTO_HOP
        timeWhenFull = nil
        sysmsg(AUTO_HOP and "✅ Auto: ON" or "❌ Auto: OFF",
            AUTO_HOP and Color3.fromRGB(0,255,120) or Color3.fromRGB(255,120,120))
    elseif msg == "/info" then
        local c = #Players:GetPlayers()
        sysmsg(("ℹ️ Players: %d | Target %d | Auto:%s"):format(c, TARGET_FULL, AUTO_HOP and "ON" or "OFF"))
    elseif msg == "/stop" then
        AUTO_HOP, isHopping, timeWhenFull = false, false, nil
        sysmsg("⏹️ หยุดการทำงานแล้ว", Color3.fromRGB(255,200,120))
    elseif msg == "/help" then
        sysmsg("คำสั่ง: /go /auto /info /stop /help")
    end
end)

-- ===== แจ้งพร้อม =====
task.delay(1, function()
    sysmsg("✅ พร้อมใช้งาน (เป้าหมาย 2–3 คน)", Color3.fromRGB(120,255,120))
end)
