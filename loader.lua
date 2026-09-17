--// Kolobok Loader v1.2 — Urgent priority for Legendary/Supreme
local KEY = (...)
if not KEY or KEY == "" then warn("Использование: loadstring(...)('КЛЮЧ')") return end

local H = game:GetService("HttpService")
local P = game:GetService("Players")
local LP = P.LocalPlayer
local TS = game:GetService("TeleportService")
local PlaceId = game.PlaceId

local U = "https://smooth-seasnail-173025.upstash.io"
local T = "gQAAAAAAAqPhAAIgcDFiNTNiMWYwMjk4NGI0OTkxYjBlMmIyZjllOTg1NzhlYQ"

local function R(o)
    local r = (syn and syn.request) or (http and http.request) or (fluxus and fluxus.request) or request
    if r then return r(o) end
    local s, b = pcall(function()
        if o.Method == "GET" then return H:GetAsync(o.Url)
        else return H:PostAsync(o.Url, o.Body or "", Enum.HttpContentType.ApplicationJson) end
    end)
    return {StatusCode = s and 200 or 500, Body = b}
end

local function C(cmd)
    local o, r = pcall(function()
        return R({Url=U, Method="POST", Headers={["Authorization"]="Bearer "..T, ["Content-Type"]="application/json"}, Body=H:JSONEncode(cmd)})
    end)
    if o and r and r.Body then
        local d, v = pcall(function() return H:JSONDecode(r.Body) end)
        if d then return v end
    end
end

local function GH()
    local h
    pcall(function() if gethwid then h = gethwid() end end)
    if not h then pcall(function() if identifyexecutor then h = identifyexecutor().."_"..tostring(LP.UserId) end end) end
    if not h then h = "fb_"..tostring(LP.UserId) end
    return h
end

local hw = GH()

local function E(m)
    pcall(function()
        local s = Instance.new("ScreenGui") s.Name = "KErr" s.Parent = game:GetService("CoreGui")
        local f = Instance.new("Frame") f.Size = UDim2.new(0,340,0,100) f.Position = UDim2.new(0.5,-170,0.4,0) f.BackgroundColor3 = Color3.fromRGB(180,30,30) f.BorderSizePixel = 0 f.Parent = s
        Instance.new("UICorner", f).CornerRadius = UDim.new(0,10)
        local t = Instance.new("TextLabel") t.Size = UDim2.new(1,-16,1,-16) t.Position = UDim2.new(0,8,0,8) t.BackgroundTransparency = 1 t.Text = m t.TextColor3 = Color3.new(1,1,1) t.TextSize = 18 t.Font = Enum.Font.GothamBold t.TextWrapped = true t.Parent = f
    end)
    warn("[Loader] " .. m)
end

-- Проверка ключа
local kr = C({"GET", "key:" .. KEY})
if not kr or not kr.result then E("КЛЮЧ НЕ НАЙДЕН") return end

local ok, kd = pcall(function() return H:JSONDecode(kr.result) end)
if not ok or not kd then E("ОШИБКА КЛЮЧА") return end

if kd.expires and kd.expires < os.time() then
    C({"DEL", "key:" .. KEY})
    E("КЛЮЧ ИСТЁК")
    return
end

if kd.hwid and kd.hwid ~= "" and kd.hwid ~= hw then
    E("КЛЮЧ ПРИВЯЗАН К ДРУГОМУ УСТРОЙСТВУ")
    return
end

if not kd.hwid or kd.hwid == "" then
    kd.hwid = hw
    C({"SET", "key:" .. KEY, H:JSONEncode(kd)})
end

-- Определение REDIS_PREFIX
local REDIS_PREFIX = KEY
local gr = C({"GET", "group:" .. KEY})
if gr and gr.result and gr.result ~= false then
    REDIS_PREFIX = gr.result
end

