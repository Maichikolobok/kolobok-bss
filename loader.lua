--// Kolobok Loader v1.1 — Priority Job Monitor
local KEY = (...)
if not KEY or KEY == "" then warn("Использование: loadstring(...)('КЛЮЧ')") return end

local H = game:GetService("HttpService")
local P = game:GetService("Players")
local TS = game:GetService("TeleportService")
local LP = P.LocalPlayer
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

-- Определяем REDIS_PREFIX (такой же как у сетчеров)
local REDIS_PREFIX = KEY
local gr = C({"GET", "group:" .. KEY})
if gr and gr.result and gr.result ~= false then
    REDIS_PREFIX = gr.result
end

-- Priority Job Monitor — фоновый цикл
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
                local rarity = pJob.rarity or "?"
                local field = pJob.field or "?"
                local finder = pJob.finder or "?"

                warn("[Loader] PRIORITY: " .. rarity .. " @ " .. field .. " by " .. finder .. " → ТП!")

                pcall(function()
                    local old = game:GetService("CoreGui"):FindFirstChild("PriorityNotif")
                    if old then old:Destroy() end

                    local sg = Instance.new("ScreenGui")
                    sg.Name = "PriorityNotif"
                    sg.Parent = game:GetService("CoreGui")

                    local fr = Instance.new("Frame")
                    fr.Size = UDim2.new(0, 340, 0, 60)
                    fr.Position = UDim2.new(0.5, -170, 0.02, 0)
                    fr.BackgroundColor3 = Color3.fromRGB(60, 50, 10)
                    fr.BorderSizePixel = 0
                    fr.Parent = sg
                    Instance.new("UICorner", fr).CornerRadius = UDim.new(0, 10)

                    local tl = Instance.new("TextLabel")
                    tl.Size = UDim2.new(1, -12, 1, -8)
                    tl.Position = UDim2.new(0, 6, 0, 4)
                    tl.BackgroundTransparency = 1
                    tl.Text = "PRIORITY: " .. rarity .. " @ " .. field .. "\nby " .. finder .. " → Телепорт..."
                    tl.TextColor3 = Color3.fromRGB(255, 220, 50)
                    tl.TextSize = 14
                    tl.Font = Enum.Font.GothamBold
                    tl.TextWrapped = true
                    tl.Parent = fr
                end)

                task.wait(1)
                pcall(function()
                    TS:TeleportToPlaceInstance(PlaceId, pJob.jobId, LP)
                end)
            end
        end
    end
end)

local sr = C({"GET", "script:base"})
if not sr or not sr.result then E("СКРИПТ НЕ НАЙДЕН") return end

local fn = loadstring(sr.result)
if fn then
    fn(KEY)
else
    E("ОШИБКА ЗАГРУЗКИ СКРИПТА")
end
