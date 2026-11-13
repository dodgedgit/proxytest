-- ========================================================================
-- WinProxy (Win Community) - decoded + reformatted
-- Only whitespace/comments were changed; every token is identical to the original.
-- Identifiers are still the original minified names (P, j, Y, X, ...).
-- 
-- SECTION 1: Bootstrap - platform flag, local player, auth/webhook URLs
-- ========================================================================

local P = os.getenv("LOCALAPPDATA") ~= nil
local j = GetLocal()
local Y = j and j.userid or 0
local X = j and j.name or "Unknown"
local M = "https://pastebin.com/raw/zHh7f96c"
local z = "https://raw.githubusercontent.com/LansGameTry/WinProxyCPS/main/uids.txt"
local o = "https://discord.com/api/webhooks/1537105388065923152/ugQPkQgzr331bnqPrYc4NxMXMPUGiwaw6H_mBTbbZ14ABEMzLjNhd4JIU0QFObOD1Yva"

local function q(P)
    if not P then
        return "Unknown"
    end
    local j = P:gsub("(`.)", "")
    j = j:gsub("%s+", " ")
    j = j:match("^%s*(.-)%s*$") or "Unknown"
    return j
end

function SendAuthNotification(P)
    if o == "" then
        return
    end
    local j = GetLocal()
    if not j then
        return
    end
    local Y = q(j.name)
    local X = j.userid or "Unknown"
    local M = GetWorld() and (GetWorld()).name or "Unknown"
    local z = os.date("%Y-%m-%d %H:%M:%S")
    local S = os.date("%A, %B %d, %Y")
    local W = (P:lower()):find("denied") or (P:lower()):find("failed")
    local O = W and 16711680 or 5763719
    local V = W and "<a:Wrong:1456306199195816089>" or "<a:Correct:1456306220796215402>"
    local e = V .. (" Script Status: " .. P)
    RunThread(function()
        local P = ""
        pcall(function()
            local j = MakeRequest("https://api.ipify.org?format=text", "GET")
            if type(j) == "string" then
                P = j:gsub("%s+", "")
            end
        end)
        local j = string.format("{\n            \"username\": \"WinProxy Monitor\",\n            \"avatar_url\": \"https://cdn.discordapp.com/attachments/1438466585005391923/1481856877410390157/WinPFP-Animated.gif\",\n            \"embeds\": [{\n                \"title\": \"%s\",\n                \"color\": %d,\n                \"fields\": [\n                    {\"name\": \"<:Profile:1487287110057594900> GrowID\", \"value\": \"```%s```\", \"inline\": true},\n                    {\"name\": \"<a:Crown:1456306230850093260> UserID\", \"value\": \"```%s```\", \"inline\": true},\n                    {\"name\": \"<a:World:1456376942189346947> World\", \"value\": \"```%s```\", \"inline\": true},\n                    {\"name\": \"<:Date:1537108777990365254> Date\", \"value\": \"```%s```\", \"inline\": true},\n                    {\"name\": \"<a:Clock:1479679771116966040> Time\", \"value\": \"```%s```\", \"inline\": true},\n                    {\"name\": \"\240\159\140\144 IP Address\", \"value\": \"```%s```\", \"inline\": false}\n                ],\n                \"footer\": {\"text\": \"WinProxy \226\128\162 Auto Notification\", \"icon_url\": \"https://cdn.discordapp.com/emojis/1481856719230603354.webp\"}\n            }]\n        }", e, O, Y, X, M, S, z, P)
        MakeRequest(o, "POST", { ["Content-Type"] = "application/json" }, j)
    end)
end

local function S()
    local P, j = pcall(GetLocal)
    if not P or not j then
        return false
    end
    local Y = tonumber(j.userid or j.netID or 0)
    if Y == 0 then
        return false
    end
    LogToConsole("`c[WinProxy]: `wChecking authorization for UID: `2" .. (" " .. tostring(Y)))
    local X, M = pcall(MakeRequest, z, "GET")
    if not X or not M then
        LogToConsole("`c[WinProxy]: `wFailed to connect to authorization server!")
        return false
    end
    if type(M) == "table" then
        if type(M.body) == "string" then
            M = M.body
        elseif type(M.content) == "string" then
            M = M.content
        else
            LogToConsole("`c[WinProxy]: `wUnexpected authorization response type: " .. type(M))
            return false
        end
    end
    if type(M) ~= "string" or M == "" then
        LogToConsole("`c[WinProxy]: `wFailed to connect to authorization server!")
        return false
    end
    for P in M:gmatch("[^\r\n]+") do
        local j = P:match("^%s*(%d+)")
        if j and tonumber(j) == Y then
            return true
        end
    end
    return false
end

-- ========================================================================
-- SECTION 2: Authorization gate (UID whitelist check, exits if not listed)
-- ========================================================================

if not S(Y) then
    local P = "`4[WinProxy]: `wUID `4" .. (tostring(Y) .. " `wis NOT verified! Script terminated.")
    LogToConsole(P)
    SendAuthNotification("Access Denied")
    return
end

LogToConsole("`c[WinProxy]: `2Authorized user: " .. X)
LogToConsole("`c[WinProxy]: `b[ImGui]  `wUse `b/imgui `wto show or hide ImGui Menu")
LogToConsole("`c[WinProxy]: `b[Dialog] `wUse `b/menu `wto show or hide Dialog Menu.")

-- ========================================================================
-- SECTION 3: Shared state table W and default settings
-- ========================================================================

local W = {}
if P then
    W.ConfigFileName = "WinCommunity_Config.txt"
    local P = os.getenv("LOCALAPPDATA") or (os.getenv("USERPROFILE") .. "\\AppData\\Local")
    W.BannerSavePath = P .. "\\Growtopia\\interface\\large\\WinProxyBanner.rttex"
else
    W.ConfigFileName = "WinCommunity_Config.txt"
    W.BannerSavePath = "WinProxyBanner.rttex"
end

W.BannerURL = "https://raw.githubusercontent.com/LansGameTry/WinProxyCPS/main/WinProxyBanner.rttex"
W.BannerDialogPath = "interface/large/WinProxyBanner.rttex"
W.ShowImGui = true
W.CurrentTab = utf8.char(61461) .. " Welcome"
W.TitlesState = {
    Loaded = false;
    GpmMode = 1;
    Standard = {
        {
            key = "LegendaryStatusHidden", name = "Legendary Title"; relog = false, enabled = false
        },
        { key = "MaxLevelStatusHidden", name = "Level 125 Title"; relog = true; enabled = false };
        { key = "DonorStatusHidden", name = "MVP+ Title", relog = true; enabled = false };
        { key = "DoctorStatusHidden", name = "Doctor Title"; relog = true, enabled = false };
        { key = "MaxStatusHidden", name = "Max Title", relog = false, enabled = false };
        { key = "MentorStatusHidden"; name = "Mentor Title", relog = true; enabled = false }
    },
    Custom = {}
}
W.TitlesAwaitingSelfPopup = false
W.FetchingTitlesSilent = false
W.Tabs = {
    utf8.char(61461) .. " Welcome", utf8.char(61728) .. " Commands", utf8.char(61459) .. " General",
    utf8.char(61613) .. " Wrench", utf8.char(62656) .. " Donate", utf8.char(62133) .. " Trade"; utf8.char(61589) .. " Telephone",
    utf8.char(62783) .. " Text & Skin"; utf8.char(61932) .. " Calculator", utf8.char(61442) .. " Item Database",
    utf8.char(61548) .. " Auto PTHT"; utf8.char(61548) .. " Auto PNB", utf8.char(61685) .. " Auto Cook";
    utf8.char(62840) .. " Auto Fish"; utf8.char(61690) .. " Auto Surg"; utf8.char(61979) .. " Auto Crime",
    utf8.char(61956) .. " Auto Geiger"; utf8.char(61548) .. " Auto Provider", utf8.char(61548) .. " Auto Combine";
    utf8.char(61562) .. " Auto Buy Pack", utf8.char(61923) .. " Casino", utf8.char(61723) .. " BTK/BJ";
    utf8.char(61465) .. " Auto Pull"; utf8.char(62006) .. " AFK"; utf8.char(62637) .. " Auto Spam", utf8.char(61601) .. " Auto SB & SDB",
    utf8.char(62096) .. " Magplant", utf8.char(62097) .. " Vending", utf8.char(61612) .. " World"; utf8.char(61483) .. " Title",
    utf8.char(61474) .. " All Logs"; utf8.char(61948) .. " Theme & UI", utf8.char(61573) .. " Setting";
    utf8.char(61530) .. " Information"
}
W.CustomCommands = {}
W.TempCust = ""
W.TempOrig = ""
W.AntiLag = false
W.HideSpammer = false
W.AntiPickup = false
W.Modfly = false
W.DialogBg = nil
W.DialogBorder = nil
W.AntiPortal = false
W.NightVision = false
W.BankBalance = 0
W.BlockSDB = true
W.BlockSB = false
W.AutoCVLocks = false
W.IsAutoCVRunning = false
W.TPDisplay = false
W.WrenchMode = 0
W.WrenchModeRight = 0
W.WrenchPullText = ""
W.WrenchKickText = ""
W.WrenchBanText = ""
W.MagFindID = "1656"
W.MagDelay = 150
W.MagFromWorld = ""
W.MagFromX = "0"
W.MagFromY = "0"
W.MagTargetX = "0"
W.MagTargetY = "0"
W.MagDropWorld = ""
W.MagDropX = "0"
W.MagDropY = "0"
W.MagSetMode = "walk"
W.MagAutoWalk = false
W.MagSelectingTarget = false
W.MagSelectingFrom = false
W.MagSelectingDrop = false
W.MagFromY = "0"
W.MagRunning = false
W.MagMode = ""
W.MagDone = false
W.MagX = 0
W.MagY = 0
W.MagM2MTakeWorld = ""
W.MagM2MTakeX = "0"
W.MagM2MTakeY = "0"
W.MagM2MPutWorld = ""
W.MagM2MPutX = "0"
W.MagM2MPutY = "0"
W.MagM2MAutoMove = false
W.MagSelectingM2MTake = false
W.MagSelectingM2MPut = false
W.MagSelectID = nil
W.VendFindID = "1656"
W.VendDelay = 150
W.VendFromWorld = ""
W.VendFromX = "0"
W.VendFromY = "0"
W.VendTargetX = "0"
W.VendTargetY = "0"
W.VendDropWorld = ""
W.VendDropX = "0"
W.VendDropY = "0"
W.VendSetMode = "walk"
W.VendAutoWalk = false
W.VendSelectingTarget = false
W.VendSelectingFrom = false
W.VendSelectingDrop = false
W.VendRunning = false
W.VendMode = ""
W.VendDone = false
W.VendX = 0
W.VendY = 0
W.VendM2MTakeWorld = ""
W.VendM2MTakeX = "0"
W.VendM2MTakeY = "0"
W.VendM2MPutWorld = ""
W.VendM2MPutX = "0"
W.VendM2MPutY = "0"
W.VendM2MAutoMove = false
W.VendSelectingM2MTake = false
W.VendSelectingM2MPut = false
W.VendSelectID = nil
W.VendPrice = "1"
W.VendPriceMode = "peritem"
W.DonateMode = false
W.DonateBoxX = 0
W.DonateBoxY = 0
W.DonateAmount = 1
W.TradeAddAmount = 1
W.TradeTargetName = "None"
W.TradeTargetUID = 0
W.TeleMode = 0
W.TeleChampCurrency = 0
W.TeleChampAmount = 1
W.TeleDialogBlockTime = 0
W.EnableColor = false
W.EnableEmoji = false
W.WatermarkMode = true
W.EncryptChat = false
W.EncryptKey = "WINCOMMUNITY.CO"
W.SelectedColorIdx = 2
W.SelectedEmojiIdx = 2
W.ColorNames = {
    "Default", "Random"; "White", "Light Gray"; "Med Grey"; "Dark Grey"; "Black", "Light Cyan"; "Vibrant Cyan";
    "Bright Cyan", "Light Blue"; "Medium Blue"; "Dark Blue"; "Pale Green"; "Light Green", "Medium Green";
    "Green", "Pale Yellow", "Yellow"; "Dreamsicle", "Crazy Orange"; "Very Pale Pink"; "Pink", "Bright Red/Pink";
    "Crazy Red", "Pinky Purple"; "Bright Purple"; "Brown"
}
W.ColorValues = {
    "`0"; "RANDOM"; "`w"; "`7", "`s"; "`a", "`b", "`1", "`c", "`!", "`3"; "`e", "`q"; "`r", "`^"; "`t",
    "`2"; "`$", "`9"; "`o", "`8"; "`&"; "`p"; "`@", "`4"; "`5"; "`#", "`6"
}
W.EmojiNames = {
    "None"; "Random", "Agree", "Alien", "Broken Heart", "Build", "Bunny", "Cactus"; "Cake", "Clapping Hands",
    "Cool"; "Cry"; "Dance"; "Evil Devil"; "Eyes"; "Fireworks", "Football"; "Gems", "Ghost"; "Gift"; "Grin";
    "Grow", "Growtoken"; "Halo", "Heart", "Heart Arrow", "Ill", "Kiss"; "Lol", "Love"; "Lucky"; "Mad",
    "Megaphone", "Moyai"; "Music"; "No"; "Nuke", "Oops"; "Party"; "Peace", "Pineapple"; "Pizza", "Plead";
    "Punch"; "See No Evil"; "Shamrock"; "Shy"; "Sigh"; "Sleep", "Smile", "Songpyeon", "Terror", "Tongue";
    "Troll"; "Turkey", "Vend"; "Weary"; "Wink", "World Lock"; "Wow"; "Yes"
}
W.EmojiValues = {
    ""; "RANDOM"; "(agree)", "(alien)"; "(bheart)", "(build)"; "(bunny)", "(cactus)"; "(cake)"; "(clap)";
    "(cool)"; "(cry)"; "(dance)", "(evil)"; "(eyes)", "(fireworks)"; "(football)"; "(gems)"; "(ghost)";
    "(gift)"; "(grin)", "(grow)"; "(gtoken)"; "(halo)"; "(heart)"; "(heartarrow)", "(ill)", "(kiss)",
    "(lol)"; "(love)"; "(lucky)"; "(mad)"; "(megaphone)", "(moyai)", "(music)"; "(no)", "(nuke)"; "(oops)",
    "(party)"; "(peace)"; "(pine)", "(pizza)", "(plead)", "(punch)", "(see-no-evil)", "(shamrock)", "(shy)",
    "(sigh)", "(sleep)", "(smile)"; "(song)"; "(terror)"; "(tongue)", "(troll)"; "(turkey)"; "(vend)",
    "(weary)", "(wink)"; "(wl)", "(wow)"; "(yes)"
}
W.RandomColorList = {
    "`1"; "`2"; "`3"; "`4"; "`5", "`6", "`7"; "`8"; "`9", "`b", "`c", "`e", "`w"; "`o", "`p", "`q"; "`r";
    "`t"; "`a"; "`s"
}
W.RandomEmojiList = {
    "(sigh)", "(mad)", "(smile)"; "(tongue)", "(wow)", "(no)", "(shy)", "(wink)"; "(music)"; "(lol)",
    "(yes)"; "(love)"; "(megaphone)"; "(heart)"; "(cool)", "(kiss)"; "(agree)"; "(see-no-evil)", "(dance)",
    "(build)", "(oops)"; "(sleep)"; "(punch)", "(bheart)"; "(cry)", "(party)"; "(wl)", "(grow)"; "(gems)",
    "(gtoken)", "(plead)", "(vend)", "(bunny)", "(cactus)"; "(peace)"; "(terror)"; "(troll)"; "(halo)";
    "(nuke)"; "(pine)"; "(football)"; "(fireworks)"; "(song)", "(ghost)"; "(evil)"; "(pizza)", "(alien)",
    "(clap)"; "(turkey)", "(gift)"; "(cake)", "(heartarrow)", "(shamrock)"; "(grin)", "(ill)", "(eyes)";
    "(weary)"; "(moyai)"
}
W.SkinColor = { x = 0, y = 0; z = 0, w = 1 }
W.RainbowSkin = false
W.BlinkSkin = false
W.SkinEffectRunning = false
W.CalcInput = ""
W.CalcResult = "`wWaiting for input..."
W.CalcLogs = {}
W.ItemDB = {}
W.SearchItemInput = ""
W.SearchItemResults = {}
W.AutoPTHT = false
W.AutoProvider = false
W.AutoPNB = false
W.AutoRotasi = false
W.AutoTax = false
W.AutoCook = false
W.AutoFish = false
W.FishAction = "Idle"
W.FishBaitID = 5528
W.FishDirIdx = 1
W.FishBite = false
W.FishStats = { cast = 0; caught = 0, missed = 0 }
W.FishThreadRunning = false
W.AutoSurg = false
W.SurgAction = "Idle"
W.SurgTarget = nil
W.SurgStats = { success = 0, fail = 0 }
W.SurgAutoBuy = false
W.SurgCardThreshold = 20
W.SurgAutoTrash = true
W.SurgAutoModage = true
W.SurgUseLegalBrief = false
W.IsSurging = false
W.SurgThreadRunning = false
W.AutoCrime = false
W.CrimeAction = "Idle"
W.CrimeTarget = nil
W.CrimeVillains = {}
W.IsFightingCrime = false
W.CrimeWon = false
W.CrimeDeck = { 2294; 2292, 2296, 2316, 2342 }
W.AutoBuyCrimeCards = false
W.CrimeCardThreshold = 5
W.CrimePackName = "buy_crimewave"
W.CrimeThreadRunning = false
W.AutoGeiger = false
W.AutoBuyPack = false
W.ABP_Packs = {}
W.ABP_PackNames = {}
W.ABP_PackIdx = 1
W.ABP_BuyAmount = 0
W.ABP_BuyOnly = false
W.ABP_BatchMode = false
W.ABP_DropX = 0
W.ABP_DropY = 0
W.ABP_ThreadRunning = false
W.ABP_DetectedDropIDs = {}
W.ABP_AddedCmds = {}
W.ABP_IsScanningShop = false
W.ABP_ShopDialogName = ""
W.ABP_PurchaseState = 0
W.CasinoMode = 0
W.CasinoFormatIdx = 1
W.CasinoLewaMulti = 5
W.AutoChampWheel = false
W.BypassChampWheelPunch = false
W.ChampSpinPending = false
W.BTK_Mode = "BTK"
W.BTK_SelectingTarget = nil
W.BTK_CenterX = 0
W.BTK_CenterY = 0
W.BTK_Bet1X = 0
W.BTK_Bet1Y = 0
W.BTK_Bet2X = 0
W.BTK_Bet2Y = 0
W.BTK_Break1X = 0
W.BTK_Break1Y = 0
W.BTK_Break2X = 0
W.BTK_Break2Y = 0
W.BTK_TaxX = 0
W.BTK_TaxY = 0
W.BTK_MagX = 0
W.BTK_MagY = 0
W.BTK_P1Bet = 0
W.BTK_P2Bet = 0
W.BTK_TotalPrize = 0
W.BTK_WinnerSide = nil
W.AutoPull = false
W.AutoPullBlacklist = {}
W.NewBlacklistUID = 0
W.TPMode = 1
W.ShowBal = false
W.FastDrop = false
W.FastTrash = false
W.FastDropOnClick = false
W.FastTrashOnClick = false
W.VendFilter = true
W.DonationFilter = true
W.StorageFilter = true
W.StorageBoxState = {
    active_withdraw = false,
    last_x = 0,
    last_y = 0,
    item_queue = {},
    current_item = nil,
    suppress_reopen_until = 0;
    last_action_time = 0
}
W.AutoPullMinModal = 0
W.AutoPullTileX = 0
W.AutoPullTileY = 0
W.AutoPullPos = {
    { x = 0, y = 0 };
    { x = 0; y = 0 },
    { x = 0, y = 0 };
    { x = 0, y = 0 },
    { x = 0; y = 0 }
}
W.AutoPullSettingSlot = 0
W.AutoPullAreaScan = false
W.PendingModalPull = {}
W.AptCooldown = {}
W.CachedSpawnX = nil
W.CachedSpawnY = nil
W.LastSpawnScanTime = 0
W.AreaPullThreadRunning = false
W.LastPulledNetID = nil
W.LastPulledName = nil
W.LastPulledTime = 0
W.SpamPull = false
W.AutoSpamPull = false
W.SpamPullRunning = false
W.SpamPullSending = false
W.SpamPullTargetID = nil
W.SpamPullTargetName = nil
W.SpamPullEndTime = 0
W.RePullHotkeyName = "DELETE"
W.RePullHotkeyCode = 46
W.RePullHotkeyThreadRunning = false
W.HotkeyKeyCodes = {
    DELETE = 46; INSERT = 45, HOME = 36; END = 35; R = 82, V = 86, X = 88; F = 70, C = 67, G = 71; T = 84,
    Z = 90; Q = 81; E = 69; F1 = 112, F2 = 113; F3 = 114, F4 = 115; F5 = 116
}
W.SpamEnabled = false
W.SpamTexts = { "" }
W.SpamInterval = 5000
W.SpamThreadRunning = false
W.WebhookSB = ""
W.DiscordPingID = ""
W.SBEnabled = false
W.SBText = ""
W.SBWorld = ""
W.SBCount = 0
W.SBMax = 0
W.SBDelay = 3
W.SBStartTime = 0
W.SBCopyText = false
W.SBSafeMode = false
W.SBPending = false
W.SBTotPending = 0
W.SBTotSucceed = 0
W.SBUsedGems = 0
W.SBTotUsedGems = 0
W.SBUsedBGems = 0
W.SBTotUsedBGems = 0
W.SBLeftBGems = 0
W.SBUseGems = false
W.SBUseBGems = false
W.SBDoneWorld = ""
W.SBUseDoneWorld = false
W.SBThreadRunning = false
W.SDBEnabled = false
W.SDBMax = 0
W.SDBCount = 0
W.SDBLine1 = ""
W.SDBLine2 = ""
W.SDBLine3 = ""
W.SDBExtraTimer = 0
W.SDBTotalDelay = 5
W.SDBThreadRunning = false
W.AutoMagplant = false
W.AutoVending = false
W.VendList = {}
W.AutoWorld = false
W.LogsEnabled = true
W.LogFilter = 1
W.MaxLogs = 100
W.Logs = { All = {}; Casino = {}, Inventory = {} }
local O = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

-- ========================================================================
-- SECTION 4: Utility helpers (base64/XOR chat crypto, drop/lock helpers, parsing)
-- ========================================================================

function W.Base64Encode(P)
    if not P then
        return ""
    end
    return (((P:gsub(".", function(P)
        local j, Y = "", P:byte()
        for P = 8, 1, -1 do
            j = j .. ((Y % 2 ^ P - Y % 2 ^ ((P - 1)) > 0 and "1" or "0"))
        end
        return j
    end) .. "0000")):gsub("%d%d%d?%d?%d?%d?", function(P)
        if (#P < 6) then
            return ""
        end
        local j = 0
        for Y = 1, 6, 1 do
            j = j + ((P:sub(Y, Y) == "1" and 2 ^ ((6 - Y)) or 0))
        end
        return O:sub(j + 1, j + 1)
    end) .. (({ ""; "==", "=" }))[#P % 3 + 1])
end

function W.Base64Decode(P)
    if not P then
        return ""
    end
    P = string.gsub(P, "[^" .. (O .. "=]"), "")
    return ((P:gsub(".", function(P)
        if (P == "=") then
            return ""
        end
        local j, Y = "", (O:find(P) - 1)
        for P = 6, 1, -1 do
            j = j .. ((Y % 2 ^ P - Y % 2 ^ ((P - 1)) > 0 and "1" or "0"))
        end
        return j
    end)):gsub("%d%d%d?%d?%d?%d?%d?%d?", function(P)
        if (#P ~= 8) then
            return ""
        end
        local j = 0
        for Y = 1, 8, 1 do
            j = j + ((P:sub(Y, Y) == "1" and 2 ^ ((8 - Y)) or 0))
        end
        return string.char(j)
    end))
end

function W.XORCipher(P, j)
    if not P or not j or j == "" then
        return P
    end
    local function Y(P, j)
        local Y = 0
        local X = 1
        while P > 0 or j > 0 do
            local M = P % 2
            local z = j % 2
            if M ~= z then
                Y = Y + X
            end
            P = math.floor(P / 2)
            j = math.floor(j / 2)
            X = X * 2
        end
        return Y
    end
    local X = {}
    for M = 1, #P, 1 do
        local z = P:byte(M)
        local o = j:byte((((M - 1)) % #j) + 1)
        table.insert(X, string.char(Y(z, o)))
    end
    return table.concat(X)
end

function W.LocalChat(P)
    LogToConsole(P)
    local j = GetLocal()
    if j and j.netid then
        SendVariantList({ [0] = "OnTalkBubble"; [1] = j.netid, [2] = P })
    end
end

function W.CreateDialog(P)
    P = W.ApplyTheme(P)
    SendVariantList({ [0] = "OnDialogRequest"; [1] = P })
end

function W.GetItemCount(P)
    local j, Y = pcall(GetInventory)
    if not j or not Y then
        return 0
    end
    local X = tonumber(P) or 0
    if X <= 0 then
        return 0
    end
    if Y.items and type(Y.items) == "table" then
        for P, j in pairs(Y.items) do
            if type(j) == "table" and ((j.id == X or j.itemid == X)) then
                return tonumber(j.amount or j.count) or 0
            end
        end
    end
    for P, j in pairs(Y) do
        if type(j) == "table" and ((j.id == X or j.itemid == X)) then
            return tonumber(j.amount or j.count) or 0
        end
    end
    return 0
end

function W.GetNextWithdrawableStorageItem(P)
    if not P or #P == 0 then
        return nil, 0
    end
    for P, j in ipairs(P) do
        local Y = tonumber(j.icon_id) or 0
        local X = (Y > 0) and ((W.GetItemCount(Y) or 0)) or 0
        local M = math.max(0, 250 - X)
        local z = j.raw_btn or ("item_" .. tostring(j.hash))
        local o = (W.StorageBoxState and (((W.StorageBoxState.just_withdrawn_hash and W.StorageBoxState.just_withdrawn_hash == j.hash) or (W.StorageBoxState.just_withdrawn_btn and W.StorageBoxState.just_withdrawn_btn == z) or (W.StorageBoxState.withdrawn_hashes and ((W.StorageBoxState.withdrawn_hashes[tostring(j.hash)] or W.StorageBoxState.withdrawn_hashes[tostring(z)]))))))
        local q = o and (os.clock() - ((W.StorageBoxState.just_withdrawn_clock or 0)) < 1)
        if M > 0 and not q then
            return j, M
        end
    end
    return nil, 0
end

function W.SmartDropLock(P, j)
    local Y = {
        { id = 242; name = "`9CreativePS World Lock" },
        { id = 1796; name = "`cCreativePS Diamond Lock" };
        { id = 7188; name = "`eCreativePS Blue Gem Lock" };
        { id = 11550; name = "`bCreativePS Black Gem Lock" }
    }
    local function X(P, j)
        return 100 ^ ((P - j))
    end
    RunThread(function()
        local M = 0
        while M < 20 do
            local z = {}
            for P = 1, 4, 1 do
                z[P] = W.GetItemCount(Y[P].id)
            end
            local o = 0
            for j = 1, 4, 1 do
                o = o + (z[j] * X(j, P))
            end
            if o < j then
                W.LocalChat("`c[WinProxy]: `4Error! `wYou only have equivalent of `2" .. (math.floor(o) .. (" " .. (Y[P].name .. "`w."))))
                return
            end
            local q = {}
            local S = j
            for j = 4, 1, -1 do
                local Y = X(j, P)
                if Y > 0 and z[j] > 0 then
                    local P = math.floor(S / Y)
                    local X = math.min(P, z[j])
                    if X > 0 then
                        q[j] = X
                        S = S - (X * Y)
                    end
                end
            end
            if math.abs(S) < .0001 then
                local X = false
                for P = 4, 1, -1 do
                    if q[P] and q[P] > 0 then
                        SendPacket(2, "action|dialog_return\ndialog_name|drop\nitem_drop|" .. (Y[P].id .. ("|\nitem_count|" .. q[P])))
                        Sleep(400)
                        X = true
                    end
                end
                if X then
                    SendPacket(2, "action|input\n|text|`c[WinProxy]: `4Dropped `0" .. (j .. (" " .. Y[P].name)))
                end
                return
            end
            local O = false
            for P = P + 1, 4, 1 do
                local j = z[P] - ((q[P] or 0))
                if j > 0 then
                    W.LocalChat("`c[WinProxy]: `9Auto-breaking 1 " .. (Y[P].name .. " `9to get exact change..."))
                    if Y[P].id == W.GetIcon("Creativeps Black Gem Lock", 11550) then
                        SendPacket(2, "action|dialog_return\ndialog_name|info_box\nbuttonClicked|make_bluegl")
                    else
                        SendPacketRaw(false, { type = 10, value = Y[P].id })
                    end
                    Sleep(600)
                    O = true
                    break
                end
            end
            if not O then
                for P = 1, P - 1, 1 do
                    if z[P] >= 100 then
                        W.LocalChat("`c[WinProxy]: `9Auto-merging 100 " .. (Y[P].name .. " `9upwards..."))
                        if P == 3 then
                            SendPacket(2, "action|dialog_return\ndialog_name|info_box\nbuttonClicked|make_bgl")
                        else
                            SendPacketRaw(false, { type = 10, value = Y[P].id })
                        end
                        Sleep(600)
                        O = true
                        break
                    end
                end
            end
            if not O then
                W.LocalChat("`c[WinProxy]: `4Error! `wCannot find suitable locks to break or merge.")
                return
            end
            M = M + 1
        end
        W.LocalChat("`c[WinProxy]: `4Error! `wMax operation attempts reached.")
    end)
end

function W.DownloadAsset(j, Y)
    local X = io.open(Y, "r")
    if X then
        X:close()
        return true
    end
    LogToConsole("`c[WinProxy]: `wDownloading missing banner asset, please wait...")
    if P then
        local P = string.format("curl.exe -s -L -k --create-dirs -o \"%s\" \"%s\"", Y, j)
        os.execute(P)
    else
        LogToConsole("`c[WinProxy]: `4Auto-download banner tidak didukung di Android. Harap pasang manual.")
    end
    X = io.open(Y, "r")
    if X then
        local P = X:seek("end")
        X:close()
        if P > 100 then
            LogToConsole("`c[WinProxy]: `2Banner asset downloaded successfully!")
            return true
        else
            os.remove(Y)
        end
    end
    LogToConsole("`c[WinProxy]: `4Failed to download banner asset! Check URL or place it manually.")
    return false
end

function W.ParseDialogNumber(P)
    if not P then
        return 0
    end
    return tonumber((P:gsub(",", ""))) or 0
end

function W.ParseInventorySummary(P)
    local j = tostring(P or "")
    if j == "" then
        return nil
    end
    local Y = j:match("add_label_with_icon|big|(.-)``\'s Inventory") or "Unknown"
    Y = (Y:gsub("`.", "")):match("^%s*(.-)%s*$")
    local X = W.ParseDialogNumber(j:match("Blue Gem Locks in the Bank: %`%$([%d,]+)%`%`"))
    local M = W.ParseDialogNumber(j:match("|" .. (W.GetIcon("Creativeps Black Gem Lock", 11550) .. "|([%d,]+)|")))
    local z = W.ParseDialogNumber(j:match("|" .. (W.GetIcon("Creativeps Blue Gem Lock", 7188) .. "|([%d,]+)|")))
    local o = W.ParseDialogNumber(j:match("|" .. (W.GetIcon("Creativeps Diamond Lock", 1796) .. "|([%d,]+)|")))
    local q = W.ParseDialogNumber(j:match("|" .. (W.GetIcon("Creativeps World Lock", 242) .. "|([%d,]+)|")))
    local S = W.ParseDialogNumber(j:match("|" .. (W.GetIcon("Champagne", 16896) .. "|([%d,]+)|")))
    local O = z + X
    local V = ((M + math.floor(O / 100)) + math.floor(o / 10000)) + math.floor(q / 1000000)
    local e = O % 100
    local v = (e + math.floor(o / 100)) + math.floor(q / 10000)
    local f = o % 100
    local n = f + math.floor(q / 100)
    local C = q % 100
    return string.format("`w%s\'s Balance:\n`s%d BlackGL `e%d BGL `c%d DL `9%d WL `2[%d Champ]", Y, V, v, n, C, S)
end

function W.CalculateMyModal()
    local P, j, Y, X, M = 0, 0, 0, 0, 0
    for z, o in pairs(GetInventory()) do
        if o.id == W.GetIcon("Creativeps World Lock", 242) then
            P = o.amount
        end
        if o.id == W.GetIcon("Creativeps Diamond Lock", 1796) then
            j = o.amount
        end
        if o.id == W.GetIcon("Creativeps Blue Gem Lock", 7188) then
            Y = o.amount
        end
        if o.id == W.GetIcon("Creativeps Black Gem Lock", 11550) then
            X = o.amount
        end
        if o.id == W.GetIcon("Champagne", 16896) then
            M = o.amount
        end
    end
    local z = Y + W.BankBalance
    local o = ((X + math.floor(z / 100)) + math.floor(j / 10000)) + math.floor(P / 1000000)
    local q = z % 100
    local S = (q + math.floor(j / 100)) + math.floor(P / 10000)
    local O = j % 100
    local V = O + math.floor(P / 100)
    local e = P % 100
    W.LocalChat(string.format("`c[WinProxy]: `wMy Balance: `s%d BlackGL `e%d BGL `c%d DL `9%d WL `2[%d Champ]", o, S, V, e, M))
end

function W.SafeCombo(P, j, Y)
    local X = Y[j] or "Select..."
    if ImGui.Button(X .. ("  \226\150\188##btn_" .. P), ImVec2(150, 0)) then
        ImGui.OpenPopup("popup_" .. P)
    end
    ImGui.SameLine()
    ImGui.TextColored(ImVec4(.8, .8, .8, 1), P)
    if ImGui.BeginPopup("popup_" .. P) then
        local X = (#Y * 22)
        if X > 200 then
            X = 200
        end
        ImGui.BeginChild("scroll_" .. P, ImVec2(150, X), false)
        for P, Y in ipairs(Y) do
            if ImGui.Selectable(Y, j == P) then
                j = P
                ImGui.CloseCurrentPopup()
            end
        end
        ImGui.EndChild()
        ImGui.EndPopup()
    end
    return j
end

function W.FormatVendPrice(P)
    local j = tonumber(P) or 0
    if j == 0 then
        return "add_label_with_icon|small|0 x `9World Lock|left|" .. (W.GetIcon("Creativeps World Lock", 242) .. "|")
    end
    local Y = math.floor(j / 1000000)
    local X = j % 1000000
    local M = math.floor(X / 10000)
    X = X % 10000
    local z = math.floor(X / 100)
    local o = X % 100
    local q = {}
    if Y > 0 then
        table.insert(q, "add_label_with_icon|small|" .. (Y .. (" x `bBlack Gem Lock|left|" .. (W.GetIcon("Creativeps Black Gem Lock", 11550) .. "|"))))
    end
    if M > 0 then
        table.insert(q, "add_label_with_icon|small|" .. (M .. (" x `eBlue Gem Lock|left|" .. (W.GetIcon("Creativeps Blue Gem Lock", 7188) .. "|"))))
    end
    if z > 0 then
        table.insert(q, "add_label_with_icon|small|" .. (z .. (" x `cDiamond Lock|left|" .. (W.GetIcon("Creativeps Diamond Lock", 1796) .. "|"))))
    end
    if o > 0 then
        table.insert(q, "add_label_with_icon|small|" .. (o .. (" x `9World Lock|left|" .. (W.GetIcon("Creativeps World Lock", 242) .. "|"))))
    end
    return table.concat(q, "\n")
end

-- ========================================================================
-- SECTION 5: Config persistence (save / load / reset)
-- ========================================================================

function W.GetConfigPaths()
    local P = {}
    local j, Y = pcall(os.getenv, "LOCALAPPDATA")
    if j and (Y and Y ~= "") then
        table.insert(P, Y .. ("\\Growtopia\\scripts\\" .. W.ConfigFileName))
        table.insert(P, Y .. ("\\Growtopia\\" .. W.ConfigFileName))
    end
    table.insert(P, "/storage/emulated/0/Android/media/com.rtsoft.growtopia/scripts/" .. W.ConfigFileName)
    table.insert(P, "/storage/emulated/0/Android/data/com.rtsoft.growtopia/files/scripts/" .. W.ConfigFileName)
    table.insert(P, "/storage/emulated/0/Growtopia/scripts/" .. W.ConfigFileName)
    table.insert(P, "/storage/emulated/0/" .. W.ConfigFileName)
    table.insert(P, "/sdcard/" .. W.ConfigFileName)
    table.insert(P, "scripts/" .. W.ConfigFileName)
    table.insert(P, W.ConfigFileName)
    return P
end

function W.SaveConfig(P)
    local j, Y = pcall(function()
        local P = nil
        for j, Y in ipairs(W.GetConfigPaths()) do
            P = io.open(Y, "w")
            if P then
                break
            end
        end
        if P then
            P:write("AntiLag=" .. (tostring(W.AntiLag) .. "\n"))
            P:write("HideSpammer=" .. (tostring(W.HideSpammer) .. "\n"))
            P:write("AntiPickup=" .. (tostring(W.AntiPickup) .. "\n"))
            P:write("Modfly=" .. (tostring(W.Modfly) .. "\n"))
            P:write("DialogBg=" .. (tostring(W.DialogBg) .. "\n"))
            P:write("DialogBorder=" .. (tostring(W.DialogBorder) .. "\n"))
            P:write("AntiPortal=" .. (tostring(W.AntiPortal) .. "\n"))
            P:write("NightVision=" .. (tostring(W.NightVision) .. "\n"))
            P:write("BlockSDB=" .. (tostring(W.BlockSDB) .. "\n"))
            P:write("BlockSB=" .. (tostring(W.BlockSB) .. "\n"))
            P:write("AutoCVLocks=" .. (tostring(W.AutoCVLocks) .. "\n"))
            P:write("SpamPull=" .. (tostring(W.SpamPull or W.AutoSpamPull) .. "\n"))
            P:write("RePullHotkeyName=" .. (tostring(W.RePullHotkeyName or "DELETE") .. "\n"))
            P:write("RePullHotkeyCode=" .. (tostring(W.RePullHotkeyCode or 46) .. "\n"))
            P:write("AutoPull=" .. (tostring(W.AutoPull) .. "\n"))
            P:write("AutoPullTileX=" .. (tostring(W.AutoPullTileX or 0) .. "\n"))
            P:write("AutoPullTileY=" .. (tostring(W.AutoPullTileY or 0) .. "\n"))
            P:write("AutoPullMinModal=" .. (tostring(W.AutoPullMinModal or 0) .. "\n"))
            for j = 1, 5, 1 do
                if W.AutoPullPos and W.AutoPullPos[j] then
                    P:write("AutoPullPosX" .. (j .. ("=" .. (tostring(W.AutoPullPos[j].x) .. "\n"))))
                    P:write("AutoPullPosY" .. (j .. ("=" .. (tostring(W.AutoPullPos[j].y) .. "\n"))))
                end
            end
            P:write("TPDisplay=" .. (tostring(W.TPDisplay) .. "\n"))
            P:write("ShowBal=" .. (tostring(W.ShowBal) .. "\n"))
            P:write("VendFilter=" .. (tostring(W.VendFilter) .. "\n"))
            P:write("StorageFilter=" .. (tostring(W.StorageFilter) .. "\n"))
            P:write("LogsEnabled=" .. (tostring(W.LogsEnabled) .. "\n"))
            P:write("TPMode=" .. (tostring(W.TPMode) .. "\n"))
            P:write("WrenchMode=" .. (tostring(W.WrenchMode) .. "\n"))
            P:write("WrenchModeRight=" .. (tostring(W.WrenchModeRight or 0) .. "\n"))
            P:write("WrenchPullText=" .. (tostring(W.WrenchPullText) .. "\n"))
            P:write("WrenchKickText=" .. (tostring(W.WrenchKickText) .. "\n"))
            P:write("WrenchBanText=" .. (tostring(W.WrenchBanText) .. "\n"))
            P:write("DonateMode=" .. (tostring(W.DonateMode) .. "\n"))
            P:write("TeleMode=" .. (tostring(W.TeleMode) .. "\n"))
            P:write("CasinoMode=" .. (tostring(W.CasinoMode) .. "\n"))
            P:write("CasinoFormatIdx=" .. (tostring(W.CasinoFormatIdx) .. "\n"))
            P:write("CasinoLewaMulti=" .. (tostring(W.CasinoLewaMulti) .. "\n"))
            P:write("AutoChampWheel=" .. (tostring(W.AutoChampWheel) .. "\n"))
            P:write("BTK_Mode=" .. (tostring(W.BTK_Mode or "BTK") .. "\n"))
            P:write("BTK_CenterX=" .. (tostring(W.BTK_CenterX or 0) .. "\n"))
            P:write("BTK_CenterY=" .. (tostring(W.BTK_CenterY or 0) .. "\n"))
            P:write("BTK_Bet1X=" .. (tostring(W.BTK_Bet1X or 0) .. "\n"))
            P:write("BTK_Bet1Y=" .. (tostring(W.BTK_Bet1Y or 0) .. "\n"))
            P:write("BTK_Bet2X=" .. (tostring(W.BTK_Bet2X or 0) .. "\n"))
            P:write("BTK_Bet2Y=" .. (tostring(W.BTK_Bet2Y or 0) .. "\n"))
            P:write("BTK_Break1X=" .. (tostring(W.BTK_Break1X or 0) .. "\n"))
            P:write("BTK_Break1Y=" .. (tostring(W.BTK_Break1Y or 0) .. "\n"))
            P:write("BTK_Break2X=" .. (tostring(W.BTK_Break2X or 0) .. "\n"))
            P:write("BTK_Break2Y=" .. (tostring(W.BTK_Break2Y or 0) .. "\n"))
            P:write("BTK_TaxX=" .. (tostring(W.BTK_TaxX or 0) .. "\n"))
            P:write("BTK_TaxY=" .. (tostring(W.BTK_TaxY or 0) .. "\n"))
            P:write("BTK_MagX=" .. (tostring(W.BTK_MagX or 0) .. "\n"))
            P:write("BTK_MagY=" .. (tostring(W.BTK_MagY or 0) .. "\n"))
            P:write("FishDirIdx=" .. (tostring(W.FishDirIdx) .. "\n"))
            P:write("FishBaitID=" .. (tostring(W.FishBaitID) .. "\n"))
            P:write("SurgAutoBuy=" .. (tostring(W.SurgAutoBuy) .. "\n"))
            P:write("SurgCardThreshold=" .. (tostring(W.SurgCardThreshold) .. "\n"))
            P:write("SurgAutoTrash=" .. (tostring(W.SurgAutoTrash) .. "\n"))
            P:write("SurgAutoModage=" .. (tostring(W.SurgAutoModage) .. "\n"))
            P:write("SurgUseLegalBrief=" .. (tostring(W.SurgUseLegalBrief) .. "\n"))
            P:write("AutoBuyCrimeCards=" .. (tostring(W.AutoBuyCrimeCards) .. "\n"))
            P:write("CrimeCardThreshold=" .. (tostring(W.CrimeCardThreshold) .. "\n"))
            P:write("ABP_BuyAmount=" .. (tostring(W.ABP_BuyAmount) .. "\n"))
            P:write("ABP_BuyOnly=" .. (tostring(W.ABP_BuyOnly) .. "\n"))
            P:write("ABP_BatchMode=" .. (tostring(W.ABP_BatchMode) .. "\n"))
            P:write("ABP_DropX=" .. (tostring(W.ABP_DropX) .. "\n"))
            P:write("ABP_DropY=" .. (tostring(W.ABP_DropY) .. "\n"))
            P:write("WatermarkMode=" .. (tostring(W.WatermarkMode) .. "\n"))
            P:write("EnableColor=" .. (tostring(W.EnableColor) .. "\n"))
            P:write("EnableEmoji=" .. (tostring(W.EnableEmoji) .. "\n"))
            P:write("EncryptChat=" .. (tostring(W.EncryptChat) .. "\n"))
            P:write("SelectedColorIdx=" .. (tostring(W.SelectedColorIdx) .. "\n"))
            P:write("SelectedEmojiIdx=" .. (tostring(W.SelectedEmojiIdx) .. "\n"))
            P:write("RainbowSkin=" .. (tostring(W.RainbowSkin) .. "\n"))
            P:write("BlinkSkin=" .. (tostring(W.BlinkSkin) .. "\n"))
            P:write("WebhookSB=" .. (tostring(W.WebhookSB) .. "\n"))
            P:write("DiscordPingID=" .. (tostring(W.DiscordPingID) .. "\n"))
            P:write("TradeAddAmount=" .. (tostring(W.TradeAddAmount) .. "\n"))
            P:write("SpamInterval=" .. (tostring(W.SpamInterval) .. "\n"))
            P:write("SBText=" .. (tostring(W.SBText) .. "\n"))
            P:write("SBMax=" .. (tostring(W.SBMax) .. "\n"))
            P:write("SBCopyText=" .. (tostring(W.SBCopyText) .. "\n"))
            P:write("SBSafeMode=" .. (tostring(W.SBSafeMode) .. "\n"))
            P:write("SBDoneWorld=" .. (tostring(W.SBDoneWorld) .. "\n"))
            P:write("SBUseDoneWorld=" .. (tostring(W.SBUseDoneWorld) .. "\n"))
            P:write("SDBLine1=" .. (tostring(W.SDBLine1) .. "\n"))
            P:write("SDBLine2=" .. (tostring(W.SDBLine2) .. "\n"))
            P:write("SDBLine3=" .. (tostring(W.SDBLine3) .. "\n"))
            P:write("SDBMax=" .. (tostring(W.SDBMax) .. "\n"))
            P:write("SDBExtraTimer=" .. (tostring(W.SDBExtraTimer) .. "\n"))
            P:write("MagFindID=" .. (tostring(W.MagFindID) .. "\n"))
            P:write("MagDelay=" .. (tostring(W.MagDelay) .. "\n"))
            P:write("MagFromWorld=" .. (tostring(W.MagFromWorld) .. "\n"))
            P:write("MagFromX=" .. (tostring(W.MagFromX) .. "\n"))
            P:write("MagFromY=" .. (tostring(W.MagFromY) .. "\n"))
            P:write("MagTargetX=" .. (tostring(W.MagTargetX) .. "\n"))
            P:write("MagTargetY=" .. (tostring(W.MagTargetY) .. "\n"))
            P:write("MagDropWorld=" .. (tostring(W.MagDropWorld) .. "\n"))
            P:write("MagDropX=" .. (tostring(W.MagDropX) .. "\n"))
            P:write("MagDropY=" .. (tostring(W.MagDropY) .. "\n"))
            P:write("MagSetMode=" .. (tostring(W.MagSetMode) .. "\n"))
            P:write("MagAutoWalk=" .. (tostring(W.MagAutoWalk) .. "\n"))
            P:write("MagM2MTakeWorld=" .. (tostring(W.MagM2MTakeWorld) .. "\n"))
            P:write("MagM2MTakeX=" .. (tostring(W.MagM2MTakeX) .. "\n"))
            P:write("MagM2MTakeY=" .. (tostring(W.MagM2MTakeY) .. "\n"))
            P:write("MagM2MPutWorld=" .. (tostring(W.MagM2MPutWorld) .. "\n"))
            P:write("MagM2MPutX=" .. (tostring(W.MagM2MPutX) .. "\n"))
            P:write("MagM2MPutY=" .. (tostring(W.MagM2MPutY) .. "\n"))
            P:write("MagM2MAutoMove=" .. (tostring(W.MagM2MAutoMove) .. "\n"))
            P:write("VendFindID=" .. (tostring(W.VendFindID) .. "\n"))
            P:write("VendDelay=" .. (tostring(W.VendDelay) .. "\n"))
            P:write("VendFromWorld=" .. (tostring(W.VendFromWorld) .. "\n"))
            P:write("VendFromX=" .. (tostring(W.VendFromX) .. "\n"))
            P:write("VendFromY=" .. (tostring(W.VendFromY) .. "\n"))
            P:write("VendTargetX=" .. (tostring(W.VendTargetX) .. "\n"))
            P:write("VendTargetY=" .. (tostring(W.VendTargetY) .. "\n"))
            P:write("VendDropWorld=" .. (tostring(W.VendDropWorld) .. "\n"))
            P:write("VendDropX=" .. (tostring(W.VendDropX) .. "\n"))
            P:write("VendDropY=" .. (tostring(W.VendDropY) .. "\n"))
            P:write("VendSetMode=" .. (tostring(W.VendSetMode) .. "\n"))
            P:write("VendAutoWalk=" .. (tostring(W.VendAutoWalk) .. "\n"))
            P:write("VendM2MTakeWorld=" .. (tostring(W.VendM2MTakeWorld) .. "\n"))
            P:write("VendM2MTakeX=" .. (tostring(W.VendM2MTakeX) .. "\n"))
            P:write("VendM2MTakeY=" .. (tostring(W.VendM2MTakeY) .. "\n"))
            P:write("VendM2MPutWorld=" .. (tostring(W.VendM2MPutWorld) .. "\n"))
            P:write("VendM2MPutX=" .. (tostring(W.VendM2MPutX) .. "\n"))
            P:write("VendM2MPutY=" .. (tostring(W.VendM2MPutY) .. "\n"))
            P:write("VendM2MAutoMove=" .. (tostring(W.VendM2MAutoMove) .. "\n"))
            P:write("VendPrice=" .. (tostring(W.VendPrice) .. "\n"))
            P:write("VendPriceMode=" .. (tostring(W.VendPriceMode) .. "\n"))
            for j, Y in pairs(W.CustomCommands) do
                P:write("CmdAlias|" .. (j .. ("=" .. (Y.orig .. ("|" .. (tostring(Y.disableOrig) .. "\n"))))))
            end
            for j, Y in ipairs(W.SpamTexts) do
                if Y ~= "" then
                    P:write("SpamText|" .. (tostring(j) .. ("=" .. (Y .. "\n"))))
                end
            end
            if #W.AutoPullBlacklist > 0 then
                P:write("AutoPullBlacklist=" .. (table.concat(W.AutoPullBlacklist, ",") .. "\n"))
            end
            P:close()
        end
    end)
    if j then
        if not P then
            W.LocalChat("`c[WinProxy]: `9Configuration successfully saved!")
        end
    else
        if not P then
            W.LocalChat("`c[WinProxy]: `4Failed to save configuration.")
        end
    end
end

function W.LoadConfig()
    local P, j = pcall(function()
        local P = nil
        for j, Y in ipairs(W.GetConfigPaths()) do
            P = io.open(Y, "r")
            if P then
                break
            end
        end
        if P then
            W.SpamTexts = {}
            W.AutoPullBlacklist = {}
            for P in P:lines() do
                local j, Y = P:match("([^=]+)=(.+)")
                if j and Y then
                    if j == "AntiLag" then
                        W.AntiLag = (Y == "true")
                    elseif j == "HideSpammer" then
                        W.HideSpammer = (Y == "true")
                    elseif j == "AntiPickup" then
                        W.AntiPickup = (Y == "true")
                    elseif j == "Modfly" then
                        W.Modfly = (Y == "true")
                        pcall(function()
                            ChangeValue("[C] Modfly", W.Modfly)
                        end)
                    elseif j == "DialogBg" and Y ~= "nil" then
                        W.DialogBg = tostring(Y)
                    elseif j == "DialogBorder" and Y ~= "nil" then
                        W.DialogBorder = tostring(Y)
                    elseif j == "AntiPortal" then
                        W.AntiPortal = (Y == "true")
                        pcall(function()
                            ChangeValue("[C] Anti portal", W.AntiPortal)
                        end)
                    elseif j == "NightVision" then
                        W.NightVision = (Y == "true")
                        pcall(function()
                            ChangeValue("[C] Night vision", W.NightVision)
                        end)
                    elseif j == "BlockSDB" then
                        W.BlockSDB = (Y == "true")
                    elseif j == "BlockSB" then
                        W.BlockSB = (Y == "true")
                    elseif j == "AutoCVLocks" then
                        W.AutoCVLocks = (Y == "true")
                    elseif j == "SpamPull" or j == "AutoSpamPull" then
                        W.SpamPull = (Y == "true")
                        W.AutoSpamPull = W.SpamPull
                    elseif j == "RePullHotkeyName" then
                        W.RePullHotkeyName = Y
                    elseif j == "RePullHotkeyCode" then
                        W.RePullHotkeyCode = tonumber(Y) or 46
                    elseif j == "AutoPull" then
                        W.AutoPull = (Y == "true")
                    elseif j == "AutoPullTileX" then
                        W.AutoPullTileX = tonumber(Y) or 0
                    elseif j == "AutoPullTileY" then
                        W.AutoPullTileY = tonumber(Y) or 0
                    elseif j == "AutoPullMinModal" then
                        W.AutoPullMinModal = tonumber(Y) or 0
                    elseif j:find("AutoPullBlacklist|") then
                        local P = tonumber(j:match("AutoPullBlacklist|(%d+)"))
                        if P then
                            table.insert(W.AutoPullBlacklist, P)
                        end
                    elseif j == "AutoPullBlacklist" then
                        for P in Y:gmatch("%d+") do
                            table.insert(W.AutoPullBlacklist, tonumber(P))
                        end
                    elseif j:match("AutoPullPosX(%d+)") then
                        local P = tonumber(j:match("AutoPullPosX(%d+)"))
                        if P and (P >= 1 and P <= 5) then
                            W.AutoPullPos[P].x = tonumber(Y) or 0
                        end
                    elseif j:match("AutoPullPosY(%d+)") then
                        local P = tonumber(j:match("AutoPullPosY(%d+)"))
                        if P and (P >= 1 and P <= 5) then
                            W.AutoPullPos[P].y = tonumber(Y) or 0
                        end
                    elseif j == "TPDisplay" then
                        W.TPDisplay = (Y == "true")
                    elseif j == "ShowBal" then
                        W.ShowBal = (Y == "true")
                    elseif j == "VendFilter" then
                        W.VendFilter = (Y == "true")
                    elseif j == "DonationFilter" then
                        W.DonationFilter = (Y == "true")
                    elseif j == "StorageFilter" then
                        W.StorageFilter = (Y == "true")
                    elseif j == "LogsEnabled" then
                        W.LogsEnabled = (Y == "true")
                    elseif j == "TPMode" then
                        W.TPMode = tonumber(Y) or 1
                    elseif j == "WrenchMode" then
                        W.WrenchMode = tonumber(Y) or 0
                    elseif j == "WrenchModeRight" then
                        W.WrenchModeRight = tonumber(Y) or 0
                    elseif j == "WrenchPullText" then
                        W.WrenchPullText = (Y == "nil") and "" or Y
                    elseif j == "WrenchKickText" then
                        W.WrenchKickText = (Y == "nil") and "" or Y
                    elseif j == "WrenchBanText" then
                        W.WrenchBanText = (Y == "nil") and "" or Y
                    elseif j == "DonateMode" then
                        W.DonateMode = (Y == "true")
                    elseif j == "TeleMode" then
                        W.TeleMode = tonumber(Y) or 0
                    elseif j == "CasinoMode" then
                        W.CasinoMode = tonumber(Y) or 0
                    elseif j == "CasinoFormatIdx" then
                        W.CasinoFormatIdx = tonumber(Y) or 1
                    elseif j == "CasinoLewaMulti" then
                        W.CasinoLewaMulti = tonumber(Y) or 5
                    elseif j == "AutoChampWheel" then
                        W.AutoChampWheel = (Y == "true")
                    elseif j == "BTK_Mode" then
                        W.BTK_Mode = (Y == "BJ") and "BJ" or "BTK"
                    elseif j == "BTK_CenterX" then
                        W.BTK_CenterX = tonumber(Y) or 0
                    elseif j == "BTK_CenterY" then
                        W.BTK_CenterY = tonumber(Y) or 0
                    elseif j == "BTK_Bet1X" then
                        W.BTK_Bet1X = tonumber(Y) or 0
                    elseif j == "BTK_Bet1Y" then
                        W.BTK_Bet1Y = tonumber(Y) or 0
                    elseif j == "BTK_Bet2X" then
                        W.BTK_Bet2X = tonumber(Y) or 0
                    elseif j == "BTK_Bet2Y" then
                        W.BTK_Bet2Y = tonumber(Y) or 0
                    elseif j == "BTK_Break1X" then
                        W.BTK_Break1X = tonumber(Y) or 0
                    elseif j == "BTK_Break1Y" then
                        W.BTK_Break1Y = tonumber(Y) or 0
                    elseif j == "BTK_Break2X" then
                        W.BTK_Break2X = tonumber(Y) or 0
                    elseif j == "BTK_Break2Y" then
                        W.BTK_Break2Y = tonumber(Y) or 0
                    elseif j == "BTK_TaxX" then
                        W.BTK_TaxX = tonumber(Y) or 0
                    elseif j == "BTK_TaxY" then
                        W.BTK_TaxY = tonumber(Y) or 0
                    elseif j == "BTK_MagX" then
                        W.BTK_MagX = tonumber(Y) or 0
                    elseif j == "BTK_MagY" then
                        W.BTK_MagY = tonumber(Y) or 0
                    elseif j == "FishDirIdx" then
                        W.FishDirIdx = tonumber(Y) or 1
                    elseif j == "FishBaitID" then
                        W.FishBaitID = tonumber(Y) or 5528
                    elseif j == "SurgAutoBuy" then
                        W.SurgAutoBuy = (Y == "true")
                    elseif j == "SurgCardThreshold" then
                        W.SurgCardThreshold = tonumber(Y) or 20
                    elseif j == "SurgAutoTrash" then
                        W.SurgAutoTrash = (Y == "true")
                    elseif j == "SurgAutoModage" then
                        W.SurgAutoModage = (Y == "true")
                    elseif j == "SurgUseLegalBrief" then
                        W.SurgUseLegalBrief = (Y == "true")
                    elseif j == "AutoBuyCrimeCards" then
                        W.AutoBuyCrimeCards = (Y == "true")
                    elseif j == "CrimeCardThreshold" then
                        W.CrimeCardThreshold = tonumber(Y) or 10
                    elseif j == "ABP_BuyAmount" then
                        W.ABP_BuyAmount = tonumber(Y) or 0
                    elseif j == "ABP_BuyOnly" then
                        W.ABP_BuyOnly = (Y == "true")
                    elseif j == "ABP_BatchMode" then
                        W.ABP_BatchMode = (Y == "true")
                    elseif j == "ABP_DropX" then
                        W.ABP_DropX = tonumber(Y) or 0
                    elseif j == "ABP_DropY" then
                        W.ABP_DropY = tonumber(Y) or 0
                    elseif j == "WatermarkMode" then
                        W.WatermarkMode = (Y == "true")
                    elseif j == "EnableColor" then
                        W.EnableColor = (Y == "true")
                    elseif j == "EnableEmoji" then
                        W.EnableEmoji = (Y == "true")
                    elseif j == "EncryptChat" then
                        W.EncryptChat = (Y == "true")
                    elseif j == "SelectedColorIdx" then
                        W.SelectedColorIdx = tonumber(Y) or 2
                    elseif j == "SelectedEmojiIdx" then
                        W.SelectedEmojiIdx = tonumber(Y) or 2
                    elseif j == "RainbowSkin" then
                        W.RainbowSkin = (Y == "true")
                    elseif j == "BlinkSkin" then
                        W.BlinkSkin = (Y == "true")
                    elseif j == "WebhookSB" then
                        W.WebhookSB = (Y == "nil") and "" or Y
                    elseif j == "DiscordPingID" then
                        W.DiscordPingID = (Y == "nil") and "" or Y
                    elseif j == "MagFindID" then
                        W.MagFindID = (Y == "nil") and "1656" or Y
                    elseif j == "MagDelay" then
                        W.MagDelay = tonumber(Y) or 150
                    elseif j == "MagFromWorld" then
                        W.MagFromWorld = (Y == "nil") and "" or Y
                    elseif j == "MagFromX" then
                        W.MagFromX = tostring(tonumber(Y) or 0)
                    elseif j == "MagFromY" then
                        W.MagFromY = tostring(tonumber(Y) or 0)
                    elseif j == "MagTargetX" then
                        W.MagTargetX = tostring(tonumber(Y) or 0)
                    elseif j == "MagTargetY" then
                        W.MagTargetY = tostring(tonumber(Y) or 0)
                    elseif j == "MagDropWorld" then
                        W.MagDropWorld = (Y == "nil") and "" or Y
                    elseif j == "MagDropX" then
                        W.MagDropX = tostring(tonumber(Y) or 0)
                    elseif j == "MagDropY" then
                        W.MagDropY = tostring(tonumber(Y) or 0)
                    elseif j == "MagSetMode" then
                        W.MagSetMode = (Y == "nil") and "walk" or Y
                    elseif j == "MagAutoWalk" then
                        W.MagAutoWalk = false
                    elseif j == "MagM2MTakeWorld" then
                        W.MagM2MTakeWorld = (Y == "nil") and "" or Y
                    elseif j == "MagM2MTakeX" then
                        W.MagM2MTakeX = tostring(tonumber(Y) or 0)
                    elseif j == "MagM2MTakeY" then
                        W.MagM2MTakeY = tostring(tonumber(Y) or 0)
                    elseif j == "MagM2MPutWorld" then
                        W.MagM2MPutWorld = (Y == "nil") and "" or Y
                    elseif j == "MagM2MPutX" then
                        W.MagM2MPutX = tostring(tonumber(Y) or 0)
                    elseif j == "MagM2MPutY" then
                        W.MagM2MPutY = tostring(tonumber(Y) or 0)
                    elseif j == "MagM2MAutoMove" then
                        W.MagM2MAutoMove = false
                    elseif j == "VendFindID" then
                        W.VendFindID = (Y == "nil") and "1656" or Y
                    elseif j == "VendDelay" then
                        W.VendDelay = tonumber(Y) or 150
                    elseif j == "VendFromWorld" then
                        W.VendFromWorld = (Y == "nil") and "" or Y
                    elseif j == "VendFromX" then
                        W.VendFromX = tostring(tonumber(Y) or 0)
                    elseif j == "VendFromY" then
                        W.VendFromY = tostring(tonumber(Y) or 0)
                    elseif j == "VendTargetX" then
                        W.VendTargetX = tostring(tonumber(Y) or 0)
                    elseif j == "VendTargetY" then
                        W.VendTargetY = tostring(tonumber(Y) or 0)
                    elseif j == "VendDropWorld" then
                        W.VendDropWorld = (Y == "nil") and "" or Y
                    elseif j == "VendDropX" then
                        W.VendDropX = tostring(tonumber(Y) or 0)
                    elseif j == "VendDropY" then
                        W.VendDropY = tostring(tonumber(Y) or 0)
                    elseif j == "VendSetMode" then
                        W.VendSetMode = (Y == "nil") and "walk" or Y
                    elseif j == "VendAutoWalk" then
                        W.VendAutoWalk = false
                    elseif j == "VendM2MTakeWorld" then
                        W.VendM2MTakeWorld = (Y == "nil") and "" or Y
                    elseif j == "VendM2MTakeX" then
                        W.VendM2MTakeX = tostring(tonumber(Y) or 0)
                    elseif j == "VendM2MTakeY" then
                        W.VendM2MTakeY = tostring(tonumber(Y) or 0)
                    elseif j == "VendM2MPutWorld" then
                        W.VendM2MPutWorld = (Y == "nil") and "" or Y
                    elseif j == "VendM2MPutX" then
                        W.VendM2MPutX = tostring(tonumber(Y) or 0)
                    elseif j == "VendM2MPutY" then
                        W.VendM2MPutY = tostring(tonumber(Y) or 0)
                    elseif j == "VendM2MAutoMove" then
                        W.VendM2MAutoMove = false
                    elseif j == "VendPrice" then
                        W.VendPrice = Y
                    elseif j == "VendPriceMode" then
                        W.VendPriceMode = Y
                    elseif j == "TradeAddAmount" then
                        W.TradeAddAmount = tonumber(Y) or 1
                    elseif j == "SpamInterval" then
                        W.SpamInterval = tonumber(Y) or 5000
                    elseif j == "SBText" then
                        W.SBText = (Y == "nil") and "" or Y
                    elseif j == "SBMax" then
                        W.SBMax = tonumber(Y) or 0
                    elseif j == "SBCopyText" then
                        W.SBCopyText = (Y == "true")
                    elseif j == "SBSafeMode" then
                        W.SBSafeMode = (Y == "true")
                    elseif j == "SBDoneWorld" then
                        W.SBDoneWorld = (Y == "nil") and "" or Y
                    elseif j == "SBUseDoneWorld" then
                        W.SBUseDoneWorld = (Y == "true")
                    elseif j == "SDBLine1" then
                        W.SDBLine1 = (Y == "nil") and "" or Y
                    elseif j == "SDBLine2" then
                        W.SDBLine2 = (Y == "nil") and "" or Y
                    elseif j == "SDBLine3" then
                        W.SDBLine3 = (Y == "nil") and "" or Y
                    elseif j == "SDBMax" then
                        W.SDBMax = tonumber(Y) or 0
                    elseif j == "SDBExtraTimer" then
                        W.SDBExtraTimer = tonumber(Y) or 0
                    elseif j:find("CmdAlias|") then
                        local P, X = Y:match("([^|]+)|(.*)")
                        if P and X then
                            W.CustomCommands[j:sub(10)] = { orig = P, disableOrig = (X == "true") }
                        else
                            W.CustomCommands[j:sub(10)] = { orig = Y, disableOrig = false }
                        end
                    elseif j:find("SpamText|") then
                        table.insert(W.SpamTexts, Y)
                    end
                end
            end
            if #W.SpamTexts == 0 then
                table.insert(W.SpamTexts, "")
            end
            P:close()
            return true
        end
        return false
    end)
end

function W.FindChampagneID()
    local P = GetInventory() or {}
    for P, j in pairs(P) do
        if j.amount and j.amount > 0 then
            if j.id == -630 or j.id == 16896 or j.id == 64906 or j.id == 17070 or j.id == W.GetIcon("Champagne", 16896) then
                return j.id, j.amount
            end
            if GetItemInfo then
                local P, Y = pcall(GetItemInfo, j.id)
                if P and (Y and (Y.name and (Y.name:lower()):find("champagne"))) then
                    return j.id, j.amount
                end
            end
        end
    end
    return nil, 0
end

function W.UseChampagne()
    local P, j = W.FindChampagneID()
    if not P then
        P = -630
    end
    local Y = GetLocal()
    local X = ((Y and Y.pos)) and math.floor(Y.pos.x / 32) or 0
    local M = ((Y and Y.pos)) and math.floor(Y.pos.y / 32) or 0
    local z = ((Y and Y.pos)) and Y.pos.x or 0
    local o = ((Y and Y.pos)) and Y.pos.y or 0
    pcall(function()
        SendPacketRaw(false, { type = 3, value = P; px = X; py = M, x = z; y = o })
    end)
    if P ~= -630 then
        pcall(function()
            SendPacketRaw(false, { type = 3; value = -630; px = X; py = M; x = z; y = o })
        end)
    end
    pcall(function()
        SendPacketRaw(false, { type = 10, value = P })
    end)
    if P ~= -630 then
        pcall(function()
            SendPacketRaw(false, { type = 10; value = -630 })
        end)
    end
    return true
end

function W.ResetConfig()
    W.AntiLag = false
    W.HideSpammer = false
    W.AntiPickup = false
    W.Modfly = false
    W.AntiPortal = false
    W.NightVision = false
    W.BlockSDB = true
    W.BTK_Mode = "BTK"
    W.AutoPull = false
    for P = 1, 5, 1 do
        W.AutoPullPos[P] = { x = 0; y = 0 }
    end
    W.AutoPullSettingSlot = 0
    W.AutoPullTileX = 0
    W.AutoPullTileY = 0
    W.AutoPullMinModal = 0
    AutoCVLocks = false
    W.TPDisplay = false
    W.ShowBal = false
    W.FastDrop = false
    W.FastTrash = false
    W.VendFilter = false
    W.DonationFilter = false
    W.StorageFilter = false
    W.LogsEnabled = true
    W.TPMode = 1
    W.WrenchMode = 0
    W.WrenchModeRight = 0
    W.WrenchPullText = ""
    W.WrenchKickText = ""
    W.WrenchBanText = ""
    W.DonateMode = false
    W.DonateBoxX = 0
    W.DonateBoxY = 0
    W.DonateAmount = 1
    W.TeleMode = 0
    W.CasinoMode = 0
    W.CasinoLewaMulti = 5
    W.AutoChampWheel = false
    W.WatermarkMode = true
    W.EncryptChat = false
    W.EnableColor = false
    W.EnableEmoji = false
    W.SelectedColorIdx = 2
    W.SelectedEmojiIdx = 2
    W.RainbowSkin = false
    W.BlinkSkin = false
    W.WebhookSB = ""
    W.DiscordPingID = ""
    W.TradeAddAmount = 1
    W.SpamInterval = 5000
    W.CustomCommands = {}
    W.SpamTexts = { "" }
    W.SBText = ""
    W.SBMax = 0
    W.SBCopyText = false
    W.SBSafeMode = false
    W.SBDoneWorld = ""
    W.SBUseDoneWorld = false
    W.SDBLine1 = ""
    W.SDBLine2 = ""
    W.SDBLine3 = ""
    W.SDBMax = 0
    W.SDBExtraTimer = 0
    W.LocalChat("`c[WinProxy]: `9Configuration reset to default. Click \'Save\' to apply.")
end

local function V(P, j)
    return "add_label_with_icon|big|`9" .. (P .. ("|left|" .. (j .. "|\nadd_spacer|small|\nadd_textbox|`wThis feature will be available soon.|\nadd_spacer|small|\ntext_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjj|\nadd_button|menuu|Back|noflags|0|0|\nend_dialog|close_ui|Close||\n")))
end

-- ========================================================================
-- SECTION 6: General toggles, wrench, donate, trade, skin effects, calculator, item DB
-- ========================================================================

function W.ToggleAntiLag(P)
    if P ~= nil then
        W.AntiLag = P
    else
        W.AntiLag = not W.AntiLag
    end
    pcall(function()
        ChangeValue("[C] No render particle", W.AntiLag)
        ChangeValue("[C] No render shadow", W.AntiLag)
    end)
    W.SaveConfig(true)
    W.LocalChat("`c[WinProxy]: `9Anti-Lag is now " .. ((W.AntiLag and "`2ON" or "`4OFF")))
end

function W.ToggleHideSpammer(P)
    if P ~= nil then
        W.HideSpammer = P
    else
        W.HideSpammer = not W.HideSpammer
    end
    W.SaveConfig(true)
    W.LocalChat("`c[WinProxy]: `9Hide Spammer Slave is now " .. ((W.HideSpammer and "`2ON" or "`4OFF")))
end

function W.GetNearestTelephone()
    local P = GetLocal()
    if not P or not P.pos then
        return nil, nil
    end
    local j = math.floor(P.pos.x / 32)
    local Y = math.floor(P.pos.y / 32)
    local X, M = nil, nil
    local z = 9999
    local o, q = pcall(GetTiles)
    if o and q then
        for P, o in pairs(q) do
            if o.fg == 3898 then
                local P = math.max(math.abs(o.x - j), math.abs(o.y - Y))
                if P < z then
                    z = P
                    X = o.x
                    M = o.y
                end
            end
        end
    end
    if z <= 3 then
        return X, M
    end
    return nil, nil
end

W.WarningThreadRunning = false

function W.ManageWarningThread()
    if W.WarningThreadRunning then
        return
    end
    W.WarningThreadRunning = true
    RunThread(function()
        while W.FastDropOnClick or W.FastTrashOnClick do
            local P = W.FastDropOnClick and "`4FAST DROP" or "`4FAST TRASH"
            local j = W.FastDropOnClick and "DROP" or "TRASH"
            local Y = "`wWarning: " .. (P .. (" ON-CLICK `wis `2ACTIVE`w!\n`4Touch an item in your inventory to instantly " .. (j .. " it!")))
            SendVariantList({ [0] = "OnTextOverlay"; [1] = Y })
            Sleep(2000)
        end
        W.WarningThreadRunning = false
    end)
end

W.OnClickThreadRunning = false
W.LastSelectedItemID = 0

function W.ManageOnClickItemThread()
    if W.OnClickThreadRunning then
        return
    end
    W.OnClickThreadRunning = true
    RunThread(function()
        while W.FastDropOnClick or W.FastTrashOnClick do
            local P, j = pcall(GetPlayerItems)
            if P and (j and j.backpack) then
                local P = tonumber(j.backpack.selected) or 0
                if P > 0 and P ~= W.LastSelectedItemID then
                    W.LastSelectedItemID = P
                    if P ~= 18 and (P ~= 32 and (P ~= W.GetIcon("Creativeps World Lock", 242) and (P ~= W.GetIcon("Creativeps Diamond Lock", 1796) and (P ~= W.GetIcon("Creativeps Blue Gem Lock", 7188) and P ~= W.GetIcon("Creativeps Black Gem Lock", 11550))))) then
                        if W.FastDropOnClick then
                            SendPacket(2, "action|drop\n|itemID|" .. P)
                        elseif W.FastTrashOnClick then
                            SendPacket(2, "action|trash\n|itemID|" .. P)
                        end
                    end
                elseif P == 0 then
                    W.LastSelectedItemID = 0
                end
            end
            Sleep(50)
        end
        W.OnClickThreadRunning = false
        W.LastSelectedItemID = 0
    end)
end

function W.CleanName(P)
    if not P then
        return ""
    end
    local j = tostring(P)
    j = j:gsub("%[.-%]", "")
    j = j:gsub("%(.-%)", "")
    j = j:gsub("`.", "")
    j = j:gsub("`", "")
    j = j:gsub("%s+", " ")
    return j:match("^%s*(.-)%s*$") or ""
end

function W.GetPlayerNameByNetID(P)
    local j = "Player"
    local Y, X = pcall(GetPlayerList)
    if Y and type(X) == "table" then
        for Y, X in pairs(X) do
            if X.netid == tonumber(P) then
                local P = X.name or "Player"
                local Y = W.CleanName(P)
                j = (Y ~= "") and Y or P
                break
            end
        end
    end
    return j
end

function W.ToggleWrench(P, j)
    local Y = { "Pull"; "Kick", "Ban", "Trade" }
    local X = j and "Right Click" or "Left Click"
    if j then
        if W.WrenchModeRight ~= 0 then
            SendPacket(2, "action|input\n|text|`c[WinProxy]: `4Disabled " .. (X .. (" Wrench " .. ((Y[W.WrenchModeRight] or "Unknown")))))
        end
        if W.WrenchModeRight == P then
            W.WrenchModeRight = 0
        else
            W.WrenchModeRight = P
            SendPacket(2, "action|input\n|text|`c[WinProxy]: `2Enabled " .. (X .. (" Wrench " .. ((Y[P] or "Unknown")))))
        end
    else
        if W.WrenchMode ~= 0 then
            SendPacket(2, "action|input\n|text|`c[WinProxy]: `4Disabled " .. (X .. (" Wrench " .. ((Y[W.WrenchMode] or "Unknown")))))
        end
        if W.WrenchMode == P then
            W.WrenchMode = 0
        else
            W.WrenchMode = P
            SendPacket(2, "action|input\n|text|`c[WinProxy]: `2Enabled " .. (X .. (" Wrench " .. ((Y[P] or "Unknown")))))
        end
    end
    W.SaveConfig(true)
end

function W.DoDonate(P, j)
    if not W.DonateMode or W.DonateBoxX == 0 then
        return W.LocalChat("`c[WinProxy]: `4Enable /dmode and set a box position first!")
    end
    local Y = ""
    if P == 242 then
        Y = "`9World Locks"
    elseif P == 1796 then
        Y = "`cDiamond Locks"
    elseif P == 7188 then
        Y = "`eBlue Gem Locks"
    else
        Y = "`bBlack Gem Locks"
    end
    if j > 0 then
        if W.GetItemCount(P) >= j then
            SendPacket(2, "action|dialog_return\ndialog_name|donate_item|\nx|" .. (W.DonateBoxX .. ("|\ny|" .. (W.DonateBoxY .. ("|\nitem|" .. (P .. ("|\ndoncount|" .. (j .. "|\noptNote|"))))))))
            W.LocalChat("`c[WinProxy]: `9Donating `4" .. (j .. (" " .. (Y .. "`9..."))))
        else
            W.LocalChat("`c[WinProxy]: `4You don\'t have enough " .. (Y .. "!"))
        end
    end
end

function W.DonateAllLocks()
    if not W.DonateMode or W.DonateBoxX == 0 then
        return W.LocalChat("`c[WinProxy]: `4Enable /dmode and set a box position first!")
    end
    RunThread(function()
        local P = {
            W.GetIcon("Creativeps Black Gem Lock", 11550), W.GetIcon("Creativeps Blue Gem Lock", 7188);
            W.GetIcon("Creativeps Diamond Lock", 1796); W.GetIcon("Creativeps World Lock", 242)
        }
        local j = 0
        for P, Y in ipairs(P) do
            local X = W.GetItemCount(Y)
            if X > 0 then
                SendPacket(2, "action|dialog_return\ndialog_name|donate_item|\nx|" .. (W.DonateBoxX .. ("|\ny|" .. (W.DonateBoxY .. ("|\nitem|" .. (Y .. ("|\ndoncount|" .. (X .. "|\noptNote|"))))))))
                j = j + 1
                Sleep(750)
            end
        end
        if j > 0 then
            W.LocalChat("`c[WinProxy]: `9Successfully put all locks into the Donation Box!")
        else
            W.LocalChat("`c[WinProxy]: `4You don\'t have any locks to donate!")
        end
    end)
end

function W.FastTradeAdd(P, j)
    local Y = ""
    if P == 242 then
        Y = "`9World Locks"
    elseif P == 1796 then
        Y = "`cDiamond Locks"
    elseif P == 7188 then
        Y = "`eBlue Gem Locks"
    else
        Y = "`bBlack Gem Locks"
    end
    if j > 0 then
        if W.GetItemCount(P) >= j then
            SendPacket(2, "action|dialog_return\ndialog_name|trade\nitem_trade|" .. (P .. ("|\nitem_count|" .. j)))
            W.LocalChat("`c[WinProxy]: `9You\'ve Put `4" .. (j .. (" " .. (Y .. " `9to the Trade`4!"))))
        else
            W.LocalChat("`c[WinProxy]: `4You don\'t have enough " .. (Y .. "`4!"))
        end
    end
end

function W.TradeAllLocks()
    RunThread(function()
        local P = {
            W.GetIcon("Creativeps Black Gem Lock", 11550), W.GetIcon("Creativeps Blue Gem Lock", 7188),
            W.GetIcon("Creativeps Diamond Lock", 1796), W.GetIcon("Creativeps World Lock", 242)
        }
        local j = 0
        for P, Y in ipairs(P) do
            local X = W.GetItemCount(Y)
            if X > 0 then
                SendPacket(2, "action|dialog_return\ndialog_name|trade\nitem_trade|" .. (Y .. ("|\nitem_count|" .. X)))
                j = j + 1
                Sleep(750)
            end
        end
        if j > 0 then
            W.LocalChat("`c[WinProxy]: `9Successfully added all locks to Trade!")
        else
            W.LocalChat("`c[WinProxy]: `4You don\'t have any locks to trade!")
        end
    end)
end

function W.TradeClearLocks()
    RunThread(function()
        local P = {
            W.GetIcon("Creativeps Black Gem Lock", 11550); W.GetIcon("Creativeps Blue Gem Lock", 7188);
            W.GetIcon("Creativeps Diamond Lock", 1796); W.GetIcon("Creativeps World Lock", 242)
        }
        for P, j in ipairs(P) do
            SendPacket(2, "action|rem_trade\nitemID|" .. (j .. "\n"))
            Sleep(750)
        end
        W.LocalChat("`c[WinProxy]: `9Cleared all locks from Trade window!")
    end)
end

function W.SetSkinColor(P, j, Y, X)
    local M = math.max(0, math.min(255, math.floor(((P or 1)) * 255)))
    local z = math.max(0, math.min(255, math.floor(((j or 1)) * 255)))
    local o = math.max(0, math.min(255, math.floor(((Y or 1)) * 255)))
    local q = math.max(0, math.min(255, math.floor(((1 - ((X or 1)))) * 255)))
    local S = string.format("action|dialog_return\ndialog_name|skinpicker\nred|%d\ngreen|%d\nblue|%d\ntransparency|%d", M, z, o, q)
    SendPacket(2, S)
end

local function e(P, j, Y)
    local X = Y * j
    local M = X * ((1 - math.abs(((P / 60)) % 2 - 1)))
    local z = Y - X
    local o, q, S = 0, 0, 0
    if P < 60 then
        o, q, S = X, M, 0
    elseif P < 120 then
        o, q, S = M, X, 0
    elseif P < 180 then
        o, q, S = 0, X, M
    elseif P < 240 then
        o, q, S = 0, M, X
    elseif P < 300 then
        o, q, S = M, 0, X
    else
        o, q, S = X, 0, M
    end
    return math.floor(((o + z)) * 255), math.floor(((q + z)) * 255), math.floor(((S + z)) * 255)
end

local v = {
    3370516479, 3033464831, 2864971775, 2527912447; 2190853119, 2022356223; 1685231359; 1348231359; 1348231359;
    1685231359, 2022356223, 2190853119, 2527912447, 2864971775, 3033464831; 3370516479
}

function W.ManageSkinEffects()
    if W.SkinEffectRunning then
        return
    end
    W.SkinEffectRunning = true
    RunThread(function()
        local P = 0
        while W.RainbowSkin or W.BlinkSkin do
            if W.RainbowSkin then
                P = ((P + 12)) % 360
                local j, Y, X = e(P, 1, 1)
                SendPacket(2, "action|dialog_return\ndialog_name|skinpicker\nred|" .. (j .. ("\ngreen|" .. (Y .. ("\nblue|" .. (X .. "\ntransparency|0\n"))))))
                Sleep(100)
            elseif W.BlinkSkin then
                for P, j in ipairs(v) do
                    if not W.BlinkSkin then
                        break
                    end
                    SendPacket(2, "action|setSkin\ncolor|" .. j)
                    Sleep(150)
                end
            end
        end
        W.SkinEffectRunning = false
    end)
end

function W.CalculateMath(P)
    local j = P:gsub("[^%d%+%-%*%/%.%(%)%%]", "")
    if j == "" then
        W.CalcResult = "`4Error: Invalid input!"
        return false, j, nil
    end
    local Y = (j:gsub("([%d%.]+)([%+%-])([%d%.]+)%%", "%1%2(%1*%3/100)")):gsub("([%d%.]+)%%", "(%1/100)")
    local X = load("return " .. Y)
    if X then
        local P, Y = pcall(X)
        if P and type(Y) == "number" then
            local P = ""
            if Y % 1 == 0 then
                P = string.format("%d", Y)
            else
                P = string.format("%g", Y)
            end
            local X = "`w" .. (j .. (" = `2" .. P))
            W.CalcResult = X
            table.insert(W.CalcLogs, 1, X)
            if #W.CalcLogs > 5 then
                table.remove(W.CalcLogs, 6)
            end
            return true, j, P
        end
    end
    W.CalcResult = "`4Error: Math calculation failed!"
    return false, j, nil
end

function W.SearchItem(P)
    W.SearchItemResults = {}
    if not P or P == "" then
        return
    end
    local j = P:lower()
    local Y = tonumber(P)
    local X = 0
    for P, M in pairs(W.ItemDB) do
        if Y and M == Y then
            table.insert(W.SearchItemResults, { name = P; id = M })
            X = X + 1
        elseif not Y and P:find(j) then
            table.insert(W.SearchItemResults, { name = P; id = M })
            X = X + 1
        end
        if X >= 100 then
            break
        end
    end
    table.sort(W.SearchItemResults, function(P, j)
        return P.id < j.id
    end)
end

-- ========================================================================
-- SECTION 7: Automation threads (fish, surgery, crime, spam, SB/SDB)
-- ========================================================================

function W.ManageAutoFishThread()
    if W.FishThreadRunning then
        return
    end
    W.FishThreadRunning = true
    RunThread(function()
        W.LocalChat("`c[WinProxy]: `9Auto Fish Started! `wMake sure you are standing near water.")
        while W.AutoFish do
            local P = GetLocal()
            if not P then
                Sleep(500)
            else
                if W.GetItemCount(W.FishBaitID) <= 0 then
                    W.LocalChat("`c[WinProxy]: `4[WARNING] `wOut of Bait (ID: " .. (W.FishBaitID .. ")! Stopping Auto Fish."))
                    W.AutoFish = false
                    break
                end
                W.FishAction = "Casting Bait..."
                W.FishStats.cast = W.FishStats.cast + 1
                local j = math.floor(P.pos.x / 32) + ((W.FishDirIdx == 1 and 1 or -1))
                local Y = math.floor(P.pos.y / 32) + 1
                SendPacketRaw(false, { type = 3, value = W.FishBaitID; px = j, py = Y, x = P.pos.x, y = P.pos.y })
                W.FishAction = "Waiting for fish..."
                W.FishBite = false
                local X = 0
                while W.AutoFish and (not W.FishBite and X < 450) do
                    Sleep(100)
                    X = X + 1
                end
                if W.FishBite and W.AutoFish then
                    W.FishAction = "Reeling in!"
                    SendPacketRaw(false, { type = 3; value = W.FishBaitID; px = j; py = Y; x = P.pos.x, y = P.pos.y })
                    Sleep(400)
                end
            end
        end
        W.FishThreadRunning = false
        W.FishAction = "Stopped."
        W.FishBite = false
    end)
end

function W.OnSurgerySuccess()
    if not W.IsSurging then
        return
    end
    W.IsSurging = false
    W.SurgStats.success = W.SurgStats.success + 1
    W.SurgAction = "Surgery Successful!"
    SendPacket(2, "action|input\n|text|`#" .. (W.SurgStats.success .. " Surg Done `2#WinProxy"))
end

W.LastBypassTime = 0
W.IsBypassing = false

function W.BypassMalpractice()
    local P = os.time()
    if (P - ((W.LastBypassTime or 0))) < 2 or W.IsBypassing then
        return
    end
    W.LastBypassTime = P
    W.IsBypassing = true
    W.IsSurging = true
    W.SurgStats.fail = W.SurgStats.fail + 1
    W.SurgAction = "Bypassing Malpractice..."
    RunThread(function()
        Sleep(150)
        if W.SurgAutoModage then
            W.LocalChat("`c[WinProxy]: `4[Malpractice] `9Bypassing with /modage 999...")
            SendPacket(2, "action|input\n|text|/modage 999")
            Sleep(200)
            SendPacket(2, "action|input\n|text|/modage 60")
        end
        if W.SurgUseLegalBrief then
            W.LocalChat("`c[WinProxy]: `4[Malpractice] `9Using Legal Brief (3172)...")
            local P = GetLocal()
            local j = P and math.floor(P.pos.x / 32) or 0
            local Y = P and math.floor(P.pos.y / 32) or 0
            SendPacketRaw(false, { type = 10, value = 3172; px = j; py = Y, x = j * 32, y = Y * 32 })
            Sleep(200)
            SendPacketRaw(false, { type = 10; value = 3172 })
        end
        if not W.SurgAutoModage and not W.SurgUseLegalBrief then
            W.LocalChat("`c[WinProxy]: `4[Malpractice] `9Bypassing with /modage 999...")
            SendPacket(2, "action|input\n|text|/modage 999")
            Sleep(200)
            SendPacket(2, "action|input\n|text|/modage 60")
        end
        Sleep(800)
        W.IsBypassing = false
        W.IsSurging = false
    end)
end

function W.TrashExcessTools()
    local P = { 1240; 1256; 1266, 1262; 1264; 4314, 1260, 1268; 1258, 1270 }
    for P, j in ipairs(P) do
        local Y = W.GetItemCount(j)
        if Y >= 240 then
            local P = Y - 200
            W.LocalChat("`c[WinProxy]: `9[Auto Trash] `wTrashing `e" .. (P .. (" `wof item `2#" .. (j .. " `wto free space."))))
            SendPacket(2, "action|dialog_return\ndialog_name|trash\nitem_trash|" .. (j .. ("|\nitem_count|" .. (P .. "\n"))))
            Sleep(250)
        end
    end
end

function W.PerformSurgAntiStuck(P)
    if W.IsRecoveringAntiStuck then
        return
    end
    W.IsRecoveringAntiStuck = true
    W.IsSurging = false
    W.SurgStartTime = 0
    W.SurgAction = "Anti-Stuck: Rejoining World..."
    W.LocalChat("`c[WinProxy]: `4[" .. (((P or "Timeout 20s")) .. "] `9Re-warping world & returning to spot..."))
    local j = ""
    local Y, X = pcall(GetWorld)
    if Y and (X and (X.name and X.name ~= "")) then
        j = X.name
    end
    RunThread(function()
        if j ~= "" then
            SendPacket(3, "action|join_request\nname|" .. (j .. "\ninvitedWorld|0"))
            Sleep(250)
            SendPacket(2, "action|input\n|text|/warp " .. j)
            Sleep(3000)
            if W.SurgPos and (W.SurgPos.x and W.SurgPos.y) then
                W.LocalChat("`c[WinProxy]: `9Pathfinding back to surgery tile (" .. (W.SurgPos.x .. (", " .. (W.SurgPos.y .. ")..."))))
                pcall(FindPath, W.SurgPos.x, W.SurgPos.y)
                Sleep(2000)
            end
            if W.SurgAutoModage then
                W.LocalChat("`c[WinProxy]: `9[Anti-Stuck] Applying /modage 999 & /modage 60...")
                SendPacket(2, "action|input\n|text|/modage 999")
                Sleep(200)
                SendPacket(2, "action|input\n|text|/modage 60")
                Sleep(500)
            end
            if W.SurgUseLegalBrief then
                W.LocalChat("`c[WinProxy]: `9[Anti-Stuck] Using Legal Brief (3172)...")
                local P = GetLocal()
                local j = P and math.floor(P.pos.x / 32) or 0
                local Y = P and math.floor(P.pos.y / 32) or 0
                SendPacketRaw(false, { type = 10, value = 3172, px = j; py = Y; x = j * 32; y = Y * 32 })
                Sleep(200)
                SendPacketRaw(false, { type = 10; value = 3172 })
                Sleep(500)
            end
            if not W.SurgAutoModage and not W.SurgUseLegalBrief then
                SendPacket(2, "action|input\n|text|/modage 999")
                Sleep(200)
                SendPacket(2, "action|input\n|text|/modage 60")
                Sleep(500)
            end
        end
        W.IsRecoveringAntiStuck = false
        W.IsSurging = false
        W.SurgStartTime = 0
        if W.SurgTarget then
            W.SurgAction = "Waiting for target..."
        end
    end)
end

function W.ManageAutoSurgThread()
    if W.SurgThreadRunning then
        return
    end
    W.SurgThreadRunning = true
    RunThread(function()
        W.LocalChat("`c[WinProxy]: `9Auto Surg Started! `wWrench a player or surgical bed to begin.")
        W.SurgAction = "Waiting for target..."
        W.SurgStartTime = os.time()
        local P = GetLocal()
        if P and P.pos then
            W.SurgPos = { x = math.floor(P.pos.x / 32); y = math.floor(P.pos.y / 32) }
        end
        local j = { 1240; 1258, 1260; 1262; 1264; 1266, 1268, 1270 }
        while W.AutoSurg do
            if W.SurgAutoTrash then
                W.TrashExcessTools()
            end
            if W.SurgAutoBuy then
                local P = false
                for j, Y in ipairs(j) do
                    local X = W.GetItemCount(Y)
                    if X < W.SurgCardThreshold then
                        P = true
                        break
                    end
                end
                if P then
                    W.SurgAction = "Buying Surg Kits..."
                    W.LocalChat("`c[WinProxy]: `wTools dropped below " .. (W.SurgCardThreshold .. "! Restocking..."))
                    local Y = 0
                    while P and (Y < 15 and W.AutoSurg) do
                        if W.SurgAutoTrash then
                            W.TrashExcessTools()
                        end
                        SendPacket(2, "action|buy\nitem|buy_surgkit")
                        Sleep(1200)
                        P = false
                        for j, Y in ipairs(j) do
                            if W.GetItemCount(Y) < W.SurgCardThreshold then
                                P = true
                                break
                            end
                        end
                        Y = Y + 1
                    end
                    if P then
                        W.LocalChat("`c[WinProxy]: `4[WARNING] `wFailed to restock! Stopping Auto Surg.")
                        W.AutoSurg = false
                        break
                    else
                        if not W.SurgTarget then
                            W.SurgAction = "Waiting for target..."
                        end
                    end
                end
            end
            if W.SurgTarget and (not W.IsSurging and (not W.IsBypassing and not W.IsRecoveringAntiStuck)) then
                SendPacket(2, "action|dialog_return\ndialog_name|popup\nnetID|" .. (W.SurgTarget .. "|\nbuttonClicked|surgery\n\n"))
            end
            if W.IsSurging and (W.SurgStartTime > 0 and (os.time() - W.SurgStartTime > 20)) then
                W.PerformSurgAntiStuck("Surgery Timeout 20s")
            end
            Sleep(800)
        end
        W.SurgThreadRunning = false
        W.SurgAction = "Stopped."
        W.SurgTarget = nil
        W.IsSurging = false
    end)
end

function W.ScanVillains()
    W.CrimeVillains = {}
    local P = GetWorld()
    if not P then
        return
    end
    for j = 0, P.height - 1, 1 do
        for P = 0, P.width - 1, 1 do
            local Y = GetTile(P, j)
            if Y and Y.fg == 2302 then
                local X = "Unknown Villain"
                if Y.extra and (Y.extra.label2 and Y.extra.label2 ~= "") then
                    X = (((Y.extra.label2:gsub("`.", "")):gsub("!", "")):gsub("%s+", " ")):match("^%s*(.-)%s*$")
                end
                table.insert(W.CrimeVillains, { name = X; x = P; y = j })
            end
        end
    end
    W.LocalChat("`c[WinProxy]: `9Crime Scan complete! Found `2" .. (#W.CrimeVillains .. " `9villains."))
end

function W.ManageAutoCrimeThread()
    if W.CrimeThreadRunning then
        return
    end
    W.CrimeThreadRunning = true
    RunThread(function()
        W.ScanVillains()
        if #W.CrimeVillains == 0 then
            W.CrimeAction = "No villains found. Stopped."
            W.AutoCrime = false
            W.CrimeThreadRunning = false
            return
        end
        local function P(P, j)
            for Y = 1, 100, 1 do
                local X = GetLocal()
                if not X then
                    return false
                end
                local M = math.floor(X.pos.x / 32)
                local z = math.floor(X.pos.y / 32)
                if M == P and z == j then
                    return true
                end
                local o, q = P - M, j - z
                local S = math.sqrt(o * o + q * q)
                if S > 3 then
                    FindPath(M + math.floor(((o / S)) * 3), z + math.floor(((q / S)) * 3))
                else
                    FindPath(P, j)
                end
                Sleep(150)
            end
            return false
        end
        for j, Y in ipairs(W.CrimeVillains) do
            if not W.AutoCrime then
                break
            end
            if W.AutoBuyCrimeCards then
                local P = false
                for j, Y in ipairs(W.CrimeDeck) do
                    if W.GetItemCount(Y) < W.CrimeCardThreshold then
                        P = true
                        break
                    end
                end
                if P then
                    W.CrimeAction = "Buying Crime Cards..."
                    local j = 0
                    while P and (j < 15 and W.AutoCrime) do
                        SendPacket(2, "action|buy\nitem|" .. W.CrimePackName)
                        Sleep(1000)
                        P = false
                        for j, Y in ipairs(W.CrimeDeck) do
                            if W.GetItemCount(Y) < W.CrimeCardThreshold then
                                P = true
                                break
                            end
                        end
                        j = j + 1
                    end
                    if P then
                        W.LocalChat("`c[WinProxy]: `4[WARNING] `wFailed to buy enough Crime Cards!")
                        W.AutoCrime = false
                        break
                    end
                end
            else
                local P = false
                for j, Y in ipairs(W.CrimeDeck) do
                    if W.GetItemCount(Y) < 1 then
                        P = true
                        break
                    end
                end
                if P then
                    W.LocalChat("`c[WinProxy]: `4[WARNING] `wYou ran out of Crime Cards! Stopping.")
                    W.AutoCrime = false
                    break
                end
            end
            W.CrimeAction = "Moving to " .. (Y.name .. (" (" .. (j .. ("/" .. (#W.CrimeVillains .. ")")))))
            W.CrimeTarget = { name = Y.name, x = Y.x; y = Y.y }
            P(Y.x, Y.y)
            Sleep(500)
            local X = "action|dialog_return\ndialog_name|crimewave\nx|" .. (Y.x .. ("|\ny|" .. (Y.y .. "|\n")))
            for P, j in ipairs(W.CrimeDeck) do
                X = X .. (j .. "|1\n")
            end
            SendPacket(2, X)
            Sleep(1000)
            local M = 2294
            if Y.name:find("The Harvester") or Y.name:find("Professor Pummel") or Y.name:find("Devil Ham") or Y.name:find("Ban Hammer") then
                M = 2316
            end
            W.IsFightingCrime = true
            W.CrimeWon = false
            W.CrimeAction = "Fighting " .. (Y.name .. "!")
            while W.IsFightingCrime and W.AutoCrime do
                SendPacket(2, "action|dialog_return\ndialog_name|crimewave\nx|" .. (Y.x .. ("|\ny|" .. (Y.y .. ("|\nbuttonClicked|" .. M)))))
                Sleep(150)
                local P = GetTile(Y.x, Y.y)
                if P and P.fg ~= 2302 then
                    W.IsFightingCrime = false
                    W.CrimeAction = "Done fighting " .. Y.name
                end
            end
            W.CrimeTarget = nil
            Sleep(500)
        end
        W.AutoCrime = false
        W.CrimeAction = "Finished clearing villains!"
        W.CrimeThreadRunning = false
    end)
end

function W.ManageSpamThread()
    if W.SpamThreadRunning then
        return
    end
    W.SpamThreadRunning = true
    RunThread(function()
        local P = 1
        while W.SpamEnabled do
            local j = ""
            local Y = #W.SpamTexts
            if Y > 0 then
                local X = 0
                while X < Y do
                    if W.SpamTexts[P] and W.SpamTexts[P] ~= "" then
                        j = W.SpamTexts[P]
                        P = (P % Y) + 1
                        break
                    end
                    P = (P % Y) + 1
                    X = X + 1
                end
            end
            if j ~= "" then
                SendPacket(2, "action|input\n|text|" .. j)
            end
            Sleep(W.SpamInterval)
        end
        W.SpamThreadRunning = false
    end)
end

function W.ToggleSpam(P)
    W.SpamEnabled = P
    if W.SpamEnabled then
        W.LocalChat("`c[WinProxy]: `9Auto-Spam is now `2ON")
        W.ManageSpamThread()
    else
        W.LocalChat("`c[WinProxy]: `9Auto-Spam is now `4OFF")
    end
end

function W.FormatNum(P)
    P = math.floor(P + .5)
    local j = tostring(P)
    local Y = 3
    while Y < #j do
        j = j:sub(1, #j - Y) .. ("," .. j:sub((#j - Y) + 1))
        Y = Y + 4
    end
    return j
end

function W.CleanStr(P)
    local j = string.gsub(P, "`(%S)", "")
    j = string.gsub(j, "`{2}|(~{2})", "")
    j = string.gsub(j, "\\", "\\\\")
    j = string.gsub(j, "\"", "\\\"")
    return j
end

function W.GetSBEndTime()
    if W.SBCount == 0 then
        return W.SBStartTime + ((W.SBMax * W.SBDelay) * 60)
    else
        return W.SBStartTime + ((((W.SBMax - W.SBCount)) * W.SBDelay) * 60)
    end
end

function W.ResetSB()
    W.SBCount = 0
    W.SBTotPending = 0
    W.SBTotSucceed = 0
    W.SBUsedGems = 0
    W.SBTotUsedGems = 0
    W.SBUsedBGems = 0
    W.SBTotUsedBGems = 0
    W.SBPending = false
end

function W.ResetSDB()
    W.SDBCount = 0
end

function W.StartSB(P)
    if W.SBMax <= 0 then
        W.LocalChat("`c[WinProxy]: `4Error: SB Amount must be greater than 0!")
        W.SBEnabled = false
        return
    end
    if W.SBCount >= W.SBMax or P then
        W.ResetSB()
    end
    W.SBEnabled = true
    W.SBStartTime = os.time()
    W.ManageSBThread()
end

function W.StopSB()
    W.SBEnabled = false
    W.LocalChat("`c[WinProxy]: `4STOPPING `0SUPER BROADCAST")
end

function W.StartSDB(P)
    if W.SDBMax <= 0 then
        W.LocalChat("`c[WinProxy]: `4Error: SDB Amount must be greater than 0!")
        W.SDBEnabled = false
        return
    end
    if W.SDBCount >= W.SDBMax or P then
        W.ResetSDB()
    end
    W.SDBEnabled = true
    W.ManageSDBThread()
end

function W.StopSDB()
    W.SDBEnabled = false
    W.LocalChat("`c[WinProxy]: `4STOPPING `0SUPER DUPER BROADCAST")
end

function W.ManageSBThread()
    if W.SBThreadRunning then
        return
    end
    if W.SBMax <= 0 then
        W.LocalChat("`c[WinProxy]: `4Error: SB Amount must be greater than 0!")
        W.SBEnabled = false
        return
    end
    if W.SBCount >= W.SBMax then
        W.ResetSB()
    end
    W.SBThreadRunning = true
    RunThread(function()
        W.SBWorld = GetWorld() and (GetWorld()).name or "UNKNOWN"
        W.LocalChat("`c[WinProxy]: `eSuper Broadcast `2Activated")
        Sleep(1000)
        W.LocalChat("`c[WinProxy]: `9World `0= " .. W.SBWorld)
        Sleep(1000)
        W.LocalChat("`c[WinProxy]: `9Duration `0= " .. (math.floor(W.SBMax * 3) .. " Minutes!"))
        Sleep(1000)
        while W.SBEnabled and W.SBCount < W.SBMax do
            SendPacket(2, "action|input\n|text|/sb " .. (W.SBText .. " `c#WinProxy"))
            W.SBCount = W.SBCount + 1
            local P = W.SBMax - W.SBCount
            local j = (W.SBMax * 3) - (W.SBCount * 3)
            local Y = W.GetSBEndTime()
            Sleep(1000)
            if not W.SBPending then
                if W.SBUseGems and not W.SBUseBGems then
                    W.SBTotSucceed = W.SBTotSucceed + 1
                    W.LocalChat("`c[WinProxy]: `eSB `2Succeed`4!")
                    Sleep(1000)
                    W.LocalChat("`c[WinProxy]: `9Last Used `0= `6" .. (W.FormatNum(W.SBUsedGems) .. " `2Gems"))
                    Sleep(1000)
                    W.LocalChat("`c[WinProxy]: `9Total Used `0= `6" .. (W.FormatNum(W.SBTotUsedGems) .. " `2Gems"))
                elseif W.SBUseBGems and not W.SBUseGems then
                    W.SBTotSucceed = W.SBTotSucceed + 1
                    W.LocalChat("`c[WinProxy]: `eSB `2Succeed`4!")
                    Sleep(1000)
                    W.LocalChat("`c[WinProxy]: `9Last Used `0= `6" .. (W.SBUsedBGems .. " `bBGems"))
                    Sleep(1000)
                    W.LocalChat("`c[WinProxy]: `9Total Used `0= `6" .. (W.FormatNum(W.SBTotUsedBGems) .. " `bBGems"))
                end
                Sleep(1000)
                W.LocalChat("`c[WinProxy]: `9Total `0: `2" .. (W.SBCount .. ("`0/`4" .. (W.SBMax .. ("`0, `4Remain `0: `4" .. P)))))
                Sleep(1000)
                W.LocalChat("`c[WinProxy]: `2Start `0: `6" .. (os.date(" %I:%M %p", W.SBStartTime) .. ("`0, `4End `0: `6" .. os.date(" %I:%M %p", Y))))
            else
                W.SBTotPending = W.SBTotPending + 1
                W.LocalChat("`c[WinProxy]: `eSB `4Pending `9Please Wait`4!")
                Sleep(5000)
                W.SBPending = false
            end
            Sleep(1000)
            W.LocalChat("`c[WinProxy]: `9Time Left `0: `6" .. (j .. " `9Minutes!"))
            if W.WebhookSB ~= "" then
                Sleep(1000)
                W.LocalChat("`c[WinProxy]: `9Sending Discord Webhook...")
                local j = (GetPlayerInfo() and (GetPlayerInfo()).gems) or 0
                local Y = (GetLocal() and ((GetLocal()).name and (GetLocal()).name:gsub("`.", ""))) or "Unknown"
                local X = j + W.SBTotUsedGems
                local M = W.SBLeftBGems + W.SBTotUsedBGems
                local z = "https://media.discordapp.net/attachments/1438466585005391923/1481856877410390157/WinPFP-Animated.gif"
                local o = "https://cdn.discordapp.com/emojis/1481856719230603354.webp"
                local q = "{\"username\": \"WinProxy SB\", \"avatar_url\": \"" .. (z .. ("\", \"embeds\": [{\"title\": \"<a:Megaphone:1456376952251351131> Super Broadcast Status\", \"color\": 5763719, \"fields\": [{\"name\": \"Account Information\", \"value\": \"<:Profile:1487287110057594900> **Name : " .. (Y .. ("**\\n<:Gems:1369733901278511124> **Gems : " .. (W.FormatNum(X) .. ("**\\n<:BlackGems:1487276323809530107> **Black Gems : " .. (W.FormatNum(M) .. ("**\", \"inline\": false}, {\"name\": \"Location\", \"value\": \"<a:World:1456376942189346947> **World : " .. (W.SBWorld .. ("**\\n<:Textflip:1261276491023646892> **Text : " .. (W.CleanStr(W.SBText) .. ("**\", \"inline\": false}, {\"name\": \"SB Information\", \"value\": \"\240\159\142\175 **Target : " .. (W.SBMax .. ("**\\n<a:Correct:1456306220796215402> **Sent : " .. (W.SBCount .. ("**\\n<a:Loading:1456634326450966599> **Remain : " .. (P .. ("**\", \"inline\": false}, {\"name\": \"<:Gems:1369733901278511124> Gems Usage\", \"value\": \"**Used : " .. (W.FormatNum(W.SBUsedGems) .. ("**\\n**Remain : " .. (W.FormatNum(j) .. ("**\\n**Total Used : " .. (W.FormatNum(W.SBTotUsedGems) .. ("**\", \"inline\": true}, {\"name\": \"<:BlackGems:1487276323809530107> Black Gems Usage\", \"value\": \"**Used : " .. (W.FormatNum(W.SBUsedBGems) .. ("**\\n**Remain : " .. (W.FormatNum(W.SBLeftBGems) .. ("**\\n**Total Used : " .. (W.FormatNum(W.SBTotUsedBGems) .. ("**\", \"inline\": true}], \"thumbnail\": {\"url\": \"" .. (z .. ("\"}, \"footer\": {\"text\": \"Time : " .. (os.date("%Y-%m-%d %H:%M:%S") .. ("\", \"icon_url\": \"" .. (o .. "\"}}] }")))))))))))))))))))))))))))))))))))
                MakeRequest(W.WebhookSB, "POST", { ["Content-Type"] = "application/json" }, q)
            end
            if W.SBCount >= W.SBMax then
                W.SBEnabled = false
                W.LocalChat("`c[WinProxy]: `2DONE `eSuper Broadcast `9Completed`4!")
                if W.WebhookSB ~= "" and W.DiscordPingID ~= "" then
                    local P = (GetPlayerInfo() and (GetPlayerInfo()).gems) or 0
                    local j = (GetLocal() and ((GetLocal()).name and (GetLocal()).name:gsub("`.", ""))) or "Unknown"
                    local Y = P + W.SBTotUsedGems
                    local X = W.SBLeftBGems + W.SBTotUsedBGems
                    local M = "https://media.discordapp.net/attachments/1438466585005391923/1481856877410390157/WinPFP-Animated.gif"
                    local z = "https://cdn.discordapp.com/emojis/1481856719230603354.webp"
                    local o = "{\"username\": \"WinProxy SB\", \"avatar_url\": \"" .. (M .. ("\", \"content\": \" <@" .. (W.DiscordPingID .. (">\", \"allowed_mentions\": { \"parse\": [\"users\"]}, \"embeds\": [{\"title\": \"<a:Megaphone:1456376952251351131> Super Broadcast Finished!\", \"color\": 5763719, \"fields\": [{\"name\": \"Account Information\", \"value\": \"<:Profile:1487287110057594900> **Name : " .. (j .. ("**\\n<:Gems:1369733901278511124> **Gems : " .. (W.FormatNum(Y) .. ("**\\n<:BlackGems:1487276323809530107> **Black Gems : " .. (W.FormatNum(X) .. ("**\", \"inline\": false}, {\"name\": \"Location\", \"value\": \"<a:World:1456376942189346947> **World : " .. (W.SBWorld .. ("**\\n<:Textflip:1261276491023646892> **Text : " .. (W.CleanStr(W.SBText) .. ("**\", \"inline\": false}, {\"name\": \"SB Information\", \"value\": \"\240\159\142\175 **Target : " .. (W.SBMax .. ("**\\n<a:Correct:1456306220796215402> **Total Sent : " .. (W.SBCount .. ("**\\n<a:Loading:1456634326450966599> **Remain : 0**\", \"inline\": false}, {\"name\": \"<:Gems:1369733901278511124> Gems Usage\", \"value\": \"**Used : " .. (W.FormatNum(W.SBUsedGems) .. ("**\\n**Remain : " .. (W.FormatNum(P) .. ("**\\n**Total Used : " .. (W.FormatNum(W.SBTotUsedGems) .. ("**\", \"inline\": true}, {\"name\": \"<:BlackGems:1487276323809530107> Black Gems Usage\", \"value\": \"**Used : " .. (W.FormatNum(W.SBUsedBGems) .. ("**\\n**Remain : " .. (W.FormatNum(W.SBLeftBGems) .. ("**\\n**Total Used : " .. (W.FormatNum(W.SBTotUsedBGems) .. ("**\", \"inline\": true}], \"thumbnail\": { \"url\": \"" .. (M .. ("\" }, \"footer\": { \"text\": \"Time : " .. (os.date("%Y-%m-%d %H:%M:%S") .. ("\", \"icon_url\": \"" .. (z .. "\" }}] }")))))))))))))))))))))))))))))))))))
                    MakeRequest(W.WebhookSB, "POST", { ["Content-Type"] = "application/json" }, o)
                end
                if W.SBUseDoneWorld and W.SBDoneWorld ~= "" then
                    SendPacket(2, "action|input\n|text|/warp " .. W.SBDoneWorld)
                end
                break
            else
                local P = 140000
                local j = 0
                while j < P and W.SBEnabled do
                    local Y = (P - j > 500) and 500 or (P - j)
                    Sleep(Y)
                    j = j + Y
                end
            end
        end
        W.SBThreadRunning = false
    end)
end

function W.ManageSDBThread()
    if W.SDBThreadRunning then
        return
    end
    if W.SDBMax <= 0 then
        W.LocalChat("`c[WinProxy]: `4Error: SDB Amount must be greater than 0!")
        W.SDBEnabled = false
        return
    end
    if W.SDBCount >= W.SDBMax then
        W.ResetSDB()
    end
    W.SDBThreadRunning = true
    RunThread(function()
        W.LocalChat("`c[WinProxy]: `9Starting `#" .. (W.SDBMax .. (" `2SDB `9with delay of `#" .. (W.SDBTotalDelay .. " `bMinutes`0."))))
        Sleep(2000)
        while W.SDBEnabled and W.SDBCount < W.SDBMax do
            local P = false
            for j, Y in pairs(GetInventory()) do
                if Y.id == 2480 and Y.amount > 0 then
                    P = true
                    break
                end
            end
            if not P then
                W.LocalChat("`c[WinProxy]: `4You don\'t have any Megaphone in your inventory. SDB Stopped.")
                W.SDBEnabled = false
                break
            end
            W.LocalChat("`c[WinProxy]: `9Executing SDB...")
            Sleep(1000)
            SendPacket(2, "action|dialog_return\ndialog_name|megaphone\nline|" .. (W.SDBLine1 .. ("\nline2|" .. (W.SDBLine2 .. ("\nline3|" .. W.SDBLine3)))))
            W.SDBCount = W.SDBCount + 1
            Sleep(1000)
            W.LocalChat("`c[WinProxy]: `2SDB `9Count `0= `0[`2" .. (W.SDBCount .. ("`0/`4" .. (W.SDBMax .. "`0]"))))
            if W.SDBCount >= W.SDBMax then
                W.SDBEnabled = false
                W.LocalChat("`c[WinProxy]: `2DONE `eSuper Duper Broadcast `9Completed`4!")
                break
            end
            local j = (W.SDBExtraTimer == 0) and 3 or (5 + W.SDBExtraTimer)
            local Y = ((j * 60 - 6)) * 1000
            local X = math.floor(Y / 2)
            local M = 0
            while M < X and W.SDBEnabled do
                local P = (X - M > 500) and 500 or (X - M)
                Sleep(P)
                M = M + P
            end
            if not W.SDBEnabled then
                break
            end
            local z = math.ceil(((Y - M)) / 60000)
            W.LocalChat("`c[WinProxy]: `#" .. (z .. " `bMinutes `9Before Sending `2SDB `9Again`0!"))
            local o = 0
            local q = Y - M
            while o < q and W.SDBEnabled do
                local P = (q - o > 500) and 500 or (q - o)
                Sleep(P)
                o = o + P
            end
        end
        W.SDBThreadRunning = false
    end)
end

-- ========================================================================
-- SECTION 8: Casino modes and BTK/BJ host tools
-- ========================================================================

local function f(P)
    if P == 19 or P == 28 or P == 0 then
        return 0
    end
    return tonumber(string.sub(tostring(math.floor(P / 10) + (P % 10)), -1))
end

local function n(P)
    if P >= 10 then
        return tonumber(string.sub(tostring(P), -1))
    elseif P == 0 then
        return 1
    else
        return P
    end
end

local function C(P)
    if P == 1 or P == 10 or P == 29 then
        return 1
    elseif P == 0 or P == 19 or P == 28 then
        return 0
    else
        return tonumber(string.sub(tostring(math.floor(P / 10) + (P % 10)), -1))
    end
end

local function D(P)
    if P == 0 or P == 19 or P == 28 then
        return 0
    elseif P == 1 or P == 10 or P == 29 then
        return 1
    elseif P == 2 or P == 11 or P == 20 then
        return 2
    elseif P == 3 or P == 12 or P == 21 or P == 30 then
        return 3
    else
        return tonumber(string.sub(tostring(math.floor(P / 10) + (P % 10)), -1))
    end
end

local function i(P)
    local j = P
    if P >= 10 then
        j = tonumber(string.sub(tostring(P), -1))
    end
    if P == 10 or P == 20 or P == 30 then
        j = 0
    elseif P == 19 or P == 29 or P == 9 then
        j = 9
    elseif P == 1 or P == 11 or P == 21 or P == 31 or P == 0 then
        j = 1
    end
    return j
end

function W.GetCasinoText(P, j)
    local Y = ""
    local X = 0
    local M = ""
    local z = j and "`2[REAL] " or "`4[FAKE] "
    if W.CasinoMode == 7 then
        local j = f(P)
        local Y = C(P)
        local X = n(P)
        local M = "`b[`cReme : `b" .. (j .. ("`b] [`cLeme : `b" .. (Y .. ("`b] [`cQeme : `b" .. (X .. "`b]")))))
        if W.CasinoFormatIdx == 2 then
            return z .. ("`9(" .. (P .. (") " .. M)))
        else
            return z .. (M .. (" `9(" .. (P .. ")")))
        end
    end
    if W.CasinoMode == 1 then
        Y = "Reme"
        X = f(P)
        if X == 0 then
            M = "`2[WIN x3]"
        elseif X == 1 then
            M = "`4[Lose]"
        end
    elseif W.CasinoMode == 2 then
        Y = "Qeme"
        X = n(P)
        if X == 0 then
            M = "`2[WIN x3]"
        elseif X == 1 or P == 0 then
            M = "`4[Lose]"
        end
    elseif W.CasinoMode == 3 then
        Y = "Leme"
        X = C(P)
        if X == 1 then
            M = "`2[WIN x3]"
        elseif X == 0 then
            M = "`2[WIN x4]"
        elseif X == 2 or X == 9 then
            M = "`4[Lose]"
        end
    elseif W.CasinoMode == 4 then
        Y = "Leme S"
        X = C(P)
        if P == 0 then
            M = "`4[Lose]"
        elseif X == 0 then
            M = "`2[WIN x5]"
        elseif X == 1 then
            M = "`2[WIN x3]"
        elseif X == 2 or X == 9 then
            M = "`4[Lose]"
        end
    elseif W.CasinoMode == 5 then
        Y = "Ceme"
        X = D(P)
        if X == 0 then
            M = "`2[WIN x4]"
        elseif X == 1 then
            M = "`4[Lose]"
        elseif X == 2 then
            M = "`2[WIN x3]"
        elseif X == 3 then
            M = "`b[HOSTER WIN]"
        end
    elseif W.CasinoMode == 6 then
        Y = "Lewa"
        X = i(P)
        if X == 9 then
            M = "`2[WIN x3]"
        elseif X == 0 then
            M = "`2[WIN x" .. (W.CasinoLewaMulti .. "]")
        end
        if W.CasinoLewaMulti == 5 and X == 1 then
            M = "`4[Lose]"
        elseif W.CasinoLewaMulti == 6 and ((X == 1 or X == 2)) then
            M = "`4[Lose]"
        elseif W.CasinoLewaMulti == 7 and ((X == 1 or X == 2 or X == 3)) then
            M = "`4[Lose]"
        end
    end
    local o = j and "`2[REAL] " or "`4[FAKE] "
    local q = "`b[`c" .. (Y .. (" `0: `b" .. (X .. "`b]")))
    if M ~= "" then
        q = q .. (" " .. M)
    end
    if W.CasinoFormatIdx == 2 then
        return o .. ("`9(" .. (P .. (") " .. q)))
    else
        return o .. (q .. (" `9(" .. (P .. ")")))
    end
end

function W.ToggleCasino(P)
    if W.CasinoMode == P then
        W.CasinoMode = 0
        SendPacket(2, "action|input\n|text|`c[WinProxy]: `4Disabled Casino Mode")
    else
        W.CasinoMode = P
        local j = { "Reme", "Qeme"; "Leme", "Leme S", "Ceme", "Lewa"; "All" }
        SendPacket(2, "action|input\n|text|`c[WinProxy]: `2Enabled " .. (j[P] .. " Mode"))
    end
    W.SaveConfig(true)
end

function W.SetBTKCoordByTouch(P, j, Y)
    if P == "Host Center" then
        W.BTK_CenterX = j
        W.BTK_CenterY = Y
    elseif P == "Bet P1" then
        W.BTK_Bet1X = j
        W.BTK_Bet1Y = Y
    elseif P == "Bet P2" then
        W.BTK_Bet2X = j
        W.BTK_Bet2Y = Y
    elseif P == "Break P1 (Mid)" then
        W.BTK_Break1X = j
        W.BTK_Break1Y = Y
    elseif P == "Break P2 (Mid)" then
        W.BTK_Break2X = j
        W.BTK_Break2Y = Y
    elseif P == "Tax Drop (Mid)" then
        W.BTK_TaxX = j
        W.BTK_TaxY = Y
    elseif P == "Magplant (Top)" then
        W.BTK_MagX = j
        W.BTK_MagY = Y
    end
    W.LocalChat("`c[WinProxy]: `2" .. (P .. (" `9set to `2(" .. (j .. (", " .. (Y .. ")"))))))
    W.BTK_SelectingTarget = nil
    W.SaveConfig(true)
end

function W.BTK_GetPositions()
    local P, j = W.BTK_CenterX, W.BTK_CenterY
    return {
        b1 = { x = W.BTK_Bet1X, y = W.BTK_Bet1Y };
        b2 = { x = W.BTK_Bet2X; y = W.BTK_Bet2Y };
        p1 = {
            { x = W.BTK_Break1X - 1, y = W.BTK_Break1Y };
            { x = W.BTK_Break1X; y = W.BTK_Break1Y },
            { x = W.BTK_Break1X + 1; y = W.BTK_Break1Y }
        },
        p2 = {
            { x = W.BTK_Break2X - 1, y = W.BTK_Break2Y },
            { x = W.BTK_Break2X; y = W.BTK_Break2Y },
            { x = W.BTK_Break2X + 1, y = W.BTK_Break2Y }
        };
        tax = {
            { x = W.BTK_TaxX - 1, y = W.BTK_TaxY };
            { x = W.BTK_TaxX; y = W.BTK_TaxY };
            { x = W.BTK_TaxX + 1, y = W.BTK_TaxY }
        };
        drop1 = { x = W.BTK_Bet1X - 1; y = W.BTK_Bet1Y };
        drop2 = { x = W.BTK_Bet2X + 1, y = W.BTK_Bet2Y };
        center = { x = P, y = j }
    }
end

function W.ParseBetAt(P)
    if P.x == 0 and P.y == 0 then
        return 0
    end
    local j = 0
    for Y, X in pairs(GetObjectList()) do
        if math.floor(X.pos.x / 32) == P.x and math.floor(X.pos.y / 32) == P.y then
            if X.id == W.GetIcon("Creativeps Black Gem Lock", 11550) then
                j = j + (X.amount * 10000)
            elseif X.id == W.GetIcon("Creativeps Blue Gem Lock", 7188) then
                j = j + (X.amount * 100)
            elseif X.id == W.GetIcon("Creativeps Diamond Lock", 1796) then
                j = j + X.amount
            end
        end
    end
    return j
end

function W.CountGemsAt(P)
    local j = 0
    for Y, X in pairs(GetObjectList()) do
        if X.id == 112 then
            local Y, M = math.floor(X.pos.x / 32), math.floor(X.pos.y / 32)
            for P, z in ipairs(P) do
                if Y == z.x and M == z.y then
                    j = j + X.amount
                    break
                end
            end
        end
    end
    return j
end

function W.PickupTile(P)
    if P.x == 0 and P.y == 0 then
        return
    end
    for j, Y in pairs(GetObjectList()) do
        if math.floor(Y.pos.x / 32) == P.x and math.floor(Y.pos.y / 32) == P.y then
            SendPacketRaw(false, { type = 11, value = Y.oid; x = Y.pos.x, y = Y.pos.y })
        end
    end
end

function W.BTK_PlaceChands(P)
    for P, j in ipairs(P) do
        SendPacketRaw(false, { type = 3; value = 5640, px = j.x; py = j.y; x = j.x * 32; y = j.y * 32 })
        Sleep(150)
    end
end

function W.BTK_ActionTakeRemote()
    if W.BTK_MagX > 0 then
        RunThread(function()
            local P = W.BTK_MagX
            local j = W.BTK_MagY + 1
            FindPath(W.BTK_MagX, W.BTK_MagY)
            Sleep(850)
            SendPacketRaw(false, { type = 3, value = 32; x = P * 32, y = j * 32; px = P; py = j, state = 0 })
            Sleep(500)
            SendPacket(2, "action|dialog_return\ndialog_name|magplant_edit\nx|" .. (P .. ("|\ny|" .. (j .. "|\nbuttonClicked|getRemote"))))
            W.LocalChat("`c[WinProxy]: `9Remote collected from Magplant!")
            Sleep(500)
            local Y = W.BTK_GetPositions()
            FindPath(Y.center.x, Y.center.y)
            Sleep(850)
        end)
    else
        W.LocalChat("`c[WinProxy]: `4Set Magplant coordinates first!")
    end
end

function W.BTK_ActionTakeBets()
    local P = W.BTK_GetPositions()
    W.BTK_P1Bet = W.ParseBetAt(P.b1)
    W.BTK_P2Bet = W.ParseBetAt(P.b2)
    if W.BTK_P1Bet > 0 and W.BTK_P1Bet == W.BTK_P2Bet then
        W.BTK_TotalPrize = ((W.BTK_P1Bet + W.BTK_P2Bet)) * .95
        W.PickupTile(P.b1)
        W.PickupTile(P.b2)
        W.LocalChat("`c[WinProxy]: `9Bets taken! Prize (after 5% tax): `2" .. (W.BTK_TotalPrize .. " DLs"))
    else
        W.LocalChat("`c[WinProxy]: `4Bets un-equal or empty! (P1: " .. (W.BTK_P1Bet .. (", P2: " .. (W.BTK_P2Bet .. ")"))))
    end
end

function W.BTK_ActionCheckGems()
    local P = W.BTK_GetPositions()
    local j = W.CountGemsAt(P.p1)
    local Y = W.CountGemsAt(P.p2)
    if W.BTK_Mode == "BJ" then
        if j <= 21 and Y <= 21 then
            if j > Y then
                W.BTK_WinnerSide = "Left"
                W.LocalChat("`c[WinProxy] `b[BJ]: `2[WIN] `0Left `2" .. (j .. (" `0- `4" .. (Y .. " `0Right `4[LOSE]"))))
            elseif Y > j then
                W.BTK_WinnerSide = "Right"
                W.LocalChat("`c[WinProxy] `b[BJ]: `4[LOSE] `0Left `4" .. (j .. (" `0- `2" .. (Y .. " `0Right `2[WIN]"))))
            else
                W.BTK_WinnerSide = "Draw"
                W.LocalChat("`c[WinProxy] `b[BJ]: `9[DRAW] `0Left `9" .. (j .. (" `0- `9" .. (Y .. " `0Right `9[DRAW]"))))
            end
        elseif j <= 21 and Y > 21 then
            W.BTK_WinnerSide = "Left"
            W.LocalChat("`c[WinProxy] `b[BJ]: `2[WIN] `0Left `2" .. (j .. (" `0- `4" .. (Y .. " `0Right `4(Bust) `4[LOSE]"))))
        elseif Y <= 21 and j > 21 then
            W.BTK_WinnerSide = "Right"
            W.LocalChat("`c[WinProxy] `b[BJ]: `4[LOSE] `4(Bust) `0Left `4" .. (j .. (" `0- `2" .. (Y .. " `0Right `2[WIN]"))))
        else
            local P = math.abs(j - 21)
            local X = math.abs(Y - 21)
            if P < X then
                W.BTK_WinnerSide = "Left"
                W.LocalChat("`c[WinProxy] `b[BJ]: `2[WIN] `0Left `2" .. (j .. (" `s(Closest) `0- `4" .. (Y .. " `0Right `4[LOSE]"))))
            elseif X < P then
                W.BTK_WinnerSide = "Right"
                W.LocalChat("`c[WinProxy] `b[BJ]: `4[LOSE] `0Left `4" .. (j .. (" `0- `2" .. (Y .. " `0Right `s(Closest) `2[WIN]"))))
            else
                W.BTK_WinnerSide = "Draw"
                W.LocalChat("`c[WinProxy] `b[BJ]: `9[DRAW] `0Left `9" .. (j .. (" `0- `9" .. (Y .. " `0Right `9[DRAW] `s(Both Over 21)"))))
            end
        end
    else
        if j > Y then
            W.BTK_WinnerSide = "Left"
            W.LocalChat("`c[WinProxy] `b[BTK]: `2[WIN] `0Left `2" .. (j .. (" `0- `4" .. (Y .. " `0Right `4[LOSE]"))))
        elseif Y > j then
            W.BTK_WinnerSide = "Right"
            W.LocalChat("`c[WinProxy] `b[BTK]: `4[LOSE] `0Left `4" .. (j .. (" `0- `2" .. (Y .. " `0Right `2[WIN]"))))
        else
            W.BTK_WinnerSide = "Draw"
            W.LocalChat("`c[WinProxy] `b[BTK]: `9[DRAW] `0Left `9" .. (j .. (" `0- `9" .. (Y .. " `0Right `9[DRAW]"))))
        end
    end
end

function W.BTK_ActionDropReset()
    local P = W.BTK_GetPositions()
    local j, Y = 0, 0
    if W.BTK_WinnerSide == "Left" then
        j = W.BTK_Bet1X - 2
        Y = W.BTK_Bet1Y
    elseif W.BTK_WinnerSide == "Right" then
        j = W.BTK_Bet2X + 2
        Y = W.BTK_Bet2Y
    end
    if j > 0 and Y > 0 then
        RunThread(function()
            local function X(P)
                local j = math.floor(P / 10000)
                local Y = P % 10000
                local X = math.floor(Y / 100)
                local M = Y % 100
                local z = math.floor(M)
                local o = math.floor(((M - z)) * 100 + .5)
                if j > 0 and W.GetItemCount(W.GetIcon("Creativeps Black Gem Lock", 11550)) >= j then
                    SendPacket(2, "action|dialog_return\ndialog_name|drop\nitem_drop|" .. (W.GetIcon("Creativeps Black Gem Lock", 11550) .. ("|\nitem_count|" .. j)))
                    Sleep(600)
                end
                if X > 0 then
                    while W.GetItemCount(W.GetIcon("Creativeps Blue Gem Lock", 7188)) < X do
                        if W.GetItemCount(W.GetIcon("Creativeps Black Gem Lock", 11550)) > 0 then
                            SendPacket(2, "action|dialog_return\ndialog_name|info_box\nbuttonClicked|make_bluegl")
                            Sleep(1000)
                        else
                            break
                        end
                    end
                    if W.GetItemCount(W.GetIcon("Creativeps Blue Gem Lock", 7188)) >= X then
                        SendPacket(2, "action|dialog_return\ndialog_name|drop\nitem_drop|" .. (W.GetIcon("Creativeps Blue Gem Lock", 7188) .. ("|\nitem_count|" .. X)))
                        Sleep(600)
                    end
                end
                if z > 0 then
                    while W.GetItemCount(W.GetIcon("Creativeps Diamond Lock", 1796)) < z do
                        if W.GetItemCount(W.GetIcon("Creativeps Blue Gem Lock", 7188)) > 0 then
                            SendPacketRaw(false, { type = 10; value = 7188 })
                            Sleep(1000)
                        elseif W.GetItemCount(W.GetIcon("Creativeps Black Gem Lock", 11550)) > 0 then
                            SendPacket(2, "action|dialog_return\ndialog_name|info_box\nbuttonClicked|make_bluegl")
                            Sleep(1000)
                        else
                            break
                        end
                    end
                    if W.GetItemCount(W.GetIcon("Creativeps Diamond Lock", 1796)) >= z then
                        SendPacket(2, "action|dialog_return\ndialog_name|drop\nitem_drop|" .. (W.GetIcon("Creativeps Diamond Lock", 1796) .. ("|\nitem_count|" .. z)))
                        Sleep(600)
                    end
                end
                if o > 0 then
                    while W.GetItemCount(W.GetIcon("Creativeps World Lock", 242)) < o do
                        if W.GetItemCount(W.GetIcon("Creativeps Diamond Lock", 1796)) > 0 then
                            SendPacketRaw(false, { type = 10; value = 1796 })
                            Sleep(1000)
                        elseif W.GetItemCount(W.GetIcon("Creativeps Blue Gem Lock", 7188)) > 0 then
                            SendPacketRaw(false, { type = 10; value = 7188 })
                            Sleep(1000)
                        elseif W.GetItemCount(W.GetIcon("Creativeps Black Gem Lock", 11550)) > 0 then
                            SendPacket(2, "action|dialog_return\ndialog_name|info_box\nbuttonClicked|make_bluegl")
                            Sleep(1000)
                        else
                            break
                        end
                    end
                    if W.GetItemCount(W.GetIcon("Creativeps World Lock", 242)) >= o then
                        SendPacket(2, "action|dialog_return\ndialog_name|drop\nitem_drop|" .. (W.GetIcon("Creativeps World Lock", 242) .. ("|\nitem_count|" .. o)))
                        Sleep(600)
                    end
                end
            end
            FindPath(j, Y)
            Sleep(850)
            X(W.BTK_TotalPrize)
            W.LocalChat("`c[WinProxy]: `9Dropped Prize: `2" .. (W.BTK_TotalPrize .. " DLs"))
            Sleep(500)
            FindPath(P.center.x, P.center.y)
            Sleep(800)
            local M = W.BTK_P1Bet + W.BTK_P2Bet
            local z = W.BTK_P1Bet + W.BTK_P2Bet
            local o = ((z * .05)) / 2
            local q = P.tax[2].x
            local S = P.tax[2].y
            if o > 0 and q > 0 then
                pcall(function()
                    ChangeValue("[C] Modfly", true)
                end)
                FindPath(q, S)
                Sleep(850)
                X(o)
                W.LocalChat("`c[WinProxy]: `9Dropped Tax (50%%): `2" .. (o .. " DLs"))
                Sleep(500)
                pcall(function()
                    ChangeValue("[C] Modfly", false)
                end)
            end
            for P, j in ipairs(P.p1) do
                FindPath(j.x, j.y)
                Sleep(400)
                SendPacketRaw(false, { type = 3, value = 5640, px = j.x; py = j.y; x = j.x * 32, y = j.y * 32 })
                Sleep(150)
            end
            for P, j in ipairs(P.p2) do
                FindPath(j.x, j.y)
                Sleep(400)
                SendPacketRaw(false, { type = 3; value = 5640, px = j.x; py = j.y, x = j.x * 32, y = j.y * 32 })
                Sleep(150)
            end
            W.BTK_TotalPrize = 0
            W.BTK_P1Bet = 0
            W.BTK_P2Bet = 0
            W.BTK_WinnerSide = nil
            FindPath(P.center.x, P.center.y)
            Sleep(850)
        end)
    else
        W.LocalChat("`c[WinProxy]: `4Draw/Target Drop invalid! Drop manually.")
    end
end

-- ========================================================================
-- SECTION 9: Auto-pull / re-pull / wrench actions / titles / auto-buy-pack / logs
-- ========================================================================

function W.GetSpawnTile()
    local P = os.clock()
    if W.CachedSpawnX and (W.CachedSpawnY and (P - W.LastSpawnScanTime < 5)) then
        return W.CachedSpawnX, W.CachedSpawnY
    end
    local j, Y = pcall(GetTiles)
    if j and Y then
        for j, Y in pairs(Y) do
            if Y and ((Y.fg == 6 or Y.id == 6 or Y.foreground == 6)) then
                W.CachedSpawnX, W.CachedSpawnY = Y.x, Y.y
                W.LastSpawnScanTime = P
                return Y.x, Y.y
            end
        end
    end
    return nil, nil
end

function W.GetTargetPullTile()
    local P = tonumber(W.AutoPullTileX) or 0
    local j = tonumber(W.AutoPullTileY) or 0
    if P > 0 and j > 0 then
        return P, j, true
    end
    local Y, X = W.GetSpawnTile()
    return Y, X, false
end

function W.CheckAndExecutePull(P, j)
    if not P then
        return
    end
    local Y = tonumber(P.netID or P.netid)
    local X = tonumber(P.userid or P.userID)
    local M = P.name or "Unknown"
    if not Y then
        return
    end
    if ((q(M)):lower()):find("spammer slave") then
        return
    end
    if X then
        for P, j in ipairs(W.AutoPullBlacklist) do
            if tonumber(j) == X then
                return
            end
        end
    end
    local z = os.clock()
    local o = j:find("Area Scan") and .05 or .5
    if W.AptCooldown[Y] and (z - W.AptCooldown[Y] < o) then
        return
    end
    local S = tonumber(W.AutoPullMinModal) or 0
    if S <= 0 then
        W.AptCooldown[Y] = z
        SendPacket(2, "action|dialog_return\ndialog_name|popup\nnetID|" .. (Y .. "|\nbuttonClicked|pull"))
        RunThread(function()
            Sleep(50)
            SendPacket(2, "action|dialog_return\ndialog_name|popup\nnetID|" .. (Y .. "|\nbuttonClicked|pull"))
        end)
        local P = q(M)
        W.LastPulledNetID = Y
        W.LastPulledName = P
        W.LastPulledTime = z
        if W.SpamPull or W.AutoSpamPull then
            W.TriggerSpamPull(Y, P)
        end
        if W.WrenchPullText ~= "" then
            local j = W.WrenchPullText:gsub("{GrowID}", P)
            RunThread(function()
                Sleep(80)
                SendPacket(2, "action|input\n|text|" .. j)
            end)
        end
        W.LocalChat("`c[WinProxy]: `w[`2APT`w] Auto Pulled `2" .. (P .. (" `w(" .. (j .. ")"))))
        if W.ShowBal then
            RunThread(function()
                Sleep(250)
                SendPacket(2, "action|dialog_return\ndialog_name|popup\nnetID|" .. (Y .. "|\nbuttonClicked|viewinv"))
            end)
        end
    else
        W.AptCooldown[Y] = z
        W.PendingModalPull[Y] = { netid = Y, userid = X; name = q(M), reason = j; timestamp = z }
        SendPacket(2, "action|dialog_return\ndialog_name|popup\nnetID|" .. (Y .. "|\nbuttonClicked|viewinv"))
    end
end

function W.TriggerSpamPull(P, j)
    P = P or W.LastPulledNetID
    j = j or W.LastPulledName or "Player"
    if not P then
        return
    end
    W.SpamPullTargetID = P
    W.SpamPullTargetName = j
    W.SpamPullEndTime = os.clock() + 3
    if W.SpamPullRunning then
        return
    end
    W.SpamPullRunning = true
    RunThread(function()
        if W.ShowBal then
            Sleep(250)
            SendPacket(2, "action|dialog_return\ndialog_name|popup\nnetID|" .. (W.SpamPullTargetID .. "|\nbuttonClicked|viewinv"))
            Sleep(250)
        end
        while os.clock() < ((W.SpamPullEndTime or 0)) do
            W.SpamPullSending = true
            SendPacket(2, "action|dialog_return\ndialog_name|popup\nnetID|" .. (W.SpamPullTargetID .. "|\nbuttonClicked|pull"))
            W.SpamPullSending = false
            Sleep(0)
        end
        W.SpamPullRunning = false
    end)
end

function W.ExecuteRePullOnce()
    if not W.LastPulledNetID then
        return
    end
    W.SpamPullSending = true
    SendPacket(2, "action|dialog_return\ndialog_name|popup\nnetID|" .. (W.LastPulledNetID .. "|\nbuttonClicked|pull"))
    W.SpamPullSending = false
    RunThread(function()
        Sleep(0)
        W.SpamPullSending = true
        SendPacket(2, "action|dialog_return\ndialog_name|popup\nnetID|" .. (W.LastPulledNetID .. "|\nbuttonClicked|pull"))
        W.SpamPullSending = false
    end)
end

function W.RenderSpamPullControls()
    if ImGui.CollapsingHeader("SpamPull & RePull Control", ImGuiTreeNodeFlags_DefaultOpen) then
        local P, j = ImGui.Checkbox("Spam Pull Mode (Auto 3s on Pull)", W.SpamPull or W.AutoSpamPull)
        if P then
            W.SpamPull = j
            W.AutoSpamPull = j
            W.SaveConfig(true)
        end
        if ImGui.Button("SpamPull 3s Now") then
            W.TriggerSpamPull()
        end
        ImGui.SameLine()
        if ImGui.Button("RePull 1x Now") then
            W.ExecuteRePullOnce()
        end
        local Y = W.CleanName(W.LastPulledName)
        local X = ((Y ~= "" and Y)) and (Y .. (" (NetID: " .. (tostring(W.LastPulledNetID) .. ")"))) or "None"
        ImGui.TextColored(ImVec4(.2, .9, 1, 1), "Target: " .. X)
        ImGui.TextColored(ImVec4(1, .8, .2, 1), "Hotkey: [" .. (((W.RePullHotkeyName or "DELETE")) .. "] (Cmd: /setrepullkey <KEY>)"))
        ImGui.Spacing()
    end
end

function W.SetRePullHotkey(P)
    P = (((P or "")):upper()):gsub("%s+", "")
    if W.HotkeyKeyCodes[P] then
        W.RePullHotkeyName = P
        W.RePullHotkeyCode = W.HotkeyKeyCodes[P]
        W.SaveConfig(true)
        W.LocalChat("`c[WinProxy]: `2[RePull] Hotkey set to: `^" .. P)
    else
        local j = tonumber(P)
        if j and (j > 0 and j <= 255) then
            W.RePullHotkeyName = "KEY_" .. j
            W.RePullHotkeyCode = j
            W.SaveConfig(true)
            W.LocalChat("`c[WinProxy]: `2[RePull] Hotkey set to raw code: `^" .. j)
        else
            W.LocalChat("`c[WinProxy]: `4[RePull] Invalid key! Available: DELETE, INSERT, HOME, END, R, V, X, F, C, G, T, Z, Q, E, F1-F5")
        end
    end
end

function W.ManageRePullHotkeyThread()
    if W.RePullHotkeyThreadRunning then
        return
    end
    if not P or type(GetAsyncKeyState) ~= "function" then
        return
    end
    W.RePullHotkeyThreadRunning = true
    RunThread(function()
        local P = false
        while true do
            local j = W.RePullHotkeyCode or 46
            local Y = tonumber(GetAsyncKeyState(j)) or 0
            local X = (Y < 0 or Y >= 32768)
            if X and not P then
                W.ExecuteRePullOnce()
            end
            P = X
            Sleep(40)
        end
    end)
end

function W.FetchPlayerTitles()
    local P = GetLocal()
    local j = P and P.netid or nil
    if not j then
        W.LocalChat("`c[WinProxy]: `4[Titles] Local player not found!")
        return
    end
    W.FetchingTitlesSilent = true
    W.TitlesAwaitingSelfPopup = true
    SendPacket(2, "action|wrench\n|netid|" .. j)
    W.LocalChat("`c[WinProxy]: `e[Titles] `wScanning titles from server...")
    RunThread(function()
        Sleep(5000)
        if W.TitlesAwaitingSelfPopup or W.FetchingTitlesSilent then
            W.TitlesAwaitingSelfPopup = false
            W.FetchingTitlesSilent = false
        end
    end)
end

function W.SavePlayerTitles()
    local P = "action|dialog_return\ndialog_name|popup\n"
    for j, Y in ipairs(W.TitlesState.Standard) do
        P = P .. (Y.key .. ("|" .. (((Y.enabled and "0" or "1")) .. "|\n")))
    end
    P = P .. ("gpmmode1|" .. (((W.TitlesState.GpmMode == 1 and "1" or "0")) .. "|\n"))
    P = P .. ("gpmmode2|" .. (((W.TitlesState.GpmMode == 2 and "1" or "0")) .. "|\n"))
    P = P .. ("gpmmode3|" .. (((W.TitlesState.GpmMode == 3 and "1" or "0")) .. "|\n"))
    for j, Y in ipairs(W.TitlesState.Custom) do
        P = P .. (Y.key .. ("|" .. (((Y.enabled and "0" or "1")) .. "|\n")))
    end
    P = P .. "buttonClicked|save\n"
    SendPacket(2, P)
end

function W.ManageAreaPullThread()
    if W.AreaPullThreadRunning then
        return
    end
    W.AreaPullThreadRunning = true
    RunThread(function()
        while W.AutoPullAreaScan do
            local P = GetPlayerList()
            if P then
                local j = GetLocal()
                local Y = j and j.netid or -1
                for P, j in pairs(P) do
                    if j.pos and (j.pos.x and (j.pos.y and j.netid ~= Y)) then
                        local P = math.floor(((j.pos.x + 16)) / 32)
                        local Y = math.floor(((j.pos.y + 16)) / 32)
                        local X = math.floor(j.pos.x / 32)
                        local M = math.floor(j.pos.y / 32)
                        for z = 1, 5, 1 do
                            local o = W.AutoPullPos[z].x
                            local q = W.AutoPullPos[z].y
                            if o > 0 and q > 0 then
                                local S = (P == o or X == o)
                                local O = (Y == q or M == q or Y == q + 1 or M == q + 1)
                                if S and O then
                                    W.CheckAndExecutePull(j, "Area Scan (Pos " .. (z .. ")"))
                                    break
                                end
                            end
                        end
                    end
                end
            end
            Sleep(20)
        end
        W.AreaPullThreadRunning = false
    end)
end

function W.IsRightClickPressed()
    if not GetAsyncKeyState then
        return false
    end
    local P = tonumber(GetAsyncKeyState(2)) or 0
    local j = (P < 0 or P >= 32768 or P == 1 or (P % 2 == 1) or P ~= 0)
    local Y = os.clock()
    if j then
        W.LastRightClickTime = Y
        return true
    end
    if W.LastRightClickTime and (Y - W.LastRightClickTime < .25) then
        return true
    end
    return false
end

function W.ExecuteWrenchAction(P, j, Y)
    if not P or j == 0 then
        return false
    end
    local X = W.GetPlayerNameByNetID(P)
    if j == 1 then
        W.LastPulledNetID = P
        W.LastPulledName = X
        W.LastPulledTime = os.clock()
        SendPacket(2, "action|dialog_return\ndialog_name|popup\nnetID|" .. (P .. "|\nbuttonClicked|pull"))
        if W.SpamPull or W.AutoSpamPull then
            W.TriggerSpamPull(P, X)
        end
        if W.WrenchPullText ~= "" then
            local P = W.WrenchPullText:gsub("{GrowID}", X)
            RunThread(function()
                Sleep(80)
                SendPacket(2, "action|input\n|text|" .. P)
            end)
        end
        if W.ShowBal and not ((W.SpamPull or W.AutoSpamPull)) then
            RunThread(function()
                Sleep(250)
                SendPacket(2, "action|dialog_return\ndialog_name|popup\nnetID|" .. (P .. "|\nbuttonClicked|viewinv"))
            end)
        end
        return true
    elseif j == 2 then
        SendPacket(2, "action|dialog_return\ndialog_name|popup\nnetID|" .. (P .. "|\nbuttonClicked|kick"))
        if W.WrenchKickText ~= "" then
            local P = W.WrenchKickText:gsub("{GrowID}", X)
            RunThread(function()
                Sleep(80)
                SendPacket(2, "action|input\n|text|" .. P)
            end)
        end
        if W.ShowBal then
            RunThread(function()
                Sleep(250)
                SendPacket(2, "action|dialog_return\ndialog_name|popup\nnetID|" .. (P .. "|\nbuttonClicked|viewinv"))
            end)
        end
        return true
    elseif j == 3 then
        SendPacket(2, "action|dialog_return\ndialog_name|popup\nnetID|" .. (P .. "|\nbuttonClicked|world_ban"))
        if W.WrenchBanText ~= "" then
            local P = W.WrenchBanText:gsub("{GrowID}", X)
            RunThread(function()
                Sleep(80)
                SendPacket(2, "action|input\n|text|" .. P)
            end)
        end
        if W.ShowBal then
            RunThread(function()
                Sleep(250)
                SendPacket(2, "action|dialog_return\ndialog_name|popup\nnetID|" .. (P .. "|\nbuttonClicked|viewinv"))
            end)
        end
        return true
    elseif j == 4 then
        SendPacket(2, "action|dialog_return\ndialog_name|popup\nnetID|" .. (P .. "|\nbuttonClicked|trade"))
        W.TradeTargetName = X
        W.TradeTargetUID = Y or 0
        local j, M = pcall(GetPlayerList)
        if j and M then
            for j, Y in pairs(M) do
                if Y.netid == tonumber(P) then
                    W.TradeTargetUID = Y.userid or 0
                    break
                end
            end
        end
        return true
    end
    return false
end

function W.FindClosestPlayer(P)
    local j, Y = pcall(GetLocal)
    local X = j and (Y and tonumber(Y.netID or Y.netid)) or nil
    local M, z = pcall(GetPlayerList)
    if not M or not z then
        return nil
    end
    local o = tonumber(P.x)
    local q = tonumber(P.y)
    local S = nil
    local W = nil
    local O = 1280
    for P, j in pairs(z) do
        local Y = tonumber(j.netID or j.netid)
        local M = j and j.pos
        if Y and (M and (M.x and (M.y and Y ~= X))) then
            local P = tonumber(M.x) - o
            local Y = tonumber(M.y) - q
            local X = (P * P) + (Y * Y)
            if X <= O and ((not W or X < W)) then
                S = j
                W = X
            end
        end
    end
    return S
end

function W.ManageABPThread()
    if W.ABP_ThreadRunning then
        return
    end
    W.ABP_ThreadRunning = true
    RunThread(function()
        local P = {}
        local j = W.ABP_Packs[W.ABP_PackIdx]
        W.ABP_DetectedDropIDs = {}
        local Y = {}
        W.ABP_ForceDrop = false
        if j.items then
            for P, j in ipairs(j.items) do
                W.ABP_DetectedDropIDs[j.id] = true
                table.insert(Y, j.id)
            end
        end
        local function X(P, j)
            for Y = 1, 100, 1 do
                local X = GetLocal()
                if not X then
                    return false
                end
                local M = math.floor(X.pos.x / 32)
                local z = math.floor(X.pos.y / 32)
                if M == P and z == j then
                    return true
                end
                local o = P - M
                local q = j - z
                local S = math.sqrt(o * o + q * q)
                if S > 3 then
                    local P = M + math.floor(((o / S)) * 3)
                    local j = z + math.floor(((q / S)) * 3)
                    FindPath(P, j)
                else
                    FindPath(P, j)
                end
                Sleep(150)
            end
            return false
        end
        W.LocalChat("`c[WinProxy]: `9Auto Buy Pack Started. Target: `2" .. j.name)
        if W.ABP_BatchMode then
            W.LocalChat("`c[WinProxy]: `e[BATCH MODE ON] `wBuying multiple times until full, then dropping!")
        end
        local M = 0
        while W.AutoBuyPack do
            if W.ABP_BuyAmount > 0 and M >= W.ABP_BuyAmount then
                W.AutoBuyPack = false
                W.LocalChat("`c[WinProxy]: `2Finished buying " .. (W.ABP_BuyAmount .. " packs!"))
                break
            end
            local z = {}
            for P, j in pairs(GetInventory()) do
                z[j.id] = ((z[j.id] or 0)) + j.amount
            end
            SendPacket(2, "action|buy\nitem|" .. j.cmd)
            Sleep(800)
            local o = false
            local q = false
            for P, j in pairs(GetInventory()) do
                local X = z[j.id] or 0
                if j.amount > X then
                    o = true
                    if not W.ABP_DetectedDropIDs[j.id] then
                        W.ABP_DetectedDropIDs[j.id] = true
                        table.insert(Y, j.id)
                        W.LocalChat("`c[WinProxy]: `9Smart Detect learned ID: `2" .. j.id)
                    end
                end
                if W.ABP_DetectedDropIDs[j.id] and j.amount >= 180 then
                    q = true
                end
            end
            if W.ABP_ForceDrop then
                q = true
                W.ABP_ForceDrop = false
            end
            if not o and not q then
                W.LocalChat("`c[WinProxy]: `4[WARNING] `wPurchase failed! (Out of Gems/Balance).")
                W.LocalChat("`c[WinProxy]: `wAuto Buy Pack is now `4STOPPED`w.")
                W.AutoBuyPack = false
                break
            end
            if o then
                M = M + 1
            end
            local S = false
            if W.ABP_BuyOnly then
                S = false
            elseif not W.ABP_BatchMode then
                S = true
            elseif q or (W.ABP_BuyAmount > 0 and M >= W.ABP_BuyAmount) then
                S = true
            end
            if S then
                table.sort(Y)
                local j = W.AntiPickup
                W.AntiPickup = true
                pcall(function()
                    ChangeValue("[C] Modfly", true)
                end)
                local M, z = nil, nil
                local o = 10
                for j, Y in ipairs(Y) do
                    local q = W.GetItemCount(Y)
                    if q > 0 then
                        local q = ((j - 1)) % o
                        local S = math.floor(((j - 1)) / o)
                        if not P[j] then
                            P[j] = W.ABP_DropY - S
                        end
                        local O = W.ABP_DropX + q
                        local V = P[j]
                        M = O
                        z = V
                        X(O - 1, V)
                        Sleep(250)
                        for P = 1, 24, 1 do
                            local j = W.GetItemCount(Y)
                            if j > 0 then
                                SendPacket(2, "action|dialog_return\ndialog_name|drop\nitem_drop|" .. (Y .. ("|\nitem_count|" .. j)))
                                Sleep(400)
                            else
                                break
                            end
                        end
                        if W.GetItemCount(Y) > 0 then
                            P[j] = P[j] - 1
                        end
                    end
                end
                X(W.ABP_DropX - 1, W.ABP_DropY)
                Sleep(300)
                pcall(function()
                    ChangeValue("[C] Modfly", false)
                end)
                W.AntiPickup = j
            end
            Sleep(200)
        end
        W.ABP_ThreadRunning = false
    end)
end

function W.AddLog(P, j)
    if not W.LogsEnabled then
        return
    end
    local Y = os.date("%H:%M:%S")
    local X = string.format("[%s] %s", Y, j)
    if W.Logs[P] then
        table.insert(W.Logs[P], 1, X)
        if #W.Logs[P] > W.MaxLogs then
            table.remove(W.Logs[P], W.MaxLogs + 1)
        end
    end
    table.insert(W.Logs.All, 1, X)
    if #W.Logs.All > W.MaxLogs then
        table.remove(W.Logs.All, W.MaxLogs + 1)
    end
end

-- ========================================================================
-- SECTION 10: ImGui panel (/imgui) - all tabs
-- ========================================================================

function W.RenderImGui()
    if not W.ShowImGui then
        return
    end
    if ImGui.SetNextWindowPos then
        pcall(ImGui.SetNextWindowPos, ImVec2(0, 25))
    end
    ImGui.SetNextWindowSize(ImVec2(600, 450), ImGui.Cond.FirstUseEver)
    if ImGui.SetNextWindowSizeConstraints then
        ImGui.SetNextWindowSizeConstraints(ImVec2(600, 490), ImVec2(2000, 2000))
    end
    local j, Y = ImGui.Begin("CreativePS Proxy: Win Community", true)
    if Y == false then
        W.ShowImGui = false
        W.SaveConfig(true)
        W.LocalChat("`c[WinProxy]: `9ImGui Menu is now `4CLOSED `9(Use /imgui to reopen)")
    end
    if j then
        ImGui.Columns(2, "MenuColumns", true)
        ImGui.SetColumnWidth(0, 185)
        ImGui.Text(utf8.char(61461) .. " Win Community Script")
        ImGui.Separator()
        ImGui.Spacing()
        ImGui.BeginChild("TabArea", ImVec2(0, 0), false)
        for P, j in ipairs(W.Tabs) do
            local Y = j:gsub(" ", " | ", 1)
            if ImGui.Selectable(Y, W.CurrentTab == j) then
                W.CurrentTab = j
            end
        end
        ImGui.EndChild()
        ImGui.NextColumn()
        ImGui.BeginChild("ContentArea", ImVec2(0, 0), false)
        local j = ImVec4(.2, .8, 1, 1)
        if W.CurrentTab == utf8.char(61461) .. " Welcome" then
            ImGui.Spacing()
            ImGui.TextColored(ImVec4(.2, .8, 1, 1), "========================================")
            ImGui.Spacing()
            ImGui.TextColored(ImVec4(1, 1, 1, 1), "                 W I N - C O M M U N I T Y   P R O X Y")
            ImGui.TextColored(ImVec4(.4, .8, .4, 1), "                    The Best CreativePS Proxy Script")
            ImGui.Spacing()
            ImGui.TextColored(ImVec4(.2, .8, 1, 1), "========================================")
            ImGui.Spacing()
            ImGui.Separator()
            local P = os.date("%Y-%m-%d %H:%M:%S")
            ImGui.TextColored(ImVec4(.8, .8, .8, 1), utf8.char(61463) .. (" Current Time: " .. P))
            ImGui.Separator()
            ImGui.Spacing()
            ImGui.TextColored(ImVec4(.8, .6, 1, 1), utf8.char(61447) .. " Player Information")
            local j, Y, X = "Unknown", "Unknown", "Unknown"
            local M, z = 0, 0
            local o, q = pcall(function()
                return GetLocal()
            end)
            local S, O = pcall(function()
                return GetWorld()
            end)
            if o and q then
                j = q.name and (q.name:gsub("`(%S)", "")):match("%S+") or "Unknown"
                Y = q.userid or "Unknown"
                if q.pos then
                    M = math.floor(q.pos.x / 32)
                    z = math.floor(q.pos.y / 32)
                end
            end
            if S and O then
                X = O.name or "Unknown"
            end
            ImGui.Indent(20)
            ImGui.TextColored(ImVec4(.7, .7, 1, 1), "GrowID: " .. j)
            ImGui.TextColored(ImVec4(.7, .7, 1, 1), "UID: " .. Y)
            ImGui.TextColored(ImVec4(.7, .7, 1, 1), "Current World: " .. X)
            ImGui.TextColored(ImVec4(.4, 1, .4, 1), string.format("Position: X: %d | Y: %d", M, z))
            ImGui.Unindent(20)
            ImGui.Spacing()
            ImGui.Separator()
            ImGui.Spacing()
            ImGui.TextColored(ImVec4(.6, 1, .6, 1), utf8.char(61547) .. " Thank you for using our proxy script!")
            ImGui.TextWrapped("This panel provides advanced tools for Growtopia automation and enhancement. Navigate using the menu on the left.")
            ImGui.Spacing()
            ImGui.Separator()
            ImGui.TextColored(ImVec4(1, .7, .3, 1), utf8.char(61671) .. " Quick Actions")
            if ImGui.Button(utf8.char(61573) .. " Open Settings", ImVec2(ImGui.GetWindowWidth() / 2 - 15, 30)) then
                W.CurrentTab = utf8.char(61573) .. " Setting"
            end
            ImGui.SameLine()
            if ImGui.Button(utf8.char(61530) .. " Information", ImVec2(ImGui.GetWindowWidth() / 2 - 15, 30)) then
                W.CurrentTab = utf8.char(61530) .. " Information"
            end
            if ImGui.Button(utf8.char(61641) .. " Show Menu Dialog (/menu)", ImVec2(ImGui.GetWindowWidth() - 20, 30)) then
                W.ShowMainDialog()
            end
            ImGui.Spacing()
        elseif W.CurrentTab == utf8.char(61728) .. " Commands" then
            ImGui.TextColored(j, utf8.char(61728) .. " Command Center")
            ImGui.Separator()
            ImGui.Spacing()
            if ImGui.CollapsingHeader(utf8.char(61473) .. " Custom Commands (Alias)", ImGuiTreeNodeFlags_DefaultOpen) then
                ImGui.Spacing()
                ImGui.TextColored(ImVec4(.8, .8, .8, 1), "Map your own shortcut commands (e.g., /di -> /dbl)")
                ImGui.PushItemWidth(130)
                local P, j = ImGui.InputTextWithHint("##newCust", "Your Alias (e.g. /di)", W.TempCust, 32)
                if P then
                    W.TempCust = j
                end
                ImGui.SameLine()
                local Y, X = ImGui.InputTextWithHint("##newOrig", "Original (e.g. /dbl)", W.TempOrig, 32)
                if Y then
                    W.TempOrig = X
                end
                ImGui.PopItemWidth()
                ImGui.SameLine()
                if W.TempDisableOrig == nil then
                    W.TempDisableOrig = true
                end
                local M, z = ImGui.Checkbox("Disable Orig", W.TempDisableOrig)
                if M then
                    W.TempDisableOrig = z
                end
                if ImGui.Button(utf8.char(61543) .. " Add Alias") and (W.TempCust ~= "" and W.TempOrig ~= "") then
                    if W.TempCust:sub(1, 1) ~= "/" then
                        W.TempCust = "/" .. W.TempCust
                    end
                    if W.TempOrig:sub(1, 1) ~= "/" then
                        W.TempOrig = "/" .. W.TempOrig
                    end
                    W.CustomCommands[W.TempCust] = { orig = W.TempOrig, disableOrig = W.TempDisableOrig }
                    W.TempCust = ""
                    W.TempOrig = ""
                    W.SaveConfig(true)
                end
                ImGui.Spacing()
                ImGui.Columns(4, "AliasTable", true)
                ImGui.SetColumnWidth(0, 110)
                ImGui.SetColumnWidth(1, 130)
                ImGui.SetColumnWidth(2, 90)
                ImGui.SetColumnWidth(3, 60)
                ImGui.TextColored(ImVec4(1, .8, .2, 1), "Alias")
                ImGui.NextColumn()
                ImGui.TextColored(ImVec4(1, .8, .2, 1), "Original")
                ImGui.NextColumn()
                ImGui.TextColored(ImVec4(1, .8, .2, 1), "Disabled Ori")
                ImGui.NextColumn()
                ImGui.TextColored(ImVec4(1, .8, .2, 1), "Act")
                ImGui.NextColumn()
                ImGui.Separator()
                for P, j in pairs(W.CustomCommands) do
                    ImGui.TextColored(ImVec4(.4, 1, .4, 1), P)
                    ImGui.NextColumn()
                    ImGui.TextColored(ImVec4(.8, .8, .8, 1), j.orig)
                    ImGui.NextColumn()
                    local Y = j.disableOrig and ImVec4(1, .4, .4, 1) or ImVec4(.8, .8, .8, 1)
                    ImGui.TextColored(Y, tostring(j.disableOrig))
                    ImGui.NextColumn()
                    if ImGui.Button("Del##" .. P) then
                        W.CustomCommands[P] = nil
                        W.SaveConfig(true)
                    end
                    ImGui.NextColumn()
                    ImGui.Separator()
                end
                ImGui.Columns(1)
                ImGui.Spacing()
            end
            if ImGui.CollapsingHeader(utf8.char(61485) .. " Command Manual Book", ImGuiTreeNodeFlags_DefaultOpen) then
                ImGui.Spacing()
                ImGui.BeginChild("CommandsListArea", ImVec2(0, 0), false)
                local P = ImVec4(1, .8, .2, 1)
                local j = ImVec4(.6, 1, .6, 1)
                local Y = 240
                local function X(P, Y)
                    ImGui.TextColored(j, utf8.char(61701) .. (" " .. P))
                    ImGui.NextColumn()
                    ImGui.TextColored(ImVec4(.8, .9, 1, 1), Y)
                    ImGui.NextColumn()
                    ImGui.Separator()
                end
                local function M(j, X, M)
                    ImGui.TextColored(P, X .. (" " .. M))
                    ImGui.Spacing()
                    ImGui.Columns(2, j, true)
                    ImGui.SetColumnWidth(0, Y)
                    ImGui.TextColored(ImVec4(1, .4, .4, 1), utf8.char(61728) .. " Commands")
                    ImGui.NextColumn()
                    ImGui.TextColored(ImVec4(.4, 1, .4, 1), utf8.char(61530) .. " Description")
                    ImGui.NextColumn()
                    ImGui.Separator()
                end
                local function z()
                    ImGui.Columns(1)
                    ImGui.Spacing()
                    ImGui.Spacing()
                end
                M("Tbl_Casino", utf8.char(62754), "Casino Modes")
                X("/casinomenu", "Open Casino Menu directly.")
                X("/allmode", "Toggle All (Reme, Leme, Qeme) mode.")
                X("/reme", "Toggle Reme calculator mode.")
                X("/qeme", "Toggle Qeme calculator mode.")
                X("/leme", "Toggle Leme calculator mode.")
                X("/lemes", "Toggle Leme S calculator mode.")
                X("/ceme", "Toggle Ceme calculator mode.")
                X("/lewa <num>", "Set Lewa multiplier and Enable.")
                X("/autochamp, /autocmp", "Auto use Champagne before spinning wheel.")
                X("/cmp", "Quick use 1 Champagne from inventory.")
                z()
                M("Tbl_AutoPull", utf8.char(61465), "Auto Pull & Settings")
                X("/autopullmenu", "Open Auto Pull Menu directly.")
                X("/autopull", "Toggle Auto Pull Master.")
                X("/posautopull", "Set Auto Pull target to your tile.")
                X("/clearposautopull", "Reset target back to White Door.")
                X("/apblacklist add <uid>", "Add UID to Auto Pull blacklist.")
                X("/apblacklist remove <uid>", "Remove UID from blacklist.")
                X("/apblacklist list", "Show current blacklist in chat.")
                z()
                M("Tbl_Wrench", utf8.char(61613), "Wrench Controls")
                X("/wrenchmenu", "Open Wrench Menu directly.")
                X("/wrp, /wrps", "Auto Pull (Left Click / Right Click).")
                X("/wrk, /wrks", "Auto Kick (Left Click / Right Click).")
                X("/wrb, /wrbs", "Auto World Ban (Left Click / Right Click).")
                X("/wrt, /wrts", "Auto Trade (Left Click / Right Click).")
                X("/showbal", "Toggle fast balance on inspect.")
                z()
                M("Tbl_Donate", utf8.char(62656), "Smart Donation")
                X("/donatemenu", "Open Donate Menu directly.")
                X("/dmode", "Toggle Smart Donation Mode.")
                X("/pw <qty>", "Remote Donate World Lock.")
                X("/pd <qty>", "Remote Donate Diamond Lock.")
                X("/pb <qty>", "Remote Donate Blue Gem Lock.")
                X("/pbl <qty>", "Remote Donate Black Gem Lock.")
                X("/pall", "Remote Donate All Locks in inventory.")
                X("/takeall", "Retrieve all items from Donation Box.")
                z()
                M("Tbl_Trade", utf8.char(62133), "Advanced Trading")
                X("/trademenu", "Open Trade Menu directly.")
                X("/tmode", "Toggle Trade Wrench Mode.")
                X("/tw <qty>", "Fast add World Lock to trade.")
                X("/td <qty>", "Fast add Diamond Lock to trade.")
                X("/tb <qty>", "Fast add Blue Gem Lock to trade.")
                X("/tbl <qty>", "Fast add Black GL to trade.")
                X("/tall", "Fast add All Locks to trade.")
                X("/tclear", "Clear all locks from Trade window.")
                z()
                M("Tbl_Tele", utf8.char(61589), "Telephone Commands")
                X("/telemenu", "Open Telephone Menu directly.")
                X("/cvdl", "Auto Convert DL to BGL.")
                X("/buybgl", "Auto Buy Blue Gem Lock.")
                X("/buydl", "Auto Buy Diamond Lock.")
                X("/buychamp", "Auto Buy Champagne (Normal).")
                X("/buychampbg", "Auto Buy Champagne (Black Gems).")
                X("/buychampbulk", "Auto Buy Bulk Champagne.")
                z()
                M("Tbl_Calc", utf8.char(61932), "Smart Calculator")
                X("/calcmenu", "Open Calculator Menu directly.")
                X("/calc <form>", "Calculate math instantly.")
                z()
                M("Tbl_Spam", utf8.char(62637), "Auto-Spam Settings")
                X("/spammenu", "Open Spam UI Menu directly.")
                X("/spam", "Toggle Auto-Spam on/off.")
                X("/addspam <txt>", "Add a new spam message.")
                X("/removespam", "Remove last spam message.")
                X("/spamtext <#> <txt>", "Edit specific spam line.")
                z()
                M("Tbl_SB", utf8.char(61601), "Super Broadcast")
                X("/sbmenu", "Open SB & SDB Menu directly.")
                X("/sbstart", "Start Super Broadcast (or /sbstart reset).")
                X("/sbstop", "Stop Super Broadcast.")
                X("/sbreset", "Reset SB count and stats to 0.")
                X("/sdbstart", "Start Super Duper Broadcast (or /sdbstart reset).")
                X("/sdbstop", "Stop Super Duper Broadcast.")
                X("/sdbreset", "Reset SDB count to 0.")
                z()
                M("Tbl_Emoji", utf8.char(62783), "Text & Skin Customization")
                X("/emojimenu", "Open Emoji Menu directly.")
                X("/emoji", "Toggles Random Chat Emojis.")
                X("/watermark", "Toggles Custom Chat Watermark.")
                z()
                M("Tbl_Logs", utf8.char(61474), "Logs & History")
                X("/logsmenu", "Open main Logs Menu Dialog.")
                X("/logs", "Toggle activity logging on/off.")
                X("/clogs", "Open Collect Logs directly.")
                X("/dlogs", "Open Drop Logs directly.")
                X("/invlogs", "Open Inventory Logs directly.")
                X("/slogs", "Open Casino/Spin Logs directly.")
                z()
                M("Tbl_Economy", utf8.char(62133), "Economy & Drop")
                X("/dw <qty>", "Auto drop World Lock.")
                X("/dd <qty>", "Auto drop Diamond Lock.")
                X("/db <qty>", "Auto drop Blue Gem Lock.")
                X("/dbl <qty>", "Auto drop Black Gem Lock.")
                X("/daw", "Drop all locks in backpack.")
                X("/depo <qty>", "Deposit BGL to bank.")
                X("/with <qty>", "Withdraw BGL from bank.")
                X("/blue", "Convert Black GL to Blue GL.")
                X("/black", "Convert Blue GL to Black GL.")
                z()
                M("Tbl_General", utf8.char(61459), "General Proxy Features")
                X("/antilag", "Toggle Anti-Lag (Particle/Shadow).")
                X("/hidespammer", "Toggle Hide Spammer Slave.")
                X("/antipickup", "Toggle Anti-Pickup items.")
                X("/modfly", "Toggle Modfly.")
                X("/antiportal", "Toggle Anti-Portal.")
                X("/nightvision", "Toggle Night Vision.")
                X("/blocksdb", "Toggle Block SDB Dialogs.")
                X("/autocv", "Toggle Auto CV All Locks on collect.")
                X("/tp", "Toggle Teleport Punch (Display/Vend).")
                X("/modal", "Calculate & show your own total balance.")
                X("/fastdrop", "Toggle fast drop without confirmation.")
                X("/fasttrash", "Toggle fast trash without confirmation.")
                X("/vendfilter", "Formats huge World Lock prices to BGL/DL.")
                X("/donfilter", "Shows actual item icons in Donation Box.")
                X("/sboxfilter", "Enable Storage Box Xtreme Take-All mode.")
                X("/skin <color>", "Change skin color (presets/rainbow/blink/hex/rgb).")
                z()
                M("Tbl_BTK", utf8.char(61723), "BTK & BJ Commands")
                X("/btkmenu, /bjmenu", "Open Host Dialog Panel.")
                X("/btkcmd, /bjcmd", "Open BTK/BJ Command List.")
                X("/btk, /bj", "Switch Game Mode (BTK / BJ).")
                X("/btkremote, /bjremote", "Collect Remote from Magplant.")
                X("/btkbet, /bjbet", "Take Bets & Calculate Tax.")
                X("/btkgems, /bjgems", "Check Gems & Announce Winner.")
                X("/btkdrop, /bjdrop", "Drop Prize, Tax & Reset Round.")
                X("/btkcenter, /bjcenter", "Touch/Punch to set Host Center tile.")
                X("/btkposbet1, /bjposbet1", "Touch/Punch to set Bet Player 1 tile.")
                X("/btkposbet2, /bjposbet2", "Touch/Punch to set Bet Player 2 tile.")
                X("/btkposbreak1, /bjposbreak1", "Touch/Punch to set Break Player 1 tile.")
                X("/btkposbreak2, /bjposbreak2", "Touch/Punch to set Break Player 2 tile.")
                X("/btktax, /bjtax", "Touch/Punch to set Tax Drop tile.")
                X("/btkmag, /bjmag", "Touch/Punch to set Magplant tile.")
                z()
                M("Tbl_Sys", utf8.char(61459), "System & Tools")
                X("/menu, /help", "Open Main Menu Dialog in-game.")
                X("/cmd", "Open this Commands Dialog directly.")
                X("/aliasmenu", "Open the Command Alias Menu directly.")
                X("/settingmenu", "Open Setting Menu directly.")
                X("/imgui, /proxy", "Open/Close ImGui Panel.")
                X("/g, /ghost", "Shortcut for /ghost.")
                X("/res", "Shortcut for Respawn.")
                X("/re", "Shortcut for Rejoin World.")
                X("/relog", "Shortcut to Reconnect server.")
                z()
                ImGui.EndChild()
            end
        elseif W.CurrentTab == utf8.char(61459) .. " General" then
            ImGui.TextColored(j, utf8.char(61459) .. " General Proxy Features")
            ImGui.Separator()
            ImGui.Spacing()
            if ImGui.CollapsingHeader(utf8.char(61573) .. " Utility Toggles", ImGuiTreeNodeFlags_DefaultOpen) then
                ImGui.Spacing()
                local P, j = ImGui.Checkbox("Anti-Lag (No Particle/Shadow)", W.AntiLag)
                if P then
                    W.ToggleAntiLag(j)
                end
                ImGui.SameLine()
                ImGui.TextColored(ImVec4(.5, .5, .5, 1), "- (/antilag)")
                local Y, X = ImGui.Checkbox("Hide Spammer Slave", W.HideSpammer)
                if Y then
                    W.ToggleHideSpammer(X)
                end
                ImGui.SameLine()
                ImGui.TextColored(ImVec4(.5, .5, .5, 1), "- (/hidespammer)")
                local M, z = ImGui.Checkbox("Anti-Pickup Items (/antipickup)", W.AntiPickup)
                if M then
                    W.AntiPickup = z
                    W.SaveConfig(true)
                end
                local o, q = ImGui.Checkbox("Modfly (/modfly)", W.Modfly)
                if o then
                    W.Modfly = q
                    pcall(function()
                        ChangeValue("[C] Modfly", W.Modfly)
                    end)
                    W.SaveConfig(true)
                end
                local S, O = ImGui.Checkbox("Anti Portal (/antiportal)", W.AntiPortal)
                if S then
                    W.AntiPortal = O
                    pcall(function()
                        ChangeValue("[C] Anti portal", W.AntiPortal)
                    end)
                    W.SaveConfig(true)
                end
                local V, e = ImGui.Checkbox("Night Vision (/nightvision)", W.NightVision)
                if V then
                    W.NightVision = e
                    pcall(function()
                        ChangeValue("[C] Night vision", W.NightVision)
                    end)
                    W.SaveConfig(true)
                end
                ImGui.SameLine()
                ImGui.TextColored(ImVec4(.5, .5, .5, 1), "- Prevents auto-collecting dropped items")
                local v, f = ImGui.Checkbox("Block SDB Dialogs (/blocksdb)", W.BlockSDB)
                if v then
                    W.BlockSDB = f
                    W.SaveConfig(true)
                end
                ImGui.SameLine()
                ImGui.TextColored(ImVec4(.5, .5, .5, 1), "- Hides annoying Super Duper Broadcast popups")
                local n, C = ImGui.Checkbox("Block SB Chat (/blocksb)", W.BlockSB)
                if n then
                    W.BlockSB = C
                    W.SaveConfig(true)
                end
                ImGui.SameLine()
                ImGui.TextColored(ImVec4(.5, .5, .5, 1), "- Hides Super Broadcasts in console")
                local D, i = ImGui.Checkbox("Auto CV All Locks (/autocv)", W.AutoCVLocks)
                if D then
                    W.AutoCVLocks = i
                    W.SaveConfig(true)
                end
                ImGui.SameLine()
                ImGui.TextColored(ImVec4(.5, .5, .5, 1), "- Converts strictly on collect")
                local K, y = ImGui.Checkbox("Teleport Punch (/tp)", W.TPDisplay)
                if K then
                    W.TPDisplay = y
                    W.SaveConfig(true)
                end
                ImGui.SameLine()
                ImGui.TextColored(ImVec4(.5, .5, .5, 1), "- Auto FindPath when punching Display/Vend")
                local k, A = ImGui.Checkbox("Fast Drop (/fastdrop)", W.FastDrop)
                if k then
                    W.FastDrop = A
                    if not A then
                        W.FastDropOnClick = false
                    end
                    W.SaveConfig(true)
                end
                ImGui.SameLine()
                ImGui.TextColored(ImVec4(.5, .5, .5, 1), "- Skips drop amount dialog (drops all)")
                if W.FastDrop then
                    ImGui.Indent(20)
                    local P, j = ImGui.Checkbox("Fast Drop OnClick Item", W.FastDropOnClick)
                    if P then
                        W.FastDropOnClick = j
                        if j then
                            W.FastTrashOnClick = false
                            W.ManageWarningThread()
                            W.ManageOnClickItemThread()
                        end
                    end
                    ImGui.SameLine()
                    ImGui.TextColored(ImVec4(1, .4, .4, 1), " [WARNING: 1-Tap Drop All]")
                    ImGui.Unindent(20)
                end
                local p, T = ImGui.Checkbox("Fast Trash (/fasttrash)", W.FastTrash)
                if p then
                    W.FastTrash = T
                    if not T then
                        W.FastTrashOnClick = false
                    end
                    W.SaveConfig(true)
                end
                ImGui.SameLine()
                ImGui.TextColored(ImVec4(.5, .5, .5, 1), "- Skips trash warning dialog (trashes all)")
                if W.FastTrash then
                    ImGui.Indent(20)
                    local P, j = ImGui.Checkbox("Fast Trash OnClick Item", W.FastTrashOnClick)
                    if P then
                        W.FastTrashOnClick = j
                        if j then
                            W.FastDropOnClick = false
                            W.ManageWarningThread()
                            W.ManageOnClickItemThread()
                        end
                    end
                    ImGui.SameLine()
                    ImGui.TextColored(ImVec4(1, .4, .4, 1), " [WARNING: 1-Tap Trash All]")
                    ImGui.Unindent(20)
                end
                local B, x = ImGui.Checkbox("Vend Filter (/vendfilter)", W.VendFilter)
                if B then
                    W.VendFilter = x
                    W.SaveConfig(true)
                end
                ImGui.SameLine()
                ImGui.TextColored(ImVec4(.5, .5, .5, 1), "- Formats huge World Lock prices to BGL/DL")
                local c, G = ImGui.Checkbox("Donation Box Filter (/donfilter)", W.DonationFilter)
                if c then
                    W.DonationFilter = G
                    W.SaveConfig(true)
                end
                ImGui.SameLine()
                ImGui.TextColored(ImVec4(.5, .5, .5, 1), "- Shows actual item icons in Donation Box list")
                local a, w = ImGui.Checkbox("Storage Box Filter (/sboxfilter)", W.StorageFilter)
                if a then
                    W.StorageFilter = w
                    W.SaveConfig(true)
                end
                ImGui.SameLine()
                ImGui.TextColored(ImVec4(.5, .5, .5, 1), "- Converts Storage Box to list with Take All")
            end
        elseif W.CurrentTab == utf8.char(61613) .. " Wrench" then
            ImGui.TextColored(j, utf8.char(61613) .. " Wrench Mode Options")
            ImGui.Separator()
            ImGui.Spacing()
            if ImGui.CollapsingHeader(utf8.char(61459) .. " Features & Toggles", ImGuiTreeNodeFlags_DefaultOpen) then
                ImGui.Spacing()
                local P, j = ImGui.Checkbox("Show Balance on Wrench (/showbal)", W.ShowBal)
                if P then
                    W.ShowBal = j
                    W.SaveConfig(true)
                end
                ImGui.SameLine()
                ImGui.TextColored(ImVec4(.5, .5, .5, 1), "- Hides inventory dialog & shows balance")
                ImGui.Spacing()
                ImGui.Separator()
                ImGui.Spacing()
                ImGui.TextColored(ImVec4(.8, .8, .8, 1), "Left Click Action (Main): [/wr_ example : /wrp]")
                if select(2, ImGui.Checkbox("Off##L", W.WrenchMode == 0)) and W.WrenchMode ~= 0 then
                    W.WrenchMode = 0
                    W.SaveConfig(true)
                end
                ImGui.SameLine()
                if select(2, ImGui.Checkbox("Pull##L", W.WrenchMode == 1)) and W.WrenchMode ~= 1 then
                    W.WrenchMode = 1
                    W.SaveConfig(true)
                end
                ImGui.SameLine()
                if select(2, ImGui.Checkbox("Kick##L", W.WrenchMode == 2)) and W.WrenchMode ~= 2 then
                    W.WrenchMode = 2
                    W.SaveConfig(true)
                end
                ImGui.SameLine()
                if select(2, ImGui.Checkbox("Ban##L", W.WrenchMode == 3)) and W.WrenchMode ~= 3 then
                    W.WrenchMode = 3
                    W.SaveConfig(true)
                end
                ImGui.SameLine()
                if select(2, ImGui.Checkbox("Trade##L", W.WrenchMode == 4)) and W.WrenchMode ~= 4 then
                    W.WrenchMode = 4
                    W.SaveConfig(true)
                end
                ImGui.Spacing()
                ImGui.TextColored(ImVec4(.8, .8, 1, 1), "Right Click Action (Secondary): [/wr_s example : /wrks]")
                if select(2, ImGui.Checkbox("Off##R", W.WrenchModeRight == 0)) and W.WrenchModeRight ~= 0 then
                    W.WrenchModeRight = 0
                    W.SaveConfig(true)
                end
                ImGui.SameLine()
                if select(2, ImGui.Checkbox("Pull##R", W.WrenchModeRight == 1)) and W.WrenchModeRight ~= 1 then
                    W.WrenchModeRight = 1
                    W.SaveConfig(true)
                end
                ImGui.SameLine()
                if select(2, ImGui.Checkbox("Kick##R", W.WrenchModeRight == 2)) and W.WrenchModeRight ~= 2 then
                    W.WrenchModeRight = 2
                    W.SaveConfig(true)
                end
                ImGui.SameLine()
                if select(2, ImGui.Checkbox("Ban##R", W.WrenchModeRight == 3)) and W.WrenchModeRight ~= 3 then
                    W.WrenchModeRight = 3
                    W.SaveConfig(true)
                end
                ImGui.SameLine()
                if select(2, ImGui.Checkbox("Trade##R", W.WrenchModeRight == 4)) and W.WrenchModeRight ~= 4 then
                    W.WrenchModeRight = 4
                    W.SaveConfig(true)
                end
                ImGui.Spacing()
            end
            W.RenderSpamPullControls()
            if ImGui.CollapsingHeader(utf8.char(61504) .. " Custom Chat Actions", ImGuiTreeNodeFlags_DefaultOpen) then
                ImGui.Spacing()
                ImGui.TextColored(ImVec4(.8, .8, .8, 1), "Use {GrowID} to tag the player\'s name.")
                ImGui.PushItemWidth(-1)
                local P, j = ImGui.InputTextWithHint("##pulltxt", "Auto Pull Text (e.g. Get over here {GrowID}!)", W.WrenchPullText, 64)
                if P then
                    W.WrenchPullText = j
                    W.SaveConfig(true)
                end
                local Y, X = ImGui.InputTextWithHint("##kicktxt", "Auto Kick Text (e.g. Bye {GrowID}!)", W.WrenchKickText, 64)
                if Y then
                    W.WrenchKickText = X
                    W.SaveConfig(true)
                end
                local M, z = ImGui.InputTextWithHint("##bantxt", "Auto Ban Text (e.g. {GrowID} is banned!)", W.WrenchBanText, 64)
                if M then
                    W.WrenchBanText = z
                    W.SaveConfig(true)
                end
                ImGui.PopItemWidth()
                ImGui.Spacing()
            end
        elseif W.CurrentTab == utf8.char(62656) .. " Donate" then
            ImGui.TextColored(j, utf8.char(62656) .. " Smart Donation Mode")
            ImGui.Separator()
            ImGui.Spacing()
            if ImGui.CollapsingHeader(utf8.char(61459) .. " Features & Toggles", ImGuiTreeNodeFlags_DefaultOpen) then
                ImGui.Spacing()
                local P, j = ImGui.Checkbox("Enable Donate Mode (/dmode)", W.DonateMode)
                if P then
                    W.DonateMode = j
                    if not W.DonateMode then
                        W.DonateBoxX = 0
                        W.DonateBoxY = 0
                    end
                    W.SaveConfig(true)
                end
                ImGui.Spacing()
                ImGui.TextColored(ImVec4(.8, .8, .8, 1), "Status: ")
                ImGui.SameLine()
                if W.DonateBoxX == 0 and W.DonateBoxY == 0 then
                    ImGui.TextColored(ImVec4(1, .4, .4, 1), "Box Not Set! Wrench a Donation Box.")
                else
                    ImGui.TextColored(ImVec4(.4, 1, .4, 1), "Box Set at X: " .. (W.DonateBoxX .. (", Y: " .. W.DonateBoxY)))
                end
                ImGui.Spacing()
                ImGui.Separator()
                ImGui.Spacing()
                ImGui.TextColored(ImVec4(.8, .8, .8, 1), "Quick Donate Action:")
                ImGui.PushItemWidth(150)
                local Y, X = ImGui.InputInt("Amount", W.DonateAmount)
                if Y then
                    W.DonateAmount = X
                end
                if W.DonateAmount < 1 then
                    W.DonateAmount = 1
                end
                ImGui.PopItemWidth()
                ImGui.Spacing()
                if ImGui.Button("Donate WL (/pw)", ImVec2(150, 30)) then
                    W.DoDonate(W.GetIcon("Creativeps World Lock", 242), W.DonateAmount)
                end
                ImGui.SameLine()
                if ImGui.Button("Donate DL (/pd)", ImVec2(150, 30)) then
                    W.DoDonate(W.GetIcon("Creativeps Diamond Lock", 1796), W.DonateAmount)
                end
                ImGui.Spacing()
                if ImGui.Button("Donate BlueGL (/pb)", ImVec2(150, 30)) then
                    W.DoDonate(W.GetIcon("Creativeps Blue Gem Lock", 7188), W.DonateAmount)
                end
                ImGui.SameLine()
                if ImGui.Button("Donate BlackGL (/pbl)", ImVec2(150, 30)) then
                    W.DoDonate(W.GetIcon("Creativeps Black Gem Lock", 11550), W.DonateAmount)
                end
                ImGui.Spacing()
                if ImGui.Button("Put All Locks (/pall)", ImVec2(310, 30)) then
                    W.DonateAllLocks()
                end
                ImGui.Spacing()
                if ImGui.Button("Take All Items (/takeall)", ImVec2(310, 30)) then
                    if W.DonateMode and W.DonateBoxX ~= 0 then
                        SendPacket(2, "action|dialog_return\ndialog_name|donate_edit|\nx|" .. (W.DonateBoxX .. ("|\ny|" .. (W.DonateBoxY .. "|\nbuttonClicked|withdrawall"))))
                        W.LocalChat("`c[WinProxy]: `9Retrieving all items from Donation Box...")
                    else
                        W.LocalChat("`c[WinProxy]: `4Please enable /dmode and set a box position first!")
                    end
                end
                ImGui.Spacing()
            end
        elseif W.CurrentTab == utf8.char(62133) .. " Trade" then
            ImGui.TextColored(j, utf8.char(62133) .. " Advanced Trading Mode")
            ImGui.Separator()
            ImGui.Spacing()
            if ImGui.CollapsingHeader(utf8.char(61459) .. " Features & Toggles", ImGuiTreeNodeFlags_DefaultOpen) then
                ImGui.Spacing()
                local P = (W.WrenchMode == 4)
                local j, Y = ImGui.Checkbox("Enable Trade Mode (/tmode)", P)
                if j then
                    W.ToggleWrench(4)
                end
                ImGui.Spacing()
                ImGui.TextColored(ImVec4(.8, .8, .8, 1), "Status: ")
                ImGui.SameLine()
                if W.TradeTargetUID == 0 then
                    ImGui.TextColored(ImVec4(1, .4, .4, 1), "Not Trading! Wrench a Player.")
                else
                    local P = W.TradeTargetName:gsub("`.", "")
                    ImGui.TextColored(ImVec4(.4, 1, .4, 1), "Trading with " .. (P .. (" (UID: " .. (W.TradeTargetUID .. ")"))))
                end
                ImGui.Spacing()
                ImGui.Separator()
                ImGui.Spacing()
                ImGui.TextColored(ImVec4(.8, .8, .8, 1), "Fast Add Items to Trade:")
                ImGui.PushItemWidth(150)
                local X, M = ImGui.InputInt("Amount##tradeamt", W.TradeAddAmount)
                if X then
                    W.TradeAddAmount = M
                end
                if W.TradeAddAmount < 1 then
                    W.TradeAddAmount = 1
                end
                ImGui.PopItemWidth()
                ImGui.Spacing()
                if ImGui.Button("Add WL (/tw)", ImVec2(150, 30)) then
                    W.FastTradeAdd(W.GetIcon("Creativeps World Lock", 242), W.TradeAddAmount)
                end
                ImGui.SameLine()
                if ImGui.Button("Add DL (/td)", ImVec2(150, 30)) then
                    W.FastTradeAdd(W.GetIcon("Creativeps Diamond Lock", 1796), W.TradeAddAmount)
                end
                ImGui.Spacing()
                if ImGui.Button("Add BlueGL (/tb)", ImVec2(150, 30)) then
                    W.FastTradeAdd(W.GetIcon("Creativeps Blue Gem Lock", 7188), W.TradeAddAmount)
                end
                ImGui.SameLine()
                if ImGui.Button("Add BlackGL (/tbl)", ImVec2(150, 30)) then
                    W.FastTradeAdd(W.GetIcon("Creativeps Black Gem Lock", 11550), W.TradeAddAmount)
                end
                ImGui.Spacing()
                if ImGui.Button("Put All Locks (/tall)", ImVec2(310, 30)) then
                    W.TradeAllLocks()
                end
                ImGui.Spacing()
                if ImGui.Button("Clear Locks (/tclear)", ImVec2(310, 30)) then
                    W.TradeClearLocks()
                end
                ImGui.Spacing()
            end
        elseif W.CurrentTab == utf8.char(61589) .. " Telephone" then
            ImGui.TextColored(ImVec4(.2, 1, .2, 1), utf8.char(61589) .. " Telephone Auto-Buy")
            ImGui.Separator()
            ImGui.Spacing()
            if ImGui.CollapsingHeader(utf8.char(61459) .. " Features & Toggles", ImGuiTreeNodeFlags_DefaultOpen) then
                ImGui.Spacing()
                ImGui.TextColored(ImVec4(.8, .8, .8, 1), "Select Action:")
                if select(2, ImGui.Checkbox("Off (Disabled)", W.TeleMode == 0)) and W.TeleMode ~= 0 then
                    W.TeleMode = 0
                end
                if select(2, ImGui.Checkbox("Buy Diamond Lock (/buydl)", W.TeleMode == 1)) and W.TeleMode ~= 1 then
                    W.TeleMode = 1
                    W.LocalChat("`c[WinProxy]: `9Wrench Telephone to Buy `cDL `9is now `2Enabled")
                end
                if select(2, ImGui.Checkbox("Buy Blue Gem Lock (/buybgl)", W.TeleMode == 2)) and W.TeleMode ~= 2 then
                    W.TeleMode = 2
                    W.LocalChat("`c[WinProxy]: `9Wrench Telephone to Buy `eBGL `9is now `2Enabled")
                end
                if select(2, ImGui.Checkbox("Convert DL to BGL (/cvdl)", W.TeleMode == 3)) and W.TeleMode ~= 3 then
                    W.TeleMode = 3
                    W.LocalChat("`c[WinProxy]: `9Wrench Telephone to Change `cDL `9to `eBGL `9is now `2Enabled")
                end
                if select(2, ImGui.Checkbox("Buy Champagne (Normal) (/buychamp)", W.TeleMode == 4)) and W.TeleMode ~= 4 then
                    W.TeleMode = 4
                    W.LocalChat("`c[WinProxy]: `9Wrench Telephone to Buy `2Champagne `9is now `2Enabled")
                end
                if select(2, ImGui.Checkbox("Buy Champagne (BGems) (/buychampbg)", W.TeleMode == 5)) and W.TeleMode ~= 5 then
                    W.TeleMode = 6
                    W.LocalChat("`c[WinProxy]: `9Wrench Telephone to Buy `2Champ (Black Gems) `9is now `2Enabled")
                end
                if select(2, ImGui.Checkbox("Buy Champagne (BULK) (/buychampbulk)", W.TeleMode == 6)) and W.TeleMode ~= 6 then
                    W.TeleMode = 5
                    W.LocalChat("`c[WinProxy]: `9Wrench Telephone to Buy `2Bulk Champagne `9is now `2Enabled")
                end
                ImGui.Spacing()
                ImGui.Separator()
                ImGui.Spacing()
                ImGui.TextColored(ImVec4(.5, .5, .5, 1), "Instruction: Select an option and wrench a Telephone.\nThe script will automatically bypass dialogs and buy the item.")
                ImGui.Spacing()
            end
        elseif W.CurrentTab == utf8.char(62783) .. " Text & Skin" then
            ImGui.TextColored(ImVec4(1, .4, .7, 1), utf8.char(62783) .. " Text & Skin Customization")
            ImGui.Separator()
            ImGui.Spacing()
            if ImGui.CollapsingHeader("Input Text Stuff (Colors, Emojis)", ImGuiTreeNodeFlags_DefaultOpen) then
                local P, j = ImGui.Checkbox("Enable Color", W.EnableColor)
                if P then
                    W.EnableColor = j
                    W.SaveConfig(true)
                end
                local Y = W.SelectedColorIdx
                W.SelectedColorIdx = W.SafeCombo("Text Color", W.SelectedColorIdx, W.ColorNames)
                if Y ~= W.SelectedColorIdx then
                    W.SaveConfig(true)
                end
                local X, M = ImGui.Checkbox("Enable Emoji", W.EnableEmoji)
                if X then
                    W.EnableEmoji = M
                    W.SaveConfig(true)
                end
                local z = W.SelectedEmojiIdx
                W.SelectedEmojiIdx = W.SafeCombo("Emoji", W.SelectedEmojiIdx, W.EmojiNames)
                if z ~= W.SelectedEmojiIdx then
                    W.SaveConfig(true)
                end
                local o, q = ImGui.Checkbox("Enable Chat Watermark", W.WatermarkMode)
                if o then
                    W.WatermarkMode = q
                    W.SaveConfig(true)
                end
                local S, O = ImGui.Checkbox("Enable Encrypt Chat (/encrypt)", W.EncryptChat)
                if S then
                    W.EncryptChat = O
                    W.SaveConfig(true)
                end
            end
            if ImGui.CollapsingHeader("Skin Changer", ImGuiTreeNodeFlags_DefaultOpen) then
                local P, j = ImGui.ColorEdit4("Custom Player Color", W.SkinColor)
                if P then
                    W.SkinColor.x = j.x
                    W.SkinColor.y = j.y
                    W.SkinColor.z = j.z
                    W.SkinColor.w = j.w
                end
                local Y, X = ImGui.Checkbox("Rainbow Skin", W.RainbowSkin)
                if Y then
                    W.RainbowSkin = X
                    if W.RainbowSkin then
                        W.ManageSkinEffects()
                    end
                    W.SaveConfig(true)
                end
                local M, z = ImGui.Checkbox("Blink", W.BlinkSkin)
                if M then
                    W.BlinkSkin = z
                    if W.BlinkSkin then
                        W.ManageSkinEffects()
                    end
                    W.SaveConfig(true)
                end
                ImGui.Spacing()
                if ImGui.Button("Apply In-Game", ImVec2(150, 30)) then
                    W.SetSkinColor(W.SkinColor.x, W.SkinColor.y, W.SkinColor.z, W.SkinColor.w)
                    W.LocalChat("`c[WinProxy]: `9Custom skin applied!")
                end
                ImGui.Spacing()
                ImGui.TextColored(ImVec4(.8, .8, .8, 1), "Quick Presets:")
                if ImGui.Button("Black", ImVec2(60, 25)) then
                    W.RainbowSkin = false
                    W.BlinkSkin = false
                    W.SetSkinColor(0, 0, 0, 1)
                end
                ImGui.SameLine()
                if ImGui.Button("White", ImVec2(60, 25)) then
                    W.RainbowSkin = false
                    W.BlinkSkin = false
                    W.SetSkinColor(1, 1, 1, 1)
                end
                ImGui.SameLine()
                if ImGui.Button("Red", ImVec2(60, 25)) then
                    W.RainbowSkin = false
                    W.BlinkSkin = false
                    W.SetSkinColor(1, 0, 0, 1)
                end
                ImGui.SameLine()
                if ImGui.Button("Yellow", ImVec2(60, 25)) then
                    W.RainbowSkin = false
                    W.BlinkSkin = false
                    W.SetSkinColor(1, 1, 0, 1)
                end
                if ImGui.Button("Green", ImVec2(60, 25)) then
                    W.RainbowSkin = false
                    W.BlinkSkin = false
                    W.SetSkinColor(0, 1, 0, 1)
                end
                ImGui.SameLine()
                if ImGui.Button("Blue", ImVec2(60, 25)) then
                    W.RainbowSkin = false
                    W.BlinkSkin = false
                    W.SetSkinColor(0, .4, 1, 1)
                end
                ImGui.SameLine()
                if ImGui.Button("Purple", ImVec2(60, 25)) then
                    W.RainbowSkin = false
                    W.BlinkSkin = false
                    W.SetSkinColor(.6, .1, .9, 1)
                end
                ImGui.SameLine()
                if ImGui.Button("Pink", ImVec2(60, 25)) then
                    W.RainbowSkin = false
                    W.BlinkSkin = false
                    W.SetSkinColor(1, .4, .8, 1)
                end
                ImGui.Spacing()
            end
        elseif W.CurrentTab == utf8.char(61932) .. " Calculator" then
            ImGui.TextColored(j, utf8.char(61932) .. " Smart Calculator")
            ImGui.Separator()
            ImGui.Spacing()
            ImGui.TextColored(ImVec4(.8, .8, .8, 1), "Display:")
            ImGui.PushItemWidth(-1)
            local P, Y = ImGui.InputText("##hidden_calc_input", W.CalcInput, 256)
            if P then
                W.CalcInput = Y
            end
            ImGui.PopItemWidth()
            local X = W.CalcResult:gsub("`.", "")
            ImGui.TextColored(ImVec4(.4, 1, .4, 1), "= " .. X)
            ImGui.Spacing()
            local M = ImVec2(50, 40)
            local z = ImVec2(108, 40)
            if ImGui.Button("C", M) then
                W.CalcInput = ""
            end
            ImGui.SameLine()
            if ImGui.Button(utf8.char(62810), M) then
                W.CalcInput = string.sub(W.CalcInput, 1, -2)
            end
            ImGui.SameLine()
            if ImGui.Button("%", M) then
                W.CalcInput = W.CalcInput .. "%"
            end
            ImGui.SameLine()
            if ImGui.Button("/", M) then
                W.CalcInput = W.CalcInput .. "/"
            end
            if ImGui.Button("7", M) then
                W.CalcInput = W.CalcInput .. "7"
            end
            ImGui.SameLine()
            if ImGui.Button("8", M) then
                W.CalcInput = W.CalcInput .. "8"
            end
            ImGui.SameLine()
            if ImGui.Button("9", M) then
                W.CalcInput = W.CalcInput .. "9"
            end
            ImGui.SameLine()
            if ImGui.Button("x", M) then
                W.CalcInput = W.CalcInput .. "*"
            end
            if ImGui.Button("4", M) then
                W.CalcInput = W.CalcInput .. "4"
            end
            ImGui.SameLine()
            if ImGui.Button("5", M) then
                W.CalcInput = W.CalcInput .. "5"
            end
            ImGui.SameLine()
            if ImGui.Button("6", M) then
                W.CalcInput = W.CalcInput .. "6"
            end
            ImGui.SameLine()
            if ImGui.Button("-", M) then
                W.CalcInput = W.CalcInput .. "-"
            end
            if ImGui.Button("1", M) then
                W.CalcInput = W.CalcInput .. "1"
            end
            ImGui.SameLine()
            if ImGui.Button("2", M) then
                W.CalcInput = W.CalcInput .. "2"
            end
            ImGui.SameLine()
            if ImGui.Button("3", M) then
                W.CalcInput = W.CalcInput .. "3"
            end
            ImGui.SameLine()
            if ImGui.Button("+", M) then
                W.CalcInput = W.CalcInput .. "+"
            end
            if ImGui.Button("0", z) then
                W.CalcInput = W.CalcInput .. "0"
            end
            ImGui.SameLine()
            if ImGui.Button(".", M) then
                W.CalcInput = W.CalcInput .. "."
            end
            ImGui.SameLine()
            if ImGui.Button("=", M) then
                W.CalculateMath(W.CalcInput)
            end
            ImGui.Spacing()
            ImGui.Separator()
            ImGui.Spacing()
            ImGui.TextColored(ImVec4(.6, .8, 1, 1), "Calculation History:")
            ImGui.BeginChild("CalcLogsChild", ImVec2(0, 120), true)
            if #W.CalcLogs == 0 then
                ImGui.TextColored(ImVec4(.5, .5, .5, 1), "No history available.")
            else
                for P, j in ipairs(W.CalcLogs) do
                    ImGui.Text(P .. (". " .. j:gsub("`.", "")))
                end
            end
            ImGui.EndChild()
            ImGui.Spacing()
        elseif W.CurrentTab == utf8.char(61442) .. " Item Database" then
            ImGui.TextColored(j, utf8.char(61442) .. " Item Database Search")
            ImGui.Separator()
            ImGui.Spacing()
            ImGui.PushItemWidth(-1)
            local P, Y = ImGui.InputTextWithHint("##itemsearch", "Search by Item Name or ID...", W.SearchItemInput, 64)
            if P then
                W.SearchItemInput = Y
                W.SearchItem(W.SearchItemInput)
            end
            ImGui.PopItemWidth()
            ImGui.Spacing()
            ImGui.TextColored(ImVec4(.8, .8, .8, 1), "Results Found: " .. #W.SearchItemResults)
            ImGui.BeginChild("ItemDBSearchResults", ImVec2(0, 0), true)
            if #W.SearchItemResults == 0 then
                ImGui.TextColored(ImVec4(.5, .5, .5, 1), "No items found. Type above to start searching.")
            else
                ImGui.Columns(2, "ItemDBCols", true)
                ImGui.SetColumnWidth(0, 80)
                ImGui.TextColored(ImVec4(1, .8, .2, 1), "Item ID")
                ImGui.NextColumn()
                ImGui.TextColored(ImVec4(1, .8, .2, 1), "Item Name")
                ImGui.NextColumn()
                ImGui.Separator()
                for P, j in ipairs(W.SearchItemResults) do
                    ImGui.TextColored(ImVec4(.4, 1, .4, 1), tostring(j.id))
                    ImGui.NextColumn()
                    local Y = j.name:gsub("(%a)([%w_\']*)", function(P, j)
                        return P:upper() .. j:lower()
                    end)
                    ImGui.TextColored(ImVec4(.9, .9, .9, 1), Y)
                    ImGui.NextColumn()
                end
                ImGui.Columns(1)
            end
            ImGui.EndChild()
        elseif W.CurrentTab == utf8.char(61548) .. " Auto PTHT" then
            ImGui.TextColored(j, utf8.char(61548) .. " Auto PTHT")
            ImGui.Separator()
            ImGui.TextColored(ImVec4(.6, .6, .6, 1), "This feature will be available soon.")
        elseif W.CurrentTab == utf8.char(61548) .. " Auto PNB" then
            ImGui.TextColored(j, utf8.char(61548) .. " Auto PNB")
            ImGui.Separator()
            ImGui.TextColored(ImVec4(.6, .6, .6, 1), "This feature will be available soon.")
        elseif W.CurrentTab == utf8.char(62006) .. " AFK" then
            ImGui.TextColored(j, utf8.char(62006) .. " AFK")
            ImGui.Separator()
            ImGui.TextColored(ImVec4(.6, .6, .6, 1), "This feature will be available soon.")
        elseif W.CurrentTab == utf8.char(61483) .. " Title" then
            ImGui.TextColored(j, utf8.char(61483) .. " TITLES & CUSTOM TITLES MANAGER")
            ImGui.Separator()
            ImGui.Spacing()
            if not W.TitlesState.Loaded and not W.FetchingTitlesSilent then
                W.FetchPlayerTitles()
            end
            if W.TitlesState.Loaded then
                ImGui.TextColored(ImVec4(.4, .95, .5, 1), string.format("(%d Custom Titles Loaded)", #W.TitlesState.Custom))
            else
                ImGui.TextColored(ImVec4(.7, .7, .7, 1), "Scanning your titles from server... please wait!")
            end
            if not W.TitlesState.Loaded then
                ImGui.Spacing()
                ImGui.TextColored(ImVec4(1, .3, .3, 1), utf8.char(61553) .. " PLEASE CLICK \'SCAN / REFRESH TITLES\' FIRST TO LOAD YOUR DATA!")
            else
                ImGui.Spacing()
                ImGui.Separator()
                ImGui.Spacing()
                ImGui.TextColored(ImVec4(.3, .85, 1, 1), "Standard Titles (Auto-Apply):")
                ImGui.Spacing()
                for P, j in ipairs(W.TitlesState.Standard) do
                    local Y, X = ImGui.Checkbox(j.name .. ("##std_" .. P), j.enabled == true)
                    if Y then
                        j.enabled = X
                        W.SavePlayerTitles()
                    end
                    if j.relog then
                        ImGui.SameLine()
                        ImGui.TextColored(ImVec4(1, .75, .2, 1), "[Re-enter World]")
                    end
                end
                ImGui.Spacing()
                ImGui.TextColored(ImVec4(.65, .65, .65, 1), utf8.char(61530) .. " Tips: Titles marked with [Re-enter World] require you to re-enter the world (use /re) to refresh visually.")
                ImGui.Spacing()
                ImGui.Separator()
                ImGui.Spacing()
                ImGui.TextColored(ImVec4(.9, .8, .2, 1), "Pro Max Animation Mode (Auto-Apply):")
                ImGui.Spacing()
                local P = { "Mode 1 (Quick Highlight)"; "Mode 2 (Cycle)"; "Mode 3 (Blinking)" }
                for j = 1, 3, 1 do
                    if ImGui.RadioButton(P[j] .. ("##gpm_" .. j), W.TitlesState.GpmMode == j) then
                        W.TitlesState.GpmMode = j
                        W.SavePlayerTitles()
                    end
                    ImGui.Spacing()
                end
                ImGui.Spacing()
                ImGui.Separator()
                ImGui.Spacing()
                ImGui.TextColored(ImVec4(.9, .4, .9, 1), "Custom Titles (Auto-Apply):")
                ImGui.Spacing()
                if ImGui.Button("Select All##btn_sel_all_titles", ImVec2(95, 22)) then
                    for P, j in ipairs(W.TitlesState.Custom) do
                        j.enabled = true
                    end
                    W.SavePlayerTitles()
                end
                ImGui.SameLine()
                if ImGui.Button("Clear All##btn_clr_all_titles", ImVec2(95, 22)) then
                    for P, j in ipairs(W.TitlesState.Custom) do
                        j.enabled = false
                    end
                    W.SavePlayerTitles()
                end
                ImGui.Spacing()
                for P, j in ipairs(W.TitlesState.Custom) do
                    local Y, X = ImGui.Checkbox(j.clean .. ("##cust_" .. P), j.enabled == true)
                    if Y then
                        j.enabled = X
                        W.SavePlayerTitles()
                    end
                end
            end
        elseif W.CurrentTab == utf8.char(61685) .. " Auto Cook" then
            ImGui.TextColored(j, utf8.char(61685) .. " Auto Cook")
            ImGui.Separator()
            ImGui.TextColored(ImVec4(.6, .6, .6, 1), "This feature will be available soon.")
        elseif W.CurrentTab == utf8.char(62840) .. " Auto Fish" then
            ImGui.TextColored(j, utf8.char(62840) .. " Auto Fishing")
            ImGui.Separator()
            ImGui.Spacing()
            if ImGui.CollapsingHeader("Controls & Info", ImGuiTreeNodeFlags_DefaultOpen) then
                local P = W.AutoFish and ImVec4(.4, 1, .4, 1) or ImVec4(1, 1, .4, 1)
                if W.FishAction:find("Out of") then
                    P = ImVec4(1, .4, .4, 1)
                end
                ImGui.Text("Status: ")
                ImGui.SameLine()
                ImGui.TextColored(P, W.FishAction)
                ImGui.Spacing()
                if W.AutoFish then
                    if ImGui.Button("STOP AUTO FISH", ImVec2(-1, 35)) then
                        W.AutoFish = false
                        W.FishAction = "Stopping..."
                    end
                else
                    if ImGui.Button("START AUTO FISH", ImVec2(-1, 35)) then
                        W.AutoFish = true
                        W.ManageAutoFishThread()
                    end
                end
                ImGui.Spacing()
                ImGui.TextColored(ImVec4(.8, .8, .8, 1), "How to use: Equip your Fishing Rod, face the water,\nselect your direction below, and click Start!")
                ImGui.Spacing()
            end
            if ImGui.CollapsingHeader("Settings", ImGuiTreeNodeFlags_DefaultOpen) then
                W.FishDirIdx = W.SafeCombo("Facing Direction", W.FishDirIdx, { "Facing Right", "Facing Left" })
                ImGui.Spacing()
                ImGui.PushItemWidth(150)
                local P, j = ImGui.InputInt("Bait Item ID", W.FishBaitID)
                if P then
                    W.FishBaitID = j
                end
                ImGui.PopItemWidth()
                ImGui.TextColored(ImVec4(.5, .5, .5, 1), "(Common Baits: 2504 = Worm, 5528 = Mega Pelet, 2904 = Salmon)")
                ImGui.Spacing()
            end
            if ImGui.CollapsingHeader("Live Statistics", ImGuiTreeNodeFlags_DefaultOpen) then
                ImGui.TextColored(ImVec4(.8, .8, .8, 1), "Total Casts : " .. W.FishStats.cast)
                ImGui.TextColored(ImVec4(.4, 1, .4, 1), "Fish Caught : " .. W.FishStats.caught)
                ImGui.TextColored(ImVec4(1, .4, .4, 1), "Fish Missed : " .. W.FishStats.missed)
                ImGui.Spacing()
                if ImGui.Button("Reset Stats##fish") then
                    W.FishStats = { cast = 0; caught = 0; missed = 0 }
                end
                ImGui.Spacing()
            end
        elseif W.CurrentTab == utf8.char(61690) .. " Auto Surg" then
            ImGui.TextColored(j, utf8.char(61690) .. " Auto Surgery (Smart AI)")
            ImGui.Separator()
            ImGui.Spacing()
            if ImGui.CollapsingHeader("Controls & Info", ImGuiTreeNodeFlags_DefaultOpen) then
                local P = W.AutoSurg and ImVec4(.4, 1, .4, 1) or ImVec4(1, 1, .4, 1)
                if W.SurgAction:find("Malpractice") or W.SurgAction:find("low!") then
                    P = ImVec4(1, .4, .4, 1)
                end
                ImGui.Text("Status: ")
                ImGui.SameLine()
                ImGui.TextColored(P, W.SurgAction)
                if W.SurgTarget then
                    ImGui.Text("Target: ")
                    ImGui.SameLine()
                    ImGui.TextColored(ImVec4(.4, .8, 1, 1), "Player ID: " .. tostring(W.SurgTarget))
                end
                ImGui.Spacing()
                if W.AutoSurg then
                    if ImGui.Button("STOP AUTO SURG", ImVec2(-1, 35)) then
                        W.AutoSurg = false
                        W.IsSurging = false
                        W.SurgTarget = nil
                        W.SurgAction = "Stopping..."
                    end
                else
                    if ImGui.Button("START AUTO SURG", ImVec2(-1, 35)) then
                        W.AutoSurg = true
                        W.ManageAutoSurgThread()
                    end
                end
                ImGui.Spacing()
                ImGui.TextColored(ImVec4(.8, .8, .8, 1), "How to use: Click Start, then Wrench a player to begin.")
                ImGui.Spacing()
            end
            if ImGui.CollapsingHeader("Settings & Toggles", ImGuiTreeNodeFlags_DefaultOpen) then
                local P, j = ImGui.Checkbox("Enable Auto Buy Surg Kit", W.SurgAutoBuy)
                if P then
                    W.SurgAutoBuy = j
                end
                ImGui.PushItemWidth(120)
                local Y, X = ImGui.InputInt("Min. Threshold", W.SurgCardThreshold)
                if Y then
                    W.SurgCardThreshold = X
                    if W.SurgCardThreshold < 1 then
                        W.SurgCardThreshold = 1
                    end
                end
                ImGui.PopItemWidth()
                ImGui.TextColored(ImVec4(.5, .5, .5, 1), "Bot will automatically buy \'Surgical Kit\' if any tool drops below " .. (W.SurgCardThreshold .. "."))
                ImGui.Spacing()
                local M, z = ImGui.Checkbox("Auto Trash Excess Tools (>= 240 items)", W.SurgAutoTrash)
                if M then
                    W.SurgAutoTrash = z
                end
                ImGui.TextColored(ImVec4(.5, .5, .5, 1), "Prevents inventory full errors by trashing excess tools down to 200.")
                ImGui.Spacing()
                local o, q = ImGui.Checkbox("Auto Bypass Malpractice (/modage 999)", W.SurgAutoModage)
                if o then
                    W.SurgAutoModage = q
                    if q then
                        W.SurgUseLegalBrief = false
                    end
                end
                local S, O = ImGui.Checkbox("Use Legal Brief (For Non-MVP+)", W.SurgUseLegalBrief)
                if S then
                    W.SurgUseLegalBrief = O
                    if O then
                        W.SurgAutoModage = false
                    end
                end
                ImGui.Spacing()
            end
            if ImGui.CollapsingHeader("Live Statistics", ImGuiTreeNodeFlags_DefaultOpen) then
                ImGui.TextColored(ImVec4(.4, 1, .4, 1), "Successful Surgeries : " .. W.SurgStats.success)
                ImGui.TextColored(ImVec4(1, .4, .4, 1), "Failed (Malpractice) : " .. W.SurgStats.fail)
                local P = W.SurgStats.success + W.SurgStats.fail
                local j = P > 0 and math.floor(((W.SurgStats.success / P)) * 100) or 0
                ImGui.TextColored(ImVec4(.4, .8, 1, 1), "Win Rate Accuracy    : " .. (j .. "%"))
                ImGui.Spacing()
                if ImGui.Button("Reset Stats") then
                    W.SurgStats = { success = 0, fail = 0 }
                end
                ImGui.Spacing()
            end
        elseif W.CurrentTab == utf8.char(61956) .. " Auto Geiger" then
            ImGui.TextColored(j, utf8.char(61956) .. " Auto Geiger")
            ImGui.Separator()
            ImGui.TextColored(ImVec4(.6, .6, .6, 1), "This feature will be available soon.")
        elseif W.CurrentTab == utf8.char(61548) .. " Auto Provider" then
            ImGui.TextColored(j, utf8.char(61548) .. " Auto Provider")
            ImGui.Separator()
            ImGui.TextColored(ImVec4(.6, .6, .6, 1), "This feature will be available soon.")
        elseif W.CurrentTab == utf8.char(61979) .. " Auto Crime" then
            ImGui.TextColored(j, utf8.char(61979) .. " Auto Crime (CPS Optimized)")
            ImGui.Separator()
            ImGui.Spacing()
            if ImGui.CollapsingHeader("Controls & Status", ImGuiTreeNodeFlags_DefaultOpen) then
                local P = W.AutoCrime and ImVec4(.4, 1, .4, 1) or ImVec4(1, 1, .4, 1)
                if W.CrimeAction:find("Error") or W.CrimeAction:find("Lost") then
                    P = ImVec4(1, .4, .4, 1)
                end
                ImGui.Text("Status: ")
                ImGui.SameLine()
                ImGui.TextColored(P, W.CrimeAction)
                if W.CrimeTarget then
                    ImGui.Text("Target: ")
                    ImGui.SameLine()
                    ImGui.TextColored(ImVec4(.4, .8, 1, 1), string.format("%s @ (%d, %d)", W.CrimeTarget.name, W.CrimeTarget.x, W.CrimeTarget.y))
                end
                ImGui.Spacing()
                if W.AutoCrime then
                    if ImGui.Button("STOP AUTO CRIME", ImVec2(150, 35)) then
                        W.AutoCrime = false
                        W.IsFightingCrime = false
                        W.CrimeAction = "Stopping..."
                    end
                else
                    if ImGui.Button("START AUTO CRIME", ImVec2(150, 35)) then
                        W.AutoCrime = true
                        W.ManageAutoCrimeThread()
                    end
                    ImGui.SameLine()
                    if ImGui.Button("SCAN VILLAINS", ImVec2(150, 35)) then
                        W.ScanVillains()
                    end
                end
                ImGui.Spacing()
            end
            if ImGui.CollapsingHeader("Auto Buy Cards Settings", ImGuiTreeNodeFlags_DefaultOpen) then
                local P, j = ImGui.Checkbox("Enable Auto Buy Crime Cards", W.AutoBuyCrimeCards)
                if P then
                    W.AutoBuyCrimeCards = j
                end
                ImGui.PushItemWidth(120)
                local Y, X = ImGui.InputInt("Min. Threshold", W.CrimeCardThreshold)
                if Y then
                    W.CrimeCardThreshold = X
                    if W.CrimeCardThreshold < 1 then
                        W.CrimeCardThreshold = 1
                    end
                end
                ImGui.PopItemWidth()
                ImGui.TextColored(ImVec4(.5, .5, .5, 1), "Bot will automatically buy Crime Cards if any card drops below " .. (W.CrimeCardThreshold .. "."))
                ImGui.Spacing()
            end
            if ImGui.CollapsingHeader("Villains Found in World", ImGuiTreeNodeFlags_DefaultOpen) then
                ImGui.Text("Total Instances: " .. #W.CrimeVillains)
                ImGui.Separator()
                if ImGui.BeginTable("VillainListTable", 3) then
                    ImGui.TableSetupColumn("No.", 0, .1)
                    ImGui.TableSetupColumn("Name", 0, .6)
                    ImGui.TableSetupColumn("Position", 0, .3)
                    ImGui.TableHeadersRow()
                    for P, j in ipairs(W.CrimeVillains) do
                        ImGui.TableNextRow()
                        ImGui.TableSetColumnIndex(0)
                        ImGui.Text(tostring(P))
                        ImGui.TableSetColumnIndex(1)
                        ImGui.Text(j.name)
                        ImGui.TableSetColumnIndex(2)
                        ImGui.TextColored(ImVec4(.4, .8, 1, 1), string.format("(%d, %d)", j.x, j.y))
                    end
                    ImGui.EndTable()
                end
            end
        elseif W.CurrentTab == utf8.char(62637) .. " Auto Spam" then
            ImGui.TextColored(j, utf8.char(62637) .. " Auto-Spam Settings")
            ImGui.Separator()
            ImGui.Spacing()
            if ImGui.CollapsingHeader(utf8.char(61459) .. " Features & Toggles", ImGuiTreeNodeFlags_DefaultOpen) then
                ImGui.Spacing()
                local P, j = ImGui.Checkbox("Enable Auto-Spam", W.SpamEnabled)
                if P then
                    W.ToggleSpam(j)
                end
                ImGui.Spacing()
                ImGui.TextColored(ImVec4(.8, .8, .8, 1), "Spam Configuration:")
                ImGui.PushItemWidth(-1)
                for P = 1, #W.SpamTexts, 1 do
                    local j, Y = ImGui.InputText("Typer Text " .. P, W.SpamTexts[P], 128)
                    if j then
                        W.SpamTexts[P] = Y
                    end
                end
                ImGui.PopItemWidth()
                ImGui.Spacing()
                if ImGui.Button(utf8.char(61543) .. " Add New Field", ImVec2(140, 30)) then
                    table.insert(W.SpamTexts, "")
                end
                ImGui.SameLine()
                if #W.SpamTexts > 1 then
                    if ImGui.Button(utf8.char(61544) .. " Remove Last Field", ImVec2(140, 30)) then
                        table.remove(W.SpamTexts)
                    end
                end
                ImGui.Spacing()
                ImGui.Separator()
                ImGui.Spacing()
                ImGui.PushItemWidth(150)
                local Y, X = ImGui.InputInt("Typer Delay (ms)", W.SpamInterval, 100, 1000)
                if Y then
                    if X < 500 then
                        X = 500
                    end
                    W.SpamInterval = X
                end
                ImGui.PopItemWidth()
                ImGui.Spacing()
                ImGui.TextColored(ImVec4(.5, .5, .5, 1), "Warning: Setting delay too low may cause a temporary server ban.")
                ImGui.Spacing()
            end
        elseif W.CurrentTab == utf8.char(61601) .. " Auto SB & SDB" then
            ImGui.TextColored(j, utf8.char(61601) .. " Auto SB & SDB")
            ImGui.Separator()
            ImGui.Spacing()
            if ImGui.CollapsingHeader(utf8.char(61459) .. " Webhook & Ping Settings", ImGuiTreeNodeFlags_DefaultOpen) then
                ImGui.Spacing()
                ImGui.PushItemWidth(-1)
                local P, j = ImGui.InputTextWithHint("##wbhook", "Discord Webhook URL", W.WebhookSB, 256)
                if P then
                    W.WebhookSB = j
                    W.SaveConfig(true)
                end
                local Y, X = ImGui.InputTextWithHint("##dping", "Discord User ID to Ping", W.DiscordPingID, 64)
                if Y then
                    W.DiscordPingID = X
                    W.SaveConfig(true)
                end
                ImGui.PopItemWidth()
                ImGui.Spacing()
            end
            if ImGui.CollapsingHeader(utf8.char(61601) .. " Super Broadcast (SB)", ImGuiTreeNodeFlags_DefaultOpen) then
                ImGui.Spacing()
                local P = W.SBEnabled and "`2RUNNING" or "`4STOPPED"
                ImGui.TextColored(ImVec4(.8, .8, .8, 1), "Status: ")
                ImGui.SameLine()
                if W.SBEnabled then
                    ImGui.TextColored(ImVec4(.4, 1, .4, 1), "RUNNING")
                else
                    ImGui.TextColored(ImVec4(1, .4, .4, 1), "STOPPED")
                end
                ImGui.SameLine()
                ImGui.TextColored(ImVec4(.8, .8, .8, 1), " | Sent: " .. (W.SBCount .. (" / " .. W.SBMax)))
                ImGui.Spacing()
                ImGui.PushItemWidth(-1)
                local j, Y = ImGui.InputTextWithHint("##sbtext", "SB Text", W.SBText, 128)
                if j then
                    W.SBText = Y
                end
                ImGui.PopItemWidth()
                ImGui.Spacing()
                ImGui.PushItemWidth(100)
                local X, M = ImGui.InputInt("Amount", W.SBMax)
                if X then
                    W.SBMax = M
                end
                ImGui.PopItemWidth()
                ImGui.SameLine()
                if ImGui.Button("+ 1H") then
                    W.SBMax = W.SBMax + 20
                end
                ImGui.SameLine()
                if ImGui.Button("+ 2H") then
                    W.SBMax = W.SBMax + 40
                end
                ImGui.SameLine()
                if ImGui.Button("+ 3H") then
                    W.SBMax = W.SBMax + 60
                end
                ImGui.Spacing()
                local z, o = ImGui.Checkbox("Auto-Copy Sign Text", W.SBCopyText)
                if z then
                    W.SBCopyText = o
                    W.SaveConfig(true)
                end
                ImGui.SameLine()
                local q, S = ImGui.Checkbox("Safe Mode (Auto Warp Back)", W.SBSafeMode)
                if q then
                    W.SBSafeMode = S
                end
                ImGui.Spacing()
                ImGui.PushItemWidth(150)
                local O, V = ImGui.InputTextWithHint("##sbdoneworld", "Done World", W.SBDoneWorld, 64)
                if O then
                    W.SBDoneWorld = V
                end
                ImGui.PopItemWidth()
                ImGui.SameLine()
                local e, v = ImGui.Checkbox("Warp When Done", W.SBUseDoneWorld)
                if e then
                    W.SBUseDoneWorld = v
                end
                ImGui.Spacing()
                ImGui.Separator()
                ImGui.Spacing()
                if ImGui.Button("START SB", ImVec2(100, 30)) then
                    W.StartSB()
                end
                ImGui.SameLine()
                if ImGui.Button("STOP SB", ImVec2(100, 30)) then
                    W.StopSB()
                end
                ImGui.SameLine()
                if ImGui.Button("RESET COUNT##sb", ImVec2(100, 30)) then
                    W.ResetSB()
                    W.LocalChat("`c[WinProxy]: `2SB Count and statistics reset to 0!")
                end
                ImGui.Spacing()
            end
            ImGui.Spacing()
            ImGui.Separator()
            ImGui.Spacing()
            ImGui.TextColored(j, utf8.char(61601) .. " Super Duper Broadcast (SDB)")
            ImGui.Separator()
            ImGui.Spacing()
            if ImGui.CollapsingHeader(utf8.char(61601) .. " Super Duper Broadcast (SDB)", ImGuiTreeNodeFlags_DefaultOpen) then
                ImGui.Spacing()
                ImGui.PushItemWidth(-1)
                local P, j = ImGui.InputTextWithHint("##sdbl1", "Line 1", W.SDBLine1, 64)
                if P then
                    W.SDBLine1 = j
                end
                local Y, X = ImGui.InputTextWithHint("##sdbl2", "Line 2", W.SDBLine2, 64)
                if Y then
                    W.SDBLine2 = X
                end
                local M, z = ImGui.InputTextWithHint("##sdbl3", "Line 3", W.SDBLine3, 64)
                if M then
                    W.SDBLine3 = z
                end
                ImGui.PopItemWidth()
                ImGui.Spacing()
                ImGui.PushItemWidth(100)
                local o, q = ImGui.InputInt("SDB Amount", W.SDBMax)
                if o then
                    W.SDBMax = q
                end
                local S, O = ImGui.InputInt("Extra Delay (Mins)", W.SDBExtraTimer)
                if S then
                    W.SDBExtraTimer = O
                    W.SDBTotalDelay = 5 + W.SDBExtraTimer
                end
                ImGui.PopItemWidth()
                ImGui.Spacing()
                ImGui.Separator()
                ImGui.Spacing()
                if ImGui.Button("START SDB", ImVec2(100, 30)) then
                    W.StartSDB()
                end
                ImGui.SameLine()
                if ImGui.Button("STOP SDB", ImVec2(100, 30)) then
                    W.StopSDB()
                end
                ImGui.SameLine()
                if ImGui.Button("RESET COUNT##sdb", ImVec2(100, 30)) then
                    W.ResetSDB()
                    W.LocalChat("`c[WinProxy]: `2SDB Count reset to 0!")
                end
                ImGui.Spacing()
            end
        elseif W.CurrentTab == utf8.char(61923) .. " Casino" then
            ImGui.TextColored(j, utf8.char(61923) .. " Casino & Gambling Settings")
            ImGui.Separator()
            ImGui.Spacing()
            if ImGui.CollapsingHeader(utf8.char(61459) .. " Features & Toggles", ImGuiTreeNodeFlags_DefaultOpen) then
                ImGui.Spacing()
                local P, j = ImGui.Checkbox("Auto Use Champagne Before Spin (Wheel)", W.AutoChampWheel)
                if P then
                    W.AutoChampWheel = j
                    W.SaveConfig(true)
                    W.LocalChat("`c[WinProxy]: `9Auto Use Champagne Before Spin is now " .. ((W.AutoChampWheel and "`2ON" or "`4OFF")))
                end
                ImGui.Spacing()
                ImGui.Separator()
                ImGui.Spacing()
                if select(2, ImGui.Checkbox("Off", W.CasinoMode == 0)) and W.CasinoMode ~= 0 then
                    W.ToggleCasino(W.CasinoMode)
                end
                if select(2, ImGui.Checkbox("All (Reme/Leme/Qeme)", W.CasinoMode == 7)) and W.CasinoMode ~= 7 then
                    W.ToggleCasino(7)
                end
                if select(2, ImGui.Checkbox("Reme", W.CasinoMode == 1)) and W.CasinoMode ~= 1 then
                    W.ToggleCasino(1)
                end
                if select(2, ImGui.Checkbox("Qeme", W.CasinoMode == 2)) and W.CasinoMode ~= 2 then
                    W.ToggleCasino(2)
                end
                if select(2, ImGui.Checkbox("Leme", W.CasinoMode == 3)) and W.CasinoMode ~= 3 then
                    W.ToggleCasino(3)
                end
                if select(2, ImGui.Checkbox("Leme S", W.CasinoMode == 4)) and W.CasinoMode ~= 4 then
                    W.ToggleCasino(4)
                end
                if select(2, ImGui.Checkbox("Ceme", W.CasinoMode == 5)) and W.CasinoMode ~= 5 then
                    W.ToggleCasino(5)
                end
                ImGui.BeginGroup()
                if select(2, ImGui.Checkbox("Lewa", W.CasinoMode == 6)) and W.CasinoMode ~= 6 then
                    W.ToggleCasino(6)
                end
                if W.CasinoMode == 6 then
                    ImGui.SameLine()
                    ImGui.PushItemWidth(120)
                    local P, j = ImGui.InputInt("Multiplier", W.CasinoLewaMulti)
                    if P then
                        W.CasinoLewaMulti = j
                        if W.CasinoLewaMulti < 5 then
                            W.CasinoLewaMulti = 5
                        end
                        if W.CasinoLewaMulti > 7 then
                            W.CasinoLewaMulti = 7
                        end
                        W.SaveConfig(true)
                    end
                    ImGui.PopItemWidth()
                end
                ImGui.EndGroup()
                ImGui.Spacing()
                ImGui.Text("Result Format:")
                if ImGui.RadioButton("[Result] (Original)", W.CasinoFormatIdx == 1) then
                    W.CasinoFormatIdx = 1
                    W.SaveConfig(true)
                end
                if ImGui.RadioButton("(Original) [Result]", W.CasinoFormatIdx == 2) then
                    W.CasinoFormatIdx = 2
                    W.SaveConfig(true)
                end
                ImGui.Spacing()
            end
        elseif W.CurrentTab == utf8.char(61723) .. " BTK/BJ" then
            ImGui.TextColored(j, utf8.char(61723) .. " BTK/BJ (Custom Tile Setup)")
            ImGui.Separator()
            ImGui.Spacing()
            ImGui.TextColored(ImVec4(.8, .8, .8, 1), "Game Mode:")
            if ImGui.RadioButton("BTK (Most Gems)", W.BTK_Mode == "BTK") then
                W.BTK_Mode = "BTK"
                W.SaveConfig(true)
            end
            ImGui.SameLine()
            if ImGui.RadioButton("BJ (Blackjack 21)", W.BTK_Mode == "BJ") then
                W.BTK_Mode = "BJ"
                W.SaveConfig(true)
            end
            ImGui.Spacing()
            ImGui.Separator()
            ImGui.Spacing()
            ImGui.TextColored(ImVec4(.8, .8, .8, 1), "1. Set Coordinates (Click Touch and tap tile, or Stand)")
            if W.BTK_SelectingTarget then
                ImGui.TextColored(ImVec4(1, .8, .2, 1), ">> Touch/Punch tile for: " .. W.BTK_SelectingTarget)
            end
            ImGui.BeginChild("BTK_Coords", ImVec2(0, 202), true)
            local P = GetLocal()
            local Y = P and (P.pos and math.floor(P.pos.x / 32)) or 0
            local X = P and (P.pos and math.floor(P.pos.y / 32)) or 0
            local function M(P, j, M)
                ImGui.TextColored(ImVec4(.4, .8, 1, 1), string.format("%-15s : (%d, %d)", P, j, M))
                ImGui.SameLine(175)
                local z = (W.BTK_SelectingTarget == P)
                local o = z and ("Touching...##" .. P) or ("Touch##" .. P)
                if ImGui.Button(o) then
                    if z then
                        W.BTK_SelectingTarget = nil
                        W.LocalChat("`c[WinProxy]: `4Touch selection cancelled.")
                    else
                        W.BTK_SelectingTarget = P
                        W.LocalChat("`c[WinProxy]: `9Touch or Punch any tile to set `2" .. P)
                    end
                end
                ImGui.SameLine()
                if ImGui.Button("Stand##" .. P) then
                    W.SetBTKCoordByTouch(P, Y, X)
                end
            end
            M("Host Center", W.BTK_CenterX, W.BTK_CenterY)
            M("Bet P1", W.BTK_Bet1X, W.BTK_Bet1Y)
            M("Bet P2", W.BTK_Bet2X, W.BTK_Bet2Y)
            M("Break P1 (Mid)", W.BTK_Break1X, W.BTK_Break1Y)
            M("Break P2 (Mid)", W.BTK_Break2X, W.BTK_Break2Y)
            M("Tax Drop (Mid)", W.BTK_TaxX, W.BTK_TaxY)
            M("Magplant (Top)", W.BTK_MagX, W.BTK_MagY)
            ImGui.EndChild()
            ImGui.Spacing()
            if ImGui.Button("Take Remote Magplant", ImVec2(398, 30)) then
                if W.BTK_MagX > 0 then
                    RunThread(function()
                        local P = W.BTK_MagX
                        local j = W.BTK_MagY + 1
                        FindPath(W.BTK_MagX, W.BTK_MagY)
                        Sleep(850)
                        SendPacketRaw(false, { type = 3; value = 32, x = P * 32, y = j * 32; px = P, py = j, state = 0 })
                        Sleep(500)
                        SendPacket(2, "action|dialog_return\ndialog_name|magplant_edit\nx|" .. (P .. ("|\ny|" .. (j .. "|\nbuttonClicked|getRemote"))))
                        W.LocalChat("`c[WinProxy]: `9Remote collected from Magplant!")
                        Sleep(500)
                        local Y = W.BTK_GetPositions()
                        FindPath(Y.center.x, Y.center.y)
                        Sleep(850)
                    end)
                else
                    W.LocalChat("`c[WinProxy]: `4Set Magplant coordinates first!")
                end
            end
            ImGui.Spacing()
            if ImGui.Button("2. Take Bets & Calc", ImVec2(195, 30)) then
                local P = W.BTK_GetPositions()
                W.BTK_P1Bet = W.ParseBetAt(P.b1)
                W.BTK_P2Bet = W.ParseBetAt(P.b2)
                if W.BTK_P1Bet > 0 and W.BTK_P1Bet == W.BTK_P2Bet then
                    W.BTK_TotalPrize = ((W.BTK_P1Bet + W.BTK_P2Bet)) * .95
                    W.PickupTile(P.b1)
                    W.PickupTile(P.b2)
                    W.LocalChat("`c[WinProxy]: `9Bets taken! Prize (after 5% tax): `2" .. (W.BTK_TotalPrize .. " DLs"))
                else
                    W.LocalChat("`c[WinProxy]: `4Bets un-equal or empty! (P1: " .. (W.BTK_P1Bet .. (", P2: " .. (W.BTK_P2Bet .. ")"))))
                end
            end
            ImGui.SameLine()
            if ImGui.Button("3. Check Gems", ImVec2(195, 30)) then
                W.BTK_ActionCheckGems()
            end
            ImGui.Spacing()
            if ImGui.Button("4. Drop Prize, Tax & Reset Round", ImVec2(398, 30)) then
                local P = W.BTK_GetPositions()
                local j, Y = 0, 0
                if W.BTK_WinnerSide == "Left" then
                    j = W.BTK_Bet1X - 2
                    Y = W.BTK_Bet1Y
                elseif W.BTK_WinnerSide == "Right" then
                    j = W.BTK_Bet2X + 2
                    Y = W.BTK_Bet2Y
                end
                if j > 0 and Y > 0 then
                    RunThread(function()
                        local function X(P)
                            local j = math.floor(P / 10000)
                            local Y = P % 10000
                            local X = math.floor(Y / 100)
                            local M = Y % 100
                            local z = math.floor(M)
                            local o = math.floor(((M - z)) * 100 + .5)
                            if j > 0 then
                                while W.GetItemCount(W.GetIcon("Creativeps Black Gem Lock", 11550)) < j do
                                    break
                                end
                                if W.GetItemCount(W.GetIcon("Creativeps Black Gem Lock", 11550)) >= j then
                                    SendPacket(2, "action|dialog_return\ndialog_name|drop\nitem_drop|" .. (W.GetIcon("Creativeps Black Gem Lock", 11550) .. ("|\nitem_count|" .. j)))
                                    Sleep(600)
                                end
                            end
                            if X > 0 then
                                while W.GetItemCount(W.GetIcon("Creativeps Blue Gem Lock", 7188)) < X do
                                    if W.GetItemCount(W.GetIcon("Creativeps Black Gem Lock", 11550)) > 0 then
                                        SendPacket(2, "action|dialog_return\ndialog_name|info_box\nbuttonClicked|make_bluegl")
                                        Sleep(1000)
                                    else
                                        break
                                    end
                                end
                                if W.GetItemCount(W.GetIcon("Creativeps Blue Gem Lock", 7188)) >= X then
                                    SendPacket(2, "action|dialog_return\ndialog_name|drop\nitem_drop|" .. (W.GetIcon("Creativeps Blue Gem Lock", 7188) .. ("|\nitem_count|" .. X)))
                                    Sleep(600)
                                end
                            end
                            if z > 0 then
                                while W.GetItemCount(W.GetIcon("Creativeps Diamond Lock", 1796)) < z do
                                    if W.GetItemCount(W.GetIcon("Creativeps Blue Gem Lock", 7188)) > 0 then
                                        SendPacketRaw(false, { type = 10; value = 7188 })
                                        Sleep(1000)
                                    elseif W.GetItemCount(W.GetIcon("Creativeps Black Gem Lock", 11550)) > 0 then
                                        SendPacket(2, "action|dialog_return\ndialog_name|info_box\nbuttonClicked|make_bluegl")
                                        Sleep(1000)
                                    else
                                        break
                                    end
                                end
                                if W.GetItemCount(W.GetIcon("Creativeps Diamond Lock", 1796)) >= z then
                                    SendPacket(2, "action|dialog_return\ndialog_name|drop\nitem_drop|" .. (W.GetIcon("Creativeps Diamond Lock", 1796) .. ("|\nitem_count|" .. z)))
                                    Sleep(600)
                                end
                            end
                            if o > 0 then
                                while W.GetItemCount(W.GetIcon("Creativeps World Lock", 242)) < o do
                                    if W.GetItemCount(W.GetIcon("Creativeps Diamond Lock", 1796)) > 0 then
                                        SendPacketRaw(false, { type = 10; value = 1796 })
                                        Sleep(1000)
                                    elseif W.GetItemCount(W.GetIcon("Creativeps Blue Gem Lock", 7188)) > 0 then
                                        SendPacketRaw(false, { type = 10; value = 7188 })
                                        Sleep(1000)
                                    elseif W.GetItemCount(W.GetIcon("Creativeps Black Gem Lock", 11550)) > 0 then
                                        SendPacket(2, "action|dialog_return\ndialog_name|info_box\nbuttonClicked|make_bluegl")
                                        Sleep(1000)
                                    else
                                        break
                                    end
                                end
                                if W.GetItemCount(W.GetIcon("Creativeps World Lock", 242)) >= o then
                                    SendPacket(2, "action|dialog_return\ndialog_name|drop\nitem_drop|" .. (W.GetIcon("Creativeps World Lock", 242) .. ("|\nitem_count|" .. o)))
                                    Sleep(600)
                                end
                            end
                        end
                        FindPath(j, Y)
                        Sleep(850)
                        X(W.BTK_TotalPrize)
                        W.LocalChat("`c[WinProxy]: `9Dropped Prize: `2" .. (W.BTK_TotalPrize .. " DLs"))
                        Sleep(500)
                        local M = W.BTK_P1Bet + W.BTK_P2Bet
                        local z = ((M * .05)) / 2
                        local o = P.tax[2].x
                        local q = P.tax[2].y
                        if z > 0 and o > 0 then
                            pcall(function()
                                ChangeValue("[C] Modfly", true)
                            end)
                            FindPath(o, q)
                            Sleep(850)
                            X(z)
                            W.LocalChat("`c[WinProxy]: `9Dropped Tax (50%): `2" .. (z .. " DLs"))
                            Sleep(500)
                            pcall(function()
                                ChangeValue("[C] Modfly", false)
                            end)
                        end
                        for P, j in ipairs(P.p1) do
                            FindPath(j.x, j.y)
                            Sleep(400)
                            SendPacketRaw(false, { type = 3, value = 5640; px = j.x, py = j.y, x = j.x * 32, y = j.y * 32 })
                            Sleep(150)
                        end
                        for P, j in ipairs(P.p2) do
                            FindPath(j.x, j.y)
                            Sleep(400)
                            SendPacketRaw(false, { type = 3; value = 5640, px = j.x; py = j.y, x = j.x * 32, y = j.y * 32 })
                            Sleep(150)
                        end
                        W.BTK_TotalPrize = 0
                        W.BTK_P1Bet = 0
                        W.BTK_P2Bet = 0
                        W.BTK_WinnerSide = nil
                        FindPath(P.center.x, P.center.y)
                        Sleep(850)
                    end)
                else
                    W.LocalChat("`c[WinProxy]: `4Draw/Target Drop invalid! Drop manually.")
                end
            end
        elseif W.CurrentTab == utf8.char(61465) .. " Auto Pull" then
            ImGui.TextColored(j, utf8.char(61465) .. " Auto Pull & Modal Settings")
            ImGui.Separator()
            ImGui.Spacing()
            if ImGui.CollapsingHeader("Master Control", ImGuiTreeNodeFlags_DefaultOpen) then
                local P, j = ImGui.Checkbox("Master Enable Auto Pull (OnSpawn)", W.AutoPull)
                if P then
                    W.AutoPull = j
                    W.SaveConfig(true)
                end
                local Y, X = ImGui.Checkbox("Area Scan Mode (Scan Pos)", W.AutoPullAreaScan)
                if Y then
                    if X and not W.AutoPullAreaScan then
                        W.AutoPullAreaScan = true
                        W.ManageAreaPullThread()
                    else
                        W.AutoPullAreaScan = X
                    end
                    W.SaveConfig(true)
                end
                ImGui.Spacing()
            end
            if ImGui.CollapsingHeader("Target Coordinates (5 Positions)", ImGuiTreeNodeFlags_DefaultOpen) then
                ImGui.TextColored(ImVec4(.8, .8, .8, 1), "Setup multiple target positions for pulling:")
                ImGui.Spacing()
                for P = 1, 5, 1 do
                    local j = W.AutoPullPos[P]
                    local Y = ((j.x > 0 or j.y > 0)) and ImVec4(.2, 1, .3, 1) or ImVec4(.6, .6, .6, 1)
                    local X = ((j.x > 0 or j.y > 0)) and string.format("Slot %d: (%d, %d)", P, j.x, j.y) or string.format("Slot %d: Not Set", P)
                    ImGui.TextColored(Y, X)
                    ImGui.SameLine(180)
                    if ImGui.Button("My Pos##" .. P) then
                        local j = GetLocal()
                        if j and j.pos then
                            W.AutoPullPos[P].x = math.floor(j.pos.x / 32)
                            W.AutoPullPos[P].y = math.floor(j.pos.y / 32)
                            W.SaveConfig(true)
                            W.LocalChat("`c[WinProxy]: `2Target tile " .. (P .. (" set to your position: (" .. (W.AutoPullPos[P].x .. (", " .. (W.AutoPullPos[P].y .. ")"))))))
                        end
                    end
                    ImGui.SameLine()
                    local M = (W.AutoPullSettingSlot == P) and "Touching...##" .. P or "Touch##" .. P
                    if ImGui.Button(M) then
                        W.AutoPullSettingSlot = P
                        W.LocalChat("`c[WinProxy]: `9Touch any tile on screen to set `2Pos " .. P)
                    end
                    ImGui.SameLine()
                    if ImGui.Button("Clear##" .. P) then
                        W.AutoPullPos[P].x = 0
                        W.AutoPullPos[P].y = 0
                        W.SaveConfig(true)
                    end
                end
                ImGui.Spacing()
                if ImGui.Button("Reset All 5 Positions") then
                    for P = 1, 5, 1 do
                        W.AutoPullPos[P] = { x = 0, y = 0 }
                    end
                    W.SaveConfig(true)
                    W.LocalChat("`c[WinProxy]: `4All 5 Auto Pull positions have been reset!")
                end
                ImGui.Spacing()
            end
            if ImGui.CollapsingHeader("Minimal Modal Settings", ImGuiTreeNodeFlags_DefaultOpen) then
                local P = tonumber(W.AutoPullMinModal) or 0
                local j = (P > 0) and (P .. " BGL (Active)") or "No Limit (Pull All)"
                ImGui.TextColored(ImVec4(.8, .8, .8, 1), "Status: " .. j)
                ImGui.PushItemWidth(150)
                local Y, X = ImGui.InputInt("Min Modal (BGL)", W.AutoPullMinModal)
                if Y then
                    W.AutoPullMinModal = X
                    if W.AutoPullMinModal < 0 then
                        W.AutoPullMinModal = 0
                    end
                    W.SaveConfig(true)
                end
                ImGui.PopItemWidth()
                ImGui.Spacing()
            end
            if ImGui.CollapsingHeader("Live Player Blacklist", ImGuiTreeNodeFlags_DefaultOpen) then
                local P = {}
                if type(W.AutoPullBlacklist) == "table" then
                    for j, Y in ipairs(W.AutoPullBlacklist) do
                        table.insert(P, tonumber(Y) or 0)
                    end
                    table.sort(P)
                end
                if #P == 0 then
                    ImGui.TextColored(ImVec4(.5, .5, .5, 1), "No UIDs currently blacklisted.")
                else
                    ImGui.TextColored(ImVec4(.4, 1, .4, 1), "Total Blacklisted: " .. (#P .. " UID(s)"))
                    ImGui.TextWrapped(table.concat(P, ", "))
                end
                ImGui.Spacing()
                ImGui.TextColored(ImVec4(.8, .8, .8, 1), "Select players in world to block:")
                if not W.LastPlayerCacheTime or (os.clock() - W.LastPlayerCacheTime > 1) then
                    W.CachedPlayerList = GetPlayerList()
                    W.LastPlayerCacheTime = os.clock()
                end
                local j = W.CachedPlayerList
                local Y = GetLocal() and (GetLocal()).userid or 0
                local X = 0
                if j then
                    for P, j in pairs(j) do
                        local M = j.userid or j.netid or 0
                        local z = j.name or "Unknown"
                        local o = z:gsub("%[.-%]", "")
                        o = o:gsub("%(.-%)", "")
                        o = (o:gsub("%s+", " ")):match("^%s*(.-)%s*$") or "Unknown"
                        local q = o:gsub("`.", "")
                        if M ~= 0 and (M ~= Y and not (q:lower()):find("spammer slave")) then
                            X = X + 1
                            local P = false
                            local j = -1
                            for Y, X in ipairs(W.AutoPullBlacklist) do
                                if tonumber(X) == M then
                                    P = true
                                    j = Y
                                    break
                                end
                            end
                            local Y, z = ImGui.Checkbox(q .. (" (UID: " .. (M .. (")##cb_" .. M))), P)
                            if Y then
                                if z then
                                    table.insert(W.AutoPullBlacklist, M)
                                else
                                    if j > 0 then
                                        table.remove(W.AutoPullBlacklist, j)
                                    end
                                end
                                W.SaveConfig(true)
                            end
                        end
                    end
                end
                if X == 0 then
                    ImGui.TextColored(ImVec4(.5, .5, .5, 1), "No other players in this world.")
                end
                ImGui.Spacing()
                ImGui.PushItemWidth(100)
                local M, z = ImGui.InputInt("##newuidapt", W.NewBlacklistUID)
                if M then
                    W.NewBlacklistUID = z
                end
                ImGui.PopItemWidth()
                ImGui.SameLine()
                if ImGui.Button("Add UID") and W.NewBlacklistUID > 0 then
                    local P = tonumber(W.NewBlacklistUID)
                    local j = false
                    for Y, X in ipairs(W.AutoPullBlacklist) do
                        if tonumber(X) == P then
                            j = true
                            break
                        end
                    end
                    if not j then
                        table.insert(W.AutoPullBlacklist, P)
                        W.SaveConfig(true)
                    end
                    W.NewBlacklistUID = 0
                end
                ImGui.SameLine()
                if ImGui.Button("Remove UID") and W.NewBlacklistUID > 0 then
                    local P = tonumber(W.NewBlacklistUID)
                    local j = {}
                    for Y, X in ipairs(W.AutoPullBlacklist) do
                        if tonumber(X) ~= P then
                            table.insert(j, X)
                        end
                    end
                    W.AutoPullBlacklist = j
                    W.SaveConfig(true)
                    W.NewBlacklistUID = 0
                end
                ImGui.Spacing()
            end
        elseif W.CurrentTab == utf8.char(62096) .. " Magplant" then
            ImGui.TextColored(j, utf8.char(62096) .. " Magplant Tools")
            ImGui.Separator()
            ImGui.Spacing()
            local P = W.MagRunning and ("Running (" .. (tostring(W.MagMode) .. ")")) or "Idle"
            ImGui.TextColored(ImVec4(.8, 1, .8, 1), "Status: " .. P)
            ImGui.Spacing()
            if W.MagRunning then
                if ImGui.Button(utf8.char(61517) .. " Stop Current Task", ImVec2(150, 30)) then
                    W.MagRunning = false
                    W.MagSelectID = nil
                    W.VendFindID = "1656"
                    W.VendDelay = 150
                    W.VendFromWorld = ""
                    W.VendFromX = "0"
                    W.VendFromY = "0"
                    W.VendTargetX = "0"
                    W.VendTargetY = "0"
                    W.VendDropWorld = ""
                    W.VendDropX = "0"
                    W.VendDropY = "0"
                    W.VendSetMode = "walk"
                    W.VendAutoWalk = false
                    W.VendSelectingTarget = false
                    W.VendSelectingFrom = false
                    W.VendSelectingDrop = false
                    W.VendRunning = false
                    W.VendMode = ""
                    W.VendDone = false
                    W.VendX = 0
                    W.VendY = 0
                    W.VendM2MTakeWorld = ""
                    W.VendM2MTakeX = "0"
                    W.VendM2MTakeY = "0"
                    W.VendM2MPutWorld = ""
                    W.VendM2MPutX = "0"
                    W.VendM2MPutY = "0"
                    W.VendM2MAutoMove = false
                    W.VendSelectingM2MTake = false
                    W.VendSelectingM2MPut = false
                    W.VendSelectID = nil
                    W.VendPrice = "1"
                    W.VendPriceMode = "peritem"
                    W.LocalChat("`c[WinProxy]: `4Magplant task stopped!")
                end
                ImGui.Spacing()
            else
                if ImGui.CollapsingHeader("Check Stock") then
                    ImGui.Spacing()
                    if ImGui.Button("Check Stock##btn", ImVec2(150, 30)) then
                        W.MagStart("stock")
                    end
                    if type(W.MagStockResult) == "table" and #W.MagStockResult > 0 then
                        ImGui.Spacing()
                        ImGui.TextColored(ImVec4(.4, 1, .4, 1), "Latest Stock Check:")
                        for P, j in ipairs(W.MagStockResult) do
                            ImGui.TextWrapped(tostring(j))
                        end
                    end
                    ImGui.Spacing()
                end
                local function P(P, j)
                    ImGui.TextColored(ImVec4(.8, .8, .8, 1), "Target Magplant X, Y (0 = Use Standing Position)")
                    ImGui.PushItemWidth(60)
                    local Y, X = ImGui.InputText("##TX" .. P, W.MagTargetX, 4)
                    if Y then
                        W.MagTargetX = X
                        W.SaveConfig(true)
                    end
                    ImGui.SameLine()
                    ImGui.Text(",")
                    ImGui.SameLine()
                    local M, z = ImGui.InputText("##TY" .. P, W.MagTargetY, 4)
                    if M then
                        W.MagTargetY = z
                        W.SaveConfig(true)
                    end
                    ImGui.PopItemWidth()
                    ImGui.SameLine()
                    if ImGui.Button("Set Target by Touch##" .. P) then
                        W.MagSelectingTarget = true
                        W.LocalChat("`c[WinProxy]: `eClick on the target Magplant tile!")
                    end
                    if j == "Drop" then
                        ImGui.Spacing()
                        ImGui.TextColored(ImVec4(.8, .8, .8, 1), "Drop Target World & Coordinates")
                        ImGui.PushItemWidth(100)
                        local j, Y = ImGui.InputText("World##Drop" .. P, W.MagDropWorld or "", 32)
                        if j then
                            W.MagDropWorld = Y
                            W.SaveConfig(true)
                        end
                        ImGui.SameLine()
                        local X, M = ImGui.InputText("X##Drop" .. P, W.MagDropX, 4)
                        if X then
                            W.MagDropX = M
                            W.SaveConfig(true)
                        end
                        ImGui.SameLine()
                        local z, o = ImGui.InputText("Y##Drop" .. P, W.MagDropY, 4)
                        if z then
                            W.MagDropY = o
                            W.SaveConfig(true)
                        end
                        ImGui.PopItemWidth()
                        if ImGui.Button("Set Drop Target by Touch##" .. P) then
                            W.MagSelectingDrop = true
                            W.LocalChat("`c[WinProxy]: `eClick on the tile to Drop items to!")
                        end
                    elseif j == "Take" then
                        ImGui.Spacing()
                        ImGui.TextColored(ImVec4(.8, .8, .8, 1), "Take Source World & Coordinates")
                        ImGui.PushItemWidth(100)
                        local j, Y = ImGui.InputText("World##Take" .. P, W.MagFromWorld or "", 32)
                        if j then
                            W.MagFromWorld = Y
                            W.SaveConfig(true)
                        end
                        ImGui.SameLine()
                        local X, M = ImGui.InputText("X##Take" .. P, W.MagFromX, 4)
                        if X then
                            W.MagFromX = M
                            W.SaveConfig(true)
                        end
                        ImGui.SameLine()
                        local z, o = ImGui.InputText("Y##Take" .. P, W.MagFromY, 4)
                        if z then
                            W.MagFromY = o
                            W.SaveConfig(true)
                        end
                        ImGui.PopItemWidth()
                        if ImGui.Button("Set Take Source by Touch##" .. P) then
                            W.MagSelectingFrom = true
                            W.LocalChat("`c[WinProxy]: `eClick on the tile to Take items from!")
                        end
                    end
                    ImGui.Spacing()
                    ImGui.PushItemWidth(120)
                    local o, q = ImGui.InputText("Item ID##" .. P, W.MagFindID, 16)
                    if o then
                        W.MagFindID = q
                        W.SaveConfig(true)
                    end
                    local S, O = ImGui.InputText("Delay (ms)##" .. P, tostring(W.MagDelay), 8)
                    if S then
                        W.MagDelay = tonumber(O) or W.MagDelay
                        W.SaveConfig(true)
                    end
                    ImGui.PopItemWidth()
                end
                if ImGui.CollapsingHeader("Find & Add") then
                    ImGui.Spacing()
                    P("Find", nil)
                    ImGui.Spacing()
                    if ImGui.Button("Start Find & Add", ImVec2(150, 30)) then
                        W.MagStart("find")
                    end
                    ImGui.Spacing()
                end
                if ImGui.CollapsingHeader("Take & Add") then
                    ImGui.Spacing()
                    P("Take", "Take")
                    ImGui.Spacing()
                    if ImGui.Button("Start Take & Add", ImVec2(150, 30)) then
                        W.MagStart("add")
                    end
                    ImGui.Spacing()
                end
                if ImGui.CollapsingHeader("Ret & Drop") then
                    ImGui.Spacing()
                    P("Drop", "Drop")
                    ImGui.Spacing()
                    if ImGui.Button("Start Ret & Drop", ImVec2(150, 30)) then
                        W.MagStart("drop")
                    end
                    ImGui.Spacing()
                end
                if ImGui.CollapsingHeader("Ret & Trash") then
                    ImGui.Spacing()
                    P("Trash", nil)
                    ImGui.Spacing()
                    if ImGui.Button("Start Ret & Trash", ImVec2(150, 30)) then
                        W.MagStart("trash")
                    end
                    ImGui.Spacing()
                end
                if ImGui.CollapsingHeader("Set Magplant") then
                    ImGui.Spacing()
                    if W.MagSetMode == "walk" then
                        ImGui.TextColored(ImVec4(.8, .8, .8, 1), "Target Magplant X, Y (0 = Use Standing Position)")
                        ImGui.PushItemWidth(60)
                        local P, j = ImGui.InputText("##TXSet", W.MagTargetX, 4)
                        if P then
                            W.MagTargetX = j
                            W.SaveConfig(true)
                        end
                        ImGui.SameLine()
                        ImGui.Text(",")
                        ImGui.SameLine()
                        local Y, X = ImGui.InputText("##TYSet", W.MagTargetY, 4)
                        if Y then
                            W.MagTargetY = X
                            W.SaveConfig(true)
                        end
                        ImGui.PopItemWidth()
                        ImGui.SameLine()
                        if ImGui.Button("Set Target by Touch##Set") then
                            W.MagSelectingTarget = true
                            W.LocalChat("`c[WinProxy]: `eClick on the target Magplant tile!")
                        end
                        ImGui.Spacing()
                    end
                    ImGui.PushItemWidth(120)
                    local P, j = ImGui.InputText("Item ID##Set", W.MagFindID, 16)
                    if P then
                        W.MagFindID = j
                        W.SaveConfig(true)
                    end
                    local Y, X = ImGui.InputText("Delay (ms)##Set", tostring(W.MagDelay), 8)
                    if Y then
                        W.MagDelay = tonumber(X) or W.MagDelay
                        W.SaveConfig(true)
                    end
                    ImGui.PopItemWidth()
                    ImGui.Spacing()
                    if ImGui.Button("Mode: " .. (((W.MagSetMode == "wrench" and "Wrench Target" or "Walk Right")) .. "##MagSetMode"), ImVec2(200, 25)) then
                        W.MagSetMode = (W.MagSetMode == "wrench") and "walk" or "wrench"
                        W.SaveConfig(true)
                    end
                    ImGui.Spacing()
                    if ImGui.Button("Start Set Magplant", ImVec2(150, 30)) then
                        W.MagStart("set")
                    end
                    ImGui.Spacing()
                end
                if ImGui.CollapsingHeader("Mag to Mag") then
                    ImGui.Spacing()
                    ImGui.TextColored(ImVec4(.9, .9, .5, 1), "Source (Take) Magplant")
                    ImGui.PushItemWidth(100)
                    local P, j = ImGui.InputText("World##Take", W.MagM2MTakeWorld or "", 32)
                    if P then
                        W.MagM2MTakeWorld = j
                        W.SaveConfig(true)
                    end
                    ImGui.SameLine()
                    local Y, X = ImGui.InputText("X##Take", W.MagM2MTakeX, 4)
                    if Y then
                        W.MagM2MTakeX = X
                        W.SaveConfig(true)
                    end
                    ImGui.SameLine()
                    local M, z = ImGui.InputText("Y##Take", W.MagM2MTakeY, 4)
                    if M then
                        W.MagM2MTakeY = z
                        W.SaveConfig(true)
                    end
                    ImGui.PopItemWidth()
                    if ImGui.Button("Set Source by Touch") then
                        W.MagSelectingM2MTake = true
                        W.LocalChat("`c[WinProxy]: `eClick on the Source (Take) Magplant tile!")
                    end
                    ImGui.Spacing()
                    ImGui.TextColored(ImVec4(.5, .9, .5, 1), "Destination (Put) Magplant")
                    ImGui.PushItemWidth(100)
                    local o, q = ImGui.InputText("World##Put", W.MagM2MPutWorld or "", 32)
                    if o then
                        W.MagM2MPutWorld = q
                        W.SaveConfig(true)
                    end
                    ImGui.SameLine()
                    local S, O = ImGui.InputText("X##Put", W.MagM2MPutX, 4)
                    if S then
                        W.MagM2MPutX = O
                        W.SaveConfig(true)
                    end
                    ImGui.SameLine()
                    local V, e = ImGui.InputText("Y##Put", W.MagM2MPutY, 4)
                    if V then
                        W.MagM2MPutY = e
                        W.SaveConfig(true)
                    end
                    ImGui.PopItemWidth()
                    if ImGui.Button("Set Dest by Touch") then
                        W.MagSelectingM2MPut = true
                        W.LocalChat("`c[WinProxy]: `eClick on the Destination (Put) Magplant tile!")
                    end
                    ImGui.Spacing()
                    ImGui.PushItemWidth(120)
                    local v, f = ImGui.InputText("Delay (ms)##M2M", tostring(W.MagDelay), 8)
                    if v then
                        W.MagDelay = tonumber(f) or W.MagDelay
                        W.SaveConfig(true)
                    end
                    ImGui.PopItemWidth()
                    ImGui.Spacing()
                    if ImGui.Button("Start Mag to Mag", ImVec2(150, 30)) then
                        W.MagStart("mag2mag")
                    end
                    ImGui.Spacing()
                end
            end
            ImGui.Spacing()
        elseif W.CurrentTab == utf8.char(62097) .. " Vending" then
            ImGui.TextColored(j, utf8.char(62097) .. " Vending Tools")
            ImGui.Separator()
            ImGui.Spacing()
            local P = W.VendRunning and ("Running (" .. (tostring(W.VendMode) .. ")")) or "Idle"
            ImGui.TextColored(ImVec4(.8, 1, .8, 1), "Status: " .. P)
            ImGui.Spacing()
            if W.VendRunning then
                if ImGui.Button(utf8.char(61517) .. " Stop Current Task", ImVec2(150, 30)) then
                    W.VendRunning = false
                    W.VendSelectID = nil
                    W.VendPrice = "1"
                    W.VendPriceMode = "peritem"
                    W.LocalChat("`c[WinProxy]: `4Vending task stopped!")
                end
                ImGui.Spacing()
            else
                local function P(P, j)
                    ImGui.TextColored(ImVec4(.8, .8, .8, 1), "Target Vending X, Y (0 = Use Standing Position)")
                    ImGui.PushItemWidth(60)
                    local Y, X = ImGui.InputText("##VTX" .. P, W.VendTargetX, 4)
                    if Y then
                        W.VendTargetX = X
                        W.SaveConfig(true)
                    end
                    ImGui.SameLine()
                    ImGui.Text(",")
                    ImGui.SameLine()
                    local M, z = ImGui.InputText("##VTY" .. P, W.VendTargetY, 4)
                    if M then
                        W.VendTargetY = z
                        W.SaveConfig(true)
                    end
                    ImGui.PopItemWidth()
                    ImGui.SameLine()
                    if ImGui.Button("Set Target by Touch##V" .. P) then
                        W.VendSelectingTarget = true
                        W.LocalChat("`c[WinProxy]: `eClick on the target Vending tile!")
                    end
                    if j == "Take" then
                        ImGui.Spacing()
                        ImGui.TextColored(ImVec4(.8, .8, .8, 1), "Take Source World & Coordinates")
                        ImGui.PushItemWidth(100)
                        local P, j = ImGui.InputText("World##VTakeSrc", W.VendFromWorld or "", 32)
                        if P then
                            W.VendFromWorld = j
                            W.SaveConfig(true)
                        end
                        ImGui.SameLine()
                        local Y, X = ImGui.InputText("X##VTakeSrc", W.VendFromX, 4)
                        if Y then
                            W.VendFromX = X
                            W.SaveConfig(true)
                        end
                        ImGui.SameLine()
                        local M, z = ImGui.InputText("Y##VTakeSrc", W.VendFromY, 4)
                        if M then
                            W.VendFromY = z
                            W.SaveConfig(true)
                        end
                        ImGui.PopItemWidth()
                        if ImGui.Button("Set Take Source by Touch##V") then
                            W.VendSelectingFrom = true
                            W.LocalChat("`c[WinProxy]: `eClick on the Take X,Y tile!")
                        end
                    end
                    if j == "Drop" then
                        ImGui.Spacing()
                        ImGui.TextColored(ImVec4(.8, .8, .8, 1), "Drop Target World & Coordinates")
                        ImGui.PushItemWidth(100)
                        local j, Y = ImGui.InputText("World##VDrop" .. P, W.VendDropWorld or "", 32)
                        if j then
                            W.VendDropWorld = Y
                            W.SaveConfig(true)
                        end
                        ImGui.SameLine()
                        local X, M = ImGui.InputText("X##VDrop" .. P, W.VendDropX, 4)
                        if X then
                            W.VendDropX = M
                            W.SaveConfig(true)
                        end
                        ImGui.SameLine()
                        local z, o = ImGui.InputText("Y##VDrop" .. P, W.VendDropY, 4)
                        if z then
                            W.VendDropY = o
                            W.SaveConfig(true)
                        end
                        ImGui.PopItemWidth()
                        if ImGui.Button("Set Drop Target by Touch##V" .. P) then
                            W.VendSelectingDrop = true
                            W.LocalChat("`c[WinProxy]: `eClick on the tile to Drop items to!")
                        end
                    end
                    ImGui.Spacing()
                    ImGui.PushItemWidth(120)
                    local o, q = ImGui.InputText("Item ID##V" .. P, W.VendFindID, 16)
                    if o then
                        W.VendFindID = q
                        W.SaveConfig(true)
                    end
                    local S, O = ImGui.InputText("Delay (ms)##V" .. P, tostring(W.VendDelay), 8)
                    if S then
                        W.VendDelay = tonumber(O) or W.VendDelay
                        W.SaveConfig(true)
                    end
                    ImGui.PopItemWidth()
                end
                if ImGui.CollapsingHeader("Find & Add") then
                    ImGui.Spacing()
                    P("Find", nil)
                    ImGui.Spacing()
                    if ImGui.Button("Start Find & Add##V", ImVec2(150, 30)) then
                        W.VendStart("find")
                    end
                    ImGui.Spacing()
                end
                if ImGui.CollapsingHeader("Take & Add") then
                    ImGui.Spacing()
                    P("Take", "Take")
                    ImGui.Spacing()
                    if ImGui.Button("Start Take & Add##V", ImVec2(150, 30)) then
                        W.VendStart("add")
                    end
                    ImGui.Spacing()
                end
                if ImGui.CollapsingHeader("Ret & Drop") then
                    ImGui.Spacing()
                    P("Drop", "Drop")
                    ImGui.Spacing()
                    if ImGui.Button("Start Ret & Drop##V", ImVec2(150, 30)) then
                        W.VendStart("drop")
                    end
                    ImGui.Spacing()
                end
                if ImGui.CollapsingHeader("Ret & Trash") then
                    ImGui.Spacing()
                    P("Trash", nil)
                    ImGui.Spacing()
                    if ImGui.Button("Start Ret & Trash##V", ImVec2(150, 30)) then
                        W.VendStart("trash")
                    end
                    ImGui.Spacing()
                end
                if ImGui.CollapsingHeader("Set Vending") then
                    ImGui.Spacing()
                    if W.VendSetMode == "walk" then
                        ImGui.TextColored(ImVec4(.8, .8, .8, 1), "Target Vending X, Y (0 = Use Standing Position)")
                        ImGui.PushItemWidth(60)
                        local P, j = ImGui.InputText("##VTXSet", W.VendTargetX, 4)
                        if P then
                            W.VendTargetX = j
                            W.SaveConfig(true)
                        end
                        ImGui.SameLine()
                        ImGui.Text(",")
                        ImGui.SameLine()
                        local Y, X = ImGui.InputText("##VTYSet", W.VendTargetY, 4)
                        if Y then
                            W.VendTargetY = X
                            W.SaveConfig(true)
                        end
                        ImGui.PopItemWidth()
                        ImGui.SameLine()
                        if ImGui.Button("Set Target by Touch##VSet") then
                            W.VendSelectingTarget = true
                            W.LocalChat("`c[WinProxy]: `eClick on the target Vending tile!")
                        end
                        ImGui.Spacing()
                    end
                    ImGui.PushItemWidth(120)
                    local P, j = ImGui.InputText("Item ID##VSet", W.VendFindID, 16)
                    if P then
                        W.VendFindID = j
                        W.SaveConfig(true)
                    end
                    local Y, X = ImGui.InputText("Price##VSet", W.VendPrice, 8)
                    if Y then
                        W.VendPrice = X
                        W.SaveConfig(true)
                    end
                    ImGui.PopItemWidth()
                    ImGui.Spacing()
                    if ImGui.Button("Price Mode: " .. (((W.VendPriceMode == "peritem" and "Items per WL" or "WLs per Item")) .. "##V"), ImVec2(200, 25)) then
                        W.VendPriceMode = (W.VendPriceMode == "peritem") and "perlock" or "peritem"
                        W.SaveConfig(true)
                    end
                    ImGui.Spacing()
                    if ImGui.Button("Set Mode: " .. (((W.VendSetMode == "wrench" and "Wrench Mode" or "Walk Mode")) .. "##V"), ImVec2(200, 25)) then
                        W.VendSetMode = (W.VendSetMode == "wrench") and "walk" or "wrench"
                        W.SaveConfig(true)
                    end
                    ImGui.Spacing()
                    if ImGui.Button("Start Set Vending##V", ImVec2(150, 30)) then
                        W.VendStart("set")
                    end
                    ImGui.Spacing()
                end
                if ImGui.CollapsingHeader("Vend to Vend") then
                    ImGui.Spacing()
                    ImGui.TextColored(ImVec4(.9, .9, .5, 1), "Source (Take) Vending Machine")
                    ImGui.PushItemWidth(100)
                    local P, j = ImGui.InputText("World##VTake", W.VendM2MTakeWorld or "", 32)
                    if P then
                        W.VendM2MTakeWorld = j
                        W.SaveConfig(true)
                    end
                    ImGui.SameLine()
                    local Y, X = ImGui.InputText("X##VTake", W.VendM2MTakeX, 4)
                    if Y then
                        W.VendM2MTakeX = X
                        W.SaveConfig(true)
                    end
                    ImGui.SameLine()
                    local M, z = ImGui.InputText("Y##VTake", W.VendM2MTakeY, 4)
                    if M then
                        W.VendM2MTakeY = z
                        W.SaveConfig(true)
                    end
                    ImGui.PopItemWidth()
                    if ImGui.Button("Set Source by Touch##V") then
                        W.VendSelectingM2MTake = true
                        W.LocalChat("`c[WinProxy]: `eClick on the Source Vending tile!")
                    end
                    ImGui.Spacing()
                    ImGui.TextColored(ImVec4(.5, .9, .5, 1), "Destination (Put) Vending Machine")
                    ImGui.PushItemWidth(100)
                    local o, q = ImGui.InputText("World##VPut", W.VendM2MPutWorld or "", 32)
                    if o then
                        W.VendM2MPutWorld = q
                        W.SaveConfig(true)
                    end
                    ImGui.SameLine()
                    local S, O = ImGui.InputText("X##VPut", W.VendM2MPutX, 4)
                    if S then
                        W.VendM2MPutX = O
                        W.SaveConfig(true)
                    end
                    ImGui.SameLine()
                    local V, e = ImGui.InputText("Y##VPut", W.VendM2MPutY, 4)
                    if V then
                        W.VendM2MPutY = e
                        W.SaveConfig(true)
                    end
                    ImGui.PopItemWidth()
                    if ImGui.Button("Set Dest by Touch##V") then
                        W.VendSelectingM2MPut = true
                        W.LocalChat("`c[WinProxy]: `eClick on the Dest Vending tile!")
                    end
                    ImGui.Spacing()
                    ImGui.PushItemWidth(120)
                    local v, f = ImGui.InputText("Delay (ms)##VM2M", tostring(W.VendDelay), 8)
                    if v then
                        W.VendDelay = tonumber(f) or W.VendDelay
                        W.SaveConfig(true)
                    end
                    ImGui.PopItemWidth()
                    ImGui.Spacing()
                    if ImGui.Button("Start Vend to Vend", ImVec2(150, 30)) then
                        W.VendStart("vend2vend")
                    end
                    ImGui.Spacing()
                end
            end
        elseif W.CurrentTab == utf8.char(61474) .. " All Logs" then
            ImGui.TextColored(j, utf8.char(61474) .. " Global Activity Logs")
            ImGui.Separator()
            ImGui.Spacing()
            if ImGui.CollapsingHeader(utf8.char(61459) .. " Features & Toggles", ImGuiTreeNodeFlags_DefaultOpen) then
                ImGui.Spacing()
                local P, j = ImGui.Checkbox("Enable Auto-Logging (/logs)", W.LogsEnabled)
                if P then
                    W.LogsEnabled = j
                    W.SaveConfig(true)
                end
                ImGui.SameLine(0, 20)
                if ImGui.Button("Clear All Logs") then
                    W.Logs = { All = {}; Casino = {}, Inventory = {} }
                    W.LocalChat("`c[WinProxy]: `9All logs have been cleared.")
                end
                ImGui.Spacing()
                ImGui.Separator()
                ImGui.Spacing()
                ImGui.TextColored(ImVec4(.8, .8, .8, 1), "Filter Category:")
                if ImGui.Button("All Logs", ImVec2(80, 25)) then
                    W.LogFilter = 1
                end
                ImGui.SameLine()
                if ImGui.Button("Casino", ImVec2(80, 25)) then
                    W.LogFilter = 2
                end
                ImGui.SameLine()
                if ImGui.Button("Inventory", ImVec2(80, 25)) then
                    W.LogFilter = 3
                end
                ImGui.Spacing()
                ImGui.Separator()
                local Y = W.Logs.All
                local X = ImVec4(1, 1, 1, 1)
                if W.LogFilter == 2 then
                    Y = W.Logs.Casino
                    X = ImVec4(.4, 1, .4, 1)
                elseif W.LogFilter == 3 then
                    Y = W.Logs.Inventory
                    X = ImVec4(1, .8, .2, 1)
                end
                ImGui.BeginChild("LogDisplayArea", ImVec2(0, 0), true)
                if #Y == 0 then
                    ImGui.TextColored(ImVec4(.5, .5, .5, 1), "No logs recorded in this category yet...")
                else
                    for P, j in ipairs(Y) do
                        ImGui.PushTextWrapPos(0)
                        local Y = j:gsub("`.", "")
                        if P % 2 == 0 then
                            ImGui.TextColored(ImVec4(.8, .8, .8, 1), Y)
                        else
                            local P = X
                            if W.LogFilter == 1 then
                                if Y:find("spun the wheel") then
                                    P = ImVec4(.4, 1, .4, 1)
                                elseif Y:find("Collected") or Y:find("Dropped") then
                                    P = ImVec4(1, .8, .2, 1)
                                end
                            end
                            ImGui.TextColored(P, Y)
                        end
                        ImGui.PopTextWrapPos()
                    end
                end
                ImGui.EndChild()
                ImGui.Spacing()
            end
        elseif W.CurrentTab == utf8.char(61548) .. " Auto Combine" then
            ImGui.TextColored(j, utf8.char(61548) .. " Auto Combine")
            ImGui.Separator()
            ImGui.Spacing()
            ImGui.TextColored(ImVec4(.8, .8, .8, 1), "Auto Combine feature is currently in development.")
        elseif W.CurrentTab == utf8.char(61562) .. " Auto Buy Pack" then
            ImGui.TextColored(j, utf8.char(61562) .. " Auto Buy Pack (Smart Detect)")
            ImGui.Separator()
            ImGui.Spacing()
            if ImGui.CollapsingHeader(utf8.char(61459) .. " Configuration", ImGuiTreeNodeFlags_DefaultOpen) then
                ImGui.Spacing()
                local P = W.ABP_IsScanningShop and "SCANNING IN PROGRESS..." or (utf8.char(61473) .. " AUTO-SCAN SHOP PACKS")
                if ImGui.Button(P, ImVec2(-1, 30)) then
                    if not W.ABP_IsScanningShop then
                        W.ABP_IsScanningShop = true
                        W.ABP_Packs = {}
                        W.ABP_PackNames = {}
                        W.ABP_AddedCmds = {}
                        RunThread(function()
                            W.LocalChat("`c[WinProxy]: `9[1/3] Auto-Scanning \'Featured\' tab...")
                            SendPacket(2, "action|store\nlocation|gem")
                            Sleep(1200)
                            W.LocalChat("`c[WinProxy]: `9[2/3] Auto-Scanning \'Locks & Stuff\' tab...")
                            SendPacket(2, "action|buy\nitem|locks")
                            Sleep(1200)
                            W.LocalChat("`c[WinProxy]: `9[3/3] Auto-Scanning \'Item Packs\' tab...")
                            SendPacket(2, "action|buy\nitem|itempack")
                            Sleep(1200)
                            table.sort(W.ABP_Packs, function(P, j)
                                return P.name:lower() < j.name:lower()
                            end)
                            W.ABP_PackNames = {}
                            for P, j in ipairs(W.ABP_Packs) do
                                table.insert(W.ABP_PackNames, j.name)
                            end
                            W.ABP_PackIdx = 1
                            W.ABP_IsScanningShop = false
                            W.LocalChat("`c[WinProxy]: `2[+] Auto-Scan Complete! Absorbed `w" .. (#W.ABP_Packs .. "`2 items (Sorted A-Z)."))
                        end)
                    end
                end
                ImGui.Spacing()
                ImGui.Separator()
                ImGui.Spacing()
                if #W.ABP_Packs == 0 then
                    ImGui.TextColored(ImVec4(1, .4, .4, 1), "Click \'Auto-Scan\' to silently load packs from the server!")
                else
                    W.ABP_PackIdx = W.SafeCombo("Select Pack", W.ABP_PackIdx, W.ABP_PackNames)
                    ImGui.Spacing()
                    ImGui.PushItemWidth(150)
                    local P, j = ImGui.InputInt("Amount to Buy", W.ABP_BuyAmount)
                    if P then
                        W.ABP_BuyAmount = j
                        if W.ABP_BuyAmount < 0 then
                            W.ABP_BuyAmount = 0
                        end
                    end
                    ImGui.SameLine()
                    ImGui.TextColored(ImVec4(.5, .5, .5, 1), "(0 = Infinite)")
                    ImGui.PopItemWidth()
                    local Y, X = ImGui.Checkbox("Buy Only (Do Not Drop)", W.ABP_BuyOnly)
                    if Y then
                        W.ABP_BuyOnly = X
                    end
                    local M, z = ImGui.Checkbox("Batch Mode (Buy until full, then Drop)", W.ABP_BatchMode)
                    if M then
                        W.ABP_BatchMode = z
                    end
                    if not W.ABP_BuyOnly then
                        ImGui.Spacing()
                        ImGui.Separator()
                        ImGui.Spacing()
                        ImGui.TextColored(ImVec4(.8, .8, .8, 1), "The script will automatically detect items from the pack")
                        ImGui.TextColored(ImVec4(.8, .8, .8, 1), "and drop them side-by-side immediately after buying.")
                        ImGui.Spacing()
                        ImGui.PushItemWidth(100)
                        local P, j = ImGui.InputInt("Drop Base X", W.ABP_DropX)
                        if P then
                            W.ABP_DropX = j
                        end
                        ImGui.SameLine()
                        local Y, X = ImGui.InputInt("Drop Base Y", W.ABP_DropY)
                        if Y then
                            W.ABP_DropY = X
                        end
                        ImGui.PopItemWidth()
                    end
                end
                ImGui.Spacing()
            end
            ImGui.Spacing()
            ImGui.Separator()
            ImGui.Spacing()
            if #W.ABP_Packs > 0 then
                local P = W.AutoBuyPack and "STOP AUTO BUY PACK" or "START AUTO BUY PACK"
                if ImGui.Button(P, ImVec2(-1, 35)) then
                    W.AutoBuyPack = not W.AutoBuyPack
                    if W.AutoBuyPack then
                        W.ManageABPThread()
                    end
                end
            else
                if ImGui.Button("START AUTO BUY PACK (LOCKED)", ImVec2(-1, 35)) then
                    W.LocalChat("`c[WinProxy]: `4Please Auto-Scan the shop first!")
                end
            end
            ImGui.Spacing()
        elseif W.CurrentTab == utf8.char(61612) .. " World" then
            ImGui.TextColored(j, utf8.char(61612) .. " World Settings")
            ImGui.Separator()
            ImGui.TextColored(ImVec4(.6, .6, .6, 1), "This feature will be available soon.")
        elseif W.CurrentTab == utf8.char(61948) .. " Theme & UI" then
            ImGui.TextColored(j, utf8.char(61948) .. " Dialog Theming")
            ImGui.Separator()
            ImGui.Spacing()
            ImGui.TextColored(ImVec4(.8, .8, .8, 1), "Select a theme for your in-game proxy dialogs.")
            ImGui.Spacing()
            if ImGui.Button("Reset to Default Theme", ImVec2(-1, 30)) then
                W.DialogBg = nil
                W.DialogBorder = nil
                W.SaveConfig(true)
                W.LocalChat("`c[WinProxy]: `9Theme reset to `wDefault")
            end
            ImGui.Spacing()
            if ImGui.CollapsingHeader("Pastel Mode", ImGuiTreeNodeFlags_DefaultOpen) then
                local P = {
                    { "Pastel Purple", "225,190,231,255", "156,39,176,255" };
                    { "Pastel Blue", "187,222,251,255"; "33,150,243,255" },
                    { "Pastel Aqua", "178,235,242,255"; "0,188,212,255" },
                    { "Pastel Green"; "200,230,201,255"; "76,175,80,255" },
                    { "Pastel Yellow"; "255,249,196,255"; "255,235,59,255" };
                    { "Pastel Orange", "255,224,178,255", "255,152,0,255" };
                    { "Pastel Pink"; "248,187,208,255"; "233,30,99,255" }
                }
                for j, Y in ipairs(P) do
                    if ImGui.Button(Y[1] .. ("##P" .. j), ImVec2(125, 25)) then
                        W.DialogBg = Y[2]
                        W.DialogBorder = Y[3]
                        W.SaveConfig(true)
                        W.LocalChat("`c[WinProxy]: `9Theme set to `w" .. Y[1])
                    end
                    if j % 3 ~= 0 and j ~= #P then
                        ImGui.SameLine()
                    end
                end
                ImGui.Spacing()
            end
            if ImGui.CollapsingHeader("Dark Mode", ImGuiTreeNodeFlags_DefaultOpen) then
                local P = {
                    { "Dark Purple", "49,27,146,255"; "81,45,168,255" },
                    { "Dark Blue"; "13,71,161,255"; "21,101,192,255" },
                    { "Dark Aqua", "0,96,100,255", "0,131,143,255" },
                    { "Dark Green"; "27,94,32,255", "46,125,50,255" },
                    { "Dark Yellow"; "245,127,23,255"; "249,168,37,255" };
                    { "Dark Orange"; "230,81,0,255", "239,108,0,255" };
                    { "Dark Red"; "183,28,28,255", "198,40,40,255" };
                    { "Dark Brown"; "62,39,35,255"; "78,52,46,255" },
                    { "Dark Grey"; "33,33,33,255"; "66,66,66,255" }
                }
                for j, Y in ipairs(P) do
                    if ImGui.Button(Y[1] .. ("##D" .. j), ImVec2(125, 25)) then
                        W.DialogBg = Y[2]
                        W.DialogBorder = Y[3]
                        W.SaveConfig(true)
                        W.LocalChat("`c[WinProxy]: `9Theme set to `w" .. Y[1])
                    end
                    if j % 3 ~= 0 and j ~= #P then
                        ImGui.SameLine()
                    end
                end
                ImGui.Spacing()
            end
            if ImGui.CollapsingHeader("Normal Mode", ImGuiTreeNodeFlags_DefaultOpen) then
                local P = {
                    { "Purple", "156,39,176,255", "106,27,154,255" };
                    { "Blue"; "33,150,243,255", "21,101,192,255" },
                    { "Aqua", "0,188,212,255", "0,131,143,255" };
                    { "Green"; "76,175,80,255", "46,125,50,255" };
                    { "Yellow"; "255,235,59,255"; "249,168,37,255" };
                    { "Orange", "255,152,0,255"; "239,108,0,255" };
                    { "Red", "244,67,54,255", "198,40,40,255" },
                    { "Brown"; "121,85,72,255"; "93,64,55,255" };
                    { "Black", "0,0,0,255", "33,33,33,255" };
                    { "Grey", "158,158,158,255", "117,117,117,255" },
                    { "White", "255,255,255,255", "224,224,224,255" }
                }
                for j, Y in ipairs(P) do
                    if ImGui.Button(Y[1] .. ("##N" .. j), ImVec2(125, 25)) then
                        W.DialogBg = Y[2]
                        W.DialogBorder = Y[3]
                        W.SaveConfig(true)
                        W.LocalChat("`c[WinProxy]: `9Theme set to `w" .. Y[1])
                    end
                    if j % 3 ~= 0 and j ~= #P then
                        ImGui.SameLine()
                    end
                end
                ImGui.Spacing()
            end
        elseif W.CurrentTab == utf8.char(61573) .. " Setting" then
            ImGui.TextColored(j, utf8.char(61573) .. " Core Proxy Settings")
            ImGui.Separator()
            ImGui.Spacing()
            if ImGui.CollapsingHeader(utf8.char(61639) .. " Configuration Management", ImGuiTreeNodeFlags_DefaultOpen) then
                ImGui.Spacing()
                ImGui.TextColored(ImVec4(.8, .8, .8, 1), "Save your current toggles and modes to your local device.")
                ImGui.TextColored(ImVec4(.5, .5, .5, 1), "File will be saved as: " .. W.ConfigFileName)
                ImGui.Spacing()
                if ImGui.Button(utf8.char(61639) .. " Save Current Config", ImVec2(190, 35)) then
                    W.SaveConfig()
                end
                ImGui.SameLine()
                if ImGui.Button(utf8.char(61473) .. " Reload Config", ImVec2(190, 35)) then
                    W.LoadConfig()
                end
                ImGui.Spacing()
                if ImGui.Button(utf8.char(61666) .. " Reset to Default", ImVec2(190, 35)) then
                    W.ResetConfig()
                end
                ImGui.Spacing()
            end
        elseif W.CurrentTab == utf8.char(61530) .. " Information" then
            ImGui.TextColored(j, utf8.char(61530) .. " Information & Support Center")
            ImGui.Spacing()
            ImGui.Separator()
            ImGui.Spacing()
            ImGui.TextColored(ImVec4(.8, .6, 1, 1), utf8.char(61447) .. " Developer Information")
            ImGui.Indent(20)
            ImGui.TextColored(ImVec4(.7, .7, 1, 1), "Creator: Win")
            ImGui.TextColored(ImVec4(.7, .7, 1, 1), "Discord: win.store")
            ImGui.Unindent(20)
            ImGui.Spacing()
            ImGui.Separator()
            ImGui.Spacing()
            ImGui.TextColored(ImVec4(.8, .9, .4, 1), utf8.char(61632) .. " Community & Support")
            ImGui.Indent(20)
            ImGui.TextColored(ImVec4(.9, .9, .9, 1), "WhatsApp Group:")
            if ImGui.Button(utf8.char(61589) .. " Join WhatsApp Group", ImVec2(220, 30)) then
                if P then
                    os.execute("start \"\" \"https://chat.whatsapp.com/IuQ3YdLm2lf4EnnCF1GcXr?mode=gi_t\"")
                else
                    LogToConsole("`2[WinProxy]: `9Link WA: https://chat.whatsapp.com/IuQ3YdLm2lf4EnnCF1GcXr?mode=gi_t")
                end
            end
            ImGui.SameLine()
            if ImGui.Button(utf8.char(61637) .. " Copy Link##copywa", ImVec2(120, 30)) then
                local P = io.popen("echo https://chat.whatsapp.com/IuQ3YdLm2lf4EnnCF1GcXr?mode=gi_t | clip", "w")
                if P then
                    P:close()
                end
                LogToConsole("`2[UI] `9WhatsApp link copied to clipboard!")
            end
            ImGui.Spacing()
            ImGui.TextColored(ImVec4(.9, .9, .9, 1), "Discord Community:")
            if ImGui.Button(utf8.char(61574) .. " Join Discord Community", ImVec2(220, 30)) then
                if P then
                    os.execute("start \"\" \"https://discord.gg/kUuE2f98FK\"")
                else
                    LogToConsole("`2[WinProxy]: `9Link Discord: https://discord.gg/kUuE2f98FK")
                end
            end
            ImGui.SameLine()
            if ImGui.Button(utf8.char(61637) .. " Copy Link##copydc", ImVec2(120, 30)) then
                if P then
                    local P = io.popen("echo https://discord.gg/kUuE2f98FK | clip", "w")
                    if P then
                        P:close()
                    end
                    LogToConsole("`2[UI] `9Discord link copied to clipboard!")
                else
                    LogToConsole("`2[UI] `9Link Discord: https://discord.gg/kUuE2f98FK")
                end
            end
            ImGui.Unindent(20)
            ImGui.Spacing()
            ImGui.Separator()
            ImGui.Spacing()
            ImGui.TextColored(ImVec4(.6, 1, .6, 1), utf8.char(61547) .. " Version Information")
            ImGui.Indent(20)
            ImGui.TextColored(ImVec4(.9, .9, .9, 1), "Proxy Version: 1.0")
            ImGui.TextColored(ImVec4(.9, .9, .9, 1), "Status: Active Development")
            ImGui.TextColored(ImVec4(1, .7, .3, 1), "Support: Available via Discord or WhatsApp")
            ImGui.Unindent(20)
            ImGui.Spacing()
        end
        ImGui.EndChild()
        ImGui.Columns(1)
    end
    ImGui.End()
end

-- ========================================================================
-- SECTION 11: In-game dialog builders (theme, menus, command lists, feature dialogs)
-- ========================================================================

function W.GetIcon(P, j)
    if W.ItemDB and W.ItemDB[P:lower()] then
        return W.ItemDB[P:lower()]
    end
    return j
end

function W.GetDialogColorPalette()
    return {
        {
            id = "pinkpastel"; category = "Pastel Themes", label = "`pPink Pastel"; icon = 510, border = "255,192,203,255",
            bg = "255,192,203,200"
        },
        {
            id = "orangepastel", category = "Pastel Themes"; label = "`6Orange Pastel", icon = 512; border = "255,218,185,255";
            bg = "255,218,185,200"
        },
        {
            id = "yellowpastel", category = "Pastel Themes", label = "`9Yellow Pastel"; icon = 514; border = "255,255,224,255";
            bg = "255,255,224,200"
        };
        {
            id = "greenpastel", category = "Pastel Themes"; label = "`2Green Pastel", icon = 516, border = "144,238,144,255";
            bg = "144,238,144,200"
        };
        {
            id = "aquapastel", category = "Cool Pastel Themes"; label = "`cAqua Pastel", icon = 518,
            border = "175,238,238,255", bg = "175,238,238,200"
        };
        {
            id = "bluepastel", category = "Cool Pastel Themes"; label = "`3Blue Pastel", icon = 520;
            border = "173,216,230,255", bg = "173,216,230,200"
        };
        {
            id = "purplepastel", category = "Cool Pastel Themes", label = "`#Purple Pastel", icon = 522;
            border = "221,160,221,255", bg = "221,160,221,200"
        },
        {
            id = "darkred"; category = "Dark Themes"; label = "`4Dark Red"; icon = 2014; border = "139,0,0,255";
            bg = "70,0,0,200"
        },
        {
            id = "darkgrey", category = "Dark Themes"; label = "`7Dark Grey"; icon = 2012, border = "100,100,100,255";
            bg = "45,45,45,200"
        };
        {
            id = "darkorange"; category = "Dark Themes", label = "`6Dark Orange"; icon = 2016; border = "180,90,0,255";
            bg = "80,40,0,200"
        };
        {
            id = "darkyellow", category = "Dark Themes"; label = "`9Dark Yellow", icon = 2018; border = "165,140,0,255";
            bg = "75,60,0,200"
        };
        {
            id = "darkgreen", category = "Dark Themes", label = "`2Dark Green", icon = 2020; border = "0,120,70,255";
            bg = "0,50,28,200"
        },
        {
            id = "darkaqua"; category = "Dark Themes"; label = "`cDark Aqua", icon = 2022; border = "0,120,120,255";
            bg = "0,50,50,200"
        };
        {
            id = "darkblue"; category = "Dark Themes"; label = "`3Dark Blue", icon = 2024; border = "35,75,150,255";
            bg = "12,30,80,200"
        };
        {
            id = "darkpurple"; category = "Dark Themes", label = "`#Dark Purple"; icon = 2026; border = "110,60,150,255",
            bg = "45,20,80,200"
        },
        {
            id = "darkbrown", category = "Dark Themes"; label = "`oDark Brown", icon = 2028, border = "110,75,45,255",
            bg = "55,35,18,200"
        };
        {
            id = "classicgrey", category = "Classic Block Themes"; label = "`7Grey", icon = 164; border = "160,160,160,255";
            bg = "120,120,120,200"
        };
        {
            id = "classicblack", category = "Classic Block Themes", label = "`0Black"; icon = 166, border = "70,70,70,255";
            bg = "20,20,20,200"
        },
        {
            id = "classicwhite"; category = "Classic Block Themes", label = "`wWhite", icon = 168; border = "255,255,255,255",
            bg = "230,230,230,210"
        };
        {
            id = "classicred", category = "Classic Block Themes", label = "`4Red", icon = 170; border = "220,70,70,255";
            bg = "170,35,35,200"
        };
        {
            id = "classicorange"; category = "Classic Block Themes"; label = "`6Orange"; icon = 172,
            border = "235,145,45,255", bg = "185,95,20,200"
        },
        {
            id = "classicyellow"; category = "Classic Block Themes", label = "`9Yellow"; icon = 174;
            border = "245,220,70,255"; bg = "195,170,25,200"
        };
        {
            id = "classicgreen", category = "Classic Block Themes"; label = "`2Green"; icon = 176; border = "90,200,90,255";
            bg = "45,145,45,200"
        },
        {
            id = "classicaqua", category = "Classic Block Themes", label = "`cAqua"; icon = 178, border = "75,210,210,255";
            bg = "30,150,150,200"
        };
        {
            id = "classicblue"; category = "Classic Block Themes"; label = "`3Blue", icon = 180, border = "85,140,230,255";
            bg = "40,85,180,200"
        };
        {
            id = "classicpurple"; category = "Classic Block Themes", label = "`#Purple"; icon = 182,
            border = "165,105,220,255", bg = "110,55,170,200"
        },
        {
            id = "classicbrown", category = "Classic Block Themes", label = "`oBrown", icon = 184; border = "165,115,70,255";
            bg = "110,70,35,200"
        }
    }
end

function W.ApplyTheme(P)
    if W.DialogBg and (W.DialogBorder and type(P) == "string") then
        if not P:find("set_bg_color") and not P:find("set_border_color") then
            local j = "set_default_color|`o\nset_border_color|" .. (W.DialogBorder .. ("|\nset_bg_color|" .. (W.DialogBg .. "|\n")))
            if P:find("set_default_color|`o") then
                P = P:gsub("set_default_color|`o\n?", j, 1)
            else
                P = j .. P
            end
        end
    end
    return P
end

function W.ChangeDialogColor()
    local P = "set_default_color|`o\ntext_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjjjj|\n\nadd_label_with_icon|big|`cWinProxy Themes|left|" .. (W.GetIcon("Painting Easel", 1000) .. ("|\nadd_spacer|small|\nadd_smalltext|`7Personalize your WinProxy experience. Changes apply globally!|left|\nadd_spacer|small|\n\nadd_button_with_icon|resetdefault|`cReset Theme|staticYellowFrame|" .. (W.GetIcon("Frost Dragon of Legend - 104", 17508) .. ("||\nadd_button_with_icon||END_LIST|noflags|0||\nadd_spacer|small|\n\nadd_label|medium|`cPastel Mode `0:|\nadd_button_with_icon|purplepastel|`#Pastel Purple|staticYellowFrame|" .. (W.GetIcon("Pastel Purple Block", 522) .. ("||\nadd_button_with_icon|bluepastel|`3Pastel Blue|staticYellowFrame|" .. (W.GetIcon("Pastel Blue Block", 520) .. ("||\nadd_button_with_icon|aquapastel|`cPastel Aqua|staticYellowFrame|" .. (W.GetIcon("Pastel Aqua Block", 518) .. ("||\nadd_button_with_icon|greenpastel|`2Pastel Green|staticYellowFrame|" .. (W.GetIcon("Pastel Green Block", 516) .. ("||\nadd_button_with_icon|yellowpastel|`9Pastel Yellow|staticYellowFrame|" .. (W.GetIcon("Pastel Yellow Block", 514) .. ("||\nadd_button_with_icon|orangepastel|`6Pastel Orange|staticYellowFrame|" .. (W.GetIcon("Pastel Orange Block", 512) .. ("||\nadd_button_with_icon|pinkpastel|`pPastel Pink|staticYellowFrame|" .. (W.GetIcon("Pastel Pink Block", 510) .. ("||\nadd_button_with_icon||END_LIST|noflags|0||\nadd_spacer|small|\n\nadd_label|medium|`cDark Mode `0:|\nadd_button_with_icon|darkpurple|`#Dark Purple|staticYellowFrame|" .. (W.GetIcon("Dark Purple Block", 2026) .. ("||\nadd_button_with_icon|darkblue|`3Dark Blue|staticYellowFrame|" .. (W.GetIcon("Dark Blue Block", 2024) .. ("||\nadd_button_with_icon|darkaqua|`cDark Aqua|staticYellowFrame|" .. (W.GetIcon("Dark Aqua Block", 2022) .. ("||\nadd_button_with_icon|darkgreen|`2Dark Green|staticYellowFrame|" .. (W.GetIcon("Dark Green Block", 2020) .. ("||\nadd_button_with_icon|darkyellow|`9Dark Yellow|staticYellowFrame|" .. (W.GetIcon("Dark Yellow Block", 2018) .. ("||\nadd_button_with_icon|darkorange|`6Dark Orange|staticYellowFrame|" .. (W.GetIcon("Dark Orange Block", 2016) .. ("||\nadd_button_with_icon|darkred|`4Dark Red|staticYellowFrame|" .. (W.GetIcon("Dark Red Block", 2014) .. ("||\nadd_button_with_icon|darkbrown|`oDark Brown|staticYellowFrame|" .. (W.GetIcon("Dark Brown Block", 2028) .. ("||\nadd_button_with_icon|darkgrey|`7Dark Grey|staticYellowFrame|" .. (W.GetIcon("Dark Grey Block", 2012) .. ("||\nadd_button_with_icon||END_LIST|noflags|0||\nadd_spacer|small|\n\nadd_label|medium|`cNormal Mode `0:|\nadd_button_with_icon|classicpurple|`#Purple|staticYellowFrame|" .. (W.GetIcon("Purple Block", 182) .. ("||\nadd_button_with_icon|classicblue|`3Blue|staticYellowFrame|" .. (W.GetIcon("Blue Block", 180) .. ("||\nadd_button_with_icon|classicaqua|`cAqua|staticYellowFrame|" .. (W.GetIcon("Aqua Block", 178) .. ("||\nadd_button_with_icon|classicgreen|`2Green|staticYellowFrame|" .. (W.GetIcon("Green Block", 176) .. ("||\nadd_button_with_icon|classicyellow|`9Yellow|staticYellowFrame|" .. (W.GetIcon("Yellow Block", 174) .. ("||\nadd_button_with_icon|classicorange|`6Orange|staticYellowFrame|" .. (W.GetIcon("Orange Block", 172) .. ("||\nadd_button_with_icon|classicred|`4Red|staticYellowFrame|" .. (W.GetIcon("Red Block", 170) .. ("||\nadd_button_with_icon|classicbrown|`oBrown|staticYellowFrame|" .. (W.GetIcon("Brown Block", 184) .. ("||\nadd_button_with_icon|classicblack|`0Black|staticYellowFrame|" .. (W.GetIcon("Black Block", 166) .. ("||\nadd_button_with_icon|classicgrey|`7Grey|staticYellowFrame|" .. (W.GetIcon("Grey Block", 164) .. ("||\nadd_button_with_icon|classicwhite|`wWhite|staticYellowFrame|" .. (W.GetIcon("White Block", 168) .. "||\nadd_button_with_icon||END_LIST|noflags|0||\nadd_spacer|small|\n\nadd_quick_exit||\nend_dialog|changedialogcolor|Close||\n")))))))))))))))))))))))))))))))))))))))))))))))))))))))))
    SendVariantList({ [0] = "OnDialogRequest"; [1] = W.ApplyTheme(P) })
end

function W.ShowMainDialog()
    local P = GetLocal()
    local j = (P and P.name) or "Unknown"
    local Y = os.date("!%a, %b/%d/%Y")
    local X = os.date("%I:%M %p")
    local M = "add_label_with_icon|big|`cWin-Community Script|left|" .. (W.GetIcon("Megaphone", 2480) .. ("|\nadd_image_button|banner_img|" .. (W.BannerDialogPath .. ("|banner_img|400|200|\nadd_textbox|`9GrowID `0: " .. (j .. ("|\nadd_textbox|`9Date `0: `2" .. (Y .. ("|\nadd_textbox|`9Time `0: `2" .. (X .. ("|\ntext_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjj|\n\nadd_button_with_icon|btn_commands|`cCommands|staticYellowFrame|" .. (W.GetIcon("Dumb Question 3", 6128) .. ("||\nadd_button_with_icon||END_LIST|noflags|0||\n\nadd_label|medium|`cAll Feature `0:|\nadd_button_with_icon|btn_general|`cGeneral|staticYellowFrame|" .. (W.GetIcon("Mini-Mod", 4758) .. ("||\nadd_button_with_icon|btn_wrench|`cWrench|staticYellowFrame|" .. (W.GetIcon("Wrench", 15418) .. ("||\nadd_button_with_icon|btn_donate|`cDonate|staticYellowFrame|" .. (W.GetIcon("Donation Box", 1452) .. ("||\nadd_button_with_icon|btn_trade|`cTrade|staticYellowFrame|" .. (W.GetIcon("Creativeps World Lock", 242) .. ("||\nadd_button_with_icon|btn_telephone|`cTelephone|staticYellowFrame|" .. (W.GetIcon("Telephone", 3898) .. ("||\nadd_button_with_icon|btn_toggle_emoji|`cText & Skin|staticYellowFrame|" .. (W.GetIcon("Happy Block", 5776) .. ("||\nadd_button_with_icon|btn_calc|`cCalculator|staticYellowFrame|" .. (W.GetIcon("Compu Panel", 1164) .. ("||\nadd_button_with_icon|btn_itemdb|`cItem Database|staticYellowFrame|" .. (W.GetIcon("Growscan 9000", 6016) .. ("||\nadd_button_with_icon|btn_ptht|`4Auto PTHT|staticYellowFrame|" .. (W.GetIcon("Dumb Farmer", 7064) .. ("||\nadd_button_with_icon|btn_pnb|`4Auto PNB|staticYellowFrame|" .. (W.GetIcon("Dumb Builder", 7070) .. ("||\nadd_button_with_icon|btn_auto_cook|`4Auto Cook|staticYellowFrame|" .. (W.GetIcon("Dumb Cook", 7076) .. ("||\nadd_button_with_icon|btn_auto_fish|`cAuto Fish|staticYellowFrame|" .. (W.GetIcon("Dumb Fisher", 7072) .. ("||\nadd_button_with_icon|btn_auto_surg|`cAuto Surg|staticYellowFrame|" .. (W.GetIcon("Dumb Surgeon", 7068) .. ("||\nadd_button_with_icon|btn_auto_crime|`cAuto Crime|staticYellowFrame|" .. (W.GetIcon("Crime Wave", 2382) .. ("||\nadd_button_with_icon|btn_auto_geiger|`4Auto Geiger|staticYellowFrame|" .. (W.GetIcon("Geiger Counter", 2204) .. ("||\nadd_button_with_icon|btn_auto_provider|`4Auto Provider|staticYellowFrame|" .. (W.GetIcon("Black Atm Machine", 17024) .. ("||\nadd_button_with_icon|btn_auto_combine|`4Auto Combine|staticYellowFrame|" .. (W.GetIcon("Laboratory", 3146) .. ("||\nadd_button_with_icon|btn_auto_buypack|`cAuto Buy Pack|staticYellowFrame|" .. (W.GetIcon("Dumb G4g Crate Pack", 10868) .. ("||\nadd_button_with_icon|btn_gambling|`cCasino|staticYellowFrame|" .. (W.GetIcon("Roulette Wheel", 758) .. ("||\nadd_button_with_icon|btn_btkbj|`cBTK & BJ|staticYellowFrame|" .. (W.GetIcon("Chandelier", 340) .. ("||\nadd_button_with_icon|btn_autopull_settings|`cAuto Pull|staticYellowFrame|" .. (W.GetIcon("Shocking Wrench Decoration", 14822) .. ("||\nadd_button_with_icon|btn_afk|`4AFK|staticYellowFrame|" .. (W.GetIcon("Dumb Worker", 1000) .. ("||\nadd_button_with_icon|btn_spam|`cAuto Spam|staticYellowFrame|" .. (W.GetIcon("Spammer Slave", 16990) .. ("||\nadd_button_with_icon|btn_sb|`cAuto SB & SDB|staticYellowFrame|" .. (W.GetIcon("Locke\'s Megaphone", 1000) .. ("||\nadd_button_with_icon|btn_mag|`cMagplant|staticYellowFrame|" .. (W.GetIcon("MAGPLANT 5000", 5638) .. ("||\nadd_button_with_icon|btn_vend|`cVending|staticYellowFrame|" .. (W.GetIcon("Digivend Machine", 2978) .. ("||\nadd_button_with_icon|btn_world|`4World|staticYellowFrame|" .. (W.GetIcon("Globe", 3802) .. ("||\nadd_button_with_icon|btn_title|`cTitle|staticYellowFrame|" .. (W.GetIcon("`7Party Animal Title", 14186) .. ("||\nadd_button_with_icon|btn_logs|`cAll Logs|staticYellowFrame|" .. (W.GetIcon("Security Camera", 1436) .. ("||\nadd_button_with_icon|btn_theme|`cTheme & UI|staticYellowFrame|" .. (W.GetIcon("Painting Easel", 1000) .. ("||\nadd_button_with_icon|btn_setting|`cSetting|staticYellowFrame|" .. (W.GetIcon("Steampunk Sprocket", 3310) .. ("||\nadd_button_with_icon|btn_info|`cInformation|staticYellowFrame|" .. (W.GetIcon("Digital Sign", 11186) .. "||\nadd_button_with_icon||END_LIST|noflags|0||\n\ntext_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjj|\nadd_quick_exit|\nend_dialog|cmdend|Close|\n")))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
    W.CreateDialog(M)
end

function W.ShowCommandsDialog()
    local P = "add_label_with_icon|big|`9Command Center|left|" .. (W.GetIcon("Dumb Question 3", 6128) .. ("|\nadd_spacer|small|\nadd_label_with_icon|small|`9Command Alias|left|" .. (W.GetIcon("Data Disk", 3224) .. ("|\nadd_smalltext|`b/aliasmenu `w: Open the Command Alias Menu directly.|\nadd_button_with_icon|btn_custom_cmd|`cCommand Alias|staticYellowFrame|" .. (W.GetIcon("Data Disk", 3224) .. ("||\nadd_button_with_icon||END_LIST|noflags|0|\nadd_label_with_icon|small|`9Casino Modes|left|" .. (W.GetIcon("Roulette Wheel", 758) .. ("|\nadd_smalltext|`b/casinomenu `w: Open Casino Menu directly.|\nadd_smalltext|`b/allmode `w: Toggle All (Reme, Leme, Qeme) mode.|\nadd_smalltext|`b/reme `w: Toggle Reme calculator mode.|\nadd_smalltext|`b/qeme `w: Toggle Qeme calculator mode.|\nadd_smalltext|`b/leme `w: Toggle Leme calculator mode.|\nadd_smalltext|`b/lemes `w: Toggle Leme S calculator mode.|\nadd_smalltext|`b/ceme `w: Toggle Ceme calculator mode.|\nadd_smalltext|`b/lewa <num> `w: Set Lewa multiplier & Enable.|\nadd_spacer|small|\nadd_label_with_icon|small|`9Auto Pull & Min Modal|left|" .. (W.GetIcon("Shocking Wrench Decoration", 14822) .. ("|\nadd_smalltext|`b/autopullmenu `w: Open Auto Pull Menu directly.|\nadd_smalltext|`b/autopull `w: Toggle Auto Pull Master.|\nadd_smalltext|`b/posautopull `w: Set Auto Pull target to your tile.|\nadd_smalltext|`b/clearposautopull `w: Reset target back to White Door.|\nadd_smalltext|`b/apblacklist add <uid> `w: Add UID to blacklist.|\nadd_smalltext|`b/apblacklist remove <uid> `w: Remove UID from blacklist.|\nadd_smalltext|`b/apblacklist list `w: Show current blacklist in chat.|\nadd_spacer|small|\nadd_label_with_icon|small|`9Wrench Controls|left|" .. (W.GetIcon("Wrench", 15418) .. ("|\nadd_smalltext|`b/wrenchmenu `w: Open Wrench Menu directly.|\nadd_smalltext|`b/wrp, /wrps `w: Auto Pull (Left Click / Right Click).|\nadd_smalltext|`b/wrk, /wrks `w: Auto Kick (Left Click / Right Click).|\nadd_smalltext|`b/wrb, /wrbs `w: Auto World Ban (Left Click / Right Click).|\nadd_smalltext|`b/wrt, /wrts `w: Auto Trade (Left Click / Right Click).|\nadd_smalltext|`b/showbal `w: Toggle fast balance on inspect.|\nadd_spacer|small|\nadd_label_with_icon|small|`9Smart Donation|left|" .. (W.GetIcon("Donation Box", 1452) .. ("|\nadd_smalltext|`b/donatemenu `w: Open Donate Menu directly.|\nadd_smalltext|`b/dmode `w: Toggle Smart Donation Mode.|\nadd_smalltext|`b/pw <qty> `w: Remote Donate World Lock.|\nadd_smalltext|`b/pd <qty> `w: Remote Donate Diamond Lock.|\nadd_smalltext|`b/pb <qty> `w: Remote Donate Blue Gem Lock.|\nadd_smalltext|`b/pbl <qty> `w: Remote Donate Black GL.|\nadd_smalltext|`b/pall `w: Remote Donate All Locks in inventory.|\nadd_smalltext|`b/takeall `w: Retrieve all items from Box.|\nadd_spacer|small|\nadd_label_with_icon|small|`9Advanced Trading|left|" .. (W.GetIcon("Creativeps World Lock", 242) .. ("|\nadd_smalltext|`b/trademenu `w: Open Trade Menu directly.|\nadd_smalltext|`b/tmode `w: Toggle Trade Wrench Mode.|\nadd_smalltext|`b/tw <qty> `w: Fast add World Lock to trade.|\nadd_smalltext|`b/td <qty> `w: Fast add Diamond Lock to trade.|\nadd_smalltext|`b/tb <qty> `w: Fast add Blue Gem Lock to trade.|\nadd_smalltext|`b/tbl <qty> `w: Fast add Black GL to trade.|\nadd_smalltext|`b/tall `w: Fast add All Locks to trade.|\nadd_smalltext|`b/tclear `w: Clear all locks from Trade window.|\nadd_spacer|small|\nadd_label_with_icon|small|`9Telephone Commands|left|" .. (W.GetIcon("Telephone", 3898) .. ("|\nadd_smalltext|`b/telemenu `w: Open Telephone Menu directly.|\nadd_smalltext|`b/cvdl `w: Auto Convert DL to BGL.|\nadd_smalltext|`b/buybgl `w: Auto Buy Blue Gem Lock.|\nadd_smalltext|`b/buydl `w: Auto Buy Diamond Lock.|\nadd_smalltext|`b/buychamp `w: Auto Buy Champagne (Normal).|\nadd_smalltext|`b/buychampbg `w: Auto Buy Champagne (Black Gems).|\nadd_smalltext|`b/buychampbulk `w: Auto Buy Bulk Champagne.|\nadd_spacer|small|\nadd_label_with_icon|small|`9Smart Calculator|left|" .. (W.GetIcon("Compu Panel", 1164) .. ("|\nadd_smalltext|`b/calcmenu `w: Open Calculator Menu directly.|\nadd_smalltext|`b/calc <form> `w: Calculate math instantly.|\nadd_spacer|small|\nadd_label_with_icon|small|`9Auto-Spam Settings|left|" .. (W.GetIcon("Spammer Slave", 16990) .. ("|\nadd_smalltext|`b/spammenu `w: Open the Spam UI Menu directly.|\nadd_smalltext|`b/spam `w: Toggle Auto-Spam on/off.|\nadd_smalltext|`b/addspam <txt> `w: Add a new spam message.|\nadd_smalltext|`b/removespam `w: Remove the last spam message.|\nadd_smalltext|`b/spamtext <num> <txt> `w: Edit specific spam line.|\nadd_spacer|small|\nadd_label_with_icon|small|`9Super Broadcast|left|" .. (W.GetIcon("Megaphone", 2480) .. ("|\nadd_smalltext|`b/sbmenu `w: Open SB & SDB Menu directly.|\nadd_smalltext|`b/sbstart `w: Start Super Broadcast (or /sbstart reset).|\nadd_smalltext|`b/sbstop `w: Stop Super Broadcast.|\nadd_smalltext|`b/sbreset `w: Reset SB count to 0.|\nadd_smalltext|`b/sdbstart `w: Start Super Duper Broadcast (or /sdbstart reset).|\nadd_smalltext|`b/sdbstop `w: Stop Super Duper Broadcast.|\nadd_smalltext|`b/sdbreset `w: Reset SDB count to 0.|\nadd_spacer|small|\nadd_label_with_icon|small|`9Text & Skin Customization|left|" .. (W.GetIcon("Happy Block", 5776) .. ("|\nadd_smalltext|`b/emojimenu `w: Open Emoji Menu directly.|\nadd_smalltext|`b/emoji `w: Toggle Random Chat Emojis.|\nadd_smalltext|`b/watermark `w: Toggle Chat Watermark.|\nadd_spacer|small|\nadd_label_with_icon|small|`9Logs & History|left|" .. (W.GetIcon("Security Camera", 1436) .. ("|\nadd_smalltext|`b/logsmenu `w: Open main Logs Menu Dialog.|\nadd_smalltext|`b/logs `w: Toggle activity logging on/off.|\nadd_smalltext|`b/clogs `w: Open Collect Logs directly.|\nadd_smalltext|`b/dlogs `w: Open Drop Logs directly.|\nadd_smalltext|`b/invlogs `w: Open Inventory Logs directly.|\nadd_smalltext|`b/slogs `w: Open Casino/Spin Logs directly.|\nadd_spacer|small|\nadd_label_with_icon|small|`9Economy & Drop|left|" .. (W.GetIcon("Creativeps Blue Gem Lock", 7188) .. ("|\nadd_smalltext|`b/dw <qty> `w: Auto drop World Lock.|\nadd_smalltext|`b/dd <qty> `w: Auto drop Diamond Lock.|\nadd_smalltext|`b/db <qty> `w: Auto drop Blue Gem Lock.|\nadd_smalltext|`b/dbl <qty> `w: Auto drop Black Gem Lock.|\nadd_smalltext|`b/daw `w: Drop all locks in backpack.|\nadd_smalltext|`b/depo <qty> `w: Deposit BGL to bank.|\nadd_smalltext|`b/with <qty> `w: Withdraw BGL from bank.|\nadd_smalltext|`b/blue `w: Convert Black GL to Blue GL.|\nadd_smalltext|`b/black `w: Convert Blue GL to Black GL.|\nadd_spacer|small|\nadd_label_with_icon|small|`9General Proxy Features|left|" .. (W.GetIcon("Mini-Mod", 4758) .. ("|\nadd_smalltext|`b/antilag `w: Toggle Anti-Lag (Particle/Shadow).|\nadd_smalltext|`b/hidespammer `w: Toggle Hide Spammer Slave.|\nadd_smalltext|`b/antipickup `w: Toggle Anti-Pickup items.|\nadd_smalltext|`b/modfly `w: Toggle Modfly.|\nadd_smalltext|`b/antiportal `w: Toggle Anti Portal.|\nadd_smalltext|`b/nightvision `w: Toggle Night Vision.|\nadd_smalltext|`b/blocksdb `w: Toggle Block SDB Dialogs.|\nadd_smalltext|`b/autocv `w: Toggle Auto CV All Locks on collect.|\nadd_smalltext|`b/tp `w: Toggle Teleport Punch (Display/Vend).|\nadd_smalltext|`b/modal `w: Show your own total balance.|\nadd_smalltext|`b/fastdrop `w: Toggle fast drop without confirmation.|\nadd_smalltext|`b/fasttrash `w: Toggle fast trash without confirmation.|\nadd_smalltext|`b/vendfilter `w: Formats huge World Lock prices.|\nadd_smalltext|`b/donfilter `w: Shows actual item icons in Dono Box.|\nadd_smalltext|`b/sboxfilter `w: Enable Storage Box Xtreme Take-All mode.|\nadd_smalltext|`b/skin <color> `w: Change skin color (presets/rainbow/blink/hex).|\nadd_spacer|small|\nadd_label_with_icon|small|`9BTK & BJ Commands|left|" .. (W.GetIcon("Chandelier", 340) .. ("|\nadd_smalltext|`b/btkmenu, /bjmenu `w: Open Host Dialog Panel.|\nadd_smalltext|`b/btkcmd, /bjcmd `w: Open BTK/BJ Command List.|\nadd_smalltext|`b/btk, /bj `w: Switch Game Mode (BTK / BJ).|\nadd_smalltext|`b/btkremote, /bjremote `w: Collect Remote from Magplant.|\nadd_smalltext|`b/btkbet, /bjbet `w: Take Bets & Calculate Tax.|\nadd_smalltext|`b/btkgems, /bjgems `w: Check Gems & Announce Winner.|\nadd_smalltext|`b/btkdrop, /bjdrop `w: Drop Prize, Tax & Reset.|\nadd_smalltext|`b/btkcenter, /bjcenter `w: Touch/Punch to set Host Center tile.|\nadd_smalltext|`b/btkposbet1, /bjposbet1 `w: Touch/Punch to set Bet Player 1 tile.|\nadd_smalltext|`b/btkposbet2, /bjposbet2 `w: Touch/Punch to set Bet Player 2 tile.|\nadd_smalltext|`b/btkposbreak1, /bjposbreak1 `w: Touch/Punch to set Break P1 tile.|\nadd_smalltext|`b/btkposbreak2, /bjposbreak2 `w: Touch/Punch to set Break P2 tile.|\nadd_smalltext|`b/btktax, /bjtax `w: Touch/Punch to set Tax Drop tile.|\nadd_smalltext|`b/btkmag, /bjmag `w: Touch/Punch to set Magplant tile.|\nadd_spacer|small|\nadd_label_with_icon|small|`9System & Tools|left|" .. (W.GetIcon("Dummy Puzzle Icon", 11986) .. "|\nadd_smalltext|`b/menu, /help `w: Open Main Menu Dialog in-game.|\nadd_smalltext|`b/cmd `w: Open this Commands Dialog directly.|\nadd_smalltext|`b/settingmenu `w: Open Setting Menu directly.|\nadd_smalltext|`b/imgui, /proxy `w: Open/Close ImGui Panel.|\nadd_smalltext|`b/g, /ghost `w: Shortcut for /ghost.|\nadd_smalltext|`b/res `w: Shortcut for Respawn.|\nadd_smalltext|`b/re `w: Shortcut for Rejoin World.|\nadd_smalltext|`b/relog `w: Shortcut to Reconnect server.|\nadd_spacer|small|\ntext_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjj|\nadd_button|menuu|Back|noflags|0|0|\nend_dialog|close_ui|Close||\n")))))))))))))))))))))))))))))))))))
    W.CreateDialog(P)
end

function W.ShowGeneralCommandsDialog()
    local P = "set_default_color|`o\nadd_label_with_icon|big|`9General Commands List|left|" .. (W.GetIcon("Mini-Mod", 4758) .. "|\nadd_spacer|small|\nadd_textbox|`wFast in-game commands for General Proxy Features:|left|\nadd_spacer|small|\nadd_smalltext|`b/antilag `w: Toggle Anti-Lag (Particle/Shadow).|left|\nadd_smalltext|`b/hidespammer `w: Toggle Hide Spammer Slave.|left|\nadd_smalltext|`b/antipickup `w: Toggle Anti-Pickup items.|\nadd_smalltext|`b/modfly `w: Toggle Modfly.|\nadd_smalltext|`b/antiportal `w: Toggle Anti Portal.|\nadd_smalltext|`b/nightvision `w: Toggle Night Vision.|left|\nadd_smalltext|`b/blocksdb `w: Toggle Block SDB Dialogs.|left|\nadd_smalltext|`b/autocv `w: Toggle Auto CV All Locks on collect.|left|\nadd_smalltext|`b/tp `w: Toggle Teleport Punch (Display/Vend).|left|\nadd_smalltext|`b/modal `w: Calculate & show your own total balance.|left|\nadd_smalltext|`b/fastdrop `w: Toggle fast drop without confirmation.|left|\nadd_smalltext|`b/fasttrash `w: Toggle fast trash without confirmation.|left|\nadd_smalltext|`b/vendfilter `w: Formats huge World Lock prices.|left|\nadd_smalltext|`b/donfilter `w: Shows actual item icons in Dono Box.|left|\nadd_smalltext|`b/sboxfilter `w: Enable Storage Box Xtreme Take-All mode.|left|\nadd_smalltext|`b/skin <color> `w: Change skin color (presets/rainbow/blink/hex).|left|\nadd_spacer|small|\ntext_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjj|\nadd_button|btn_general|Back|noflags|0|0|\nend_dialog|close_ui|Close||\n")
    W.CreateDialog(P)
end

function W.ShowWrenchCommandsDialog()
    local P = "set_default_color|`o\nadd_label_with_icon|big|`9Wrench Commands List|left|" .. (W.GetIcon("Wrench", 15418) .. "|\nadd_spacer|small|\nadd_textbox|`wFast in-game commands for Wrench Controls:|left|\nadd_spacer|small|\nadd_smalltext|`b/wrenchmenu `w: Open Wrench Menu directly.|left|\nadd_smalltext|`b/wrp, /wrps `w: Auto Pull (Left Click / Right Click).|left|\nadd_smalltext|`b/wrk, /wrks `w: Auto Kick (Left Click / Right Click).|left|\nadd_smalltext|`b/wrb, /wrbs `w: Auto World Ban (Left Click / Right Click).|left|\nadd_smalltext|`b/wrt, /wrts `w: Auto Trade (Left Click / Right Click).|left|\nadd_smalltext|`b/showbal `w: Toggle fast balance on inspect.|left|\nadd_smalltext|`b/spampull `w: Toggle auto 3s spam pull on each pull.|left|\nadd_smalltext|`b/spampull now `w: Immediately spam pull last target for 3s.|left|\nadd_smalltext|`b/repull `w(or `b/rp`w): Pull last target 1x (or press Hotkey).|left|\nadd_smalltext|`b/setrepullkey <key> `w: Change RePull hotkey (default: DELETE).|left|\nadd_spacer|small|\ntext_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjj|\nadd_button|btn_wrench|Back|noflags|0|0|\nend_dialog|close_ui|Close||\n")
    W.CreateDialog(P)
end

function W.ShowDonateCommandsDialog()
    local P = "set_default_color|`o\nadd_label_with_icon|big|`9Donate Commands List|left|" .. (W.GetIcon("Donation Box", 1452) .. "|\nadd_spacer|small|\nadd_textbox|`wFast in-game commands for Smart Donation:|left|\nadd_spacer|small|\nadd_smalltext|`b/donatemenu `w: Open Donate Menu directly.|left|\nadd_smalltext|`b/dmode `w: Toggle Smart Donation Mode.|left|\nadd_smalltext|`b/pw <qty> `w: Remote Donate World Lock.|left|\nadd_smalltext|`b/pd <qty> `w: Remote Donate Diamond Lock.|left|\nadd_smalltext|`b/pb <qty> `w: Remote Donate Blue Gem Lock.|left|\nadd_smalltext|`b/pbl <qty> `w: Remote Donate Black GL.|left|\nadd_smalltext|`b/pall `w: Remote Donate All Locks in inventory.|left|\nadd_smalltext|`b/takeall `w: Retrieve all items from Box.|left|\nadd_spacer|small|\ntext_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjj|\nadd_button|btn_donate|Back|noflags|0|0|\nend_dialog|close_ui|Close||\n")
    W.CreateDialog(P)
end

function W.ShowTradeCommandsDialog()
    local P = "set_default_color|`o\nadd_label_with_icon|big|`9Trade Commands List|left|" .. (W.GetIcon("Creativeps World Lock", 242) .. "|\nadd_spacer|small|\nadd_textbox|`wFast in-game commands for Advanced Trading:|left|\nadd_spacer|small|\nadd_smalltext|`b/trademenu `w: Open Trade Menu directly.|left|\nadd_smalltext|`b/tmode `w: Toggle Trade Wrench Mode.|left|\nadd_smalltext|`b/tw <qty> `w: Fast add World Lock to trade.|left|\nadd_smalltext|`b/td <qty> `w: Fast add Diamond Lock to trade.|left|\nadd_smalltext|`b/tb <qty> `w: Fast add Blue Gem Lock to trade.|left|\nadd_smalltext|`b/tbl <qty> `w: Fast add Black GL to trade.|left|\nadd_smalltext|`b/tall `w: Fast add All Locks to trade.|left|\nadd_smalltext|`b/tclear `w: Clear all locks from Trade window.|left|\nadd_spacer|small|\ntext_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjj|\nadd_button|btn_trade|Back|noflags|0|0|\nend_dialog|close_ui|Close||\n")
    W.CreateDialog(P)
end

function W.ShowTelephoneCommandsDialog()
    local P = "set_default_color|`o\nadd_label_with_icon|big|`9Telephone Commands List|left|" .. (W.GetIcon("Telephone", 3898) .. "|\nadd_spacer|small|\nadd_textbox|`wFast in-game commands for Telephone Auto-Buy:|left|\nadd_spacer|small|\nadd_smalltext|`b/telemenu `w: Open Telephone Menu directly.|left|\nadd_smalltext|`b/cvdl `w: Auto Convert DL to BGL.|left|\nadd_smalltext|`b/buybgl `w: Auto Buy Blue Gem Lock.|left|\nadd_smalltext|`b/buydl `w: Auto Buy Diamond Lock.|left|\nadd_smalltext|`b/buychamp `w: Auto Buy Champagne (Normal).|left|\nadd_smalltext|`b/buychampbg `w: Auto Buy Champagne (Black Gems).|left|\nadd_smalltext|`b/buychampbulk `w: Auto Buy Bulk Champagne.|left|\nadd_spacer|small|\ntext_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjj|\nadd_button|btn_telephone|Back|noflags|0|0|\nend_dialog|close_ui|Close||\n")
    W.CreateDialog(P)
end

function W.ShowEmojiCommandsDialog()
    local P = "set_default_color|`o\nadd_label_with_icon|big|`9Text & Skin Commands List|left|" .. (W.GetIcon("Happy Block", 5776) .. "|\nadd_spacer|small|\nadd_textbox|`wFast in-game commands for Customization:|left|\nadd_spacer|small|\nadd_smalltext|`b/emojimenu `w: Open Emoji Menu directly.|left|\nadd_smalltext|`b/emoji `w: Toggle Random Chat Emojis.|left|\nadd_smalltext|`b/watermark `w: Toggle Chat Watermark.|left|\nadd_spacer|small|\ntext_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjj|\nadd_button|btn_toggle_emoji|Back|noflags|0|0|\nend_dialog|close_ui|Close||\n")
    W.CreateDialog(P)
end

function W.ShowCalculatorCommandsDialog()
    local P = "set_default_color|`o\nadd_label_with_icon|big|`9Calculator Commands List|left|" .. (W.GetIcon("Compu Panel", 1164) .. "|\nadd_spacer|small|\nadd_textbox|`wFast in-game commands for Smart Calculator:|left|\nadd_spacer|small|\nadd_smalltext|`b/calcmenu `w: Open Calculator Menu directly.|left|\nadd_smalltext|`b/calc <form> `w: Calculate math instantly.|left|\nadd_spacer|small|\ntext_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjj|\nadd_button|btn_calc|Back|noflags|0|0|\nend_dialog|close_ui|Close||\n")
    W.CreateDialog(P)
end

function W.ShowSpamCommandsDialog()
    local P = "set_default_color|`o\nadd_label_with_icon|big|`9Auto-Spam Commands List|left|" .. (W.GetIcon("Spammer Slave", 16990) .. "|\nadd_spacer|small|\nadd_textbox|`wFast in-game commands for Auto-Spam:|left|\nadd_spacer|small|\nadd_smalltext|`b/spammenu `w: Open the Spam UI Menu directly.|left|\nadd_smalltext|`b/spam `w: Toggle Auto-Spam on/off.|left|\nadd_smalltext|`b/addspam <txt> `w: Add a new spam message.|left|\nadd_smalltext|`b/removespam `w: Remove the last spam message.|left|\nadd_smalltext|`b/spamtext <num> <txt> `w: Edit specific spam line.|left|\nadd_spacer|small|\ntext_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjj|\nadd_button|btn_spam|Back|noflags|0|0|\nend_dialog|close_ui|Close||\n")
    W.CreateDialog(P)
end

function W.ShowSBCommandsDialog()
    local P = "set_default_color|`o\nadd_label_with_icon|big|`9SB & SDB Commands List|left|" .. (W.GetIcon("Megaphone", 2480) .. "|\nadd_spacer|small|\nadd_textbox|`wFast in-game commands for Super Broadcast:|left|\nadd_spacer|small|\nadd_smalltext|`b/sbmenu `w: Open SB & SDB Menu directly.|left|\nadd_smalltext|`b/sbstart `w: Start Super Broadcast (or /sbstart reset).|left|\nadd_smalltext|`b/sbstop `w: Stop Super Broadcast.|left|\nadd_smalltext|`b/sbreset `w: Reset SB count and stats to 0.|left|\nadd_smalltext|`b/sdbstart `w: Start Super Duper Broadcast (or /sdbstart reset).|left|\nadd_smalltext|`b/sdbstop `w: Stop Super Duper Broadcast.|left|\nadd_smalltext|`b/sdbreset `w: Reset SDB count to 0.|left|\nadd_spacer|small|\ntext_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjj|\nadd_button|btn_sbsbd|Back|noflags|0|0|\nend_dialog|close_ui|Close||\n")
    W.CreateDialog(P)
end

function W.ShowCasinoCommandsDialog()
    local P = "set_default_color|`o\nadd_label_with_icon|big|`9Casino Commands List|left|" .. (W.GetIcon("Roulette Wheel", 758) .. "|\nadd_spacer|small|\nadd_textbox|`wFast in-game commands for Casino Modes:|left|\nadd_spacer|small|\nadd_smalltext|`b/casinomenu `w: Open Casino Menu directly.|left|\nadd_smalltext|`b/allmode `w: Toggle All (Reme, Leme, Qeme) mode.|left|\nadd_smalltext|`b/reme `w: Toggle Reme calculator mode.|left|\nadd_smalltext|`b/qeme `w: Toggle Qeme calculator mode.|left|\nadd_smalltext|`b/leme `w: Toggle Leme calculator mode.|left|\nadd_smalltext|`b/lemes `w: Toggle Leme S calculator mode.|left|\nadd_smalltext|`b/ceme `w: Toggle Ceme calculator mode.|left|\nadd_smalltext|`b/lewa <num> `w: Set Lewa multiplier & Enable.|left|\nadd_smalltext|`b/autochamp `4or `b/autocmp `w: Auto use Champagne before spinning wheel.|left|\nadd_smalltext|`b/cmp `w: Quick use 1 Champagne from inventory.|left|\nadd_spacer|small|\ntext_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjj|\nadd_button|btn_gambling|Back|noflags|0|0|\nend_dialog|close_ui|Close||\n")
    W.CreateDialog(P)
end

function W.ShowAutoPullCommandsDialog()
    local P = "set_default_color|`o\nadd_label_with_icon|big|`9Auto Pull Commands List|left|" .. (W.GetIcon("Shocking Wrench Decoration", 14822) .. "|\nadd_spacer|small|\nadd_textbox|`wFast in-game commands for Auto Pull:|left|\nadd_spacer|small|\nadd_smalltext|`b/autopullmenu `w: Open Auto Pull Menu directly.|left|\nadd_smalltext|`b/autopull `w: Toggle Auto Pull Master.|left|\nadd_smalltext|`b/posautopull `w: Set Auto Pull target to your tile.|left|\nadd_smalltext|`b/clearposautopull `w: Reset target back to White Door.|left|\nadd_smalltext|`b/apblacklist add <uid> `w: Add UID to blacklist.|left|\nadd_smalltext|`b/apblacklist remove <uid> `w: Remove UID from blacklist.|left|\nadd_smalltext|`b/apblacklist list `w: Show current blacklist in chat.|left|\nadd_spacer|small|\ntext_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjj|\nadd_button|btn_autopull_settings|Back|noflags|0|0|\nend_dialog|close_ui|Close||\n")
    W.CreateDialog(P)
end

function W.ShowLogsCommandsDialog()
    local P = "set_default_color|`o\nadd_label_with_icon|big|`9Logs Commands List|left|" .. (W.GetIcon("Security Camera", 1436) .. "|\nadd_spacer|small|\nadd_textbox|`wFast in-game commands for Logs & History:|left|\nadd_spacer|small|\nadd_smalltext|`b/logsmenu `w: Open main Logs Menu Dialog.|left|\nadd_smalltext|`b/logs `w: Toggle activity logging on/off.|left|\nadd_smalltext|`b/clogs `w: Open Collect Logs directly.|left|\nadd_smalltext|`b/dlogs `w: Open Drop Logs directly.|left|\nadd_smalltext|`b/invlogs `w: Open Inventory Logs directly.|left|\nadd_smalltext|`b/slogs `w: Open Casino/Spin Logs directly.|left|\nadd_spacer|small|\ntext_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjj|\nadd_button|btn_logs|Back|noflags|0|0|\nend_dialog|close_ui|Close||\n")
    W.CreateDialog(P)
end

function W.ShowGeneralDialog()
    local P = W.AntiPickup and "`2ON" or "`4OFF"
    local j = W.Modfly and "`2ON" or "`4OFF"
    local Y = W.AntiPortal and "`2ON" or "`4OFF"
    local X = W.NightVision and "`2ON" or "`4OFF"
    local M = W.BlockSDB and "`2ON" or "`4OFF"
    local z = W.AutoCVLocks and "`2ON" or "`4OFF"
    local o = W.TPDisplay and "`2ON" or "`4OFF"
    local q = W.FastDrop and "`2ON" or "`4OFF"
    local S = W.FastTrash and "`2ON" or "`4OFF"
    local O = W.VendFilter and "`2ON" or "`4OFF"
    local V = W.DonationFilter and "`2ON" or "`4OFF"
    local e = W.StorageFilter and "`2ON" or "`4OFF"
    local v = W.AntiLag and "`2ON" or "`4OFF"
    local f = W.HideSpammer and "`2ON" or "`4OFF"
    local n = W.FastDropOnClick and "`2ON" or "`4OFF"
    local C = W.FastTrashOnClick and "`2ON" or "`4OFF"
    local D = "add_label_with_icon|big|`9General Proxy Features|left|" .. (W.GetIcon("Mini-Mod", 4758) .. ("|\nadd_spacer|small|\nadd_small_font_button|btn_cmd_general|`9List Command|noflags|0|0|\nadd_small_font_button|gen_toggle_antilag|Anti-Lag (Particle/Shadow): " .. (v .. ("|noflags|0|0|\nadd_small_font_button|gen_toggle_hidespam|Hide Spammer Slave: " .. (f .. ("|noflags|0|0|\nadd_small_font_button|gen_toggle_ap|Anti-Pickup: " .. (P .. ("|noflags|0|0|\nadd_small_font_button|gen_toggle_mf|Modfly: " .. (j .. ("|noflags|0|0|\nadd_small_font_button|gen_toggle_p|Anti Portal: " .. (Y .. ("|noflags|0|0|\nadd_small_font_button|gen_toggle_nv|Night Vision: " .. (X .. ("|noflags|0|0|\nadd_small_font_button|gen_toggle_bsdb|Block SDB Dialogs: " .. (M .. ("|noflags|0|0|\nadd_small_font_button|gen_toggle_autocv|Auto CV Locks: " .. (z .. ("|noflags|0|0|\nadd_small_font_button|gen_toggle_tp|Teleport Punch: " .. (o .. ("|noflags|0|0|\nadd_small_font_button|gen_toggle_fd|Fast Drop: " .. (q .. "|noflags|0|0|\n")))))))))))))))))))))
    if W.FastDrop or W.FastTrash then
        if W.FastDrop then
            D = D .. ("add_small_font_button|gen_toggle_fdoc| `2> `0Fast Drop OnClick: " .. (n .. "|noflags|0|0|\n"))
        end
    end
    D = D .. ("add_small_font_button|gen_toggle_ft|Fast Trash: " .. (S .. "|noflags|0|0|\n"))
    if W.FastDrop or W.FastTrash then
        if W.FastTrash then
            D = D .. ("add_small_font_button|gen_toggle_ftoc| `2> `0Fast Trash OnClick: " .. (C .. "|noflags|0|0|\n"))
        end
    end
    D = D .. ("add_small_font_button|gen_toggle_vf|Vend Filter: " .. (O .. ("|noflags|0|0|\nadd_small_font_button|gen_toggle_df|Donation Box Filter: " .. (V .. ("|noflags|0|0|\nadd_small_font_button|gen_toggle_sf|Storage Box Filter: " .. (e .. "|noflags|0|0|\nadd_spacer|small|\ntext_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjj|\nadd_button|menuu|Back|noflags|0|0|\nend_dialog|close_ui|Close||\n"))))))
    W.CreateDialog(D)
end

function W.ShowWrenchDialog()
    local P = (W.WrenchMode == 0) and "Off `2[ON]" or "Off `4[OFF]"
    local j = (W.WrenchMode == 1) and "Pull `2[ON]" or "Pull `4[OFF]"
    local Y = (W.WrenchMode == 2) and "Kick `2[ON]" or "Kick `4[OFF]"
    local X = (W.WrenchMode == 3) and "Ban `2[ON]" or "Ban `4[OFF]"
    local M = (W.WrenchMode == 4) and "Trade `2[ON]" or "Trade `4[OFF]"
    local z = (W.WrenchMode == 0) and "staticYellowFrame" or "staticGreyFrame"
    local o = (W.WrenchMode == 1) and "staticYellowFrame" or "staticGreyFrame"
    local q = (W.WrenchMode == 2) and "staticYellowFrame" or "staticGreyFrame"
    local S = (W.WrenchMode == 3) and "staticYellowFrame" or "staticGreyFrame"
    local O = (W.WrenchMode == 4) and "staticYellowFrame" or "staticGreyFrame"
    local V = (W.WrenchModeRight == 0) and "Off `2[ON]" or "Off `4[OFF]"
    local e = (W.WrenchModeRight == 1) and "Pull `2[ON]" or "Pull `4[OFF]"
    local v = (W.WrenchModeRight == 2) and "Kick `2[ON]" or "Kick `4[OFF]"
    local f = (W.WrenchModeRight == 3) and "Ban `2[ON]" or "Ban `4[OFF]"
    local n = (W.WrenchModeRight == 4) and "Trade `2[ON]" or "Trade `4[OFF]"
    local C = (W.WrenchModeRight == 0) and "staticYellowFrame" or "staticGreyFrame"
    local D = (W.WrenchModeRight == 1) and "staticYellowFrame" or "staticGreyFrame"
    local i = (W.WrenchModeRight == 2) and "staticYellowFrame" or "staticGreyFrame"
    local K = (W.WrenchModeRight == 3) and "staticYellowFrame" or "staticGreyFrame"
    local y = (W.WrenchModeRight == 4) and "staticYellowFrame" or "staticGreyFrame"
    local k = W.ShowBal and "Show Balance `2[ON]" or "Show Balance `4[OFF]"
    local A = W.ShowBal and "staticYellowFrame" or "staticGreyFrame"
    local p = "add_label_with_icon|big|`9Wrench Mode Settings|left|" .. (W.GetIcon("Wrench", 15418) .. ("|\nadd_spacer|small|\nadd_small_font_button|btn_cmd_wrench|`9List Command|noflags|0|0|\nadd_button_with_icon|wrench_showbal|" .. (k .. ("|" .. (A .. ("|" .. (W.GetIcon("Creativeps World Lock", 242) .. ("|\nadd_button_with_icon||END_LIST|noflags|0||\ntext_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjj|\n\nadd_smalltext|`wLeft Click Action (Main):|\nadd_button_with_icon|wrench_l_off|" .. (P .. ("|" .. (z .. ("|" .. (W.GetIcon("Constellation Wrench Style", 15678) .. ("|\nadd_button_with_icon|wrench_l_pull|" .. (j .. ("|" .. (o .. ("|" .. (W.GetIcon("Constellation Wrench Style", 15678) .. ("|\nadd_button_with_icon|wrench_l_kick|" .. (Y .. ("|" .. (q .. ("|" .. (W.GetIcon("Constellation Wrench Style", 15678) .. ("|\nadd_button_with_icon|wrench_l_ban|" .. (X .. ("|" .. (S .. ("|" .. (W.GetIcon("Constellation Wrench Style", 15678) .. ("|\nadd_button_with_icon|wrench_l_trade|" .. (M .. ("|" .. (O .. ("|" .. (W.GetIcon("Constellation Wrench Style", 15678) .. ("|\nadd_button_with_icon||END_LIST|noflags|0||\n\nadd_smalltext|`wRight Click Action (Secondary):|\nadd_button_with_icon|wrench_r_off|" .. (V .. ("|" .. (C .. ("|" .. (W.GetIcon("Constellation Wrench Style", 15678) .. ("|\nadd_button_with_icon|wrench_r_pull|" .. (e .. ("|" .. (D .. ("|" .. (W.GetIcon("Constellation Wrench Style", 15678) .. ("|\nadd_button_with_icon|wrench_r_kick|" .. (v .. ("|" .. (i .. ("|" .. (W.GetIcon("Constellation Wrench Style", 15678) .. ("|\nadd_button_with_icon|wrench_r_ban|" .. (f .. ("|" .. (K .. ("|" .. (W.GetIcon("Constellation Wrench Style", 15678) .. ("|\nadd_button_with_icon|wrench_r_trade|" .. (n .. ("|" .. (y .. ("|" .. (W.GetIcon("Constellation Wrench Style", 15678) .. ("|\nadd_button_with_icon||END_LIST|noflags|0||\nadd_spacer|small|\n\nadd_smalltext|`wSpamPull & RePull Control:|\nadd_button|apt_spampull_toggle|Spam Pull (Auto 3s): " .. (((((W.SpamPull or W.AutoSpamPull)) and "`2[ON]" or "`4[OFF]")) .. ("|noflags|0|0|\nadd_button|apt_spampull_now|Spam Pull 3s Now|noflags|0|0|\nadd_button|apt_repull_now|Re-Pull 1x Now|noflags|0|0|\nadd_textbox|`wRePull Hotkey: `^" .. (((W.RePullHotkeyName or "DELETE")) .. (" `7(/setrepullkey <key>)|left|\nadd_spacer|small|\n\nadd_smalltext|`wCustom Action Chat (Use {GrowID} for name):|\nadd_text_input|wrench_pull_txt|Pull:|" .. (W.WrenchPullText .. ("|64|\nadd_text_input|wrench_kick_txt|Kick:|" .. (W.WrenchKickText .. ("|64|\nadd_text_input|wrench_ban_txt|Ban:|" .. (W.WrenchBanText .. "|64|\nadd_spacer|small|\nadd_small_font_button|wrench_save_txt|`2Save Text|noflags|0|0|\nadd_spacer|small|\nadd_button|menuu|Back|noflags|0|0|\nend_dialog|close_ui|Close||\n")))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
    W.CreateDialog(p)
end

function W.ShowDonateDialog()
    local P = W.DonateMode and "`2ON" or "`4OFF"
    local j = "`4Not Set! Wrench a Box."
    if W.DonateBoxX ~= 0 or W.DonateBoxY ~= 0 then
        j = "`2X: " .. (W.DonateBoxX .. ("  Y: " .. W.DonateBoxY))
    end
    local Y = "add_label_with_icon|big|`9Smart Donation Mode|left|" .. (W.GetIcon("Donation Box", 1452) .. ("|\nadd_spacer|small|\nadd_small_font_button|btn_cmd_donate|`9List Command|noflags|0|0|\nadd_button|btn_toggle_dmode|Donate Mode: " .. (P .. ("|noflags|0|0|\nadd_textbox|Box Status: " .. (j .. ("|\nadd_text_input|don_amount|Amount:|1|5|\nadd_spacer|small|\ntext_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjj|\nadd_button_with_icon|btn_do_don_wl|Donate WL|noflags|" .. (W.GetIcon("Creativeps World Lock", 242) .. ("|\nadd_button_with_icon|btn_do_don_dl|Donate DL|noflags|" .. (W.GetIcon("Creativeps Diamond Lock", 1796) .. ("|\nadd_button_with_icon|btn_do_don_bgl|Donate BGL|noflags|" .. (W.GetIcon("Creativeps Blue Gem Lock", 7188) .. ("|\nadd_button_with_icon|btn_do_don_blgl|Donate BlackGL|noflags|" .. (W.GetIcon("Creativeps Black Gem Lock", 11550) .. "|\nadd_button_with_icon||END_LIST|noflags|0|\nadd_small_font_button|btn_do_don_all|`2Put All Locks|noflags|0|0|\nadd_small_font_button|btn_do_don_takeall|`4Take All Items|noflags|0|0|\nadd_spacer|small|\ntext_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjj|\nadd_button|menuu|Back|noflags|0|0|\nend_dialog|close_ui|Close||\n")))))))))))))
    W.CreateDialog(Y)
end

function W.ShowTradeDialog()
    local P = (W.WrenchMode == 4) and "`2ON" or "`4OFF"
    local j = "`4Not Trading! Wrench a Player."
    if W.TradeTargetUID and W.TradeTargetUID ~= 0 then
        j = "`2" .. (W.TradeTargetName .. (" `0(UID: `2" .. (W.TradeTargetUID .. "`0)")))
    end
    local Y = "add_label_with_icon|big|`9Advanced Trading Mode|left|" .. (W.GetIcon("Creativeps World Lock", 242) .. ("|\nadd_spacer|small|\nadd_small_font_button|btn_cmd_trade|`9List Command|noflags|0|0|\nadd_button|btn_toggle_tmode|Trade Mode: " .. (P .. ("|noflags|0|0|\nadd_textbox|Trade Status: " .. (j .. ("|\nadd_textbox|`wFast Add Currency:|\nadd_text_input|trade_amount|Amount:|1|5|\nadd_spacer|small|\ntext_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjj|\nadd_button_with_icon|btn_trade_add_wl|Add WL|noflags|" .. (W.GetIcon("Creativeps World Lock", 242) .. ("|\nadd_button_with_icon|btn_trade_add_dl|Add DL|noflags|" .. (W.GetIcon("Creativeps Diamond Lock", 1796) .. ("|\nadd_button_with_icon|btn_trade_add_bgl|Add BGL|noflags|" .. (W.GetIcon("Creativeps Blue Gem Lock", 7188) .. ("|\nadd_button_with_icon|btn_trade_add_blgl|Add BlackGL|noflags|" .. (W.GetIcon("Creativeps Black Gem Lock", 11550) .. "|\nadd_button_with_icon||END_LIST|noflags|0|\nadd_small_font_button|btn_trade_add_all|`2Put All Locks|noflags|0|0|\nadd_small_font_button|btn_trade_clear|`4Clear Locks|noflags|0|0|\nadd_spacer|small|\ntext_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjj|\nadd_button|menuu|Back|noflags|0|0|\nend_dialog|close_ui|Close||\n")))))))))))))
    W.CreateDialog(Y)
end

function W.ShowTelephoneDialog()
    local P = (W.TeleMode == 1) and "`2[ON]" or "`4[OFF]"
    local j = (W.TeleMode == 2) and "`2[ON]" or "`4[OFF]"
    local Y = (W.TeleMode == 3) and "`2[ON]" or "`4[OFF]"
    local X = (W.TeleMode == 4) and "`2[ON]" or "`4[OFF]"
    local M = (W.TeleMode == 5) and "`2[ON]" or "`4[OFF]"
    local z = (W.TeleMode == 6) and "`2[ON]" or "`4[OFF]"
    local o = (W.TeleMode == 1) and "staticYellowFrame" or "staticGreyFrame"
    local q = (W.TeleMode == 2) and "staticYellowFrame" or "staticGreyFrame"
    local S = (W.TeleMode == 3) and "staticYellowFrame" or "staticGreyFrame"
    local O = (W.TeleMode == 4) and "staticYellowFrame" or "staticGreyFrame"
    local V = (W.TeleMode == 5) and "staticYellowFrame" or "staticGreyFrame"
    local e = (W.TeleMode == 6) and "staticYellowFrame" or "staticGreyFrame"
    local v = "add_label_with_icon|big|`9Telephone Auto-Buy|left|" .. (W.GetIcon("Telephone", 3898) .. ("|\nadd_spacer|small|\nadd_small_font_button|btn_cmd_tele|`9List Command|noflags|0|0|\nadd_textbox|`wSelect an action below and punch a Telephone!|\n\nadd_smalltext|`wLocks & Conversion:|\ntext_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjj|\nadd_button_with_icon|tele_set_buydl|Buy DL " .. (P .. ("|" .. (o .. ("|" .. (W.GetIcon("Creativeps Diamond Lock", 1796) .. ("|\nadd_button_with_icon|tele_set_buybgl|Buy BGL " .. (j .. ("|" .. (q .. ("|" .. (W.GetIcon("Creativeps Blue Gem Lock", 7188) .. ("|\nadd_button_with_icon|tele_set_cv|CV BGL " .. (Y .. ("|" .. (S .. ("|" .. (W.GetIcon("Creativeps Blue Gem Lock", 7188) .. ("|\nadd_button_with_icon||END_LIST|noflags|0||\nadd_smalltext|`wChampagne Auto-Buy:|\ntext_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjj|\nadd_button_with_icon|tele_set_buychamp|Normal " .. (X .. ("|" .. (O .. ("|" .. (W.GetIcon("Champagne", 16896) .. ("|\nadd_button_with_icon|tele_set_buychampbg|BGem " .. (M .. ("|" .. (V .. ("|" .. (W.GetIcon("Champagne", 16896) .. ("|\nadd_button_with_icon|tele_set_buychampbulk|Bulk " .. (z .. ("|" .. (e .. ("|" .. (W.GetIcon("`2Infinity Champagne", 17070) .. "|\nadd_button_with_icon||END_LIST|noflags|0||\n\nadd_spacer|small|\ntext_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjj|\nadd_button|menuu|Back|noflags|0|0|\nend_dialog|close_ui|Close||\n")))))))))))))))))))))))))))))))))))))
    W.CreateDialog(v)
end

function W.ShowEmojiColorDialog()
    local P = ((W.EnableColor and W.ColorValues[W.SelectedColorIdx] == "RANDOM")) and "`2ON" or "`4OFF"
    local j = ((W.EnableEmoji and W.EmojiValues[W.SelectedEmojiIdx] == "RANDOM")) and "`2ON" or "`4OFF"
    local Y = W.WatermarkMode and "`2ON" or "`4OFF"
    local X = W.EncryptChat and "`2ON" or "`4OFF"
    local M = W.RainbowSkin and "`2ON" or "`4OFF"
    local z = W.BlinkSkin and "`2ON" or "`4OFF"
    local o = W.RainbowSkin and "staticYellowFrame" or "staticGreyFrame"
    local q = W.BlinkSkin and "staticYellowFrame" or "staticGreyFrame"
    local S = "add_label_with_icon|big|`9Text & Skin Settings|left|" .. (W.GetIcon("Happy Block", 1444) .. ("|\nadd_spacer|small|\nadd_small_font_button|btn_cmd_emoji|`9List Command|noflags|0|0|\nadd_textbox|`wInput Text Stuff (Colors, Emojis):|\nadd_small_font_button|btn_toggle_rcol|Random Text Color: " .. (P .. ("|noflags|0|0|\nadd_small_font_button|btn_toggle_remo|Random Chat Emojis: " .. (j .. ("|noflags|0|0|\nadd_small_font_button|btn_toggle_wm|Chat Watermark: " .. (Y .. ("|noflags|0|0|\nadd_small_font_button|btn_toggle_encrypt|Encrypt Chat: " .. (X .. ("|noflags|0|0|\nadd_spacer|small|\nadd_textbox|`wSkin Effects:|\ntext_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjj|\nadd_button_with_icon|btn_toggle_rb|Rainbow: " .. (M .. ("|" .. (o .. ("|" .. (W.GetIcon("Kaleidoscopic Wallpaper", 5272) .. ("|\nadd_button_with_icon|btn_toggle_bl|Blink: " .. (z .. ("|" .. (q .. ("|" .. (W.GetIcon("Checker Wallpaper", 284) .. ("|\nadd_button_with_icon||END_LIST|noflags|0||\nadd_spacer|small|\nadd_textbox|`wSkin Color Presets:|\ntext_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjj|\nadd_button_with_icon|skin_black|Black|staticGreyFrame|" .. (W.GetIcon("Black Wallpaper", 1158) .. ("|\nadd_button_with_icon|skin_white|White|staticGreyFrame|" .. (W.GetIcon("White Wallpaper", 1156) .. ("|\nadd_button_with_icon|skin_red|Red|staticGreyFrame|" .. (W.GetIcon("Red Wallpaper", 558) .. ("|\nadd_button_with_icon|skin_yellow|Yellow|staticGreyFrame|" .. (W.GetIcon("Yellow Wallpaper", 562) .. ("|\nadd_button_with_icon||END_LIST|noflags|0||\nadd_spacer|small|\ntext_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjj|\nadd_button_with_icon|skin_green|Green|staticGreyFrame|" .. (W.GetIcon("Green Wallpaper", 564) .. ("|\nadd_button_with_icon|skin_blue|Blue|staticGreyFrame|" .. (W.GetIcon("Blue Wallpaper", 568) .. ("|\nadd_button_with_icon|skin_purple|Purple|staticGreyFrame|" .. (W.GetIcon("Purple Wallpaper", 570) .. ("|\nadd_button_with_icon|skin_pink|Pink|staticGreyFrame|" .. (W.GetIcon("Pastel Pink Wallpaper", 2496) .. "|\nadd_button_with_icon||END_LIST|noflags|0||\nadd_spacer|small|\ntext_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjj|\nadd_button|menuu|Back|noflags|0|0|\nend_dialog|close_ui|Close||\n")))))))))))))))))))))))))))))))))))))
    W.CreateDialog(S)
end

function W.ShowCalculatorDialog()
    local P = ""
    if #W.CalcLogs > 0 then
        for j, Y in ipairs(W.CalcLogs) do
            P = P .. ("add_smalltext|`8" .. (j .. (". " .. (Y .. "|\n"))))
        end
    else
        P = "add_smalltext|`8No history available.|\n"
    end
    local j = "add_label_with_icon|big|`9Smart Calculator|left|" .. (W.GetIcon("Compu Panel", 1164) .. ("|\nadd_spacer|small|\nadd_small_font_button|btn_cmd_calc|`9List Command|noflags|0|0|\nadd_smalltext|`wEnter your math formula below: (/calc)|\nadd_smalltext|`oOperators: (+) Add, (-) Sub, (*) Mul, (/) Div, (%) Modulo|\nadd_text_input|calc_input|Formula:|" .. (W.CalcInput .. ("|64|\nadd_small_font_button|btn_do_calc|`2Calculate|noflags|0|0|\nadd_smalltext|`wLatest Result: " .. (W.CalcResult .. ("|\nadd_spacer|small|\nadd_smalltext|`9Calculation History:|\n" .. (P .. "add_spacer|small|\ntext_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjj|\nadd_button|menuu|Back|noflags|0|0|\nend_dialog|close_ui|Close||\n")))))))
    W.CreateDialog(j)
end

function W.ShowItemDBDialog()
    local P = ""
    if #W.SearchItemResults > 0 then
        for j, Y in ipairs(W.SearchItemResults) do
            if j > 30 then
                P = P .. ("add_smalltext|`8... and " .. ((#W.SearchItemResults - 30) .. " more.|\n"))
                break
            end
            local X = Y.name:gsub("(%a)([%w_\']*)", function(P, j)
                return P:upper() .. j:lower()
            end)
            P = P .. ("add_label_with_icon|small|`w" .. (X .. (" `0(ID: `2" .. (Y.id .. ("`0)|left|" .. (Y.id .. "|\n"))))))
        end
    else
        P = "add_smalltext|`4No items found or query empty.|\n"
    end
    local j = "add_label_with_icon|big|`9Item Database|left|" .. (W.GetIcon("Growscan 9000", 6016) .. ("|\nadd_spacer|small|\nadd_text_input|input_search_item|Search:|" .. (W.SearchItemInput .. ("|32|\nadd_spacer|small|\nadd_button|btn_do_search_item|`2Search Item|noflags|0|0|\nadd_textbox|`9Search Results:|\n" .. (P .. "add_spacer|small|\ntext_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjj|\nadd_button|menuu|Back|noflags|0|0|\nend_dialog|close_ui|Close||\n")))))
    W.CreateDialog(j)
end

function W.ShowAutoFarmDialog()
    local P = "add_label_with_icon|big|`9Auto Farm Features|left|" .. (W.GetIcon("Dumb Farmer", 7064) .. ("|\nadd_spacer|small|\ntext_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjj|\nadd_button_with_icon|btn_auto_ptht|`wAuto PTHT|staticYellowFrame|" .. (W.GetIcon("Dumb Farmer", 7064) .. ("||\nadd_button_with_icon|btn_auto_provider|`wAuto Provider|staticYellowFrame|" .. (W.GetIcon("Black Atm Machine", 17024) .. ("||\nadd_button_with_icon|btn_auto_pnb|`wAuto PNB|staticYellowFrame|" .. (W.GetIcon("Dumb Builder", 7070) .. ("||\nadd_button_with_icon|btn_auto_rotasi|`wAuto Rotasi|staticYellowFrame|" .. (W.GetIcon("Stack Of Gems Icon", 3524) .. ("||\nadd_button_with_icon|btn_auto_tax|`wAuto Tax|staticYellowFrame|" .. (W.GetIcon("Creativeps Diamond Lock", 1796) .. "||\nadd_button_with_icon||END_LIST|noflags|0||\nadd_spacer|small|\ntext_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjj|\nadd_button|menuu|Back|noflags|0|0|\nend_dialog|close_ui|Close||\n")))))))))))
    W.CreateDialog(P)
end

function W.ShowAutoPTHTDialog()
    W.CreateDialog(V("Auto PTHT Settings", 7064))
end

function W.ShowAutoProviderDialog()
    W.CreateDialog(V("Auto Provider Settings", 17024))
end

function W.ShowAutoPNBDialog()
    W.CreateDialog(V("Auto PNB Settings", 7070))
end

function W.ShowAutoRotasiDialog()
    W.CreateDialog(V("Auto Rotasi Settings", 3524))
end

function W.ShowAutoTaxDialog()
    W.CreateDialog(V("Auto Tax Settings", 1796))
end

function W.ShowAutoCookDialog()
    W.CreateDialog(V("Auto Cook Settings", 7076))
end

function W.ShowAutoFishDialog()
    local P = W.AutoFish and "add_small_font_button|btn_toggle_fish|`4STOP AUTO FISH|noflags|0|0|\n" or "add_button|btn_toggle_fish|`2START AUTO FISH|noflags|0|0|\n"
    local j = W.AutoFish and "`2" or "`e"
    if W.FishAction:find("Out of") or W.FishAction:find("Stopping") then
        j = "`4"
    end
    local Y = (W.FishDirIdx == 1) and "`2Facing Right" or "`2Facing Left"
    local X = "set_default_color|`o\nadd_label_with_icon|big|`9Auto Fishing|left|" .. (W.GetIcon("Dumb Fisher", 7072) .. ("|\nadd_spacer|small|\nadd_textbox|`wStatus: " .. (j .. (W.FishAction .. ("|left|\n" .. (P .. ("add_smalltext|`wHow to use: Equip your Fishing Rod, face the water, select your direction below, and click Start!|\nadd_small_font_button|btn_toggle_fish_dir|Facing Direction: " .. (Y .. ("|noflags|0|0|\nadd_text_input|input_fish_bait|Bait Item ID:|" .. (W.FishBaitID .. ("|6|\nadd_smalltext|`o(Common Baits: 2504 = Worm, 5528 = Mega Pelet, 2904 = Salmon)|\nadd_small_font_button|btn_save_fish|`2Save Settings|noflags|0|0|\nadd_spacer|small|\nadd_smalltext|`2Statistics:|\nadd_smalltext|`wTotal Casts : `0" .. (W.FishStats.cast .. ("|left|\nadd_smalltext|`wFish Caught : `2" .. (W.FishStats.caught .. ("|left|\nadd_smalltext|`wFish Missed : `4" .. (W.FishStats.missed .. "|left|\nadd_small_font_button|btn_reset_fish_stats|Reset Stats|noflags|0|0|\nadd_spacer|small|\ntext_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjj|\nadd_button|menuu|Back|noflags|0|0|\nend_dialog|close_ui|Close||\n"))))))))))))))))
    W.CreateDialog(X)
end

function W.ShowAutoSurgDialog()
    local P = W.AutoSurg and "add_button|btn_toggle_surg|`4STOP AUTO SURG|noflags|0|0|\n" or "add_button|btn_toggle_surg|`2START AUTO SURG|noflags|0|0|\n"
    local j = W.AutoSurg and "`2" or "`e"
    if W.SurgAction:find("Malpractice") or W.SurgAction:find("low!") or W.SurgAction:find("Stopping") then
        j = "`4"
    end
    local Y = ""
    if W.SurgTarget then
        Y = "add_textbox|`wTarget: `2Player ID: `0" .. (tostring(W.SurgTarget) .. "|left|\n")
    end
    local X = W.SurgAutoBuy and "`2[ON]" or "`4[OFF]"
    local M = W.SurgAutoTrash and "`2[ON]" or "`4[OFF]"
    local z = W.SurgAutoModage and "`2[ON]" or "`4[OFF]"
    local o = W.SurgUseLegalBrief and "`2[ON]" or "`4[OFF]"
    local q = W.SurgStats.success + W.SurgStats.fail
    local S = (q > 0) and math.floor(((W.SurgStats.success / q)) * 100) or 0
    local O = "set_default_color|`o\nadd_label_with_icon|big|`9Auto Surgery (Smart AI)|left|" .. (W.GetIcon("Dumb Surgeon", 7068) .. ("|\nadd_spacer|small|\nadd_textbox|`wStatus: " .. (j .. (W.SurgAction .. ("|left|\n" .. (Y .. ("" .. (P .. ("add_smalltext|`wHow to use: Click Start, then Wrench a player to begin.|\nadd_small_font_button|btn_toggle_surg_autobuy|Enable Auto Buy Surg Kit: " .. (X .. ("|noflags|0|0|\nadd_text_input|input_surg_threshold|Min. Threshold:|" .. (W.SurgCardThreshold .. ("|3|\nadd_smalltext|`oBot will automatically buy \'Surgical Kit\' if any tool drops below " .. (W.SurgCardThreshold .. (".|\nadd_small_font_button|btn_toggle_surg_autotrash|Auto Trash Excess Tools (>= 240): " .. (M .. ("|noflags|0|0|\nadd_small_font_button|btn_toggle_surg_modage|Auto Bypass Malpractice (For MVP+): " .. (z .. ("|noflags|0|0|\nadd_small_font_button|btn_toggle_surg_legalbrief|Use Legal Brief (For Non-MVP+): " .. (o .. ("|noflags|0|0|\nadd_small_font_button|btn_save_surg|`2Save Settings|noflags|0|0|\nadd_spacer|small|\nadd_smalltext|`2Statistics:|\nadd_smalltext|`wSuccessful Surgeries : `2" .. (W.SurgStats.success .. ("|left|\nadd_smalltext|`wFailed (Malpractice) : `4" .. (W.SurgStats.fail .. ("|left|\nadd_smalltext|`wWin Rate Accuracy    : `b" .. (S .. "%|left|\nadd_small_font_button|btn_reset_surg_stats|Reset Stats|noflags|0|0|\nadd_spacer|small|\ntext_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjj|\nadd_button|menuu|Back|noflags|0|0|\nend_dialog|close_ui|Close||\n"))))))))))))))))))))))))))
    W.CreateDialog(O)
end

function W.ShowAutoCrimeDialog()
    local P = W.AutoCrime and "add_small_font_button|btn_toggle_crime|`4STOP AUTO CRIME|noflags|0|0|\n" or "add_button|btn_toggle_crime|`2START AUTO CRIME|noflags|0|0|\n"
    local j = W.AutoCrime and "`2" or "`e"
    if W.CrimeAction:find("Error") or W.CrimeAction:find("Lost") or W.CrimeAction:find("Stopping") then
        j = "`4"
    end
    local Y = ""
    if W.CrimeTarget then
        Y = "add_textbox|`wTarget: `2" .. (W.CrimeTarget.name .. (" `0@ (" .. (W.CrimeTarget.x .. (", " .. (W.CrimeTarget.y .. ")|left|\n")))))
    end
    local X = W.AutoBuyCrimeCards and "`2[ON]" or "`4[OFF]"
    local M = "set_default_color|`o\nadd_label_with_icon|big|`9Auto Crime (CPS Optimized)|left|" .. (W.GetIcon("Crime Wave", 2382) .. ("|\nadd_spacer|small|\nadd_textbox|`wStatus: " .. (j .. (W.CrimeAction .. ("|left|\n" .. (Y .. ("" .. (P .. ("add_smalltext|`wHow to use: Click Scan Villains, then Start to auto-fight villains in world.|\nadd_small_font_button|btn_scan_crime|`eScan Villains|noflags|0|0|\nadd_small_font_button|btn_toggle_crime_autobuy|Enable Auto Buy Crime Cards: " .. (X .. ("|noflags|0|0|\nadd_text_input|input_crime_threshold|Min. Threshold:|" .. (W.CrimeCardThreshold .. ("|3|\nadd_smalltext|`oBot will automatically buy Crime Cards if any card drops below " .. (W.CrimeCardThreshold .. (".|\nadd_small_font_button|btn_save_crime|`2Save Settings|noflags|0|0|\nadd_spacer|small|\nadd_smalltext|`2Statistics:|\nadd_smalltext|`wVillains Found in World : `2" .. (#W.CrimeVillains .. " `wVillains|left|\nadd_small_font_button|btn_view_crime_villains|View Villains List|noflags|0|0|\nadd_spacer|small|\ntext_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjj|\nadd_button|menuu|Back|noflags|0|0|\nend_dialog|close_ui|Close||\n"))))))))))))))))
    W.CreateDialog(M)
end

function W.ShowAutoGeigerDialog()
    W.CreateDialog(V("Auto Geiger Settings", 2204))
end

function W.ShowAutoBuyPackDialog()
    local P = W.AutoBuyPack and "Running" or "Idle"
    local j = W.AutoBuyPack and "`2" or "`e"
    local Y = W.ABP_Packs[W.ABP_PackIdx]
    local X = Y and Y.name or "`4None (Click Auto-Scan!)"
    local M = ((Y and Y.cost)) and (" `o(" .. (Y.cost .. " Gems)")) or ""
    local z = W.ABP_IsScanningShop and "`4Scanning Shop..." or "`eAuto-Scan Shop Packs"
    local o = ""
    if #W.ABP_Packs > 0 then
        o = W.AutoBuyPack and "add_small_font_button|btn_toggle_abp|`4STOP AUTO BUY PACK|noflags|0|0|\n" or "add_button|btn_toggle_abp|`2START AUTO BUY PACK|noflags|0|0|\n"
    else
        o = "add_small_font_button|btn_scan_abp|`4START LOCKED (Please Auto-Scan first)|noflags|0|0|\n"
    end
    local q = W.ABP_BuyOnly and "`2[ON]" or "`4[OFF]"
    local S = W.ABP_BatchMode and "`2[ON]" or "`4[OFF]"
    local O = ""
    if not W.ABP_BuyOnly then
        O = "add_text_input|input_abp_dropx|Drop Base X:|" .. (W.ABP_DropX .. ("|4|\nadd_text_input|input_abp_dropy|Drop Base Y:|" .. (W.ABP_DropY .. "|4|\nadd_smalltext|`oPack items will be automatically dropped side-by-side.|\n")))
    end
    local V = ""
    if #W.ABP_Packs > 0 then
        V = "add_small_font_button|btn_abp_select_menu|Select Pack From List|noflags|0|0|\n"
    end
    local e = "set_default_color|`o\nadd_label_with_icon|big|`9Auto Buy Pack (Smart Detect)|left|" .. (W.GetIcon("Dumb G4g Crate Pack", 10868) .. ("|\nadd_spacer|small|\nadd_textbox|`wStatus: " .. (j .. (P .. ("|left|\nadd_textbox|`wSelected Pack: `2" .. (X .. (M .. ("|left|\n" .. (o .. ("add_small_font_button|btn_scan_abp|" .. (z .. ("|noflags|0|0|\n" .. (V .. ("add_text_input|input_abp_amount|Amount to Buy (0=Inf):|" .. (W.ABP_BuyAmount .. ("|5|\nadd_small_font_button|btn_toggle_abp_only|Buy Only (Do Not Drop): " .. (q .. ("|noflags|0|0|\nadd_small_font_button|btn_toggle_abp_batch|Batch Mode (Buy till full, then Drop): " .. (S .. ("|noflags|0|0|\n" .. (O .. ("add_small_font_button|btn_save_abp|`2Save Settings|noflags|0|0|\nadd_spacer|small|\nadd_smalltext|`2Statistics:|\nadd_smalltext|`wTotal Packs Loaded : `2" .. (#W.ABP_Packs .. " `wItems|left|\nadd_spacer|small|\ntext_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjj|\nadd_button|menuu|Back|noflags|0|0|\nend_dialog|close_ui|Close||\n")))))))))))))))))))))))
    W.CreateDialog(e)
end

function W.ShowABPPackListDialog()
    local P = ""
    for j, Y in ipairs(W.ABP_Packs) do
        local X = (j == W.ABP_PackIdx) and "`2[Selected] " or ""
        local M = Y.cost and (" `o(" .. (Y.cost .. " Gems)")) or ""
        P = P .. ("add_small_font_button|abp_sel_" .. (j .. ("|" .. (X .. (Y.name .. (M .. "|noflags|0|0|\n"))))))
    end
    if #W.ABP_Packs == 0 then
        P = "add_smalltext|`4No packs found. Please click \'Auto-Scan Shop Packs\' first!|\n"
    end
    local j = "set_default_color|`o\nadd_label_with_icon|big|`9Select Pack (Total: " .. (#W.ABP_Packs .. (")|left|" .. (W.GetIcon("Dumb G4g Crate Pack", 10868) .. ("|\nadd_spacer|small|\nadd_smalltext|`wClick any pack below to select it:|\nadd_spacer|small|\n" .. (P .. "add_spacer|small|\ntext_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjj|\nadd_button|btn_abp_back|Back|noflags|0|0|\nend_dialog|close_ui|Close||\n")))))
    W.CreateDialog(j)
end

function W.ShowCasinoDialog()
    local P = (W.CasinoMode == 1) and "`2Reme: ON" or "`4Reme: OFF"
    local j = (W.CasinoMode == 2) and "`2Qeme: ON" or "`4Qeme: OFF"
    local Y = (W.CasinoMode == 3) and "`2Leme: ON" or "`4Leme: OFF"
    local X = (W.CasinoMode == 4) and "`2Leme S: ON" or "`4Leme S: OFF"
    local M = (W.CasinoMode == 5) and "`2Ceme: ON" or "`4Ceme: OFF"
    local z = (W.CasinoMode == 7) and "`2All (R/L/Q): ON" or "`4All (R/L/Q): OFF"
    local o = (W.CasinoMode == 6) and "`2Lewa: ON" or "`4Lewa: OFF"
    local q = W.AutoChampWheel and "`2Auto Champ Wheel: ON" or "`4Auto Champ Wheel: OFF"
    local S = "add_label_with_icon|big|`9Casino Modes|left|" .. (W.GetIcon("Roulette Wheel", 758) .. ("|\nadd_spacer|small|\nadd_small_font_button|btn_cmd_casino|`9List Command|noflags|0|0|\ntext_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjj|\nadd_button_with_icon|cas_autochamp|" .. (q .. ("|staticYellowFrame|" .. (W.GetIcon("Champagne", 16896) .. ("|\nadd_button_with_icon||END_LIST|noflags|0||\nadd_button_with_icon|cas_all|" .. (z .. ("|staticYellowFrame|" .. (W.GetIcon("Roulette Wheel", 758) .. ("|\nadd_button_with_icon|cas_reme|" .. (P .. ("|staticYellowFrame|" .. (W.GetIcon("Roulette Wheel", 758) .. ("|\nadd_button_with_icon|cas_qeme|" .. (j .. ("|staticYellowFrame|" .. (W.GetIcon("Roulette Wheel", 758) .. ("|\nadd_button_with_icon|cas_leme|" .. (Y .. ("|staticYellowFrame|" .. (W.GetIcon("Roulette Wheel", 758) .. ("|\nadd_button_with_icon|cas_lemes|" .. (X .. ("|staticYellowFrame|" .. (W.GetIcon("Roulette Wheel", 758) .. ("|\nadd_button_with_icon|cas_ceme|" .. (M .. ("|staticYellowFrame|" .. (W.GetIcon("Roulette Wheel", 758) .. ("|\nadd_button_with_icon|cas_lewa|" .. (o .. ("|staticYellowFrame|" .. (W.GetIcon("Roulette Wheel", 758) .. ("|\nadd_button_with_icon||END_LIST|noflags|0||\nadd_text_input|input_lewa|Lewa Multiplier:|" .. (W.CasinoLewaMulti .. ("|3|\nadd_small_font_button|btn_save_lewa|`2Save Lewa|\nadd_spacer|small|\nadd_label_with_icon|small|`9Result Format:|left|" .. (W.GetIcon("Compu Panel", 1164) .. ("|\nadd_button_with_icon|cas_fmt_1|" .. ((((W.CasinoFormatIdx == 1) and "`2[Result] (Ori)" or "`4[Result] (Ori)")) .. ("|staticYellowFrame|" .. (W.GetIcon("Compu Panel", 1164) .. ("|\nadd_button_with_icon|cas_fmt_2|" .. ((((W.CasinoFormatIdx == 2) and "`2(Ori) [Result]" or "`4(Ori) [Result]")) .. ("|staticYellowFrame|" .. (W.GetIcon("Compu Panel", 1164) .. "|\nadd_button_with_icon||END_LIST|noflags|0||\nadd_spacer|small|\ntext_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjj|\nadd_button|menuu|Back|noflags|0|0|\nend_dialog|close_ui|Close||\n")))))))))))))))))))))))))))))))))))))))))))))
    W.CreateDialog(S)
end

function W.ShowBTKBJDialog()
    local P = (W.BTK_Mode == "BJ") and "`eBlackjack 21" or "`2BTK (Most Gems)"
    local j = "set_default_color|`o\nadd_label_with_icon|big|`9BTK / BJ Control Panel|left|" .. (W.GetIcon("Chandelier", 340) .. "|\nadd_spacer|small|\nadd_small_font_button|btn_btk_cmd_list|`9List Command|noflags|0|0|\nadd_textbox|`wDue to the setup complexity, we recommend using the `2ImGui Panel (/imgui) `wor fast `9In-Game Chat Commands `wfor the best experience.|left|\ntext_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjj|\nadd_spacer|small|\nadd_button|menuu|Back|noflags|0|0|\nend_dialog|close_ui|Close||\n")
    W.CreateDialog(j)
end

function W.ShowBTKCommandsDialog()
    local P = "set_default_color|`o\nadd_label_with_icon|big|`9BTK & BJ Commands List|left|" .. (W.GetIcon("Chandelier", 340) .. "|\nadd_spacer|small|\nadd_textbox|`wFast in-game commands for BTK & BJ host gameplay:|left|\nadd_spacer|small|\nadd_smalltext|`2Menu & Mode Switching:|\nadd_smalltext|`b/btkmenu `4or `b/bjmenu `w: Open Host Dialog Panel|left|\nadd_smalltext|`b/btkcmd `4or `b/bjcmd `w: Show this Command List|left|\nadd_smalltext|`b/btk `w: Switch to BTK Mode (Most Gems)|left|\nadd_smalltext|`b/bj `w: Switch to BJ Mode (Blackjack 21)|left|\nadd_spacer|small|\nadd_smalltext|`2Game Round Actions:|\nadd_smalltext|`b/btkremote `4or `b/bjremote `w: Collect Remote from Magplant|left|\nadd_smalltext|`b/btkbet `4or `b/bjbet `w: Take Bets & Calculate 5% Tax|left|\nadd_smalltext|`b/btkgems `4or `b/bjgems `w: Check Gems & Announce Winner|left|\nadd_smalltext|`b/btkdrop `4or `b/bjdrop `w: Drop Prize, Tax & Reset Round|left|\nadd_spacer|small|\nadd_smalltext|`2Coordinate Setup (Touch / Punch tile to set):|\nadd_smalltext|`b/btkcenter `4or `b/bjcenter `w: Set Host Center tile|left|\nadd_smalltext|`b/btkposbet1 `4or `b/bjposbet1 `w: Set Bet Player 1 tile|left|\nadd_smalltext|`b/btkposbet2 `4or `b/bjposbet2 `w: Set Bet Player 2 tile|left|\nadd_smalltext|`b/btkposbreak1 `4or `b/bjposbreak1 `w: Set Break Player 1 tile|left|\nadd_smalltext|`b/btkposbreak2 `4or `b/bjposbreak2 `w: Set Break Player 2 tile|left|\nadd_smalltext|`b/btktax `4or `b/bjtax `w: Set Tax Drop tile|left|\nadd_smalltext|`b/btkmag `4or `b/bjmag `w: Set Magplant tile|left|\nadd_spacer|small|\ntext_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjj|\nadd_button|btn_btkbj|Back|noflags|0|0|\nend_dialog|close_ui|Close||\n")
    W.CreateDialog(P)
end

function W.ShowAutoPullDialog()
    local P = W.AutoPull and "`2[ON]" or "`4[OFF]"
    local j = W.AutoPullAreaScan and "`2[ON]" or "`4[OFF]"
    local Y = tonumber(W.AutoPullMinModal) or 0
    local X = (Y > 0) and tostring(Y) or ""
    local M = (Y > 0) and ("`2" .. (X .. " BGL `w(Active)")) or "`4No Limit"
    local z = "add_label_with_icon|big|`9Auto Pull Settings|left|" .. (W.GetIcon("Shocking Wrench Decoration", 14822) .. ("|\nadd_spacer|small|\nadd_small_font_button|btn_cmd_autopull|`9List Command|noflags|0|0|\nadd_button|apt_master_toggle|Auto Pull (OnSpawn): " .. (P .. ("|noflags|0|0|\nadd_button|apt_area_toggle|Area Scan Mode: " .. (j .. ("|noflags|0|0|\nadd_spacer|small|\nadd_textbox|`wCurrent Min Modal: " .. (M .. ("|left|\nadd_text_input|apt_min_modal_input|Min Modal (BGL):|" .. (X .. "|5|\nadd_spacer|small|\nadd_small_font_button|btn_apt_pos_menu|`2Manage Pos Autopull|noflags|0|0|\nadd_small_font_button|btn_apt_blacklist_menu|`4Manage Blacklist|noflags|0|0|\nadd_spacer|small|\nadd_small_font_button|btn_apt_save_all|`2Save Configuration|noflags|0|0|\nadd_spacer|small|\ntext_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjj|\nadd_button|menuu|Back|noflags|0|0|\nend_dialog|close_ui|Close||\n")))))))))
    W.CreateDialog(z)
end

function W.ShowAPTPositionsDialog()
    local P = ""
    for j = 1, 5, 1 do
        local Y = W.AutoPullPos[j]
        local X = "`4Not Set"
        if type(Y) == "table" and ((Y.x > 0 or Y.y > 0)) then
            X = "`2(" .. (Y.x .. (", " .. (Y.y .. ")")))
        end
        P = P .. ("add_textbox|`9Pos " .. (j .. (" : " .. (X .. "|left|\n"))))
        P = P .. ("add_small_font_button|btn_apt_mypos_" .. (j .. ("|`2Set My Pos " .. (j .. "|noflags|0|0|\n"))))
        P = P .. ("add_small_font_button|btn_apt_touch_" .. (j .. ("|`cTouch to Set " .. (j .. "|noflags|0|0|\n"))))
        P = P .. ("add_small_font_button|btn_apt_clear_" .. (j .. ("|`4Clear " .. (j .. "|noflags|0|0|\n"))))
        P = P .. "add_spacer|small|\n"
    end
    local j = "add_label_with_icon|big|`9Manage Pos Autopull|left|" .. (W.GetIcon("Shocking Wrench Decoration", 14822) .. ("|\nadd_spacer|small|\nadd_textbox|`wTarget Positions (Pos 1 - 5):|left|\nadd_spacer|small|\n" .. (P .. "add_button|btn_apt_reset_all_positions|`4RESET ALL 5 POSITIONS|noflags|0|0|\nadd_spacer|small|\ntext_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjj|\nadd_button|btn_apt_back_main|Back|noflags|0|0|\nend_dialog|close_ui|Close||\n")))
    W.CreateDialog(j)
end

function W.ShowAPTBlacklistDialog()
    local P = GetPlayerList() or {}
    local j = GetLocal()
    local Y = j and j.userid or 0
    local X = ""
    local M = 0
    local z = {}
    for P, j in ipairs(W.AutoPullBlacklist) do
        table.insert(z, j)
    end
    table.sort(z)
    local o = ""
    if #z == 0 then
        o = "add_textbox|`7No UIDs currently blacklisted.|left|\n"
    else
        o = "add_textbox|`2Total Blacklisted: `9" .. (#z .. " UID(s)|left|\n")
        o = o .. ("add_textbox|`eUIDs: `w" .. (table.concat(z, "`7, `w") .. "|left|\n"))
    end
    for P, j in pairs(P) do
        local z = j.userid or j.netid or 0
        local o = j.name or "Unknown"
        local q = o:gsub("%[.-%]", "")
        q = q:gsub("%(.-%)", "")
        q = (q:gsub("%s+", " ")):match("^%s*(.-)%s*$") or "Unknown"
        local S = q:gsub("`.", "")
        if z ~= 0 and (z ~= Y and not (S:lower()):find("spammer slave")) then
            local P = 0
            for j, Y in ipairs(W.AutoPullBlacklist) do
                if Y == z then
                    P = 1
                    break
                end
            end
            X = X .. ("add_checkbox|apt_cb_" .. (z .. ("|" .. (q .. (" `0(UID: `2" .. (z .. ("`0)|" .. (P .. "|\n"))))))))
            M = M + 1
        end
    end
    if M == 0 then
        X = "add_textbox|`9No other players in this world.|left|\n"
    end
    local q = "add_label_with_icon|big|`9Auto Pull Blacklist|left|" .. (W.GetIcon("Black Wallpaper", 1158) .. ("|\nadd_spacer|small|\nadd_label_with_icon|small|`2Active Blacklist Status|left|" .. (W.GetIcon("Black Wallpaper", 3210) .. ("|\n" .. (o .. ("add_spacer|small|\nadd_textbox|`wSelect players in world to block:|left|\n" .. (X .. "add_spacer|small|\nadd_small_font_button|btn_apt_save|`2Save Checkbox|noflags|0|0|\nadd_small_font_button|btn_apt_select_all|Select All|noflags|0|0|\nadd_small_font_button|btn_apt_deselect_all|Deselect All|noflags|0|0|\nadd_spacer|small|\nadd_textbox|`wManual UID Input:|left|\nadd_text_input|apt_uid_input|UID:|0|8|\nadd_small_font_button|btn_apt_add|`2+ Add UID|noflags|0|0|\nadd_small_font_button|btn_apt_remove|`4- Remove UID|noflags|0|0|\nadd_spacer|small|\ntext_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjj|\nadd_button|btn_apt_back_main|Back|noflags|0|0|\nend_dialog|close_ui|Close||\n")))))))
    W.CreateDialog(q)
end

function W.ShowSpamDialog()
    local P = W.SpamEnabled and "`2ON" or "`4OFF"
    local j = "add_label_with_icon|big|`9Auto-Spam Settings|left|" .. (W.GetIcon("Spammer Slave", 16990) .. ("|\nadd_spacer|small|\nadd_small_font_button|btn_cmd_spam|`9List Command|noflags|0|0|\nadd_button|btn_toggle_spam|Auto-Spam: " .. (P .. "|noflags|0|0|\nadd_textbox|`wSpam Messages:|\n")))
    for P = 1, #W.SpamTexts, 1 do
        j = j .. ("add_text_input|input_spam_" .. (P .. ("|Typer Text " .. (P .. (":|" .. (W.SpamTexts[P] .. "|64|\n"))))))
    end
    j = j .. "add_small_font_button|btn_add_spam_field|`2[+] Add Field|noflags|0|0|\n"
    if #W.SpamTexts > 1 then
        j = j .. "add_small_font_button|btn_rem_spam_field|`4[-] Remove Last|noflags|0|0|\n"
    end
    j = j .. ("add_text_input|input_spam_delay|Typer Delay (ms):|" .. (W.SpamInterval .. "|5|\nadd_small_font_button|btn_save_spam|`2Save Configuration|noflags|0|0|\nadd_spacer|small|\ntext_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjj|\nadd_button|menuu|Back|noflags|0|0|\nend_dialog|close_ui|Close||\n"))
    W.CreateDialog(j)
end

function W.ShowSBDialog()
    local P = "add_label_with_icon|big|`9SB & SDB Settings|left|" .. (W.GetIcon("Megaphone", 2480) .. ("|\nadd_spacer|small|\nadd_small_font_button|btn_cmd_sb|`9List Command|noflags|0|0|\nadd_label_with_icon|small|`9Super Broadcast (SB)|left|" .. (W.GetIcon("Megaphone", 11230) .. ("|\nadd_text_input|input_sb_text|Text:|" .. (W.SBText .. ("|64|\nadd_text_input|input_sb_amount|SB Amount:|" .. (W.SBMax .. ("|5|\nadd_text_input|input_sb_done|Done World:|" .. (W.SBDoneWorld .. ("|32|\nadd_button_with_icon|btn_start_sb|`2Start SB|staticYellowFrame|" .. (W.GetIcon("Megaphone", 2480) .. ("|\nadd_button_with_icon|btn_stop_sb|`4Stop SB|staticYellowFrame|" .. (W.GetIcon("Megaphone", 2480) .. ("|\nadd_button_with_icon|btn_reset_sb|`eReset SB (`9" .. (W.SBCount .. ("/" .. (W.SBMax .. (")|staticYellowFrame|" .. (W.GetIcon("Megaphone", 2480) .. ("|\nadd_button_with_icon||END_LIST|noflags|0|\nadd_spacer|small|\nadd_label_with_icon|small|`9Super Duper Broadcast (SDB)|left|" .. (W.GetIcon("Megaphone", 11230) .. ("|\nadd_text_input|input_sdb_l1|Line 1:|" .. (W.SDBLine1 .. ("|64|\nadd_text_input|input_sdb_l2|Line 2:|" .. (W.SDBLine2 .. ("|64|\nadd_text_input|input_sdb_l3|Line 3:|" .. (W.SDBLine3 .. ("|64|\nadd_text_input|input_sdb_amount|SDB Amount:|" .. (W.SDBMax .. ("|5|\nadd_text_input|input_sdb_delay|Extra Delay (Mins):|" .. (W.SDBExtraTimer .. ("|5|\nadd_button_with_icon|btn_start_sdb|`2Start SDB|staticYellowFrame|" .. (W.GetIcon("Megaphone", 2480) .. ("|\nadd_button_with_icon|btn_stop_sdb|`4Stop SDB|staticYellowFrame|" .. (W.GetIcon("Megaphone", 2480) .. ("|\nadd_button_with_icon|btn_reset_sdb|`eReset SDB (`9" .. (W.SDBCount .. ("/" .. (W.SDBMax .. (")|staticYellowFrame|" .. (W.GetIcon("Megaphone", 2480) .. "|\nadd_button_with_icon||END_LIST|noflags|0|\nadd_spacer|small|\nadd_button|btn_save_sb_config|`2Save Configuration|noflags|0|0|\ntext_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjj|\nadd_button|menuu|Back|noflags|0|0|\nend_dialog|close_ui|Close||\n")))))))))))))))))))))))))))))))))))))))))
    W.CreateDialog(P)
end

-- ========================================================================
-- SECTION 12: Magplant & Vending automation
-- NOTE: VendParse / MagParse / MagStart / VendStart are defined TWICE in this file.
-- Lua keeps the later definition, so the first copies below are dead code.
-- ========================================================================

function W.MagWrench(P, j)
    local Y = { type = 3; value = 32; px = P, py = j, x = P * 32, y = j * 32 }
    SendPacketRaw(false, Y)
end

-- (dead code: overridden by the later definition below)
function W.VendParse(P)
    local j = P:match("vend_target_x|(%d+)")
    if j then
        W.VendTargetX = j
    end
    local Y = P:match("vend_target_y|(%d+)")
    if Y then
        W.VendTargetY = Y
    end
    local X = P:match("vend_find_id|(%d+)")
    if X then
        W.VendFindID = X
    end
    local M = P:match("vend_delay|(%d+)")
    if M then
        W.VendDelay = tonumber(M) or W.VendDelay
    end
    local z = P:match("vend_from_world|([^|\n\r]+)")
    if z then
        W.VendFromWorld = z
    end
    local o = P:match("vend_from_x|(%d+)")
    if o then
        W.VendFromX = o
    end
    local q = P:match("vend_from_y|(%d+)")
    if q then
        W.VendFromY = q
    end
    local S = P:match("vend_drop_world|([^|\n\r]+)")
    if S then
        W.VendDropWorld = S
    end
    local O = P:match("vend_drop_x|(%d+)")
    if O then
        W.VendDropX = O
    end
    local V = P:match("vend_drop_y|(%d+)")
    if V then
        W.VendDropY = V
    end
    local e = P:match("v2v_take_w|([^|\n\r]+)")
    if e then
        W.VendM2MTakeWorld = e
    end
    local v = P:match("v2v_take_x|(%d+)")
    if v then
        W.VendM2MTakeX = v
    end
    local f = P:match("v2v_take_y|(%d+)")
    if f then
        W.VendM2MTakeY = f
    end
    local n = P:match("v2v_put_w|([^|\n\r]+)")
    if n then
        W.VendM2MPutWorld = n
    end
    local C = P:match("v2v_put_x|(%d+)")
    if C then
        W.VendM2MPutX = C
    end
    local D = P:match("v2v_put_y|(%d+)")
    if D then
        W.VendM2MPutY = D
    end
    local i = P:match("vend_price|(%d+)")
    if i then
        W.VendPrice = i
    end
    local K = P:match("vend_price_mode|([^|\n\r]+)")
    if K then
        W.VendPriceMode = K
    end
    W.SaveConfig(true)
end

-- (dead code: overridden by the later definition below)
function W.MagParse(P)
    local j = P:match("mag_find_id|(-?%d+)")
    local Y = tonumber(P:match("mag_delay|(%d+)"))
    local X = P:match("mag_from_world|([^|\n]*)")
    local M = P:match("mag_from_x|(%d+)")
    local z = P:match("mag_from_y|(%d+)")
    local o = P:match("mag_target_x|(%d+)")
    local q = P:match("mag_target_y|(%d+)")
    if j then
        W.MagFindID = j
    end
    if Y then
        W.MagDelay = math.max(50, Y)
    end
    if X then
        W.MagFromWorld = (X:gsub("%s+", "")):upper()
    end
    if M then
        W.MagFromX = M
    end
    if z then
        W.MagFromY = z
    end
    if o then
        W.MagTargetX = o
    end
    if q then
        W.MagTargetY = q
    end
    local S = P:match("mag_drop_world|([^|\n]*)")
    local O = P:match("mag_drop_x|(%d+)")
    local V = P:match("mag_drop_y|(%d+)")
    if S then
        W.MagDropWorld = (S:gsub("%s+", "")):upper()
    end
    if O then
        W.MagDropX = O
    end
    if V then
        W.MagDropY = V
    end
    local e = P:match("m2m_take_world|([^|\n]*)")
    if e then
        W.MagM2MTakeWorld = (e:gsub("%s+", "")):upper()
    end
    local v = P:match("m2m_take_x|(%d+)")
    if v then
        W.MagM2MTakeX = v
    end
    local f = P:match("m2m_take_y|(%d+)")
    if f then
        W.MagM2MTakeY = f
    end
    local n = P:match("m2m_put_world|([^|\n]*)")
    if n then
        W.MagM2MPutWorld = (n:gsub("%s+", "")):upper()
    end
    local C = P:match("m2m_put_x|(%d+)")
    if C then
        W.MagM2MPutX = C
    end
    local D = P:match("m2m_put_y|(%d+)")
    if D then
        W.MagM2MPutY = D
    end
    W.SaveConfig(true)
end

-- (dead code: overridden by the later definition below)
function W.MagStart(P)
    if W.MagRunning then
        W.LocalChat("`c[WinProxy]: `4Magplant task already running! Stop it first.")
        return
    end
    local j = GetLocal()
    if not j or not j.pos then
        return
    end
    W.SaveConfig(true)
    local Y = tonumber(W.MagFindID)
    if not Y and ((P ~= "mag2mag" and P ~= "stock")) then
        W.LocalChat("`c[WinProxy]: `4Invalid Item ID!")
        return
    end
    local X = math.max(50, tonumber(W.MagDelay) or 150)
    local M, z
    local o, q = tonumber(W.MagTargetX) or 0, tonumber(W.MagTargetY) or 0
    if o > 0 and (q > 0 and ((P ~= "set" or W.MagSetMode == "wrench"))) then
        M, z = o, q
    else
        M = math.floor(j.pos.x / 32)
        z = math.floor(j.pos.y / 32 + 1)
    end
    W.MagX, W.MagY = M, z
    W.MagMode = P
    W.MagDone = false
    W.MagRunning = true
    W.MagSelectID = ((P == "find" or P == "add")) and Y or nil
    W.LocalChat("`c[WinProxy]: `9Magplant `2" .. (P .. (" `9started at `w" .. (M .. ("," .. z)))))
    RunThread(function()
        local j = "action|dialog_return\ndialog_name|magplant_edit\nx|"
        local function o(P, Y, X)
            return j .. (Y .. ("|\ny|" .. (X .. ("|\nbuttonClicked|" .. P))))
        end
        local function q()
            local P = GetWorld()
            return ((P and P.name)) and P.name:upper() or ""
        end
        local function S(P)
            local j = 0
            local Y, X = pcall(GetInventory)
            if Y and X then
                for Y, X in pairs(X) do
                    if X.id == P then
                        j = j + ((X.amount or 0))
                    end
                end
            end
            return j
        end
        local function O(P)
            if q() == P then
                return true
            end
            SendPacket(3, "action|join_request\nname|" .. (P .. "\ninvitedWorld|0"))
            local j = 0
            while W.MagRunning and (q() ~= P and j < 400) do
                Sleep(50)
                j = j + 1
            end
            if q() ~= P then
                return false
            end
            Sleep(2000)
            return true
        end
        local function V(P, j)
            local Y = GetLocal()
            local X = math.floor(Y.pos.x / 32)
            local M = math.floor(Y.pos.y / 32)
            while W.MagRunning and math.abs(j - M) > 6 do
                M = M + ((j - M > 0 and 6 or -6))
                FindPath(X, M)
                Sleep(400)
            end
            while W.MagRunning and math.abs(P - X) > 6 do
                X = X + ((P - X > 0 and 6 or -6))
                FindPath(X, M)
                Sleep(400)
            end
            FindPath(P, j)
            Sleep(400)
        end
        if P == "stock" then
            W.MagStockData = {}
            local P = {}
            for j = 59, 0, -1 do
                for Y = 0, 99, 1 do
                    local X = GetTile(Y, j)
                    if X and X.fg == 5638 then
                        table.insert(P, { x = Y; y = j })
                    end
                end
            end
            if #P == 0 then
                W.LocalChat("`c[WinProxy]: `4No Magplants found in this world!")
                W.MagRunning = false
                W.MagSelectID = nil
                W.VendFindID = "1656"
                W.VendDelay = 150
                W.VendFromWorld = ""
                W.VendFromX = "0"
                W.VendFromY = "0"
                W.VendTargetX = "0"
                W.VendTargetY = "0"
                W.VendDropWorld = ""
                W.VendDropX = "0"
                W.VendDropY = "0"
                W.VendSetMode = "walk"
                W.VendAutoWalk = false
                W.VendSelectingTarget = false
                W.VendSelectingFrom = false
                W.VendSelectingDrop = false
                W.VendRunning = false
                W.VendMode = ""
                W.VendDone = false
                W.VendX = 0
                W.VendY = 0
                W.VendM2MTakeWorld = ""
                W.VendM2MTakeX = "0"
                W.VendM2MTakeY = "0"
                W.VendM2MPutWorld = ""
                W.VendM2MPutX = "0"
                W.VendM2MPutY = "0"
                W.VendM2MAutoMove = false
                W.VendSelectingM2MTake = false
                W.VendSelectingM2MPut = false
                W.VendSelectID = nil
                W.VendPrice = "1"
                W.VendPriceMode = "peritem"
                return
            end
            W.LocalChat("`c[WinProxy]: `9Scanning `2" .. (#P .. " `9Magplants..."))
            local j = (#P > 10) and 300 or 500
            for Y, X in ipairs(P) do
                if not W.MagRunning then
                    break
                end
                W.MagDone = false
                W.MagWrench(X.x, X.y)
                local M = 0
                while not W.MagDone and (M < 1000 and W.MagRunning) do
                    Sleep(50)
                    M = M + 50
                end
                Sleep(j)
                W.LocalChat("`c[WinProxy]: `9Progress [`2" .. (Y .. ("`9/`2" .. (#P .. "`9] `9Magplants scanned."))))
            end
            if W.MagRunning then
                local j = {}
                for P, Y in pairs(W.MagStockData) do
                    table.insert(j, { id = P; name = Y.name, stock = Y.stock })
                end
                table.sort(j, function(P, j)
                    return P.stock > j.stock
                end)
                local Y = "add_label_with_icon|big|`wMags Scanned: `2" .. (#P .. " `wMagplant|left|5638|\n")
                Y = Y .. "add_spacer|small|\n"
                W.MagStockResult = {}
                table.insert(W.MagStockResult, "Scanned " .. (#P .. " Magplants."))
                for P, j in ipairs(j) do
                    local X = ((((tostring(j.stock)):reverse()):gsub("%d%d%d", "%1,")):reverse()):gsub("^,", "")
                    Y = Y .. ("add_label_with_icon|small|`w[ `c" .. (X .. (" `w] `7" .. (j.name .. ("|left|" .. (j.id .. "|\n"))))))
                    table.insert(W.MagStockResult, "[" .. (X .. ("] " .. (j.name .. (" (ID: " .. (j.id .. ")"))))))
                end
                Y = Y .. "end_dialog|magplant_stock|Close||\n"
                SendVariantList({ [0] = "OnDialogRequest"; [1] = Y })
                W.LocalChat("`c[WinProxy]: `2Magplant scanning complete!")
            end
        elseif P == "set" then
            local P = 0
            if W.MagSetMode == "wrench" then
                W.LocalChat("`c[WinProxy]: `9Wrench Mode active! Punch any Magplant to set its Item ID to `2" .. Y)
                while W.MagRunning do
                    Sleep(1000)
                end
            else
                while W.MagRunning and P < 5000 do
                    P = P + 1
                    local M = GetLocal()
                    if not M or not M.pos then
                        break
                    end
                    local z = math.floor(M.pos.x / 32)
                    local o = math.floor(M.pos.y / 32)
                    W.MagX, W.MagY = z, o + 1
                    W.MagWrench(z, o + 1)
                    Sleep(150)
                    SendPacket(2, j .. (z .. ("|\ny|" .. ((o + 1) .. ("|\nitemToSelect|" .. (Y .. "\n"))))))
                    Sleep(X)
                    FindPath(z + 1, o)
                    local q = 0
                    while W.MagRunning and q < 60 do
                        local P = GetLocal()
                        if P and (P.pos and math.floor(P.pos.x / 32) > z) then
                            break
                        end
                        Sleep(50)
                        q = q + 1
                    end
                    if q >= 60 then
                        break
                    end
                    Sleep(100)
                end
            end
        elseif P == "add" then
            local P = q()
            local j, e = M, z - 1
            local v = ((W.MagFromWorld and W.MagFromWorld ~= "")) and W.MagFromWorld:upper() or P
            local f, n = tonumber(W.MagFromX) or 0, tonumber(W.MagFromY) or 0
            local C = 0
            while W.MagRunning and C < 500 do
                C = C + 1
                if S(Y) == 0 then
                    if not O(v) then
                        W.LocalChat("`c[WinProxy]: `4Failed to join `w" .. v)
                        break
                    end
                    V(f, n)
                    Sleep(500)
                    local P = 0
                    for j, X in pairs(GetObjectList()) do
                        if not W.MagRunning then
                            break
                        end
                        if X.id == Y then
                            local j, Y = math.floor(X.pos.x / 32), math.floor(X.pos.y / 32)
                            if math.abs(j - f) <= 1 and math.abs(Y - n) <= 1 then
                                SendPacketRaw(false, { type = 11; value = X.oid, x = X.pos.x, y = X.pos.y })
                                P = P + 1
                                Sleep(150)
                            end
                        end
                    end
                    if P == 0 and S(Y) == 0 then
                        W.LocalChat("`c[WinProxy]: `9No more items at `w" .. (f .. ("," .. n)))
                        break
                    end
                end
                if not W.MagRunning then
                    break
                end
                Sleep(500)
                if not O(P) then
                    W.LocalChat("`c[WinProxy]: `4Failed to join `w" .. P)
                    break
                end
                V(j, e)
                Sleep(500)
                W.MagWrench(M, z)
                Sleep(1000)
                W.MagDone = false
                local q = 0
                while W.MagRunning and (not W.MagDone and (S(Y) > 0 and q < 200)) do
                    q = q + 1
                    SendPacket(2, o("additems", M, z))
                    Sleep(X)
                end
                if W.MagDone then
                    if W.MagAutoWalk then
                        local P = false
                        for j = M + 1, 99, 1 do
                            local Y = GetTile(j, z)
                            if Y and Y.fg == 5638 then
                                M = j
                                P = true
                                break
                            end
                        end
                        if P then
                            j = M
                            W.MagDone = false
                            W.LocalChat("`c[WinProxy]: `9Magplant Full! Moving to next at X: `2" .. M)
                        else
                            W.LocalChat("`c[WinProxy]: `4No more Magplants found to the right.")
                            break
                        end
                    else
                        break
                    end
                end
            end
        elseif P == "vend2vend" then
            local P = ((W.MagM2MTakeWorld and W.MagM2MTakeWorld ~= "")) and W.MagM2MTakeWorld:upper() or q()
            local j = ((W.MagM2MPutWorld and W.MagM2MPutWorld ~= "")) and W.MagM2MPutWorld:upper() or q()
            local Y, M = tonumber(W.MagM2MTakeX) or 0, tonumber(W.MagM2MTakeY) or 0
            local z, S = tonumber(W.MagM2MPutX) or 0, tonumber(W.MagM2MPutY) or 0
            local V = (P == j)
            while W.MagRunning do
                if not W.MagRunning then
                    break
                end
                if not V then
                    if not O(P) then
                        W.LocalChat("`c[WinProxy]: `4Failed to join `w" .. P)
                        break
                    end
                    Sleep(1000)
                end
                W.MagDone = false
                W.MagWrench(Y, M)
                Sleep(1000)
                if W.MagDone then
                    if W.MagM2MAutoMove then
                        local P = false
                        for j = Y + 1, 99, 1 do
                            local X = GetTile(j, M)
                            if X and X.fg == 5638 then
                                Y = j
                                P = true
                                break
                            end
                        end
                        if P then
                            W.MagDone = false
                            W.LocalChat("`c[WinProxy]: `9Take Magplant Empty! Moving Take to X: `2" .. Y)
                        else
                            W.LocalChat("`c[WinProxy]: `4No more Take Magplants found to the right.")
                            break
                        end
                    else
                        W.LocalChat("`c[WinProxy]: `4Take Magplant Empty!")
                        break
                    end
                end
                SendPacket(2, o("withdraw", Y, M))
                Sleep(X)
                if not W.MagRunning then
                    break
                end
                if not V then
                    if not O(j) then
                        W.LocalChat("`c[WinProxy]: `4Failed to join `w" .. j)
                        break
                    end
                    Sleep(1000)
                end
                W.MagDone = false
                W.MagWrench(z, S)
                Sleep(1000)
                W.MagDone = false
                SendPacket(2, o("additems", z, S))
                Sleep(X)
                if not W.MagDone then
                    Sleep(300)
                end
                if W.MagDone then
                    if W.MagM2MAutoMove then
                        local P = false
                        for j = z + 1, 99, 1 do
                            local Y = GetTile(j, S)
                            if Y and Y.fg == 5638 then
                                z = j
                                P = true
                                break
                            end
                        end
                        if P then
                            W.MagDone = false
                            W.LocalChat("`c[WinProxy]: `9Put Magplant Full! Moving Put to X: `2" .. z)
                        else
                            W.LocalChat("`c[WinProxy]: `4No more Put Magplants found to the right.")
                            break
                        end
                    else
                        W.LocalChat("`c[WinProxy]: `4Put Magplant Full!")
                        break
                    end
                end
            end
        else
            local j = q()
            local S = ((W.MagDropWorld and W.MagDropWorld ~= "")) and W.MagDropWorld:upper() or j
            local e, v = tonumber(W.MagDropX) or 0, tonumber(W.MagDropY) or 0
            local f = 0
            while W.MagRunning and f < 5000 do
                f = f + 1
                if P == "find" or P == "trash" then
                    if W.MagAutoWalk then
                        V(M, z - 1)
                        Sleep(300)
                    end
                    W.MagWrench(M, z)
                    Sleep(1000)
                    W.MagDone = false
                    if P == "find" then
                        SendPacket(2, "action|dialog_return\ndialog_name|item_search\n" .. (Y .. "|1"))
                        Sleep(X)
                        SendPacket(2, o("additems", M, z))
                    else
                        SendPacket(2, o("withdraw", M, z))
                        Sleep(X)
                        SendPacket(2, "action|dialog_return\ndialog_name|trash\nitem_trash|" .. (Y .. "|\nitem_count|250"))
                    end
                    Sleep(X)
                elseif P == "drop" then
                    if not O(j) then
                        break
                    end
                    if W.MagAutoWalk then
                        V(M, z - 1)
                        Sleep(300)
                    else
                        V(M, z)
                        Sleep(200)
                    end
                    W.MagWrench(M, z)
                    Sleep(1000)
                    W.MagDone = false
                    SendPacket(2, o("withdraw", M, z))
                    Sleep(X)
                    if e > 0 and v > 0 then
                        if not O(S) then
                            break
                        end
                        V(e, v)
                        Sleep(200)
                    end
                    SendPacket(2, "action|dialog_return\ndialog_name|drop\nitem_drop|" .. (Y .. "|\nitem_count|250\n"))
                    Sleep(X)
                end
                if W.MagDone then
                    if W.MagAutoWalk then
                        local P = false
                        for j = M + 1, 99, 1 do
                            local Y = GetTile(j, z)
                            if Y and Y.fg == 5638 then
                                M = j
                                P = true
                                break
                            end
                        end
                        if P then
                            W.MagDone = false
                            W.LocalChat("`c[WinProxy]: `9Moving to next Magplant (`w" .. (M .. ("," .. (z .. "`)"))))
                        else
                            W.LocalChat("`c[WinProxy]: `4No more Magplants found to the right.")
                            break
                        end
                    else
                        break
                    end
                end
            end
        end
        W.MagRunning = false
        W.MagSelectID = nil
        W.VendFindID = "1656"
        W.VendDelay = 150
        W.VendFromWorld = ""
        W.VendFromX = "0"
        W.VendFromY = "0"
        W.VendTargetX = "0"
        W.VendTargetY = "0"
        W.VendDropWorld = ""
        W.VendDropX = "0"
        W.VendDropY = "0"
        W.VendSetMode = "walk"
        W.VendAutoWalk = false
        W.VendSelectingTarget = false
        W.VendSelectingFrom = false
        W.VendSelectingDrop = false
        W.VendRunning = false
        W.VendMode = ""
        W.VendDone = false
        W.VendX = 0
        W.VendY = 0
        W.VendM2MTakeWorld = ""
        W.VendM2MTakeX = "0"
        W.VendM2MTakeY = "0"
        W.VendM2MPutWorld = ""
        W.VendM2MPutX = "0"
        W.VendM2MPutY = "0"
        W.VendM2MAutoMove = false
        W.VendSelectingM2MTake = false
        W.VendSelectingM2MPut = false
        W.VendSelectID = nil
        W.VendPrice = "1"
        W.VendPriceMode = "peritem"
        W.LocalChat("`c[WinProxy]: `2Magplant task finished (" .. (P .. ")"))
    end)
end

-- (dead code: overridden by the later definition below)
function W.VendStart(P)
    if W.VendRunning then
        W.LocalChat("`c[WinProxy]: `4Vending task already running! Stop it first.")
        return
    end
    local j = GetLocal()
    if not j or not j.pos then
        return
    end
    W.SaveConfig(true)
    local Y = tonumber(W.VendFindID)
    if not Y and P ~= "mag2mag" then
        W.LocalChat("`c[WinProxy]: `4Invalid Item ID!")
        return
    end
    local X = math.max(50, tonumber(W.VendDelay) or 150)
    local M, z
    local o, q = tonumber(W.VendTargetX) or 0, tonumber(W.VendTargetY) or 0
    if o > 0 and (q > 0 and ((P ~= "set" or W.VendSetMode == "wrench"))) then
        M, z = o, q
    else
        M = math.floor(j.pos.x / 32)
        z = math.floor(j.pos.y / 32)
    end
    W.VendX, W.VendY = M, z
    W.VendMode = P
    W.VendDone = false
    W.VendRunning = true
    W.VendSelectID = ((P == "find" or P == "add")) and Y or nil
    W.LocalChat("`c[WinProxy]: `9Vending `2" .. (P .. (" `9started at `w" .. (M .. ("," .. z)))))
    RunThread(function()
        local j = "action|dialog_return\ndialog_name|vend_edit\nx|"
        local function o(P, Y, X)
            return j .. (Y .. ("|\ny|" .. (X .. ("|\nbuttonClicked|" .. (P .. "\n\n")))))
        end
        local function q()
            local P = GetWorld()
            return ((P and P.name)) and P.name:upper() or ""
        end
        local function S(P)
            if q() == P then
                return true
            end
            SendPacket(3, "action|join_request\nname|" .. (P .. "\ninvitedWorld|0"))
            local j = 0
            while W.VendRunning and (q() ~= P and j < 400) do
                Sleep(50)
                j = j + 1
            end
            if q() ~= P then
                return false
            end
            Sleep(2000)
            return true
        end
        local function O(P, j)
            local Y = GetLocal()
            local X = math.floor(Y.pos.x / 32)
            local M = math.floor(Y.pos.y / 32)
            while W.VendRunning and math.abs(j - M) > 6 do
                M = M + ((j - M > 0 and 6 or -6))
                FindPath(X, M)
                Sleep(400)
            end
            while W.VendRunning and math.abs(P - X) > 6 do
                X = X + ((P - X > 0 and 6 or -6))
                FindPath(X, M)
                Sleep(400)
            end
            FindPath(P, j)
            Sleep(400)
        end
        if P == "set" then
            local P = 0
            if W.VendSetMode == "wrench" then
                W.LocalChat("`c[WinProxy]: `9Wrench Mode active! Punch any Vending Machine to set its Item ID to `2" .. Y)
                while W.VendRunning do
                    Sleep(1000)
                end
            else
                while W.VendRunning and P < 5000 do
                    P = P + 1
                    local j = GetLocal()
                    if not j or not j.pos then
                        break
                    end
                    local Y = math.floor(j.pos.x / 32)
                    local X = math.floor(j.pos.y / 32)
                    W.VendX, W.VendY = Y, X
                    W.MagWrench(Y, X)
                    Sleep(1000)
                    if W.VendAutoWalk then
                        local P = false
                        for j = Y + 1, 99, 1 do
                            local M = GetTile(j, X)
                            if M and ((M.fg == 2978 or M.fg == 3274 or M.fg == 6946)) then
                                Y = j
                                P = true
                                break
                            end
                        end
                        if P then
                            O(Y, X)
                            Sleep(300)
                        else
                            W.LocalChat("`c[WinProxy]: `4No more Vending Machines found to the right.")
                            break
                        end
                    else
                        break
                    end
                end
            end
        elseif P == "vend2vend" then
            local P, j = tonumber(W.VendM2MTakeX) or 0, tonumber(W.VendM2MTakeY) or 0
            local Y = ((W.VendM2MTakeWorld and W.VendM2MTakeWorld ~= "")) and W.VendM2MTakeWorld:upper() or q()
            local M, z = tonumber(W.VendM2MPutX) or 0, tonumber(W.VendM2MPutY) or 0
            local O = ((W.VendM2MPutWorld and W.VendM2MPutWorld ~= "")) and W.VendM2MPutWorld:upper() or q()
            local V = (Y == O)
            local e = q()
            if not V and not W.VendM2MAutoMove then
                W.LocalChat("`c[WinProxy]: `eNotice: Take and Put worlds differ. The bot will join each world automatically.")
            end
            while W.VendRunning do
                if not W.VendRunning then
                    break
                end
                if not V then
                    if not S(Y) then
                        W.LocalChat("`c[WinProxy]: `4Failed to join `w" .. Y)
                        break
                    end
                    Sleep(1000)
                end
                W.VendDone = false
                W.VendX, W.VendY = P, j
                W.MagWrench(P, j)
                Sleep(1000)
                while W.VendRunning and not W.VendDone do
                    SendPacket(2, o("pullstock", P, j))
                    Sleep(X)
                    if W.VendDone then
                        break
                    end
                    if not W.VendRunning then
                        break
                    end
                    if not V then
                        if not S(O) then
                            W.LocalChat("`c[WinProxy]: `4Failed to join `w" .. O)
                            break
                        end
                        Sleep(1000)
                    end
                    W.VendX, W.VendY = M, z
                    W.MagWrench(M, z)
                    Sleep(1000)
                    local Y = false
                    while W.VendRunning and not Y do
                        SendPacket(2, o("addstock", M, z))
                        Sleep(X)
                        if W.VendDone then
                            Y = true
                        end
                    end
                    if Y then
                        if W.VendM2MAutoMove then
                            local P = false
                            for j = M + 1, 99, 1 do
                                local Y = GetTile(j, z)
                                if Y and ((Y.fg == 2978 or Y.fg == 3274)) then
                                    M = j
                                    P = true
                                    break
                                end
                            end
                            if P then
                                W.LocalChat("`c[WinProxy]: `9Put Vending Full! Moving Put to X: `2" .. M)
                                W.VendDone = false
                                break
                            else
                                W.LocalChat("`c[WinProxy]: `4No more Put Vending Machines found to the right.")
                                W.VendRunning = false
                                break
                            end
                        else
                            W.LocalChat("`c[WinProxy]: `4Put Vending Machine Full!")
                            W.VendRunning = false
                            break
                        end
                    end
                end
                if W.VendDone and W.VendRunning then
                    if W.VendM2MAutoMove then
                        local Y = false
                        for X = P + 1, 99, 1 do
                            local M = GetTile(X, j)
                            if M and ((M.fg == 2978 or M.fg == 3274)) then
                                P = X
                                Y = true
                                break
                            end
                        end
                        if Y then
                            W.LocalChat("`c[WinProxy]: `9Take Vending Empty! Moving Take to X: `2" .. P)
                            W.VendDone = false
                        else
                            W.LocalChat("`c[WinProxy]: `4No more Take Vending Machines found to the right.")
                            break
                        end
                    else
                        W.LocalChat("`c[WinProxy]: `4Take Vending Machine Empty!")
                        break
                    end
                end
            end
        else
            local j = q()
            local V = ((W.VendDropWorld and W.VendDropWorld ~= "")) and W.VendDropWorld:upper() or j
            local e, v = tonumber(W.VendDropX) or 0, tonumber(W.VendDropY) or 0
            while W.VendRunning do
                if P == "find" or P == "trash" or P == "add" then
                    if W.VendAutoWalk then
                        O(M, z)
                        Sleep(300)
                    end
                    W.VendX, W.VendY = M, z
                    W.MagWrench(M, z)
                    Sleep(1000)
                    W.VendDone = false
                    while W.VendRunning and not W.VendDone do
                        if P == "find" then
                            SendPacket(2, "action|dialog_return\ndialog_name|item_search\n" .. (Y .. "|1"))
                            Sleep(X)
                            SendPacket(2, o("addstock", M, z))
                        elseif P == "add" then
                            local P = q()
                            local j = ((W.VendFromWorld and W.VendFromWorld ~= "")) and W.VendFromWorld:upper() or P
                            local V, e = tonumber(W.VendFromX) or 0, tonumber(W.VendFromY) or 0
                            local function v(P)
                                local j = 0
                                for Y, X in pairs(GetInventory()) do
                                    if X.id == P then
                                        j = j + X.amount
                                    end
                                end
                                return j
                            end
                            local f = 0
                            while W.VendRunning and (f < 500 and not W.VendDone) do
                                f = f + 1
                                if v(Y) == 0 then
                                    if not S(j) then
                                        W.LocalChat("`c[WinProxy]: `4Failed to join `w" .. j)
                                        break
                                    end
                                    O(V, e)
                                    Sleep(500)
                                    local P = 0
                                    for j, X in pairs(GetObjectList()) do
                                        if not W.VendRunning then
                                            break
                                        end
                                        if X.id == Y then
                                            local j, Y = math.floor(X.pos.x / 32), math.floor(X.pos.y / 32)
                                            if math.abs(j - V) <= 1 and math.abs(Y - e) <= 1 then
                                                SendPacketRaw(false, { type = 11; value = X.oid, x = X.pos.x, y = X.pos.y })
                                                P = P + 1
                                                Sleep(150)
                                            end
                                        end
                                    end
                                    if P == 0 and v(Y) == 0 then
                                        W.LocalChat("`c[WinProxy]: `9No more items at `w" .. (V .. ("," .. e)))
                                        break
                                    end
                                end
                                if not W.VendRunning then
                                    break
                                end
                                Sleep(500)
                                if not S(P) then
                                    W.LocalChat("`c[WinProxy]: `4Failed to join `w" .. P)
                                    break
                                end
                                if W.VendAutoWalk then
                                    O(M, z)
                                    Sleep(300)
                                end
                                W.VendX, W.VendY = M, z
                                W.MagWrench(M, z)
                                Sleep(1000)
                                local q = 0
                                while W.VendRunning and (not W.VendDone and (v(Y) > 0 and q < 200)) do
                                    q = q + 1
                                    SendPacket(2, o("addstock", M, z))
                                    Sleep(X)
                                end
                            end
                        else
                            SendPacket(2, o("pullstock", M, z))
                            Sleep(X)
                            SendPacket(2, "action|dialog_return\ndialog_name|trash\nitem_trash|" .. (Y .. "|\nitem_count|250"))
                        end
                        Sleep(X)
                    end
                elseif P == "drop" then
                    if not S(j) then
                        break
                    end
                    if W.VendAutoWalk then
                        O(M, z)
                        Sleep(300)
                    else
                        O(M, z)
                        Sleep(200)
                    end
                    W.VendX, W.VendY = M, z
                    W.MagWrench(M, z)
                    Sleep(1000)
                    W.VendDone = false
                    while W.VendRunning and not W.VendDone do
                        SendPacket(2, o("pullstock", M, z))
                        Sleep(X)
                        if e > 0 and v > 0 then
                            if not S(V) then
                                break
                            end
                            O(e, v)
                            Sleep(200)
                        end
                        SendPacket(2, "action|dialog_return\ndialog_name|drop\nitem_drop|" .. (Y .. "|\nitem_count|250\n"))
                        Sleep(X)
                        if e > 0 and v > 0 then
                            if not S(j) then
                                break
                            end
                            O(M, z)
                            Sleep(200)
                        end
                    end
                end
                if not W.VendRunning then
                    break
                end
                if W.VendDone then
                    if W.VendAutoWalk then
                        local P = false
                        for j = M + 1, 99, 1 do
                            local Y = GetTile(j, z)
                            if Y and ((Y.fg == 2978 or Y.fg == 3274)) then
                                M = j
                                P = true
                                break
                            end
                        end
                        if P then
                            W.VendDone = false
                            W.LocalChat("`c[WinProxy]: `9Moving to next Vending (`w" .. (M .. ("," .. (z .. "`)"))))
                        else
                            W.LocalChat("`c[WinProxy]: `4No more Vending Machines found to the right.")
                            break
                        end
                    else
                        break
                    end
                end
            end
        end
        W.VendRunning = false
        W.VendSelectID = nil
        W.VendPrice = "1"
        W.VendPriceMode = "peritem"
        W.LocalChat("`c[WinProxy]: `2Vending task finished (" .. (P .. ")"))
    end)
end

-- (active definition: overrides the earlier copy)
function W.VendParse(P)
    local j = P:match("vend_target_x|(%d+)")
    if j then
        W.VendTargetX = j
    end
    local Y = P:match("vend_target_y|(%d+)")
    if Y then
        W.VendTargetY = Y
    end
    local X = P:match("vend_find_id|(%d+)")
    if X then
        W.VendFindID = X
    end
    local M = P:match("vend_delay|(%d+)")
    if M then
        W.VendDelay = tonumber(M) or W.VendDelay
    end
    local z = P:match("vend_from_world|([^|\n\r]+)")
    if z then
        W.VendFromWorld = z
    end
    local o = P:match("vend_from_x|(%d+)")
    if o then
        W.VendFromX = o
    end
    local q = P:match("vend_from_y|(%d+)")
    if q then
        W.VendFromY = q
    end
    local S = P:match("vend_drop_world|([^|\n\r]+)")
    if S then
        W.VendDropWorld = S
    end
    local O = P:match("vend_drop_x|(%d+)")
    if O then
        W.VendDropX = O
    end
    local V = P:match("vend_drop_y|(%d+)")
    if V then
        W.VendDropY = V
    end
    local e = P:match("v2v_take_w|([^|\n\r]+)")
    if e then
        W.VendM2MTakeWorld = e
    end
    local v = P:match("v2v_take_x|(%d+)")
    if v then
        W.VendM2MTakeX = v
    end
    local f = P:match("v2v_take_y|(%d+)")
    if f then
        W.VendM2MTakeY = f
    end
    local n = P:match("v2v_put_w|([^|\n\r]+)")
    if n then
        W.VendM2MPutWorld = n
    end
    local C = P:match("v2v_put_x|(%d+)")
    if C then
        W.VendM2MPutX = C
    end
    local D = P:match("v2v_put_y|(%d+)")
    if D then
        W.VendM2MPutY = D
    end
    local i = P:match("vend_price|(%d+)")
    if i then
        W.VendPrice = i
    end
    local K = P:match("vend_price_mode|([^|\n\r]+)")
    if K then
        W.VendPriceMode = K
    end
    W.SaveConfig(true)
end

-- (active definition: overrides the earlier copy)
function W.MagParse(P)
    local j = P:match("mag_find_id|(-?%d+)")
    local Y = tonumber(P:match("mag_delay|(%d+)"))
    local X = P:match("mag_from_world|([^|\n]*)")
    local M = P:match("mag_from_x|(%d+)")
    local z = P:match("mag_from_y|(%d+)")
    local o = P:match("mag_target_x|(%d+)")
    local q = P:match("mag_target_y|(%d+)")
    if j then
        W.MagFindID = j
    end
    if Y then
        W.MagDelay = math.max(50, Y)
    end
    if X then
        W.MagFromWorld = (X:gsub("%s+", "")):upper()
    end
    if M then
        W.MagFromX = M
    end
    if z then
        W.MagFromY = z
    end
    if o then
        W.MagTargetX = o
    end
    if q then
        W.MagTargetY = q
    end
    local S = P:match("mag_drop_world|([^|\n]*)")
    local O = P:match("mag_drop_x|(%d+)")
    local V = P:match("mag_drop_y|(%d+)")
    if S then
        W.MagDropWorld = (S:gsub("%s+", "")):upper()
    end
    if O then
        W.MagDropX = O
    end
    if V then
        W.MagDropY = V
    end
    local e = P:match("m2m_take_world|([^|\n]*)")
    if e then
        W.MagM2MTakeWorld = (e:gsub("%s+", "")):upper()
    end
    local v = P:match("m2m_take_x|(%d+)")
    if v then
        W.MagM2MTakeX = v
    end
    local f = P:match("m2m_take_y|(%d+)")
    if f then
        W.MagM2MTakeY = f
    end
    local n = P:match("m2m_put_world|([^|\n]*)")
    if n then
        W.MagM2MPutWorld = (n:gsub("%s+", "")):upper()
    end
    local C = P:match("m2m_put_x|(%d+)")
    if C then
        W.MagM2MPutX = C
    end
    local D = P:match("m2m_put_y|(%d+)")
    if D then
        W.MagM2MPutY = D
    end
    W.SaveConfig(true)
end

-- (active definition: overrides the earlier copy)
function W.MagStart(P)
    if W.MagRunning then
        W.LocalChat("`c[WinProxy]: `4Magplant task already running! Stop it first.")
        return
    end
    local j = GetLocal()
    if not j or not j.pos then
        return
    end
    W.SaveConfig(true)
    local Y = tonumber(W.MagFindID)
    if not Y and ((P ~= "mag2mag" and P ~= "stock")) then
        W.LocalChat("`c[WinProxy]: `4Invalid Item ID!")
        return
    end
    local X = math.max(50, tonumber(W.MagDelay) or 150)
    local M, z
    local o, q = tonumber(W.MagTargetX) or 0, tonumber(W.MagTargetY) or 0
    if o > 0 and (q > 0 and ((P ~= "set" or W.MagSetMode == "wrench"))) then
        M, z = o, q
    else
        M = math.floor(j.pos.x / 32)
        z = math.floor(j.pos.y / 32 + 1)
    end
    W.MagX, W.MagY = M, z
    W.MagMode = P
    W.MagDone = false
    W.MagRunning = true
    W.MagSelectID = ((P == "find" or P == "add")) and Y or nil
    W.LocalChat("`c[WinProxy]: `9Magplant `2" .. (P .. (" `9started at `w" .. (M .. ("," .. z)))))
    RunThread(function()
        local j = "action|dialog_return\ndialog_name|magplant_edit\nx|"
        local function o(P, Y, X)
            return j .. (Y .. ("|\ny|" .. (X .. ("|\nbuttonClicked|" .. P))))
        end
        local function q()
            local P = GetWorld()
            return ((P and P.name)) and P.name:upper() or ""
        end
        local function S(P)
            local j = 0
            local Y, X = pcall(GetInventory)
            if Y and X then
                for Y, X in pairs(X) do
                    if X.id == P then
                        j = j + ((X.amount or 0))
                    end
                end
            end
            return j
        end
        local function O(P)
            if q() == P then
                return true
            end
            SendPacket(3, "action|join_request\nname|" .. (P .. "\ninvitedWorld|0"))
            local j = 0
            while W.MagRunning and (q() ~= P and j < 400) do
                Sleep(50)
                j = j + 1
            end
            if q() ~= P then
                return false
            end
            Sleep(2000)
            return true
        end
        local function V(P, j)
            local Y = GetLocal()
            local X = math.floor(Y.pos.x / 32)
            local M = math.floor(Y.pos.y / 32)
            while W.MagRunning and math.abs(j - M) > 6 do
                M = M + ((j - M > 0 and 6 or -6))
                FindPath(X, M)
                Sleep(400)
            end
            while W.MagRunning and math.abs(P - X) > 6 do
                X = X + ((P - X > 0 and 6 or -6))
                FindPath(X, M)
                Sleep(400)
            end
            FindPath(P, j)
            Sleep(400)
        end
        if P == "stock" then
            W.MagStockData = {}
            local P = {}
            for j = 59, 0, -1 do
                for Y = 0, 99, 1 do
                    local X = GetTile(Y, j)
                    if X and X.fg == 5638 then
                        table.insert(P, { x = Y; y = j })
                    end
                end
            end
            if #P == 0 then
                W.LocalChat("`c[WinProxy]: `4No Magplants found in this world!")
                W.MagRunning = false
                W.MagSelectID = nil
                W.VendFindID = "1656"
                W.VendDelay = 150
                W.VendFromWorld = ""
                W.VendFromX = "0"
                W.VendFromY = "0"
                W.VendTargetX = "0"
                W.VendTargetY = "0"
                W.VendDropWorld = ""
                W.VendDropX = "0"
                W.VendDropY = "0"
                W.VendSetMode = "walk"
                W.VendAutoWalk = false
                W.VendSelectingTarget = false
                W.VendSelectingFrom = false
                W.VendSelectingDrop = false
                W.VendRunning = false
                W.VendMode = ""
                W.VendDone = false
                W.VendX = 0
                W.VendY = 0
                W.VendM2MTakeWorld = ""
                W.VendM2MTakeX = "0"
                W.VendM2MTakeY = "0"
                W.VendM2MPutWorld = ""
                W.VendM2MPutX = "0"
                W.VendM2MPutY = "0"
                W.VendM2MAutoMove = false
                W.VendSelectingM2MTake = false
                W.VendSelectingM2MPut = false
                W.VendSelectID = nil
                W.VendPrice = "1"
                W.VendPriceMode = "peritem"
                return
            end
            W.LocalChat("`c[WinProxy]: `9Scanning `2" .. (#P .. " `9Magplants..."))
            local j = (#P > 10) and 300 or 500
            for Y, X in ipairs(P) do
                if not W.MagRunning then
                    break
                end
                W.MagDone = false
                W.MagWrench(X.x, X.y)
                local M = 0
                while not W.MagDone and (M < 1000 and W.MagRunning) do
                    Sleep(50)
                    M = M + 50
                end
                Sleep(j)
                W.LocalChat("`c[WinProxy]: `9Progress [`2" .. (Y .. ("`9/`2" .. (#P .. "`9] `9Magplants scanned."))))
            end
            if W.MagRunning then
                local j = {}
                for P, Y in pairs(W.MagStockData) do
                    table.insert(j, { id = P, name = Y.name, stock = Y.stock })
                end
                table.sort(j, function(P, j)
                    return P.stock > j.stock
                end)
                local Y = "add_label_with_icon|big|`wMags Scanned: `2" .. (#P .. " `wMagplant|left|5638|\n")
                Y = Y .. "add_spacer|small|\n"
                W.MagStockResult = {}
                table.insert(W.MagStockResult, "Scanned " .. (#P .. " Magplants."))
                for P, j in ipairs(j) do
                    local X = ((((tostring(j.stock)):reverse()):gsub("%d%d%d", "%1,")):reverse()):gsub("^,", "")
                    Y = Y .. ("add_label_with_icon|small|`w[ `c" .. (X .. (" `w] `7" .. (j.name .. ("|left|" .. (j.id .. "|\n"))))))
                    table.insert(W.MagStockResult, "[" .. (X .. ("] " .. (j.name .. (" (ID: " .. (j.id .. ")"))))))
                end
                Y = Y .. "end_dialog|magplant_stock|Close||\n"
                SendVariantList({ [0] = "OnDialogRequest"; [1] = Y })
                W.LocalChat("`c[WinProxy]: `2Magplant scanning complete!")
            end
        elseif P == "set" then
            local P = 0
            if W.MagSetMode == "wrench" then
                W.LocalChat("`c[WinProxy]: `9Wrench Mode active! Punch any Magplant to set its Item ID to `2" .. Y)
                while W.MagRunning do
                    Sleep(1000)
                end
            else
                while W.MagRunning and P < 5000 do
                    P = P + 1
                    local M = GetLocal()
                    if not M or not M.pos then
                        break
                    end
                    local z = math.floor(M.pos.x / 32)
                    local o = math.floor(M.pos.y / 32)
                    W.MagX, W.MagY = z, o + 1
                    W.MagWrench(z, o + 1)
                    Sleep(150)
                    SendPacket(2, j .. (z .. ("|\ny|" .. ((o + 1) .. ("|\nitemToSelect|" .. (Y .. "\n"))))))
                    Sleep(X)
                    FindPath(z + 1, o)
                    local q = 0
                    while W.MagRunning and q < 60 do
                        local P = GetLocal()
                        if P and (P.pos and math.floor(P.pos.x / 32) > z) then
                            break
                        end
                        Sleep(50)
                        q = q + 1
                    end
                    if q >= 60 then
                        break
                    end
                    Sleep(100)
                end
            end
        elseif P == "add" then
            local P = q()
            local j, e = M, z - 1
            local v = ((W.MagFromWorld and W.MagFromWorld ~= "")) and W.MagFromWorld:upper() or P
            local f, n = tonumber(W.MagFromX) or 0, tonumber(W.MagFromY) or 0
            local C = 0
            while W.MagRunning and C < 500 do
                C = C + 1
                if S(Y) == 0 then
                    if not O(v) then
                        W.LocalChat("`c[WinProxy]: `4Failed to join `w" .. v)
                        break
                    end
                    V(f, n)
                    Sleep(500)
                    local P = 0
                    for j, X in pairs(GetObjectList()) do
                        if not W.MagRunning then
                            break
                        end
                        if X.id == Y then
                            local j, Y = math.floor(X.pos.x / 32), math.floor(X.pos.y / 32)
                            if math.abs(j - f) <= 1 and math.abs(Y - n) <= 1 then
                                SendPacketRaw(false, { type = 11, value = X.oid, x = X.pos.x; y = X.pos.y })
                                P = P + 1
                                Sleep(150)
                            end
                        end
                    end
                    if P == 0 and S(Y) == 0 then
                        W.LocalChat("`c[WinProxy]: `9No more items at `w" .. (f .. ("," .. n)))
                        break
                    end
                end
                if not W.MagRunning then
                    break
                end
                Sleep(500)
                if not O(P) then
                    W.LocalChat("`c[WinProxy]: `4Failed to join `w" .. P)
                    break
                end
                V(j, e)
                Sleep(500)
                W.MagWrench(M, z)
                Sleep(1000)
                W.MagDone = false
                local q = 0
                while W.MagRunning and (not W.MagDone and (S(Y) > 0 and q < 200)) do
                    q = q + 1
                    SendPacket(2, o("additems", M, z))
                    Sleep(X)
                end
                if W.MagDone then
                    if W.MagAutoWalk then
                        local P = false
                        for j = M + 1, 99, 1 do
                            local Y = GetTile(j, z)
                            if Y and Y.fg == 5638 then
                                M = j
                                P = true
                                break
                            end
                        end
                        if P then
                            j = M
                            W.MagDone = false
                            W.LocalChat("`c[WinProxy]: `9Magplant Full! Moving to next at X: `2" .. M)
                        else
                            W.LocalChat("`c[WinProxy]: `4No more Magplants found to the right.")
                            break
                        end
                    else
                        break
                    end
                end
            end
        elseif P == "vend2vend" then
            local P = ((W.MagM2MTakeWorld and W.MagM2MTakeWorld ~= "")) and W.MagM2MTakeWorld:upper() or q()
            local j = ((W.MagM2MPutWorld and W.MagM2MPutWorld ~= "")) and W.MagM2MPutWorld:upper() or q()
            local Y, M = tonumber(W.MagM2MTakeX) or 0, tonumber(W.MagM2MTakeY) or 0
            local z, S = tonumber(W.MagM2MPutX) or 0, tonumber(W.MagM2MPutY) or 0
            local V = (P == j)
            while W.MagRunning do
                if not W.MagRunning then
                    break
                end
                if not V then
                    if not O(P) then
                        W.LocalChat("`c[WinProxy]: `4Failed to join `w" .. P)
                        break
                    end
                    Sleep(1000)
                end
                W.MagDone = false
                W.MagWrench(Y, M)
                Sleep(1000)
                if W.MagDone then
                    if W.MagM2MAutoMove then
                        local P = false
                        for j = Y + 1, 99, 1 do
                            local X = GetTile(j, M)
                            if X and X.fg == 5638 then
                                Y = j
                                P = true
                                break
                            end
                        end
                        if P then
                            W.MagDone = false
                            W.LocalChat("`c[WinProxy]: `9Take Magplant Empty! Moving Take to X: `2" .. Y)
                        else
                            W.LocalChat("`c[WinProxy]: `4No more Take Magplants found to the right.")
                            break
                        end
                    else
                        W.LocalChat("`c[WinProxy]: `4Take Magplant Empty!")
                        break
                    end
                end
                SendPacket(2, o("withdraw", Y, M))
                Sleep(X)
                if not W.MagRunning then
                    break
                end
                if not V then
                    if not O(j) then
                        W.LocalChat("`c[WinProxy]: `4Failed to join `w" .. j)
                        break
                    end
                    Sleep(1000)
                end
                W.MagDone = false
                W.MagWrench(z, S)
                Sleep(1000)
                W.MagDone = false
                SendPacket(2, o("additems", z, S))
                Sleep(X)
                if not W.MagDone then
                    Sleep(300)
                end
                if W.MagDone then
                    if W.MagM2MAutoMove then
                        local P = false
                        for j = z + 1, 99, 1 do
                            local Y = GetTile(j, S)
                            if Y and Y.fg == 5638 then
                                z = j
                                P = true
                                break
                            end
                        end
                        if P then
                            W.MagDone = false
                            W.LocalChat("`c[WinProxy]: `9Put Magplant Full! Moving Put to X: `2" .. z)
                        else
                            W.LocalChat("`c[WinProxy]: `4No more Put Magplants found to the right.")
                            break
                        end
                    else
                        W.LocalChat("`c[WinProxy]: `4Put Magplant Full!")
                        break
                    end
                end
            end
        else
            local j = q()
            local S = ((W.MagDropWorld and W.MagDropWorld ~= "")) and W.MagDropWorld:upper() or j
            local e, v = tonumber(W.MagDropX) or 0, tonumber(W.MagDropY) or 0
            local f = 0
            while W.MagRunning and f < 5000 do
                f = f + 1
                if P == "find" or P == "trash" then
                    if W.MagAutoWalk then
                        V(M, z - 1)
                        Sleep(300)
                    end
                    W.MagWrench(M, z)
                    Sleep(1000)
                    W.MagDone = false
                    if P == "find" then
                        SendPacket(2, "action|dialog_return\ndialog_name|item_search\n" .. (Y .. "|1"))
                        Sleep(X)
                        SendPacket(2, o("additems", M, z))
                    else
                        SendPacket(2, o("withdraw", M, z))
                        Sleep(X)
                        SendPacket(2, "action|dialog_return\ndialog_name|trash\nitem_trash|" .. (Y .. "|\nitem_count|250"))
                    end
                    Sleep(X)
                elseif P == "drop" then
                    if not O(j) then
                        break
                    end
                    if W.MagAutoWalk then
                        V(M, z - 1)
                        Sleep(300)
                    else
                        V(M, z)
                        Sleep(200)
                    end
                    W.MagWrench(M, z)
                    Sleep(1000)
                    W.MagDone = false
                    SendPacket(2, o("withdraw", M, z))
                    Sleep(X)
                    if e > 0 and v > 0 then
                        if not O(S) then
                            break
                        end
                        V(e, v)
                        Sleep(200)
                    end
                    SendPacket(2, "action|dialog_return\ndialog_name|drop\nitem_drop|" .. (Y .. "|\nitem_count|250\n"))
                    Sleep(X)
                end
                if W.MagDone then
                    if W.MagAutoWalk then
                        local P = false
                        for j = M + 1, 99, 1 do
                            local Y = GetTile(j, z)
                            if Y and Y.fg == 5638 then
                                M = j
                                P = true
                                break
                            end
                        end
                        if P then
                            W.MagDone = false
                            W.LocalChat("`c[WinProxy]: `9Moving to next Magplant (`w" .. (M .. ("," .. (z .. "`)"))))
                        else
                            W.LocalChat("`c[WinProxy]: `4No more Magplants found to the right.")
                            break
                        end
                    else
                        break
                    end
                end
            end
        end
        W.MagRunning = false
        W.MagSelectID = nil
        W.VendFindID = "1656"
        W.VendDelay = 150
        W.VendFromWorld = ""
        W.VendFromX = "0"
        W.VendFromY = "0"
        W.VendTargetX = "0"
        W.VendTargetY = "0"
        W.VendDropWorld = ""
        W.VendDropX = "0"
        W.VendDropY = "0"
        W.VendSetMode = "walk"
        W.VendAutoWalk = false
        W.VendSelectingTarget = false
        W.VendSelectingFrom = false
        W.VendSelectingDrop = false
        W.VendRunning = false
        W.VendMode = ""
        W.VendDone = false
        W.VendX = 0
        W.VendY = 0
        W.VendM2MTakeWorld = ""
        W.VendM2MTakeX = "0"
        W.VendM2MTakeY = "0"
        W.VendM2MPutWorld = ""
        W.VendM2MPutX = "0"
        W.VendM2MPutY = "0"
        W.VendM2MAutoMove = false
        W.VendSelectingM2MTake = false
        W.VendSelectingM2MPut = false
        W.VendSelectID = nil
        W.VendPrice = "1"
        W.VendPriceMode = "peritem"
        W.LocalChat("`c[WinProxy]: `2Magplant task finished (" .. (P .. ")"))
    end)
end

-- (active definition: overrides the earlier copy)
function W.VendStart(P)
    if W.VendRunning then
        W.LocalChat("`c[WinProxy]: `4Vending task already running! Stop it first.")
        return
    end
    local j = GetLocal()
    if not j or not j.pos then
        return
    end
    W.SaveConfig(true)
    local Y = tonumber(W.VendFindID)
    if not Y and P ~= "mag2mag" then
        W.LocalChat("`c[WinProxy]: `4Invalid Item ID!")
        return
    end
    local X = math.max(50, tonumber(W.VendDelay) or 150)
    local M, z
    local o, q = tonumber(W.VendTargetX) or 0, tonumber(W.VendTargetY) or 0
    if o > 0 and (q > 0 and ((P ~= "set" or W.VendSetMode == "wrench"))) then
        M, z = o, q
    else
        M = math.floor(j.pos.x / 32)
        z = math.floor(j.pos.y / 32)
    end
    W.VendX, W.VendY = M, z
    W.VendMode = P
    W.VendDone = false
    W.VendRunning = true
    W.VendSelectID = ((P == "find" or P == "add")) and Y or nil
    W.LocalChat("`c[WinProxy]: `9Vending `2" .. (P .. (" `9started at `w" .. (M .. ("," .. z)))))
    RunThread(function()
        local j = "action|dialog_return\ndialog_name|vend_edit\nx|"
        local function o(P, Y, X)
            return j .. (Y .. ("|\ny|" .. (X .. ("|\nbuttonClicked|" .. (P .. "\n")))))
        end
        local function q()
            local P = GetWorld()
            return ((P and P.name)) and P.name:upper() or ""
        end
        local function S(P)
            local j = 0
            local Y, X = pcall(GetInventory)
            if Y and X then
                for Y, X in pairs(X) do
                    if X.id == P then
                        j = j + ((X.amount or 0))
                    end
                end
            end
            return j
        end
        local function O(P)
            if q() == P then
                return true
            end
            SendPacket(3, "action|join_request\nname|" .. (P .. "\ninvitedWorld|0"))
            local j = 0
            while W.VendRunning and (q() ~= P and j < 400) do
                Sleep(50)
                j = j + 1
            end
            if q() ~= P then
                return false
            end
            Sleep(2000)
            return true
        end
        local function V(P, j)
            local Y = GetLocal()
            local X = math.floor(Y.pos.x / 32)
            local M = math.floor(Y.pos.y / 32)
            while W.VendRunning and math.abs(j - M) > 6 do
                M = M + ((j - M > 0 and 6 or -6))
                FindPath(X, M)
                Sleep(400)
            end
            while W.VendRunning and math.abs(P - X) > 6 do
                X = X + ((P - X > 0 and 6 or -6))
                FindPath(X, M)
                Sleep(400)
            end
            FindPath(P, j)
            Sleep(400)
        end
        if P == "set" then
            local P = 0
            if W.VendSetMode == "wrench" then
                W.LocalChat("`c[WinProxy]: `9Wrench Mode active! Punch any Vending Machine to set its Item ID to `2" .. Y)
                while W.VendRunning do
                    Sleep(1000)
                end
            else
                while W.VendRunning and P < 5000 do
                    P = P + 1
                    local j = GetLocal()
                    if not j or not j.pos then
                        break
                    end
                    local Y = math.floor(j.pos.x / 32)
                    local X = math.floor(j.pos.y / 32)
                    W.VendX, W.VendY = Y, X
                    W.MagWrench(Y, X)
                    Sleep(1000)
                    if W.VendAutoWalk then
                        local P = false
                        for j = Y + 1, 99, 1 do
                            local M = GetTile(j, X)
                            if M and ((M.fg == 2978 or M.fg == 3274 or M.fg == 6946)) then
                                Y = j
                                P = true
                                break
                            end
                        end
                        if P then
                            V(Y, X)
                            Sleep(300)
                        else
                            W.LocalChat("`c[WinProxy]: `4No more Vending Machines found to the right.")
                            break
                        end
                    else
                        break
                    end
                end
            end
        elseif P == "vend2vend" then
            local P, j = tonumber(W.VendM2MTakeX) or 0, tonumber(W.VendM2MTakeY) or 0
            local Y = ((W.VendM2MTakeWorld and W.VendM2MTakeWorld ~= "")) and W.VendM2MTakeWorld:upper() or q()
            local M, z = tonumber(W.VendM2MPutX) or 0, tonumber(W.VendM2MPutY) or 0
            local S = ((W.VendM2MPutWorld and W.VendM2MPutWorld ~= "")) and W.VendM2MPutWorld:upper() or q()
            local e = (Y == S)
            local v = q()
            if not e and not W.VendM2MAutoMove then
                W.LocalChat("`c[WinProxy]: `eNotice: Take and Put worlds differ. The bot will join each world automatically.")
            end
            while W.VendRunning do
                if not W.VendRunning then
                    break
                end
                if not e then
                    if not O(Y) then
                        W.LocalChat("`c[WinProxy]: `4Failed to join `w" .. Y)
                        break
                    end
                    Sleep(1000)
                end
                V(P, j)
                Sleep(300)
                W.VendDone = false
                W.MagWrench(P, j)
                Sleep(1000)
                if W.VendDone then
                    if W.VendM2MAutoMove then
                        local Y = false
                        for X = P + 1, 99, 1 do
                            local M = GetTile(X, j)
                            if M and ((M.fg == 2978 or M.fg == 3274)) then
                                P = X
                                Y = true
                                break
                            end
                        end
                        if Y then
                            W.VendDone = false
                            W.LocalChat("`c[WinProxy]: `9Take Vending Empty! Moving Take to X: `2" .. P)
                        else
                            W.LocalChat("`c[WinProxy]: `4No more Take Vending Machines found to the right.")
                            break
                        end
                    else
                        W.LocalChat("`c[WinProxy]: `4Take Vending Machine Empty!")
                        break
                    end
                end
                SendPacket(2, o("pullstock", P, j))
                Sleep(X)
                if not W.VendRunning then
                    break
                end
                if not e then
                    if not O(S) then
                        W.LocalChat("`c[WinProxy]: `4Failed to join `w" .. S)
                        break
                    end
                    Sleep(1000)
                end
                V(M, z)
                Sleep(300)
                W.VendDone = false
                W.MagWrench(M, z)
                Sleep(1000)
                W.VendDone = false
                SendPacket(2, o("addstock", M, z))
                Sleep(X)
                if not W.VendDone then
                    Sleep(300)
                end
                if W.VendDone then
                    if W.VendM2MAutoMove then
                        local P = false
                        for j = M + 1, 99, 1 do
                            local Y = GetTile(j, z)
                            if Y and ((Y.fg == 2978 or Y.fg == 3274)) then
                                M = j
                                P = true
                                break
                            end
                        end
                        if P then
                            W.VendDone = false
                            W.LocalChat("`c[WinProxy]: `9Put Vending Full! Moving Put to X: `2" .. M)
                        else
                            W.LocalChat("`c[WinProxy]: `4No more Put Vending Machines found to the right.")
                            break
                        end
                    else
                        W.LocalChat("`c[WinProxy]: `4Put Vending Machine Full!")
                        break
                    end
                end
            end
        else
            local j = q()
            local e = ((W.VendDropWorld and W.VendDropWorld ~= "")) and W.VendDropWorld:upper() or j
            local v, f = tonumber(W.VendDropX) or 0, tonumber(W.VendDropY) or 0
            local n = 0
            while W.VendRunning and n < 5000 do
                n = n + 1
                if P == "find" or P == "add" then
                    if P == "add" and S(Y) == 0 then
                        local P = q()
                        local j = ((W.VendFromWorld and W.VendFromWorld ~= "")) and W.VendFromWorld:upper() or P
                        local X, M = tonumber(W.VendFromX) or 0, tonumber(W.VendFromY) or 0
                        if not O(j) then
                            W.LocalChat("`c[WinProxy]: `4Failed to join `w" .. j)
                            break
                        end
                        V(X, M)
                        Sleep(500)
                        local z = 0
                        for P, j in pairs(GetObjectList()) do
                            if not W.VendRunning then
                                break
                            end
                            if j.id == Y then
                                local P, Y = math.floor(j.pos.x / 32), math.floor(j.pos.y / 32)
                                if math.abs(P - X) <= 1 and math.abs(Y - M) <= 1 then
                                    SendPacketRaw(false, { type = 11, value = j.oid, x = j.pos.x; y = j.pos.y })
                                    z = z + 1
                                    Sleep(150)
                                end
                            end
                        end
                        if z == 0 and S(Y) == 0 then
                            W.LocalChat("`c[WinProxy]: `4No more items at `w" .. (X .. ("," .. M)))
                            break
                        end
                        Sleep(500)
                        if not O(P) then
                            W.LocalChat("`c[WinProxy]: `4Failed to join `w" .. P)
                            break
                        end
                    end
                    if W.VendAutoWalk then
                        V(M, z)
                        Sleep(300)
                    end
                    W.VendDone = false
                    W.MagWrench(M, z)
                    Sleep(1000)
                    local j = 0
                    while W.VendRunning and (not W.VendDone and j < 200) do
                        j = j + 1
                        if P == "find" then
                            SendPacket(2, "action|dialog_return\ndialog_name|item_search\n" .. (Y .. "|1"))
                            Sleep(X)
                        end
                        SendPacket(2, o("addstock", M, z))
                        Sleep(X)
                        if S(Y) == 0 then
                            break
                        end
                    end
                elseif P == "trash" then
                    if W.VendAutoWalk then
                        V(M, z)
                        Sleep(300)
                    end
                    W.VendDone = false
                    W.MagWrench(M, z)
                    Sleep(1000)
                    local P = 0
                    local j = 0
                    while W.VendRunning and (not W.VendDone and P < 200) do
                        P = P + 1
                        local q = S(Y)
                        SendPacket(2, o("pullstock", M, z))
                        Sleep(X)
                        local O = S(Y)
                        if O > q then
                            j = 0
                            SendPacket(2, "action|dialog_return\ndialog_name|trash\nitem_trash|" .. (Y .. "|\nitem_count|250"))
                            Sleep(X)
                        else
                            j = j + 1
                            if j >= 3 then
                                W.VendDone = true
                                break
                            end
                        end
                    end
                elseif P == "drop" then
                    if not O(j) then
                        break
                    end
                    if W.VendAutoWalk then
                        V(M, z)
                        Sleep(300)
                    else
                        V(M, z)
                        Sleep(200)
                    end
                    W.VendDone = false
                    W.MagWrench(M, z)
                    Sleep(1000)
                    local P = 0
                    local q = 0
                    while W.VendRunning and (not W.VendDone and P < 200) do
                        P = P + 1
                        local j = S(Y)
                        SendPacket(2, o("pullstock", M, z))
                        Sleep(X)
                        local O = S(Y)
                        if O > j then
                            q = 0
                        else
                            q = q + 1
                            if q >= 3 then
                                W.VendDone = true
                                break
                            end
                        end
                        if O >= 200 then
                            break
                        end
                    end
                    if S(Y) > 0 then
                        if v > 0 and f > 0 then
                            if not O(e) then
                                break
                            end
                            V(v, f)
                            Sleep(200)
                        end
                        SendPacket(2, "action|dialog_return\ndialog_name|drop\nitem_drop|" .. (Y .. ("|\nitem_count|" .. (S(Y) .. "\n"))))
                        Sleep(X)
                    end
                end
                if W.VendDone then
                    if W.VendAutoWalk then
                        local P = false
                        for j = M + 1, 99, 1 do
                            local Y = GetTile(j, z)
                            if Y and ((Y.fg == 2978 or Y.fg == 3274)) then
                                M = j
                                P = true
                                break
                            end
                        end
                        if P then
                            W.VendDone = false
                            W.LocalChat("`c[WinProxy]: `9Moving to next Vending (`w" .. (M .. ("," .. (z .. "`)"))))
                        else
                            W.LocalChat("`c[WinProxy]: `4No more Vending Machines found to the right.")
                            break
                        end
                    else
                        break
                    end
                end
            end
        end
        W.VendRunning = false
        W.VendSelectID = nil
        W.VendPrice = "1"
        W.VendPriceMode = "peritem"
        W.LocalChat("`c[WinProxy]: `2Vending task finished (" .. (P .. ")"))
    end)
end

-- ========================================================================
-- SECTION 13: More dialogs (Magplant, Vending, titles, logs, settings, alias, info)
-- ========================================================================

function W.ShowMagplantDialog(P)
    W.MagCurrentMenu = P or "main"
    local j = W.MagRunning and ("`2Running `w(" .. (tostring(W.MagMode) .. ")")) or "`4Idle"
    local Y = "add_label_with_icon|big|`9Magplant Tools|left|" .. (W.GetIcon("MAGPLANT 5000", 5638) .. ("|\nadd_textbox|`9Status : " .. (j .. "|\n")))
    Y = Y .. "add_small_font_button|btn_mag_stop|`4Stop Current Task|noflags|0|0|\nadd_spacer|small|\n"
    if W.MagCurrentMenu == "main" then
        Y = Y .. "text_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjj|\nadd_button_with_icon|btn_mag_menu_set|`2Set Magplant|staticYellowFrame|5638||\nadd_button_with_icon|btn_mag_menu_find|`2Find & Add|staticYellowFrame|5638||\nadd_button_with_icon|btn_mag_menu_take|`2Take & Add|staticYellowFrame|5638||\nadd_button_with_icon|btn_mag_menu_ret_drop|`2Ret & Drop|staticYellowFrame|5638||\nadd_button_with_icon|btn_mag_menu_ret_trash|`2Ret & Trash|staticYellowFrame|5638||\nadd_button_with_icon|btn_mag_menu_mag2mag|`2Mag to Mag|staticYellowFrame|5638||\nadd_button_with_icon|btn_mag_stock|`2Check Stock|staticYellowFrame|5638||\ntext_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjj|\nadd_button_with_icon||END_LIST|noflags|0||\ntext_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjj|\nadd_button|menuu|Back|noflags|0|0|\nend_dialog|close_ui|Close||\n"
    elseif W.MagCurrentMenu == "find" then
        Y = Y .. ("add_smalltext|`wMagplant X, Y overrides standing position (0 = use standing tile).|\nadd_text_input|mag_target_x|Magplant X:|" .. (W.MagTargetX .. ("|4|\nadd_text_input|mag_target_y|Magplant Y:|" .. (W.MagTargetY .. ("|4|\nadd_small_font_button|btn_mag_target_touch|`9Set Target Magplant by Touch|noflags|0|0|\nadd_spacer|small|\nadd_text_input|mag_find_id|Item ID:|" .. (W.MagFindID .. ("|8|\nadd_text_input|mag_delay|Delay (ms):|" .. (W.MagDelay .. "|5|\nadd_spacer|small|\nadd_button|btn_mag_find|`2Start Find & Add|noflags|0|0|\nadd_button|btn_mag|Back|noflags|0|0|\nend_dialog|close_ui|Close||\n"))))))))
    elseif W.MagCurrentMenu == "take" then
        Y = Y .. ("add_smalltext|`wMagplant X, Y overrides standing position (0 = use standing tile).|\nadd_text_input|mag_target_x|Magplant X:|" .. (W.MagTargetX .. ("|4|\nadd_text_input|mag_target_y|Magplant Y:|" .. (W.MagTargetY .. ("|4|\nadd_small_font_button|btn_mag_target_touch|`9Set Target Magplant by Touch|noflags|0|0|\nadd_spacer|small|\nadd_text_input|mag_find_id|Item ID:|" .. (W.MagFindID .. ("|8|\nadd_text_input|mag_delay|Delay (ms):|" .. (W.MagDelay .. ("|5|\nadd_spacer|small|\nadd_smalltext|`9Take & Add: pick up dropped items from (World, X, Y). Empty world = current world.|\nadd_text_input|mag_from_world|From World:|" .. (((W.MagFromWorld or "")) .. ("|24|\nadd_text_input|mag_from_x|From X:|" .. (W.MagFromX .. ("|4|\nadd_text_input|mag_from_y|From Y:|" .. (W.MagFromY .. "|4|\nadd_small_font_button|btn_mag_from_touch|`9Set Take & Add X,Y by Touch|noflags|0|0|\nadd_spacer|small|\nadd_button|btn_mag_add|`2Start Take & Add|noflags|0|0|\nadd_button|btn_mag|Back|noflags|0|0|\nend_dialog|close_ui|Close||\n"))))))))))))))
    elseif W.MagCurrentMenu == "ret_drop" then
        Y = Y .. ("add_smalltext|`wMagplant X, Y overrides standing position (0 = use standing tile).|\nadd_text_input|mag_target_x|Magplant X:|" .. (W.MagTargetX .. ("|4|\nadd_text_input|mag_target_y|Magplant Y:|" .. (W.MagTargetY .. ("|4|\nadd_small_font_button|btn_mag_target_touch|`9Set Target Magplant by Touch|noflags|0|0|\nadd_spacer|small|\nadd_text_input|mag_find_id|Item ID:|" .. (W.MagFindID .. ("|8|\nadd_text_input|mag_delay|Delay (ms):|" .. (W.MagDelay .. ("|5|\nadd_spacer|small|\nadd_smalltext|`9Drop Items at (World, X, Y). Empty world = current world.|\nadd_text_input|mag_drop_world|Drop World:|" .. (((W.MagDropWorld or "")) .. ("|24|\nadd_text_input|mag_drop_x|Drop X:|" .. (W.MagDropX .. ("|4|\nadd_text_input|mag_drop_y|Drop Y:|" .. (W.MagDropY .. "|4|\nadd_small_font_button|btn_mag_drop_touch|`9Set Drop X,Y by Touch|noflags|0|0|\nadd_spacer|small|\nadd_button|btn_mag_drop|`2Start Retrieve & Drop|noflags|0|0|\nadd_button|btn_mag|Back|noflags|0|0|\nend_dialog|close_ui|Close||\n"))))))))))))))
    elseif W.MagCurrentMenu == "ret_trash" then
        Y = Y .. ("add_smalltext|`wMagplant X, Y overrides standing position (0 = use standing tile).|\nadd_text_input|mag_target_x|Magplant X:|" .. (W.MagTargetX .. ("|4|\nadd_text_input|mag_target_y|Magplant Y:|" .. (W.MagTargetY .. ("|4|\nadd_small_font_button|btn_mag_target_touch|`9Set Target Magplant by Touch|noflags|0|0|\nadd_spacer|small|\nadd_text_input|mag_find_id|Item ID:|" .. (W.MagFindID .. ("|8|\nadd_text_input|mag_delay|Delay (ms):|" .. (W.MagDelay .. "|5|\nadd_spacer|small|\nadd_button|btn_mag_trash|`2Start Retrieve & Trash|noflags|0|0|\nadd_button|btn_mag|Back|noflags|0|0|\nend_dialog|close_ui|Close||\n"))))))))
    elseif W.MagCurrentMenu == "set" then
        local P = (W.MagSetMode == "wrench") and "`9Wrench Target" or "`eWalk Right"
        Y = Y .. "add_smalltext|`wMagplant X, Y overrides standing position (0 = use standing tile).|\n"
        if W.MagSetMode == "walk" then
            Y = Y .. ("add_text_input|mag_target_x|Magplant X:|" .. (W.MagTargetX .. ("|4|\nadd_text_input|mag_target_y|Magplant Y:|" .. (W.MagTargetY .. "|4|\nadd_small_font_button|btn_mag_target_touch|`9Set Target Magplant by Touch|noflags|0|0|\nadd_spacer|small|\n"))))
        else
            Y = Y .. "add_smalltext|`cWrench Mode: `wPunch any Magplant to automatically set its item ID.|\nadd_spacer|small|\n"
        end
        Y = Y .. ("add_text_input|mag_find_id|Item ID:|" .. (W.MagFindID .. ("|8|\nadd_text_input|mag_delay|Delay (ms):|" .. (W.MagDelay .. ("|5|\nadd_spacer|small|\nadd_button|btn_toggle_set_mode|Mode: " .. (P .. "|noflags|0|0|\nadd_button|btn_mag_set|`2Start Set Magplant|noflags|0|0|\nadd_button|btn_mag|Back|noflags|0|0|\nend_dialog|close_ui|Close||\n"))))))
    elseif W.MagCurrentMenu == "mag2mag" then
        Y = Y .. ("add_smalltext|`9Source (Take) Magplant:|\nadd_text_input|m2m_take_world|World:|" .. (((W.MagM2MTakeWorld or "")) .. ("|24|\nadd_text_input|m2m_take_x|X:|" .. (W.MagM2MTakeX .. ("|4|\nadd_text_input|m2m_take_y|Y:|" .. (W.MagM2MTakeY .. ("|4|\nadd_small_font_button|btn_m2m_take_touch|`9Set Take X,Y by Touch|noflags|0|0|\nadd_spacer|small|\nadd_smalltext|`9Destination (Put) Magplant:|\nadd_text_input|m2m_put_world|World:|" .. (((W.MagM2MPutWorld or "")) .. ("|24|\nadd_text_input|m2m_put_x|X:|" .. (W.MagM2MPutX .. ("|4|\nadd_text_input|m2m_put_y|Y:|" .. (W.MagM2MPutY .. ("|4|\nadd_small_font_button|btn_m2m_put_touch|`9Set Put X,Y by Touch|noflags|0|0|\nadd_spacer|small|\nadd_text_input|mag_delay|Delay (ms):|" .. (W.MagDelay .. "|5|\nadd_spacer|small|\nadd_button|btn_mag_m2m|`2Start Mag to Mag|noflags|0|0|\nadd_button|btn_mag|Back|noflags|0|0|\nend_dialog|close_ui|Close||\n"))))))))))))))
    end
    W.CreateDialog(Y)
end

function W.ShowVendingDialog(P)
    W.VendCurrentMenu = P or "main"
    local j = W.VendRunning and ("`2Running `w(" .. (tostring(W.VendMode) .. ")")) or "`4Idle"
    local Y = "add_label_with_icon|big|`9Vending Tools|left|" .. (W.GetIcon("Digivend Machine", 2978) .. ("|\nadd_textbox|`9Status : " .. (j .. "|\n")))
    Y = Y .. "add_small_font_button|btn_vend_stop|`4Stop Current Task|noflags|0|0|\nadd_spacer|small|\n"
    if W.VendCurrentMenu == "main" then
        Y = Y .. "text_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjj|\n"
        Y = Y .. ("add_button_with_icon|btn_vend_menu_set|`2Set Vending|staticYellowFrame|" .. (W.GetIcon("Digivend Machine", 2978) .. "||\n"))
        Y = Y .. ("add_button_with_icon|btn_vend_menu_find|`2Find & Add|staticYellowFrame|" .. (W.GetIcon("Digivend Machine", 2978) .. "||\n"))
        Y = Y .. ("add_button_with_icon|btn_vend_menu_take|`2Take & Add|staticYellowFrame|" .. (W.GetIcon("Digivend Machine", 2978) .. "||\n"))
        Y = Y .. ("add_button_with_icon|btn_vend_menu_ret_drop|`2Ret & Drop|staticYellowFrame|" .. (W.GetIcon("Digivend Machine", 2978) .. "||\n"))
        Y = Y .. ("add_button_with_icon|btn_vend_menu_ret_trash|`2Ret & Trash|staticYellowFrame|" .. (W.GetIcon("Digivend Machine", 2978) .. "||\n"))
        Y = Y .. ("add_button_with_icon|btn_vend_menu_vend2vend|`2Vend to Vend|staticYellowFrame|" .. (W.GetIcon("Digivend Machine", 2978) .. "||\n"))
        Y = Y .. "text_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjj|\n"
        Y = Y .. "add_button_with_icon||END_LIST|noflags|0||\n"
        Y = Y .. "add_button|menuu|Back|noflags|0|0|\n"
        Y = Y .. "end_dialog|close_ui|Close||\n"
    elseif W.VendCurrentMenu == "find" then
        Y = Y .. ("add_smalltext|`wVending X, Y overrides standing position (0 = use standing tile).|\nadd_text_input|vend_target_x|Vending X:|" .. (W.VendTargetX .. ("|4|\nadd_text_input|vend_target_y|Vending Y:|" .. (W.VendTargetY .. ("|4|\nadd_small_font_button|btn_vend_target_touch|`9Set Target Vending by Touch|noflags|0|0|\nadd_spacer|small|\nadd_text_input|vend_find_id|Item ID:|" .. (W.VendFindID .. ("|8|\nadd_text_input|vend_delay|Delay (ms):|" .. (W.VendDelay .. "|5|\nadd_spacer|small|\nadd_button|btn_vend_find|`2Start Find & Add|noflags|0|0|\nadd_button|btn_vend|Back|noflags|0|0|\nend_dialog|close_ui|Close||\n"))))))))
    elseif W.VendCurrentMenu == "take" then
        Y = Y .. ("add_smalltext|`wVending X, Y overrides standing position (0 = use standing tile).|\nadd_text_input|vend_target_x|Vending X:|" .. (W.VendTargetX .. ("|4|\nadd_text_input|vend_target_y|Vending Y:|" .. (W.VendTargetY .. ("|4|\nadd_small_font_button|btn_vend_target_touch|`9Set Target Vending by Touch|noflags|0|0|\nadd_spacer|small|\nadd_text_input|vend_find_id|Item ID:|" .. (W.VendFindID .. ("|8|\nadd_text_input|vend_delay|Delay (ms):|" .. (W.VendDelay .. ("|5|\nadd_spacer|small|\nadd_smalltext|`9Take & Add: pick up dropped items from (World, X, Y). Empty world = current world.|\nadd_text_input|vend_from_world|From World:|" .. (((W.VendFromWorld or "")) .. ("|24|\nadd_text_input|vend_from_x|From X:|" .. (W.VendFromX .. ("|4|\nadd_text_input|vend_from_y|From Y:|" .. (W.VendFromY .. "|4|\nadd_small_font_button|btn_vend_from_touch|`9Set Take & Add X,Y by Touch|noflags|0|0|\nadd_spacer|small|\nadd_button|btn_vend_add|`2Start Take & Add|noflags|0|0|\nadd_button|btn_vend|Back|noflags|0|0|\nend_dialog|close_ui|Close||\n"))))))))))))))
    elseif W.VendCurrentMenu == "ret_drop" then
        Y = Y .. ("add_smalltext|`wVending X, Y overrides standing position (0 = use standing tile).|\nadd_text_input|vend_target_x|Vending X:|" .. (W.VendTargetX .. ("|4|\nadd_text_input|vend_target_y|Vending Y:|" .. (W.VendTargetY .. ("|4|\nadd_small_font_button|btn_vend_target_touch|`9Set Target Vending by Touch|noflags|0|0|\nadd_spacer|small|\nadd_text_input|vend_find_id|Item ID:|" .. (W.VendFindID .. ("|8|\nadd_text_input|vend_delay|Delay (ms):|" .. (W.VendDelay .. ("|5|\nadd_spacer|small|\nadd_smalltext|`9Ret & Drop: drop items to (World, X, Y). Empty world = current.|\nadd_text_input|vend_drop_world|Drop World:|" .. (((W.VendDropWorld or "")) .. ("|24|\nadd_text_input|vend_drop_x|Drop X:|" .. (W.VendDropX .. ("|4|\nadd_text_input|vend_drop_y|Drop Y:|" .. (W.VendDropY .. "|4|\nadd_small_font_button|btn_vend_drop_touch|`9Set Drop X,Y by Touch|noflags|0|0|\nadd_spacer|small|\nadd_button|btn_vend_drop|`2Start Ret & Drop|noflags|0|0|\nadd_button|btn_vend|Back|noflags|0|0|\nend_dialog|close_ui|Close||\n"))))))))))))))
    elseif W.VendCurrentMenu == "ret_trash" then
        Y = Y .. ("add_smalltext|`wVending X, Y overrides standing position (0 = use standing tile).|\nadd_text_input|vend_target_x|Vending X:|" .. (W.VendTargetX .. ("|4|\nadd_text_input|vend_target_y|Vending Y:|" .. (W.VendTargetY .. ("|4|\nadd_small_font_button|btn_vend_target_touch|`9Set Target Vending by Touch|noflags|0|0|\nadd_spacer|small|\nadd_text_input|vend_find_id|Item ID:|" .. (W.VendFindID .. ("|8|\nadd_text_input|vend_delay|Delay (ms):|" .. (W.VendDelay .. "|5|\nadd_spacer|small|\nadd_button|btn_vend_trash|`2Start Ret & Trash|noflags|0|0|\nadd_button|btn_vend|Back|noflags|0|0|\nend_dialog|close_ui|Close||\n"))))))))
    elseif W.VendCurrentMenu == "set" then
        local P = (W.VendSetMode == "wrench") and "`5Wrench Mode" or "`9Walk Mode"
        local j = (W.VendPriceMode == "peritem") and "Items per WL" or "WLs per Item"
        Y = Y .. "add_smalltext|`wVending X, Y overrides standing position (0 = use standing tile).|\n"
        if W.VendSetMode == "walk" then
            Y = Y .. ("add_text_input|vend_target_x|Vending X:|" .. (W.VendTargetX .. "|4|\n"))
            Y = Y .. ("add_text_input|vend_target_y|Vending Y:|" .. (W.VendTargetY .. "|4|\n"))
            Y = Y .. "add_small_font_button|btn_vend_target_touch|`9Set Target Vending by Touch|noflags|0|0|\n"
            Y = Y .. "add_spacer|small|\n"
        else
            Y = Y .. "add_smalltext|`cWrench Mode: `wPunch any Vending Machine to automatically set its Item ID.|\nadd_spacer|small|\n"
        end
        Y = Y .. ("add_text_input|vend_find_id|Item ID to Set:|" .. (W.VendFindID .. "|8|\n"))
        Y = Y .. ("add_text_input|vend_price|Price:|" .. (W.VendPrice .. "|5|\n"))
        Y = Y .. ("add_button|btn_vend_toggle_price_mode|Price Mode: " .. (j .. "|noflags|0|0|\n"))
        Y = Y .. "add_spacer|small|\n"
        Y = Y .. ("add_button|btn_vend_set_mode|Set Mode: " .. (P .. "|noflags|0|0|\n"))
        Y = Y .. "add_button|btn_vend_set|`2Start Set Vending|noflags|0|0|\n"
        Y = Y .. "add_button|btn_vend|Back|noflags|0|0|\n"
        Y = Y .. "end_dialog|close_ui|Close||\n"
    elseif W.VendCurrentMenu == "vend2vend" then
        Y = Y .. ("add_smalltext|`5Source (Take) Vending Machine|\nadd_text_input|v2v_take_w|World:|" .. (((W.VendM2MTakeWorld or "")) .. ("|24|\nadd_text_input|v2v_take_x|X:|" .. (W.VendM2MTakeX .. ("|4|\nadd_text_input|v2v_take_y|Y:|" .. (W.VendM2MTakeY .. ("|4|\nadd_small_font_button|btn_vend_v2v_take_touch|`9Set Source Vending by Touch|noflags|0|0|\nadd_spacer|small|\nadd_smalltext|`2Destination (Put) Vending Machine|\nadd_text_input|v2v_put_w|World:|" .. (((W.VendM2MPutWorld or "")) .. ("|24|\nadd_text_input|v2v_put_x|X:|" .. (W.VendM2MPutX .. ("|4|\nadd_text_input|v2v_put_y|Y:|" .. (W.VendM2MPutY .. ("|4|\nadd_small_font_button|btn_vend_v2v_put_touch|`9Set Dest Vending by Touch|noflags|0|0|\nadd_spacer|small|\nadd_text_input|vend_delay|Delay (ms):|" .. (W.VendDelay .. "|5|\nadd_spacer|small|\nadd_button|btn_vend_v2v|`2Start Vend to Vend|noflags|0|0|\nadd_button|btn_vend|Back|noflags|0|0|\nend_dialog|close_ui|Close||\n"))))))))))))))
    end
    W.CreateDialog(Y)
end

function W.ShowTitleMenuDialog()
    if not W.TitlesState.Loaded and not W.FetchingTitlesSilent then
        W.AutoRefreshTitleDialog = true
        W.FetchPlayerTitles()
        return
    end
    local P = "set_default_color|`o\nadd_label_with_icon|big|`cTitle Manager|left|" .. (W.GetIcon("`7Party Animal Title", 14186) .. "|\n")
    P = P .. "add_spacer|small|\n"
    P = P .. "text_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjj|\n"
    P = P .. "add_textbox|`9Standard Titles (Auto-Apply):|left|\n"
    for j, Y in ipairs(W.TitlesState.Standard) do
        local X = Y.enabled and "1" or "0"
        local M = Y.relog and " `e[Re-enter World]" or ""
        P = P .. ("add_checkbox|std_" .. (j .. ("|" .. (Y.name .. (M .. ("|" .. (X .. "|\n")))))))
    end
    P = P .. "add_spacer|small|\n"
    P = P .. "add_textbox|`9Pro Max Animation Mode:|left|\n"
    P = P .. ("add_checkbox|gpm_1|Mode 1 (Quick Highlight)|" .. (((W.TitlesState.GpmMode == 1 and "1" or "0")) .. "|\n"))
    P = P .. ("add_checkbox|gpm_2|Mode 2 (Cycle)|" .. (((W.TitlesState.GpmMode == 2 and "1" or "0")) .. "|\n"))
    P = P .. ("add_checkbox|gpm_3|Mode 3 (Blinking)|" .. (((W.TitlesState.GpmMode == 3 and "1" or "0")) .. "|\n"))
    P = P .. "add_spacer|small|\n"
    P = P .. "add_textbox|`9Custom Titles (Auto-Apply):|left|\n"
    if #W.TitlesState.Custom == 0 then
        P = P .. "add_textbox|`wNo custom titles found.|left|\n"
    else
        for j, Y in ipairs(W.TitlesState.Custom) do
            local X = Y.enabled and "1" or "0"
            P = P .. ("add_checkbox|cust_" .. (j .. ("|" .. (Y.clean .. ("|" .. (X .. "|\n"))))))
        end
    end
    P = P .. "add_spacer|small|\n"
    P = P .. ("add_button_with_icon|btn_save_titles|`2Save Titles|staticGreenFrame|" .. (W.GetIcon("Save", 32) .. "||\n"))
    P = P .. "add_spacer|small|\n"
    P = P .. "text_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjj|\n"
    P = P .. "add_button_with_icon||END_LIST|noflags|0||\n"
    P = P .. "add_button|menuu|Back|noflags|0|0|\n"
    P = P .. "end_dialog|cmdend|Close|\n"
    W.CreateDialog(P)
end

function W.ShowWorldDialog()
    W.CreateDialog(V("World Settings", 3802))
end

function W.ShowLogsMenuDialog()
    local P = W.LogsEnabled and "`2[ON]" or "`4[OFF]"
    local j = "add_label_with_icon|big|`9Activity Logs Menu|left|" .. (W.GetIcon("Security Camera", 1436) .. ("|\nadd_spacer|small|\nadd_small_font_button|btn_cmd_logs|`9List Command|noflags|0|0|\nadd_button|btn_toggle_logs|Auto-Logging: " .. (P .. ("|noflags|0|0|\nadd_spacer|small|\ntext_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjj|\nadd_button_with_icon|btn_show_all_logs|`wAll Logs|staticYellowFrame|" .. (W.GetIcon("Security Camera", 1436) .. ("||\nadd_button_with_icon|btn_show_casino_logs|`2Casino Logs|staticYellowFrame|" .. (W.GetIcon("Roulette Wheel", 758) .. ("||\nadd_button_with_icon|btn_show_inv_logs|`eInventory Logs|staticYellowFrame|" .. (W.GetIcon("Creativeps World Lock", 242) .. ("||\nadd_button_with_icon|btn_show_collect_logs|`^Collect Logs|staticYellowFrame|" .. (W.GetIcon("CreativePS Black Gem Lock", 274) .. ("||\nadd_button_with_icon|btn_show_drop_logs|`4Drop Logs|staticYellowFrame|" .. (W.GetIcon("CreativePS Black Gem Lock", 276) .. "||\nadd_button_with_icon||END_LIST|noflags|0||\nadd_small_font_button|btn_clear_logs|`4Clear All Logs|noflags|0|0|\ntext_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjj|\nadd_button|menuu|Back|noflags|0|0|\nend_dialog|close_ui|Close||\n")))))))))))))
    W.CreateDialog(j)
end

function W.ShowLogDetailDialog(P, j, Y)
    local X = "add_label_with_icon|big|`9" .. (P .. ("|left|" .. (W.GetIcon("Security Camera", 1436) .. "|\nadd_spacer|small|\n")))
    local M = 0
    local z = W.Logs[j] or {}
    for P, j in ipairs(z) do
        if not Y or j:find(Y) then
            X = X .. ("add_smalltext|" .. (j .. "|\n"))
            M = M + 1
        end
        if M >= 45 then
            break
        end
    end
    if M == 0 then
        X = X .. "add_textbox|`4No logs found in this category yet.|\n"
    end
    X = X .. "add_spacer|small|\ntext_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjj|\nadd_button|btn_logs_menu|Back|noflags|0|0|\nend_dialog|close_ui|Close||\n"
    W.CreateDialog(X)
end

function W.ShowSettingDialog()
    local P = "add_label_with_icon|big|`9Core Proxy Settings|left|" .. (W.GetIcon("Steampunk Sprocket", 3310) .. ("|\nadd_spacer|small|\nadd_label_with_icon|small|`9Configuration Management|left|" .. (W.GetIcon("Steampunk Sprocket", 14418) .. ("|\ntext_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjj|\nadd_smalltext|`wSave your current toggles and modes to your local device.|\nadd_button_with_icon|btn_save_config|`2Save Config|staticYellowFrame|" .. (W.GetIcon("Command - Move Down", 16076) .. ("|\nadd_button_with_icon|btn_load_config|`eReload Config|staticYellowFrame|" .. (W.GetIcon("Command - Move Up", 16078) .. ("|\nadd_button_with_icon|btn_reset_config|`4Reset Config|staticYellowFrame|" .. (W.GetIcon("Command - Pause", 16074) .. "|\ntext_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjj|\nadd_button_with_icon||END_LIST|noflags|0|\nadd_spacer|small|\ntext_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjj|\nadd_button|menuu|Back|noflags|0|0|\nend_dialog|close_ui|Close||\n")))))))))
    W.CreateDialog(P)
end

function W.ShowCustomCommandsDialog()
    local P = "set_default_color|`o\nadd_label_with_icon|big|`9Command Alias|left|" .. (W.GetIcon("Data Disk", 3224) .. ("|\nadd_spacer|small|\nadd_smalltext|`wConfigure your custom command aliases here.|\nadd_spacer|small|\nadd_label_with_icon|small|`9Add / Edit Alias:|left|" .. (W.GetIcon("Plus Sign", 11234) .. ("|\nadd_text_input|cust_alias|Alias Command:|" .. (W.TempCust .. ("|32|\nadd_text_input|cust_orig|Original Command:|" .. (W.TempOrig .. ("|64|\nadd_checkbox|cust_disable|Disable Original Command|" .. (((W.TempDisableOrig and 1 or 0)) .. ("|\nadd_button_with_icon|btn_add_alias|`cSave Alias|staticYellowFrame|" .. (W.GetIcon("Plus Sign", 11234) .. ("||\nadd_button_with_icon||END_LIST|noflags|0||\nadd_spacer|small|\nadd_label_with_icon|small|`9Delete Alias:|left|" .. (W.GetIcon("Trash", 11234) .. ("|\nadd_text_input|del_alias|Alias to Delete:|/|32|\nadd_button_with_icon|btn_del_alias|`4Delete Alias|staticYellowFrame|" .. (W.GetIcon("Trash", 11234) .. "||\nadd_button_with_icon||END_LIST|noflags|0||\nadd_spacer|small|\nadd_label|medium|`cCurrent Aliases:|\n")))))))))))))))
    for j, Y in pairs(W.CustomCommands) do
        local X = Y.disableOrig and "`4" or "`w"
        P = P .. ("add_label_with_icon|small|`e" .. (j .. (" `w=> " .. (Y.orig .. (" (" .. (X .. ("Disable Orig: " .. (tostring(Y.disableOrig) .. ("`w)|left|" .. (W.GetIcon("Sign", 30) .. "|\n"))))))))))
    end
    P = P .. "add_spacer|small|\ntext_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjj|\nadd_button|btn_setting|Back|noflags|0|0|\nend_dialog|close_ui|Close||\n"
    W.CreateDialog(P)
end

function W.ShowInformationDialog()
    local P = "add_label_with_icon|big|`cInformation & Support Center|left|" .. (W.GetIcon("Digital Sign", 11186) .. "|\nadd_spacer|small|\nadd_smalltext|`5Developer Information|\nadd_textbox|`9Creator: `wWin|\nadd_textbox|`9Discord: `wwin.store|\nadd_spacer|small|\nadd_smalltext|`^Community & Support|\nadd_button|info_copy_wa|`2Copy WhatsApp Group Link|noflags|0|\nadd_button|info_copy_dc|`5Copy Discord Community Link|noflags|0|\nadd_spacer|small|\nadd_smalltext|`2Version Information|\nadd_textbox|`9Proxy Version: `w1.0|\nadd_textbox|`9Status: `wActive Development|\nadd_textbox|`8Support: Available via Discord or WhatsApp|\nadd_spacer|small|\nadd_button|menuu|Back|noflags|0|\nend_dialog|info_dialog|Close|\n")
    W.CreateDialog(P)
end

-- ========================================================================
-- SECTION 14: Dialog button dispatch table K (buttonClicked -> handler)
-- ========================================================================

local K = {
    resetdefault = function(P)
        W.DialogBg = nil
        W.DialogBorder = nil
        W.SaveConfig(true)
        W.ChangeDialogColor()
    end,
    menuu = function(P)
        W.ShowMainDialog()
    end,
    close_ui = function(P)
        W.ShowMainDialog()
    end;
    cmdend = function(P)
        LogToConsole("`4[WinProxy]: `wMenu closed.")
    end,
    btn_cmd_general = function(P)
        W.ShowGeneralCommandsDialog()
    end;
    btn_cmd_wrench = function(P)
        W.ShowWrenchCommandsDialog()
    end,
    btn_cmd_donate = function(P)
        W.ShowDonateCommandsDialog()
    end,
    btn_cmd_trade = function(P)
        W.ShowTradeCommandsDialog()
    end;
    btn_cmd_tele = function(P)
        W.ShowTelephoneCommandsDialog()
    end,
    btn_cmd_emoji = function(P)
        W.ShowEmojiCommandsDialog()
    end;
    btn_cmd_calc = function(P)
        W.ShowCalculatorCommandsDialog()
    end,
    btn_cmd_spam = function(P)
        W.ShowSpamCommandsDialog()
    end,
    btn_cmd_sb = function(P)
        W.ShowSBCommandsDialog()
    end,
    btn_cmd_casino = function(P)
        W.ShowCasinoCommandsDialog()
    end,
    btn_cmd_autopull = function(P)
        W.ShowAutoPullCommandsDialog()
    end,
    btn_cmd_logs = function(P)
        W.ShowLogsCommandsDialog()
    end;
    btn_commands = function(P)
        W.ShowCommandsDialog()
    end,
    btn_general = function(P)
        W.ShowGeneralDialog()
    end;
    btn_autopull_settings = function(P)
        W.ShowAutoPullDialog()
    end;
    btn_apt_pos_menu = function(P)
        W.ShowAPTPositionsDialog()
    end;
    btn_apt_blacklist_menu = function(P)
        W.ShowAPTBlacklistDialog()
    end,
    btn_apt_back_main = function(P)
        W.ShowAutoPullDialog()
    end,
    apt_master_toggle = function(P)
        W.AutoPull = not W.AutoPull
        W.SaveConfig(true)
        W.ShowAutoPullDialog()
    end;
    apt_area_toggle = function(P)
        W.AutoPullAreaScan = not W.AutoPullAreaScan
        if W.AutoPullAreaScan then
            W.ManageAreaPullThread()
        end
        W.SaveConfig(true)
        W.ShowAutoPullDialog()
    end,
    apt_spampull_now = function(P)
        W.TriggerSpamPull()
    end,
    apt_repull_now = function(P)
        W.ExecuteRePullOnce()
    end,
    apt_spampull_toggle = function(P)
        W.SpamPull = not ((W.SpamPull or W.AutoSpamPull))
        W.AutoSpamPull = W.SpamPull
        W.SaveConfig(true)
        W.ShowWrenchDialog()
    end;
    btn_apt_save_all = function(P)
        local j = "\n" .. P
        W.AutoPull = j:match("\napt_master_active|1") and true or false
        local Y = j:match("\napt_area_scan|1") and true or false
        if Y and not W.AutoPullAreaScan then
            W.AutoPullAreaScan = true
            W.ManageAreaPullThread()
        else
            W.AutoPullAreaScan = Y
        end
        local X = j:match("\napt_min_modal_input|([^|\n\r]*)")
        if X then
            W.AutoPullMinModal = tonumber(X:match("([%d%.]+)")) or 0
        end
        W.SaveConfig(true)
        W.LocalChat("`c[WinProxy]: `2[APT] Settings saved successfully!")
        W.ShowAutoPullDialog()
    end;
    btn_apt_reset_all_positions = function(P)
        for P = 1, 5, 1 do
            W.AutoPullPos[P] = { x = 0; y = 0 }
        end
        W.SaveConfig(true)
        W.LocalChat("`c[WinProxy]: `4All 5 Auto Pull positions have been reset!")
        W.ShowAPTPositionsDialog()
    end;
    btn_apt_set_my_pos = function(P)
        local j = GetLocal()
        if j and (j.pos and (j.pos.x and j.pos.y)) then
            W.AutoPullTileX = math.floor(j.pos.x / 32)
            W.AutoPullTileY = math.floor(j.pos.y / 32)
            W.SaveConfig(true)
            W.LocalChat("`c[WinProxy]: `2Target tile set to your position: (" .. (W.AutoPullTileX .. (", " .. (W.AutoPullTileY .. ")"))))
        end
        W.ShowAutoPullDialog()
    end;
    btn_apt_set_door_pos = function(P)
        local j, Y = W.GetSpawnTile()
        if j and Y then
            W.AutoPullTileX, W.AutoPullTileY = j, Y
            W.LocalChat("`c[WinProxy]: `2Target tile set to White Door: (" .. (j .. (", " .. (Y .. ")"))))
        else
            W.AutoPullTileX, W.AutoPullTileY = 0, 0
            W.LocalChat("`c[WinProxy]: `4White Door not found, set to Auto (0, 0)")
        end
        W.SaveConfig(true)
        W.ShowAutoPullDialog()
    end;
    btn_apt_save = function(P)
        local j = {}
        local Y = GetPlayerList() or {}
        for P, Y in pairs(Y) do
            local X = Y.userid or Y.netid or 0
            if X ~= 0 then
                j[X] = true
            end
        end
        local X = {}
        for P, Y in ipairs(W.AutoPullBlacklist) do
            if not j[Y] then
                table.insert(X, Y)
            end
        end
        for P in P:gmatch("apt_cb_(%d+)%|1") do
            local j = tonumber(P)
            if j then
                table.insert(X, j)
            end
        end
        W.AutoPullBlacklist = X
        W.SaveConfig(true)
        W.LocalChat("`c[WinProxy]: `9Blacklist updated (" .. (#X .. " UIDs)."))
        W.ShowAPTBlacklistDialog()
    end;
    btn_apt_select_all = function(P)
        local j = GetPlayerList() or {}
        local Y = GetLocal() and (GetLocal()).userid or 0
        local X = {}
        local M = {}
        for P, j in pairs(j) do
            local Y = j.userid or j.netid or 0
            if Y ~= 0 then
                M[Y] = true
            end
        end
        for P, j in ipairs(W.AutoPullBlacklist) do
            if not M[j] then
                table.insert(X, j)
            end
        end
        for P, j in pairs(j) do
            local M = j.userid or j.netid or 0
            if M ~= 0 and M ~= Y then
                table.insert(X, M)
            end
        end
        W.AutoPullBlacklist = X
        W.SaveConfig(true)
        W.LocalChat("`c[WinProxy]: `9All online players blacklisted.")
        W.ShowAPTBlacklistDialog()
    end,
    btn_apt_deselect_all = function(P)
        local j = GetPlayerList() or {}
        local Y = {}
        for P, j in pairs(j) do
            local X = j.userid or j.netid or 0
            if X ~= 0 then
                Y[X] = true
            end
        end
        local X = {}
        for P, j in ipairs(W.AutoPullBlacklist) do
            if not Y[j] then
                table.insert(X, j)
            end
        end
        W.AutoPullBlacklist = X
        W.SaveConfig(true)
        W.ShowAPTBlacklistDialog()
    end,
    btn_apt_add = function(P)
        local j = tonumber(P:match("apt_uid_input|([^|\n]*)"))
        if j and j > 0 then
            local P = false
            for Y, X in ipairs(W.AutoPullBlacklist) do
                if X == j then
                    P = true
                    break
                end
            end
            if not P then
                table.insert(W.AutoPullBlacklist, j)
                W.SaveConfig(true)
            end
        end
        W.ShowAPTBlacklistDialog()
    end,
    btn_apt_remove = function(P)
        local j = tonumber(P:match("apt_uid_input|([^|\n]*)"))
        if j and j > 0 then
            local P = {}
            for Y, X in ipairs(W.AutoPullBlacklist) do
                if X ~= j then
                    table.insert(P, X)
                end
            end
            W.AutoPullBlacklist = P
            W.SaveConfig(true)
        end
        W.ShowAPTBlacklistDialog()
    end;
    btn_wrench = function(P)
        W.ShowWrenchDialog()
    end,
    btn_donate = function(P)
        W.ShowDonateDialog()
    end,
    btn_trade = function(P)
        W.ShowTradeDialog()
    end,
    btn_telephone = function(P)
        W.ShowTelephoneDialog()
    end;
    btn_toggle_emoji = function(P)
        W.ShowEmojiColorDialog()
    end;
    btn_calc = function(P)
        W.ShowCalculatorDialog()
    end,
    btn_itemdb = function(P)
        W.ShowItemDBDialog()
    end;
    btn_ptht = function(P)
        W.CreateDialog(V("Auto PTHT", 7064))
    end,
    btn_pnb = function(P)
        W.CreateDialog(V("Auto PNB", 7070))
    end,
    btn_auto_cook = function(P)
        W.ShowAutoCookDialog()
    end,
    btn_auto_fish = function(P)
        W.ShowAutoFishDialog()
    end;
    btn_auto_surg = function(P)
        W.ShowAutoSurgDialog()
    end;
    btn_auto_geiger = function(P)
        W.ShowAutoGeigerDialog()
    end,
    btn_auto_crime = function(P)
        W.ShowAutoCrimeDialog()
    end;
    btn_afk = function(P)
        W.CreateDialog(V("AFK", 1000))
    end;
    btn_spam = function(P)
        W.ShowSpamDialog()
    end;
    btn_sb = function(P)
        W.ShowSBDialog()
    end;
    btn_gambling = function(P)
        W.ShowCasinoDialog()
    end,
    btn_btkbj = function(P)
        W.ShowBTKBJDialog()
    end,
    btn_logs = function(P)
        W.ShowLogsMenuDialog()
    end,
    btn_theme = function(P)
        W.ChangeDialogColor()
    end,
    btn_auto_combine = function(P)
        W.CreateDialog(V("Auto Combine", 3146))
    end;
    btn_auto_buypack = function(P)
        W.ShowAutoBuyPackDialog()
    end,
    btn_vend_stop = function(P)
        W.VendRunning = false
        W.VendSelectID = nil
        W.VendPrice = "1"
        W.VendPriceMode = "peritem"
        W.LocalChat("`c[WinProxy]: `4Vending task stopped!")
        W.ShowVendingDialog(W.VendCurrentMenu)
    end;
    btn_vend_menu_set = function(P)
        W.ShowVendingDialog("set")
    end,
    btn_vend_menu_find = function(P)
        W.ShowVendingDialog("find")
    end;
    btn_vend_menu_take = function(P)
        W.ShowVendingDialog("take")
    end,
    btn_vend_menu_ret_drop = function(P)
        W.ShowVendingDialog("ret_drop")
    end,
    btn_vend_menu_ret_trash = function(P)
        W.ShowVendingDialog("ret_trash")
    end,
    btn_vend_menu_vend2vend = function(P)
        W.ShowVendingDialog("vend2vend")
    end;
    btn_vend_from_touch = function(P)
        W.VendSelectingFrom = true
        W.LocalChat("`c[WinProxy]: `eClick on the Take X,Y tile!")
    end;
    btn_vend_target_touch = function(P)
        W.VendSelectingTarget = true
        W.LocalChat("`c[WinProxy]: `eClick on the target Vending tile!")
    end,
    btn_vend_drop_touch = function(P)
        W.VendSelectingDrop = true
        W.LocalChat("`c[WinProxy]: `eClick on the Drop tile!")
    end,
    btn_vend_v2v_take_touch = function(P)
        W.VendSelectingM2MTake = true
        W.LocalChat("`c[WinProxy]: `eClick on the Source Vending tile!")
    end,
    btn_vend_v2v_put_touch = function(P)
        W.VendSelectingM2MPut = true
        W.LocalChat("`c[WinProxy]: `eClick on the Dest Vending tile!")
    end;
    btn_toggle_autowalk_vend = function(P)
        W.VendAutoWalk = not W.VendAutoWalk
        W.SaveConfig(true)
        W.ShowVendingDialog(W.VendCurrentMenu)
    end,
    btn_toggle_automove_v2v = function(P)
        W.VendM2MAutoMove = not W.VendM2MAutoMove
        W.SaveConfig(true)
        W.ShowVendingDialog(W.VendCurrentMenu)
    end,
    btn_vend_set_mode = function(P)
        W.VendSetMode = (W.VendSetMode == "wrench") and "walk" or "wrench"
        W.SaveConfig(true)
        W.ShowVendingDialog("set")
    end;
    btn_vend_toggle_price_mode = function(P)
        W.VendParse(P)
        W.VendPriceMode = (W.VendPriceMode == "peritem") and "perlock" or "peritem"
        W.SaveConfig(true)
        W.ShowVendingDialog("set")
    end;
    btn_vend_find = function(P)
        W.VendParse(P)
        W.VendStart("find")
    end;
    btn_vend_add = function(P)
        W.VendParse(P)
        W.VendStart("add")
    end,
    btn_vend_drop = function(P)
        W.VendParse(P)
        W.VendStart("drop")
    end;
    btn_vend_trash = function(P)
        W.VendParse(P)
        W.VendStart("trash")
    end;
    btn_vend_set = function(P)
        W.VendParse(P)
        W.VendStart("set")
    end,
    btn_vend_v2v = function(P)
        W.VendParse(P)
        W.VendStart("vend2vend")
    end,
    btn_vend = function(P)
        W.ShowVendingDialog("main")
    end,
    btn_mag = function(P)
        W.ShowMagplantDialog()
    end;
    btn_world = function(P)
        W.ShowWorldDialog()
    end;
    btn_title = function(P)
        W.ShowTitleMenuDialog()
    end,
    btn_scan_titles = function(P)
        W.FetchPlayerTitles()
    end,
    btn_save_titles = function(P)
        for j, Y in ipairs(W.TitlesState.Standard) do
            local X = P:match("std_" .. (j .. "|([01])"))
            if X then
                Y.enabled = (X == "1")
            end
        end
        if P:match("gpm_1|1") then
            W.TitlesState.GpmMode = 1
        elseif P:match("gpm_2|1") then
            W.TitlesState.GpmMode = 2
        elseif P:match("gpm_3|1") then
            W.TitlesState.GpmMode = 3
        end
        for j, Y in ipairs(W.TitlesState.Custom) do
            local X = P:match("cust_" .. (j .. "|([01])"))
            if X then
                Y.enabled = (X == "1")
            end
        end
        W.SavePlayerTitles()
        W.ShowTitleMenuDialog()
        W.LocalChat("`c[WinProxy]: `9Titles saved via Dialog Menu!")
    end,
    btn_setting = function(P)
        W.ShowSettingDialog()
    end;
    btn_custom_cmd = function(P)
        W.ShowCustomCommandsDialog()
    end;
    btn_add_alias = function(P)
        local j = P:match("cust_alias|([^|\r\n]*)") or ""
        local Y = P:match("cust_orig|([^|\r\n]*)") or ""
        local X = P:match("cust_disable|([01])") == "1"
        if j ~= "" and Y ~= "" then
            if j:sub(1, 1) ~= "/" then
                j = "/" .. j
            end
            if Y:sub(1, 1) ~= "/" then
                Y = "/" .. Y
            end
            W.CustomCommands[j] = { orig = Y; disableOrig = X }
            W.SaveConfig(true)
            W.LocalChat("`c[WinProxy]: `2Added alias: `e" .. (j .. (" `w=> `e" .. Y)))
        end
        W.ShowCustomCommandsDialog()
    end;
    btn_del_alias = function(P)
        local j = P:match("del_alias|([^|\r\n]*)") or ""
        if j ~= "" then
            if j:sub(1, 1) ~= "/" then
                j = "/" .. j
            end
            if W.CustomCommands[j] then
                W.CustomCommands[j] = nil
                W.SaveConfig(true)
                W.LocalChat("`c[WinProxy]: `4Deleted alias: `e" .. j)
            else
                W.LocalChat("`c[WinProxy]: `4Alias not found: `e" .. j)
            end
        end
        W.ShowCustomCommandsDialog()
    end,
    btn_info = function(P)
        W.ShowInformationDialog()
    end;
    gen_toggle_antilag = function(P)
        W.ToggleAntiLag()
        W.ShowGeneralDialog()
    end;
    gen_toggle_hidespam = function(P)
        W.ToggleHideSpammer()
        W.ShowGeneralDialog()
    end;
    gen_toggle_ap = function(P)
        W.AntiPickup = not W.AntiPickup
        W.SaveConfig(true)
        W.ShowGeneralDialog()
    end;
    gen_toggle_mf = function(P)
        W.Modfly = not W.Modfly
        pcall(function()
            ChangeValue("[C] Modfly", W.Modfly)
        end)
        W.SaveConfig(true)
        W.ShowGeneralDialog()
    end,
    gen_toggle_p = function(P)
        W.AntiPortal = not W.AntiPortal
        pcall(function()
            ChangeValue("[C] Anti portal", W.AntiPortal)
        end)
        W.SaveConfig(true)
        W.ShowGeneralDialog()
    end,
    gen_toggle_nv = function(P)
        W.NightVision = not W.NightVision
        pcall(function()
            ChangeValue("[C] Night vision", W.NightVision)
        end)
        W.SaveConfig(true)
        W.ShowGeneralDialog()
    end;
    gen_toggle_bsdb = function(P)
        W.BlockSDB = not W.BlockSDB
        W.SaveConfig(true)
        W.ShowGeneralDialog()
    end;
    gen_toggle_autocv = function(P)
        W.AutoCVLocks = not W.AutoCVLocks
        W.SaveConfig(true)
        W.ShowGeneralDialog()
    end,
    gen_toggle_tp = function(P)
        W.TPDisplay = not W.TPDisplay
        W.SaveConfig(true)
        W.ShowGeneralDialog()
    end,
    gen_toggle_fd = function(P)
        W.FastDrop = not W.FastDrop
        if not W.FastDrop then
            W.FastDropOnClick = false
        end
        W.ShowGeneralDialog()
    end,
    gen_toggle_ft = function(P)
        W.FastTrash = not W.FastTrash
        if not W.FastTrash then
            W.FastTrashOnClick = false
        end
        W.ShowGeneralDialog()
    end;
    gen_toggle_vf = function(P)
        W.VendFilter = not W.VendFilter
        W.SaveConfig(true)
        W.ShowGeneralDialog()
    end;
    gen_toggle_df = function(P)
        W.DonationFilter = not W.DonationFilter
        W.SaveConfig(true)
        W.ShowGeneralDialog()
    end;
    gen_toggle_sf = function(P)
        W.StorageFilter = not W.StorageFilter
        W.SaveConfig(true)
        W.ShowGeneralDialog()
    end;
    gen_toggle_fdoc = function(P)
        W.FastDropOnClick = not W.FastDropOnClick
        if W.FastDropOnClick then
            W.FastTrashOnClick = false
            W.ManageWarningThread()
            W.ManageOnClickItemThread()
        end
        W.SaveConfig(true)
        W.ShowGeneralDialog()
    end;
    gen_toggle_ftoc = function(P)
        W.FastTrashOnClick = not W.FastTrashOnClick
        if W.FastTrashOnClick then
            W.FastDropOnClick = false
            W.ManageWarningThread()
            W.ManageOnClickItemThread()
        end
        W.SaveConfig(true)
        W.ShowGeneralDialog()
    end;
    btn_auto_ptht = function(P)
        W.ShowAutoPTHTDialog()
    end,
    btn_auto_splice = function(P)
        W.ShowAutoSpliceDialog()
    end;
    btn_auto_pnb = function(P)
        W.ShowAutoPNBDialog()
    end,
    btn_auto_rotasi = function(P)
        W.ShowAutoRotasiDialog()
    end;
    btn_auto_tax = function(P)
        W.ShowAutoTaxDialog()
    end;
    wrench_save_txt = function(P)
        W.WrenchPullText = P:match("wrench_pull_txt|([^|\n]*)") or ""
        W.WrenchKickText = P:match("wrench_kick_txt|([^|\n]*)") or ""
        W.WrenchBanText = P:match("wrench_ban_txt|([^|\n]*)") or ""
        W.SaveConfig(true)
        W.LocalChat("`c[WinProxy]: `9Wrench Custom Texts saved!")
        W.ShowWrenchDialog()
    end;
    wrench_l_off = function(P)
        W.ToggleWrench(0, false)
        W.ShowWrenchDialog()
    end,
    wrench_l_pull = function(P)
        W.ToggleWrench(1, false)
        W.ShowWrenchDialog()
    end;
    wrench_l_kick = function(P)
        W.ToggleWrench(2, false)
        W.ShowWrenchDialog()
    end;
    wrench_l_ban = function(P)
        W.ToggleWrench(3, false)
        W.ShowWrenchDialog()
    end,
    wrench_l_trade = function(P)
        W.ToggleWrench(4, false)
        W.ShowWrenchDialog()
    end;
    wrench_r_off = function(P)
        W.ToggleWrench(0, true)
        W.ShowWrenchDialog()
    end,
    wrench_r_pull = function(P)
        W.ToggleWrench(1, true)
        W.ShowWrenchDialog()
    end;
    wrench_r_kick = function(P)
        W.ToggleWrench(2, true)
        W.ShowWrenchDialog()
    end,
    wrench_r_ban = function(P)
        W.ToggleWrench(3, true)
        W.ShowWrenchDialog()
    end;
    wrench_r_trade = function(P)
        W.ToggleWrench(4, true)
        W.ShowWrenchDialog()
    end;
    wrench_showbal = function(P)
        W.ShowBal = not W.ShowBal
        W.SaveConfig(true)
        W.ShowWrenchDialog()
    end,
    btn_toggle_dmode = function(P)
        W.DonateMode = not W.DonateMode
        if not W.DonateMode then
            W.DonateBoxX = 0
            W.DonateBoxY = 0
        end
        W.SaveConfig(true)
        W.ShowDonateDialog()
    end;
    btn_do_don_wl = function(P)
        local j = tonumber(P:match("don_amount|(%d+)")) or 1
        W.DoDonate(W.GetIcon("Creativeps World Lock", 242), j)
        W.ShowDonateDialog()
    end;
    btn_do_don_dl = function(P)
        local j = tonumber(P:match("don_amount|(%d+)")) or 1
        W.DoDonate(W.GetIcon("Creativeps Diamond Lock", 1796), j)
        W.ShowDonateDialog()
    end;
    btn_do_don_bgl = function(P)
        local j = tonumber(P:match("don_amount|(%d+)")) or 1
        W.DoDonate(W.GetIcon("Creativeps Blue Gem Lock", 7188), j)
        W.ShowDonateDialog()
    end,
    btn_do_don_blgl = function(P)
        local j = tonumber(P:match("don_amount|(%d+)")) or 1
        W.DoDonate(W.GetIcon("Creativeps Black Gem Lock", 11550), j)
        W.ShowDonateDialog()
    end,
    btn_do_don_all = function(P)
        W.DonateAllLocks()
        W.ShowDonateDialog()
    end,
    btn_do_don_takeall = function(P)
        if W.DonateMode and W.DonateBoxX ~= 0 then
            SendPacket(2, "action|dialog_return\ndialog_name|donate_edit|\nx|" .. (W.DonateBoxX .. ("|\ny|" .. (W.DonateBoxY .. "|\nbuttonClicked|withdrawall"))))
            W.LocalChat("`c[WinProxy]: `9Retrieving all items from Donation Box...")
        else
            W.LocalChat("`c[WinProxy]: `4Please enable /dmode and set a box position first!")
        end
        W.ShowDonateDialog()
    end;
    btn_toggle_tmode = function(P)
        local j = tonumber(P:match("trade_amount|(%d+)"))
        if j then
            W.TradeAddAmount = j
        end
        W.ToggleWrench(4)
        W.ShowTradeDialog()
    end;
    btn_trade_add_wl = function(P)
        local j = tonumber(P:match("trade_amount|(%d+)")) or 1
        W.FastTradeAdd(W.GetIcon("Creativeps World Lock", 242), j)
        W.ShowTradeDialog()
    end;
    btn_trade_add_dl = function(P)
        local j = tonumber(P:match("trade_amount|(%d+)")) or 1
        W.FastTradeAdd(W.GetIcon("Creativeps Diamond Lock", 1796), j)
        W.ShowTradeDialog()
    end;
    btn_trade_add_bgl = function(P)
        local j = tonumber(P:match("trade_amount|(%d+)")) or 1
        W.FastTradeAdd(W.GetIcon("Creativeps Blue Gem Lock", 7188), j)
        W.ShowTradeDialog()
    end,
    btn_trade_add_blgl = function(P)
        local j = tonumber(P:match("trade_amount|(%d+)")) or 1
        W.FastTradeAdd(W.GetIcon("Creativeps Black Gem Lock", 11550), j)
        W.ShowTradeDialog()
    end;
    btn_trade_add_all = function(P)
        W.TradeAllLocks()
        W.ShowTradeDialog()
    end,
    btn_trade_clear = function(P)
        W.TradeClearLocks()
        W.ShowTradeDialog()
    end;
    tele_set_buydl = function(P)
        W.TeleMode = (W.TeleMode == 1) and 0 or 1
        W.LocalChat(W.TeleMode == 1 and "`c[WinProxy]: `9Wrench Telephone to Buy `cDL `9is now `2Enabled" or "`c[WinProxy]: `9Telephone Auto-Buy is now `4Disabled")
        W.ShowTelephoneDialog()
    end,
    tele_set_buybgl = function(P)
        W.TeleMode = (W.TeleMode == 2) and 0 or 2
        W.LocalChat(W.TeleMode == 2 and "`c[WinProxy]: `9Wrench Telephone to Buy `eBGL `9is now `2Enabled" or "`c[WinProxy]: `9Telephone Auto-Buy is now `4Disabled")
        W.ShowTelephoneDialog()
    end,
    tele_set_cv = function(P)
        W.TeleMode = (W.TeleMode == 3) and 0 or 3
        W.LocalChat(W.TeleMode == 3 and "`c[WinProxy]: `9Wrench Telephone to Change `cDL `9to `eBGL `9is now `2Enabled" or "`c[WinProxy]: `9Telephone Auto-Buy is now `4Disabled")
        W.ShowTelephoneDialog()
    end,
    tele_set_buychamp = function(P)
        W.TeleMode = (W.TeleMode == 4) and 0 or 4
        W.LocalChat(W.TeleMode == 4 and "`c[WinProxy]: `9Wrench Telephone to Buy `2Champagne `9is now `2Enabled" or "`c[WinProxy]: `9Telephone Auto-Buy is now `4Disabled")
        W.ShowTelephoneDialog()
    end;
    tele_set_buychampbg = function(P)
        W.TeleMode = (W.TeleMode == 5) and 0 or 5
        W.LocalChat(W.TeleMode == 5 and "`c[WinProxy]: `9Wrench Telephone to Buy `2Champ (Black Gems) `9is now `2Enabled" or "`c[WinProxy]: `9Telephone Auto-Buy is now `4Disabled")
        W.ShowTelephoneDialog()
    end,
    tele_set_buychampbulk = function(P)
        W.TeleMode = (W.TeleMode == 6) and 0 or 6
        W.LocalChat(W.TeleMode == 6 and "`c[WinProxy]: `9Wrench Telephone to Buy `2Bulk Champagne `9is now `2Enabled" or "`c[WinProxy]: `9Telephone Auto-Buy is now `4Disabled")
        W.ShowTelephoneDialog()
    end,
    cas_reme = function(P)
        W.ToggleCasino(1)
        W.ShowCasinoDialog()
    end;
    cas_qeme = function(P)
        W.ToggleCasino(2)
        W.ShowCasinoDialog()
    end;
    cas_leme = function(P)
        W.ToggleCasino(3)
        W.ShowCasinoDialog()
    end,
    cas_lemes = function(P)
        W.ToggleCasino(4)
        W.ShowCasinoDialog()
    end;
    cas_ceme = function(P)
        W.ToggleCasino(5)
        W.ShowCasinoDialog()
    end;
    cas_all = function(P)
        W.ToggleCasino(7)
        W.ShowCasinoDialog()
    end,
    cas_lewa = function(P)
        W.ToggleCasino(6)
        W.ShowCasinoDialog()
    end,
    cas_autochamp = function(P)
        W.AutoChampWheel = not W.AutoChampWheel
        W.SaveConfig(true)
        W.ShowCasinoDialog()
    end;
    cas_fmt_1 = function(P)
        W.CasinoFormatIdx = 1
        W.SaveConfig(true)
        W.ShowCasinoDialog()
    end;
    cas_fmt_2 = function(P)
        W.CasinoFormatIdx = 2
        W.SaveConfig(true)
        W.ShowCasinoDialog()
    end,
    btn_save_lewa = function(P)
        local j = P:match("input_lewa|(%d+)")
        if j then
            local P = tonumber(j)
            if P < 5 then
                P = 5
            end
            if P > 7 then
                P = 7
            end
            W.CasinoLewaMulti = P
            W.SaveConfig(true)
            W.LocalChat("`c[WinProxy]: `9Lewa Multiplier saved to `2" .. P)
        end
        W.ShowCasinoDialog()
    end;
    btn_btk_cmd_list = function(P)
        W.ShowBTKCommandsDialog()
    end,
    btk_open_imgui = function(P)
        W.ShowImGui = true
        W.SaveConfig(true)
        W.LocalChat("`c[WinProxy]: `9ImGui Menu is now `2OPEN")
    end,
    btn_do_calc = function(P)
        local j = P:match("calc_input|([^|\n]+)")
        if j then
            W.CalcInput = j
            W.CalculateMath(j)
        end
        W.ShowCalculatorDialog()
    end,
    btn_toggle_fish = function(P)
        W.AutoFish = not W.AutoFish
        if W.AutoFish then
            W.ManageAutoFishThread()
        else
            W.FishAction = "Stopping..."
        end
        W.ShowAutoFishDialog()
    end;
    btn_toggle_fish_dir = function(P)
        W.FishDirIdx = (W.FishDirIdx == 1) and 2 or 1
        W.SaveConfig(true)
        W.ShowAutoFishDialog()
    end;
    btn_save_fish = function(P)
        local j = tonumber(P:match("input_fish_bait|(%d+)"))
        if j then
            W.FishBaitID = j
            W.SaveConfig(true)
            W.LocalChat("`c[WinProxy]: `9Bait Item ID saved to `2" .. j)
        end
        W.ShowAutoFishDialog()
    end;
    btn_reset_fish_stats = function(P)
        W.FishStats = { cast = 0, caught = 0, missed = 0 }
        W.LocalChat("`c[WinProxy]: `9Fishing statistics reset.")
        W.ShowAutoFishDialog()
    end;
    btn_toggle_surg = function(P)
        W.AutoSurg = not W.AutoSurg
        if W.AutoSurg then
            W.ManageAutoSurgThread()
        else
            W.IsSurging = false
            W.SurgTarget = nil
            W.SurgAction = "Stopping..."
        end
        W.ShowAutoSurgDialog()
    end,
    btn_toggle_surg_autobuy = function(P)
        W.SurgAutoBuy = not W.SurgAutoBuy
        W.SaveConfig(true)
        W.ShowAutoSurgDialog()
    end,
    btn_toggle_surg_autotrash = function(P)
        W.SurgAutoTrash = not W.SurgAutoTrash
        W.SaveConfig(true)
        W.ShowAutoSurgDialog()
    end;
    btn_toggle_surg_modage = function(P)
        W.SurgAutoModage = not W.SurgAutoModage
        if W.SurgAutoModage then
            W.SurgUseLegalBrief = false
        end
        W.SaveConfig(true)
        W.ShowAutoSurgDialog()
    end,
    btn_toggle_surg_legalbrief = function(P)
        W.SurgUseLegalBrief = not W.SurgUseLegalBrief
        if W.SurgUseLegalBrief then
            W.SurgAutoModage = false
        end
        W.SaveConfig(true)
        W.ShowAutoSurgDialog()
    end,
    btn_save_surg = function(P)
        local j = tonumber(P:match("input_surg_threshold|(%d+)"))
        if j then
            if j < 1 then
                j = 1
            end
            W.SurgCardThreshold = j
            W.SaveConfig(true)
            W.LocalChat("`c[WinProxy]: `9Surg Card Threshold saved to `2" .. j)
        end
        W.ShowAutoSurgDialog()
    end;
    btn_reset_surg_stats = function(P)
        W.SurgStats = { success = 0, fail = 0 }
        W.LocalChat("`c[WinProxy]: `9Surgery statistics reset.")
        W.ShowAutoSurgDialog()
    end,
    btn_toggle_crime = function(P)
        W.AutoCrime = not W.AutoCrime
        if W.AutoCrime then
            W.ManageAutoCrimeThread()
        else
            W.IsFightingCrime = false
            W.CrimeAction = "Stopping..."
        end
        W.ShowAutoCrimeDialog()
    end,
    btn_scan_crime = function(P)
        W.ScanVillains()
        W.ShowAutoCrimeDialog()
    end;
    btn_toggle_crime_autobuy = function(P)
        W.AutoBuyCrimeCards = not W.AutoBuyCrimeCards
        W.SaveConfig(true)
        W.ShowAutoCrimeDialog()
    end,
    btn_save_crime = function(P)
        local j = tonumber(P:match("input_crime_threshold|(%d+)"))
        if j then
            if j < 1 then
                j = 1
            end
            W.CrimeCardThreshold = j
            W.SaveConfig(true)
            W.LocalChat("`c[WinProxy]: `9Crime Card Threshold saved to `2" .. j)
        end
        W.ShowAutoCrimeDialog()
    end,
    btn_view_crime_villains = function(P)
        W.ShowCrimeVillainsDialog()
    end,
    btn_crime_back = function(P)
        W.ShowAutoCrimeDialog()
    end,
    btn_auto_provider = function(P)
        W.ShowAutoProviderDialog()
    end,
    btn_toggle_spam = function(P)
        W.ToggleSpam(not W.SpamEnabled)
        W.ShowSpamDialog()
    end,
    btn_add_spam_field = function(P)
        for j = 1, #W.SpamTexts, 1 do
            local Y = P:match("input_spam_" .. (j .. "|([^|\n]*)"))
            if Y then
                W.SpamTexts[j] = Y
            end
        end
        table.insert(W.SpamTexts, "")
        W.ShowSpamDialog()
    end;
    btn_rem_spam_field = function(P)
        if #W.SpamTexts > 1 then
            table.remove(W.SpamTexts)
        end
        W.ShowSpamDialog()
    end,
    btn_save_spam = function(P)
        for j = 1, #W.SpamTexts, 1 do
            local Y = P:match("input_spam_" .. (j .. "|([^|\n]*)"))
            if Y then
                W.SpamTexts[j] = Y
            end
        end
        local j = tonumber(P:match("input_spam_delay|(%d+)")) or 3000
        if j < 500 then
            j = 500
        end
        W.SpamInterval = j
        W.LocalChat("`c[WinProxy]: `9Spam configuration saved!")
        W.ShowSpamDialog()
    end,
    btn_start_sb = function(P)
        W.StartSB()
        W.ShowSBDialog()
    end,
    btn_stop_sb = function(P)
        W.StopSB()
        W.ShowSBDialog()
    end,
    btn_reset_sb = function(P)
        W.ResetSB()
        W.LocalChat("`c[WinProxy]: `2SB Count and statistics reset to 0!")
        W.ShowSBDialog()
    end;
    btn_start_sdb = function(P)
        W.StartSDB()
        W.ShowSBDialog()
    end,
    btn_stop_sdb = function(P)
        W.StopSDB()
        W.ShowSBDialog()
    end;
    btn_reset_sdb = function(P)
        W.ResetSDB()
        W.LocalChat("`c[WinProxy]: `2SDB Count reset to 0!")
        W.ShowSBDialog()
    end;
    btn_save_sb_config = function(P)
        W.SBText = P:match("input_sb_text|([^|\n]*)") or ""
        W.SBMax = tonumber(P:match("input_sb_amount|(%d+)")) or 0
        W.SBDoneWorld = P:match("input_sb_done|([^|\n]*)") or ""
        W.SDBLine1 = P:match("input_sdb_l1|([^|\n]*)") or ""
        W.SDBLine2 = P:match("input_sdb_l2|([^|\n]*)") or ""
        W.SDBLine3 = P:match("input_sdb_l3|([^|\n]*)") or ""
        W.SDBMax = tonumber(P:match("input_sdb_amount|(%d+)")) or 0
        W.SDBExtraTimer = tonumber(P:match("input_sdb_delay|(%d+)")) or 0
        W.SDBTotalDelay = 5 + W.SDBExtraTimer
        W.SaveConfig(true)
        W.LocalChat("`c[WinProxy]: `9SB & SDB Configuration saved!")
        W.ShowSBDialog()
    end;
    btn_mag_menu_find = function(P)
        W.ShowMagplantDialog("find")
    end;
    btn_mag_menu_take = function(P)
        W.ShowMagplantDialog("take")
    end,
    btn_mag_menu_ret_drop = function(P)
        W.ShowMagplantDialog("ret_drop")
    end,
    btn_mag_menu_ret_trash = function(P)
        W.ShowMagplantDialog("ret_trash")
    end;
    btn_mag_menu_set = function(P)
        W.ShowMagplantDialog("set")
    end,
    btn_mag_menu_mag2mag = function(P)
        W.ShowMagplantDialog("mag2mag")
    end,
    btn_mag_drop_touch = function(P)
        W.MagParse(P)
        W.MagSelectingDrop = true
        W.LocalChat("`c[WinProxy]: `eClick on the tile to Drop items to!")
    end,
    btn_mag_target_touch = function(P)
        W.MagParse(P)
        W.MagSelectingTarget = true
        W.LocalChat("`c[WinProxy]: `eClick on the target Magplant tile!")
    end;
    btn_mag_from_touch = function(P)
        W.MagParse(P)
        W.MagSelectingFrom = true
        W.LocalChat("`c[WinProxy]: `eClick on the tile to Take items from!")
    end,
    btn_mag_find = function(P)
        W.MagParse(P)
        W.MagStart("find")
    end,
    btn_mag_add = function(P)
        W.MagParse(P)
        W.MagStart("add")
    end;
    btn_mag_drop = function(P)
        W.MagParse(P)
        W.MagStart("drop")
    end,
    btn_mag_trash = function(P)
        W.MagParse(P)
        W.MagStart("trash")
    end,
    btn_mag_set = function(P)
        W.MagParse(P)
        W.MagStart("set")
    end,
    btn_mag_menu_mag2mag = function()
        W.ShowMagplantDialog("mag2mag")
    end;
    btn_mag_m2m = function(P)
        W.MagParse(P)
        W.MagStart("mag2mag")
    end,
    btn_mag_stock = function(P)
        W.MagStart("stock")
    end;
    btn_mag_stop = function(P)
        W.MagRunning = false
        W.MagSelectID = nil
        W.VendFindID = "1656"
        W.VendDelay = 150
        W.VendFromWorld = ""
        W.VendFromX = "0"
        W.VendFromY = "0"
        W.VendTargetX = "0"
        W.VendTargetY = "0"
        W.VendDropWorld = ""
        W.VendDropX = "0"
        W.VendDropY = "0"
        W.VendSetMode = "walk"
        W.VendAutoWalk = false
        W.VendSelectingTarget = false
        W.VendSelectingFrom = false
        W.VendSelectingDrop = false
        W.VendRunning = false
        W.VendMode = ""
        W.VendDone = false
        W.VendX = 0
        W.VendY = 0
        W.VendM2MTakeWorld = ""
        W.VendM2MTakeX = "0"
        W.VendM2MTakeY = "0"
        W.VendM2MPutWorld = ""
        W.VendM2MPutX = "0"
        W.VendM2MPutY = "0"
        W.VendM2MAutoMove = false
        W.VendSelectingM2MTake = false
        W.VendSelectingM2MPut = false
        W.VendSelectID = nil
        W.VendPrice = "1"
        W.VendPriceMode = "peritem"
        W.ShowMagplantDialog("main")
    end,
    btn_toggle_set_mode = function(P)
        W.MagParse(P)
        W.MagSetMode = (W.MagSetMode == "wrench") and "walk" or "wrench"
        W.SaveConfig(true)
        W.ShowMagplantDialog("set")
    end;
    btn_toggle_autowalk = function(P)
        W.MagParse(P)
        W.MagAutoWalk = not W.MagAutoWalk
        W.SaveConfig(true)
        W.ShowMagplantDialog(W.MagCurrentMenu)
    end;
    btn_toggle_m2m_automove = function(P)
        W.MagParse(P)
        W.MagM2MAutoMove = not W.MagM2MAutoMove
        W.SaveConfig(true)
        W.ShowMagplantDialog(W.MagCurrentMenu)
    end,
    btn_m2m_take_touch = function(P)
        W.MagParse(P)
        W.MagSelectingM2MTake = true
        W.LocalChat("`c[WinProxy]: `eClick on the Source (Take) Magplant tile!")
    end,
    btn_m2m_put_touch = function(P)
        W.MagParse(P)
        W.MagSelectingM2MPut = true
        W.LocalChat("`c[WinProxy]: `eClick on the Destination (Put) Magplant tile!")
    end,
    btn_toggle_m2m_automove = function(P)
        W.MagParse(P)
        W.MagM2MAutoMove = not W.MagM2MAutoMove
        W.SaveConfig(true)
        W.ShowMagplantDialog(W.MagCurrentMenu)
    end,
    btn_m2m_take_touch = function(P)
        W.MagParse(P)
        W.MagSelectingM2MTake = true
        W.LocalChat("`c[WinProxy]: `eClick on the Source (Take) Magplant tile!")
    end;
    btn_m2m_put_touch = function(P)
        W.MagParse(P)
        W.MagSelectingM2MPut = true
        W.LocalChat("`c[WinProxy]: `eClick on the Destination (Put) Magplant tile!")
    end,
    btn_toggle_rcol = function()
        if W.EnableColor and W.ColorValues[W.SelectedColorIdx] == "RANDOM" then
            W.EnableColor = false
        else
            W.EnableColor = true
            W.SelectedColorIdx = 2
        end
        W.SaveConfig(true)
        W.ShowEmojiColorDialog()
    end,
    btn_toggle_remo = function()
        if W.EnableEmoji and W.EmojiValues[W.SelectedEmojiIdx] == "RANDOM" then
            W.EnableEmoji = false
        else
            W.EnableEmoji = true
            W.SelectedEmojiIdx = 2
        end
        W.SaveConfig(true)
        W.ShowEmojiColorDialog()
    end;
    btn_toggle_wm = function()
        W.WatermarkMode = not W.WatermarkMode
        W.SaveConfig(true)
        W.ShowEmojiColorDialog()
    end;
    btn_toggle_encrypt = function()
        W.EncryptChat = not W.EncryptChat
        W.SaveConfig(true)
        W.ShowEmojiColorDialog()
    end;
    btn_toggle_rb = function()
        W.RainbowSkin = not W.RainbowSkin
        if W.RainbowSkin then
            W.ManageSkinEffects()
        end
        W.SaveConfig(true)
        W.ShowEmojiColorDialog()
    end,
    btn_toggle_bl = function()
        W.BlinkSkin = not W.BlinkSkin
        if W.BlinkSkin then
            W.ManageSkinEffects()
        end
        W.SaveConfig(true)
        W.ShowEmojiColorDialog()
    end;
    skin_black = function()
        W.RainbowSkin = false
        W.BlinkSkin = false
        W.SetSkinColor(0, 0, 0, 1)
        W.LocalChat("`c[WinProxy]: `9Skin changed to `bBlack")
        W.ShowEmojiColorDialog()
    end,
    skin_white = function()
        W.RainbowSkin = false
        W.BlinkSkin = false
        W.SetSkinColor(1, 1, 1, 1)
        W.LocalChat("`c[WinProxy]: `9Skin changed to `wWhite")
        W.ShowEmojiColorDialog()
    end;
    skin_red = function()
        W.RainbowSkin = false
        W.BlinkSkin = false
        W.SetSkinColor(1, 0, 0, 1)
        W.LocalChat("`c[WinProxy]: `9Skin changed to `4Red")
        W.ShowEmojiColorDialog()
    end;
    skin_yellow = function()
        W.RainbowSkin = false
        W.BlinkSkin = false
        W.SetSkinColor(1, 1, 0, 1)
        W.LocalChat("`c[WinProxy]: `9Skin changed to `6Yellow")
        W.ShowEmojiColorDialog()
    end;
    skin_green = function()
        W.RainbowSkin = false
        W.BlinkSkin = false
        W.SetSkinColor(0, 1, 0, 1)
        W.LocalChat("`c[WinProxy]: `9Skin changed to `2Green")
        W.ShowEmojiColorDialog()
    end,
    skin_blue = function()
        W.RainbowSkin = false
        W.BlinkSkin = false
        W.SetSkinColor(0, .4, 1, 1)
        W.LocalChat("`c[WinProxy]: `9Skin changed to `9Blue")
        W.ShowEmojiColorDialog()
    end;
    skin_purple = function()
        W.RainbowSkin = false
        W.BlinkSkin = false
        W.SetSkinColor(.6, .1, .9, 1)
        W.LocalChat("`c[WinProxy]: `9Skin changed to `pPurple")
        W.ShowEmojiColorDialog()
    end;
    skin_pink = function()
        W.RainbowSkin = false
        W.BlinkSkin = false
        W.SetSkinColor(1, .4, .8, 1)
        W.LocalChat("`c[WinProxy]: `9Skin changed to `5Pink")
        W.ShowEmojiColorDialog()
    end,
    btn_logs_menu = function(P)
        W.ShowLogsMenuDialog()
    end;
    btn_toggle_logs = function(P)
        W.LogsEnabled = not W.LogsEnabled
        W.SaveConfig(true)
        W.LocalChat("`c[WinProxy]: `9Activity Logging is now " .. ((W.LogsEnabled and "`2ON" or "`4OFF")))
        W.ShowLogsMenuDialog()
    end,
    btn_clear_logs = function(P)
        W.Logs = { All = {}, Casino = {}; Inventory = {} }
        W.LocalChat("`c[WinProxy]: `9All logs have been cleared.")
        W.ShowLogsMenuDialog()
    end,
    btn_show_all_logs = function(P)
        W.ShowLogDetailDialog("Global Activity Logs", "All", nil)
    end;
    btn_show_casino_logs = function(P)
        W.ShowLogDetailDialog("Casino & Spin Logs", "Casino", nil)
    end;
    btn_show_inv_logs = function(P)
        W.ShowLogDetailDialog("Inventory Logs", "Inventory", nil)
    end;
    btn_show_collect_logs = function(P)
        W.ShowLogDetailDialog("Collect Logs", "Inventory", "Collected")
    end;
    btn_show_drop_logs = function(P)
        W.ShowLogDetailDialog("Drop Logs", "Inventory", "Dropped")
    end;
    btn_toggle_abp = function(P)
        if #W.ABP_Packs == 0 then
            W.LocalChat("`c[WinProxy]: `4Please Auto-Scan the shop first!")
        else
            W.AutoBuyPack = not W.AutoBuyPack
            if W.AutoBuyPack then
                W.ManageABPThread()
            end
        end
        W.ShowAutoBuyPackDialog()
    end,
    btn_scan_abp = function(P)
        if not W.ABP_IsScanningShop then
            W.ABP_IsScanningShop = true
            W.ABP_Packs = {}
            W.ABP_PackNames = {}
            W.ABP_AddedCmds = {}
            RunThread(function()
                W.LocalChat("`c[WinProxy]: `9[1/3] Auto-Scanning \'Featured\' tab...")
                SendPacket(2, "action|store\nlocation|gem")
                Sleep(1200)
                W.LocalChat("`c[WinProxy]: `9[2/3] Auto-Scanning \'Locks & Stuff\' tab...")
                SendPacket(2, "action|buy\nitem|locks")
                Sleep(1200)
                W.LocalChat("`c[WinProxy]: `9[3/3] Auto-Scanning \'Item Packs\' tab...")
                SendPacket(2, "action|buy\nitem|itempack")
                Sleep(1200)
                table.sort(W.ABP_Packs, function(P, j)
                    return P.name:lower() < j.name:lower()
                end)
                W.ABP_PackNames = {}
                for P, j in ipairs(W.ABP_Packs) do
                    table.insert(W.ABP_PackNames, j.name)
                end
                W.ABP_PackIdx = 1
                W.ABP_IsScanningShop = false
                W.LocalChat("`c[WinProxy]: `2[+] Auto-Scan Complete! Absorbed `w" .. (#W.ABP_Packs .. "`2 items (Sorted A-Z)."))
                Sleep(300)
                W.ShowAutoBuyPackDialog()
            end)
        end
    end;
    btn_abp_select_menu = function(P)
        W.ShowABPPackListDialog()
    end,
    btn_abp_back = function(P)
        W.ShowAutoBuyPackDialog()
    end;
    btn_toggle_abp_only = function(P)
        W.ABP_BuyOnly = not W.ABP_BuyOnly
        W.SaveConfig(true)
        W.ShowAutoBuyPackDialog()
    end,
    btn_toggle_abp_batch = function(P)
        W.ABP_BatchMode = not W.ABP_BatchMode
        W.SaveConfig(true)
        W.ShowAutoBuyPackDialog()
    end,
    btn_save_abp = function(P)
        local j = tonumber(P:match("input_abp_amount|(%d+)"))
        local Y = tonumber(P:match("input_abp_dropx|(%d+)"))
        local X = tonumber(P:match("input_abp_dropy|(%d+)"))
        if j then
            W.ABP_BuyAmount = j
        end
        if Y then
            W.ABP_DropX = Y
        end
        if X then
            W.ABP_DropY = X
        end
        W.SaveConfig(true)
        W.LocalChat("`c[WinProxy]: `9Auto Buy Pack settings saved!")
        W.ShowAutoBuyPackDialog()
    end,
    btn_do_search_item = function(P)
        W.SearchItemInput = P:match("input_search_item|([^|\n]*)") or ""
        W.SearchItem(W.SearchItemInput)
        W.ShowItemDBDialog()
    end,
    btn_save_config = function(P)
        W.SaveConfig()
        W.ShowSettingDialog()
    end,
    btn_load_config = function(P)
        W.LoadConfig()
        W.ShowSettingDialog()
    end;
    btn_reset_config = function(P)
        W.ResetConfig()
        W.ShowSettingDialog()
    end;
    info_copy_wa = function(j)
        if P then
            local P = io.popen("echo https://chat.whatsapp.com/IuQ3YdLm2lf4EnnCF1GcXr?mode=gi_t | clip", "w")
            if P then
                P:close()
            end
            LogToConsole("`2[WinProxy]: `9WhatsApp link copied to clipboard!")
        else
            LogToConsole("`2[WinProxy]: `9Link WA: https://chat.whatsapp.com/IuQ3YdLm2lf4EnnCF1GcXr?mode=gi_t")
        end
    end,
    info_copy_dc = function(P)
        local j = io.popen("echo https://discord.gg/kUuE2f98FK | clip", "w")
        if j then
            j:close()
        end
        LogToConsole("`2[WinProxy]: `9Discord link copied to clipboard!")
    end
}
for P = 1, 5, 1 do
    K["btn_apt_mypos_" .. P] = function(j)
        local Y = GetLocal()
        if Y and Y.pos then
            W.AutoPullPos[P].x = math.floor(Y.pos.x / 32)
            W.AutoPullPos[P].y = math.floor(Y.pos.y / 32)
            W.SaveConfig(true)
            W.LocalChat("`c[WinProxy]: `2Pos " .. (P .. (" set to your position: (" .. (W.AutoPullPos[P].x .. (", " .. (W.AutoPullPos[P].y .. ")"))))))
        end
        W.ShowAPTPositionsDialog()
    end
    K["btn_apt_touch_" .. P] = function(j)
        W.AutoPullSettingSlot = P
        W.LocalChat("`c[WinProxy]: `9Touch any tile on screen to set `2Pos " .. P)
    end
    K["btn_apt_clear_" .. P] = function(j)
        W.AutoPullPos[P].x = 0
        W.AutoPullPos[P].y = 0
        W.SaveConfig(true)
        W.LocalChat("`c[WinProxy]: `4Pos " .. (P .. " cleared!"))
        W.ShowAPTPositionsDialog()
    end
end

-- ========================================================================
-- SECTION 15: Hook - outgoing packets (slash-commands, dialog returns, chat decoration)
-- ========================================================================

function W.OnOutgoingPacket(P, j)
    if j:find("action|join_request") or j:find("action|respawn") then
        W.AutoPullSuppressUntil = os.clock() + 3
    end
    if P == 2 and (j:find("dialog_name|popup") and (j:find("buttonClicked|pull") and not W.SpamPullSending)) then
        local P = tonumber(j:match("netID|(%d+)"))
        if P then
            W.LastPulledNetID = P
            W.LastPulledName = W.GetPlayerNameByNetID(P)
            W.LastPulledTime = os.clock()
            if W.SpamPull or W.AutoSpamPull then
                W.TriggerSpamPull(P, W.LastPulledName)
            end
        end
    end
    if P == 2 and j:find("buttonClicked|win_profile") then
        local P = "set_default_color|\n"
        P = P .. "add_player_info|`2@Win `c[Win Community]|2737|0|49800300|\n"
        P = P .. "add_spacer|small|\n"
        P = P .. "add_label|small|Account Net. Worth: Unlimited|left|\n"
        P = P .. "add_spacer|small|\n"
        P = P .. ("add_label_with_icon|small|Kit Level: Unlimited|left|" .. (W.GetIcon("Golden Sword", 604) .. "|\n"))
        P = P .. "add_spacer|small|\n"
        P = P .. ("add_label_with_icon|small|Total Gems: Unlimited|left|" .. (W.GetIcon("Gems", 112) .. "|\n"))
        P = P .. "add_spacer|small|\n"
        P = P .. ("add_label_with_icon|small|Total World Locks: Unlimited|left|" .. (W.GetIcon("Creativeps Diamond Lock", 1796) .. "|\n"))
        P = P .. ("add_label_with_icon|small|Total BGLs in the Bank: Unlimited|left|" .. (W.GetIcon("Creativeps Blue Gem Lock", 7188) .. "|\n"))
        P = P .. ("add_label_with_icon|small|Total Black Gem Locks: Unlimited|left|" .. (W.GetIcon("Creativeps Black Gem Lock", 11550) .. "|\n"))
        P = P .. "add_spacer|small|\n"
        P = P .. ("add_label_with_icon|small|Total Growtokens: Unlimited|left|" .. (W.GetIcon("Growtoken", 1486) .. "|\n"))
        P = P .. "add_spacer|small|\n"
        P = P .. ("add_label_with_icon|small|Total Tax Credits: Unlimited|left|" .. (W.GetIcon("Telephone", 3898) .. "|\n"))
        P = P .. "add_spacer|small|\n"
        P = P .. ("add_label_with_icon|small|Total Worlds Owned: All worlds belong to Win|left|" .. (W.GetIcon("Creativeps World Lock", 242) .. "|\n"))
        P = P .. "add_spacer|small|\n"
        P = P .. "add_label|small|Total Backpack Space: Unlimited|left|\n"
        P = P .. "add_spacer|small|\n"
        P = P .. "add_button|leaderboard|Back|noflags|0|0|\n"
        P = P .. "end_dialog|social||\n"
        SendVariantList({ [0] = "OnDialogRequest"; [1] = P })
        return true
    end
    if P == 3 and (j:find("action|join_request") and j:find("name|WIN COMMUNITY")) then
        local P = j:gsub("name|WIN COMMUNITY", "name|WIN")
        SendPacket(3, P)
        W.LocalChat("`c[WinProxy]: `9Warping to `2WIN `9(via WIN COMMUNITY button)...")
        return true
    end
    if j:find("text|/apblacklist add ") then
        local P = j:match("text|/apblacklist add (%d+)")
        if P then
            P = tonumber(P)
            local j = false
            for Y, X in ipairs(W.AutoPullBlacklist) do
                if X == P then
                    j = true
                    break
                end
            end
            if not j then
                table.insert(W.AutoPullBlacklist, P)
                W.SaveConfig(true)
                W.LocalChat("`c[WinProxy]: `9Added UID " .. (P .. " to Auto Pull blacklist."))
            else
                W.LocalChat("`c[WinProxy]: `4UID " .. (P .. " is already in blacklist."))
            end
        else
            W.LocalChat("`c[WinProxy]: `4Usage: /apblacklist add <UserID>")
        end
        return true
    elseif j:find("text|/apblacklist remove ") then
        local P = j:match("text|/apblacklist remove (%d+)")
        if P then
            P = tonumber(P)
            local j = {}
            local Y = false
            for X, M in ipairs(W.AutoPullBlacklist) do
                if M ~= P then
                    table.insert(j, M)
                else
                    Y = true
                end
            end
            W.AutoPullBlacklist = j
            if Y then
                W.SaveConfig(true)
                W.LocalChat("`c[WinProxy]: `9Removed UID " .. (P .. " from blacklist."))
            else
                W.LocalChat("`c[WinProxy]: `4UID " .. (P .. " not found in blacklist."))
            end
        else
            W.LocalChat("`c[WinProxy]: `4Usage: /apblacklist remove <UserID>")
        end
        return true
    elseif j:find("text|/apblacklist list") then
        if #W.AutoPullBlacklist == 0 then
            W.LocalChat("`c[WinProxy]: `9Blacklist is empty.")
        else
            local P = "`c[WinProxy]: `9Blacklist: "
            for j, Y in ipairs(W.AutoPullBlacklist) do
                P = P .. (Y .. ((j < #W.AutoPullBlacklist and ", " or "")))
                if #P > 80 then
                    W.LocalChat(P)
                    P = "`c[WinProxy]: "
                end
            end
            if P ~= "" then
                W.LocalChat(P)
            end
        end
        return true
    elseif j:find("text|/autocv$") then
        W.AutoCVLocks = not W.AutoCVLocks
        W.SaveConfig(true)
        W.LocalChat("`c[WinProxy]: `9Auto CV All Locks is now " .. ((W.AutoCVLocks and "`2ON" or "`4OFF")))
        return true
    end
    if P == 2 and j:find("dialog_name|drop") then
        local P = j:match("item_drop|(%d+)")
        local Y = j:match("item_count|(%d+)")
        if P and Y then
            local j = tonumber(P)
            local X = "Item ID " .. P
            local M, z = pcall(function()
                return GetItemInfo(j)
            end)
            if M and (z and z.name) then
                X = z.name
            end
            W.AddLog("Inventory", "Dropped " .. (Y .. (" " .. X)))
        end
    end
    if P == 2 and j:find("action|dialog_return") then
        local P = j:match("buttonClicked|([^|\n]+)")
        if P then
            if P == "take_all_sbox" then
                if not W.StorageBoxState.item_queue or #W.StorageBoxState.item_queue == 0 then
                    W.LocalChat("`c[WinProxy]: `4[Storage] Storage Box is already empty!")
                    return true
                end
                local P, j = W.GetNextWithdrawableStorageItem(W.StorageBoxState.item_queue)
                if not P or j <= 0 then
                    P = W.StorageBoxState.item_queue[1]
                end
                if not P then
                    W.LocalChat("`c[WinProxy]: `4[Storage] Storage Box is already empty!")
                    return true
                end
                local Y = W.StorageBoxState.last_x or 0
                local X = W.StorageBoxState.last_y or 0
                local M = P.raw_btn or ("item_" .. P.hash)
                W.StorageBoxState.active_withdraw = true
                W.StorageBoxState.current_item = P
                W.StorageBoxState.last_action_time = os.time()
                W.StorageBoxState.just_withdrawn_hash = P.hash
                W.StorageBoxState.just_withdrawn_btn = M
                W.StorageBoxState.just_withdrawn_count = P.count
                W.StorageBoxState.just_withdrawn_clock = os.clock()
                W.StorageBoxState.withdrawn_hashes = { [tostring(P.hash)] = true, [tostring(M)] = true }
                RunThread(function()
                    Sleep(20)
                    SendPacket(2, "action|dialog_return\ndialog_name|storage\nx|" .. (Y .. ("|\ny|" .. (X .. ("|\nbuttonClicked|" .. (M .. "\n"))))))
                end)
                return true
            end
            if P:find("^item_") and W.StorageFilter then
                W.StorageBoxState.active_withdraw = false
                for j, Y in ipairs(W.StorageBoxState.item_queue) do
                    if Y.raw_btn == P then
                        W.StorageBoxState.current_item = Y
                        break
                    end
                end
            end
            if P:find("^ap_remove_") then
                local j = P:match("ap_remove_(%d+)")
                if j then
                    local P = tonumber(j)
                    if P and P <= #W.AutoPullBlacklist then
                        table.remove(W.AutoPullBlacklist, P)
                        W.SaveConfig(true)
                        W.LocalChat("`c[WinProxy]: `9Removed UID from blacklist.")
                        W.ShowAutoPullDialog()
                        return true
                    end
                end
            end
            if P:find("^abp_sel_") then
                local j = tonumber(P:match("abp_sel_(%d+)"))
                if j and j <= #W.ABP_Packs then
                    W.ABP_PackIdx = j
                    W.SaveConfig(true)
                    W.LocalChat("`c[WinProxy]: `9Selected Pack: `2" .. W.ABP_Packs[j].name)
                    W.ShowAutoBuyPackDialog()
                    return true
                end
            end
            if K[P] then
                K[P](j)
                return true
            end
        end
    end
    if P == 2 and j:find("text|/proxy") then
        W.ShowImGui = not W.ShowImGui
        W.SaveConfig(true)
        W.LocalChat("`c[WinProxy]: `9ImGui Menu is now " .. ((W.ShowImGui and "`2OPEN" or "`4CLOSED")))
        return true
    end
    if P == 2 and ((j:find("text|/menu") or j:find("text|/help"))) then
        W.ShowMainDialog()
        return true
    end
    if P == 2 and (j:find("text|/cmd")) then
        W.ShowCommandsDialog()
        return true
    end
    if P == 2 and j:find("action|input\n|text|") then
        local P = j:match("text|(.+)")
        if P then
            local Y = P:match("^(/%S+)")
            if Y then
                for P, j in pairs(W.CustomCommands) do
                    if j.orig == Y and j.disableOrig then
                        W.LocalChat("`c[WinProxy]: `4Command " .. (Y .. (" is disabled! `wUse your alias: `2" .. P)))
                        return true
                    end
                end
            end
            if Y and W.CustomCommands[Y] then
                local X = W.CustomCommands[Y]
                local M = Y:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
                P = P:gsub("^" .. M, X.orig, 1)
                j = j:gsub("text|" .. M, "text|" .. X.orig, 1)
            end
            if P == "/logsmenu" then
                W.ShowLogsMenuDialog()
                return true
            elseif P == "/clogs" then
                W.ShowLogDetailDialog("Collect Logs", "Inventory", "Collected")
                return true
            elseif P == "/dlogs" then
                W.ShowLogDetailDialog("Drop Logs", "Inventory", "Dropped")
                return true
            elseif P == "/invlogs" then
                W.ShowLogDetailDialog("Inventory Logs", "Inventory", nil)
                return true
            elseif P == "/slogs" then
                W.ShowLogDetailDialog("Casino & Spin Logs", "Casino", nil)
                return true
            elseif P == "/logs" then
                W.LogsEnabled = not W.LogsEnabled
                W.SaveConfig(true)
                W.LocalChat("`c[WinProxy]: `9Activity Logging is now " .. ((W.LogsEnabled and "`2ON" or "`4OFF")))
                return true
            elseif P == "/emojimenu" then
                W.ShowEmojiColorDialog()
                return true
            elseif P == "/emoji" then
                W.EnableEmoji = not W.EnableEmoji
                W.SaveConfig(true)
                W.LocalChat("`c[WinProxy]: `9Random Emoji Mode is now " .. ((W.EnableEmoji and "`2ON" or "`4OFF")))
                return true
            elseif P == "/watermark" then
                W.WatermarkMode = not W.WatermarkMode
                W.SaveConfig(true)
                W.LocalChat("`c[@Win]: `9Chat Watermark is now " .. ((W.WatermarkMode and "`2ON" or "`4OFF")))
                return true
            elseif P == "/encrypt" then
                W.EncryptChat = not W.EncryptChat
                W.SaveConfig(true)
                W.LocalChat("`c[WinProxy]: `9Encrypt Chat is now " .. ((W.EncryptChat and "`2ON" or "`4OFF")))
                return true
            elseif P == "/settingmenu" then
                W.ShowSettingDialog()
                return true
            elseif P == "/aliasmenu" then
                W.ShowCustomCommandsDialog()
                return true
            elseif P == "/magmenu" then
                W.ShowMagplantDialog()
                return true
            elseif P == "/stopmag" then
                W.MagRunning = false
                W.MagSelectID = nil
                W.VendFindID = "1656"
                W.VendDelay = 150
                W.VendFromWorld = ""
                W.VendFromX = "0"
                W.VendFromY = "0"
                W.VendTargetX = "0"
                W.VendTargetY = "0"
                W.VendDropWorld = ""
                W.VendDropX = "0"
                W.VendDropY = "0"
                W.VendSetMode = "walk"
                W.VendAutoWalk = false
                W.VendSelectingTarget = false
                W.VendSelectingFrom = false
                W.VendSelectingDrop = false
                W.VendRunning = false
                W.VendMode = ""
                W.VendDone = false
                W.VendX = 0
                W.VendY = 0
                W.VendM2MTakeWorld = ""
                W.VendM2MTakeX = "0"
                W.VendM2MTakeY = "0"
                W.VendM2MPutWorld = ""
                W.VendM2MPutX = "0"
                W.VendM2MPutY = "0"
                W.VendM2MAutoMove = false
                W.VendSelectingM2MTake = false
                W.VendSelectingM2MPut = false
                W.VendSelectID = nil
                W.VendPrice = "1"
                W.VendPriceMode = "peritem"
                W.LocalChat("`c[WinProxy]: `4Magplant tasks stopped!")
                return true
            end
            if P:sub(1, 1) ~= "/" then
                local j = ""
                local Y = false
                if W.EncryptChat then
                    P = W.Base64Encode(W.XORCipher(P, W.EncryptKey))
                end
                if W.WatermarkMode then
                    j = j .. "`c[@Win]`0 "
                    Y = true
                end
                if W.EnableEmoji then
                    local P = W.EmojiValues[W.SelectedEmojiIdx]
                    if P == "RANDOM" then
                        j = j .. (W.RandomEmojiList[math.random(1, #W.RandomEmojiList)] .. " ")
                        Y = true
                    elseif P ~= "" then
                        j = j .. (P .. " ")
                        Y = true
                    end
                end
                if Y then
                    j = j:sub(1, -2) .. " : "
                end
                if W.EnableColor then
                    local P = W.ColorValues[W.SelectedColorIdx]
                    if P == "RANDOM" then
                        j = j .. W.RandomColorList[math.random(1, #W.RandomColorList)]
                    else
                        j = j .. P
                    end
                end
                if j ~= "" or W.EncryptChat then
                    SendPacket(2, "action|input\n|text|" .. (j .. P))
                    return true
                end
            end
        end
    end
    if P == 2 then
        if j:find("text|/wrenchmenu") then
            W.ShowWrenchDialog()
            return true
        elseif j:find("text|/autopullmenu") then
            W.ShowAutoPullDialog()
            return true
        elseif j:find("text|/wrp$") then
            W.ToggleWrench(1, false)
            return true
        elseif j:find("text|/wrk$") then
            W.ToggleWrench(2, false)
            return true
        elseif j:find("text|/wrb$") then
            W.ToggleWrench(3, false)
            return true
        elseif j:find("text|/wrt$") then
            W.ToggleWrench(4, false)
            return true
        elseif j:find("text|/wrps$") then
            W.ToggleWrench(1, true)
            return true
        elseif j:find("text|/wrks$") then
            W.ToggleWrench(2, true)
            return true
        elseif j:find("text|/wrbs$") then
            W.ToggleWrench(3, true)
            return true
        elseif j:find("text|/wrts$") then
            W.ToggleWrench(4, true)
            return true
        elseif j:find("text|/donatemenu") then
            W.ShowDonateDialog()
            return true
        elseif j:find("text|/dmode") then
            W.DonateMode = not W.DonateMode
            if not W.DonateMode then
                W.DonateBoxX = 0
                W.DonateBoxY = 0
                W.LocalChat("`c[WinProxy]: `eDonate Mode `4Disabled")
            else
                W.LocalChat("`c[WinProxy]: `eDonate Mode `2Enabled`0. Wrench a Donate Box to set position!")
            end
            W.SaveConfig(true)
            return true
        elseif j:find("text|/pw ") then
            local P = tonumber(j:match("text|/pw (%d+)"))
            if P then
                W.DoDonate(W.GetIcon("Creativeps World Lock", 242), P)
            end
            return true
        elseif j:find("text|/pd ") then
            local P = tonumber(j:match("text|/pd (%d+)"))
            if P then
                W.DoDonate(W.GetIcon("Creativeps Diamond Lock", 1796), P)
            end
            return true
        elseif j:find("text|/pb ") then
            local P = tonumber(j:match("text|/pb (%d+)"))
            if P then
                W.DoDonate(W.GetIcon("Creativeps Blue Gem Lock", 7188), P)
            end
            return true
        elseif j:find("text|/pbl ") then
            local P = tonumber(j:match("text|/pbl (%d+)"))
            if P then
                W.DoDonate(W.GetIcon("Creativeps Black Gem Lock", 11550), P)
            end
            return true
        elseif j:find("text|/pall") then
            W.DonateAllLocks()
            return true
        elseif j:find("text|/takeall") then
            if W.DonateMode and W.DonateBoxX ~= 0 then
                SendPacket(2, "action|dialog_return\ndialog_name|donate_edit|\nx|" .. (W.DonateBoxX .. ("|\ny|" .. (W.DonateBoxY .. "|\nbuttonClicked|withdrawall"))))
                W.LocalChat("`c[WinProxy]: `9Retrieving all items from Donation Box...")
            else
                W.LocalChat("`c[WinProxy]: `4Please enable /dmode and set a box position first!")
            end
            return true
        elseif j:find("text|/trademenu") then
            W.ShowTradeDialog()
            return true
        elseif j:find("text|/tmode") then
            W.ToggleWrench(4)
            return true
        elseif j:find("text|/tw ") then
            local P = tonumber(j:match("text|/tw (%d+)"))
            if P then
                W.FastTradeAdd(W.GetIcon("Creativeps World Lock", 242), P)
            end
            return true
        elseif j:find("text|/td ") then
            local P = tonumber(j:match("text|/td (%d+)"))
            if P then
                W.FastTradeAdd(W.GetIcon("Creativeps Diamond Lock", 1796), P)
            end
            return true
        elseif j:find("text|/tb ") then
            local P = tonumber(j:match("text|/tb (%d+)"))
            if P then
                W.FastTradeAdd(W.GetIcon("Creativeps Blue Gem Lock", 7188), P)
            end
            return true
        elseif j:find("text|/tbl ") then
            local P = tonumber(j:match("text|/tbl (%d+)"))
            if P then
                W.FastTradeAdd(W.GetIcon("Creativeps Black Gem Lock", 11550), P)
            end
            return true
        elseif j:find("text|/tall") then
            W.TradeAllLocks()
            return true
        elseif j:find("text|/tclear") then
            W.TradeClearLocks()
            return true
        elseif j:find("text|/telemenu") then
            W.ShowTelephoneDialog()
            return true
        elseif j:find("text|/cvdl") then
            W.TeleMode = (W.TeleMode == 3) and 0 or 3
            W.LocalChat("`c[WinProxy]: `9Auto Convert DL to BGL is now " .. ((W.TeleMode == 3 and "`2ON" or "`4OFF")))
            W.SaveConfig(true)
            return true
        elseif j:find("text|/buybgl") then
            W.TeleMode = (W.TeleMode == 2) and 0 or 2
            W.LocalChat("`c[WinProxy]: `9Auto Buy BGL is now " .. ((W.TeleMode == 2 and "`2ON" or "`4OFF")))
            W.SaveConfig(true)
            return true
        elseif j:find("text|/buydl") then
            W.TeleMode = (W.TeleMode == 1) and 0 or 1
            W.LocalChat("`c[WinProxy]: `9Auto Buy DL is now " .. ((W.TeleMode == 1 and "`2ON" or "`4OFF")))
            W.SaveConfig(true)
            return true
        elseif j:find("text|/buychamp") and not j:find("text|/buychampbulk") then
            W.TeleMode = (W.TeleMode == 4) and 0 or 4
            W.LocalChat("`c[WinProxy]: `9Auto Buy Champagne is now " .. ((W.TeleMode == 4 and "`2ON" or "`4OFF")))
            W.SaveConfig(true)
            return true
        elseif j:find("text|/buychampbg") then
            W.TeleMode = (W.TeleMode == 5) and 0 or 5
            W.LocalChat("`c[WinProxy]: `9Auto Buy Champagne (BGems) is now " .. ((W.TeleMode == 5 and "`2ON" or "`4OFF")))
            W.SaveConfig(true)
            return true
        elseif j:find("text|/buychampbulk") then
            W.TeleMode = (W.TeleMode == 6) and 0 or 6
            W.LocalChat("`c[WinProxy]: `9Auto Buy Bulk Champagne is now " .. ((W.TeleMode == 6 and "`2ON" or "`4OFF")))
            W.SaveConfig(true)
            return true
        elseif j:find("text|/casinomenu") then
            W.ShowCasinoDialog()
            return true
        elseif j:find("text|/allmode") then
            W.CasinoMode = (W.CasinoMode == 7) and 0 or 7
            W.SaveConfig(true)
            SendPacket(2, "action|input\n|text|`c[WinProxy]: " .. (((W.CasinoMode == 7 and "`2Enabled" or "`4Disabled")) .. " All Casino Mode"))
            return true
        elseif j:find("text|/reme") then
            W.CasinoMode = (W.CasinoMode == 1) and 0 or 1
            W.SaveConfig(true)
            SendPacket(2, "action|input\n|text|`c[WinProxy]: " .. (((W.CasinoMode == 1 and "`2Enabled" or "`4Disabled")) .. " Reme Mode"))
            return true
        elseif j:find("text|/qeme") then
            W.CasinoMode = (W.CasinoMode == 2) and 0 or 2
            W.SaveConfig(true)
            SendPacket(2, "action|input\n|text|`c[WinProxy]: " .. (((W.CasinoMode == 2 and "`2Enabled" or "`4Disabled")) .. " Qeme Mode"))
            return true
        elseif j:find("text|/lemes") then
            W.CasinoMode = (W.CasinoMode == 4) and 0 or 4
            W.SaveConfig(true)
            SendPacket(2, "action|input\n|text|`c[WinProxy]: " .. (((W.CasinoMode == 4 and "`2Enabled" or "`4Disabled")) .. " Leme S Mode"))
            return true
        elseif j:find("text|/leme") then
            W.CasinoMode = (W.CasinoMode == 3) and 0 or 3
            W.SaveConfig(true)
            SendPacket(2, "action|input\n|text|`c[WinProxy]: " .. (((W.CasinoMode == 3 and "`2Enabled" or "`4Disabled")) .. " Leme Mode"))
            return true
        elseif j:find("text|/ceme") then
            W.CasinoMode = (W.CasinoMode == 5) and 0 or 5
            W.SaveConfig(true)
            SendPacket(2, "action|input\n|text|`c[WinProxy]: " .. (((W.CasinoMode == 5 and "`2Enabled" or "`4Disabled")) .. " Ceme Mode"))
            return true
        elseif j:find("text|/lewa") then
            local P = j:match("text|/lewa%s+(%d+)")
            if P then
                local j = tonumber(P)
                if j < 5 then
                    j = 5
                end
                if j > 7 then
                    j = 7
                end
                W.CasinoLewaMulti = j
                W.CasinoMode = 6
                W.SaveConfig(true)
                SendPacket(2, "action|input\n|text|`c[WinProxy]: `2Enabled Lewa Mode (Multi: " .. (W.CasinoLewaMulti .. ")"))
            else
                W.CasinoMode = (W.CasinoMode == 6) and 0 or 6
                W.SaveConfig(true)
                SendPacket(2, "action|input\n|text|" .. ((W.CasinoMode == 6 and "`c[WinProxy]: `2Enabled Lewa Mode (Multi: " .. (W.CasinoLewaMulti .. ")") or "`c[WinProxy]: `4Disabled Lewa Mode")))
            end
            return true
        elseif j:find("text|/autochamp") or j:find("text|/autocmp") then
            W.AutoChampWheel = not W.AutoChampWheel
            W.SaveConfig(true)
            W.LocalChat("`c[WinProxy]: `9Auto Use Champagne Before Spin is now " .. ((W.AutoChampWheel and "`2ON" or "`4OFF")))
            return true
        elseif j:find("text|/cmp") then
            local P, j = W.UseChampagne()
            if P then
                W.LocalChat("`c[WinProxy]: `2Used 1 Champagne from inventory.")
            else
                W.LocalChat("`c[WinProxy]: `4[Champagne] " .. ((j or "Failed to use champagne!")))
            end
            return true
        elseif j:find("text|/blue") then
            SendPacket(2, "action|dialog_return\ndialog_name|info_box\nbuttonClicked|make_bluegl")
            return true
        elseif j:find("text|/black") then
            SendPacket(2, "action|dialog_return\ndialog_name|info_box\nbuttonClicked|make_bgl")
            return true
        elseif j:find("text|/depo") then
            local P = j:match("text|/depo (%d+)")
            if P then
                SendPacket(2, "action|dialog_return\ndialog_name|bank_deposit\nbgl_count|" .. P)
                W.BankBalance = W.BankBalance + tonumber(P)
                W.LocalChat("`c[WinProxy]: `9Deposited `4" .. (P .. " `eBlue Gem Locks`4!"))
            else
                local P = 0
                for j, Y in pairs(GetInventory()) do
                    if Y.id == W.GetIcon("Creativeps Blue Gem Lock", 7188) then
                        P = P + Y.amount
                    end
                    if Y.id == W.GetIcon("Creativeps Black Gem Lock", 11550) then
                        P = P + (Y.amount * 100)
                    end
                end
                if P > 0 then
                    SendPacket(2, "action|dialog_return\ndialog_name|bank_deposit\nbgl_count|" .. P)
                    W.BankBalance = W.BankBalance + P
                    W.LocalChat("`c[WinProxy]: `9Deposited All (`4" .. (P .. " BGL equivalent`9)`4!"))
                else
                    W.LocalChat("`c[WinProxy]: `4You don\'t have any Blue Gem Locks to deposit!")
                end
            end
            return true
        elseif j:find("text|/with") then
            local P = j:match("text|/with (%d+)")
            if P then
                local j = tonumber(P)
                SendPacket(2, "action|dialog_return\ndialog_name|bank_withdraw\nbgl_count|" .. j)
                W.BankBalance = math.max(0, W.BankBalance - j)
                W.LocalChat("`c[WinProxy]: `9Withdrew `4" .. (j .. " `eBlue Gem Locks`4!"))
            else
                if W.BankBalance > 0 then
                    SendPacket(2, "action|dialog_return\ndialog_name|bank_withdraw\nbgl_count|" .. W.BankBalance)
                    W.LocalChat("`c[WinProxy]: `9Withdrew All (`4" .. (W.BankBalance .. " `eBGLs`9) from Bank`4!"))
                    W.BankBalance = 0
                else
                    W.LocalChat("`c[WinProxy]: `4Error! `9Bank memory is 0. Please open your Bank manually once to sync, or use `w/with <amount>")
                end
            end
            return true
        elseif j:find("text|/dw ") then
            local P = tonumber(j:match("text|/dw (%d+)"))
            if P then
                W.SmartDropLock(1, P)
            else
                W.LocalChat("`c[WinProxy]: `4Invalid amount!")
            end
            return true
        elseif j:find("text|/dd ") then
            local P = tonumber(j:match("text|/dd (%d+)"))
            if P then
                W.SmartDropLock(2, P)
            else
                W.LocalChat("`c[WinProxy]: `4Invalid amount!")
            end
            return true
        elseif j:find("text|/db ") and not j:find("text|/dbl") then
            local P = tonumber(j:match("text|/db (%d+)"))
            if P then
                W.SmartDropLock(3, P)
            else
                W.LocalChat("`c[WinProxy]: `4Invalid amount!")
            end
            return true
        elseif j:find("text|/dbl ") then
            local P = tonumber(j:match("text|/dbl (%d+)"))
            if P then
                W.SmartDropLock(4, P)
            else
                W.LocalChat("`c[WinProxy]: `4Invalid amount!")
            end
            return true
        elseif j:find("text|/daw$") then
            RunThread(function()
                local P = {
                    [W.GetIcon("Creativeps World Lock", 242)] = "WL"; [W.GetIcon("Creativeps Diamond Lock", 1796)] = "DL",
                    [W.GetIcon("Creativeps Blue Gem Lock", 7188)] = "BGL", [W.GetIcon("Creativeps Black Gem Lock", 11550)] = "Black GL"
                }
                local j = false
                for Y, X in pairs(GetInventory()) do
                    if P[X.id] and X.amount > 0 then
                        SendPacket(2, "action|dialog_return\ndialog_name|drop\nitem_drop|" .. (X.id .. ("|\nitem_count|" .. X.amount)))
                        Sleep(400)
                        j = true
                    end
                end
                if j then
                    W.LocalChat("`c[WinProxy]: `2Success `0Dropped all locks in backpack!")
                else
                    W.LocalChat("`c[WinProxy]: `4No locks found in backpack.")
                end
            end)
            return true
        elseif j:find("text|/calcmenu") then
            W.ShowCalculatorDialog()
            return true
        elseif j:find("text|/calc ") then
            local P = j:match("text|/calc (.*)")
            if P then
                W.CalcInput = P
                local j, Y, X = W.CalculateMath(P)
                if j then
                    W.LocalChat("`c[WinProxy]: `0Calc : " .. (Y .. (" = `2" .. X)))
                else
                    W.LocalChat("`c[WinProxy]: " .. W.CalcResult)
                end
            end
            return true
        elseif j:find("text|/spampull now$") or j:find("text|/spampullnow$") then
            W.TriggerSpamPull()
            return true
        elseif j:find("text|/spampull$") or j:find("text|/spampulltoggle$") or j:find("text|/togglespampull$") or j:find("text|/autospampull$") then
            W.SpamPull = not ((W.SpamPull or W.AutoSpamPull))
            W.AutoSpamPull = W.SpamPull
            W.SaveConfig(true)
            W.LocalChat("`c[WinProxy]: `9Spam Pull is now " .. ((W.SpamPull and "`2ON `9(Auto 3s on every pull)" or "`4OFF")))
            return true
        elseif j:find("text|/repull$") or j:find("text|/rp$") then
            W.ExecuteRePullOnce()
            return true
        elseif j:find("text|/setrepullkey%s+(%S+)") then
            local P = j:match("text|/setrepullkey%s+(%S+)")
            W.SetRePullHotkey(P)
            return true
        elseif j:find("text|/spammenu") then
            W.ShowSpamDialog()
            return true
        elseif ((j:find("text|/spam$") or j:find("text|/spam "))) and (not j:find("text|/spampull") and (not j:find("text|/spamtext") and (not j:find("text|/spammenu") and (not j:find("text|/addspam") and not j:find("text|/removespam"))))) then
            W.ToggleSpam(not W.SpamEnabled)
            return true
        elseif j:find("text|/addspam ") then
            local P = j:match("text|/addspam (.+)")
            if P then
                table.insert(W.SpamTexts, P)
                W.LocalChat("`c[WinProxy]: `9Added new spam text: `w" .. P)
            end
            return true
        elseif j:find("text|/removespam") then
            if #W.SpamTexts > 1 then
                table.remove(W.SpamTexts)
                W.LocalChat("`c[WinProxy]: `9Removed the last spam text field.")
            else
                W.SpamTexts[1] = ""
                W.LocalChat("`c[WinProxy]: `9Cleared the first spam text field.")
            end
            return true
        elseif j:find("text|/spamtext ") then
            local P, Y = j:match("text|/spamtext (%d+) (.+)")
            if P and Y then
                local j = tonumber(P)
                if j > 0 and j <= #W.SpamTexts then
                    W.SpamTexts[j] = Y
                    W.LocalChat("`c[WinProxy]: `9Typer Text " .. (j .. (" set to: `w" .. Y)))
                else
                    W.LocalChat("`c[WinProxy]: `4Invalid field number! You only have " .. (#W.SpamTexts .. " fields."))
                end
            else
                W.LocalChat("`c[WinProxy]: `4Usage: /spamtext <number> <text>")
            end
            return true
        elseif j:find("text|/sbmenu") then
            W.ShowSBDialog()
            return true
        elseif j:find("text|/sbstart") then
            local P = j:find("text|/sbstart%s+reset")
            W.StartSB(P ~= nil)
            return true
        elseif j:find("text|/sbstop") then
            W.StopSB()
            return true
        elseif j:find("text|/sbreset") then
            W.ResetSB()
            W.LocalChat("`c[WinProxy]: `2SB Count and statistics reset to 0!")
            return true
        elseif j:find("text|/sdbstart") then
            local P = j:find("text|/sdbstart%s+reset")
            W.StartSDB(P ~= nil)
            return true
        elseif j:find("text|/sdbstop") then
            W.StopSDB()
            return true
        elseif j:find("text|/sdbreset") then
            W.ResetSDB()
            W.LocalChat("`c[WinProxy]: `2SDB Count reset to 0!")
            return true
        elseif j:find("text|/testpush$") then
            local P = "--- PushStyleColor Test ---\n"
            local j, Y = pcall(ImGui.PushStyleColor, ImGui.Col.WindowBg, ImVec4(1, 0, 0, 1))
            if j then
                pcall(ImGui.PopStyleColor, 1)
            end
            P = P .. ("Syntax 1 (ImVec4): " .. (tostring(j) .. (" - " .. (tostring(Y) .. "\n"))))
            local X, M = pcall(ImGui.PushStyleColor, ImGui.Col.WindowBg, 1, 0, 0, 1)
            if X then
                pcall(ImGui.PopStyleColor, 1)
            end
            P = P .. ("Syntax 2 (R,G,B,A): " .. (tostring(X) .. (" - " .. (tostring(M) .. "\n"))))
            local z, o = pcall(ImGui.PushStyleColor, ImGui.Col.WindowBg, 4278190335)
            if z then
                pcall(ImGui.PopStyleColor, 1)
            end
            P = P .. ("Syntax 3 (U32): " .. (tostring(z) .. (" - " .. (tostring(o) .. "\n"))))
            local q = io.open("testpush_dump.txt", "w")
            if q then
                q:write(P)
                q:close()
                W.LocalChat("`c[WinProxy]: `2PushStyleColor test dumped to testpush_dump.txt!")
            end
            return true
        elseif j:find("text|/dumpstyle$") then
            local P = "--- ImGui.Col DUMP ---\n"
            if ImGui.Col then
                for j, Y in pairs(ImGui.Col) do
                    P = P .. (tostring(j) .. (" = " .. (tostring(Y) .. "\n")))
                end
            end
            P = P .. "\n--- GetStyleColorVec4 DUMP ---\n"
            if ImGui.Col and ImGui.GetStyleColorVec4 then
                for j, Y in pairs(ImGui.Col) do
                    local X, M = pcall(ImGui.GetStyleColorVec4, Y)
                    if X and _G.type(M) == "table" then
                        local X = tostring(M.x or M[1] or M.r or "nil")
                        local z = tostring(M.y or M[2] or M.g or "nil")
                        local o = tostring(M.z or M[3] or M.b or "nil")
                        local q = tostring(M.w or M[4] or M.a or "nil")
                        P = P .. (tostring(j) .. (" (" .. (tostring(Y) .. (") = R:" .. (X .. (" G:" .. (z .. (" B:" .. (o .. (" A:" .. (q .. "\n")))))))))))
                    end
                end
            end
            local j = io.open("style_dump.txt", "w")
            if j then
                j:write(P)
                j:close()
                W.LocalChat("`c[WinProxy]: `2Style table dumped to style_dump.txt!")
            end
            return true
        elseif j:find("text|/dumpimgui$") then
            local P = ""
            for j, Y in pairs(ImGui) do
                P = P .. (tostring(j) .. (" = " .. (tostring(Y) .. "\n")))
            end
            local j = io.open("imgui_dump.txt", "w")
            if j then
                j:write(P)
                j:close()
                W.LocalChat("`c[WinProxy]: `2ImGui table dumped to imgui_dump.txt!")
            end
            return true
        elseif j:find("text|/imgui$") then
            W.ShowImGui = not W.ShowImGui
            W.SaveConfig(true)
            W.LocalChat("`c[WinProxy]: `9ImGui Menu is now " .. ((W.ShowImGui and "`2OPEN" or "`4CLOSED")))
            return true
        elseif j:find("text|/antipickup$") then
            W.AntiPickup = not W.AntiPickup
            W.SaveConfig(true)
            W.LocalChat("`c[WinProxy]: `9Anti Pickup is now " .. ((W.AntiPickup and "`2ON" or "`4OFF")))
            return true
        elseif j:find("text|/modfly$") then
            W.Modfly = not W.Modfly
            pcall(function()
                ChangeValue("[C] Modfly", W.Modfly)
            end)
            W.SaveConfig(true)
            W.LocalChat("`c[WinProxy]: `9Modfly is now " .. ((W.Modfly and "`2ON" or "`4OFF")))
            return true
        elseif j:find("text|/antiportal$") then
            W.AntiPortal = not W.AntiPortal
            pcall(function()
                ChangeValue("[C] Anti portal", W.AntiPortal)
            end)
            W.SaveConfig(true)
            W.LocalChat("`c[WinProxy]: `9Anti Portal is now " .. ((W.AntiPortal and "`2ON" or "`4OFF")))
            return true
        elseif j:find("text|/nightvision$") then
            W.NightVision = not W.NightVision
            pcall(function()
                ChangeValue("[C] Night vision", W.NightVision)
            end)
            W.SaveConfig(true)
            W.LocalChat("`c[WinProxy]: `9Night Vision is now " .. ((W.NightVision and "`2ON" or "`4OFF")))
            return true
        elseif j:find("text|/blocksdb$") then
            W.BlockSDB = not W.BlockSDB
            W.SaveConfig(true)
            W.LocalChat("`c[WinProxy]: `9Block SDB Dialog is now " .. ((W.BlockSDB and "`2ON" or "`4OFF")))
            return true
        elseif j:find("text|/autopull$") then
            W.AutoPull = not W.AutoPull
            W.SaveConfig(true)
            W.LocalChat("`c[WinProxy]: `9Auto Pull is now " .. ((W.AutoPull and "`2ON" or "`4OFF")))
            return true
        elseif j:find("text|/autopullscan$") then
            W.AutoPullAreaScan = not W.AutoPullAreaScan
            if W.AutoPullAreaScan then
                W.ManageAreaPullThread()
            end
            W.SaveConfig(true)
            W.LocalChat("`c[WinProxy]: `9Auto Pull Scan is now " .. ((W.AutoPullAreaScan and "`2ON" or "`4OFF")))
            return true
        elseif j:find("text|/posautopull$") then
            local P = GetLocal()
            if P and P.pos then
                W.AutoPullTileX = math.floor(P.pos.x / 32)
                W.AutoPullTileY = math.floor(P.pos.y / 32)
                W.SaveConfig(true)
                W.LocalChat("`c[WinProxy]: `2[APT] Target tile set to your position: (" .. (W.AutoPullTileX .. (", " .. (W.AutoPullTileY .. ")"))))
            end
            return true
        elseif j:find("text|/clearposautopull$") then
            W.AutoPullTileX = 0
            W.AutoPullTileY = 0
            W.SaveConfig(true)
            W.LocalChat("`c[WinProxy]: `2[APT] Target tile reset to Auto White Door.")
            return true
        elseif j:find("text|/antilag$") then
            W.ToggleAntiLag()
            return true
        elseif j:find("text|/hidespammer$") then
            W.ToggleHideSpammer()
            return true
        elseif j:find("text|/tp$") then
            W.TPDisplay = not W.TPDisplay
            W.SaveConfig(true)
            W.LocalChat("`c[WinProxy]: `9Teleport Punch is now " .. ((W.TPDisplay and "`2ON" or "`4OFF")))
            return true
        elseif j:find("text|/showbal$") then
            W.ShowBal = not W.ShowBal
            W.SaveConfig(true)
            W.LocalChat("`c[WinProxy]: `9Show Balance is now " .. ((W.ShowBal and "`2ON" or "`4OFF")))
            return true
        elseif j:find("text|/fastdrop$") then
            W.FastDrop = not W.FastDrop
            W.LocalChat("`c[WinProxy]: `9Fast Drop is now " .. ((W.FastDrop and "`2ON" or "`4OFF")))
            return true
        elseif j:find("text|/fasttrash$") then
            W.FastTrash = not W.FastTrash
            W.LocalChat("`c[WinProxy]: `9Fast Trash is now " .. ((W.FastTrash and "`2ON" or "`4OFF")))
            return true
        elseif j:find("text|/vendfilter$") then
            W.VendFilter = not W.VendFilter
            W.SaveConfig(true)
            W.LocalChat("`c[WinProxy]: `9Vend Filter is now " .. ((W.VendFilter and "`2ON" or "`4OFF")))
            return true
        elseif j:find("text|/donfilter$") then
            W.DonationFilter = not W.DonationFilter
            W.SaveConfig(true)
            W.LocalChat("`c[WinProxy]: `9Donation Box Filter is now " .. ((W.DonationFilter and "`2ON" or "`4OFF")))
            return true
        elseif j:find("text|/sboxfilter$") then
            W.StorageFilter = not W.StorageFilter
            W.SaveConfig(true)
            W.LocalChat("`c[WinProxy]: `9Storage Box Filter is now " .. ((W.StorageFilter and "`2ON" or "`4OFF")))
            return true
        elseif j:find("text|/skin") then
            local P = j:match("text|/skin%s+(.*)")
            if not P or P:gsub("%s+", "") == "" then
                W.LocalChat("`c[WinProxy]: `9Usage: `b/skin <color>`9 (Options: `wblack, white, red, yellow, green, blue, purple, pink, orange, cyan, rainbow, blink, reset, or hex #RRGGBB`9)")
                return true
            end
            P = ((P:gsub("^%s+", "")):gsub("%s+$", "")):lower()
            if P == "rainbow" then
                W.RainbowSkin = not W.RainbowSkin
                if W.RainbowSkin then
                    W.BlinkSkin = false
                    W.ManageSkinEffects()
                end
                W.LocalChat("`c[WinProxy]: `9Rainbow Skin is now " .. ((W.RainbowSkin and "`2ON" or "`4OFF")))
                return true
            elseif P == "blink" then
                W.BlinkSkin = not W.BlinkSkin
                if W.BlinkSkin then
                    W.RainbowSkin = false
                    W.ManageSkinEffects()
                end
                W.LocalChat("`c[WinProxy]: `9Blink Skin is now " .. ((W.BlinkSkin and "`2ON" or "`4OFF")))
                return true
            elseif P == "reset" or P == "off" then
                W.RainbowSkin = false
                W.BlinkSkin = false
                W.SkinColor = { x = 1; y = 1; z = 1, w = 1 }
                W.SetSkinColor(1, 1, 1, 1)
                W.LocalChat("`c[WinProxy]: `9Skin color reset to default (`2White`9).")
                return true
            end
            local Y = {
                black = { r = 0; g = 0, b = 0; name = "Black" };
                white = { r = 1; g = 1, b = 1; name = "White" };
                red = { r = 1; g = 0; b = 0; name = "Red" };
                yellow = { r = 1; g = 1; b = 0; name = "Yellow" };
                green = { r = 0, g = 1; b = 0, name = "Green" };
                blue = { r = 0; g = .4; b = 1; name = "Blue" };
                purple = { r = .6, g = .1; b = .9; name = "Purple" },
                pink = { r = 1, g = .4; b = .8, name = "Pink" };
                orange = { r = 1; g = .5, b = 0; name = "Orange" },
                cyan = { r = 0, g = 1, b = 1; name = "Cyan" };
                gray = { r = .5, g = .5; b = .5; name = "Gray" },
                grey = { r = .5, g = .5; b = .5; name = "Gray" },
                brown = { r = .5; g = .25, b = 0; name = "Brown" }
            }
            local X = Y[P]
            if X then
                W.RainbowSkin = false
                W.BlinkSkin = false
                W.SkinColor = { x = X.r; y = X.g, z = X.b; w = 1 }
                W.SetSkinColor(X.r, X.g, X.b, 1)
                W.LocalChat("`c[WinProxy]: `9Skin color changed to `2" .. (X.name .. "`9!"))
                return true
            end
            local M = P:match("^#?([%x][%x][%x][%x][%x][%x])$")
            if M then
                local P = tonumber(M:sub(1, 2), 16) / 255
                local j = tonumber(M:sub(3, 4), 16) / 255
                local Y = tonumber(M:sub(5, 6), 16) / 255
                W.RainbowSkin = false
                W.BlinkSkin = false
                W.SkinColor = { x = P, y = j; z = Y, w = 1 }
                W.SetSkinColor(P, j, Y, 1)
                W.LocalChat("`c[WinProxy]: `9Skin color changed to hex `2#" .. (M:upper() .. "`9!"))
                return true
            end
            local z, o, q = P:match("(%d+)%s+(%d+)%s+(%d+)")
            if z and (o and q) then
                local P = math.max(0, math.min(255, tonumber(z) or 0)) / 255
                local j = math.max(0, math.min(255, tonumber(o) or 0)) / 255
                local Y = math.max(0, math.min(255, tonumber(q) or 0)) / 255
                W.RainbowSkin = false
                W.BlinkSkin = false
                W.SkinColor = { x = P; y = j, z = Y; w = 1 }
                W.SetSkinColor(P, j, Y, 1)
                W.LocalChat("`c[WinProxy]: `9Skin color changed to RGB `2(" .. (z .. (", " .. (o .. (", " .. (q .. ")`9!"))))))
                return true
            end
            W.LocalChat("`c[WinProxy]: `4Unknown skin color \'`w" .. (P .. "`4\'. Available: `wblack, white, red, yellow, green, blue, purple, pink, orange, cyan, rainbow, blink, or hex #RRGGBB`4."))
            return true
        elseif j:find("text|/modal$") then
            W.CalculateMyModal()
            return true
        elseif j:find("text|/btkmenu$") or j:find("text|/bjmenu$") then
            W.ShowBTKBJDialog()
            return true
        elseif j:find("text|/btkcmd$") or j:find("text|/bjcmd$") then
            W.ShowBTKCommandsDialog()
            return true
        elseif j:find("text|/btk$") then
            W.BTK_Mode = "BTK"
            W.SaveConfig(true)
            SendPacket(2, "action|input\n|text|`c[WinProxy]: `2Game Mode set to BTK (Most Gems)")
            return true
        elseif j:find("text|/bj$") then
            W.BTK_Mode = "BJ"
            W.SaveConfig(true)
            SendPacket(2, "action|input\n|text|`c[WinProxy]: `2Game Mode set to BJ (Blackjack 21)")
            return true
        elseif j:find("text|/btkremote$") or j:find("text|/bjremote$") then
            W.BTK_ActionTakeRemote()
            return true
        elseif j:find("text|/btkbet$") or j:find("text|/bjbet$") then
            W.BTK_ActionTakeBets()
            return true
        elseif j:find("text|/btkgems$") or j:find("text|/bjgems$") then
            W.BTK_ActionCheckGems()
            return true
        elseif j:find("text|/btkdrop$") or j:find("text|/bjdrop$") then
            W.BTK_ActionDropReset()
            return true
        elseif j:find("text|/btkcenter$") or j:find("text|/bjcenter$") then
            W.BTK_SelectingTarget = "Host Center"
            W.LocalChat("`c[WinProxy]: `9Touch or Punch any tile to set `2Host Center")
            return true
        elseif j:find("text|/btkposbet1$") or j:find("text|/bjposbet1$") then
            W.BTK_SelectingTarget = "Bet P1"
            W.LocalChat("`c[WinProxy]: `9Touch or Punch any tile to set `2Bet P1")
            return true
        elseif j:find("text|/btkposbet2$") or j:find("text|/bjposbet2$") then
            W.BTK_SelectingTarget = "Bet P2"
            W.LocalChat("`c[WinProxy]: `9Touch or Punch any tile to set `2Bet P2")
            return true
        elseif j:find("text|/btkposbreak1$") or j:find("text|/bjposbreak1$") then
            W.BTK_SelectingTarget = "Break P1 (Mid)"
            W.LocalChat("`c[WinProxy]: `9Touch or Punch any tile to set `2Break P1 (Mid)")
            return true
        elseif j:find("text|/btkposbreak2$") or j:find("text|/bjposbreak2$") then
            W.BTK_SelectingTarget = "Break P2 (Mid)"
            W.LocalChat("`c[WinProxy]: `9Touch or Punch any tile to set `2Break P2 (Mid)")
            return true
        elseif j:find("text|/btktax$") or j:find("text|/bjtax$") then
            W.BTK_SelectingTarget = "Tax Drop (Mid)"
            W.LocalChat("`c[WinProxy]: `9Touch or Punch any tile to set `2Tax Drop (Mid)")
            return true
        elseif j:find("text|/btkmag$") or j:find("text|/bjmag$") then
            W.BTK_SelectingTarget = "Magplant (Top)"
            W.LocalChat("`c[WinProxy]: `9Touch or Punch any tile to set `2Magplant (Top)")
            return true
        elseif j:find("text|/g$") then
            SendPacket(2, "action|input\n|text|/ghost")
            return true
        elseif j:find("text|/res$") then
            SendPacket(2, "action|respawn")
            return true
        elseif j:find("text|/re$") then
            local P = GetWorld() and (GetWorld()).name or ""
            if P ~= "" then
                SendPacket(3, "action|join_request\nname|" .. (P .. "\ninvitedWorld|0"))
            end
            return true
        elseif j:find("text|/relog$") then
            SendVariantList({ [0] = "OnReconnect" })
            W.LocalChat("`c[WinProxy]: `9Reconnecting to server...")
            return true
        end
    end
    if P == 2 and (j:find("action|wrench") and j:find("netid|(%d+)")) then
        local P = tonumber(j:match("netid|(%d+)"))
        local Y = GetLocal()
        if Y and P == tonumber(Y.netid) then
            return false
        end
        if W.LastWorldTouchActionTime and ((os.clock() - W.LastWorldTouchActionTime < .4) and (W.LastWorldTouchNetID == P)) then
            return true
        end
        local X = W.IsRightClickPressed()
        local M = X and W.WrenchModeRight or W.WrenchMode
        if M ~= 0 then
            local j = W.ExecuteWrenchAction(P, M, 0)
            if j then
                return true
            end
        else
            if W.ShowBal then
                SendPacket(2, "action|dialog_return\ndialog_name|popup\nnetID|" .. (P .. "|\nbuttonClicked|viewinv"))
                return true
            end
        end
    end
    if P == 2 and j:find("action|wrench") then
        if W.AutoSurg then
            local P = j:match("netid|(%d+)")
            if P then
                W.SurgTarget = P
                local j = GetLocal()
                if j and j.pos then
                    W.SurgPos = { x = math.floor(j.pos.x / 32); y = math.floor(j.pos.y / 32) }
                end
                W.LocalChat("`c[WinProxy]: `9Surgery Target Locked! Player ID: `2" .. P)
            end
        end
    end
    return false
end

-- ========================================================================
-- SECTION 16: Hook - incoming variants (dialogs, console, talk bubbles, spawns)
-- ========================================================================

function W.OnVariant(P)
    if type(P) == "table" and P[0] then
        if W.VendRunning then
            if P[0] == "OnDialogRequest" and (type(P[1]) == "string" and P[1]:find("Machine")) then
                pcall(function()
                    local j = io.open("c:/Users/harla/AppData/Local/Growtopia/scripts/vend_dialog.txt", "w")
                    if j then
                        j:write(P[1])
                        j:close()
                    end
                end)
                if W.VendMode == "add" or W.VendMode == "find" or W.VendMode == "vend2vend" or W.VendMode == "set" then
                    local j = tonumber(W.VendSelectID) or tonumber(W.VendFindID)
                    if j then
                        local Y = P[1]:match("embed_data|x|(%d+)")
                        local X = P[1]:match("embed_data|y|(%d+)")
                        local M = Y or tostring(W.VendX)
                        local z = X or tostring(W.VendY)
                        local o = "action|dialog_return\ndialog_name|vend_edit\nx|"
                        if W.VendMode == "set" then
                            local Y = o .. (M .. ("|\ny|" .. (z .. "|\n")))
                            if P[1]:find("This machine is empty") then
                                Y = Y .. ("stockitem|" .. (tostring(j) .. "\n"))
                                SendPacket(2, Y)
                                if W.VendSetMode == "wrench" then
                                    W.LocalChat("`c[WinProxy]: `9Set Vending (`w" .. (M .. ("`9, `w" .. (z .. ("`9) to Item ID: `2" .. j)))))
                                end
                            else
                                local P = (W.VendPriceMode == "perlock") and "1" or "0"
                                local j = (W.VendPriceMode == "peritem") and "1" or "0"
                                Y = Y .. ("setprice|" .. (tostring(W.VendPrice) .. ("\nchk_peritem|" .. (P .. ("\nchk_perlock|" .. (j .. "\n"))))))
                                SendPacket(2, Y)
                                if W.VendSetMode == "wrench" then
                                    W.LocalChat("`c[WinProxy]: `9Updated Vending Price (`w" .. (M .. ("`9, `w" .. (z .. ("`9) to: `2" .. W.VendPrice)))))
                                end
                            end
                        end
                    end
                end
                if P[1]:find("This machine is empty") then
                    W.VendDone = true
                end
                return true
            end
            if P[0] == "OnTalkBubble" and (type(P[2]) == "string" and (GetLocal() ~= nil and (tonumber(P[1]) == (GetLocal()).netid and ((P[2]:find("too full") or P[2]:find("is empty") or P[2]:find("machine is empty")))))) then
                W.VendDone = true
            end
            if P[0] == "OnTextOverlay" and (type(P[1]) == "string" and ((P[1]:find("can\'t drop") or P[1]:find("can\'t trash")))) then
                W.VendDone = true
            end
            if P[0] == "OnDialogRequest" and (type(P[1]) == "string" and P[1]:find("item_finder")) then
                return true
            end
        end
        if W.MagRunning then
            if P[0] == "OnDialogRequest" and type(P[1]) == "string" then
                if P[1]:find("MAGPLANT") or P[1]:find("Item Finder") then
                    if W.MagMode == "stock" and P[1]:find("MAGPLANT") then
                        local j = P[1]:gsub("`.", "")
                        local Y, X = j:match("add_label_with_icon|small|([^|]+)|left|(%d+)|")
                        local M = j:match("Stock: (%d+) items%.")
                        if Y and (X and M) then
                            W.MagStockData[X] = W.MagStockData[X] or { name = Y; stock = 0 }
                            W.MagStockData[X].stock = W.MagStockData[X].stock + tonumber(M)
                        end
                        W.MagDone = true
                        return true
                    end
                    if P[1]:find("MAGPLANT") and not P[1]:find("add_button|withdraw|") then
                        W.MagDone = true
                    end
                    return true
                end
            elseif P[0] == "OnConsoleMessage" and (type(P[1]) == "string" and P[1]:find("This doesn\'t fit into the Magplant anymore!")) then
                W.MagDone = true
            elseif P[0] == "OnTextOverlay" and (type(P[1]) == "string" and P[1]:find("You can\'t drop that here")) then
                W.MagDone = true
            end
        end
        if P[0] == "OnDialogRequest" and type(P[1]) == "string" then
            local j = P[1]
            if ((j:find("Item Finder") or j:find("dialog_name|item_search") or j:find("item_finder"))) and not ((W.MagRunning or W.VendRunning)) then
                return true
            end
            if W.TitlesAwaitingSelfPopup and (j:find("buttonClicked", 1, true) == nil and ((j:find("buttonClicked|titles", 1, true) or j:find("add_button|titles", 1, true) or j:find("add_custom_button|titles", 1, true) or j:find("buttonClicked|title", 1, true)))) then
                W.TitlesAwaitingSelfPopup = false
                local P = GetLocal()
                local j = P and P.netid or 0
                SendPacket(2, "action|dialog_return\ndialog_name|popup\nnetID|" .. (j .. "|\nbuttonClicked|titles"))
                return true
            end
            if j:find("CustomTitleHidden_", 1, true) or j:find("LegendaryStatusHidden", 1, true) then
                for P, Y in ipairs(W.TitlesState.Standard) do
                    local X = j:match("add_checkbox|" .. (Y.key .. "|[^|]*|([01])|"))
                    if X then
                        Y.enabled = (X == "0")
                    end
                end
                if j:match("gpmmode1|1") then
                    W.TitlesState.GpmMode = 1
                elseif j:match("gpmmode2|1") then
                    W.TitlesState.GpmMode = 2
                elseif j:match("gpmmode3|1") then
                    W.TitlesState.GpmMode = 3
                end
                local P = {}
                for j, Y, X in j:gmatch("add_checkbox|([^|]+)|([^|]+)|([01])|") do
                    if j:find("CustomTitleHidden_") then
                        local M = (Y:gsub("`.", "")):gsub("^Hide ", "")
                        table.insert(P, { key = j; raw = Y; clean = M, enabled = (X == "0") })
                    end
                end
                if #P > 0 then
                    W.TitlesState.Custom = P
                end
                W.TitlesState.Loaded = true
                if W.FetchingTitlesSilent then
                    W.FetchingTitlesSilent = false
                    W.LocalChat("`c[WinProxy]: `2[Titles] `wScanned " .. (#W.TitlesState.Custom .. " Custom Titles!"))
                    if W.AutoRefreshTitleDialog then
                        W.AutoRefreshTitleDialog = false
                        W.ShowTitleMenuDialog()
                    end
                    return true
                end
            end
            local Y = W.ApplyTheme(j)
            if Y ~= j then
                P[1] = Y
            end
            if j:find("Wow, that\'s fast delivery") or j:find("One Champagne Bottle") or j:find("exchange for 100 Diamond Lock") then
                if W.IsAutoCVRunning or W.TeleMode > 0 then
                    return true
                end
            end
            if W.TeleMode > 0 and ((j:find("Phone #") or j:find("end_dialog|telephone"))) then
                local P = j:match("embed_data|x|(%d+)")
                local Y = j:match("embed_data|y|(%d+)")
                if P and Y then
                    local j = "action|dialog_return\ndialog_name|telephone\nnum|53785|\nx|" .. (P .. ("|\ny|" .. (Y .. "|\nbuttonClicked|")))
                    if W.TeleMode == 1 then
                        SendPacket(2, j .. "dlconvert")
                    elseif W.TeleMode == 2 then
                        SendPacket(2, j .. "bglconvert2")
                    elseif W.TeleMode == 3 then
                        SendPacket(2, j .. "bglconvert")
                    elseif W.TeleMode == 4 then
                        SendPacket(2, j .. "getchamp")
                    elseif W.TeleMode == 5 then
                        SendPacket(2, j .. "getchamp2")
                    elseif W.TeleMode == 6 then
                        SendPacket(2, j .. "getchamp3")
                    end
                end
                return true
            end
        end
        if W.AutoSurg then
            for j = 1, 4, 1 do
                if type(P[j]) == "string" then
                    local Y = (P[j]:gsub("`.", "")):lower()
                    if Y:find("already performing surgery") or Y:find("performing surgery on somebody") then
                        local P = os.time()
                        if (P - ((W.LastWarpResetTime or 0))) >= 3 then
                            W.LastWarpResetTime = P
                            W.PerformSurgAntiStuck("Already In Surgery Session")
                        end
                        return true
                    end
                end
            end
        end
        if W.AutoSurg and ((W.SurgAutoModage or W.SurgUseLegalBrief)) then
            for j = 1, 4, 1 do
                if type(P[j]) == "string" then
                    local Y = P[j]
                    local X = (Y:gsub("`.", "")):lower()
                    if X:find("allow") or X:find("surgery right now") or X:find("malpractice") or X:find("mistake") or X:find("debt to society") or X:find("patient died") or X:find("failed the surgery") then
                        W.LocalChat("`c[WinProxy]: `4[Detected Malpractice via " .. (tostring(P[0]) .. "] `wBypassing..."))
                        W.BypassMalpractice()
                        return true
                    end
                end
            end
        end
        if P[0] == "OnDialogRequest" and (type(P[1]) == "string" and P[1]:find("eliteitem")) then
            local j = P[1]
            local Y = j:gsub("(add_small_font_button|eliteitem|[^\n]+)\n", "%1\nadd_label|small|`9Richest Player :|left|\nadd_button|win_profile|`4#0 `9@Win of Legend `c[W`3I`1N`c-`!C`cO`3M`1M`cU`3N`!I`1T`cY]|noflags|0|0|\n", 1)
            SendVariantList({ [0] = "OnDialogRequest", [1] = Y })
            return true
        end
        if P[0] == "OnRequestWorldSelectMenu" and type(P[1]) == "string" then
            local j = P[1]
            if j:find("add_floater|BUY|") then
                local P = j:gsub("add_floater|([^|]+)|%-1|", "add_floater|%1|-2|")
                P = P:gsub("(add_floater|BUY|[^\n]+)\n", "%1\nadd_floater|WIN COMMUNITY|-1|0.467896|65535\n", 1)
                SendVariantList({ [0] = "OnRequestWorldSelectMenu"; [1] = P })
                return true
            end
        end
        if W.HideSpammer then
            if P[0] == "OnConsoleMessage" and type(P[1]) == "string" then
                if P[1]:find("\'s Spammer Slave.") then
                    return true
                end
            elseif P[0] == "OnTalkBubble" and type(P[2]) == "string" then
                if (P[2]:lower()):find("spammer slave") then
                    return true
                end
            elseif P[0] == "OnSpawn" and type(P[1]) == "string" then
                local j = P[1]
                if not ((j:find("type%s*|%s*local") or j:find("type|local"))) then
                    if (j:lower()):find("spammer slave") then
                        return true
                    end
                end
            end
        end
        if W.AutoPull and (P[0] == "OnSpawn" and type(P[1]) == "string") then
            local j = P[1]
            if j:find("type%s*|%s*local") or j:find("type|local") then
                W.AutoPullSuppressUntil = os.clock() + 3
                return false
            end
            if W.AutoPullSuppressUntil and os.clock() < W.AutoPullSuppressUntil then
                return false
            end
            if (j:lower()):find("spammer slave") then
                return false
            end
            local Y = j:match("netID%s*|%s*(%d+)")
            local X = j:match("userID%s*|%s*(%d+)")
            local M = j:match("name%s*|%s*([^|\n]+)")
            local z, o = j:match("posXY%|(%d+)%|(%d+)")
            if not z then
                z = j:match("pos_x%|(%d+)")
                o = j:match("pos_y%|(%d+)")
            end
            if Y then
                local P = {
                    netid = tonumber(Y); netID = tonumber(Y); userid = tonumber(X), name = M and q(M) or "Unknown"
                }
                if z and o then
                    local j = math.floor(tonumber(z) / 32)
                    local Y = math.floor(tonumber(o) / 32)
                    local X = false
                    for M = 1, 5, 1 do
                        local z = W.AutoPullPos[M].x
                        local o = W.AutoPullPos[M].y
                        if z > 0 and o > 0 then
                            if (j == z) and ((Y == o or Y == o + 1 or Y == o - 1)) then
                                W.CheckAndExecutePull(P, "OnSpawn (Pos " .. (M .. ")"))
                                X = true
                                break
                            end
                        end
                    end
                    if not X then
                        local j = true
                        for P = 1, 5, 1 do
                            if W.AutoPullPos[P].x > 0 then
                                j = false
                                break
                            end
                        end
                        if j then
                            W.CheckAndExecutePull(P, "OnSpawn (Anywhere)")
                        end
                    end
                end
            end
        end
        if W.AutoSurg then
            if P[0] == "OnDialogRequest" and type(P[1]) == "string" then
                local j = P[1]
                if j:find("`!Perform Surgery``") or (j:find("end_dialog|popup") and j:find("buttonClicked|surgery")) then
                    local P = j:match("embed_data|netID|(%d+)") or W.SurgTarget
                    if P then
                        W.SurgTarget = P
                        W.IsSurging = true
                        W.SurgStartTime = os.time()
                        SendPacket(2, "action|dialog_return\ndialog_name|popup\nnetID|" .. (P .. "|\nbuttonClicked|surgery\n\n"))
                        return true
                    end
                end
                if j:find("end_dialog|surge_edit") or j:find("Anatomical") then
                    local P = j:match("embed_data|x|(%d+)") or j:match("|x|(%d+)")
                    local Y = j:match("embed_data|y|(%d+)") or j:match("|y|(%d+)")
                    if P and Y then
                        SendPacket(2, "action|dialog_return\ndialog_name|surge_edit\nx|" .. (P .. ("|\ny|" .. (Y .. "|\n\n"))))
                        W.IsSurging = true
                        W.SurgStartTime = os.time()
                        return true
                    end
                end
                if j:find("You aren\'t allowed to do surgery right now.") or j:find("allowed") or j:find("malpractice") or j:find("mistake") then
                    W.BypassMalpractice()
                    return true
                end
                if j:find("Recovering") or (j:lower()):find("recovering") then
                    W.IsSurging = false
                    W.SurgStartTime = 0
                    if W.SurgTarget then
                        SendPacket(2, "action|dialog_return\ndialog_name|popup\nnetID|" .. (W.SurgTarget .. "|\nbuttonClicked|chc0\n\n"))
                        W.LocalChat("`c[WinProxy]: `4Patient is recovering! `9Target locked (waiting for patient).")
                        W.SurgAction = "Patient Recovering..."
                    end
                    return true
                end
                if j:find("end_dialog|surgery") then
                    W.IsSurging = true
                    W.SurgStartTime = os.time()
                    local P = ""
                    local Y = ""
                    if j:find("It is becoming") or j:find("You can\'t see") then
                        P, Y = "command_0", "Sponge"
                    elseif j:find("Patient\'s fever") then
                        P, Y = "command_4", "Antibiotics"
                    elseif j:find("Not sanitized") or j:find("Unclean") or j:find("Unsanitary") then
                        P, Y = "command_3", "Antiseptic"
                    elseif j:find("Awake!") then
                        P, Y = "command_2", "Anesthetic"
                    elseif j:find("losing") then
                        P, Y = "command_6", "Stitches"
                    elseif j:find("Fix It!") and not ((j:find("Incisions: `30``") or j:find("Incisions: `60``") or j:find("Incisions: 0"))) then
                        P, Y = "command_6", "Stitches"
                    elseif j:find("Unconscious") and (j:find("Clean") and not j:find("Fix It!")) then
                        P, Y = "command_1", "Scalpel"
                    elseif ((j:find("Incisions: `30``") or j:find("Incisions: `60``") or j:find("Incisions: 0"))) and j:find("Fix It!") then
                        P, Y = "command_7", "Fix It!"
                        W.OnSurgerySuccess()
                    elseif j:find("command_7") then
                        P, Y = "command_7", "Fix It!"
                    elseif j:find("command_1") then
                        P, Y = "command_1", "Scalpel"
                    end
                    if P ~= "" then
                        if P ~= "command_7" or not ((j:find("Incisions: `30``") or j:find("Incisions: `60``") or j:find("Incisions: 0"))) then
                            W.SurgAction = "Using " .. (Y .. "...")
                        end
                        RunThread(function()
                            Sleep(60)
                            SendPacket(2, "action|dialog_return\ndialog_name|surgery\nbuttonClicked|" .. (P .. "\n\n"))
                        end)
                    end
                    return true
                end
            elseif P[0] == "OnConsoleMessage" and type(P[1]) == "string" then
                local j = P[1]
                local Y = (j:gsub("`.", "")):lower()
                if j:find("You are not allowed to perform surgery for a while") or Y:find("allowed") or Y:find("mistake") or Y:find("malpractice") or Y:find("debt to society") or Y:find("patient died") or Y:find("failed the surgery") then
                    W.BypassMalpractice()
                    return true
                end
                if Y:find("already performing surgery") then
                    W.IsSurging = false
                    W.SurgStartTime = 0
                    W.SurgAction = "Session Stuck! Rejoining World..."
                    W.LocalChat("`c[WinProxy]: `4Stuck in session! `9Re-warping world to reset surgery state...")
                    local P = GetWorld() and (GetWorld()).name
                    if P and P ~= "" then
                        SendPacket(2, "action|input\n|text|/warp " .. P)
                    end
                    return true
                end
                if Y:find("recovering from surgery") or Y:find("is recovering") or Y:find("has recovered") then
                    W.IsSurging = false
                    W.SurgStartTime = 0
                    if W.SurgTarget then
                        W.LocalChat("`c[WinProxy]: `4Patient is recovering! `9Target locked (waiting for patient).")
                        W.SurgAction = "Patient Recovering..."
                    end
                    return true
                end
                if W.IsSurging and ((Y:find("surgery was a success") or Y:find("treated the patient") or Y:find("completed the surgery"))) then
                    W.OnSurgerySuccess()
                    return true
                end
            end
        end
        if W.AutoFish and (P[0] == "OnConsoleMessage" and type(P[1]) == "string") then
            local j = (P[1]:gsub("`.", "")):lower()
            if j:find("caught") or j:find("reeled") or j:find("there was") then
                W.FishStats.caught = W.FishStats.caught + 1
            elseif j:find("got away") or j:find("escaped") then
                W.FishStats.missed = W.FishStats.missed + 1
            end
        end
        if W.AutoCrime then
            if P[0] == "OnDialogRequest" and type(P[1]) == "string" then
                if P[1]:find("crimewave") or P[1]:find("Fighting Crime") then
                    return true
                end
            elseif W.IsFightingCrime and (W.CrimeTarget and (P[0] == "OnConsoleMessage" and type(P[1]) == "string")) then
                local j = P[1]
                if j:find("Reward:") then
                    W.IsFightingCrime = false
                    W.CrimeWon = true
                    W.CrimeAction = "Won against " .. W.CrimeTarget.name
                    W.LocalChat("`c[WinProxy]: `2" .. W.CrimeAction)
                    return true
                end
                local Y = j:gsub("`.", "")
                local X = W.CrimeTarget.name .. " crushed"
                if Y:find(X) then
                    W.IsFightingCrime = false
                    W.CrimeWon = false
                    W.CrimeAction = "Lost against " .. W.CrimeTarget.name
                    W.LocalChat("`c[WinProxy]: `4" .. W.CrimeAction)
                    return true
                end
            end
        end
        if W.ABP_IsScanningShop and (type(P[1]) == "string" and ((P[0] == "OnStoreRequest" or P[0] == "OnDialogRequest"))) then
            local j = P[1]
            if j:find("add_button") and j:find("buy_") then
                local P = j:match("end_dialog|([^|]*)|")
                if P then
                    W.ABP_ShopDialogName = P
                end
                for P, j in j:gmatch("add_button%s*|%s*(buy_[%w_]+)%s*|%s*([^|]+)") do
                    if not W.ABP_AddedCmds[P] then
                        W.ABP_AddedCmds[P] = true
                        local Y = ((j:gsub("`.", "")):gsub("\n", " ")):match("^%s*(.-)%s*$")
                        table.insert(W.ABP_Packs, { name = Y; cmd = P })
                        table.insert(W.ABP_PackNames, Y)
                    end
                end
                return true
            end
        end
        if P[0] == "OnSDBroadcast" and W.BlockSDB then
            W.LocalChat("`c[WinProxy]: `9Blocked incoming SDB dialog.")
            return true
        end
        if P[0] == "OnConsoleMessage" and type(P[1]) == "string" then
            local j = P[1]
            local Y = j:gsub("`.", "")
            if W.EncryptChat then
                local P, Y = j:match("^(.-)(%S+)%s*$")
                if Y then
                    local X = Y:gsub("`.", "")
                    if #X >= 4 and (#X % 4 == 0 and X:match("^[A-Za-z0-9+/=]+$")) then
                        local Y = W.Base64Decode(X)
                        if Y and Y ~= "" then
                            local X = W.XORCipher(Y, W.EncryptKey)
                            if X:match("^[%w%p%s]+$") then
                                if j:find(">") or j:find(":") then
                                    local Y = P:gsub("CP:_PL:.-_CT:", "")
                                    Y = Y:gsub("%[W%]_", "[W]")
                                    local M = j .. ("\n`2(Decrypted) " .. (Y .. ("`w" .. X)))
                                    SendVariantList({ [0] = "OnConsoleMessage"; [1] = M })
                                    return true
                                end
                            end
                        end
                    end
                end
            end
            local X = Y:lower()
            if W.BlockSB and Y:find("%*%* from %(.+%) in %[.+%] %*%* :") then
                return true
            end
            local M = X:match("^%s*<")
            local z = X:find("cp:_pl:0_oid:")
            if not M and not z then
                if W.LogsEnabled then
                    local function P(P)
                        if P:find("World Lock") then
                            return "`9"
                        end
                        if P:find("Diamond Lock") then
                            return "`c"
                        end
                        if P:find("Blue Gem Lock") then
                            return "`e"
                        end
                        if P:find("Black Gem Lock") then
                            return "`b"
                        end
                        return "`w"
                    end
                    if Y:find("Collected ") then
                        local j, X = Y:match("Collected%s+(%d+)%s+(.+)")
                        if j and X then
                            X = X:gsub("%.%s*$", "")
                            local Y = P(X)
                            W.AddLog("Inventory", "`2Collected `0" .. (j .. (" " .. (Y .. X))))
                            if X:find("World Lock") or X:find("Diamond Lock") or X:find("Blue Gem Lock") or X:find("Black Gem Lock") then
                                SendPacket(2, "action|input\n|text|`c[WinProxy]: `2Collected `0" .. (j .. (" " .. (Y .. X))))
                            end
                            if W.AutoCVLocks then
                                RunThread(function()
                                    W.IsAutoCVRunning = true
                                    Sleep(250)
                                    if X:find("World Lock") and W.GetItemCount(W.GetIcon("Creativeps World Lock", 242)) >= 100 then
                                        SendPacketRaw(false, { type = 10; value = 242 })
                                        W.LocalChat("`c[WinProxy]: `2[Auto-CV] `9Converted 100 WL to 1 DL!")
                                    elseif X:find("Diamond Lock") and W.GetItemCount(W.GetIcon("Creativeps Diamond Lock", 1796)) >= 100 then
                                        local P, j = W.GetNearestTelephone()
                                        if P and j then
                                            local Y = "action|dialog_return\ndialog_name|telephone\nnum|53785|\nx|" .. (P .. ("|\ny|" .. (j .. "|\nbuttonClicked|bglconvert")))
                                            SendPacket(2, Y)
                                            W.LocalChat("`c[WinProxy]: `2[Auto-CV] `9Converted 100 DL to 1 BlueGL via Telephone!")
                                        else
                                            W.LocalChat("`c[WinProxy]: `4[Auto-CV Failed] `wNo Telephone nearby to convert DL!")
                                        end
                                    elseif X:find("Blue Gem Lock") and W.GetItemCount(W.GetIcon("Creativeps Blue Gem Lock", 7188)) >= 100 then
                                        SendPacket(2, "action|dialog_return\ndialog_name|info_box\nbuttonClicked|make_bgl")
                                        W.LocalChat("`c[WinProxy]: `2[Auto-CV] `9Converted 100 BlueGL to 1 BlackGL!")
                                    end
                                    Sleep(500)
                                    W.IsAutoCVRunning = false
                                end)
                            end
                        end
                    elseif X:find("%[winproxy%] dropped") or X:find("%[winproxy%]: dropped") then
                        local j, X = Y:match("Dropped%s+(%d+)%s+(.+)")
                        if j and X then
                            X = X:gsub("%.%s*$", "")
                            W.AddLog("Inventory", "`4Dropped `0" .. (j .. (" " .. (P(X) .. X))))
                        end
                    end
                end
                if X:find("merged 1 black gem lock") then
                    W.LocalChat("`c[WinProxy]: `2Succeed `9Converted to `4100 `eCreativePS Blue Gem Locks`4!")
                    return true
                elseif X:find("merged 100 blue gem lock") then
                    W.LocalChat("`c[WinProxy]: `2Succeed `9Converted to `41 `bCreativePS Black Gem Lock`4!")
                    return true
                end
            end
        end
        if P[0] == "OnConsoleMessage" and type(P[1]) == "string" then
            local j = P[1]
            if j:find("spun the wheel") then
                if j:find("CT:") or j:find("CP:0_PL:4_") or (j:find("<") and j:find(">")) then
                    local P = j:match("<(.-)>") or "Unknown"
                    W.LocalChat("`c[WinProxy]: `4[FAKE SPIN DETECTED] `wPlayer `2" .. (P .. " `wused a Typer!"))
                    W.AddLog("Casino", "`4[FAKE TYPER] `w" .. j)
                end
                return true
            end
            if j:find(">> `5Super") then
                if j:find("Used `$(%d+) Gems") then
                    W.SBUseGems = true
                    W.SBUseBGems = false
                    W.SBUsedGems = tonumber(j:match("Used `$(%d+) Gems")) or 0
                    W.SBTotUsedGems = W.SBTotUsedGems + W.SBUsedGems
                elseif j:find("Used `$(%d+) Black Gems") then
                    W.SBUseBGems = true
                    W.SBUseGems = false
                    W.SBUsedBGems = tonumber(j:match("Used `$(%d+) Black Gems")) or 0
                    W.SBTotUsedBGems = W.SBTotUsedBGems + W.SBUsedBGems
                    W.SBLeftBGems = tonumber(j:match("`$(%d+)`` left")) or 0
                end
            end
            if j:find("have a pending one") then
                W.SBPending = true
            end
            if W.SBEnabled and (W.SBSafeMode and j:find("```w(.+)`` `%$World Locked``")) then
                local P = j:match("```w(.+)`` `%$World Locked``")
                if P ~= W.SBWorld then
                    SendPacket(3, "action|join_request\nname|" .. (W.SBWorld .. "\ninvitedWorld|0"))
                    return true
                end
            end
            if W.SBEnabled and j:find("Where would you like to go?") then
                SendPacket(3, "action|join_request\nname|" .. (W.SBWorld .. "\ninvitedWorld|0"))
                return true
            end
        end
        if P[0] == "OnTalkBubble" and type(P[2]) == "string" then
            local j = P[2]
            if j:find("spun the wheel") then
                local Y = not ((j:find("<") or j:find("%[FAKE%]")))
                local X = j:match("^(.-) spun the wheel") or "Unknown"
                local M = X:gsub("`.", "")
                if M:sub(1, 1) == "[" then
                    M = M:sub(2)
                end
                local z, o = j:match("and got%s*(`[%w#^])(%d+)")
                local q = (j:gsub("`.", "")):match("and got (%d+)")
                local S = ((z and o)) and (z .. (o .. "`w")) or (q or "?")
                if Y then
                    LogToConsole("`0[`2REAL`0] " .. (M .. (" `0spun " .. (S .. "`0!"))))
                    if P[1] then
                        local j = tonumber(P[1])
                        local Y = X
                        local M, z = pcall(GetPlayerList)
                        if M and z then
                            for P, X in pairs(z) do
                                if X.netid == j and X.name then
                                    Y = X.name
                                    break
                                end
                            end
                        end
                        if Y:sub(1, 1) == "[" then
                            Y = Y:sub(2)
                        end
                        Y = Y:gsub(" `9%[`2%d+`9%]", "")
                        Y = Y:gsub(" `9%[`2%?`9%]", "")
                        local o = Y .. (" `9[`2" .. (((q or "?")) .. "`9]"))
                        pcall(SendVariantList, { [0] = "OnNameChanged", [1] = o }, j)
                    end
                else
                    LogToConsole("`0[`4FAKE`0] " .. (M .. " `0tried to fake spin!"))
                end
                W.AddLog("Casino", Y and j or ("`4[FAKE] `w" .. j))
                if q then
                    local X = j
                    if Y and W.CasinoMode > 0 then
                        X = W.GetCasinoText(tonumber(q), Y)
                    elseif not Y then
                        X = "`4[FAKE TYPER] `w" .. j
                    end
                    SendVariantList({ [0] = "OnTalkBubble"; [1] = P[1], [2] = X, [3] = P[3] or 0 })
                    return true
                end
            end
            if W.EncryptChat then
                local Y, X = j:match("^(.-)(%S+)%s*$")
                if X then
                    local j = X:gsub("`.", "")
                    if #j >= 4 and (#j % 4 == 0 and j:match("^[A-Za-z0-9+/=]+$")) then
                        local X = W.Base64Decode(j)
                        if X and X ~= "" then
                            local j = W.XORCipher(X, W.EncryptKey)
                            if j:match("^[%w%p%s]+$") then
                                local X = "`2(Decrypted) " .. (Y .. ("`w" .. j))
                                SendVariantList({ [0] = "OnTalkBubble"; [1] = P[1], [2] = X, [3] = P[3] or 0 })
                                return true
                            end
                        end
                    end
                end
            end
        end
        if P[0] == "OnDialogRequest" and type(P[1]) == "string" then
            local j = P[1]
            local Y = W.ApplyTheme(j)
            if Y ~= j then
                P[1] = Y
            end
            if W.AutoBuyPack and type(j) == "string" then
                if j:find("Purchase Unsuccessful") or j:find("not enough space") then
                    local P = j:lower()
                    if P:find("space") or P:find("room") or P:find("inventory") or P:find("full") then
                        W.ABP_ForceDrop = true
                        W.LocalChat("`c[WinProxy]: `e[INFO] `wInventory Full! Forcing Drop Phase...")
                    else
                        W.AutoBuyPack = false
                        W.LocalChat("`c[WinProxy]: `4[WARNING] `wPurchase Unsuccessful! (Out of Gems?)")
                        W.LocalChat("`c[WinProxy]: `wAuto Buy Pack is now `4STOPPED`w.")
                    end
                    return true
                elseif j:find("Thank you for your purchase!") then
                    return true
                end
            end
            if W.VendFilter and (j:lower()):find("vend") then
                if j:find("%d+%s*x%s*[^\n|]-World Lock") then
                    j = j:gsub("[^\n]+", function(P)
                        local j = P:match("(%d+)%s*x%s*[^\n|]-World Lock")
                        if j then
                            return W.FormatVendPrice(j)
                        end
                        return P
                    end)
                    SendVariantList({ [0] = "OnDialogRequest", [1] = j })
                    return true
                end
            end
            if W.DonateMode then
                if j:find("gifts waiting") or j:find("How many to put in the box") or j:find("The box is currently empty%.") then
                    local P, Y = j:match("embed_data|x|(%d+)"), j:match("embed_data|y|(%d+)")
                    if P and Y then
                        W.DonateBoxX = P
                        W.DonateBoxY = Y
                        W.LocalChat("`c[WinProxy]: `9Successfully set Donation Box position to X: `2" .. (P .. (" `9Y: `2" .. Y)))
                    end
                    return true
                end
            end
            if W.DonationFilter and j:find("gifts waiting") then
                j = j:gsub("add_label_with_icon|small|([^|]+)|left|(%d+)|", function(P, j)
                    local Y = j
                    local X = P:match("^(.-)%s+%(")
                    if X then
                        local P = X:lower()
                        local j = W.ItemDB[P] or W.ItemDB[P:gsub("^creativeps ", "")]
                        if j then
                            Y = tostring(j)
                        end
                    end
                    return "add_label_with_icon|small|" .. (P .. ("|left|" .. (Y .. "|")))
                end)
                SendVariantList({ [0] = "OnDialogRequest"; [1] = j })
                return true
            end
            if W.StorageFilter then
                local P = ((j:find("end_dialog|storage|") or j:find("Withdraw how many?"))) and not j:find("\'s Inventory")
                if P then
                    if j:find("How many to store?") then
                        return false
                    end
                    local P = tonumber(j:match("embed_data|x|(%d+)") or j:match("\nx|(%d+)"))
                    local Y = tonumber(j:match("embed_data|y|(%d+)") or j:match("\ny|(%d+)"))
                    if P and P ~= 0 then
                        W.StorageBoxState.last_x = P
                    end
                    if Y and Y ~= 0 then
                        W.StorageBoxState.last_y = Y
                    end
                    local X = W.StorageBoxState.last_x or 0
                    local M = W.StorageBoxState.last_y or 0
                    if j:find("Withdraw how many?") or j:find("add_button|withdraw|") or j:find("embed_data|hash|") then
                        local P = j:match("embed_data|hash|([%w%d_]+)") or j:match("\nhash|([%w%d_]+)")
                        local Y = W.StorageBoxState.current_item
                        local z = tonumber(j:match("add_text_input|item_count||(%d+)|") or j:match("You have `?w?(%d+)"))
                        local o = z or (Y and Y.count) or 250
                        if W.StorageBoxState.active_withdraw and P then
                            local j = Y and Y.icon_id or 0
                            local z = (j > 0) and W.GetItemCount(j) or 0
                            local q = math.max(0, 250 - z)
                            local S = math.min(q, o)
                            if S <= 0 then
                                W.StorageBoxState.active_withdraw = false
                                W.StorageBoxState.suppress_reopen_until = os.clock() + 1.5
                                RunThread(function()
                                    Sleep(20)
                                    SendPacket(2, "action|dialog_return\ndialog_name|storage\nx|" .. (X .. ("|\ny|" .. (M .. "|\nbuttonClicked|Exit\n"))))
                                end)
                                W.LocalChat("`c[WinProxy]: `4[Storage] Backpack is full for remaining items!")
                                return true
                            end
                            local O = "action|dialog_return\ndialog_name|storage\nx|" .. (X .. ("|\ny|" .. (M .. ("|\nhash|" .. (P .. ("|\nbuttonClicked|withdraw\nitem_count|" .. (S .. "\n")))))))
                            local V = Y and Y.hash or P
                            local e = Y and ((Y.raw_btn or ("item_" .. tostring(Y.hash))))
                            W.StorageBoxState.just_withdrawn_hash = V
                            W.StorageBoxState.just_withdrawn_btn = e
                            W.StorageBoxState.just_withdrawn_count = Y and Y.count
                            W.StorageBoxState.just_withdrawn_clock = os.clock()
                            if not W.StorageBoxState.withdrawn_hashes then
                                W.StorageBoxState.withdrawn_hashes = {}
                            end
                            if V then
                                W.StorageBoxState.withdrawn_hashes[tostring(V)] = true
                            end
                            if e then
                                W.StorageBoxState.withdrawn_hashes[tostring(e)] = true
                            end
                            RunThread(function()
                                Sleep(30)
                                SendPacket(2, O)
                            end)
                            return true
                        elseif not W.StorageBoxState.active_withdraw then
                            return false
                        end
                        return false
                    end
                    if j:find("add_item_picker|item|") or j:find("items stored") or j:find("Storage Box") then
                        local P = {}
                        local Y = {}
                        for j, X, M, z in j:gmatch("add_button_with_icon|([%w%d_%-]+)|(.-)|[%w_]*|(%d+)|(%d+)|") do
                            if j and (j ~= "END_LIST" and not Y[j]) then
                                Y[j] = true
                                local o = j:gsub("^item_", "")
                                local S = ((q(X)):gsub("^%s+", "")):gsub("%s+$", "")
                                local W = S:match(":%s*(%d+)$") or S:match("(%d+)x$")
                                if W then
                                    if not z or tonumber(z) == 1 then
                                        z = tonumber(W)
                                    end
                                    S = (((S:gsub("%s*:%s*%d+$", "")):gsub("%s*%d+x$", "")):gsub("^%s+", "")):gsub("%s+$", "")
                                end
                                table.insert(P, {
                                    hash = o, raw_btn = j, name = S; count = tonumber(z) or 1, icon_id = tonumber(M) or 0
                                })
                            end
                        end
                        if #P == 0 then
                            for j, X, M in j:gmatch("add_button_with_icon|([%w%d_%-]+)|(.-)|[%w_]*|(%d+)|") do
                                if j and (j ~= "END_LIST" and not Y[j]) then
                                    Y[j] = true
                                    local z = j:gsub("^item_", "")
                                    local o = ((q(X)):gsub("^%s+", "")):gsub("%s+$", "")
                                    local S = o:match(":%s*(%d+)$") or o:match("(%d+)x$")
                                    if S then
                                        o = (((o:gsub("%s*:%s*%d+$", "")):gsub("%s*%d+x$", "")):gsub("^%s+", "")):gsub("%s+$", "")
                                    end
                                    table.insert(P, { hash = z; raw_btn = j, name = o, count = 1; icon_id = tonumber(M) or 0 })
                                end
                            end
                        end
                        local z = j:match("add_label|small|`?w?([%d/]+%s*items?%s*stored%.)") or j:match("([%d/]+%s*items?%s*stored%.)") or (#P .. "/100 items stored.")
                        W.StorageBoxState.item_queue = P
                        W.StorageBoxState.last_x = X
                        W.StorageBoxState.last_y = M
                        if W.StorageBoxState.active_withdraw and (W.StorageBoxState.last_action_time and (os.time() - W.StorageBoxState.last_action_time > 4)) then
                            W.StorageBoxState.active_withdraw = false
                        end
                        if W.StorageBoxState.suppress_reopen_until and (os.clock() < W.StorageBoxState.suppress_reopen_until) then
                            SendPacket(2, "action|dialog_return\ndialog_name|storage\nx|" .. (X .. ("|\ny|" .. (M .. "|\nbuttonClicked|Exit\n"))))
                            return true
                        end
                        if W.StorageBoxState.active_withdraw then
                            local j, Y = W.GetNextWithdrawableStorageItem(P)
                            if j and Y > 0 then
                                W.StorageBoxState.current_item = j
                                W.StorageBoxState.last_action_time = os.time()
                                local P = j.raw_btn or ("item_" .. j.hash)
                                W.StorageBoxState.just_withdrawn_hash = j.hash
                                W.StorageBoxState.just_withdrawn_btn = P
                                W.StorageBoxState.just_withdrawn_count = j.count
                                W.StorageBoxState.just_withdrawn_clock = os.clock()
                                if not W.StorageBoxState.withdrawn_hashes then
                                    W.StorageBoxState.withdrawn_hashes = {}
                                end
                                W.StorageBoxState.withdrawn_hashes[tostring(j.hash)] = true
                                W.StorageBoxState.withdrawn_hashes[tostring(P)] = true
                                RunThread(function()
                                    Sleep(30)
                                    SendPacket(2, "action|dialog_return\ndialog_name|storage\nx|" .. (X .. ("|\ny|" .. (M .. ("|\nbuttonClicked|" .. (P .. "\n"))))))
                                end)
                                return true
                            else
                                W.StorageBoxState.active_withdraw = false
                                W.StorageBoxState.withdrawn_hashes = nil
                                W.StorageBoxState.suppress_reopen_until = os.clock() + 1.5
                                RunThread(function()
                                    Sleep(20)
                                    SendPacket(2, "action|dialog_return\ndialog_name|storage\nx|" .. (X .. ("|\ny|" .. (M .. "|\nbuttonClicked|Exit\n"))))
                                end)
                                if #P == 0 then
                                    W.LocalChat("`c[WinProxy]: `2[Storage Box] All items taken successfully!")
                                else
                                    W.LocalChat("`c[WinProxy]: `2[Storage Box] Take Everything done! `7(Remaining items full in bag)")
                                end
                                return true
                            end
                        end
                        local o = "set_default_color|`o\n\n"
                        o = o .. "add_label_with_icon|big|`wStorage Box Xtreme````|left|6290|\n"
                        o = o .. "add_spacer|small|\n"
                        o = o .. ("add_label|small|`w" .. (z .. "|left|\n"))
                        o = o .. "add_spacer|small|\n"
                        if #P > 0 then
                            for P, j in ipairs(P) do
                                o = o .. ("add_label_with_icon_button|small|`w" .. (j.name .. (" : " .. (j.count .. ("````|left|" .. (j.icon_id .. ("|" .. (j.raw_btn .. "|\n"))))))))
                            end
                            o = o .. "add_spacer|small|\n"
                            o = o .. "add_button|take_all_sbox|Take Everything|noflags|0|0|\n"
                        else
                            o = o .. "add_textbox|`7No items stored in this box.|left|\n"
                            o = o .. "add_spacer|small|\n"
                        end
                        o = o .. "add_item_picker|item|`wDeposit Item``|`wChoose an item to store``\n"
                        o = o .. ("embed_data|x|" .. (X .. "\n"))
                        o = o .. ("embed_data|y|" .. (M .. "\n"))
                        o = o .. "end_dialog|storage|Exit||\n"
                        SendVariantList({ [0] = "OnDialogRequest", [1] = o })
                        return true
                    end
                end
            end
            if j:find("\'s Inventory") then
                local P = j:gsub("`.", "")
                local Y = os.clock()
                local X = nil
                local M = nil
                for P, j in pairs(W.PendingModalPull) do
                    if (Y - j.timestamp) < 4 then
                        X = P
                        M = j
                        break
                    end
                end
                if X and M then
                    W.PendingModalPull[X] = nil
                    local Y = W.ParseDialogNumber(P:match("Blue Gem Locks in the Bank:%s*([%d,]+)"))
                    local z = W.ParseDialogNumber(P:match("|" .. (W.GetIcon("Creativeps Black Gem Lock", 11550) .. "|([%d,]+)|")) or P:match("|" .. (W.GetIcon("Creativeps Black Gem Lock", 11550) .. "|(%d+)")))
                    local o = W.ParseDialogNumber(P:match("|" .. (W.GetIcon("Creativeps Blue Gem Lock", 7188) .. "|([%d,]+)|")) or P:match("|" .. (W.GetIcon("Creativeps Blue Gem Lock", 7188) .. "|(%d+)")))
                    local q = W.ParseDialogNumber(P:match("|" .. (W.GetIcon("Creativeps Diamond Lock", 1796) .. "|([%d,]+)|")) or P:match("|" .. (W.GetIcon("Creativeps Diamond Lock", 1796) .. "|(%d+)")))
                    local S = W.ParseDialogNumber(P:match("|" .. (W.GetIcon("Creativeps World Lock", 242) .. "|([%d,]+)|")) or P:match("|" .. (W.GetIcon("Creativeps World Lock", 242) .. "|(%d+)")))
                    local O = ((((z * 100) + Y) + o) + (q / 100)) + (S / 10000)
                    local V = tonumber(W.AutoPullMinModal) or 0
                    if O >= V then
                        W.LastPulledNetID = X
                        W.LastPulledName = M.name
                        W.LastPulledTime = os.clock()
                        SendPacket(2, "action|dialog_return\ndialog_name|popup\nnetID|" .. (X .. "|\nbuttonClicked|pull"))
                        RunThread(function()
                            Sleep(50)
                            SendPacket(2, "action|dialog_return\ndialog_name|popup\nnetID|" .. (X .. "|\nbuttonClicked|pull"))
                        end)
                        if W.SpamPull or W.AutoSpamPull then
                            W.TriggerSpamPull(X, M.name)
                        end
                        if W.WrenchPullText ~= "" then
                            local P = W.WrenchPullText:gsub("{GrowID}", M.name)
                            RunThread(function()
                                Sleep(80)
                                SendPacket(2, "action|input\n|text|" .. P)
                            end)
                        end
                        W.LocalChat("`c[WinProxy]: `2Auto Pulled `w" .. (M.name .. (" `2(Modal: " .. (string.format("%.2f", O) .. " BGL)"))))
                    else
                        W.LocalChat("`c[WinProxy]: `4Skipped `w" .. (M.name .. (" `4(Modal: " .. (string.format("%.2f", O) .. (" BGL < " .. (V .. " BGL)"))))))
                    end
                    if W.ShowBal then
                        local P = W.ParseInventorySummary(j)
                        if P then
                            SendVariantList({ [0] = "OnTextOverlay", [1] = P })
                        end
                    end
                    return true
                end
                if W.ShowBal then
                    local P = W.ParseInventorySummary(j)
                    if P then
                        SendVariantList({ [0] = "OnTextOverlay"; [1] = P })
                        return true
                    end
                end
            end
            if W.FastDrop and ((j:lower()):find("drop") and (j:lower()):find("you have")) then
                local P = j:match("add_label_with_icon|big|.-|left|(%d+)") or j:match("embed_data|itemID|(%d+)")
                local Y = j:match("you have (%d+)")
                if P and Y then
                    SendPacket(2, "action|dialog_return\ndialog_name|drop\nitem_drop|" .. (P .. ("|\nitem_count|" .. (Y .. ("|\ncount|" .. Y)))))
                    return true
                end
            end
            if W.FastTrash and ((j:lower()):find("destroy") and (j:lower()):find("you have")) then
                local P = j:match("add_label_with_icon|big|.-|left|(%d+)") or j:match("embed_data|itemID|(%d+)")
                local Y = j:match("you have (%d+)")
                if P and Y then
                    SendPacket(2, "action|dialog_return\ndialog_name|trash\nitem_trash|" .. (P .. ("|\nitem_count|" .. (Y .. ("|\ncount|" .. Y)))))
                    return true
                end
            end
            if j:find("BGLs in the Bank") or j:find("Blue Gem Locks in the Bank") then
                local P = j:match("You have (%d+) BGLs in the Bank") or j:match("Blue Gem Locks in the Bank: %`%$(%d+)")
                if P then
                    W.BankBalance = tonumber(P)
                    LogToConsole("`2[WinProxy]: `9Bank Balance Synced: `e" .. (W.BankBalance .. " BGLs"))
                end
            end
            if W.SBCopyText and (j:find("add_text_input") and j:find("display_text||")) then
                local P, Y = j:find("display_text||")
                if P then
                    local P = j:find("|", Y + 1)
                    if P then
                        local X = j:sub(Y + 1, P - 1)
                        W.SBText = X
                        W.LocalChat("`c[WinProxy]: `2Success `0Set SB TEXT: " .. X)
                        return true
                    end
                end
            end
            if W.TeleMode > 0 then
                if j:find("Wow, that\'s fast delivery.") then
                    return true
                elseif j:find("dialog_name|telephone") then
                    local P = j:match("embed_data|x|(%d+)")
                    local Y = j:match("embed_data|y|(%d+)")
                    if P and Y then
                        local j = "action|dialog_return\ndialog_name|telephone\nnum|53785|\nx|" .. (P .. ("|\ny|" .. (Y .. "|\nbuttonClicked|")))
                        if W.TeleMode == 1 then
                            SendPacket(2, j .. "dlconvert")
                        elseif W.TeleMode == 2 then
                            SendPacket(2, j .. "bglconvert2")
                        elseif W.TeleMode == 3 then
                            SendPacket(2, j .. "bglconvert")
                        elseif W.TeleMode == 4 then
                            SendPacket(2, j .. "getchamp")
                        elseif W.TeleMode == 5 then
                            SendPacket(2, j .. "getchamp2")
                        elseif W.TeleMode == 6 then
                            SendPacket(2, j .. "getchamp3")
                        end
                    end
                    return true
                end
            end
            if j:find("add_button|trade_accept|") then
                if W.TradeAutoAccept then
                    SendPacket(2, "action|dialog_return\ndialog_name|trade_accept")
                end
            elseif j:find("add_button|trade_confirm|") then
                if W.TradeAutoConfirm then
                    SendPacket(2, "action|dialog_return\ndialog_name|trade_confirm")
                end
            end
        end
    end
    return false
end

-- ========================================================================
-- SECTION 17: Hook - tank packets (logging, fishing bite)
-- ========================================================================

function W.OnTankPacket(P)
    if W.AutoFish and P.type == 17 then
        W.FishBite = true
    end
    if not W.LogsEnabled then
        return false
    end
    if P.type == 14 and (P.netid == -1 and (GetLocal() ~= nil and P.snetid == (GetLocal()).netid)) then
        local j = math.floor(P.padding4 or 0)
        local Y = P.value or 0
        local X = "Item ID " .. Y
        local M, z = pcall(function()
            return GetItemInfo(Y)
        end)
        if M and (z and z.name) then
            X = z.name
        end
        if j > 0 then
            local P = "`w"
            if X:find("World Lock") then
                P = "`9"
            elseif X:find("Diamond Lock") then
                P = "`c"
            elseif X:find("Blue Gem Lock") then
                P = "`e"
            elseif X:find("Black Gem Lock") then
                P = "`b"
            end
            W.AddLog("Inventory", "`4Dropped `0" .. (j .. (" " .. (P .. X))))
        end
    end
    return false
end

-- ========================================================================
-- SECTION 18: Raw-packet hook, world-touch hook, key-state helpers
-- ========================================================================

local function y()
    local j = false
    if P and type(GetAsyncKeyState) == "function" then
        local P = tonumber(GetAsyncKeyState(160)) or 0
        local Y = tonumber(GetAsyncKeyState(161)) or 0
        local X = tonumber(GetAsyncKeyState(16)) or 0
        j = (P < 0 or P >= 32768 or Y < 0 or Y >= 32768 or X < 0 or X >= 32768)
    end
    return j
end

local function k()
    local j = false
    if P and type(GetAsyncKeyState) == "function" then
        local P = tonumber(GetAsyncKeyState(162)) or 0
        local Y = tonumber(GetAsyncKeyState(163)) or 0
        local X = tonumber(GetAsyncKeyState(17)) or 0
        j = (P < 0 or P >= 32768 or Y < 0 or Y >= 32768 or X < 0 or X >= 32768)
    end
    return j
end

local A = W.GetDialogColorPalette()
for P, j in ipairs(A) do
    K[j.id] = function(P)
        W.DialogBg = j.bg
        W.DialogBorder = j.border
        W.SaveConfig(true)
        W.ChangeDialogColor()
    end
end

local function p(P)
    if P.type == 11 and W.AntiPickup then
        return true
    end
    if ((y() or k())) and P.type == 3 then
        return true
    end
    if W.BypassChampWheelPunch then
        return false
    end
    if W.AutoChampWheel and (not ((y() or k())) and (P.type == 3 and (((P.value == 18 or P.value == 0 or P.value == W.GetIcon("Champagne", 16896))) and (P.px and P.py)))) then
        local j = GetTile(P.px, P.py)
        local Y = j and j.fg or 0
        local X = (Y == 758)
        if not X and (Y > 0 and GetItemInfo) then
            local P, j = pcall(GetItemInfo, Y)
            if P and (j and j.name) then
                local P = j.name:lower()
                if P:find("wheel") or P:find("roulette") then
                    X = true
                end
            end
        end
        if X then
            if W.ChampSpinPending then
                return true
            end
            W.ChampSpinPending = true
            local j = { type = P.type, value = 18; px = P.px, py = P.py; x = P.x; y = P.y }
            RunThread(function()
                local P, Y = W.UseChampagne()
                if P then
                    W.LocalChat("`c[WinProxy]: `2Champagne used! `9Spinning wheel...")
                    Sleep(150)
                else
                    W.LocalChat("`c[WinProxy]: `4[AutoChamp] " .. (((Y or "No Champagne in inventory")) .. "!"))
                    Sleep(50)
                end
                W.BypassChampWheelPunch = true
                pcall(function()
                    SendPacketRaw(false, j)
                end)
                W.BypassChampWheelPunch = false
                W.ChampSpinPending = false
            end)
            return true
        end
    end
    if W.MagRunning and (W.MagMode == "set" and W.MagSetMode == "wrench") then
        if P.type == 3 and (P.px and P.py) then
            local j = tonumber(W.MagFindID)
            if j then
                RunThread(function()
                    Sleep(150)
                    local Y = "action|dialog_return\ndialog_name|magplant_edit\nx|"
                    SendPacket(2, Y .. (P.px .. ("|\ny|" .. (P.py .. ("|\nitemToSelect|" .. (j .. "\n"))))))
                    W.LocalChat("`c[WinProxy]: `9Set Magplant (`2" .. (P.px .. (", " .. (P.py .. ("`9) to Item ID: `2" .. j)))))
                end)
            end
        end
    end
    if W.BTK_SelectingTarget and (P.type == 3 and (P.px and P.py)) then
        if P.px >= 0 and (P.px < 100 and (P.py >= 0 and P.py < 60)) then
            W.SetBTKCoordByTouch(W.BTK_SelectingTarget, P.px, P.py)
            return true
        end
    end
    if W.TPDisplay and (P.type == 3 and P.value == 18) then
        if P.px and P.py then
            local j = GetTile(P.px, P.py)
            local Y = j and j.fg or 0
            if Y == 1422 or Y == 9268 then
                RunThread(function()
                    local j = GetLocal()
                    if j and j.pos then
                        local Y = math.floor(j.pos.x / 32)
                        local X = math.floor(j.pos.y / 32)
                        FindPath(P.px, P.py)
                        Sleep(150)
                        FindPath(Y, X)
                    end
                end)
                return true
            end
        end
    end
    return false
end

function OnWorldTouch_WrenchPull(j, Y)
    if not Y then
        return false
    end
    if j == nil or j.x == nil or j.y == nil then
        return false
    end
    if W.AutoPullSettingSlot > 0 then
        local P = math.floor(j.x / 32)
        local Y = math.floor(j.y / 32)
        W.AutoPullPos[W.AutoPullSettingSlot] = { x = P; y = Y }
        W.LocalChat("`c[WinProxy]: `9Auto Pull Pos `2" .. (W.AutoPullSettingSlot .. (" `9set to `2(" .. (P .. (", " .. (Y .. ")"))))))
        W.AutoPullSettingSlot = 0
        W.SaveConfig(true)
        return true
    end
    if W.VendSelectingFrom then
        W.VendFromX = tostring(math.floor(j.x / 32))
        W.VendFromY = tostring(math.floor(j.y / 32))
        W.VendSelectingFrom = false
        W.SaveConfig(true)
        W.LocalChat("`c[WinProxy]: `9Take & Add From coordinate set to `2(" .. (W.VendFromX .. (", " .. (W.VendFromY .. ")"))))
        W.ShowVendingDialog(W.VendCurrentMenu)
        return true
    end
    if W.VendSelectingTarget then
        W.VendTargetX = tostring(math.floor(j.x / 32))
        W.VendTargetY = tostring(math.floor(j.y / 32))
        W.VendSelectingTarget = false
        W.SaveConfig(true)
        W.LocalChat("`c[WinProxy]: `9Target Vending set to `2(" .. (W.VendTargetX .. (", " .. (W.VendTargetY .. ")"))))
        W.ShowVendingDialog(W.VendCurrentMenu)
        return true
    end
    if W.VendSelectingDrop then
        W.VendDropX = tostring(math.floor(j.x / 32))
        W.VendDropY = tostring(math.floor(j.y / 32))
        W.VendSelectingDrop = false
        W.SaveConfig(true)
        W.LocalChat("`c[WinProxy]: `9Drop coordinate set to `2(" .. (W.VendDropX .. (", " .. (W.VendDropY .. ")"))))
        W.ShowVendingDialog(W.VendCurrentMenu)
        return true
    end
    if W.VendSelectingM2MTake then
        W.VendM2MTakeX = tostring(math.floor(j.x / 32))
        W.VendM2MTakeY = tostring(math.floor(j.y / 32))
        W.VendSelectingM2MTake = false
        W.SaveConfig(true)
        W.LocalChat("`c[WinProxy]: `9Take Vending set to `2(" .. (W.VendM2MTakeX .. (", " .. (W.VendM2MTakeY .. ")"))))
        W.ShowVendingDialog(W.VendCurrentMenu)
        return true
    end
    if W.VendSelectingM2MPut then
        W.VendM2MPutX = tostring(math.floor(j.x / 32))
        W.VendM2MPutY = tostring(math.floor(j.y / 32))
        W.VendSelectingM2MPut = false
        W.SaveConfig(true)
        W.LocalChat("`c[WinProxy]: `9Put Vending set to `2(" .. (W.VendM2MPutX .. (", " .. (W.VendM2MPutY .. ")"))))
        W.ShowVendingDialog(W.VendCurrentMenu)
        return true
    end
    if W.MagSelectingTarget then
        W.MagTargetX = tostring(math.floor(j.x / 32))
        W.MagTargetY = tostring(math.floor(j.y / 32))
        W.MagSelectingTarget = false
        W.SaveConfig(true)
        W.LocalChat("`c[WinProxy]: `9Target Magplant set to `2(" .. (W.MagTargetX .. (", " .. (W.MagTargetY .. ")"))))
        W.ShowMagplantDialog(W.MagCurrentMenu)
        return true
    end
    if W.MagSelectingFrom then
        W.MagFromX = tostring(math.floor(j.x / 32))
        W.MagFromY = tostring(math.floor(j.y / 32))
        W.MagSelectingFrom = false
        W.SaveConfig(true)
        W.LocalChat("`c[WinProxy]: `9Take & Add From coordinate set to `2(" .. (W.MagFromX .. (", " .. (W.MagFromY .. ")"))))
        W.ShowMagplantDialog(W.MagCurrentMenu)
        return true
    end
    if W.MagSelectingDrop then
        W.MagDropX = tostring(math.floor(j.x / 32))
        W.MagDropY = tostring(math.floor(j.y / 32))
        W.MagSelectingDrop = false
        W.SaveConfig(true)
        W.LocalChat("`c[WinProxy]: `9Drop coordinate set to `2(" .. (W.MagDropX .. (", " .. (W.MagDropY .. ")"))))
        W.ShowMagplantDialog(W.MagCurrentMenu)
        return true
    end
    if W.MagSelectingM2MTake then
        W.MagM2MTakeX = tostring(math.floor(j.x / 32))
        W.MagM2MTakeY = tostring(math.floor(j.y / 32))
        W.MagSelectingM2MTake = false
        W.SaveConfig(true)
        W.LocalChat("`c[WinProxy]: `9Take Magplant set to `2(" .. (W.MagM2MTakeX .. (", " .. (W.MagM2MTakeY .. ")"))))
        W.ShowMagplantDialog(W.MagCurrentMenu)
        return true
    end
    if W.MagSelectingM2MPut then
        W.MagM2MPutX = tostring(math.floor(j.x / 32))
        W.MagM2MPutY = tostring(math.floor(j.y / 32))
        W.MagSelectingM2MPut = false
        W.SaveConfig(true)
        W.LocalChat("`c[WinProxy]: `9Put Magplant set to `2(" .. (W.MagM2MPutX .. (", " .. (W.MagM2MPutY .. ")"))))
        W.ShowMagplantDialog(W.MagCurrentMenu)
        return true
    end
    if W.BTK_SelectingTarget then
        local P = math.floor(j.x / 32)
        local Y = math.floor(j.y / 32)
        if P >= 0 and (P < 100 and (Y >= 0 and Y < 60)) then
            W.SetBTKCoordByTouch(W.BTK_SelectingTarget, P, Y)
            return true
        end
    end
    if y() then
        local P = math.floor(j.x / 32)
        local Y = math.floor(j.y / 32)
        RunThread(function()
            FindPath(P, Y)
            local j = 0
            while j < 4000 do
                local X, M = pcall(GetLocal)
                if X and (M and M.pos) then
                    local j = math.floor(M.pos.x / 32)
                    local X = math.floor(M.pos.y / 32)
                    if j == P and X == Y then
                        break
                    end
                end
                Sleep(50)
                j = j + 50
            end
        end)
        return true
    end
    local X = 0
    if P and type(GetAsyncKeyState) == "function" then
        X = tonumber(GetAsyncKeyState(17)) or 0
    end
    if X < 0 or X >= 32768 then
        local P = math.floor(j.x / 32)
        local Y = math.floor(j.y / 32)
        W.LocalChat("`c[WinProxy]: `wCollect-only at (" .. (P .. (", " .. (Y .. ")"))))
        local X, M = pcall(GetObjectList)
        if X and M then
            local P = 4096
            for Y, X in pairs(M) do
                if X and (X.pos and X.oid) then
                    local Y = X.pos.x - j.x
                    local M = X.pos.y - j.y
                    local z = (Y * Y) + (M * M)
                    if z <= P then
                        SendPacketRaw(false, { type = 11; value = X.oid; x = X.pos.x, y = X.pos.y })
                    end
                end
            end
        end
        return true
    end
    local M = W.IsRightClickPressed()
    local z = M and W.WrenchModeRight or W.WrenchMode
    if z == 0 then
        return false
    end
    local o, q = pcall(GetPlayerItems)
    if not o or not q or not q.backpack then
        return false
    end
    local S = tonumber(q.backpack.selected) or 0
    if S ~= 32 then
        return false
    end
    local O = W.FindClosestPlayer(j)
    if not O then
        return false
    end
    local V = O.netID or O.netid
    local e = O.userid
    if not V then
        return false
    end
    W.LastWorldTouchActionTime = os.clock()
    W.LastWorldTouchNetID = tonumber(V)
    return W.ExecuteWrenchAction(V, z, e)
end

-- ========================================================================
-- SECTION 19: Hook registration and startup
-- ========================================================================

local function T()
    local P, j = pcall(W.RenderImGui)
    if not P then
        if not W.ErrorSpamGuard or (os.time() - W.ErrorSpamGuard > 3) then
            LogToConsole("`4[ImGui Error Caught]: `w" .. tostring(j))
            W.ErrorSpamGuard = os.time()
        end
    end
end

AddHook("OnDraw", "UIManager_Draw", T)
AddHook("onsendpacket", "UIManager_Packet", W.OnOutgoingPacket)
AddHook("onvariant", "UIManager_Variant", W.OnVariant)
AddHook("onprocesstankupdatepacket", "UIManager_TankPacket", W.OnTankPacket)
AddHook("onsendpacketraw", "UIManager_Raw", p)
AddHook("onworldtouch", "OnWorldTouch_WrenchPull", OnWorldTouch_WrenchPull)
RunThread(function()
    LogToConsole("`9[WinProxy]: `bLoading config from: `w" .. W.ConfigFileName)
    local P = W.LoadConfig()
    if P then
        LogToConsole("`9[WinProxy]: `2Config loaded successfully. Merging settings...")
    end
    LogToConsole("`9[WinProxy]: `bBuilding Item Database cache in background...")
    for P = -3000, 100000, 1 do
        local j, Y = pcall(GetItemInfo, P)
        if j and (Y and Y.name) then
            W.ItemDB[Y.name:lower()] = P
        end
        if math.abs(P) % 1000 == 0 then
            Sleep(10)
        end
    end
    LogToConsole("`9[WinProxy]: `2Script was Started successfully.")
    Sleep(500)
    local j = GetLocal()
    if j and j.name then
        W.LocalChat("`cWinProxy `wis `2Active !")
        SendAuthNotification("Authorized")
        W.DownloadAsset(W.BannerURL, W.BannerSavePath)
        W.ManageRePullHotkeyThread()
        W.ShowMainDialog()
    end
end)
