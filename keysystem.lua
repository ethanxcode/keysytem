if not game:IsLoaded() then game.Loaded:Wait() end

local cloneref = cloneref or function(o) return o end
local Http  = cloneref(game:GetService("HttpService"))
local GUI   = cloneref(game:GetService("StarterGui"))
local LP    = cloneref(game:GetService("Players")).LocalPlayer
local Rbx   = cloneref(game:GetService("RbxAnalyticsService"))
local TweenService = cloneref(game:GetService("TweenService"))
local StarterGui = cloneref(game:GetService("StarterGui"))
local CoreGui = cloneref(game:GetService("CoreGui"))

local API = "https://streehub.vercel.app/api/redeem"

local _req = (syn and syn.request)
          or (http and http.request)
          or http_request
          or (fluxus and fluxus.request)
          or request

if restorefunction and _req then pcall(restorefunction, _req) end

local function isHooked(fn)
    if not fn then return true end
    return islclosure and islclosure(fn)
end

local function notif(title, text, dur)
    pcall(GUI.SetCore, GUI, "SendNotification", {
        Title = title, Text = text, Duration = dur or 5
    })
end

local function kick(msg)
    LP:Kick("[StreeHub]\n" .. msg)
    task.wait(9e9)
end

local function callAPI(key)
    if not _req then return nil end

    local body = Http:JSONEncode({
        key       = key,
        hwid      = Rbx:GetClientId(),
        username  = LP.Name,
        executor  = (identifyexecutor and identifyexecutor()) or "Unknown",
        gameId    = game.GameId,
        placeId   = game.PlaceId,
        timestamp = tick(),
    })

    local ok, resp = pcall(_req, {
        Url     = API,
        Method  = "POST",
        Headers = {
            ["Content-Type"] = "application/json",
            ["User-Agent"]   = "StreeHub/2.4",
        },
        Body = body,
    })

    if not ok or not resp or type(resp) ~= "table" then return nil end
    if not resp.Body then return nil end

    local ok2, data = pcall(Http.JSONDecode, Http, resp.Body)
    return ok2 and data or nil
end

