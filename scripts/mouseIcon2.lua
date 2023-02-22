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

---@param state GameState
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

    local mx, my = self.gamestate:get_mouse_position()
    self.x, self.y = mx, my
    self.mx, self.my = self.x, self.y

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

function Icon:stay_on_bounds()
    local camera = self.gamestate.camera

    if self.y < 0 then self.y = 0 end
    if self.y > SCREEN_HEIGHT then self.y = SCREEN_HEIGHT end
    if self.x < camera.x then self.x = camera.x end
    if self.x > camera.x + SCREEN_WIDTH then
        self.x = camera.x + SCREEN_WIDTH
    end
end

function Icon:mouse_moved(x, y, dx, dy)
    local camera = self.gamestate.camera
    local scale = camera.desired_scale
    dx = dx / scale
    dy = dy / scale

    self.x, self.y = self.x + dx, self.y + dy

    self:stay_on_bounds()
end

function Icon:update(dt)
    Component.update(self, dt)

    -- local mx, my = self.gamestate:get_mouse_position()
    -- local dx, dy = mx - self.mx, my - self.my
    -- self.mx, self.my = mx, my

    -- self.x, self.y = self.x + dx, self.y + dy
end

function Icon:my_draw()
    if self.state == States.normal then
        love.graphics.setColor(0, 0, 1)
    else
        love.graphics.setColor(1, 0, 0)
    end

    -- love.graphics.circle("fill", self.x, self.y, self.w)
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
end

function Icon:draw()
    Component.draw(self, self.my_draw)
end

return Icon
