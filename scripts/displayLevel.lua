local Affectable = _G.JM_Affectable

---@type JM.Font.Font
local font

---@class Game.Component.DisplayLvl : JM.Template.Affectable
local Display = setmetatable({}, Affectable)
Display.__index = Display

---@param state GameState.Game
function Display:new(state)
    local obj = Affectable:new()
    setmetatable(obj, self)
    Display.__constructor__(obj, state)
    return obj
end

---@param state GameState.Game
function Display:__constructor__(state)
    self.gamestate = state
    self.x = 32 * 16
    self.y = 32 * 1
    self.level = 1
    font = font or _G.FONT_LEVEL --state:game_get_gui_font()
end

function Display:load()

end

function Display:finish()

end

--=======================================================================
function Display:flick()
    local eff = self:apply_effect("flickering", { speed = 0.1, duration = 0.2 * 6 })
    eff:set_final_action(function()
        self:set_visible(true)
    end)
end

function Display:increment()
    self.level = self.level + 1
    self:flick()
end

function Display:get_value()
    return self.level
end

function Display:update(dt)
    Affectable.update(self, dt)
end

function Display:my_draw()
    font:printf(string.format("<color, 1, 1, 1> <bold> Level %02d", self.level), self.x, self.y, "right", self.x + 32 * 6)
end

function Display:draw()
    Affectable.draw(self, self.my_draw)
end

return Display
