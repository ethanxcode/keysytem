if not game:IsLoaded() then
    game.Loaded:Wait()
end

local cloneref = cloneref or function(o) return o end

local HttpService = cloneref(game:GetService("HttpService"))
local Players = cloneref(game:GetService("Players"))
local StarterGui = cloneref(game:GetService("StarterGui"))
local TweenService = cloneref(game:GetService("TweenService"))
local CoreGui = cloneref(game:GetService("CoreGui"))
local RbxAnalyticsService = cloneref(game:GetService("RbxAnalyticsService"))

local LP = Players.LocalPlayer

local API = "https://streehub.vercel.app/api/redeem"

-- REQUEST SUPPORT
local request =
    (syn and syn.request)
    or (http and http.request)
    or http_request
    or (fluxus and fluxus.request)
    or request

-- NOTIFICATION
local function notif(title,text,dur)
    pcall(function()
        StarterGui:SetCore("SendNotification",{
            Title = title,
            Text = text,
            Duration = dur or 5
        })
    end)
end

-- SAFE KICK
local function kick(msg)
    LP:Kick("[STREE HUB]\n"..msg)
end

-- KEY FORMAT
local function validKey(key)
    return key:match("^STRE%-[A-Z0-9]{4}%-[A-Z0-9]{4}%-[A-Z0-9]{4}$")
end

-- API CALL
local function callAPI(key)

    if not request then
        warn("Request function missing")
        return nil
    end

    local body = HttpService:JSONEncode({
        key = key,
        hwid = RbxAnalyticsService:GetClientId(),
        username = LP.Name,
        executor = identifyexecutor and identifyexecutor() or "Unknown",
        placeId = game.PlaceId,
        timestamp = tick()
    })

    local ok,res = pcall(function()
        return request({
            Url = API,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = body
        })
    end)

    if not ok then
        warn("API Request Failed:",res)
        return nil
    end

    if not res or not res.Body then
        return nil
    end

    local ok2,data = pcall(function()
        return HttpService:JSONDecode(res.Body)
    end)

    if ok2 then
        return data
    end

    return nil
end

-- GET KEY
local key = tostring(_G.script_key or ""):gsub("%s+",""):upper()

if not validKey(key) then
    notif("STREE HUB","Format key salah\nSTRE-XXXX-XXXX-XXXX",6)
    task.wait(2)
    kick("Key format invalid")
    return
end

notif("STREE HUB","Verifying key...",3)

local result = callAPI(key)

if not result then
    kick("Server tidak merespon.\nCoba lagi.")
    return
end

if result.status ~= "premium" then

    local reason = result.reason or "INVALID"

    if reason == "NOT_REDEEMED" then
        kick("Key belum di redeem.")
    elseif reason == "HWID_LIMIT" then
        kick("Key sudah dipakai device lain.")
    elseif reason == "RATE_LIMITED" then
        kick("Terlalu cepat. Coba lagi.")
    else
        kick("Key tidak valid.")
    end

    return
end

notif("STREE HUB","Key verified ✓",3)

-- GAME SCRIPTS
local gameScripts = {

    [2753915549] = {
        name = "Blox Fruit",
        premium = "https://raw.githubusercontent.com/create-stree/STREE-HUB/main/Blox-Fruit/Dev.lua"
    },

    [286090429] = {
        name = "Arsenal",
        premium = "https://raw.githubusercontent.com/create-stree/STREE-HUB/main/Arsenal/Premium.lua"
    }

}

-- LOADING UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = CoreGui
ScreenGui.IgnoreGuiInset = true

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0,300,0,120)
Frame.Position = UDim2.new(0.5,-150,0.5,-60)
Frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
Frame.Parent = ScreenGui

local Bar = Instance.new("Frame")
Bar.Size = UDim2.new(0,0,0,6)
Bar.Position = UDim2.new(0,0,1,-6)
Bar.BackgroundColor3 = Color3.fromRGB(0,255,0)
Bar.Parent = Frame

local tween = TweenService:Create(
    Bar,
    TweenInfo.new(2),
    {Size = UDim2.new(1,0,0,6)}
)

tween:Play()
tween.Completed:Wait()

ScreenGui:Destroy()

-- DETECT GAME
local gameData = gameScripts[game.PlaceId]

if not gameData then
    kick("Game tidak support.")
    return
end

notif("STREE HUB","Loading "..gameData.name,3)

-- LOAD SCRIPT
local ok,err = pcall(function()

    local src = game:HttpGet(gameData.premium)

    if not src or src == "" then
        error("Script kosong")
    end

    loadstring(src)()

end)

if not ok then
    warn("Script Load Error:",err)
    kick("Script gagal load")
end

print("STREE HUB Loaded ✓")
