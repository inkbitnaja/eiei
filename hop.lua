-- █████████████████████████████████████████████████████████████████
--  VENOZ Cluster Ultra-Tight LowPop Hopper (2–3 players)  — Delta Ready
--  • Leader/Follower (ลด 429 เมื่อเปิดหลายจอ)
--  • API pagination + backoff (Leader เท่านั้น)
--  • Blind Hop ต่อเนื่องข้ามเซิร์ฟด้วย TeleportData (ทุกจอ)
--  • Stability Patch: safe teleport + retry + min gap + backoff
--  • ULTRA mode: >3 หรือ <2 คน → Hop ทันที + Post-Join check
--  • Chat cmds: /go /auto /ultra /normal /leader /follower /info /stop /help
-- █████████████████████████████████████████████████████████████████

-- ===== Imports & Shortcuts =====
local Players          = game:GetService("Players")
local HttpService      = game:GetService("HttpService")
local TeleportService  = game:GetService("TeleportService")
local StarterGui       = game:GetService("StarterGui")

local player     = Players.LocalPlayer
local placeId    = game.PlaceId
local myJobId    = game.JobId

-- ======== CONFIG (ปรับได้) ========
-- กำหนดกอง 15 จอ: ให้ 1–2 จอเป็น Leader (API), ที่เหลือ Follower
local API_ENABLED        = false      -- Leader = true, Follower = false
local ULTRA_MODE         = true       -- โหมดตึงสุด
local AUTO_HOP           = true

-- เป้าหมายจำนวนคน
local MIN_PLAYERS        = 2
local MAX_PLAYERS        = 3

-- โหมดปกติ (เผื่อสลับ)
local TARGET_FULL        = 5
local WAIT_BEFORE_HOP    = 20

-- ควบคุมความถี่ (สำคัญเวลาหลายจอ)
local STARTUP_JITTER_MAX = 3.0        -- ดีเลย์สุ่มก่อนเริ่ม (กันชนพร้อมกัน)
local MIN_TELEPORT_GAP   = 3.8        -- เวลาขั้นต่ำระหว่างเทเลพอร์ต
local TELEPORT_MAX_TRIES = 6          -- เทเลพอร์ตซ้ำสูงสุด/ครั้ง
local BACKOFFS           = {2, 3, 4, 6, 8, 10}

-- กันวนกลับเซิร์ฟเดิมชั่วคราว
local REVISIT_TTL        = 120        -- วินาที

-- Blind Hop ต่อรอบ
local BLIND_MAX_ATTEMPTS = 40
local BLIND_COOLDOWN     = 3.5

-- API (Leader เท่านั้น)
local MAX_PAGES          = 10
local API_LIMIT          = 100
local API_BACKOFF_START  = 1.2
local API_BACKOFF_MAX    = 6
local API_JITTER         = 0.35
local PAGE_DELAY         = 0.2
-- ===================================

-- ====== Utils ======
local function sysmsg(txt, rgb)
    pcall(function()
        StarterGui:SetCore("ChatMakeSystemMessage", { Text = txt; Color = rgb or Color3.fromRGB(210,230,255) })
    end)
end

math.randomseed(os.time() + player.UserId)
task.wait(math.random() * STARTUP_JITTER_MAX)

sysmsg(("✅ VENOZ Cluster Hopper | Mode:%s | API:%s | Target %d–%d")
    :format(ULTRA_MODE and "ULTRA" or "NORMAL", API_ENABLED and "ON (Leader)" or "OFF (Follower)", MIN_PLAYERS, MAX_PLAYERS),
    Color3.fromRGB(120,255,120))

local visited = {}       -- jobId -> expireAt
local function pruneVisited()
    local t = os.time()
    for id, exp in pairs(visited) do
        if exp <= t then visited[id] = nil end
    end
end

-- ===== Stability Patch: safe teleport with gap + retries + backoff =====
local lastTeleportTick, lastInitFail = 0, false
pcall(function()
    TeleportService.TeleportInitFailed:Connect(function() lastInitFail = true end)
end)

local function gapReady()
    local d = tick() - lastTeleportTick
    if d < MIN_TELEPORT_GAP then task.wait(MIN_TELEPORT_GAP - d) end
    lastTeleportTick = tick()
end

