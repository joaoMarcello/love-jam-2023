local Affectable = _G.JM_Affectable
local Font = _G.JM_Font

local string_format = string.format
local math_floor = math.floor

---@class Game.Component.Timer : JM.Template.Affectable
local Timer = setmetatable({}, Affectable)
Timer.__index = Timer

---@return Game.Component.Timer
function Timer:new()
    local obj = Affectable:new()
    setmetatable(obj, self)
    Timer.__constructor__(obj)
    return obj
end

function Timer:__constructor__()
    self.time_in_sec = 20
    self.speed = 1.0
    self.acumulator = 0.0
end

function Timer:init()

end

function Timer:load()

end

function Timer:finish()

end

--===========================================================================

function Timer:time_is_up()
    return self.time_in_sec <= 0.0
end

function Timer:minute()
    return math_floor(self.time_in_sec / 60)
end

function Timer:seconds(minutes)
    minutes = minutes or self:minute()
    local sec = math_floor(self.time_in_sec - minutes * 60)
    return sec
end

function Timer:get_time()
    local minutes = self:minute()
    local seconds = self:seconds(minutes)
    local dec = (self.time_in_sec - minutes * 60 - seconds) * 10

    return minutes, seconds, dec
end

function Timer:get_time2()
    local time = self.time_in_sec * 100
    local minute = math_floor(time / 6000)
    local seconds = (time - (minute * 6000)) / 100
    seconds = math_floor(seconds)
    local dec = time - minute * 6000 - seconds * 100

    return minute, seconds, dec
end

function Timer:update(dt)
    self.time_in_sec = self.time_in_sec - dt
    if self.time_in_sec < 0 then self.time_in_sec = 0 end
end

function Timer:draw()
    local min, sec, dec = self:get_time2()

    Font.current:push()
    Font.current:set_color(_G.JM_Utils:get_rgba(1, 1, 0, 1))
    Font:print(string_format("%.1f", self.time_in_sec), 500, 64)
    Font:print(string_format("%02d", min), 500, 90)
    Font:print(string_format("%02d", sec), 500, 130)
    Font:print(string_format("%02d", dec), 500, 160)

    local sm = string_format("%02d:%02d:%02d", min, sec, dec)
    Font:print(sm, 500, 200)

    Font.current:pop()
end

return Timer
