local Affectable = _G.JM_Affectable
local Font = _G.JM_Font

local string_format = string.format
local math_floor = math.floor

---@type JM.Font.Font
local font

---@class Game.Component.Timer : JM.Template.Affectable
local Timer = setmetatable({}, Affectable)
Timer.__index = Timer

---@param state GameState.Game
---@return Game.Component.Timer
function Timer:new(state)
    local obj = Affectable:new()
    setmetatable(obj, self)
    Timer.__constructor__(obj, state)
    return obj
end

---@param state GameState.Game
function Timer:__constructor__(state)
    self.time_in_sec = 30 --60 * 1 + 30
    self.speed = 1.0
    self.acumulator = 0.0

    self.gamestate = state

    self.x = 32 * 16
    self.y = 32 * 3

    self.ox = (32 * 5) / 2
    self.oy = 32 + 16

    self.__lock = false

    if not font then
        font = state:game_get_gui_font()
    end
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

function Timer:flick()
    local eff = self:apply_effect("flickering", { speed = 0.1, duration = 0.2 * 6 })
    self.is_flick = true
    eff:set_final_action(function()
        self:set_visible(true)
        self.is_flick = false
    end)
end

function Timer:pulse()
    local eff = self:apply_effect("pulse", { range = 0.15, speed = 0.3, duration = 0.3 * 4 })
end

function Timer:increment(value)
    value = value or 0
    self.time_in_sec = self.time_in_sec + value
    if self.time_in_sec <= 0 then self.time_in_sec = 0 end

    if value > 0 then
        self:pulse()
    end
end

function Timer:decrement(value)
    value = -math.abs(value)
    self:increment(value)
    self:flick()
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

function Timer:lock(time)
    if not self.__lock then
        self.__lock = true
    end
end

function Timer:unlock()
    if self.__lock then self.__lock = false end
end

function Timer:pause(time)
    self.__pause = time or 0.5
    self:lock()
end

function Timer:update(dt)
    Affectable.update(self, dt)

    local panel = self.gamestate:game_get_panel()

    if self.__pause then
        self.__pause = self.__pause - dt
        if self.__pause <= 0 then
            self.__pause = false
            self:unlock()
        end
    end

    if not self.__lock and not panel:is_locked() then
        self.time_in_sec = self.time_in_sec - dt
        if self.time_in_sec < 0 then self.time_in_sec = 0 end
    end
end

function Timer:my_draw()
    local min, sec, dec = self:get_time2()

    font:push()
    font:set_color(_G.JM_Utils:get_rgba(1, 1, 0, 1))
    -- font:set_font_size(28)
    local sm = string_format("%02d:%02d:%02d", min, sec, dec)
    font:print(sm, self.x + 16, self.y + 32)
    font:pop()
end

function Timer:draw()
    Affectable.draw(self, self.my_draw)

    font:push()
    font:set_color(_G.JM_Utils:get_rgba(1, 1, 1, 1))
    font:set_font_size(font.__font_size - 6)
    font:print("TIME",
        self.x,
        self.y + 32 - font.__font_size - font.__line_space
    )
    font:pop()
end

return Timer
