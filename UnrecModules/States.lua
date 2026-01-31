--ESP
local esp_on = true
local esp_distance = 1000
local espCache = {}
--Injection
local Dexloaded = false
local Spyloaded = false
local Ketloaded = false
local Infloaded = false
--AntiAfk
local antiIdleActive = false
local idleConnection
--noclip
local noclipEnabled = false
local noclipConn
--walspeed
local speedEnabled = false
local originalSpeed
--jumppower
local jumpEnabled = false
local originalJump

--Violence District
local dAttaking = false
