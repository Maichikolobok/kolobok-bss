--// Kolobok Searcher Loader v2.1 — Global Config mode
local CFG = (type(getgenv) == "function" and getgenv().CONFIG) or CONFIG or {}
local WEBHOOK = (type(getgenv) == "function" and getgenv().WEBHOOK_URL) or WEBHOOK_URL or ""

if type(CFG) ~= "table" then CFG = {} end
if type(WEBHOOK) ~= "string" or WEBHOOK == "" then
    warn("[Searcher] WEBHOOK_URL не задан")
    return
end

local H = game:GetService("HttpService")
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

local sr = C({"GET", "script:searcher"})
if not sr or not sr.result then warn("[Searcher] СКРИПТ НЕ НАЙДЕН В UPSTASH") return end

local fn = loadstring(sr.result)
if fn then fn(CFG, WEBHOOK) else warn("[Searcher] ОШИБКА ЗАГРУЗКИ СКРИПТА") end