local function fakeKey()
    local c = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local function seg()
        local s = ""
        for i = 1, 4 do s = s .. c:sub(math.random(#c), math.random(#c)) end
        return s
    end
    return "FAKE-" .. seg() .. "-" .. seg() .. "-" .. seg()
end

local key = tostring(_G.script_key or ""):gsub("%s+", ""):upper()

if not key:match("^STRE%-[A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9]%-[A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9]%-[A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9]$") then
    notif("StreeHub", "Format key salah!\nContoh: STRE-XXXX-XXXX-XXXX", 6)
    task.wait(1.5)
    kick("Key tidak valid.\nDapat key via Discord panel.")
    return
end

if isHooked(_req) then kick("Security check failed.") return end

notif("StreeHub", "Memverifikasi key...", 4)

local checks = {{ t="REAL", k=key }, { t="FAKE", k=fakeKey() }}
for i = #checks, 2, -1 do
    local j = math.random(i)
    checks[i], checks[j] = checks[j], checks[i]
end

local result, busted = nil, false
for _, c in ipairs(checks) do
    task.wait(math.random(1, 3) / 10)
    local data = callAPI(c.k)
    if c.t == "FAKE" and data and data.status == "premium" then busted = true end
    if c.t == "REAL" then result = data end
end

if busted then kick("Security check failed.") return end
if not result then kick("Gagal konek ke server.\nCek koneksi internet.") return end

local s, r = result.status, result.reason

if s == "premium" then
    notif("StreeHub", "✅ Verified! Halo, " .. LP.Name, 5)
    _G.streehub = { ok = true, premium = true }
elseif s == "kick" then
    if r == "NOT_REDEEMED" then
        notif("StreeHub", "Key belum di-redeem!\nRedeem dulu via Discord.", 7)
        task.wait(2)
        kick("Belum redeem key.\nKlik 'Redeem Key' di panel Discord.")
    elseif r == "HWID_LIMIT" then
        kick("Key terikat device lain.\nKlik 'Reset HWID' di Discord.")
    elseif r == "RATE_LIMITED" then
        kick("Terlalu cepat. Coba lagi 1 menit.")
    else
        notif("StreeHub", "Key tidak valid.", 5)
        task.wait(1.5)
        kick("Key tidak valid.")
    end
    return
else
    kick("Response tidak dikenal.")
    return
end

print("[StreeHub] ✅ " .. LP.Name)
repeat task.wait() until game.Players.LocalPlayer and game.Players.LocalPlayer.Character

local placeId = game.PlaceId
local streeLogo = "rbxassetid://99948086845842"

local gameScripts = {
    [127794225497302] = {
        name = "Abyss",
        premium = "https://raw.githubusercontent.com/create-stree/STREE-HUB/refs/heads/main/Abyss/Premium.lua"
    },
    [286090429] = {
        name = "Arsenal",
        premium = "https://raw.githubusercontent.com/create-stree/STREE-HUB/refs/heads/main/Arsenal/Premium.lua"
    },
    [124311897657957] = {
        name = "Break A Lucky Block",
        premium = "https://raw.githubusercontent.com/create-stree/STREE-HUB/refs/heads/main/BALB/Premium.lua"
    },
    [2753915549] = {
        name = "Blox Fruit",
        premium = "https://raw.githubusercontent.com/create-stree/STREE-HUB/refs/heads/main/Blox-Fruit/Dev.lua"
    },
    [123921593837160] = {
        name = "Climb and Jump Tower",
        premium = "https://raw.githubusercontent.com/create-stree/STREE-HUB/refs/heads/main/Climb%20and%20Jump%20Tower/Premium.lua"
    },
    [131623223084840] = {
        name = "Escape Tsunami For Brainrot",
        premium = "https://raw.githubusercontent.com/create-stree/STREE-HUB/refs/heads/main/ETFB/Premium.lua"
    },
    [121864768012064] = {
        name = "Fish It",
        premium = "https://raw.githubusercontent.com/create-stree/STREE-HUB/refs/heads/main/Fish_It/Premium.lua"
    },
    [18687417158] = {
        name = "Forsaken",
        premium = "https://pandadevelopment.net/virtual/file/0ab33cd15eae6790"
    },
    [130594398886540] = {
        name = "Garden Horizons",
        premium = "https://raw.githubusercontent.com/create-stree/STREE-HUB/refs/heads/main/Garden-Horizons/Premium.lua"
    },
    [136599248168660] = {
        name = "Solo Hunter",
        premium = "https://raw.githubusercontent.com/create-stree/STREE-HUB/refs/heads/main/Solo-Hunter/Premium.lua"
    }
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 320, 0, 160)
Frame.Position = UDim2.new(0.5, -160, 0.5, -80)
Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Frame.BackgroundTransparency = 0.3
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 20)
UICorner.Parent = Frame

local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 2
UIStroke.Color = Color3.fromRGB(0, 255, 0)
UIStroke.Parent = Frame

local Image = Instance.new("ImageLabel")
Image.Image = streeLogo
Image.BackgroundTransparency = 1
Image.Size = UDim2.new(0, 80, 0, 80)
Image.Position = UDim2.new(0.5, -40, 0, 15)
Image.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Text = "STREE HUB"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 22
Title.TextColor3 = Color3.fromRGB(0, 255, 0)
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 0, 0, 105)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Parent = Frame

local Loading = Instance.new("Frame")
Loading.Size = UDim2.new(0, 260, 0, 6)
Loading.Position = UDim2.new(0.5, -130, 1, -20)
Loading.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Loading.BorderSizePixel = 0
Loading.Parent = Frame

local Bar = Instance.new("Frame")
Bar.Size = UDim2.new(0, 0, 1, 0)
Bar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
Bar.BorderSizePixel = 0
Bar.Parent = Loading

local tween = TweenService:Create(Bar, TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 1, 0)})
tween:Play()
tween.Completed:Wait()
task.wait(0.3)
ScreenGui:Destroy()

local gameData = gameScripts[placeId]
local gameName = gameData and gameData.name or "Unknown Game"

StarterGui:SetCore("SendNotification", {
    Title = "STREE HUB",
    Text = "Detected game: " .. gameName,
    Icon = streeLogo,
    Duration = 3
})

StarterGui:SetCore("SendNotification", {
    Title = "STREE HUB",
    Text = "Premium User",
    Icon = streeLogo,
    Duration = 3
})

task.wait(2)

if gameData then
    StarterGui:SetCore("SendNotification", {
        Title = "STREE HUB",
        Text = "Loading Premium version for " .. gameName .. "...",
        Icon = streeLogo,
        Duration = 3
    })
    loadstring(game:HttpGet(gameData.premium))()
else
    StarterGui:SetCore("SendNotification", {
        Title = "STREE HUB",
        Text = "Game not supported!",
        Icon = streeLogo,
        Duration = 4
    })
    LP:Kick("❌ Game not supported!")
end
