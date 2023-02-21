local Component = require "scripts.component"

---@enum MouseIcon2.States
local States = {
    normal = 1,
    point = 2
}

---@class MouseIcon2 : GameComponent
local Icon = setmetatable({}, Component)
Icon.__index = Icon
Icon.States = States

---@return MouseIcon2
function Icon:new(state, args)
    args = args or {}
    args.w = 8
    args.h = 8

    local obj = Component:new(state, args)
    setmetatable(obj, self)
    Icon.__constructor__(obj, state, args)
    return obj
end

---@param state GameState
function Icon:__constructor__(state, args)
    self.gamestate = state

    self:set_state(States.normal)
end

function Icon:load()

end

function Icon:finish()

end

function Icon:set_state(state)
    if self.state == state then return end
    self.state = state
end

function Icon:update(dt)
    Component.update(self, dt)

    local mx, my = self.gamestate:get_mouse_position()
    self.x, self.y = mx, my
end

function Icon:my_draw()
    if self.state == States.normal then
        love.graphics.setColor(0, 0, 1)
    else
        love.graphics.setColor(1, 0, 0)
    end

    love.graphics.circle("fill", self.x, self.y, self.w)
end

function Icon:draw()
    Component.draw(self, self.my_draw)
end

return Icon
