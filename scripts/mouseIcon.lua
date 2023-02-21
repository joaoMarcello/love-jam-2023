local Affectable = _G.JM_Affectable

---@enum MouseIcon.States
local States = {
    shock = 1,
    grab = 2,
    point = 3,
    prepare = 4
}

---@class MouseIcon : JM.Template.Affectable
local Icon = setmetatable({}, Affectable)
Icon.__index = Icon
Icon.States = States

function Icon:new(state, args)
    local obj = Affectable:new()
    setmetatable(obj, self)
    Icon.__constructor__(obj, state, args)
    return obj
end

---@param state GameState.Game
function Icon:__constructor__(state, args)
    self.gamestate = state
    self.x, self.y = state:get_mouse_position()
    self.w = 16
    self.h = 16

    self.state = States.prepare
end

function Icon:load()

end

function Icon:finish()

end

function Icon:get_color_state()
    local Utils = _G.JM_Utils

    if self.state == States.prepare then
        return Utils:get_rgba(1, 1, 1, 1)
    elseif self.state == States.point then
        return Utils:get_rgba(0, 0, 0, 1)
    elseif self.state == States.grab then
        return Utils:get_rgba(0, 0, 1, 1)
    elseif self.state == States.shock then
        return Utils:get_rgba(1, 1, 0, 1)
    end
end

function Icon:update(dt)
    Affectable.update(self, dt)

    self.x, self.y = self.gamestate:get_mouse_position()
end

function Icon:my_draw()
    love.graphics.setColor(self:get_color_state())
    love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)
end

function Icon:draw()
    Affectable.draw(self, self.my_draw)
end

return Icon
