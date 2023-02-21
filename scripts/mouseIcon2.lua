local Component = require "scripts.component"

---@class MouseIcon2 : GameComponent
local Icon = setmetatable({}, Component)
Icon.__index = Icon

function Icon:new(state, args)
    args = args or {}
    args.w = 16
    args.h = 16

    local obj = Component:new(state, args)
    setmetatable(obj, self)
    Icon.__constructor__(obj, state, args)
    return obj
end

---@param state GameState
function Icon:__constructor__(state, args)
    self.gamestate = state
end

function Icon:load()

end

function Icon:finish()

end

function Icon:update(dt)
    Component.update(self, dt)

    local mx, my = self.gamestate:get_mouse_position()
    self.x, self.y = mx, my
end

function Icon:my_draw()
    love.graphics.setColor(0, 0, 1)
    love.graphics.circle("fill", self.x, self.y, 16)
end

function Icon:draw()
    Component.draw(self, self.my_draw)
end

return Icon