local function safeTeleportInstance(jobId)
    for i=1,TELEPORT_MAX_TRIES do
        lastInitFail = false
        gapReady()
        local ok = pcall(function() TeleportService:TeleportToPlaceInstance(placeId, jobId, player) end)
        if ok and not lastInitFail then return true end
        task.wait(BACKOFFS[math.min(i,#BACKOFFS)])
    end
    return false
end

local function safeTeleportPlace(tpData)
    for i=1,TELEPORT_MAX_TRIES do
        lastInitFail = false
        gapReady()
        local ok = pcall(function() TeleportService:Teleport(placeId, player, tpData) end)
        if ok and not lastInitFail then return true end
        task.wait(BACKOFFS[math.min(i,#BACKOFFS)])
    end
    return false
end

-- ===== queue_on_teleport bootstrap =====
local qot = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)
if qot then
    -- ถ้ามี URL loader ของคุณเองให้แก้ตรงนี้; ถ้าไม่มีก็ปล่อยไว้เฉย ๆ
    local LOADER_URL = nil -- เช่น "https://raw.githubusercontent.com/venozeiei/yourrepo/main/lowhop.lua"
    if LOADER_URL then
        qot(([[
            local ok,err = pcall(function()
                loadstring(game:HttpGet(%q))()
            end)
            if not ok then warn("QueueOnTeleport loader error:", err) end
        ]]):format(LOADER_URL))
    end
end

-- ===== API (Leader) =====
local function fetchPage(cursor, backoff)
    local base = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=%d"):format(placeId, API_LIMIT)
    local url  = cursor and (base .. "&cursor=" .. HttpService:UrlEncode(cursor)) or base

    local ok, resp = pcall(function() return game:HttpGet(url, true) end)
    if not ok or not resp or resp == "" then
        task.wait(math.min(backoff, API_BACKOFF_MAX) + math.random()*API_JITTER)
        return nil, backoff * 1.6
    end
    local ok2, data = pcall(function() return HttpService:JSONDecode(resp) end)
    if not ok2 or not data or not data.data then
        task.wait(math.min(backoff, API_BACKOFF_MAX) + math.random()*API_JITTER)
        return nil, backoff * 1.6
    end
    return data, API_BACKOFF_START
end

local function findLowPlayersViaAPI()
    if not API_ENABLED then return nil end
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
            local id      = srv.id
            local playing = tonumber(srv.playing) or 0
            if id ~= myJobId and playing >= MIN_PLAYERS and playing <= MAX_PLAYERS and not visited[id] then
                if (not best) or (playing < best.playing) then
                    best = { id = id, playing = playing }
                end
            end
        end
        if best then return best.id end
        cursor = data.nextPageCursor
        if not cursor then break end
        task.wait(PAGE_DELAY + math.random()*API_JITTER)
    end
    return nil
end

-- ===== Blind Hop (ทุกจอใช้; ใช้หนักใน Follower) =====
local function blindHopUntilMatched()
    sysmsg(API_ENABLED and "🎲 API ไม่เจอ → Blind Hop" or "🎲 Blind Hop (Follower)", Color3.fromRGB(255,215,120))
    safeTeleportPlace({
        mode       = "acquire_lowpop",
        attempts   = 0,
        maxAttempts= BLIND_MAX_ATTEMPTS,
        minP       = MIN_PLAYERS,
        maxP       = MAX_PLAYERS,
    })
end

-- ===== สานต่อ TeleportData หลังเข้าเซิร์ฟใหม่ =====
task.defer(function()
    local join = player:GetJoinData()
    local td = join and join.TeleportData
    if td and td.mode == "acquire_lowpop" then
        local attempts = tonumber(td.attempts) or 0
        local maxA     = tonumber(td.maxAttempts) or BLIND_MAX_ATTEMPTS
        local minP     = tonumber(td.minP) or MIN_PLAYERS
        local maxP     = tonumber(td.maxP) or MAX_PLAYERS
        local settle   = ULTRA_MODE and 1.5 or 3.0

        task.delay(settle, function()
            local cnt = #Players:GetPlayers()
            if cnt >= minP and cnt <= maxP then
                sysmsg(("✅ พบเซิร์ฟ %d คน — หยุดค้น"):format(cnt), Color3.fromRGB(0,255,120))
                return
            end
            if attempts >= maxA then
                sysmsg("⚠️ ถึงเพดาน Blind Hop แล้ว หยุดก่อน", Color3.fromRGB(255,200,120)); return
            end
            task.wait(BLIND_COOLDOWN)
            safeTeleportPlace({
                mode="acquire_lowpop",
                attempts=attempts+1, maxAttempts=maxA,
                minP=minP, maxP=maxP
            })
        end)
    else
        if ULTRA_MODE then
            task.delay(1.5, function()
                local c = #Players:GetPlayers()
                if c > MAX_PLAYERS or c < MIN_PLAYERS then
                    safeTeleportPlace({
                        mode="acquire_lowpop",
                        attempts=0, maxAttempts=BLIND_MAX_ATTEMPTS,
                        minP=MIN_PLAYERS, maxP=MAX_PLAYERS
                    })
                end
            end)
        end
    end
end)

-- ===== Hop หลัก =====
local isHopping, timeWhenFull = false, nil
local function doHop()
    if isHopping then return end
    isHopping = true
    sysmsg("⏩ กำลังหาเซิร์ฟ 2–3 คน...", Color3.fromRGB(255,215,120))

    local target = findLowPlayersViaAPI()
    if target then
        visited[target] = os.time() + REVISIT_TTL
        if safeTeleportInstance(target) then return end
    end
    blindHopUntilMatched()
    isHopping = false
end

-- ===== Loop คุมโหมด =====
task.spawn(function()
    while true do
        task.wait(ULTRA_MODE and 3 or 5)
        if not AUTO_HOP or isHopping then continue end

        local c = #Players:GetPlayers()
        if ULTRA_MODE then
            if c > MAX_PLAYERS or c < MIN_PLAYERS then
                doHop()
            end
        else
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
    end
end)

-- ===== Logs เล็กน้อย =====
Players.PlayerAdded:Connect(function(plr)
    print(("➕ %s เข้ามา (รวม %d)"):format(plr.Name, #Players:GetPlayers()))
end)
Players.PlayerRemoving:Connect(function(plr)
    task.wait(0.35)
    print(("➖ %s ออก (เหลือ %d)"):format(plr.Name, #Players:GetPlayers()))
end)

-- ===== Chat Commands =====
player.Chatted:Connect(function(msg)
    msg = msg:lower()
    if msg == "/go" then
        doHop()
    elseif msg == "/auto" then
        AUTO_HOP = not AUTO_HOP; timeWhenFull = nil
        sysmsg(AUTO_HOP and "✅ Auto: ON" or "❌ Auto: OFF",
            AUTO_HOP and Color3.fromRGB(0,255,120) or Color3.fromRGB(255,120,120))
    elseif msg == "/ultra" then
        ULTRA_MODE = true; timeWhenFull = nil
        sysmsg("💥 Ultra Mode: ON", Color3.fromRGB(0,255,160))
    elseif msg == "/normal" then
        ULTRA_MODE = false
        sysmsg("🧩 Normal Mode: ON", Color3.fromRGB(120,200,255))
    elseif msg == "/leader" then
        API_ENABLED = true
        sysmsg("👑 This instance: LEADER (API ON)", Color3.fromRGB(255,230,120))
    elseif msg == "/follower" then
        API_ENABLED = false
        sysmsg("👣 This instance: FOLLOWER (API OFF)", Color3.fromRGB(180,220,255))
    elseif msg == "/info" then
        local c = #Players:GetPlayers()
        sysmsg(("ℹ️ %d คน | Mode:%s | API:%s | Auto:%s"):format(
            c, ULTRA_MODE and "ULTRA" or "NORMAL", API_ENABLED and "ON" or "OFF", AUTO_HOP and "ON" or "OFF"))
    elseif msg == "/stop" then
        AUTO_HOP, isHopping, timeWhenFull = false, false, nil
        sysmsg("⛔ หยุดระบบแล้ว", Color3.fromRGB(255,180,120))
    elseif msg == "/help" then
        sysmsg("คำสั่ง: /go /auto /ultra /normal /leader /follower /info /stop /help")
    end
end)

-- ===== Ready =====
task.delay(1, function()
    sysmsg("✅ พร้อมใช้งาน — ตั้ง Leader 1–2 จอ, ที่เหลือ Follower", Color3.fromRGB(120,255,120))
end)
