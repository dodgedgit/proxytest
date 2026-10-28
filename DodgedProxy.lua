-- ======================================================================
-- DodgedProxy v2.0-reviewed  |  CreativePS Proxy / BotHax Lua  |  based on supplied v2.0 draft
--
-- REVIEWED STATICALLY ONLY; NOT RUN INSIDE THE PROXY. Written against the BotHax README
-- (github.com/dravenox/bothax). Every uncertain thing is tagged:
--   [DOC] documented in the README          [STD] standard Growtopia protocol,
--   [UNV] unverified guess, isolated in PKT   not in the README (test it)
-- Rules followed: no RunThread/load/loadfile/os.execute/os.date, no MakeRequest,
-- Sleep() is only ever called from the main loop (never inside a hook),
-- the script ends in an infinite loop so hooks stay alive.
-- ======================================================================

local VERSION = "2.0"

-- ---------------------------------------------------------------- lifecycle
local HOOK_LABELS = {}
local function addHook(kind, label, fn)
    pcall(RemoveHook, label)           -- [DOC] RemoveHook: avoids duplicate hooks on re-run
    AddHook(kind, label, fn)           -- [DOC]
    HOOK_LABELS[#HOOK_LABELS + 1] = label
end

-- ---------------------------------------------------------------- constants
local TICK_MS, MAX_QUEUE, LOG_CAP, CHAT_MAX = 50, 300, 80, 120
local SPAM_GAP_MS, SPAM_MAX_RUN = 3000, 10     -- bounded, user-started spam
local SB_GAP_MS, SB_MAX_RUN = 10000, 5         -- bounded, user-started broadcast
-- ASSUMPTION (cannot be verified from the README): lock ratios
local WL_PER_DL, DL_PER_BGL, BGL_PER_BLACK = 100, 100, 100

local LK = {   -- ids resolved at startup by name via GetItemInfo [DOC]; these are fallbacks
    wl    = {id = 242,   label = "WL",   expect = "World Lock",     value = 1},
    dl    = {id = 1796,  label = "DL",   expect = "Diamond Lock",   value = WL_PER_DL},
    bgl   = {id = 7188,  label = "BGL",  expect = "Blue Gem Lock",  value = WL_PER_DL * DL_PER_BGL},
    black = {id = 11550, label = "BLGL", expect = "Black Gem Lock", value = WL_PER_DL * DL_PER_BGL * BGL_PER_BLACK},
}
local LK_ORDER = {"wl", "dl", "bgl", "black"}
local LK_BY_ID = {}

-- Packet templates. All text packets go through SendPacket(type, text) [DOC].
local PKT
PKT = {
    respawn   = "action|respawn",                                                    -- [DOC] README example
    chat      = function(t) return "action|input\n|text|" .. t end,                  -- [STD]
    drop      = function(id) return "action|drop\n|itemID|" .. id end,               -- [STD]
    dropOK    = function(id, n) return "action|dialog_return\ndialog_name|drop_item\nitemID|" .. id .. "|\ncount|" .. n end, -- [STD]
    trashOK   = function(id, n) return "action|dialog_return\ndialog_name|trash_item\nitemID|" .. id .. "|\ncount|" .. n end, -- [STD]
    wrench    = function(nid) return "action|wrench\n|netid|" .. nid end,            -- [STD]
    wrenchBtn = function(nid, b) return "action|dialog_return\ndialog_name|popup\nnetID|" .. nid .. "|\nbuttonClicked|" .. b end, -- [STD]
    phoneButton = nil,                                                               -- [UNV] set to e.g. "dial" if /capture shows a button
    phone     = function(x, y, num)                                                  -- [UNV]
        return "action|dialog_return\ndialog_name|phonecall\ntilex|" .. x .. "|\ntiley|" .. y .. "|\nnum|" .. num .. "|"
            .. (PKT.phoneButton and ("\nbuttonClicked|" .. PKT.phoneButton) or "")
    end,
    tradeAdd  = function(id, n) return "action|dialog_return\ndialog_name|trade_item\nitemID|" .. id .. "|\ncount|" .. n end, -- [UNV]
    donate    = function(x, y, id, n) return "action|dialog_return\ndialog_name|give_item\ntilex|" .. x .. "|\ntiley|" .. y .. "|\nitemID|" .. id .. "|\ncount|" .. n end, -- [UNV]
    quit      = "action|quit",                                                       -- [UNV] /relog
}
local WRENCH_BTN = {pull = "pull", kick = "kick", ban = "worldban", trade = "trade"} -- [STD]
local EMOJIS = {"(lol)", "(wl)", "(heart)", "(party)", "(cry)", "(kiss)"}             -- [UNV]
local PH_KEYS = {"cvbgl", "buybgl", "buydl", "champ", "champbg", "champbulk", "black"}
local PH_LABEL = {cvbgl = "CV BGL", buybgl = "Buy BGL", buydl = "Buy DL", champ = "Champagne Normal",
    champbg = "Champagne BGem", champbulk = "Champagne Bulk", black = "BGL -> Black"}

-- ---------------------------------------------------------------- state
local function newConfig()
    return {
        logging = true, antiLag = false, antiPickup = false, blockSDB = false, autoCV = false,
        tpunch = false, fastDrop = false, fastTrash = false, dmode = false,
        wrenchMode = "off", wrenchChat = false,
        wrenchText = {pull = "Gas {GrowID}?", kick = "Bye {GrowID}!", ban = "Banned Begger {GrowID}!"},
        phoneArmed = nil,
        phones = {cvbgl = "53785"},      -- user-supplied; every other number must be set with /setphone
        emoji = false, randColor = false, watermark = false, encrypt = false,
        modes = {reme = false, qeme = false, leme = false},
        autoPull = false, apTarget = {kind = "door"}, apBlack = {},
        spamMsgs = {"Buying Locks!", "Selling DLS!"}, sbMsg = "Hello World!",
        host = {mode = "btk", tax = 10, btk = {}, bj = {}},   -- tax 10 is an ASSUMPTION
    }
end
local Config = newConfig()
local RT = {
    tick = 0, running = true, idle = 0, queue = {}, timers = {}, selfSent = {}, job = {},
    dropUntil = 0, wpend = nil, wlast = -100, pulled = {}, pick = nil, phoneTile = nil,
    donBox = nil, donWorld = nil, trading = false, lastSnap = nil, lastCV = -1000, lastPhone = -1000,
    imgui = false, cap = false, history = {}, calcLast = nil, door = nil, doorWorld = nil,
    amt = "1", itemRes = {}, betLines = {}, logKey = "collect", sec = "system",
}
local Logs = {collect = {}, drop = {}, inv = {}, spin = {}, capture = {}}

-- ---------------------------------------------------------------- utilities
local function plain(s) return (tostring(s):gsub("`.", "")) end
local function dsafe(s) return (plain(s):gsub("[|\r\n]", " ")) end
local function log(t) LogToConsole("`2[DodgedProxy]`o " .. tostring(t)) end   -- LogToConsole [DOC examples]
local function onoff(b) return b and "ON" or "OFF" end

local function toInt(s, lo, hi)      -- strict: digits only (rejects negatives, decimals, hex, junk)
    if s == nil then return nil end
    local str = tostring(s):match("^%s*(%d+)%s*$")
    if not str or #str > 9 then return nil end
    local n = tonumber(str)
    if (lo and n < lo) or (hi and n > hi) then return nil end
    return n
end

local function fmt(n)
    local neg = n < 0
    local s = tostring(math.floor(math.abs(n)))
    s = s:reverse():gsub("(%d%d%d)", "%1,")
    s = s:reverse():gsub("^,", "")
    return neg and ("-" .. s) or s
end

local function pushLog(name, text)
    if name ~= "capture" and not Config.logging then return end
    local l = Logs[name]
    l[#l + 1] = text
    while #l > LOG_CAP do table.remove(l, 1) end
end

local function utcParts()            -- uses os.time only (the only allowed os function)
    local ok, t = pcall(os.time)
    if not ok or type(t) ~= "number" then return nil end
    local days, secs = t // 86400, t % 86400
    local z = days + 719468
    local era = z // 146097
    local doe = z - era * 146097
    local yoe = (doe - doe // 1460 + doe // 36524 - doe // 146096) // 365
    local y = yoe + era * 400
    local doy = doe - (365 * yoe + yoe // 4 - yoe // 100)
    local mp = (5 * doy + 2) // 153
    local d = doy - (153 * mp + 2) // 5 + 1
    local m = mp < 10 and mp + 3 or mp - 9
    if m <= 2 then y = y + 1 end
    return y, m, d, secs // 3600, (secs % 3600) // 60, secs % 60
end
local function nowStr()
    local y, m, d, hh, mm = utcParts()
    return y and string.format("%04d-%02d-%02d %02d:%02d UTC", y, m, d, hh, mm) or nil
end
local function stamp()
    local _, _, _, hh, mm, ss = utcParts()
    return hh and string.format("%02d:%02d:%02d", hh, mm, ss) or "--:--:--"
end

pcall(function() math.randomseed(os.time()) end)

-- ---------------------------------------------------------------- scheduler
-- One queue consumed by the main loop. Tasks may Sleep(). Timers and bounded jobs are
-- tick-based and never block, so no branch can starve the queue.
local function enqueue(fn, afterMs)
    if #RT.queue >= MAX_QUEUE then log("`4Queue full - action dropped.") return false end
    RT.queue[#RT.queue + 1] = {fn = fn, after = math.max(0, math.ceil((afterMs or 0) / TICK_MS))}
    return true
end
local function after(ms, fn)
    if #RT.timers >= 100 then return end
    RT.timers[#RT.timers + 1] = {due = RT.tick + math.ceil(ms / TICK_MS), fn = fn}
end
local function send(t, s, afterMs) return enqueue(function() SendPacket(t, s) end, afterMs or 200) end

local function sayRaw(text)          -- run inside a queue task; marks the text as ours
    RT.selfSent[text] = RT.tick + 100
    SendPacket(2, PKT.chat(text))
end
local function chatOK(t)
    return type(t) == "string" and #t > 0 and #t <= CHAT_MAX and not t:find("[\r\n]")
end
local function say(text, afterMs)
    if not chatOK(text) then log("`4Chat text empty/too long (max " .. CHAT_MAX .. ").") return false end
    return enqueue(function() sayRaw(text) end, afterMs or 400)
end

-- ---------------------------------------------------------------- inventory
local function invCount(id)          -- nil = inventory unreadable (callers must not assume 0)
    local ok, inv = pcall(GetInventory)          -- [DOC] Inventory[] = {id, amount, flags}
    if not ok or type(inv) ~= "table" then return nil end
    local n = 0
    for _, it in pairs(inv) do
        if it.id == id then n = n + (it.amount or 0) end
    end
    return n
end
local function snap()
    local s = {}
    for _, k in ipairs(LK_ORDER) do
        local n = invCount(LK[k].id)
        if n == nil then return nil end
        s[k] = n
    end
    return s
end
local function diffStr(a, b)
    local parts = {}
    for _, k in ipairs(LK_ORDER) do
        local d = (b[k] or 0) - (a[k] or 0)
        if d ~= 0 then parts[#parts + 1] = string.format("%s %+d", LK[k].label, d) end
    end
    return #parts > 0 and table.concat(parts, ", ") or nil
end
local function watch(label, ms, note)   -- reports success ONLY if the inventory really changed
    local before = snap()
    after(ms or 1500, function()
        local now = snap()
        if not before or not now then log(label .. ": cannot read inventory to confirm.") return end
        local d = diffStr(before, now)
        if d then log("`2" .. label .. " confirmed by inventory: " .. d)
        else log("`4" .. label .. ": no inventory change detected." .. (note or " The packet format may be wrong - use /capture.")) end
    end)
end
local function totalWL()
    local t = 0
    for _, k in ipairs(LK_ORDER) do
        local n = invCount(LK[k].id)
        if n == nil then return nil end
        t = t + n * LK[k].value
    end
    return t
end
local function formatLocks(wl)
    local parts = {}
    for i = #LK_ORDER, 1, -1 do
        local k = LK_ORDER[i]
        local n = wl // LK[k].value
        if n > 0 then parts[#parts + 1] = n .. " " .. LK[k].label; wl = wl - n * LK[k].value end
    end
    return #parts > 0 and table.concat(parts, " + ") or "0"
end
local function resolveLocks()
    local lines = {}
    for _, k in ipairs(LK_ORDER) do
        local lk = LK[k]
        local ok, info = pcall(GetItemInfo, lk.expect)      -- [DOC] accepts a name
        if ok and type(info) == "table" and info.id and info.id ~= 0 and info.id ~= lk.id then
            lines[#lines + 1] = k .. ": name lookup gave id " .. info.id .. " (fallback was " .. lk.id .. "), using it"
            lk.id = info.id
        end
        local ok2, byId = pcall(GetItemInfo, lk.id)
        local nm = (ok2 and type(byId) == "table" and byId.name) or "?"
        lines[#lines + 1] = k .. ": id " .. lk.id .. " = " .. plain(nm)
        LK_BY_ID[lk.id] = k
    end
    return lines
end

-- ---------------------------------------------------------------- world helpers
local function worldName()
    local ok, w = pcall(GetWorld)                -- [DOC]
    return ok and type(w) == "table" and w.name or nil
end
local function myTile()
    local ok, me = pcall(GetLocal)               -- [DOC]
    if not ok or type(me) ~= "table" or not me.pos then return nil end
    return math.floor(me.pos.x / 32), math.floor(me.pos.y / 32)
end
local function itemName(id)
    local ok, info = pcall(GetItemInfo, id)
    return (ok and type(info) == "table" and info.name or ""):lower()
end
local function tileName(x, y)
    local ok, t = pcall(GetTile, x, y)           -- [DOC]
    if not ok or type(t) ~= "table" or not t.fg or t.fg == 0 then return "" end
    return itemName(t.fg)
end
local function findTiles(sub, limit)
    local out, cache = {}, {}
    local ok, tiles = pcall(GetTiles)            -- [DOC]
    if not ok or type(tiles) ~= "table" then return out end
    for _, t in pairs(tiles) do
        local fg = t.fg
        if fg and fg ~= 0 then
            if cache[fg] == nil then cache[fg] = itemName(fg) end
            if cache[fg]:find(sub, 1, true) then
                out[#out + 1] = {x = t.x or (t.pos and t.pos.x), y = t.y or (t.pos and t.pos.y)}
                if limit and #out >= limit then break end
            end
        end
    end
    return out
end
local function playerName(nid)
    local ok, p = pcall(GetPlayer, nid)          -- [DOC]
    if ok and type(p) == "table" and p.name then return plain(p.name) end
    return "player"
end
local function teleportTo(x, y)
    for _, c in ipairs({{x, y}, {x, y + 1}, {x, y - 1}, {x - 1, y}, {x + 1, y}}) do
        local ok, walk = pcall(CheckPath, c[1], c[2])      -- [DOC]
        if ok and walk then FindPath(c[1], c[2]); return true end   -- [DOC]
    end
    log("`4No walkable tile near " .. x .. "," .. y)
    return false
end

-- ---------------------------------------------------------------- actions
local function dropTask(key, want)   -- inventory is re-read immediately before the action
    local lk = LK[key]
    local have = invCount(lk.id)
    if have == nil then log("`4Inventory unreadable - nothing dropped.") return end
    local n = want
    if want == "all" then n = have
    elseif want > have then log(string.format("`4Refused: asked to drop %d %s but you have %d.", want, lk.label, have)) return end
    if n <= 0 then log("`4No " .. lk.label .. " to drop.") return end
    RT.dropUntil = RT.tick + 40
    watch("Drop " .. n .. " " .. lk.label)
    -- Do not Sleep() inside a queue task: that stalls every other timer and hook-driven job.
    SendPacket(2, PKT.drop(lk.id))
    after(250, function()
        local current = invCount(lk.id)
        if current == nil or current < n then
            log("`4Drop cancelled: inventory changed or could not be read before confirmation.")
            return
        end
        SendPacket(2, PKT.dropOK(lk.id, n))
        pushLog("drop", stamp() .. " drop " .. n .. " " .. lk.label .. " (sent; confirmation unverified)")
    end)
end
local function queueDrop(key, want) enqueue(function() dropTask(key, want) end, 600) end

local function smartDropTask(target)  -- exact amount of DL-equivalent or nothing; never uses WL
    local dl, bgl, blk = invCount(LK.dl.id), invCount(LK.bgl.id), invCount(LK.black.id)
    if not (dl and bgl and blk) then log("`4Inventory unreadable.") return end
    -- Select largest denominations first. The previous DL-first greedy order could
    -- falsely reject an exact payment (e.g. 1 BGL + 50 DL for 150 DL-equivalent).
    local need = target
    local useDL, useBGL, useBLK = 0, 0, 0
    local perBlack = DL_PER_BGL * BGL_PER_BLACK
    useBLK = math.min(blk, need // perBlack); need = need - useBLK * perBlack
    useBGL = math.min(bgl, need // DL_PER_BGL); need = need - useBGL * DL_PER_BGL
    useDL = math.min(dl, need); need = need - useDL
    if need > 0 then
        log("`4/dd " .. target .. ": cannot be paid exactly from your DL/BGL/Black locks (short " .. need .. " DL). Nothing dropped.")
        return
    end
    if useBLK > 0 then queueDrop("black", useBLK) end
    if useBGL > 0 then queueDrop("bgl", useBGL) end
    if useDL > 0 then queueDrop("dl", useDL) end
end

local function convertBlackToBGL()    -- /blue: activate Black GL in inventory
    enqueue(function()
        local have = invCount(LK.black.id)
        if not have or have < 1 then log("`4You have no Black Gem Lock to convert.") return end
        watch("Black GL -> BGL", 2000)
        SendPacketRaw(false, {type = 10, value = LK.black.id})   -- [DOC] pattern (README shows DL->WL with type 10)
    end, 600)
end

local function dialPhone(key, tx, ty)
    local num = Config.phones[key]
    if not num then log("`4No phone number for '" .. key .. "'. Use /setphone " .. key .. " <digits>.") return end
    if RT.tick - RT.lastPhone < 60 then log("`4Phone: wait 3 seconds between calls.") return end
    if not (tx and ty) then
        local t = RT.phoneTile or findTiles("telephone", 1)[1]
        if not t then log("`4No Telephone found in this world (place one or arm phone mode and punch it).") return end
        tx, ty = t.x, t.y
    end
    RT.phoneTile = {x = tx, y = ty}
    RT.lastPhone = RT.tick
    enqueue(function()
        watch("Phone " .. PH_LABEL[key], 8000, " If a dialog opened, finish it manually.")
        SendPacket(2, PKT.phone(tx, ty, num))
        log("Phone " .. PH_LABEL[key] .. ": sent number " .. num .. " at tile " .. tx .. "," .. ty .. " (not confirmed yet).")
    end, 500)
end

local function queueTrade(key, want)  -- [UNV] packet; cannot be confirmed from inventory
    enqueue(function()
        local lk = LK[key]
        local have = invCount(lk.id)
        if not have then log("`4Inventory unreadable.") return end
        local n = (want == "all") and have or want
        if n > have then log(string.format("`4Refused: %d %s requested, you have %d.", n, lk.label, have)) return end
        if n <= 0 then return end
        SendPacket(2, PKT.tradeAdd(lk.id, n))
        log("Trade: sent add " .. n .. " " .. lk.label .. " (not confirmed - check the trade window).")
    end, 500)
end

local function donationBox()
    if RT.donBox and RT.donWorld == worldName() then return RT.donBox end
    return nil
end
local function queueDonate(key, want)  -- [UNV] packet; confirmed by inventory drop
    if not donationBox() then log("`4No donation box set. Turn on /dmode and wrench a Donation Box.") return end
    enqueue(function()
        local box, lk = donationBox(), LK[key]
        if not box then return end
        local have = invCount(lk.id)
        if not have then log("`4Inventory unreadable.") return end
        local n = (want == "all") and have or want
        if n > have then log(string.format("`4Refused: %d %s requested, you have %d.", n, lk.label, have)) return end
        if n <= 0 then return end
        watch("Donate " .. n .. " " .. lk.label)
        SendPacket(2, PKT.donate(box.x, box.y, lk.id, n))
    end, 600)
end

local function wrenchAction(nid, mode)  -- wrench a player, then answer the REAL dialog (see handleDialog)
    enqueue(function()
        RT.wpend = {mode = mode, nid = nid, due = RT.tick + 80}
        SendPacket(2, PKT.wrench(nid))
    end, 900)
end

local function pullTarget()
    local t = Config.apTarget
    if t.kind == "tile" then return t.x, t.y end
    if not RT.door or RT.doorWorld ~= worldName() then
        local f = findTiles("white door", 1)
        if #f == 0 then f = findTiles("main door", 1) end
        RT.door, RT.doorWorld = f[1], worldName()
    end
    if RT.door then return RT.door.x, RT.door.y end
    return nil
end
local function autoPullScan()
    local ok, list = pcall(GetPlayerList)       -- [DOC] excludes yourself
    if not ok or type(list) ~= "table" then return end
    local tx, ty = pullTarget()
    if not tx then return end
    for _, p in pairs(list) do
        if p.pos and p.netid and not (p.userid and Config.apBlack[tostring(p.userid)]) and not RT.pulled[p.netid] then
            local px, py = math.floor(p.pos.x / 32), math.floor(p.pos.y / 32)
            if math.abs(px - tx) <= 1 and math.abs(py - ty) <= 1 then
                RT.pulled[p.netid] = RT.tick + 400      -- per-player 20 s cooldown
                wrenchAction(p.netid, "pull")
            end
        end
    end
end

local function evalMath(s)           -- recursive-descent parser, no dynamic code
    s = tostring(s or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if #s == 0 then return false, "empty formula" end
    if #s > 100 then return false, "formula too long" end
    if s:find("[^%d%s%.%+%-%*/%%%^%(%)]") then return false, "invalid characters" end
    local pos, depth, expr = 1, 0, nil
    local function skip() while s:sub(pos, pos):match("%s") do pos = pos + 1 end end
    local function num()
        skip()
        local n = s:match("^%d+%.?%d*", pos) or s:match("^%.%d+", pos)
        if not n then error("number expected") end
        pos = pos + #n
        return tonumber(n) + 0.0
    end
    local function atom()
        depth = depth + 1
        if depth > 30 then error("too deeply nested") end
        skip()
        local c, v = s:sub(pos, pos)
        if c == "(" then
            pos = pos + 1; v = expr(); skip()
            if s:sub(pos, pos) ~= ")" then error("missing )") end
            pos = pos + 1
        elseif c == "-" then pos = pos + 1; v = -atom()
        else v = num() end
        depth = depth - 1
        return v
    end
    local function pow() local v = atom(); skip()
        if s:sub(pos, pos) == "^" then pos = pos + 1; return v ^ pow() end
        return v end
    local function term() local v = pow()
        while true do
            skip(); local c = s:sub(pos, pos)
            if c == "*" then pos = pos + 1; v = v * pow()
            elseif c == "/" then pos = pos + 1; v = v / pow()
            elseif c == "%" then pos = pos + 1; v = v % pow()
            else return v end
        end end
    expr = function() local v = term()
        while true do
            skip(); local c = s:sub(pos, pos)
            if c == "+" then pos = pos + 1; v = v + term()
            elseif c == "-" then pos = pos + 1; v = v - term()
            else return v end
        end end
    local ok, v = pcall(function() local r = expr(); skip()
        if pos <= #s then error("unexpected '" .. s:sub(pos, pos) .. "'") end
        return r end)
    if not ok then return false, (tostring(v):gsub("^.-:%d+: ", "")) end
    if v ~= v or v == math.huge or v == -math.huge then return false, "undefined result" end
    if v == math.floor(v) and math.abs(v) < 1e15 then return true, fmt(v) end
    return true, string.format("%.6g", v)
end

-- ---------------------------------------------------------------- bounded broadcast jobs
local JOB_GAP = {spam = SPAM_GAP_MS, sb = SB_GAP_MS, sdb = SB_GAP_MS}
local JOB_MAX = {spam = SPAM_MAX_RUN, sb = SB_MAX_RUN, sdb = SB_MAX_RUN}
local function jobText(kind, idx)
    if kind == "spam" then return Config.spamMsgs[idx] end
    return (kind == "sb" and "/sb " or "/sdb ") .. Config.sbMsg      -- /sdb syntax is [UNV]
end
local function startJob(kind, countArg)
    if RT.job[kind] then RT.job[kind] = nil; log(kind:upper() .. " stopped.") return end
    if kind == "spam" and #Config.spamMsgs == 0 then log("`4No spam messages. Use /addspam <text>.") return end
    local n = (kind == "spam") and math.min(#Config.spamMsgs, JOB_MAX[kind]) or 1
    if countArg then
        n = toInt(countArg, 1, JOB_MAX[kind])
        if not n then log("`4Count must be a whole number 1-" .. JOB_MAX[kind] .. ".") return end
    end
    RT.job[kind] = {left = n, idx = 1, gap = math.ceil(JOB_GAP[kind] / TICK_MS), nextAt = RT.tick}
    log(kind:upper() .. " started: " .. n .. " message(s), one every " .. (JOB_GAP[kind] // 1000) .. "s. Run the same command again to stop.")
end
local function tickJobs()
    for kind, j in pairs(RT.job) do
        if RT.tick >= j.nextAt then
            local text = jobText(kind, j.idx)
            if text and chatOK(text) then say(text, 0) end
            j.left = j.left - 1
            j.idx = (kind == "spam") and (j.idx % math.max(#Config.spamMsgs, 1) + 1) or 1
            j.nextAt = RT.tick + j.gap
            if j.left <= 0 then RT.job[kind] = nil; log(kind:upper() .. " finished.") end
        end
    end
end

-- ---------------------------------------------------------------- dialog builders
local B = {}
function B.head(t, icon) return "set_default_color|`o\nadd_label_with_icon|big|`2" .. t .. "|left|" .. icon .. "|\nadd_spacer|small|\n" end
function B.tx(s) return "add_textbox|`w" .. dsafe(s) .. "|left|\n" end
function B.btn(n, l) return "add_button|" .. n .. "|" .. l .. "|noflags|0|0|\n" end
function B.tog(n, l, on) return B.btn(n, l .. ": " .. (on and "`2ON``" or "`4OFF``")) end
function B.inp(n, l, def, len) return "add_text_input|" .. n .. "|" .. l .. "|" .. dsafe(def or "") .. "|" .. (len or 60) .. "|\n" end
function B.foot(page, lc)
    return "add_spacer|small|\n" .. (lc and B.btn("lc", "List Command") or "")
        .. "add_button|back|Back|noflags|0|0|\nadd_quick_exit|\nend_dialog|dp_" .. page .. "||Close|"
end
local function showDialog(d)
    local ok, err = pcall(SendVariantList, {[0] = "OnDialogRequest", [1] = d}, -1, 0)   -- [DOC] signature
    if not ok then log("`4Dialog failed: " .. tostring(err)) end
end

local Pages, SEC, SEC_ORDER, CMD = {}, {}, {}, {}
local showPage

local function section(key, title) SEC[key] = {title = title, list = {}}; SEC_ORDER[#SEC_ORDER + 1] = key end
-- st: "ok" | "test" (needs in-game test) | "partial" | "na" (unavailable)
local function cmd(sec, names, usage, help, st, fn)
    names = type(names) == "table" and names or {names}
    local e = {names = names, usage = usage, help = help, st = st, fn = fn}
    for _, n in ipairs(names) do CMD[n] = e end
    table.insert(SEC[sec].list, e)
end
local function na(sec, names, usage, help, why)
    cmd(sec, names, usage, help, "na", function() log("`4" .. usage .. " is unavailable: " .. why) end)
    local e = CMD[type(names) == "table" and names[1] or names]; e.why = why
end

local function setToggle(k)
    Config[k] = not Config[k]
    log(k .. ": " .. onoff(Config[k]))
    if k == "autoCV" and Config[k] and not Config.phones.cvbgl then log("`4Auto CV needs /setphone cvbgl <digits>.") end
end

-- ---------------------------------------------------------------- pages
local MAIN = {
    {"general", "General", 18}, {"wrench", "Wrench", 32}, {"donate", "Donate", 1796}, {"trade", "Trade", 242},
    {"tele", "Telephone", 3898}, {"emoji", "Emoji & Color", 1420}, {"calc", "Calculator", 3898}, {"itemdb", "Item Database", 32},
    {"autofarm", "Auto Farm", 32, true}, {"autocook", "Auto Cook", 32, true}, {"autofish", "Auto Fish", 32, true},
    {"autosurg", "Auto Surgery", 32, true}, {"autocrime", "Auto Crime", 32, true}, {"autogeiger", "Auto Geiger", 32, true},
    {"autoprovider", "Auto Provider", 32, true}, {"autobuypack", "Auto Buy Pack", 32, true},
    {"casino", "Casino", 758}, {"btk", "BTK & BJ", 758}, {"autopull", "Auto Pull", 32}, {"autospam", "Auto Spam", 2480},
    {"autosb", "Auto SB & SDB", 2480}, {"magvend", "Mag & Vend", 32, true}, {"world", "World", 6}, {"logs", "All Logs", 2480},
}

Pages.main = {
    build = function()
        local d = B.head("DodgedProxy " .. VERSION, 758) .. B.tx("Date/Time: " .. (nowStr() or "unavailable"))
        d = d .. "add_button_with_icon|m_cmd|Commands|staticBlueFrame|32||\nadd_button_with_icon|m_set|Setting|staticBlueFrame|1008||\n"
        d = d .. "add_button_with_icon|m_info|Information|staticBlueFrame|6016||\nadd_button_with_icon||END_LIST|noflags|0||\n"
        d = d .. "add_label|small|`wAll Feature :|left|\n"
        for _, e in ipairs(MAIN) do
            d = d .. "add_button_with_icon|p_" .. e[1] .. "|" .. (e[4] and "`4" or "") .. e[2] .. "|staticBlueFrame|" .. e[3] .. "||\n"
        end
        return d .. "add_button_with_icon||END_LIST|noflags|0||\nadd_quick_exit|\nend_dialog|dp_main||Close|"
    end,
    act = function(b)
        if b == "m_cmd" then showPage("cmdlist") elseif b == "m_set" then showPage("setting")
        elseif b == "m_info" then showPage("info") elseif b:sub(1, 2) == "p_" then showPage(b:sub(3)) end
    end,
}

local MARK = {ok = "", test = " `3[T]``", partial = " `6[P]``", na = " `4[X]``"}
Pages.cmdlist = {
    build = function()
        local d = B.head("Commands", 32) .. B.tx("Legend: [T] needs in-game testing, [P] partial, [X] unavailable.")
        for _, k in ipairs(SEC_ORDER) do d = d .. B.btn("s_" .. k, SEC[k].title) end
        return d .. B.foot("cmdlist")
    end,
    act = function(b) local k = b:match("^s_(%w+)$"); if k and SEC[k] then RT.sec = k; showPage("cmdsec") end end,
}
Pages.cmdsec = {
    back = "cmdlist",
    build = function()
        local s = SEC[RT.sec]
        local d = B.head(s.title, 32)
        for _, e in ipairs(s.list) do
            d = d .. "add_textbox|`w" .. dsafe(e.usage) .. "`o : " .. dsafe(e.help) .. (MARK[e.st] or "") .. "|left|\n"
            if e.why then d = d .. "add_smalltext|`4" .. dsafe(e.why) .. "|\n" end
        end
        return d .. B.foot("cmdsec")
    end,
}

local TOG = {antiLag = "Anti-Lag (weather/particles)", antiPickup = "Anti-Pickup", blockSDB = "Block SDB Dialogs",
    autoCV = "Auto CV Locks", tpunch = "Teleport Punch (Display/Vend)", fastDrop = "Fast Drop", fastTrash = "Fast Trash"}
local TOG_ORDER = {"antiLag", "antiPickup", "blockSDB", "autoCV", "tpunch", "fastDrop", "fastTrash"}
Pages.general = {sec = "general",
    build = function()
        local d = B.head("General Proxy Features", 18)
        for _, k in ipairs(TOG_ORDER) do d = d .. B.tog("t_" .. k, TOG[k], Config[k]) end
        d = d .. B.tx("Unavailable (no verified data): Hide Spammer Slave, Vend Filter, Donation Box Filter, Storage Box Filter.")
        return d .. B.foot("general", true)
    end,
    act = function(b) local k = b:match("^t_(%w+)$"); if k and TOG[k] then setToggle(k) end; showPage("general") end,
}

local WM = {"off", "pull", "kick", "ban", "trade"}
local function chatClean(t)
    t = tostring(t or ""):gsub("[\r\n|]", " "):gsub("^%s+", ""):gsub("%s+$", "")
    return #t <= 100 and t or nil
end
Pages.wrench = {sec = "wrench",
    build = function()
        local d = B.head("Wrench Mode Settings", 32) .. B.tx("Left Click Action (Main):")
        for _, m in ipairs(WM) do d = d .. B.tog("wm_" .. m, m:sub(1, 1):upper() .. m:sub(2), Config.wrenchMode == m) end
        d = d .. B.tx("Right Click Action: unavailable - the documented hooks do not say which mouse button was used.")
        d = d .. B.tog("chat", "Chat on action", Config.wrenchChat) .. B.tx("Custom chat ({GrowID} = player name):")
        d = d .. B.inp("tpull", "Pull:", Config.wrenchText.pull, 100) .. B.inp("tkick", "Kick:", Config.wrenchText.kick, 100)
        d = d .. B.inp("tban", "Ban:", Config.wrenchText.ban, 100) .. B.btn("savetext", "Save Text")
        d = d .. B.tx("Show Balance: unavailable (CPS wrench dialog format not verified). Mode applies to one wrench click at a time; there is no mass kick/ban.")
        return d .. B.foot("wrench", true)
    end,
    act = function(b, f)
        local m = b:match("^wm_(%a+)$")
        if m then Config.wrenchMode = m; log("Wrench mode: " .. m)
        elseif b == "chat" then Config.wrenchChat = not Config.wrenchChat
        elseif b == "savetext" then
            local p, k, n = chatClean(f.tpull), chatClean(f.tkick), chatClean(f.tban)
            if p and k and n then Config.wrenchText = {pull = p, kick = k, ban = n}; log("Wrench texts saved.")
            else log("`4Texts must be at most 100 characters.") end
        end
        showPage("wrench")
    end,
}

local KEYBTN = {w = "wl", d = "dl", b = "bgl", k = "black"}
Pages.donate = {sec = "donate",
    build = function()
        local box = donationBox()
        local d = B.head("Smart Donation Mode", 1796) .. B.tog("dmode", "Donate Mode", Config.dmode)
        d = d .. B.tx("Box Status: " .. (box and ("set at " .. box.x .. "," .. box.y) or "Not set. Turn on Donate Mode and wrench a Donation Box."))
        d = d .. B.inp("amt", "Amount:", RT.amt, 6) .. B.btn("do_w", "Donate WL") .. B.btn("do_d", "Donate DL")
        d = d .. B.btn("do_b", "Donate BGL") .. B.btn("do_k", "Donate BlackGL") .. B.btn("do_all", "Put All Locks")
        d = d .. B.tx("Take All Items: unavailable (take-all dialog not verified). Donation packet is unverified - results are confirmed by inventory change.")
        return d .. B.foot("donate", true)
    end,
    act = function(b, f)
        RT.amt = tostring(toInt(f.amt, 1, 999999) or RT.amt)
        if b == "dmode" then setToggle("dmode")
        elseif b == "do_all" then for _, k in ipairs(LK_ORDER) do queueDonate(k, "all") end
        elseif b:match("^do_%a$") then
            local n = toInt(f.amt, 1, 999999)
            if n then queueDonate(KEYBTN[b:sub(4)], n) else log("`4Amount must be a positive whole number.") end
        end
        showPage("donate")
    end,
}

Pages.trade = {sec = "trade",
    build = function()
        local d = B.head("Advanced Trading Mode", 242) .. B.tog("tmode", "Trade Mode (wrench = trade)", Config.wrenchMode == "trade")
        d = d .. B.tx("Trade Status: " .. (RT.trading and "In a trade (detected)." or "Not trading (or not detected). Wrench a player."))
        d = d .. B.inp("amt", "Amount:", RT.amt, 6) .. B.btn("tr_w", "Add WL") .. B.btn("tr_d", "Add DL")
        d = d .. B.btn("tr_b", "Add BGL") .. B.btn("tr_k", "Add BlackGL") .. B.btn("tr_all", "Put All Locks")
        d = d .. B.tx("Clear Locks: unavailable (no verified way to remove items from a trade). Add packet is unverified and cannot be confirmed by inventory.")
        return d .. B.foot("trade", true)
    end,
    act = function(b, f)
        RT.amt = tostring(toInt(f.amt, 1, 999999) or RT.amt)
        if b == "tmode" then Config.wrenchMode = (Config.wrenchMode == "trade") and "off" or "trade"
        elseif b == "tr_all" then for _, k in ipairs(LK_ORDER) do queueTrade(k, "all") end
        elseif b:match("^tr_%a$") then
            local n = toInt(f.amt, 1, 999999)
            if n then queueTrade(KEYBTN[b:sub(4)], n) else log("`4Amount must be a positive whole number.") end
        end
        showPage("trade")
    end,
}

Pages.tele = {sec = "tele",
    build = function()
        local d = B.head("Telephone Auto-Buy", 3898) .. B.tx("Arm an action, then punch a Telephone. Numbers are yours to set; only CV BGL has a default (user-supplied).")
        for _, k in ipairs(PH_KEYS) do
            d = d .. B.tog("arm_" .. k, PH_LABEL[k] .. (Config.phones[k] and "" or " (no number)"), Config.phoneArmed == k)
        end
        d = d .. B.tx("Phone numbers (digits only, blank = unset):")
        for _, k in ipairs(PH_KEYS) do d = d .. B.inp("n_" .. k, PH_LABEL[k] .. ":", Config.phones[k] or "", 9) end
        d = d .. B.btn("savenums", "Save Numbers")
        return d .. B.foot("tele", true)
    end,
    act = function(b, f)
        local k = b:match("^arm_(%w+)$")
        if k then
            if not Config.phones[k] then log("`4Set a number for " .. PH_LABEL[k] .. " first.")
            else Config.phoneArmed = (Config.phoneArmed == k) and nil or k end
        elseif b == "savenums" then
            for _, key in ipairs(PH_KEYS) do
                local v = tostring(f["n_" .. key] or ""):gsub("%s", "")
                if v == "" then Config.phones[key] = nil
                elseif v:match("^%d+$") and #v >= 3 and #v <= 9 then Config.phones[key] = v
                else log("`4" .. PH_LABEL[key] .. ": number must be 3-9 digits.") end
            end
            if Config.phoneArmed and not Config.phones[Config.phoneArmed] then Config.phoneArmed = nil end
        end
        showPage("tele")
    end,
}

Pages.emoji = {sec = "emoji",
    build = function()
        local d = B.head("Emoji & Color Settings", 1420)
        d = d .. B.tog("randColor", "Random Text Color", Config.randColor) .. B.tog("emoji", "Random Chat Emojis", Config.emoji)
        d = d .. B.tog("watermark", "Chat Watermark", Config.watermark) .. B.tog("encrypt", "Encrypt Chat", Config.encrypt)
        d = d .. B.tx("Skin Effects (Rainbow/Blink) and Skin Color Presets: unavailable - no verified variant/skin values.")
        d = d .. B.tx("Chat decoration only touches plain chat (not /commands) and is skipped if the line would exceed " .. CHAT_MAX .. " characters.")
        return d .. B.foot("emoji", true)
    end,
    act = function(b) if b == "randColor" or b == "emoji" or b == "watermark" or b == "encrypt" then setToggle(b) end; showPage("emoji") end,
}

Pages.calc = {sec = "calc",
    build = function()
        local d = B.head("Smart Calculator", 3898) .. B.tx("Operators: + - * / % ^ and ( ). Enter a formula:")
        d = d .. B.inp("formula", "Formula:", "", 100) .. B.btn("go", "Calculate")
        d = d .. B.tx("Latest Result: " .. (RT.calcLast or "Waiting for input..."))
        d = d .. B.tx("History:")
        if #RT.history == 0 then d = d .. B.tx("No history available.") end
        for i = #RT.history, 1, -1 do d = d .. B.tx(RT.history[i]) end
        return d .. B.foot("calc", true)
    end,
    act = function(b, f)
        if b == "go" then
            local ok, r = evalMath(f.formula)
            RT.calcLast = ok and (dsafe(f.formula) .. " = " .. r) or ("error: " .. r)
            if ok then RT.history[#RT.history + 1] = RT.calcLast; while #RT.history > 10 do table.remove(RT.history, 1) end end
        end
        showPage("calc")
    end,
}

local function itemSearch(q)
    local out = {}
    q = tostring(q or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if q == "" then return {"Enter an item name or id."} end
    local id = toInt(q)
    if id then
        local ok, info = pcall(GetItemInfo, id)
        if ok and type(info) == "table" and info.id and info.id ~= 0 then
            out[1] = string.format("%d: %s (rarity %s)", info.id, dsafe(info.name or "?"), tostring(info.rarity)) else out[1] = "No item with id " .. id end
        return out
    end
    local ok, list = pcall(GetItemsByPartialName, q)         -- [DOC]
    if not ok or type(list) ~= "table" or #list == 0 then return {"No items match '" .. dsafe(q) .. "'."} end
    for i, it in ipairs(list) do
        if i > 15 then out[#out + 1] = "... (more, refine the search)"; break end
        out[#out + 1] = string.format("%d: %s (rarity %s)", it.id, dsafe(it.name or "?"), tostring(it.rarity))
    end
    return out
end
Pages.itemdb = {sec = "itemdb",
    build = function()
        local d = B.head("Item Database", 32) .. B.inp("q", "Name or id:", "", 40) .. B.btn("go", "Search")
        for _, l in ipairs(RT.itemRes) do d = d .. B.tx(l) end
        return d .. B.foot("itemdb", true)
    end,
    act = function(b, f) if b == "go" then RT.itemRes = itemSearch(f.q) end; showPage("itemdb") end,
}

Pages.casino = {sec = "casino",
    build = function()
        local m = Config.modes
        local d = B.head("Casino Modes", 758) .. B.tog("reme", "Reme", m.reme) .. B.tog("qeme", "Qeme", m.qeme) .. B.tog("leme", "Leme (formula assumed)", m.leme)
        d = d .. B.btn("all", "Toggle All (Reme, Leme, Qeme)")
        d = d .. B.tx("Unavailable (formula unknown): Leme S, Ceme, Lewa <num>. /cf and /dice are local random rolls, not game results.")
        d = d .. B.tx("Last spins:")
        for i = math.max(1, #Logs.spin - 4), #Logs.spin do d = d .. B.tx(Logs.spin[i]) end
        return d .. B.foot("casino", true)
    end,
    act = function(b)
        local m = Config.modes
        if b == "all" then local on = not (m.reme and m.qeme and m.leme); m.reme, m.qeme, m.leme = on, on, on
        elseif m[b] ~= nil then m[b] = not m[b] end
        showPage("casino")
    end,
}

-- BTK/BJ: only what the documented API can do (positions + bet totals from dropped locks)
local function hostTbl() return Config.host[Config.host.mode] end
local function betReport()
    local h, lines = hostTbl(), {}
    local ok, objs = pcall(GetObjectList)                    -- [DOC]
    if not ok or type(objs) ~= "table" then return {"Cannot read world objects."} end
    local pot = 0
    for i, key in ipairs({"bet1", "bet2"}) do
        local pos = h[key]
        if not pos then lines[#lines + 1] = "Bet " .. i .. ": tile not set"
        else
            local total = 0
            for _, o in pairs(objs) do
                local k = LK_BY_ID[o.id]
                if k and o.pos and math.floor(o.pos.x / 32) == pos.x and math.floor(o.pos.y / 32) == pos.y then
                    total = total + LK[k].value * (o.amount or 1)
                end
            end
            local who = {}
            for _, p in pairs(GetPlayerList() or {}) do
                if p.pos and math.floor(p.pos.x / 32) == pos.x and math.floor(p.pos.y / 32) == pos.y then who[#who + 1] = plain(p.name) end
            end
            pot = pot + total
            lines[#lines + 1] = string.format("Bet %d (%d,%d): %s [%s]", i, pos.x, pos.y, formatLocks(total), #who > 0 and table.concat(who, ", ") or "nobody standing")
        end
    end
    local tax = pot * Config.host.tax // 100
    lines[#lines + 1] = string.format("Pot %s | Tax %d%% = %s | Prize %s", formatLocks(pot), Config.host.tax, formatLocks(tax), formatLocks(pot - tax))
    return lines
end
Pages.btk = {sec = "btk",
    build = function()
        local h = hostTbl()
        local function p(k) return h[k] and (h[k].x .. "," .. h[k].y) or "not set" end
        local d = B.head("Host Panel (" .. Config.host.mode:upper() .. ")", 758) .. B.btn("mode", "Switch Mode (now " .. Config.host.mode:upper() .. ")")
        d = d .. B.tx("Center: " .. p("center") .. " | Bet P1: " .. p("bet1") .. " | Bet P2: " .. p("bet2"))
        d = d .. B.btn("set_center", "Set Center") .. B.btn("set_bet1", "Set Bet P1") .. B.btn("set_bet2", "Set Bet P2")
        d = d .. B.inp("tax", "Tax % (0-50):", tostring(Config.host.tax), 2) .. B.btn("calc", "Take Bets & Calculate Tax")
        for _, l in ipairs(RT.betLines) do d = d .. B.tx(l) end
        d = d .. B.tx("Unavailable: remote collect, gem check/winner, prize drop, break P1/P2, tax tile, magplant tile (mechanics not verifiable). Bet totals count dropped locks on the bet tiles.")
        return d .. B.foot("btk", true)
    end,
    act = function(b, f)
        local t = toInt(f.tax, 0, 50)
        if t then Config.host.tax = t end
        if b == "mode" then Config.host.mode = (Config.host.mode == "btk") and "bj" or "btk"
        elseif b:match("^set_") then
            RT.pick = {field = b:sub(5), mode = Config.host.mode, expires = RT.tick + 600}
            log("Punch or touch the tile now (30 seconds).")
            return
        elseif b == "calc" then RT.betLines = betReport() end
        showPage("btk")
    end,
}

Pages.autopull = {sec = "autopull",
    build = function()
        local t, tx, ty = Config.apTarget, pullTarget()
        local bl = {}
        for k in pairs(Config.apBlack) do bl[#bl + 1] = k end
        local d = B.head("Auto Pull", 32) .. B.tog("ap", "Auto Pull Master", Config.autoPull)
        d = d .. B.tx("Trigger tile: " .. (t.kind == "tile" and "your saved tile" or "White Door") .. (tx and (" (" .. tx .. "," .. ty .. ")") or " (not found)"))
        d = d .. B.tx("A player standing within 1 tile of the trigger tile gets pulled once (20 s cooldown each, one wrench per second).")
        d = d .. B.btn("pos", "Set trigger = my tile") .. B.btn("door", "Reset to White Door")
        d = d .. B.inp("uid", "UID:", "", 9) .. B.btn("bladd", "Blacklist add") .. B.btn("blrem", "Blacklist remove")
        d = d .. B.tx("Blacklist: " .. (#bl > 0 and table.concat(bl, ", ") or "(empty)"))
        return d .. B.foot("autopull", true)
    end,
    act = function(b, f)
        if b == "ap" then setToggle("autoPull")
        elseif b == "pos" then local x, y = myTile(); if x then Config.apTarget = {kind = "tile", x = x, y = y}; log("Auto Pull trigger = " .. x .. "," .. y) else log("`4Cannot read your position.") end
        elseif b == "door" then Config.apTarget = {kind = "door"}
        elseif b == "bladd" or b == "blrem" then
            local u = toInt(f.uid, 1)
            if not u then log("`4UID must be a positive whole number.")
            else Config.apBlack[tostring(u)] = (b == "bladd") or nil end
        end
        showPage("autopull")
    end,
}

local function jobStatus(k) local j = RT.job[k]; return j and (j.left .. " left") or "idle" end
Pages.autospam = {sec = "spam",
    build = function()
        local d = B.head("Auto Spam", 2480) .. B.tx("Bounded run: max " .. SPAM_MAX_RUN .. " messages, one per " .. SPAM_GAP_MS // 1000 .. "s, only when you start it. Status: " .. jobStatus("spam"))
        for i, m in ipairs(Config.spamMsgs) do d = d .. B.tx(i .. ". " .. m) end
        d = d .. B.inp("txt", "Message:", "", 100) .. B.btn("run", "Start / Stop run") .. B.btn("add", "Add message") .. B.btn("rem", "Remove last")
        return d .. B.foot("autospam", true)
    end,
    act = function(b, f)
        if b == "run" then startJob("spam")
        elseif b == "add" then local t = chatClean(f.txt); if t and chatOK(t) then table.insert(Config.spamMsgs, t) else log("`4Message empty or too long.") end
        elseif b == "rem" then table.remove(Config.spamMsgs) end
        showPage("autospam")
    end,
}
Pages.autosb = {sec = "sb",
    build = function()
        local d = B.head("Super Broadcast", 2480) .. B.tx("Bounded: max " .. SB_MAX_RUN .. " broadcasts, one per " .. SB_GAP_MS // 1000 .. "s. SB: " .. jobStatus("sb") .. " | SDB: " .. jobStatus("sdb"))
        d = d .. B.inp("txt", "Message:", Config.sbMsg, 100) .. B.btn("sb", "Start / Stop SB") .. B.btn("sdb", "Start / Stop SDB (/sdb unverified)")
        return d .. B.foot("autosb", true)
    end,
    act = function(b, f)
        local t = chatClean(f.txt)
        if t and #t > 0 then Config.sbMsg = t end
        if b == "sb" or b == "sdb" then startJob(b) end
        showPage("autosb")
    end,
}

Pages.world = {sec = "world",
    build = function()
        local ok, w = pcall(GetWorld)
        local d = B.head("World", 6)
        if ok and type(w) == "table" then
            d = d .. B.tx(string.format("%s | %dx%d | %d tiles | %d objects", dsafe(w.name or "?"), w.width or 0, w.height or 0, w.tilecount or 0, w.objectcount or 0))
        else d = d .. B.tx("World info unavailable.") end
        local okp, pl = pcall(GetPlayerList)
        local n = 0
        if okp and type(pl) == "table" then
            for _, p in pairs(pl) do
                n = n + 1
                if n <= 15 and p.pos then d = d .. B.tx(string.format("%s | net %s | uid %s | tile %d,%d", plain(p.name), tostring(p.netid), tostring(p.userid), p.pos.x // 32, p.pos.y // 32)) end
            end
        end
        d = d .. B.tx("Other players: " .. n) .. B.btn("rejoin", "Rejoin world") .. B.btn("refresh", "Refresh")
        return d .. B.foot("world", true)
    end,
    act = function(b) if b == "rejoin" then local n = worldName(); if n then RequestJoinWorld(n) end else showPage("world") end end,
}

local LOGNAME = {collect = "Collect Logs", drop = "Drop Logs", inv = "Inventory Logs", spin = "Casino/Spin Logs", capture = "Capture (debug)"}
Pages.logs = {sec = "logs",
    build = function()
        local d = B.head("Logs & History", 2480) .. B.tog("lg", "Activity logging", Config.logging) .. B.tog("cap", "Packet capture (debug)", RT.cap)
        for _, k in ipairs({"collect", "drop", "inv", "spin", "capture"}) do d = d .. B.btn("v_" .. k, LOGNAME[k] .. " (" .. #Logs[k] .. ")") end
        return d .. B.btn("clear", "Clear all logs") .. B.foot("logs", true)
    end,
    act = function(b)
        if b == "lg" then setToggle("logging")
        elseif b == "cap" then RT.cap = not RT.cap; log("Capture: " .. onoff(RT.cap))
        elseif b == "clear" then for k in pairs(Logs) do Logs[k] = {} end
        elseif b:match("^v_") then RT.logKey = b:sub(3); showPage("loglist"); return end
        showPage("logs")
    end,
}
Pages.loglist = {back = "logs",
    build = function()
        local l = Logs[RT.logKey]
        local d = B.head(LOGNAME[RT.logKey], 2480)
        if #l == 0 then d = d .. B.tx("No entries.") end
        for i = math.max(1, #l - 39), #l do d = d .. B.tx(l[i]) end
        return d .. B.foot("loglist")
    end,
}

local function resetConfig() Config = newConfig(); log("Config reset to defaults (memory only).") end
Pages.setting = {
    build = function()
        local d = B.head("Core Proxy Settings", 1008) .. B.tx("Save Config / Reload Config: unavailable - the BotHax README documents no file read/write API, so settings live in memory only and reset when the script restarts.")
        d = d .. B.btn("reset", "Reset Config") .. B.btn("ids", "Check lock item ids") .. B.btn("unload", "Unload script")
        d = d .. B.tx("Queue: " .. #RT.queue .. " task(s) | Hooks: " .. #HOOK_LABELS .. " | Version " .. VERSION)
        return d .. B.foot("setting")
    end,
    act = function(b)
        if b == "reset" then resetConfig()
        elseif b == "ids" then for _, l in ipairs(resolveLocks()) do log(l) end
        elseif b == "unload" then
            RT.running = false
            for _, l in ipairs(HOOK_LABELS) do pcall(RemoveHook, l) end
            log("Unloaded."); return
        end
        showPage("setting")
    end,
}
Pages.info = {
    build = function()
        return B.head("DodgedProxy " .. VERSION, 6016) .. B.tx("Credits: dodged__ (dc.gg/dodged)")
            .. B.tx("Built from the BotHax README. Commands marked [T] use standard-protocol or unverified packets that need an in-game test. Use /capture + /capturelogs to record real packets.")
            .. B.foot("info")
    end,
}
local function naPage(key, title, why)
    Pages[key] = {build = function()
        return B.head(title, 32) .. B.tx("Unavailable: " .. why)
            .. B.tx("To help enable it: turn on Packet capture (All Logs), do the action by hand once, then read the capture log.") .. B.foot(key)
    end}
end
naPage("autofarm", "Auto Farm", "no verified punch/place packet layout or documented farm control names ([A] settings exist via ChangeValue but their names are not documented).")
naPage("autocook", "Auto Cook", "cooking dialogs/packets are not documented and unverified.")
naPage("autofish", "Auto Fish", "fishing packets are not documented and unverified.")
naPage("autosurg", "Auto Surgery", "surgery dialog and tool ids are unverified; the earlier guessed mapping was invented and has been removed.")
naPage("autocrime", "Auto Crime", "no documented mechanics or packets.")
naPage("autogeiger", "Auto Geiger", "no documented mechanics or packets.")
naPage("autoprovider", "Auto Provider", "no documented mechanics or packets.")
naPage("autobuypack", "Auto Buy Pack", "store/pack dialogs are unverified.")
naPage("magvend", "Mag & Vend", "magplant/vending dialog formats are unverified.")

showPage = function(key)
    local p = Pages[key]
    if not p then log("`4Unknown page " .. tostring(key)) return end
    showDialog(p.build())
end

-- ---------------------------------------------------------------- commands
section("system", "System & Tools"); section("general", "General Proxy Features"); section("economy", "Economy & Drop")
section("donate", "Smart Donation"); section("trade", "Advanced Trading"); section("tele", "Telephone Commands")
section("calc", "Smart Calculator"); section("casino", "Casino Modes"); section("wrench", "Wrench Controls")
section("autopull", "Auto Pull"); section("spam", "Auto-Spam"); section("sb", "Super Broadcast")
section("emoji", "Emoji & Color"); section("logs", "Logs & History"); section("itemdb", "Item Database")
section("world", "World"); section("btk", "BTK & BJ")

local function qty(a, usage)
    local n = toInt(a:match("^(%S+)"), 1, 100000000)
    if not n then log("`4Usage: " .. usage .. " (positive whole number)") end
    return n
end
local function rest(a) return (a:gsub("^%s+", ""):gsub("%s+$", "")) end

-- system
cmd("system", {"/menu", "/help"}, "/menu, /help", "Open main menu", "ok", function() showPage("main") end)
cmd("system", "/cmd", "/cmd", "Open command list", "ok", function() showPage("cmdlist") end)
cmd("system", "/settingmenu", "/settingmenu", "Open Setting menu", "ok", function() showPage("setting") end)
cmd("system", {"/imgui", "/proxy"}, "/imgui, /proxy", "Toggle read-only status panel (ImGui)", "partial", function()
    RT.imgui = not RT.imgui; log("ImGui panel: " .. onoff(RT.imgui)) end)
cmd("system", {"/g", "/ghost"}, "/g, /ghost", "Send /ghost to the server", "test", function() say("/ghost", 0) end)
cmd("system", "/res", "/res", "Respawn", "ok", function() send(2, PKT.respawn) end)
cmd("system", "/re", "/re", "Rejoin current world", "ok", function()
    local n = worldName(); if n then RequestJoinWorld(n) else log("`4World name unavailable.") end end)
cmd("system", "/relog", "/relog", "Reconnect (sends quit packet)", "test", function() send(3, PKT.quit) end)
cmd("system", "/unload", "/unload", "Remove hooks and stop the script", "ok", function() Pages.setting.act("unload") end)
cmd("system", "/lockids", "/lockids", "Print resolved lock item ids/names", "ok", function() for _, l in ipairs(resolveLocks()) do log(l) end end)
cmd("system", "/setphone", "/setphone <key> <digits|clear>", "Set a phone number (keys: " .. table.concat(PH_KEYS, ", ") .. ")", "ok", function(a)
    local k, v = a:match("^(%S+)%s+(%S+)$")
    if not k or not PH_LABEL[k] then log("`4Usage: /setphone <" .. table.concat(PH_KEYS, "|") .. "> <3-9 digits|clear>") return end
    if v == "clear" then Config.phones[k] = nil; log("Cleared " .. k) return end
    if v:match("^%d+$") and #v >= 3 and #v <= 9 then Config.phones[k] = v; log("Set " .. k .. " = " .. v) else log("`4Number must be 3-9 digits.") end
end)
cmd("system", "/capture", "/capture", "Toggle packet capture (debug)", "ok", function() RT.cap = not RT.cap; log("Capture: " .. onoff(RT.cap)) end)
cmd("system", "/capturelogs", "/capturelogs", "Show captured packets", "ok", function() RT.logKey = "capture"; showPage("loglist") end)

-- general
cmd("general", "/antilag", "/antilag", "Block weather/particle variants", "test", function() setToggle("antiLag") end)
cmd("general", "/antipickup", "/antipickup", "Block item pickup packets", "test", function() setToggle("antiPickup") end)
cmd("general", "/blocksdb", "/blocksdb", "Block SDB dialogs (text match)", "test", function() setToggle("blockSDB") end)
cmd("general", "/autocv", "/autocv", "Auto convert DL->BGL on collect", "test", function() setToggle("autoCV") end)
cmd("general", "/tp", "/tp", "Toggle Teleport Punch (Display/Vend)", "test", function() setToggle("tpunch") end)
cmd("general", "/modal", "/modal", "Show your total lock balance", "ok", function()
    local t = totalWL()
    if not t then log("`4Inventory unreadable.") return end
    log("Total balance: " .. fmt(t) .. " WL = " .. formatLocks(t))
end)
cmd("general", "/fastdrop", "/fastdrop", "Auto-confirm drop dialogs", "test", function() setToggle("fastDrop") end)
cmd("general", "/fasttrash", "/fasttrash", "Auto-confirm trash dialogs", "test", function() setToggle("fastTrash") end)
na("general", "/hidespammer", "/hidespammer", "Toggle Hide Spammer Slave", "feature semantics unknown")
na("general", "/vendfilter", "/vendfilter", "Format huge WL prices", "vending dialog format not verified")
na("general", "/donfilter", "/donfilter", "Show item icons in donation box", "donation dialog format not verified")
na("general", "/sboxfilter", "/sboxfilter", "Storage box take-all mode", "storage box dialog format not verified")

-- economy
cmd("economy", "/dw", "/dw <qty>", "Drop World Lock", "test", function(a) local n = qty(a, "/dw <qty>"); if n then queueDrop("wl", n) end end)
cmd("economy", "/dd", "/dd <qty>", "Smart drop in DL: DL, then BGL, then Black; never WL; exact or nothing", "test", function(a)
    local n = qty(a, "/dd <DL qty>"); if n then enqueue(function() smartDropTask(n) end, 300) end end)
cmd("economy", "/db", "/db <qty>", "Drop Blue Gem Lock", "test", function(a) local n = qty(a, "/db <qty>"); if n then queueDrop("bgl", n) end end)
cmd("economy", "/dbl", "/dbl <qty>", "Drop Black Gem Lock", "test", function(a) local n = qty(a, "/dbl <qty>"); if n then queueDrop("black", n) end end)
cmd("economy", "/daw", "/daw", "Drop all locks (inventory re-read before each drop)", "test", function()
    for _, k in ipairs(LK_ORDER) do queueDrop(k, "all") end end)
cmd("economy", "/blue", "/blue", "Convert Black GL to Blue GL (item activation)", "test", function() convertBlackToBGL() end)
cmd("economy", "/black", "/black", "Convert Blue GL to Black GL (needs /setphone black)", "test", function()
    dialPhone("black") end)
na("economy", "/depo", "/depo <qty>", "Deposit BGL to bank", "no verified bank API/dialog; the old version only changed a local variable, which was misleading")
na("economy", "/with", "/with <qty>", "Withdraw BGL from bank", "no verified bank API/dialog")

-- donate
cmd("donate", "/donatemenu", "/donatemenu", "Open donate menu", "ok", function() showPage("donate") end)
cmd("donate", "/dmode", "/dmode", "Toggle donation mode (wrench a box to set it)", "test", function() setToggle("dmode") end)
for _, d in ipairs({{"/pw", "wl", "World Lock"}, {"/pd", "dl", "Diamond Lock"}, {"/pb", "bgl", "Blue Gem Lock"}, {"/pbl", "black", "Black Gem Lock"}}) do
    cmd("donate", d[1], d[1] .. " <qty>", "Remote donate " .. d[3], "test", function(a)
        local n = qty(a, d[1] .. " <qty>"); if n then queueDonate(d[2], n) end end)
end
cmd("donate", "/pall", "/pall", "Donate all locks", "test", function() for _, k in ipairs(LK_ORDER) do queueDonate(k, "all") end end)
na("donate", "/takeall", "/takeall", "Retrieve all items from box", "take-all dialog not verified")

-- trade
cmd("trade", "/trademenu", "/trademenu", "Open trade menu", "ok", function() showPage("trade") end)
cmd("trade", "/tmode", "/tmode", "Toggle trade wrench mode", "test", function()
    Config.wrenchMode = (Config.wrenchMode == "trade") and "off" or "trade"; log("Wrench mode: " .. Config.wrenchMode) end)
for _, d in ipairs({{"/tw", "wl", "World Lock"}, {"/td", "dl", "Diamond Lock"}, {"/tb", "bgl", "Blue Gem Lock"}, {"/tbl", "black", "Black Gem Lock"}}) do
    cmd("trade", d[1], d[1] .. " <qty>", "Fast add " .. d[3] .. " to trade", "test", function(a)
        local n = qty(a, d[1] .. " <qty>"); if n then queueTrade(d[2], n) end end)
end
cmd("trade", "/tall", "/tall", "Fast add all locks to trade", "test", function() for _, k in ipairs(LK_ORDER) do queueTrade(k, "all") end end)
na("trade", "/tclear", "/tclear", "Clear locks from trade window", "no verified way to remove items from a trade")

-- telephone
cmd("tele", "/telemenu", "/telemenu", "Open telephone menu", "ok", function() showPage("tele") end)
cmd("tele", "/cvdl", "/cvdl", "Dial CV BGL number", "test", function() dialPhone("cvbgl") end)
cmd("tele", "/buybgl", "/buybgl", "Dial Buy BGL number (/setphone buybgl first)", "test", function() dialPhone("buybgl") end)
cmd("tele", "/buydl", "/buydl", "Dial Buy DL number (/setphone buydl first)", "test", function() dialPhone("buydl") end)
cmd("tele", "/buychamp", "/buychamp", "Dial Champagne (normal)", "test", function() dialPhone("champ") end)
cmd("tele", "/buychampbg", "/buychampbg", "Dial Champagne (black gems)", "test", function() dialPhone("champbg") end)
cmd("tele", "/buychampbulk", "/buychampbulk", "Dial Champagne bulk", "test", function() dialPhone("champbulk") end)

-- calculator
cmd("calc", "/calcmenu", "/calcmenu", "Open calculator menu", "ok", function() showPage("calc") end)
cmd("calc", "/calc", "/calc <formula>", "Calculate (+ - * / % ^ and parentheses)", "ok", function(a)
    local ok, r = evalMath(a)
    log(ok and (dsafe(a) .. " = " .. r) or ("`4Math error: " .. r))
end)

-- casino
cmd("casino", "/casinomenu", "/casinomenu", "Open casino menu", "ok", function() showPage("casino") end)
cmd("casino", "/allmode", "/allmode", "Toggle Reme+Leme+Qeme", "test", function()
    local m = Config.modes; local on = not (m.reme and m.qeme and m.leme)
    m.reme, m.qeme, m.leme = on, on, on; log("ALL modes: " .. onoff(on)) end)
cmd("casino", "/reme", "/reme", "Toggle Reme mode", "test", function() Config.modes.reme = not Config.modes.reme; log("REME: " .. onoff(Config.modes.reme)) end)
cmd("casino", "/qeme", "/qeme", "Toggle Qeme mode", "test", function() Config.modes.qeme = not Config.modes.qeme; log("QEME: " .. onoff(Config.modes.qeme)) end)
cmd("casino", "/leme", "/leme", "Toggle Leme mode (formula assumed = Reme, x3 label)", "partial", function() Config.modes.leme = not Config.modes.leme; log("LEME: " .. onoff(Config.modes.leme)) end)
na("casino", "/lemes", "/lemes", "Toggle Leme S mode", "formula unknown")
na("casino", "/ceme", "/ceme", "Toggle Ceme mode", "formula unknown")
na("casino", "/lewa", "/lewa <num>", "Set Lewa multiplier", "formula unknown")
cmd("casino", "/cf", "/cf", "Local coinflip (not a game result)", "ok", function() log("Coinflip (local random): " .. (math.random(2) == 1 and "Heads" or "Tails")) end)
cmd("casino", "/dice", "/dice", "Local dice roll (not a game result)", "ok", function() log("Dice (local random): " .. math.random(6)) end)

-- wrench
cmd("wrench", "/wrenchmenu", "/wrenchmenu", "Open wrench menu", "ok", function() showPage("wrench") end)
for _, d in ipairs({{"pull", "/wrp", "/wrps"}, {"kick", "/wrk", "/wrks"}, {"ban", "/wrb", "/wrbs"}, {"trade", "/wrt", "/wrts"}}) do
    cmd("wrench", d[2], d[2], "Wrench = " .. d[1] .. " (one player per click)", "test", function()
        Config.wrenchMode = (Config.wrenchMode == d[1]) and "off" or d[1]; log("Wrench mode: " .. Config.wrenchMode) end)
    na("wrench", d[3], d[3], "Right-click variant of " .. d[2], "right-click is not exposed by the documented hooks")
end
na("wrench", "/showbal", "/showbal", "Fast balance on inspect", "CPS wrench dialog format not verified")

-- auto pull
cmd("autopull", "/autopullmenu", "/autopullmenu", "Open Auto Pull menu", "ok", function() showPage("autopull") end)
cmd("autopull", "/autopull", "/autopull", "Toggle Auto Pull", "test", function() setToggle("autoPull") end)
cmd("autopull", "/posautopull", "/posautopull", "Trigger tile = your tile", "test", function()
    local x, y = myTile(); if x then Config.apTarget = {kind = "tile", x = x, y = y}; log("Auto Pull trigger = " .. x .. "," .. y) else log("`4Cannot read position.") end end)
cmd("autopull", "/clearposautopull", "/clearposautopull", "Trigger tile = White Door", "test", function() Config.apTarget = {kind = "door"}; log("Auto Pull trigger = White Door") end)
cmd("autopull", "/apblacklist", "/apblacklist add|remove <uid> | list", "Manage blacklist", "ok", function(a)
    local sub, uid = a:match("^(%S+)%s*(%S*)")
    if sub == "list" then
        local t = {}; for k in pairs(Config.apBlack) do t[#t + 1] = k end
        log("Blacklist: " .. (#t > 0 and table.concat(t, ", ") or "(empty)"))
    elseif (sub == "add" or sub == "remove") and toInt(uid, 1) then
        Config.apBlack[tostring(toInt(uid, 1))] = (sub == "add") or nil; log(sub .. " " .. uid .. " done.")
    else log("`4Usage: /apblacklist add <uid> | remove <uid> | list") end
end)

-- spam / broadcast (bounded, user-started)
cmd("spam", "/spammenu", "/spammenu", "Open spam menu", "ok", function() showPage("autospam") end)
cmd("spam", "/spam", "/spam [count]", "Start/stop a bounded spam run (max " .. SPAM_MAX_RUN .. ", " .. SPAM_GAP_MS // 1000 .. "s apart)", "partial", function(a) startJob("spam", a:match("^(%S+)")) end)
cmd("spam", "/addspam", "/addspam <txt>", "Add a spam message", "ok", function(a)
    local t = chatClean(a); if t and chatOK(t) then table.insert(Config.spamMsgs, t); log("Added spam #" .. #Config.spamMsgs) else log("`4Message empty or too long.") end end)
cmd("spam", "/removespam", "/removespam", "Remove last spam message", "ok", function() table.remove(Config.spamMsgs); log("Removed last spam message.") end)
cmd("spam", "/spamtext", "/spamtext <num> <txt>", "Edit a spam line", "ok", function(a)
    local n, t = a:match("^(%d+)%s+(.+)$"); n = toInt(n, 1); t = t and chatClean(t)
    if n and Config.spamMsgs[n] and t and chatOK(t) then Config.spamMsgs[n] = t; log("Edited spam #" .. n) else log("`4Usage: /spamtext <num> <txt>") end end)
cmd("sb", "/sbmenu", "/sbmenu", "Open SB/SDB menu", "ok", function() showPage("autosb") end)
cmd("sb", "/sbstart", "/sbstart [count]", "Start bounded SB run (max " .. SB_MAX_RUN .. ", " .. SB_GAP_MS // 1000 .. "s apart)", "test", function(a)
    if not RT.job.sb then startJob("sb", a:match("^(%S+)")) else log("SB already running; use /sbstop.") end end)
cmd("sb", "/sbstop", "/sbstop", "Stop SB run", "ok", function() RT.job.sb = nil; log("SB stopped.") end)
cmd("sb", "/sdbstart", "/sdbstart [count]", "Start bounded SDB run (/sdb syntax unverified)", "test", function(a)
    if not RT.job.sdb then startJob("sdb", a:match("^(%S+)")) else log("SDB already running; use /sdbstop.") end end)
cmd("sb", "/sdbstop", "/sdbstop", "Stop SDB run", "ok", function() RT.job.sdb = nil; log("SDB stopped.") end)
cmd("sb", "/sbmsg", "/sbmsg <txt>", "Set SB/SDB message", "ok", function(a)
    local t = chatClean(a); if t and #t > 0 and chatOK(t) then Config.sbMsg = t; log("SB message set.") else log("`4Message empty or too long.") end end)
cmd("spam", "/spamstop", "/spamstop", "Stop any running spam/SB/SDB job", "ok", function() RT.job = {}; log("All broadcast jobs stopped.") end)

-- emoji
cmd("emoji", "/emojimenu", "/emojimenu", "Open emoji menu", "ok", function() showPage("emoji") end)
cmd("emoji", "/emoji", "/emoji", "Toggle random chat emojis", "test", function() setToggle("emoji") end)
cmd("emoji", "/watermark", "/watermark", "Toggle chat watermark", "test", function() setToggle("watermark") end)
cmd("emoji", "/textcolor", "/textcolor", "Toggle random text color", "test", function() setToggle("randColor") end)
cmd("emoji", "/encryptchat", "/encryptchat", "Toggle Encrypt Chat (Encrypt() output unverified)", "test", function() setToggle("encrypt") end)

-- logs
cmd("logs", "/logsmenu", "/logsmenu", "Open logs menu", "ok", function() showPage("logs") end)
cmd("logs", "/logs", "/logs", "Toggle activity logging", "ok", function() setToggle("logging") end)
cmd("logs", "/clogs", "/clogs", "Collect logs", "test", function() RT.logKey = "collect"; showPage("loglist") end)
cmd("logs", "/dlogs", "/dlogs", "Drop logs", "ok", function() RT.logKey = "drop"; showPage("loglist") end)
cmd("logs", "/invlogs", "/invlogs", "Inventory (lock) change logs", "ok", function() RT.logKey = "inv"; showPage("loglist") end)
cmd("logs", "/slogs", "/slogs", "Casino/spin logs", "test", function() RT.logKey = "spin"; showPage("loglist") end)

-- item database / world / btk
cmd("itemdb", "/item", "/item <name|id>", "Search the item database", "ok", function(a)
    RT.itemRes = itemSearch(a); for _, l in ipairs(RT.itemRes) do log(l) end end)
cmd("world", "/world", "/world", "Open world info page", "ok", function() showPage("world") end)
for _, g in ipairs({"btk", "bj"}) do
    local other = (g == "btk") and "bj" or "btk"
    cmd("btk", {"/" .. g .. "menu"}, "/" .. g .. "menu", "Open host panel", "ok", function() Config.host.mode = g; showPage("btk") end)
    cmd("btk", {"/" .. g .. "cmd"}, "/" .. g .. "cmd", "Open BTK/BJ command list", "ok", function() RT.sec = "btk"; showPage("cmdsec") end)
    cmd("btk", "/" .. g, "/" .. g, "Switch game mode to " .. g:upper(), "ok", function() Config.host.mode = g; log("Game mode: " .. g:upper()) end)
    for _, f in ipairs({{"center", "Host Center"}, {"posbet1", "Bet Player 1", "bet1"}, {"posbet2", "Bet Player 2", "bet2"}}) do
        local field = f[3] or f[1]
        cmd("btk", "/" .. g .. f[1], "/" .. g .. f[1], "Punch/touch to set " .. f[2] .. " tile", "test", function()
            Config.host.mode = g; RT.pick = {field = field, mode = g, expires = RT.tick + 600}; log("Punch or touch the tile now (30 seconds).") end)
    end
    cmd("btk", "/" .. g .. "bet", "/" .. g .. "bet", "Total dropped locks on bet tiles and tax", "test", function()
        Config.host.mode = g; RT.betLines = betReport(); for _, l in ipairs(RT.betLines) do log(l) end end)
    for _, f in ipairs({{"remote", "magplant remote collect"}, {"gems", "gem check / winner"}, {"drop", "prize drop"},
        {"posbreak1", "break P1 tile"}, {"posbreak2", "break P2 tile"}, {"tax", "tax drop tile"}, {"mag", "magplant tile"}}) do
        na("btk", "/" .. g .. f[1], "/" .. g .. f[1], f[2], "game mechanics/packets not verifiable with the documented API")
    end
end

-- ---------------------------------------------------------------- hooks
local function capLog(tag, text)
    if not RT.cap then return end
    text = tostring(text):gsub("\n", "\\n")
    pushLog("capture", stamp() .. " " .. tag .. ": " .. text:sub(1, 300))
end

local function decorate(text)
    local out = text
    if Config.randColor then out = "`" .. math.random(1, 9) .. out end
    if Config.emoji then out = out .. " " .. EMOJIS[math.random(#EMOJIS)] end
    if Config.watermark then out = out .. " [DodgedProxy]" end
    if Config.encrypt then
        local ok, enc = pcall(Encrypt, out)                  -- [DOC] output format unverified
        if ok and type(enc) == "string" and enc:match("^[%g ]+$") then out = enc else return nil end
    end
    if #out > CHAT_MAX then return nil end
    return out
end

local function parseFields(pkt)
    local f = {}
    for line in pkt:gmatch("[^\n]+") do
        local k, v = line:match("^([^|]+)|(.*)$")
        if k then f[k] = v end
    end
    return f
end

local function handlePick(x, y)
    local pk = RT.pick
    RT.pick = nil
    if not pk or RT.tick > pk.expires then return end
    Config.host[pk.mode][pk.field] = {x = x, y = y}
    log(pk.mode:upper() .. " " .. pk.field .. " tile set to " .. x .. "," .. y)
    showPage("btk")
end

addHook("OnSendPacket", "DP_Send", function(ptype, pkt)                 -- [DOC] (type, packet-string)
    if type(pkt) ~= "string" then return false end
    local dname = pkt:match("dialog_name|(dp_[%w_]+)")
    if dname then                                                         -- clicks on OUR dialogs never reach the server
        local page = dname:sub(4)
        local f = parseFields(pkt)
        local b = f.buttonClicked
        local p = Pages[page]
        if b == "back" then showPage((p and p.back) or "main")
        elseif b == "lc" and p and p.sec then RT.sec = p.sec; showPage("cmdsec")
        elseif b and b ~= "" and p and p.act then
            local ok, err = pcall(p.act, b, f)
            if not ok then log("`4UI error: " .. tostring(err)) end
        end
        return true
    end
    capLog("OUT" .. tostring(ptype), pkt)

    local text = pkt:match("action|input\n|text|([^\n]*)")
    if text then
        local exp = RT.selfSent[text]
        if exp and exp >= RT.tick then RT.selfSent[text] = nil; return false end   -- our own message
        if text:sub(1, 1) == "/" then
            local name, args = text:match("^(/%S+)%s*(.*)$")
            local e = name and CMD[name:lower()]
            if e then
                local ok, err = pcall(e.fn, rest(args or ""))
                if not ok then log("`4Error in " .. name .. ": " .. tostring(err)) end
                return true
            end
            return false
        end
        if Config.randColor or Config.emoji or Config.watermark or Config.encrypt then
            local out = decorate(text)
            if out and out ~= text then enqueue(function() sayRaw(out) end, 150); return true end
        end
        return false
    end

    if pkt:find("action|wrench", 1, true) then
        local nid = toInt(pkt:match("|netid|(%d+)"))
        if nid then
            local okm, me = pcall(GetLocal)
            if Config.wrenchMode ~= "off" and not (okm and me and me.netid == nid) and RT.tick - RT.wlast >= 20 then
                RT.wlast = RT.tick
                RT.wpend = {mode = Config.wrenchMode, nid = nid, due = RT.tick + 80}
            end
        elseif Config.dmode then
            local x, y = toInt(pkt:match("|x|(%d+)")), toInt(pkt:match("|y|(%d+)"))
            if x and y then
                if tileName(x, y):find("donation", 1, true) then
                    RT.donBox, RT.donWorld = {x = x, y = y}, worldName(); log("Donation box set at " .. x .. "," .. y)
                else log("`4That tile is not a Donation Box.") end
            end
        end
    end
    return false
end)

addHook("OnSendPacketRaw", "DP_Raw", function(p)                         -- [DOC] (packet table)
    if type(p) ~= "table" then return false end
    if RT.cap and p.type ~= 0 then capLog("RAW", "type=" .. tostring(p.type) .. " value=" .. tostring(p.value) .. " px=" .. tostring(p.px) .. " py=" .. tostring(p.py)) end
    if Config.antiPickup and p.type == 11 then return true end            -- [STD] type 11 = object pickup
    if p.type == 3 and p.value == 18 then                                 -- [DOC] type 3 = punch/place; 18 = fist [STD]
        local x, y = p.px or p.tx or p.int_x, p.py or p.ty or p.int_y     -- [DOC] field aliases
        if x and y then
            if RT.pick then handlePick(x, y); return true end
            if Config.phoneArmed and tileName(x, y):find("telephone", 1, true) then dialPhone(Config.phoneArmed, x, y); return true end
            if Config.tpunch then
                local n = tileName(x, y)
                if n:find("display", 1, true) or n:find("vending", 1, true) then teleportTo(x, y); return true end
            end
        end
    end
    return false
end)

addHook("OnWorldTouch", "DP_Touch", function(pos, start)                  -- [DOC]
    if RT.pick and start and type(pos) == "table" then
        handlePick(math.floor(pos.x / 32), math.floor(pos.y / 32))
        return true
    end
    return false
end)

local function handleDialog(a)
    if a:find("end_dialog|dp_", 1, true) then return false end            -- our own dialogs
    if Config.blockSDB and a:lower():find("super duper", 1, true) then return true end   -- [UNV] text match
    if capLog then capLog("IN dlg", a) end

    local wp = RT.wpend
    if wp and RT.tick <= wp.due then
        local did = tonumber(a:match("embed_data|netID|(%-?%d+)") or a:match("netID|(%-?%d+)"))
        if did == wp.nid then
            RT.wpend = nil
            local btn = WRENCH_BTN[wp.mode]
            if btn and a:find("add_button|" .. btn .. "|", 1, true) then
                local nid, mode = wp.nid, wp.mode
                enqueue(function()
                    SendPacket(2, PKT.wrenchBtn(nid, btn))
                    log("Wrench " .. mode .. " sent for " .. playerName(nid) .. " (server result not verified).")
                    if Config.wrenchChat and Config.wrenchText[mode] then
                        local name = playerName(nid)
                        say((Config.wrenchText[mode]:gsub("{GrowID}", function() return name end)), 400)
                    end
                end, 300)
                return true
            end
            log("`4Wrench dialog has no '" .. tostring(btn) .. "' button (no permission?).")
            return false
        end
    end

    if RT.tick <= RT.dropUntil and a:find("end_dialog|drop_item|", 1, true) then return true end   -- our own drop
    if Config.fastDrop and a:find("end_dialog|drop_item|", 1, true) then
        local id, cnt = toInt(a:match("embed_data|itemID|(%d+)")), toInt(a:match("add_text_input|count||(%d+)|"))
        if id and cnt and cnt <= (invCount(id) or 0) then send(2, PKT.dropOK(id, cnt), 100); return true end
    end
    if Config.fastTrash and a:find("end_dialog|trash_item|", 1, true) then
        local id, cnt = toInt(a:match("embed_data|itemID|(%d+)")), toInt(a:match("add_text_input|count||(%d+)|"))
        if id and cnt and cnt <= (invCount(id) or 0) then send(2, PKT.trashOK(id, cnt), 100); return true end
    end
    return false
end

addHook("OnVariant", "DP_Var", function(var, netid, delay)               -- [DOC]
    local fn, a = var[0], var[1]
    if Config.antiLag and (fn == "OnSetCurrentWeather" or fn == "OnParticleEffect") then return true end   -- [STD] names
    if fn == "OnStartTrade" then RT.trading = true elseif fn == "OnForceTradeEnd" then RT.trading = false end -- [STD] names
    if fn == "OnDialogRequest" and type(a) == "string" then return handleDialog(a) end
    local msg = (fn == "OnConsoleMessage" and a) or (fn == "OnTalkBubble" and var[2]) or nil
    if type(msg) == "string" then
        local text = plain(msg)
        local x = toInt(text:match("spun the wheel and got (%d+)"))        -- phrase supplied by the user
        if x then
            pushLog("spin", stamp() .. " " .. text)
            local r, m = (x // 10 + x % 10) % 10, Config.modes
            if m.reme then log("REME: " .. x .. " -> " .. r) end
            if m.leme then log("LEME: " .. x .. " -> " .. r .. " [X3]") end
            if m.qeme then log("QEME: " .. x .. " -> " .. (x % 10)) end
        end
        if fn == "OnConsoleMessage" and text:find("Collected", 1, true) then pushLog("collect", stamp() .. " " .. text) end
    end
    return false
end)

addHook("OnDraw", "DP_Draw", function(dt)                                -- [DOC] ImGui.Begin/Text/End only
    if not RT.imgui or ImGui == nil then return end
    if ImGui.Begin("DodgedProxy " .. VERSION) then
        ImGui.Text("Queue: " .. #RT.queue .. " | Wrench: " .. Config.wrenchMode .. " | AutoPull: " .. onoff(Config.autoPull))
        ImGui.Text("Spam: " .. jobStatus("spam") .. " | SB: " .. jobStatus("sb") .. " | SDB: " .. jobStatus("sdb"))
        local t = totalWL()
        ImGui.Text("Balance: " .. (t and formatLocks(t) or "unreadable"))
    end
    ImGui.End()
end)

-- ---------------------------------------------------------------- main loop
local function onTick()
    -- 1) queue (a task may Sleep; nothing else is blocked for long)
    if RT.idle > 0 then RT.idle = RT.idle - 1
    elseif #RT.queue > 0 then
        local t = table.remove(RT.queue, 1)
        local ok, err = pcall(t.fn)
        if not ok then log("`4Task error: " .. tostring(err)) end
        RT.idle = t.after
    end
    -- 2) timers
    local i = 1
    while i <= #RT.timers do
        local t = RT.timers[i]
        if RT.tick >= t.due then table.remove(RT.timers, i); pcall(t.fn) else i = i + 1 end
    end
    -- 3) bounded jobs, auto pull, inventory log / auto CV, housekeeping
    tickJobs()
    if Config.autoPull and RT.tick % 20 == 0 then autoPullScan() end
    if RT.tick % 40 == 0 then
        local s = snap()
        if s then
            if RT.lastSnap then
                local d = diffStr(RT.lastSnap, s)
                if d then
                    pushLog("inv", stamp() .. " " .. d)
                    if Config.autoCV and s.dl > RT.lastSnap.dl and s.dl >= DL_PER_BGL and RT.tick - RT.lastCV > 200 then
                        RT.lastCV = RT.tick; dialPhone("cvbgl")
                    end
                end
            end
            RT.lastSnap = s
        end
    end
    if RT.tick % 200 == 0 then
        for k, v in pairs(RT.selfSent) do if v < RT.tick then RT.selfSent[k] = nil end end
        for k, v in pairs(RT.pulled) do if v < RT.tick then RT.pulled[k] = nil end end
    end
end

for _, l in ipairs(resolveLocks()) do log(l) end
log("v" .. VERSION .. " loaded. Type /menu or /cmd.")

while RT.running do                  -- keeps the hooks alive (README: hooks live while the script runs)
    RT.tick = RT.tick + 1
    local ok, err = pcall(onTick)
    if not ok then LogToConsole("`4[DodgedProxy] tick error: " .. tostring(err)) end
    Sleep(TICK_MS)                   -- [DOC]
end
