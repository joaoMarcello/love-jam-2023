local Component = require "scripts.component"

---@class Game.Component.Panel : GameComponent
local Panel = setmetatable({}, Component)
Panel.__index = Panel

---@param state GameState
function Panel:new(state, args)
    args = args or {}
    args.x = args.x or 64
    args.y = args.y or 64
    args.w = (32 * 3 * 4) - (32 * 2)
    args.h = (32 * 2 * 3) + (32 * 4)

    local obj = Component:new(state, args)
    setmetatable(obj, self)

    Panel.__constructor__(obj, state, self)

    return obj
end

---@param state GameState.Game|GameState
function Panel:__constructor__(state, args)
    self.gamestate = state

    self.ox = self.w / 2
    self.oy = self.h / 2
end

--==========================================================================
do
    function Panel:load()

    end

    function Panel:init()

    end

    function Panel:finish()

    end
end
--==========================================================================

function Panel:update(dt)
    Component.update(self, dt)
end

function Panel:my_draw()
    love.graphics.setColor(0, 0, 1, 0.2)
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)

    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle("line", self.x, self.y, self.w, self.h)
end

function Panel:draw()
    Component.draw(self, self.my_draw)
end

return Panel