-- ========== PRIORITY MONITOR ==========
local function showNotification(pJob)
    pcall(function()
        local old = game:GetService("CoreGui"):FindFirstChild("PriorityNotif")
        if old then old:Destroy() end
    end)

    local isUrgent = pJob.urgent == true

    local sg = Instance.new("ScreenGui")
    sg.Name = "PriorityNotif"
    sg.ResetOnSpawn = false
    sg.Parent = game:GetService("CoreGui")

    local f = Instance.new("Frame")
    f.Size = UDim2.new(0, 380, 0, 90)
    f.Position = UDim2.new(0.5, -190, 0.15, 0)
    f.BorderSizePixel = 0
    f.Parent = sg
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 12)

    if isUrgent then
        f.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
    else
        f.BackgroundColor3 = Color3.fromRGB(30, 80, 160)
    end

    local rarityText = pJob.rarity or "?"
    local fieldText = pJob.field or "?"
    local finderText = pJob.finder or "?"

    local tl = Instance.new("TextLabel")
    tl.Size = UDim2.new(1, -16, 0, 30)
    tl.Position = UDim2.new(0, 8, 0, 8)
    tl.BackgroundTransparency = 1
    tl.TextColor3 = Color3.new(1, 1, 1)
    tl.TextSize = 18
    tl.Font = Enum.Font.GothamBold
    tl.TextXAlignment = Enum.TextXAlignment.Left
    tl.Parent = f

    if isUrgent then
        tl.Text = "URGENT: " .. rarityText
    else
        tl.Text = "НАЙДЕНО: " .. rarityText
    end

    local tl2 = Instance.new("TextLabel")
    tl2.Size = UDim2.new(1, -16, 0, 22)
    tl2.Position = UDim2.new(0, 8, 0, 38)
    tl2.BackgroundTransparency = 1
    tl2.Text = "Поле: " .. fieldText .. " | Нашёл: " .. finderText
    tl2.TextColor3 = Color3.fromRGB(220, 220, 220)
    tl2.TextSize = 13
    tl2.Font = Enum.Font.Gotham
    tl2.TextXAlignment = Enum.TextXAlignment.Left
    tl2.Parent = f

    local tl3 = Instance.new("TextLabel")
    tl3.Size = UDim2.new(1, -16, 0, 18)
    tl3.Position = UDim2.new(0, 8, 0, 60)
    tl3.BackgroundTransparency = 1
    tl3.TextSize = 12
    tl3.Font = Enum.Font.Code
    tl3.TextXAlignment = Enum.TextXAlignment.Left
    tl3.Parent = f

    if isUrgent then
        tl3.Text = "БРОСАЮ ВСЁ → ТЕЛЕПОРТ СЕЙЧАС!"
        tl3.TextColor3 = Color3.fromRGB(255, 200, 80)
    else
        tl3.Text = "Телепорт через 10 сек..."
        tl3.TextColor3 = Color3.fromRGB(180, 220, 255)
    end

    return sg, tl3
end

task.spawn(function()
    local lastJobId = nil

    while true do
        task.wait(5)

        local pOk, pResult = pcall(function()
            return C({"GET", REDIS_PREFIX .. ":priority_job"})
        end)

        if pOk and pResult and pResult.result and pResult.result ~= false then
            local dOk, pJob = pcall(function()
                return H:JSONDecode(pResult.result)
            end)

            if dOk and pJob and pJob.jobId and pJob.jobId ~= game.JobId and pJob.jobId ~= lastJobId then
                lastJobId = pJob.jobId
                local isUrgent = pJob.urgent == true

                local notifGui, countdownLabel = showNotification(pJob)

                if isUrgent then
                    task.wait(1)
                else
                    for i = 10, 1, -1 do
                        if countdownLabel then
                            countdownLabel.Text = "Телепорт через " .. i .. " сек..."
                        end
                        task.wait(1)
                    end
                end

                pcall(function()
                    TS:TeleportToPlaceInstance(PlaceId, pJob.jobId, LP)
                end)
            end
        end
    end
end)

-- Загрузка основного скрипта
local sr = C({"GET", "script:base"})
if not sr or not sr.result then E("СКРИПТ НЕ НАЙДЕН") return end

local fn = loadstring(sr.result)
if fn then
    fn(KEY)
else
    E("ОШИБКА ЗАГРУЗКИ СКРИПТА")
end
